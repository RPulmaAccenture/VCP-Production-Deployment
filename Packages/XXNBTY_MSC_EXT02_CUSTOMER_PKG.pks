CREATE OR REPLACE PACKAGE XXNBTY_MSCEXT02_CUSTOMER_PKG
AS
  --------------------------------------------------------------------------------------------
  /*
  Package Name: XXNBTY_MSCEXT02_CUSTOMER_PKG
  Author's Name: Jack Fabroada
  Date written: 17-Nov-2014
  RICEFW Object: EXT02
  Description: Package specification for EXT02- Customer Extension - Demantra Integration
  Program Style:
  Maintenance History:
  Date         Issue#  Name         Remarks
  -----------  ------  -----------  ------------------------------------------------
  17-Nov-2014          Jack Fabroada  Initial Development
  */
  --------------------------------------------------------------------------------------------
    
   PROCEDURE collect_cust_num(
    x_errbuf OUT VARCHAR2
    ,x_retcode OUT VARCHAR2);
    

	
END XXNBTY_MSCEXT02_CUSTOMER_PKG;

/
show errors;
