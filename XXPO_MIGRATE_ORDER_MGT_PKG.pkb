CREATE OR REPLACE PACKAGE BODY BCM.XXPO_MIGRATE_ORDER_MGT_PKG AS                                                                                     
/* $Header: MIGRATE_ORDER_MGT_PKG.sql-SPEC 1.0 2022/07/21 $ */
----------------------------------------------------------------------
-- VERSION      : 1.0   
-- PROGRAM      : MIGRATE_ORDER_MGT_PKG.sql
-- DATE         : 21/07/2022 
-- DESCRIPTION  : Migration of data from table XXBCM_ORDER_MGT 
-- AUTHOR       : H.RAMDOWAR           
----------------------------------------------------------------------                                                                              
                                                                                                                                             
-- Global variables (g__...)                                                                                                        
                                                                                                                                           
  g_package             VARCHAR2(30)  := 'XXPO_MIGRATE_ORDER_MGT_PKG';                                                              
  g_sqlerrm             VARCHAR2(250) := NULL;         
                                                                                    

/*==========================================================================================*/
/* Function       : remove_alpha                                                            */
/* Description    : Removal of alphabets present (in amount and contact number)             */
/* Remarks        : Replace o with 0 and I with 1 and S with 5                              */                                                      
/*==========================================================================================*/
FUNCTION remove_alpha(P_SOURCE IN VARCHAR2) RETURN VARCHAR2
    AS 
    v_target      VARCHAR2(1000);
    BEGIN
    v_target := '';

    select REPLACE(P_SOURCE,'o','0') into v_target from dual;
    select REPLACE(v_target,'I','1') into v_target  from dual;
    select REPLACE(v_target,'S','5') into v_target  from dual;

    RETURN v_target;
    END;



PROCEDURE main IS                                                                                                                           

    BEGIN                                                                                                                                        
        --Calling of the different procedures defined 
        DBMS_OUTPUT.PUT_LINE('Execution of package ' || g_package|| ' started!'); 
        INSERT_SUPPLIER;
        INSERT_INVOICE;
        INSERT_ORDER_HEADER;
        INSERT_ORDER_LINE;        
        
        COMMIT;                                                                                                                                     
    EXCEPTION                                                                                                                                    
    WHEN OTHERS THEN                                                                                                                          
        G_sqlerrm := SUBSTR(SQLERRM,1,200);                                                                                                    
        
        DBMS_OUTPUT.PUT_LINE('Error migrating data!');      
        DBMS_OUTPUT.PUT_LINE('Cause : ' ||g_sqlerrm);                 
        ROLLBACK;                                                                                                                              


    END main;                                                                                                                                    

/*==========================================================================================*/
/* Procedure      : INSERT_SUPPLIER                                                         */
/* Description    : Insertion of supplier data into supplier table                          */
/* Remarks        : Only data not existing in table supplier is added (to avoid duplicates) */                                                      
/*==========================================================================================*/

PROCEDURE INSERT_SUPPLIER IS                                                                                                          

    n_count_supplier_tab     NUMBER := 0 ;                                                                                                     

    BEGIN                                                                                                                                        

        DBMS_OUTPUT.PUT_LINE('Start inserting into table XXBCM_SUPPLIER!');                                     
        INSERT INTO BCM.XXBCM_SUPPLIER
        (
            SUPP_REF
            ,NAME
            ,CONTACT_NAME
            ,ADDRESS
            ,CONTACT_NUM_1
            ,CONTACT_NUM_2
            ,EMAIL   
        )
        SELECT
            'SUP_' || lpad (SUPPLIER_SEQ.nextval, 3, '0' )  AS SUPP_REF --defining a unique reference for supplier
            ,SUPPLIER_NAME
            ,SUPP_CONTACT_NAME
            ,SUPP_ADDRESS
            ,CONTACT_NUM_1
            ,CONTACT_NUM_2
            ,SUPP_EMAIL
            FROM
            (
                SELECT 
                DISTINCT
                om.SUPPLIER_NAME
                ,om.SUPP_CONTACT_NAME
                ,om.SUPP_ADDRESS      
                ,REPLACE(REGEXP_SUBSTR(om.SUPP_CONTACT_NUMBER,'[0123456789 ]+',1,1),' ','') CONTACT_NUM_1
                ,REMOVE_ALPHA(REGEXP_REPLACE(REPLACE(om.SUPP_CONTACT_NUMBER,REGEXP_SUBSTR(om.SUPP_CONTACT_NUMBER,'[0123456789 ]+',1,1),''),'[, .]')) CONTACT_NUM_2	 
                ,om.SUPP_EMAIL
                FROM BCM.XXBCM_ORDER_MGT om
                where  1=1
                AND NOT EXISTS (SELECT 1 FROM BCM.XXBCM_SUPPLIER s  WHERE s.NAME = om.SUPPLIER_NAME)
            ) sup;
                    
        SELECT COUNT(1)                                                                                                                              
        INTO n_count_supplier_tab                                                                                                                        
        FROM BCM.XXBCM_SUPPLIER;                                                                                                      

        DBMS_OUTPUT.PUT_LINE('Insertion into table XXBCM_SUPPLIER completed.'); 
        DBMS_OUTPUT.PUT_LINE('Number of rows into table XXBCM_SUPPLIER: ' || n_count_supplier_tab); 

    END INSERT_SUPPLIER;   


/*==============================================================================================*/
/* Procedure      : INSERT_ORDER_HEADER                                                         */
/* Description    : Insertion of purchase order header details into order header table          */
/* Remarks        : Only data not existing in table order header is added (to avoid duplicates) */                                                     
/*==============================================================================================*/
PROCEDURE INSERT_ORDER_HEADER IS                                                                                                          

    n_count_orderHeader_tab     NUMBER := 0 ;                                                                                                     

    BEGIN                                                                                                                                        

        DBMS_OUTPUT.PUT_LINE('Start inserting into table XXBCM_ORDER_HEADER!');                                     
        INSERT INTO BCM.XXBCM_ORDER_HEADER
        (
            HEADER_REF, 
            ORDER_DATE, 
            TOTAL_AMT, 
            DESCRIPTION, 
            STATUS, 
            PERIOD,
            SUPP_REF  
        )
        SELECT
            om.ORDER_REF
            ,TO_DATE(om.ORDER_DATE, 'DD-MM-YY', 'NLS_DATE_LANGUAGE = American') AS ORDER_DATE
            ,TO_NUMBER(REPLACE(om.ORDER_TOTAL_AMOUNT, ',','')) AS TOTAL_AMT
            ,om.ORDER_DESCRIPTION      
            ,om.ORDER_STATUS 		 
            ,LTRIM(TO_DATE(om.ORDER_DATE, 'DD-MM-YY', 'NLS_DATE_LANGUAGE = American'), '0123456789-') AS PERIOD
            ,(SELECT s.SUPP_REF FROM BCM.XXBCM_SUPPLIER s WHERE s.NAME = om.SUPPLIER_NAME) AS  SUPP_REF            
            FROM BCM.XXBCM_ORDER_MGT om
            WHERE 1=1
            AND ORDER_REF NOT LIKE '%-%'
            AND NOT EXISTS (SELECT 1 FROM BCM.XXBCM_ORDER_HEADER oh WHERE oh.HEADER_REF = om.ORDER_REF);
                   
        SELECT COUNT(1)                                                                                                                              
        INTO n_count_orderHeader_tab                                                                                                                        
        FROM BCM.XXBCM_ORDER_HEADER;                                                                                                      

        DBMS_OUTPUT.PUT_LINE('Insertion into table XXBCM_ORDER_HEADER completed.'); 
        DBMS_OUTPUT.PUT_LINE('Number of rows into table XXBCM_ORDER_HEADER: ' || n_count_orderHeader_tab); 

    END INSERT_ORDER_HEADER;                                                                                                                    

/*==============================================================================================*/
/* Procedure      : INSERT_ORDER_LINE                                                           */
/* Description    : Insertion of purchase order line details into order line table              */
/* Remarks        : Only data not existing in table order line is added (to avoid duplicates)   */                                                     
/*==============================================================================================*/
PROCEDURE INSERT_ORDER_LINE IS                                                                                                          

    n_count_orderLine_tab     NUMBER := 0 ;                                                                                                     

    BEGIN                                                                                                                                        

        DBMS_OUTPUT.PUT_LINE('Start inserting into table XXBCM_ORDER_LINE!');                                     
        INSERT INTO BCM.XXBCM_ORDER_LINE
        (
            HEADER_REF,
            LINE_REF, 
            DESCRIPTION, 
            LINE_AMT,
            STATUS, 
            INVOICE_REF 
        )
        SELECT
            SUBSTR(om.ORDER_REF,1,5) AS HEADER_REF
            ,om.ORDER_REF AS LINE_REF
            ,om.ORDER_DESCRIPTION  
            ,TO_NUMBER(REMOVE_ALPHA(REPLACE(om.ORDER_LINE_AMOUNT, ',',''))) AS LINE_AMT
            ,om.ORDER_STATUS
            ,om.INVOICE_REFERENCE           
            FROM BCM.XXBCM_ORDER_MGT om
            WHERE 1=1
            AND om.ORDER_REF LIKE '%-%'
            AND NOT EXISTS (SELECT 1 FROM BCM.XXBCM_ORDER_LINE ol WHERE ol.LINE_REF = om.ORDER_REF AND ol.LINE_REF LIKE '%-%');
                   
        SELECT COUNT(1)                                                                                                                              
        INTO n_count_orderLine_tab                                                                                                                        
        FROM BCM.XXBCM_ORDER_LINE;                                                                                                      

        DBMS_OUTPUT.PUT_LINE('Insertion into table XXBCM_ORDER_LINE completed.'); 
        DBMS_OUTPUT.PUT_LINE('Number of rows into table XXBCM_ORDER_LINE: ' || n_count_orderLine_tab); 

    END INSERT_ORDER_LINE; 

/*==============================================================================================*/
/* Procedure      : INSERT_INVOICE                                                              */
/* Description    : Insertion of invoice details into invoice table                             */
/* Remarks        :                                                                             */                                                     
/*==============================================================================================*/
PROCEDURE INSERT_INVOICE IS                                                                                                          

    n_count_invoice_tab     NUMBER := 0 ;                                                                                                     

    BEGIN                                                                                                                                        

        DBMS_OUTPUT.PUT_LINE('Start inserting into table XXBCM_INVOICE!');                                     
        INSERT INTO BCM.XXBCM_INVOICE
        (
            INVOICE_REF
            ,DESCRIPTION 
            ,INV_DATE
            ,STATUS
            ,HOLD_REASON
            ,AMOUNT 
        )
        SELECT
            om.INVOICE_REFERENCE
            ,om.INVOICE_DESCRIPTION
            ,TO_DATE(om.INVOICE_DATE, 'DD-MM-YY', 'NLS_DATE_LANGUAGE = American') AS INV_DATE
            ,om.INVOICE_STATUS
            ,om.INVOICE_HOLD_REASON
            ,TO_NUMBER(REMOVE_ALPHA(REPLACE(om.INVOICE_AMOUNT, ',',''))) AS INVOICE_AMOUNT   
            FROM BCM.XXBCM_ORDER_MGT om
            WHERE om.INVOICE_REFERENCE IS NOT NULL;
                   
        SELECT COUNT(1)                                                                                                                              
        INTO n_count_invoice_tab                                                                                                                        
        FROM BCM.XXBCM_INVOICE;                                                                                                      

        DBMS_OUTPUT.PUT_LINE('Insertion into table XXBCM_INVOICE completed.'); 
        DBMS_OUTPUT.PUT_LINE('Number of rows into table XXBCM_INVOICE: ' || n_count_invoice_tab); 

    END INSERT_INVOICE; 


END XXPO_MIGRATE_ORDER_MGT_PKG;                                                                                                                  

