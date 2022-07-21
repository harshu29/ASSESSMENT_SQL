/*==========================================================================================*/
/* Function       : format_telNum                                                           */
/* Description    : Format phone number based on required format                            */
/* Remarks        : Phone Number used as parameter IN                                       */                                                      
/*==========================================================================================*/
CREATE OR REPLACE FUNCTION format_telNum(P_PHONE_NUM IN VARCHAR2) RETURN VARCHAR2
    AS
    v_phoneNum VARCHAR2(1000);
    
    BEGIN
        IF P_PHONE_NUM IS NOT NULL THEN 
          CASE 
                WHEN length(P_PHONE_NUM) = 8 THEN 
                    v_phoneNum:= SUBSTR(P_PHONE_NUM,1,4) || '-' || SUBSTR(P_PHONE_NUM, 5);
                ELSE 
                    v_phoneNum:= SUBSTR(P_PHONE_NUM,1,3) || '-' || SUBSTR(P_PHONE_NUM, 4);
            END CASE;
        END IF;
   
    RETURN v_phoneNum;
    END;


/*==========================================================================================*/
/* Description    : Ques6 Select statement                                                  */                                                     
/*==========================================================================================*/
SELECT distinct
   s.NAME "Supplier Name"
   ,s.CONTACT_NAME "Supplier Contact Name"
   ,format_telNum(CONTACT_NUM_1) "Supplier Contact No. 1"
   ,format_telNum(CONTACT_NUM_2) "Supplier Contact No. 2"
   ,(select count(HEADER_REF) from XXBCM_ORDER_HEADER where SUPP_REF=oh.SUPP_REF and SUPP_REF=s.SUPP_REF and ORDER_DATE BETWEEN TO_DATE('01-JAN-17', 'DD-MM-YY') AND TO_DATE('31-AUG-17', 'DD-MM-YY') group by oh.SUPP_REF) "Total Orders"  
   ,TO_CHAR((SELECT SUM(h.TOTAL_AMT) FROM XXBCM_ORDER_HEADER h where h.SUPP_REF=s.SUPP_REF and ORDER_DATE BETWEEN TO_DATE('01-JAN-17', 'DD-MM-YY') AND TO_DATE('31-AUG-17', 'DD-MM-YY') group by h.SUPP_REF),'99,999,990.00') "Order Total Amount"
FROM 
    XXBCM_SUPPLIER s
    ,XXBCM_ORDER_HEADER oh
WHERE 1=1
    AND oh.SUPP_REF = s.SUPP_REF
    AND oh.ORDER_DATE BETWEEN TO_DATE('01-JAN-17', 'DD-MM-YY') AND TO_DATE('31-AUG-17', 'DD-MM-YY');