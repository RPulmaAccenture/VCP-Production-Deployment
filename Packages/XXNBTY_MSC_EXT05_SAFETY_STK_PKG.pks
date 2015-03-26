create or replace PACKAGE        "XXNBTY_MSCEXT05_SAFETY_STK_PKG" 
--------------------------------------------------------------------------------------------
/*
Package Name: XXNBTY_MSCEXT05_SAFETY_STK_PKG
Author's Name: Mark Anthony Geamoga
Date written: 16-Jan-2015
RICEFW Object: EXT05
Description: This program validates records from staging table (xxnbty_msc_safety_stocks_st) to base table (MSC_SAFETY_STOCKS).
             It will generate Safety Stocks error report and send it to recipients.
             It will generate Safety Stocks report and send it to recipient(s) after data validation.
Program Style: 

Maintenance History: 

Date			Issue#		Name					Remarks	
-----------		------		-----------				------------------------------------------------
16-Jan-2015				 	Mark Anthony Geamoga	Initial Development

*/
--------------------------------------------------------------------------------------------
IS
  g_last_updated_by   NUMBER(15);
  g_created_by        NUMBER(15);

  TYPE stg_rec_type       IS RECORD (     org                          xxnbty_msc_safety_stocks_st.org%TYPE
                                    ,item                         xxnbty_msc_safety_stocks_st.item%TYPE
                                    ,period_start_date            xxnbty_msc_safety_stocks_st.period_start_date%TYPE
                                );
  TYPE sfty_rec_type      IS RECORD (         plan_id                  msc_safety_stocks.plan_id%TYPE
                                  ,      organization_id          msc_safety_stocks.organization_id%TYPE
                                  ,      sr_instance_id           msc_safety_stocks.sr_instance_id%TYPE
                                  ,      inventory_item_id        msc_safety_stocks.inventory_item_id%TYPE
                                  ,      period_start_date        msc_safety_stocks.period_start_date%TYPE
                                  ,      safety_stock_quantity    msc_safety_stocks.safety_stock_quantity%TYPE
                                  ,      last_update_date         msc_safety_stocks.last_update_date%TYPE
                                  ,      last_updated_by          msc_safety_stocks.last_updated_by%TYPE
                                  ,      creation_date            msc_safety_stocks.creation_date%TYPE
                                  ,      created_by               msc_safety_stocks.created_by%TYPE
                                  ,      user_defined_safety_stocks  msc_safety_stocks.user_defined_safety_stocks%TYPE
                                  ,      user_defined_dos         msc_safety_stocks.user_defined_dos%TYPE
                                );
                                
  TYPE stg_tab_type    IS TABLE OF stg_rec_type;  
  TYPE sfty_tab_type   IS TABLE OF sfty_rec_type;
  TYPE stocks_tab_type IS TABLE OF msc_safety_stocks%ROWTYPE;
  
  g_stg                    stg_tab_type;
  g_stocks                 stocks_tab_type;
  g_sfty	                   sfty_tab_type;
    
  --main procedure that will execute subprocedures for the generation of report
  PROCEDURE safety_stocks_main_pr (x_retcode             OUT VARCHAR2, 
                     x_errbuf              OUT VARCHAR2);
  
  --subprocedure that will validate Safety Stocks from staging table
  PROCEDURE validate_safety_stocks (x_retcode             OUT VARCHAR2, 
                                    x_errbuf              OUT VARCHAR2);
  
  --subprocedure that will transfer Safety Stocks from staging to base table
  PROCEDURE insert_safety_stocks (x_retcode             OUT VARCHAR2, 
                                  x_errbuf              OUT VARCHAR2);
  
  --subprocedure that will generate error output file. 
  PROCEDURE generate_error_report (x_retcode             OUT VARCHAR2, 
                                   x_errbuf              OUT VARCHAR2);
                                   
  --subprocedure that will generate error output file.
  PROCEDURE get_error_report ( x_retcode             OUT VARCHAR2, 
                               x_errbuf              OUT VARCHAR2,
                               x_request_id         OUT NUMBER);                              
 
  --subprocedure that will generate Safety Stocks report
  PROCEDURE generate_report (x_retcode             OUT VARCHAR2, 
                             x_errbuf              OUT VARCHAR2,
                             x_request_id         OUT NUMBER);
                        
  --subprocedure that will send Safety Stocks report to recipient(s) from the lookups
  PROCEDURE generate_email (x_retcode   OUT VARCHAR2, 
                            x_errbuf    OUT VARCHAR2,
                            p_new_filename VARCHAR2,
                            p_old_filename VARCHAR2,
                            p_subject      VARCHAR2,
                            p_message      VARCHAR2,
                            p_lookup_name  VARCHAR2); 
  
END XXNBTY_MSCEXT05_SAFETY_STK_PKG;
/
show errors;
