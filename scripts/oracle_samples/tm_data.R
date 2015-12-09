require(ROracle)

# default database settings
default.db.username <- "tm_data"
default.db.password <- "tm_data"
default.db.connection.string <-"host:port/sid" # Enter correct database host, port and SID

# creating connection to oracle database
get.connection <- function(db.connection.string=default.db.connection.string,
									db.username=default.db.username,
									db.password=default.db.password) {
	db.connection <- dbConnect(Oracle(),
								username=db.username,
								password=db.password,
								dbname=db.connection.string)
	
	# return database connection object
	db.connection
}

# processing all routines to output timeseries data
get.subject_ids <- function(study_id, study_attribute) {
	
	# getting database connection
	db.connection <- get.connection()
	
	# reading data from database
	data <- get.data(db.connection, study_id, study_attribute)
	
	# creating data structures
	subject_ids <- data.frame(values=data[,2])
	
	# closing connection
	dbDisconnect(db.connection)
	
	# return subject_ids
	subjects_ids
}

# getting data from database
get.data <- function(db.connection, study_id, study_attribute) {
	query <- paste(
		'SELECT v.STUDY_ID, v.SUBJECT_ID, v.DATA_TYPE, v.DATA_VALUE, a.CLINICAL_ATTRIBUTE FROM TM_DATA.STUDIES_CLINICAL_VALUES_MAT v ',
		'INNER JOIN TM_DATA.STUDIES_CLINICAL_ATTRIBUTES a ON a.CONCEPT_CD = v.CONCEPT_CD ',
		'WHERE ',
			'a.CLINICAL_ATTRIBUTE = \'',study_attribute,'\' ',
			'AND v.study_id =\'', study_id, '\'', 
		sep=''
	)
	
	# saving data as dataframe structure
	data <- as.data.frame(dbGetQuery(db.connection,query))
	
    #return data    
	data
}

# calling our function
get.subject_ids('study','study_attribute')