CREATE OR REPLACE PACKAGE "APPS"."MSC_CL_CLEANSE" AUTHID CURRENT_USER AS 
/* $Header: MSCCLCAB.pls 120.0 2005/05/25 20:00:48 appldev noship $ */
----------------------------------------------------------------------------------------------
/*
Package Name: MSC_CL_CLEANSE
Author's Name: Ronald Villavieja
Date written: 05-Dec-2014
RICEFW Object: LF19
Description: Package specs for LF19 - Item cost.
Program Style: 

Maintenance History: 

Date			Issue#		Name					Remarks	
-----------		------		-----------				------------------------------------------------
05-Dec-2014				 	Ronald Villavieja		Modified the MSCCLCAB.pls


*/
--------------------------------------------------------------------------------------------
  

  ----- CONSTANTS --------------------------------------------------------

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

   PROCEDURE CLEANSE( ERRBUF				OUT NOCOPY VARCHAR2,
	              RETCODE				OUT NOCOPY NUMBER,
                      pIID                              IN  NUMBER);

   PROCEDURE CLEANSE_RELEASE(  ERRBUF            OUT NOCOPY VARCHAR2,
                               RETCODE           OUT NOCOPY NUMBER,
                               P_ENTITY          IN  VARCHAR2,
                               P_SR_INSTANCE_ID  IN  NUMBER,
                               P_PO_BATCH_NUMBER IN  NUMBER);

END MSC_CL_CLEANSE;

/
show errors;
