CREATE OR REPLACE PACKAGE        "XXNBTY_VCP_SEND_EMAIL_PKG"

  --------------------------------------------------------------------------------------------
  /*
  Package Name: XXNBTY_VCP_SEND_EMAIL_PKG
  Author's Name: Mark Anthony Geamoga
  Date written: 19-Dec-2014
  RICEFW Object: N/A
  Description: Package will generate an error output file for all or specific VCP/EBS RICEFW.
				This output file will be sent to identified recipient(s) using UNIX program.
  Program Style:
  Maintenance History:
  Date         Issue#  Name         			Remarks
  -----------  ------  -------------------		------------------------------------------------
  19-Dec-2014          Mark Anthony Geamoga  	Initial Development
  */
  --------------------------------------------------------------------------------------------

IS
  g_with_error_msg  BOOLEAN := FALSE;

  --main procedure that will call another procedure to generate error log
  PROCEDURE send_email_main (x_retcode             OUT VARCHAR2,
                             x_errbuf              OUT VARCHAR2,
                             p_ricefw_name            VARCHAR2,
                             p_allow_send_if_no_error VARCHAR2);

  --procedure that will send access error log file and send it to recepients using lookups
  PROCEDURE generate_email (x_retcode   OUT VARCHAR2,
                            x_errbuf    OUT VARCHAR2,
                            p_ricefw_name  VARCHAR2,
                            p_new_filename VARCHAR2,
                            p_old_filename VARCHAR2,
                            p_lookup_name  VARCHAR2);

  --procedure to generate error log per ricefw using FND_FILE
  PROCEDURE generate_err_log (x_retcode   OUT VARCHAR2,
                              x_errbuf    OUT VARCHAR2,
                              p_ricefw_name VARCHAR2,
                              p_width       NUMBER);

END XXNBTY_VCP_SEND_EMAIL_PKG;

/

show errors;
