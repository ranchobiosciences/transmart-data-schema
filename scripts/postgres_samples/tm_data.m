% Enter your studyId
studyId = '<your studyId>';

% Database settings
% Enter correct database host, port
dbname = 'transmart'
username = 'postgres'
password = 'postgres'
host = '<host>'
port=5432

% SQL query to get data from database
sqlQuery = strcat('SELECT subject_id, data_value  FROM tm_data.studies_clinical_values WHERE study_id =''', studyId, ''' AND subject_id IS NOT NULL');

% Connecting to database
conn = database(dbname,username,password,...
				'Vendor','PostgreSQL',...
				'DriverType','thin',...
				'Server', host, 'PortNumber',port);
setdbprefs('DataReturnFormat','cellarray');

% Getting data from database (using cursor)
disp(sqlQuery);
curs = exec(conn, sqlQuery);
curs = fetch(curs);
sqlRes = cell2table(curs.Data);
close(curs);
close(conn);

% Converting SQL result to arrays
% Creating structures
sql_subjects = sqlRes{:,1}; % getting subject_ids

sql_data = sqlRes{:,2}; % getting values
sql_values = cellfun(@str2double, sql_data); % converting type of values to double