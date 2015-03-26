#!/bin/bash
echo "Enter Username:"
read username
echo "Enter Password:"
read password

home=/home/nbtydata
top=$XXNBTY_TOP
bin_fndcpesr=/u01/oracle/apps/apps_st/appl/fnd/12.0.0/bin/fndcpesr

#executing all SQL files
sqlplus -s $username/$password <<eof
spool VCP_batch_deployment.log

prompt Executing script xxnbty_msc_costs_st_tab.sql
	@$top/sql/xxnbty_msc_costs_st_tab.sql
prompt Executing script xxnbty_msc_safety_stocks_st_tab.sql
	@$top/sql/xxnbty_msc_safety_stocks_st_tab.sql
prompt Executing script xxnbty_msc_spread_denorms_tab.sql
	@$top/sql/xxnbty_msc_spread_denorms_tab.sql

prompt Executing all packages
prompt 
prompt Executing script MSC_CL_CLEANSE_PKG.pks
	@$top/admin/sql/MSC_CL_CLEANSE_PKG.pks
prompt Executing script MSC_CL_CLEANSE_PKG.pkb
	@$top/admin/sql/MSC_CL_CLEANSE_PKG.pkb	
prompt Executing script XXNBTY_VCP_SEND_EMAIL_PKG.pks
	@$top/admin/sql/XXNBTY_VCP_SEND_EMAIL_PKG.pks	
prompt Executing script XXNBTY_VCP_SEND_EMAIL_PKG.pkb
	@$top/admin/sql/XXNBTY_VCP_SEND_EMAIL_PKG.pkb	
prompt Executing script XXNBTY_MSC_EXT01_ITEM_DESC_PKG.pks
	@$top/admin/sql/XXNBTY_MSC_EXT01_ITEM_DESC_PKG.pks	
prompt Executing script XXNBTY_MSC_EXT01_ITEM_DESC_PKG.pkb
	@$top/admin/sql/XXNBTY_MSC_EXT01_ITEM_DESC_PKG.pkb
prompt Executing script XXNBTY_MSC_EXT02_CUSTOMER_PKG.pks
	@$top/admin/sql/XXNBTY_MSC_EXT02_CUSTOMER_PKG.pks
prompt Executing script XXNBTY_MSC_EXT02_CUSTOMER_PKG.pkb
	@$top/admin/sql/XXNBTY_MSC_EXT02_CUSTOMER_PKG.pkb		
prompt Executing script XXNBTY_MSC_EXT03_SPREAD_EXT_PKG.pks
	@$top/admin/sql/XXNBTY_MSC_EXT03_SPREAD_EXT_PKG.pks	
prompt Executing script XXNBTY_MSC_EXT03_SPREAD_EXT_PKG.pkb
	@$top/admin/sql/XXNBTY_MSC_EXT03_SPREAD_EXT_PKG.pkb
prompt Executing script XXNBTY_MSC_EXT05_SAFETY_STK_PKG.pks
	@$top/admin/sql/XXNBTY_MSC_EXT05_SAFETY_STK_PKG.pks
prompt Executing script XXNBTY_MSC_EXT05_SAFETY_STK_PKG.pkb
	@$top/admin/sql/XXNBTY_MSC_EXT05_SAFETY_STK_PKG.pkb	


spool off
eof
echo "" >> VCP_batch_deployment.log

#setting permission for all user
echo "Setting permission for all user" >> VCP_batch_deployment.log
echo "" >> VCP_batch_deployment.log
##chmod 777 $home >> VCP_batch_deployment.log
##chmod 777 -R $home/VCP_RICEFW >> VCP_batch_deployment.log
chmod 777 $top/bin/XXNBTYVCPSENDEMAIL.prog >> $home/VCP_RICEFW/VCP_batch_deployment.log

chmod 777 $top/bin/lf19_int.ctl >> $home/VCP_RICEFW/VCP_batch_deployment.log
chmod 777 $top/bin/ext05.ctl >> $home/VCP_RICEFW/VCP_batch_deployment.log

chmod 777 $top/bin/XXNBTYLF10 >> $home/VCP_RICEFW/VCP_batch_deployment.log
chmod 777 $top/bin/XXNBTYLF11 >> $home/VCP_RICEFW/VCP_batch_deployment.log
chmod 777 $top/bin/XXNBTYLF14 >> $home/VCP_RICEFW/VCP_batch_deployment.log
chmod 777 $top/bin/XXNBTYLF16 >> $home/VCP_RICEFW/VCP_batch_deployment.log
chmod 777 $top/bin/XXNBTYLF17 >> $home/VCP_RICEFW/VCP_batch_deployment.log
chmod 777 $top/bin/XXNBTYLF19 >> $home/VCP_RICEFW/VCP_batch_deployment.log

cd $home/VCP_RICEFW
echo "Finished setting permission for all user" >> VCP_batch_deployment.log
echo "" >> VCP_batch_deployment.log

#converting all Unix files
echo "Converting all Unix files" >> VCP_batch_deployment.log
echo "" >> VCP_batch_deployment.log
dos2unix $top/bin/XXNBTYLF10 >> VCP_batch_deployment.log 2>&1
dos2unix $top/bin/XXNBTYLF11 >> VCP_batch_deployment.log 2>&1
dos2unix $top/bin/XXNBTYLF14 >> VCP_batch_deployment.log 2>&1
dos2unix $top/bin/XXNBTYLF16 >> VCP_batch_deployment.log 2>&1
dos2unix $top/bin/XXNBTYLF17 >> VCP_batch_deployment.log 2>&1
dos2unix $top/bin/XXNBTYLF19 >> VCP_batch_deployment.log 2>&1
dos2unix $top/bin/XXNBTYVCPSENDEMAIL.prog >> VCP_batch_deployment.log 2>&1

echo "" >> VCP_batch_deployment.log

#creating Symbolic Links
echo "Creating Symbolic links" >> VCP_batch_deployment.log
echo "" >> VCP_batch_deployment.log
cd $top/bin
ln -s $bin_fndcpesr XXNBTYVCPSENDEMAIL >> $home/VCP_RICEFW/VCP_batch_deployment.log 2>&1

cd $top/admin/import
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

#uploading all FND files
echo "Uploading all FND files" >> $home/VCP_RICEFW/VCP_batch_deployment.log
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

cd $top/admin/import
#function to upload concurrent program
function upload_cp(){
	echo "Uploading $1..." >> $home/VCP_RICEFW/VCP_batch_deployment.log
	FNDLOAD $username/$password 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct $1 CUSTOM_MODE=FORCE >> $home/VCP_RICEFW/VCP_batch_deployment.log 2>&1
}

#function to upload value set
function upload_vs(){
	echo "Uploading $1..." >> $home/VCP_RICEFW/VCP_batch_deployment.log
	FNDLOAD $username/$password 0 Y UPLOAD $FND_TOP/patch/115/import/afffload.lct $1 CUSTOM_MODE=FORCE >> $home/VCP_RICEFW/VCP_batch_deployment.log 2>&1
}

#function to upload request set
function upload_rs(){
	echo "Uploading $1..." >> $home/VCP_RICEFW/VCP_batch_deployment.log
	FNDLOAD $username/$password 0 Y UPLOAD $FND_TOP/patch/115/import/afcprset.lct $1 CUSTOM_MODE=FORCE >> $home/VCP_RICEFW/VCP_batch_deployment.log 2>&1
}

#function to upload request set links
function upload_rsl(){
	echo "Uploading $1..." >> $home/VCP_RICEFW/VCP_batch_deployment.log
	FNDLOAD $username/$password 0 Y UPLOAD $FND_TOP/patch/115/import/afcprset.lct $1 CUSTOM_MODE=FORCE >> $home/VCP_RICEFW/VCP_batch_deployment.log 2>&1
}

#function to upload request set group
function upload_rsg(){
	echo "Uploading $1..." >> $home/VCP_RICEFW/VCP_batch_deployment.log
	FNDLOAD $username/$password 0 Y UPLOAD $FND_TOP/patch/115/import/afcpreqg.lct $1 CUSTOM_MODE=FORCE >> $home/VCP_RICEFW/VCP_batch_deployment.log 2>&1
}

#function to upload lookup
function upload_lkp(){
	echo "Uploading $1..." >> $home/VCP_RICEFW/VCP_batch_deployment.log
	FNDLOAD $username/$password 0 Y UPLOAD $FND_TOP/patch/115/import/aflvmlu.lct $1 CUSTOM_MODE=FORCE >> $home/VCP_RICEFW/VCP_batch_deployment.log 2>&1
}



echo "Uploading Oracle Send Email" >> $home/VCP_RICEFW/VCP_batch_deployment.log
upload_vs XXNBTY_VCP_SEND_EMAIL_VS.ldt
upload_vs XXNBTY_VCP_PROCESS_ERROR_VS.ldt
upload_lkp XXNBTY_VCP_SEND_EMAIL_LT.ldt
upload_cp XXNBTY_VCP_SEND_EMAIL_CP.ldt
upload_cp XXNBTY_VCP_PROCESS_ERROR_CP.ldt
upload_rsg XXNBTY_VCP_SEND_EMAIL_RG.ldt
upload_rsg XXNBTY_VCP_PROCESS_ERROR_RG.ldt

echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "Uploading EXT01 - ITEM DESCRIPTION UPDATED IN ASCP" >> $home/VCP_RICEFW/VCP_batch_deployment.log
upload_vs XXNBTY_EXT01_VS.ldt
upload_cp XXNBTY_EXT01_CP.ldt
upload_rsg XXNBTY_EXT01_RG.ldt
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "Uploading EXT02 - CUSTOMER NUMBER COLLECTION" >> $home/VCP_RICEFW/VCP_batch_deployment.log
upload_cp XXNBTY_EXT02_CP.ldt
upload_rsg XXNBTY_EXT02_RG.ldt
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "Uploading EXT03 - Spread Forecast Extension" >> $home/VCP_RICEFW/VCP_batch_deployment.log
upload_vs XXNBTY_EXT03_VS.ldt
upload_cp XXNBTY_EXT03_CP.ldt
upload_rsg XXNBTY_EXT03_RG.ldt
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "Uploading LF10 - Supplies On Hand" >> $home/VCP_RICEFW/VCP_batch_deployment.log

upload_cp XXNBTY_LF10_CP.ldt
upload_rs XXNBTY_LF10_RS.ldt
upload_rsl XXNBTY_LF10_RL.ldt
upload_rsg XXNBTY_LF10_RG.ldt
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "Uploading LF11 - Supplies In Transit" >> $home/VCP_RICEFW/VCP_batch_deployment.log
upload_cp XXNBTY_LF11_CP.ldt
upload_rs XXNBTY_LF11_RS.ldt
upload_rsl XXNBTY_LF11_RL.ldt
upload_rsg XXNBTY_LF11_RG.ldt
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "Uploading LF14 - Work Order Supplies" >> $home/VCP_RICEFW/VCP_batch_deployment.log
upload_cp XXNBTY_LF14_CP.ldt
upload_rs XXNBTY_LF14_RS.ldt
upload_rsl XXNBTY_LF14_RL.ldt
upload_rsg XXNBTY_LF14_RG.ldt
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "Uploading LF16 - WIP Component Demand" >> $home/VCP_RICEFW/VCP_batch_deployment.log
upload_cp XXNBTY_LF16_CP.ldt
upload_rs XXNBTY_LF16_RS.ldt
upload_rsl XXNBTY_LF16_RL.ldt
upload_rsg XXNBTY_LF16_RG.ldt
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "Uploading LF17 - Sales Order" >> $home/VCP_RICEFW/VCP_batch_deployment.log
upload_cp XXNBTY_LF17_CP.ldt
upload_rs XXNBTY_LF17_RS.ldt
upload_rsl XXNBTY_LF17_RL.ldt
upload_rsg XXNBTY_LF17_RG.ldt
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "Uploading LF19 - Item Cost" >> $home/VCP_RICEFW/VCP_batch_deployment.log
upload_cp XXNBTY_LF19_CP_a.ldt
upload_cp XXNBTY_LF19_CP_b.ldt
upload_rs XXNBTY_LF19_RS.ldt
upload_rsl XXNBTY_LF19_RSL.ldt
upload_rsg XXNBTY_LF19_RG.ldt
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "Uploading EXT05 - Safety Stocks" >> $home/VCP_RICEFW/VCP_batch_deployment.log
upload_lkp XXNBTY_EXT05_LT_a.ldt
upload_lkp XXNBTY_EXT05_LT_b.ldt
upload_cp XXNBTY_EXT05_CP_a.ldt
upload_cp XXNBTY_EXT05_CP_b.ldt
upload_cp XXNBTY_EXT05_CP_c.ldt
upload_cp XXNBTY_EXT05_CP_d.ldt
upload_rs XXNBTY_EXT05_RS.ldt
upload_rsl XXNBTY_EXT05_RL.ldt
upload_rsg XXNBTY_EXT05_RG.ldt
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

echo "Uploading Sanjay Request Set" >> $home/VCP_RICEFW/VCP_batch_deployment.log
upload_rs XXNBTY_DAILY_PLANNING_REQUEST_RS.ldt
upload_rsl XXNBTY_DAILY_PLANNING_REQUEST_RL.ldt
upload_rsg XXNBTY_DAILY_PLANNING_REQUEST_RG.ldt
upload_rs XXNBTY_Planning_MPS_MRP_RS.ldt
upload_rsl XXNBTY_Planning_MPS_MRP_RL.ldt
upload_rsg XXNBTY_Planning_MPS_MRP_RG.ldt
upload_rs XXNBTY_WEEKLY_PLANNING_RS.ldt
upload_rsl XXNBTY_WEEKLY_PLANNING_RL.ldt
upload_rsg XXNBTY_WEEKLY_PLANNING_RG.ldt
upload_rs XXNBTYWEEKLYMPS_RS.ldt
upload_rsl XXNBTYWEEKLYMPS_RL.ldt
upload_rsg XXNBTYWEEKLYMPS_RG.ldt
upload_rs XXNBTYMONTHMPS_RS.ldt
upload_rsl XXNBTYMONTHMPS_RL.ldt
upload_rsg XXNBTYMONTHMPS_RG.ldt
upload_rs XXNBTY_MONTHLY_PLAN_RS.ldt
upload_rsl XXNBTY_MONTHLY_PLAN_RL.ldt
upload_rsg XXNBTY_MONTHLY_PLAN_RG.ldt
echo "" >> $home/VCP_RICEFW/VCP_batch_deployment.log

exit 0