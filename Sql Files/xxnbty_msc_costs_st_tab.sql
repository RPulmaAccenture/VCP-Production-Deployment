--------------------------------------------------------------------------------------------------------
/*
	Table Name: XXNBTY_MSC_COSTS_ST																		
	Author's Name: Ronald Villavieja																				
	Date written: 06-Oct-2014																						
	RICEFW Object: LF19																								
	Description: Staging Table for LF19-Item Cost.																
	Program Style: 																									
																													
	Maintenance History:																							
																													
	Date			Issue#		Name			Remarks																
	-----------		------		-----------		------------------------------------------------					
	06-Oct-2014				 	Ronald Villavieja		Initial Development			
	6-Mar-2015					Erwin Ramos					Update the schema of apps to xxnbty. 
															Added the [PUBLIC SYNONYM xxnbty_msc_costs_st] command.	
*/
--------------------------------------------------------------------------------------------------------

  CREATE TABLE xxnbty.xxnbty_msc_costs_st
   (	CREATION_DATE DATE
	,CREATED_BY NUMBER
	,LAST_UPDATE_DATE DATE	
	,LAST_UPDATED_BY NUMBER
	,LAST_UPDATE_LOGIN NUMBER
	,REQUEST_ID NUMBER
	,SOURCE VARCHAR2(25) 
	,TEMPLATE_NAME VARCHAR2(100) 
	,RECORD_ID NUMBER
	,STATUS VARCHAR2(25) DEFAULT 'N'
	,ERROR_DESCRIPTION VARCHAR2(2000) 
	,ORGANIZATION_CODE VARCHAR2(100 )
	,ITEM_NAME VARCHAR2(250)
	,SR_ORGANIZATION_ID VARCHAR2(100 ) 
	,SR_INSTANCE_ID VARCHAR2(100)
	,SR_INVENTORY_ITEM_ID VARCHAR2(100 ) 
	,STANDARD_COST NUMBER
	);

--[PUBLIC SYNONYM xxnbty_msc_costs_st]
CREATE OR REPLACE PUBLIC SYNONYM xxnbty_msc_costs_st for xxnbty.xxnbty_msc_costs_st;