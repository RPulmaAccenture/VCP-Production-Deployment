--------------------------------------------------------------------------------------------------------
/*
	Table Name: xxnbty_msc_safety_stocks_st																		
	Author's Name: Mark Anthony Geamoga																				
	Date written: 16-Jan-2015																							
	RICEFW Object: EXT05																								
	Description: Staging Table for EXT05-Safety Stocks.																
	Program Style: 																									
																													
	Maintenance History:																							
																													
	Date			Issue#		Name						Remarks																
	-----------		------		-----------					------------------------------------------------					
	16-Jan-2015				 	Mark Anthony Geamoga		Initial Development		
	6-Mar-2015					Erwin Ramos					Update the schema of apps to xxnbty. 
															Added the [PUBLIC SYNONYM xxnbty_msc_safety_stocks_st] command.
*/			
--------------------------------------------------------------------------------------------------------

CREATE TABLE xxnbty.xxnbty_msc_safety_stocks_st 
(
ITEM                        VARCHAR2 (250)  -- Item Number 
,ORG                         VARCHAR2 (7)	-- Organization Code e.g. EBS:045
,PERIOD_START_DATE			      DATE
,USER_DEFINED_SAFETY_STOCKS	NUMBER
,USER_DEFINED_DOS				    NUMBER		
,PROCESS_FLAG                NUMBER
,ERROR_DESCRIPTION           VARCHAR2 (240)
,LAST_UPDATE_DATE				    DATE
,LAST_UPDATED_BY				      NUMBER
,CREATION_DATE				        DATE
,CREATED_BY					        NUMBER
,LAST_UPDATE_LOGIN 					NUMBER
);

--[PUBLIC SYNONYM xxnbty_msc_safety_stocks_st]
CREATE OR REPLACE PUBLIC SYNONYM xxnbty_msc_safety_stocks_st for xxnbty.xxnbty_msc_safety_stocks_st;
