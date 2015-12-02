% Enter your studyId
studyId = '<your studyId>';

% Database settings
% Enter correct database host, port and SID
username = 'tm_data'
password = 'tm_data'
host = '<host>'
sid='<SID>'
port=1521

% SQL query to get data from database
sqlQuery = strcat('SELECT data_value, sample_cd FROM tm_data.studies_clinical_values WHERE study_id =''', studyId, ''' AND sample_cd IS NOT NULL');

% Connecting to database
conn = database(sid,username,password,'Vendor','Oracle',...
				'DriverType','thin','Server', host, 'PortNumber',port);
setdbprefs('DataReturnFormat','cellarray');

% Getting data from database (using cursor)
disp(sqlQuery);
curs = exec(conn, sqlQuery);
curs = fetch(curs);
sqlRes = cell2table(curs.Data);
close(curs);

% Converting SQL result to arrays
% Creating structures
ts_data = sqlRes{:,1}; % getting values
ts_values = cellfun(@str2double, ts_data); % converting type of values to double

ts_dates = sqlRes{:,2}; % getting dates

% Creating timeseries object
timeSeries = timeseries(ts_values, ts_dates, 'name', 'test');

% Output timeSeries
disp(timeSeries)
plot(timeSeries)