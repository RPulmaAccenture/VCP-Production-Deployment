--------------------------------------------------------------------------------------------------------
/*
	Table Name: xxnbty_msc_denorms_deleted																		
	Author's Name: Mark Anthony Geamoga																				
	Date written: 1-Dec-2014																							
	RICEFW Object: EXT03																								
	Description: Staging Table for EXT03-Safety Stocks.																
	Program Style: 																									
																													
	Maintenance History:																							
																													
	Date			Issue#		Name						Remarks																
	-----------		------		-----------					------------------------------------------------					
	1-Dec-2014				 	Mark Anthony Geamoga		Initial Development	
	6-Mar-2015					Erwin Ramos					Update the schema of apps to xxnbty. 
															Added the [PUBLIC SYNONYM xxnbty_msc_denorms_deleted] command.

*/			
--------------------------------------------------------------------------------------------------------

CREATE TABLE xxnbty.xxnbty_msc_denorms_deleted 
(
   demand_plan_id                  NUMBER      NOT NULL        
  ,scenario_id                     NUMBER      NOT NULL
  ,demand_id                       NUMBER      NOT NULL
  ,bucket_type                     NUMBER        
  ,start_time                      DATE          
  ,end_time                        DATE          
  ,quantity                        NUMBER        
  ,sr_organization_id              NUMBER        
  ,sr_instance_id                  NUMBER        
  ,sr_inventory_item_id            NUMBER        
  ,error_type                      VARCHAR2(30)  
  ,forecast_error                  NUMBER        
  ,inventory_item_id               NUMBER        
  ,sr_ship_to_loc_id               NUMBER        
  ,sr_customer_id                  NUMBER        
  ,sr_zone_id                      NUMBER        
  ,priority                        NUMBER        
  ,dp_uom_code                     VARCHAR2(10)  
  ,ascp_uom_code                   VARCHAR2(10)  
  ,demand_class                    VARCHAR2(240) 
  ,unit_price                      NUMBER        
  ,creation_date                   DATE         NOT NULL
  ,created_by                      NUMBER       NOT NULL
  ,last_update_login               NUMBER        
  ,request_id                      NUMBER        
  ,program_application_id          NUMBER        
  ,program_id                      NUMBER        
  ,program_update_date             DATE          
  ,pf_name                         VARCHAR2(250) 
  ,mape_in_sample                  NUMBER        
  ,mape_out_sample                 NUMBER        
  ,forecast_volatility             NUMBER        
  ,avg_demand                      NUMBER
);

--[PUBLIC SYNONYM xxnbty_msc_denorms_deleted]
CREATE OR REPLACE PUBLIC SYNONYM xxnbty_msc_denorms_deleted for xxnbty.xxnbty_msc_denorms_deleted;
