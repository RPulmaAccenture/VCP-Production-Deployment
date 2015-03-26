create or replace PACKAGE BODY XXNBTY_MSCEXT02_CUSTOMER_PKG
AS
  --------------------------------------------------------------------------------------------
  /*
  Package Name: XXNBTY_MSCEXT02_CUSTOMER_PKG
  Author's Name: Jack Fabroada
  Date written: 17-Nov-2014
  RICEFW Object: EXT01
  Description: Package body for EXT02- Customer Extension - Demantra Integration
  Program Style:
  Maintenance History:
  Date         Issue#  Name         Remarks
  -----------  ------  -----------  ------------------------------------------------
  17-Nov-2014          Jack Fabroada  Initial Development
  24-Feb-2015		   Daniel Rodil	  Modifled get dbLink as a cursor
  2-Mar-2015		   Daniel Rodil   Modified query and update as per the changes in the FD						  
  */
  --------------------------------------------------------------------------------------------

PROCEDURE        collect_cust_num(
    x_errbuf OUT VARCHAR2
    ,x_retcode OUT VARCHAR2)		
AS

  TYPE c_typ IS REF CURSOR;
  c_cus_num      c_typ;
  l_cus_num        msc_trading_partner_sites.attribute1%TYPE;
  l_srtp_site_id   msc_trading_partner_sites.sr_tp_site_id%TYPE;
  query_str        VARCHAR2(1000);
  dbLink           msc_apps_instances.M2A_DBLINK%TYPE;
  update_flag      BOOLEAN := FALSE;
  v_instance_id	   msc_apps_instances.INSTANCE_ID%TYPE;
  
  -- Get DB Link from VCP to EBS
  CURSOR c_dbLink
  IS
  SELECT mai.M2A_DBLINK, mai.INSTANCE_ID
    FROM msc_apps_instances mai
   WHERE mai.instance_code = 'EBS';
  
BEGIN

  -- Get DB Link from VCP to EBS
  OPEN c_dbLink;
  FETCH c_dbLink INTO dbLink, v_instance_id;
  CLOSE c_dbLink;
  
  -- SQL query to get the customer number from EBS to corresponding site ID in VCP 
  /*query_str := 'SELECT hps.party_site_name
					,mtps.sr_tp_site_id
				FROM hz_party_sites@'|| dbLink ||' hps,
					hz_cust_acct_sites_all@'|| dbLink ||' hcas, 
					msc_trading_partner_sites mtps
				WHERE hps.party_site_id = hcas.party_site_id
				AND hcas.cust_acct_site_id = mtps.sr_tp_site_id 
				AND mtps.partner_type = 2';
  */  
  -- 2-mar drodil updated the query based on the changes in FD
  -- 2-mar drodil added substr in the party_site_name as the attribute1 is 150 only while party_site_name is 240 in lenght
  query_str := 'SELECT substr(hps.party_site_name, 1,150)  
					,mtps.sr_tp_site_id
				FROM hz_party_sites@'|| dbLink ||' hps,
					hz_cust_acct_sites_all@'|| dbLink ||' hcas, 
					hz_cust_site_uses_all@'|| dbLink ||' hcsu, 
					msc_trading_partner_sites mtps
				WHERE hps.party_site_id = hcas.party_site_id
				AND hcas.cust_acct_site_id = hcsu.cust_acct_site_id
				AND hcsu.site_use_id = mtps.sr_tp_site_id 
				AND mtps.sr_instance_id = '|| v_instance_id ||'
				AND mtps.partner_type = 2';

				
  OPEN c_cus_num FOR query_str;
    LOOP
        FETCH c_cus_num INTO l_cus_num,l_srtp_site_id;
        EXIT WHEN c_cus_num%NOTFOUND;
        
        IF l_cus_num IS NULL THEN
          CONTINUE;
        ELSE  
          UPDATE msc_trading_partner_sites
          SET attribute1 = l_cus_num
          WHERE sr_tp_site_id = l_srtp_site_id
		  AND sr_instance_id = v_instance_id  -- 2-mar drodil updated based on the changes in FD
          AND partner_type = 2;
          update_flag := TRUE;          
        END IF;       
    END LOOP;
  CLOSE c_cus_num;
  
  IF  update_flag THEN      
    FND_CONCURRENT.AF_COMMIT;
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_errbuf  := sqlerrm;
    x_retcode := '2';
	
END collect_cust_num;

END XXNBTY_MSCEXT02_CUSTOMER_PKG;

/
show errors;
