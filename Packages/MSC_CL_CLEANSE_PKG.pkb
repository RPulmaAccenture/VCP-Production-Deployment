  CREATE OR REPLACE PACKAGE BODY "APPS"."MSC_CL_CLEANSE" AS -- body
/* $Header: MSCCLCAB.pls 120.0 2005/05/25 20:00:48 appldev noship $ */
/*
Package Name: MSC_CL_CLEANSE
Author's Name: Ronald Villavieja
Date written: 05-Dec-2014
RICEFW Object: LF19
Description: Package body for LF19 - Item cost.
Program Style: 

Maintenance History: 

Date			Issue#		Name					Remarks	
-----------		------		-----------				------------------------------------------------
05-Dec-2014				 	Ronald Villavieja		Modified the MSCCLCAB.pls


*/
--------------------------------------------------------------------------------------------


PROCEDURE CLEANSE( ERRBUF				OUT NOCOPY VARCHAR2,
	              RETCODE				OUT NOCOPY NUMBER,
                      pIID                              IN  NUMBER)
   IS
   f_num     number := 0;
   f_num_err number := 0;
   f_num_nup number := 0;
   f_dir     fnd_lookup_values.meaning%type;
   v_conc_req_id number;
   v_userid      number;
   v_gonogo      varchar2(1) := 'N';
   v_prev_log    varchar2(1000);
   BEGIN
   ---RRV10102014: Removing ABC Class Processes as per Ankit's email.
   ---RRV10062014: Removed other hook customizations. Only one remaining is for Cost and ABC Classes.
   ---RRV10062014: Load Flat file data to staging tables (BEGIN)
   --- Cost and ABC Initialization and flat file Load
    v_conc_req_id := fnd_global.conc_request_id;
    v_userid      := fnd_global.user_id;
   ---RRV11052014: Added condition wherein Hook will only run for LF19 Item Cost
	-- added to check in the staging table instead of the request set
	
	BEGIN
		Select 'Y'
		  into v_gonogo
		  from xxnbty_msc_costs_st
		 where status = 'N'
		   and rownum < 2;
	EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'**** Error Encountered Validating Staging table xxnbty_msc_costs_st. '||SQLERRM);
        RETCODE:=G_WARNING;    		   
	END;
	--
   
   IF v_gonogo = 'Y' THEN ----- Should only process for ITEM COST and not for other processes
	BEGIN
    DECLARE	
       v_inst msc_apps_instances.instance_code%type;
       v_cnt  number := 0;
    BEGIN
	
       FOR i_rec IN ( SELECT instance_code FROM msc_apps_instances
                       WHERE instance_id = pIID ) LOOP
          v_inst := i_rec.instance_code;
       END LOOP;
	   
       FOR upd_cst_rec IN ( SELECT xcct.rowid, xcct.* FROM xxnbty_msc_costs_st xcct
                             WHERE xcct.status = 'N') LOOP
           UPDATE xxnbty_msc_costs_st
              SET organization_code = v_inst||':'||organization_code,
                  request_id = v_conc_req_id
            WHERE rowid = upd_cst_rec.rowid;
           IF MOD(10000,500) = 0  THEN
              FND_CONCURRENT.AF_COMMIT;
          END IF;
       END LOOP; 
       FND_CONCURRENT.AF_COMMIT;
    END;
	
    DECLARE
	     v_found VARCHAR2(1) := 'N';
	  BEGIN
	  
	  ---RRV09102014: Processing COST (Begin)
	  ---RRV10102014: changing where clause to match against ORGANIZATION_CODE and ITEM_NAME
         FOR cost_rec IN ( SELECT cst.ROWID, cst.* FROM xxnbty_msc_costs_st cst where status = 'N' ) LOOP
		     FOR stgcost_rec IN (SELECT mssi.ROWID, mssi.* 
                               FROM msc.msc_st_system_items mssi
			                        WHERE mssi.organization_code   = cost_rec.organization_code
								                AND mssi.item_name           = cost_rec.item_name ) LOOP
			     UPDATE msc.msc_st_system_items
				    SET standard_cost = cost_rec.standard_cost
				  WHERE rowid = stgcost_rec.rowid;
					v_found := 'Y';
					f_num := NVL(f_num,0) + 1;
		     END LOOP;
			 
			 IF v_found = 'Y' THEN
			    UPDATE xxnbty_msc_costs_st
				   SET status = 'P'
				 WHERE rowid = cost_rec.rowid;
		     ELSIF v_found = 'N' THEN
			    UPDATE xxnbty_msc_costs_st
				   SET status = 'E',
				       error_description = 'Record not found in MSC_ST_SYSTEM_ITEMS.'
				WHERE rowid = cost_rec.rowid;
		     END IF;
			 v_found := 'N';
	     END LOOP;
		 v_found := 'N';
		 
	  ---RRV09102014: Processing COST (END)
     EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'**** Error encountered at Update Process. '||SQLERRM);
        --null;
     END;
   ---RRV09022014:Commit changes.
       FND_CONCURRENT.AF_COMMIT;
	   
   ---RRV10072014: Log error messages
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '=== '||RPAD('COST ',300,'='));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('ORGANIZATION CODE', 30, ' ')||' '||RPAD('SR INSTANCE ID', 30, ' ')||' '||RPAD('ITEM NAME',30, ' ')||' '||RPAD('STANDARD COST',20, ' ')||' '||RPAD('CREATION DATE',20, ' ')||' '||RPAD('SOURCE',15,' ')||' '||RPAD('STATUS', 10, ' ')||' '||RPAD('ERROR DESCRIPTION',200, ' '));
    
	FOR cost_err_rec IN ( SELECT  RPAD(organization_code,30,' ') AS sr_org_id
								, RPAD(' ',30,' ') as sr_inst_id
								, RPAD(item_name,30, ' ') AS sr_inv_itm_id
								, RPAD(standard_cost, 20, ' ') as std_cst
								, RPAD(creation_date,20,' ') as crt_dte
								, RPAD(source,15,' '), RPAD('COST', 15, ' ') AS cst
								, RPAD('ERROR', 10, ' ') AS stat
								, RPAD(error_description, 200, ' ') AS err_desc
                            FROM xxnbty_msc_costs_st
                           WHERE status = 'E' ) LOOP
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, cost_err_rec.sr_org_id||' '||cost_err_rec.sr_inst_id||' '||cost_err_rec.sr_inv_itm_id||' '||cost_err_rec.std_cst||' '||cost_err_rec.crt_dte||' '||cost_err_rec.cst||' '||cost_err_rec.stat||' '||cost_err_rec.err_desc);
		f_num_err := NVL(f_num_err,0) + 1;
    END LOOP;
	
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '=== '||RPAD('Total Cost Records With Errors : '||f_num_err||' ',300, '==='));
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '=== '||RPAD('Total Cost Records Successfully Updated : '||f_num||' ',300, '==='));
	
  ---RRV10262014 Log Data Pull data that were not updated
	  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
	  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '=== '||RPAD('ST SYSTEM ITEMS NOT UPDATED ',300,'='));

  FOR not_updated IN (SELECT ( RPAD(abl.ORGANIZATION_CODE, 30, ' ')||' '||RPAD(abl.SR_INSTANCE_ID, 30, ' ')||' '||RPAD(abl.ITEM_NAME, 30, ' ')||RPAD(abl.STANDARD_COST, 20, ' ')||RPAD('Record Not in Flat File', 200,' ') ) as err_log
                        FROM msc_st_system_items abl,
                             xxnbty_msc_costs_st bkr
                       WHERE abl.organization_code = bkr.organization_code
                         AND abl.item_name <> bkr.item_name
                         AND bkr.status = 'P' ) LOOP
     IF v_prev_log <> not_updated.err_log OR v_prev_log IS NULL THEN
--        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,not_updated.err_log); 
        f_num_nup := f_num_nup + 1;
     END IF;
     v_prev_log := not_updated.err_log;
  END LOOP;
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '=== '||RPAD('Total ST System Items Not Updated : '||f_num_nup||' ',300, '==='));

  RETCODE:= G_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'**** Error encountered at File Read procedure. '||SQLERRM);
        RETCODE:=G_WARNING;
  END;
  ELSE
    RETCODE := G_SUCCESS;
  END IF;
  
  END ;

   --This package will be called from the release code. Any data cleansing
   --can be performed while releasing the data to the source.
   --P_ENTITY          - Added for future use.
   --P_SR_INSTANCE_ID  - Instance Identifier
   --P_PO_BATCH_NUMBER - Identifier to process the relevant data.
PROCEDURE CLEANSE_RELEASE(  ERRBUF            OUT NOCOPY VARCHAR2,
                               RETCODE           OUT NOCOPY NUMBER,
                               P_ENTITY          IN  VARCHAR2,
                               P_SR_INSTANCE_ID  IN  NUMBER,
                               P_PO_BATCH_NUMBER IN  NUMBER)
   IS
   BEGIN
       RETCODE := G_SUCCESS;
 END;

END MSC_CL_CLEANSE;

/
show errors;
