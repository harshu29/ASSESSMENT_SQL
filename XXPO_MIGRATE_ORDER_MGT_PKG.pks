CREATE OR REPLACE PACKAGE BCM.XXPO_MIGRATE_ORDER_MGT_PKG AS
/* $Header: MIGRATE_ORDER_MGT_PKG.sql-SPEC 1.0 2022/07/20 $ */
----------------------------------------------------------------------
-- VERSION      : 1.0   
-- PROGRAM      : MIGRATE_ORDER_MGT_PKG.sql
-- DATE         : 21/07/2022 
-- DESCRIPTION  : Migration of data from table XXBCM_ORDER_MGT 
-- AUTHOR       : H.RAMDOWAR           
---------------------------------------------------------------------- 

PROCEDURE main;
PROCEDURE INSERT_SUPPLIER;
PROCEDURE INSERT_ORDER_HEADER;
PROCEDURE INSERT_ORDER_LINE;
PROCEDURE INSERT_INVOICE;
        

FUNCTION remove_alpha(P_SOURCE IN VARCHAR2) RETURN VARCHAR2;

END;