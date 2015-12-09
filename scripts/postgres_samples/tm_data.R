require(RPostgreSQL)

# database settings
default.db.name <- "transmart"
default.db.username <-"postgres"
default.db.password <-"postgres"
default.db.connection.host <-"localhost"
default.db.connection.port <- "5432"

# creating connection to postgreSQL database
get.connection <- function(db.connection.host=default.db.connection.host,
							db.connection.port=default.db.connection.port,
							db.username=default.db.username,
							db.password=default.db.password,
							db.name=default.db.name) {
	db.connection <- dbConnect(PostgreSQL(),
							host=db.connection.host,
							port=db.connection.port,
							user=db.username,
							password=db.password,
							dbname=db.name)
	# return connection object
	db.connection
}

# test function for getting patients' subject identifiers
get.patients.subjects <- function() {
	
	# getting database connection
	db.connection <- get.connection()
	
	# getting result set with studies
	rs <- dbSendQuery(db.connection, "SELECT DISTINCT patient_num, subject_id FROM tm_data.studies_patients")
	
	#fetching all data from result set as data.frame
	data <- fetch(rs,n=-1)
	
	# closing connection
	dbDisconnect(db.connection)
	
	# returning data
	data
}

# calling our function
get.patient.subjects()