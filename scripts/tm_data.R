require(ROracle)

# default database settings (start)
default.db.username <- "tm_data"
default.db.password <- "tm_data"
default.db.connection.string <-"host:port/sid" # Enter correct database host, port and SID

# creating connection to oracle databse
# Run this function first to get database access!
connect.database.tm_data <- function(db.connection.string=default.db.connection.string, db.username=default.db.username, db.password=default.db.password) {
	db.connection <- dbConnect(Oracle(), username=db.username, password=db.password, dbname=db.connection.string)
}

# processing all routines to output timeseries data
load.timeseries.data <- function(study_id) {
	# reading data from database
	connect.database.tm_data();
	src.data <- get.data(study_id);
	data <- format(src.data, digits=20)

	# creating data structures
	dlong <- data.frame(values=data[,1])
	values <- data.frame(values=data[,2])
	dates <-  data.frame(dates=data[,3])
	
	d1 <- as.vector(dates$dates)
	pdates <- as.POSIXct(d1)

	nvalues <- as.vector(as.numeric(values$values))
	
	require(xts)
	# getting nvalues as extensible time series
	ts <- xts(nvalues, order.by=pdates)
	# output plot of timeseries
	plot(ts)
}

# getting data from database
get.data <- function(study_id) {
	query <- paste(
		'SELECT v.sample_cd_long, v.data_value, v.sample_cd_date FROM STUDIES_CLINICAL_VALUES_MAT v ',
		'INNER JOIN STUDIES_CLINICAL_ATTRIBUTES a ON a.CONCEPT_CD = v.CONCEPT_CD ',
		'WHERE ',
			'a.CLINICAL_ATTRIBUTE = \'\\path\\to\\study\\attribute\\\' ',
			'AND v.study_id =\'', study_id, '\'', 
		sep=''
	)
	# saving data as dataframe structure
	data <- as.data.frame(dbGetQuery(db.connection,query))
    #return data    
	data
}

# creating timseries data from file
create.timeseries.data <- function(filename) {
	time.series.data <- scan(filename);
	ts(time.series.data);
}
