OPTIONS (SKIP=1)
LOAD DATA
INFILE 'XXNBTY_MANUAL_SS.csv'
TRUNCATE
INTO TABLE xxnbty_msc_safety_stocks_st
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
		 ITEM								
		,ORG								
		,PERIOD_START_DATE				
		,USER_DEFINED_SAFETY_STOCKS			
		,USER_DEFINED_DOS							
		,CREATION_DATE	SYSDATE
		,LAST_UPDATE_DATE	SYSDATE
		,CREATED_BY	CONSTANT '-1'
		,LAST_UPDATED_BY CONSTANT '-1'
		,LAST_UPDATE_LOGIN CONSTANT '-1'
)