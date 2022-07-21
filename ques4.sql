
/*==========================================================================================*/
/* Function       : get_action                                                              */
/* Description    : Dtermine action based on invoice status                                 */
/* Remarks        : Invoice Reference used as parameter IN                                   */                                                      
/*==========================================================================================*/
CREATE OR REPLACE FUNCTION get_action(P_INV_REF IN VARCHAR2) RETURN VARCHAR2
    AS
    v_action VARCHAR2(20);
    CURSOR c_status IS select distinct status from XXBCM_INVOICE where INVOICE_REF = P_INV_REF;
    TYPE  type_status is table of c_status%rowtype;
        rec_status type_status;
    BEGIN
    v_action:='';
        OPEN c_status;
        FETCH c_status BULK COLLECT INTO rec_status;
        CLOSE c_status;
        FOR n in 1..rec_status.count 
            LOOP
            IF rec_status(n).status='Pending' THEN v_action:='To follow up'; EXIT; END IF;
            IF rec_status(n).status IS NULL THEN v_action:='To verify'; EXIT; END IF;
            IF rec_status(n).status ='Paid' THEN v_action:='OK'; END IF;
            END LOOP;      
   
    RETURN v_action;
    END;


/*==========================================================================================*/
/* Description    : Ques4 Select statement                                                  */                                                     
/*==========================================================================================*/
select 
    ltrim(REGEXP_REPLACE(oh.HEADER_REF,'[PO]'), '0') "Order Reference"
    ,oh.PERIOD "Order Period"
    ,INITCAP(s.NAME) "Supplier Name"
    ,TO_CHAR(oh.TOTAL_AMT,'99,999,990.00') "Order Total Amount"
    ,oh.STATUS "Order Status"
    ,inv.INVOICE_REF "Invoice Reference"
    ,(SELECT TO_CHAR(SUM(AMOUNT),'99,999,990.00') from XXBCM_INVOICE where INVOICE_REF=inv.INVOICE_REF group by INVOICE_REF) "Invoice Total Amount"
    ,get_action(inv.INVOICE_REF) "Action"
    ,oh.ORDER_DATE
from 
    XXBCM_ORDER_HEADER oh
    ,XXBCM_SUPPLIER s
    ,(select distinct HEADER_REF,INVOICE_REF from XXBCM_ORDER_LINE) ol
    ,(select distinct INVOICE_REF from XXBCM_INVOICE) inv
    
WHERE 1=1
AND oh.SUPP_REF=s.SUPP_REF
AND oh.HEADER_REF = ol.HEADER_REF
AND ol.INVOICE_REF= inv.INVOICE_REF
ORDER BY oh.ORDER_DATE DESC;

