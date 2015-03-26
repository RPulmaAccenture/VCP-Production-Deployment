CREATE OR REPLACE PACKAGE XXNBTY_MSCEXT01_ITEM_DESC_PKG
AS
  --------------------------------------------------------------------------------------------
  /*
  Package Name: XXNBTY_MSCEXT01_ITEM_DESC_PKG
  Author's Name: Jack Fabroada
  Date written: 08-Dec-2014
  RICEFW Object: EXT01
  Description: Package specification for EXT01 - Item description
  Program Style:
  Maintenance History:
  Date         Issue#  Name         Remarks
  -----------  ------  -----------  ------------------------------------------------
  08-Dec-2014          Jack Fabroada  Initial Development
  */
  --------------------------------------------------------------------------------------------
  PROCEDURE update_item_desc_proc(
      x_errbuf OUT VARCHAR2 
      ,x_retcode OUT NUMBER 
      ,p_reprocess IN VARCHAR2 DEFAULT 'YES' );
      
      
END XXNBTY_MSCEXT01_ITEM_DESC_PKG;

/
show errors;
