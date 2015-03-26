--------------------------------------------------------------------------------------------
/*
Script Name: xxnbty_vcp_grant_command_all_tables
Date written: 10-Mar-2015	
RICEFW Object: N/A
Description: Grant command of all VCP staging tables to APPS user.
Program Style: 

Maintenance History: 

Date			Issue#		Name					Remarks	
-----------		------		-----------				------------------------------------------------
10-Mar-2015				 	Erwin Ramos				Initial Development


*/
--------------------------------------------------------------------------------------------
DECLARE 

BEGIN 
	EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, DELETE, UPDATE ON xxnbty.xxnbty_msc_costs_st TO APPS'; 
	EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, DELETE, UPDATE ON xxnbty.xxnbty_msc_safety_stocks_st TO APPS'; 
	EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, DELETE, UPDATE ON xxnbty.xxnbty_msc_denorms_deleted TO APPS'; 
END; 
/
show errors;
