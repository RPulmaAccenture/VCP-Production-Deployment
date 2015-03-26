CREATE OR REPLACE PACKAGE BODY XXNBTY_MSCEXT03_SPREAD_EXT_PKG
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
  24-Feb-2015		  Daniel Rodil			Modified to pass the bucket type and base forecast
											c_monthly_bucket_type to c_bucket_type and = NVL(p_mon_wk_bucket_type,3)
											c_base_forecast = NVL(p_base_forecast,5556984)
  3-Mar-2015		  Erwin Ramos			Changed the SQLERRM to 2
  6-Mar-2015		  Erwin Ramos			Update the apps.xxnbty_msc_denorms_deleted to xxnbty_msc_denorms_deleted.
	
  */
  --------------------------------------------------------------------------------------------

PROCEDURE       past_due_forecast 
				( x_errbuf OUT VARCHAR2
                 ,x_retcode OUT VARCHAR2
                 ,p_calendar IN msc.msc_calendars.calendar_code%TYPE
				 ,p_mon_wk_bucket_type IN msd.msd_dp_scn_entries_denorm.bucket_type%TYPE
				 ,p_base_forecast IN msd.msd_dp_scn_entries_denorm.scenario_id%TYPE )

IS
  TYPE forecast_type       IS TABLE OF msd.msd_dp_scn_entries_denorm%ROWTYPE;

  l_mon_forecast        forecast_type;
  l_daily_forecast      forecast_type;

  l_max_demand_id       msd.msd_dp_scn_entries_denorm.demand_id%TYPE;
  l_demand_id           msd.msd_dp_scn_entries_denorm.demand_id%TYPE;
  l_ctr_inserted        NUMBER := 0;
  l_ctr_deleted         NUMBER := 0;
  l_ctr_no_calendar     NUMBER := 0;

  c_bucket_type 		NUMBER := NVL(p_mon_wk_bucket_type,3); --3        --constant variable for bucket type
  c_base_forecast       NUMBER := NVL(p_base_forecast,5556984); -- 5556984; --constant variable for base forecast
  c_limit				NUMBER := 10000;

  --cursor to retrieve monthly forecast for conversion
  CURSOR c_mon_forecast ( p_bucket_type  msd.msd_dp_scn_entries_denorm.bucket_type%TYPE,
                          p_scenario_id  msd.msd_dp_scn_entries_denorm.scenario_id%TYPE,
                          p_date_limit   msd.msd_dp_scn_entries_denorm.start_time%TYPE )
  IS SELECT *
       FROM msd.msd_dp_scn_entries_denorm
      WHERE bucket_type = p_bucket_type
        AND scenario_id = p_scenario_id
        AND TRUNC(start_time) <= TRUNC(p_date_limit)
      ORDER BY start_time, quantity;

  --cursor that will generate daily forecast
  CURSOR c_daily_forecast ( p_monthly_forecast  msd.msd_dp_scn_entries_denorm%ROWTYPE,
                            p_max_demand_id     msd.msd_dp_scn_entries_denorm.demand_id%TYPE,
                            p_calendar_code     msc.msc_calendars.calendar_code%TYPE)
  IS SELECT  p_monthly_forecast.demand_plan_id
      ,      p_monthly_forecast.scenario_id
      ,      (p_max_demand_id + ROWNUM)
      ,      1
      ,      b.calendar_date
      ,      b.calendar_date + 1
             --compute quantity per daily bucket type
      ,      CEIL(p_monthly_forecast.quantity / MAX(ROWNUM) KEEP (DENSE_RANK LAST ORDER BY b.calendar_date) OVER (PARTITION BY a.sr_instance_id))
      ,      p_monthly_forecast.sr_organization_id
      ,      p_monthly_forecast.sr_instance_id
      ,      p_monthly_forecast.sr_inventory_item_id
      ,      p_monthly_forecast.error_type
      ,      p_monthly_forecast.forecast_error
      ,      p_monthly_forecast.inventory_item_id
      ,      p_monthly_forecast.sr_ship_to_loc_id
      ,      p_monthly_forecast.sr_customer_id
      ,      p_monthly_forecast.sr_zone_id
      ,      p_monthly_forecast.priority
      ,      p_monthly_forecast.dp_uom_code
      ,      p_monthly_forecast.ascp_uom_code
      ,      p_monthly_forecast.demand_class
      ,      p_monthly_forecast.unit_price
      ,      p_monthly_forecast.creation_date
      ,      p_monthly_forecast.created_by
      ,      p_monthly_forecast.last_update_login
      ,      p_monthly_forecast.request_id
      ,      p_monthly_forecast.program_application_id
      ,      p_monthly_forecast.program_id
      ,      p_monthly_forecast.program_update_date
      ,      p_monthly_forecast.pf_name
      ,      p_monthly_forecast.mape_in_sample
      ,      p_monthly_forecast.mape_out_sample
      ,      p_monthly_forecast.forecast_volatility
      ,      p_monthly_forecast.avg_demand
     FROM msc.msc_calendars a, msc.msc_calendar_dates b
    WHERE a.calendar_code = b.calendar_code
      AND a.calendar_code = p_calendar_code
      AND a.sr_instance_id = b.sr_instance_id
      AND a.sr_instance_id = p_monthly_forecast.sr_instance_id
      AND b.calendar_date BETWEEN p_monthly_forecast.start_time AND p_monthly_forecast.end_time
      AND b.seq_num IS NOT NULL --exclude weekends
    ORDER BY b.seq_num;

BEGIN
  --delete backup but remain at least two months backup
  DELETE
    FROM xxnbty_msc_denorms_deleted
   WHERE start_time < (SELECT ADD_MONTHS(MAX(start_time),-1)      --get latest month exported but not greater than SYSDATE minus 1 month
                         FROM msd.msd_dp_scn_entries_denorm
                        WHERE bucket_type = c_bucket_type --Monthly/weekly bucket type
                          AND scenario_id = c_base_forecast       --Base Forecast
                          AND TRUNC(start_time) <= TRUNC(SYSDATE));

  --get maximum demand id
  SELECT NVL(MAX(demand_id),0)
    INTO l_max_demand_id
    FROM msd.msd_dp_scn_entries_denorm;

  l_demand_id := l_max_demand_id;

  --select all monthly past due forecast
  OPEN c_mon_forecast ( c_bucket_type, --Monthly/weekly bucket type
                        c_base_forecast,       --Base Forecast
                        SYSDATE                --limit to current and previous months
                      );
  LOOP
  FETCH c_mon_forecast BULK COLLECT INTO l_mon_forecast LIMIT c_limit;
    FOR i IN 1..l_mon_forecast.COUNT
    LOOP
      --select all calendar dates for the month excluding all weekends and other exceptions
      OPEN c_daily_forecast ( l_mon_forecast(i),
                              l_demand_id,
                              p_calendar
                            );
      LOOP
      FETCH c_daily_forecast BULK COLLECT INTO l_daily_forecast LIMIT c_limit;

        FORALL ii IN 1..l_daily_forecast.COUNT
          INSERT INTO msd.msd_dp_scn_entries_denorm VALUES l_daily_forecast(ii);

      l_demand_id := l_demand_id + l_daily_forecast.COUNT; --update demand id for the next monthly forecast

      IF l_daily_forecast.COUNT = 0 THEN
        l_ctr_no_calendar := l_ctr_no_calendar + 1; --count all monthly forecast with no calendar setup
      ELSE
        --backup monthly past due forecast before deleting
        INSERT INTO xxnbty_msc_denorms_deleted VALUES l_mon_forecast(i);
        l_ctr_deleted := l_ctr_deleted + 1; --count all backed up monthly forecast
      END IF;

      EXIT WHEN c_daily_forecast%NOTFOUND;
      END LOOP;
      CLOSE c_daily_forecast;

    COMMIT;
    END LOOP;
    EXIT WHEN c_mon_forecast%NOTFOUND;
  END LOOP;
  CLOSE c_mon_forecast;

  --delete all monthly forecast that have been converted
  DELETE
    FROM msd.msd_dp_scn_entries_denorm a
   WHERE EXISTS (SELECT 1
                   FROM xxnbty_msc_denorms_deleted b
                  WHERE b.demand_id = a.demand_id
                    AND b.bucket_type = a.bucket_type
                    AND b.scenario_id = a.scenario_id
                    AND b.sr_instance_id = a.sr_instance_id
                    AND b.sr_organization_id = a.sr_organization_id
                    AND b.sr_inventory_item_id = a.sr_inventory_item_id);
  COMMIT;

  l_ctr_inserted := l_demand_id - l_max_demand_id; --count all inserted records

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Total of '|| TO_CHAR(l_ctr_no_calendar, 'fm999,999,999,999,999') || ' record(s) has/have no calendar setup.');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Total of '|| TO_CHAR(l_ctr_deleted, 'fm999,999,999,999,999') || ' record(s) has/have been converted and deleted.');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Total of '|| TO_CHAR(l_ctr_inserted, 'fm999,999,999,999,999') || ' record(s) has/have been inserted in DENORM table.');

EXCEPTION
   WHEN OTHERS THEN
      x_errbuf := SQLCODE;
      x_retcode := 2;
END past_due_forecast;

END XXNBTY_MSCEXT03_SPREAD_EXT_PKG;
/

show errors;
