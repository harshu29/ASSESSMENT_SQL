/*==========================================================================================*/
/* Function       : get_invRef                                                              */
/* Description    : Concatenate invoice reference based on order                            */
/* Remarks        : Order header Reference used as parameter IN                              */                                                      
/*==========================================================================================*/
CREATE OR REPLACE FUNCTION get_invRef(P_HEADER_REF IN VARCHAR2) RETURN VARCHAR2
    AS
    v_invConcat VARCHAR2(1000);
    CURSOR c_invRef IS select distinct INVOICE_REF from XXBCM_ORDER_LINE where HEADER_REF = P_HEADER_REF AND INVOICE_REF IS NOT NULL ORDER BY INVOICE_REF;
    TYPE  type_invRef is table of c_invRef%rowtype;
        rec_invRef type_invRef;
    BEGIN
    v_invConcat:=null;
        OPEN c_invRef;
        FETCH c_invRef BULK COLLECT INTO rec_invRef;
        CLOSE c_invRef;
        FOR n in 1..rec_invRef.count 
            LOOP
            IF v_invConcat is not null THEN v_invConcat:= v_invConcat || ', ' || rec_invRef(n).INVOICE_REF; END IF;
            IF v_invConcat is null THEN v_invConcat:= rec_invRef(n).INVOICE_REF ;  END IF;
             
            END LOOP;      
   
    RETURN v_invConcat;
    END;

/*==========================================================================================*/
/* Description    : Ques5 Select statement                                                  */                                                     
/*==========================================================================================*/
select 
    distinct
    ltrim(REGEXP_REPLACE(oh.HEADER_REF,'[PO]'), '0') "Order Reference"
    ,TO_CHAR(oh.ORDER_DATE, 'Month DD,YYYY') "Order Date"
    ,oh.PERIOD "Order Period"
    ,UPPER(s.NAME) "Supplier Name"
    ,TO_CHAR(oh.TOTAL_AMT,'99,999,990.00') "Order Total Amount"
    ,oh.STATUS "Order Status"
   ,get_invRef(oh.HEADER_REF) "Invoice References"
    
from 
    XXBCM_ORDER_HEADER oh
    ,XXBCM_SUPPLIER s
    ,(select distinct HEADER_REF,INVOICE_REF from XXBCM_ORDER_LINE) ol
    ,(select distinct INVOICE_REF from XXBCM_INVOICE) inv
    ,(SELECT HEADER_REF
        FROM (select salary2.*, rownum rnum from
                     (select oh.* from XXBCM_ORDER_HEADER oh ORDER BY oh.TOTAL_AMT DESC) salary2
              where rownum <= 3 )
        WHERE rnum >= 3) third_highest_amt
    
WHERE 1=1
AND oh.SUPP_REF=s.SUPP_REF
AND oh.HEADER_REF = ol.HEADER_REF
AND ol.INVOICE_REF= inv.INVOICE_REF
AND third_highest_amt.HEADER_REF = oh.HEADER_REF;


