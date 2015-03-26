CREATE OR REPLACE PACKAGE BODY XXNBTY_MSCEXT01_ITEM_DESC_PKG
AS
  --------------------------------------------------------------------------------------------
  /*
  Package Name: XXNBTY_MSCEXT01_ITEM_DESC_PKG
  Author's Name: Jack Fabroada
  Date written: 08-Dec-2014
  RICEFW Object: EXT01
  Description: Package body for EXT01 - Item description
  Program Style:
  Maintenance History:
  Date         Issue#  Name         	Remarks
  -----------  ------  --------------  	------------------------------------------------
  08-Dec-2014          Jack Fabroada  	Initial Development

  */
  --------------------------------------------------------------------------------------------

PROCEDURE update_item_desc_proc
(
    x_errbuf          OUT VARCHAR2
  , x_retcode         OUT NUMBER
  , p_reprocess IN VARCHAR2 DEFAULT 'YES'
) AS


 --------------------------------------------------------------------------------------------
  /*
  Procedure Name: update_item_desc_proc
  Author's Name: Jack Fabroada
  Date written: 08-Dec-2014
  RICEFW Object: EXT01
  Description: Procedure for update item description
  Program Style:
  Maintenance History:
  Date         Issue#  Name         	Remarks
  -----------  ------  --------------  	------------------------------------------------
  08-Dec-2014          Jack Fabroada  	Initial Development
  17-Feb-2015		   Erwin Ramos		Updated the p_reprocess to UPPER case to address case sensitive. 
										Modifled get dbLink as a cursor
  */
  --------------------------------------------------------------------------------------------


  TYPE description_rec_type    IS RECORD (plan_id              msc_system_items.plan_id%TYPE
                                     ,sr_instance_id       msc_system_items.sr_instance_id%TYPE
                                     ,organization_id      msc_system_items.organization_id%TYPE
                                     ,inventory_item_id    msc_system_items.inventory_item_id%TYPE
                                     ,item_name            msc_system_items.item_name%TYPE
                                     ,description          msc_system_items.description%TYPE
                                     ,part_number          NUMBER
                                     ,prefix               VARCHAR2 (150) 
                                     ,suffix               VARCHAR2 (150) 
                                     ,concat_desc          VARCHAR2 (240) );

  TYPE description_tab_type    IS TABLE OF description_rec_type;

  t_items                 description_tab_type;
  c_items               SYS_REFCURSOR;
  query_str               VARCHAR2(3000);
  dbLink                  MSC_APPS_INSTANCES.M2A_DBLINK%TYPE;
  v_err_msg               VARCHAR2(100);

  num_of_successful       NUMBER := 0;
  num_of_errored_rec      NUMBER := 0;
  c_limit                 CONSTANT NUMBER := 10000;
  v_p_reprocess			VARCHAR2(3) := UPPER(p_reprocess);
  
  
  -- Get DB Link from VCP to EBS
  CURSOR c_dbLink
  IS
  SELECT mai.M2A_DBLINK
    FROM msc_apps_instances mai
   WHERE mai.instance_code = 'EBS';

BEGIN
  -- Get DB Link from VCP to EBS
  OPEN c_dbLink;
  FETCH c_dbLink INTO dbLink;
  CLOSE c_dbLink;
  

-- Query string for cursor to get the data from EBS and concatenate to the Item description in VCP.
  query_str := 'SELECT msi.plan_id
                      ,msi.sr_instance_id
                      ,msi.organization_id
                      ,msi.inventory_item_id
                      ,msi.item_name
                      ,msi.description
                      ,ebsa.part_number
                      ,ebsa.prefix
                      ,ebsa.suffix
                      ,''('' || DECODE(ebsa.prefix, NULL, '''', ebsa.prefix||''-'') || ebsa.part_number || DECODE(ebsa.suffix, NULL, '''', ''-''||ebsa.suffix) || '') '' || msi.description item_desc
                 FROM msc_system_items msi,
                      (SELECT msib.segment1,
                              MAX(DECODE(eagv.attr_group_name, ''NBTY_LEGACY_MAIN_ATTR'', emsieb.n_ext_attr1,
                                                            ''NBTY_LEGACY_PACKAGING_MAIN_ATT'', emsieb.n_ext_attr1,
                                                            NULL)) part_number,
                              MAX(DECODE(eagv.attr_group_name, ''NBTY_LEGACY_BULK_MAIN_ATTR'', emsieb.c_ext_attr4,
                                                            ''NBTY_LEGACY_PACKAGING_MAIN_ATT'', emsieb.c_ext_attr1,
                                                            NULL)) prefix,
                              MAX(DECODE(eagv.attr_group_name, ''NBTY_LEGACY_FG_MAIN_ATTR'', emsieb.c_ext_attr2,
                                                            NULL)) suffix
                         FROM apps.ego_mtl_sy_items_ext_b@'|| dbLink ||' emsieb
                              ,apps.ego_attr_groups_v@'|| dbLink ||' eagv
                              ,apps.mtl_system_items_b@'|| dbLink ||' msib     --table that contains item name (SEGMENT1) which can be used to join with the ITEM_NAME in MSC_SYSTEM_ITEMS (VCP)
                        WHERE eagv.attr_group_id = emsieb.attr_group_id
                          AND msib.inventory_item_id = emsieb.inventory_item_id
                          AND msib.organization_id = emsieb.organization_id
                          AND eagv.attr_group_name IN (''NBTY_LEGACY_PACKAGING_MAIN_ATT'',
                                                    ''NBTY_LEGACY_MAIN_ATTR'',
                                                    ''NBTY_LEGACY_FG_MAIN_ATTR'',
                                                    ''NBTY_LEGACY_BULK_MAIN_ATTR'')
                        GROUP BY msib.segment1) ebsa
                WHERE msi.item_name = ebsa.segment1
                  AND msi.plan_id = -1
                  AND ((attribute1 = ''0'' AND ''' || v_p_reprocess  || ''' = ''YES'')
                       OR (attribute1 IS NULL AND ''' || v_p_reprocess || ''' = ''NO''))';

  OPEN c_items FOR query_str;
  LOOP
    FETCH c_items BULK COLLECT INTO t_items LIMIT c_limit;

    FOR i IN 1..t_items.COUNT
    LOOP
  
      IF t_items(i).part_number IS NULL THEN --No Part Number
        num_of_errored_rec := num_of_errored_rec + 1; --count records with error
        v_err_msg := 'No Part Number found.';

        --generate log output for each records with error
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '----------------------------------------------');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'Oracle Item #: '            || t_items(i).item_name);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'Oracle Item Description: '  || t_items(i).description);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'AS400 Part #: '             || t_items(i).part_number);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'Primary Suffix: '           || t_items(i).suffix);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'Purchasing Prefix: '        || t_items(i).prefix);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'Error Message: '            || v_err_msg);
      ELSE --only 1 record is queried and with Part Number
        v_err_msg := NULL;
        num_of_successful := num_of_successful + 1;        --count processed records
      END IF;

      -- when v_err_msg is null, update the description with the concatenated item desc and attribute1 to 1.
      -- when v_err_msg is not null, then update attribute1 to 0
      UPDATE msc_system_items 
         SET description = DECODE(NVL(v_err_msg,'NULL'), 'NULL', t_items(i).concat_desc, description)
                          ,attribute1 = DECODE(NVL(v_err_msg, 'NULL'), 'NULL','1',0)
                          ,attribute2 = v_err_msg
        WHERE plan_id           = t_items(i).plan_id
         AND  sr_instance_id    = t_items(i).sr_instance_id
         AND  inventory_item_id = t_items(i).inventory_item_id
   --      AND  item_name         = t_items(i).item_name;                --additional criteria to address Defect 82 (NBTY Site)
         AND organization_id    = t_items(i).organization_id;
  
    END LOOP;
    
    FND_CONCURRENT.AF_COMMIT;
    
    EXIT WHEN c_items%NOTFOUND;
  END LOOP;
  CLOSE c_items;

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '----------------------------------------------');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'Number of records successfully updated: ' || TO_CHAR( num_of_successful, '999,999,999') );
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'Number of errored records: ' || TO_CHAR( num_of_errored_rec, '999,999,999') );

  num_of_successful  := 0;
  num_of_errored_rec := 0;

EXCEPTION
  WHEN OTHERS THEN
    x_errbuf  := SQLERRM;
    x_retcode := 2;
END update_item_desc_proc;

END XXNBTY_MSCEXT01_ITEM_DESC_PKG;

/
show errors;

