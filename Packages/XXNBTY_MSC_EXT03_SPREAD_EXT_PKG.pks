CREATE OR REPLACE PACKAGE XXNBTY_MSCEXT03_SPREAD_EXT_PKG
AS
  --------------------------------------------------------------------------------------------
  /*
  Package Name: XXNBTY_MSCEXT03_SPREAD_EXT_PKG
  Author's Name: Mark Anthony Geamoga
  Date written: 1-Dec-2014
  RICEFW Object: EXT03
  Description: This package will convert monthly/weekly past due forecast to daily bucket based on the defined working days from the manufacturing calendar.
  Program Style:
  Maintenance History:
  Date         Issue#  Name         		Remarks
  -----------  ------  -----------------	------------------------------------------------
  1-Dec-2014          Mark Anthony Geamoga  Initial Development
  24-Feb-2014		  Daniel Rodil			Modified to pass the bucket type and base forecast
  */
  --------------------------------------------------------------------------------------------
    
	PROCEDURE past_due_forecast 
				( x_errbuf OUT VARCHAR2
                 ,x_retcode OUT VARCHAR2
                 ,p_calendar IN msc.msc_calendars.calendar_code%TYPE
				 ,p_mon_wk_bucket_type IN msd.msd_dp_scn_entries_denorm.bucket_type%TYPE
				 ,p_base_forecast IN msd.msd_dp_scn_entries_denorm.scenario_id%TYPE );
    

	
END XXNBTY_MSCEXT03_SPREAD_EXT_PKG;
/
show errors;
