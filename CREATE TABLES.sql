----------------------------------------------------------------------
-- VERSION      : 1.0
-- DESCRIPTION  : Creation of table scripts + sequence 
-- AUTHOR       : H.RAMDOWAR   
-- DATE         : 21/07/2022 
----------------------------------------------------------------------

/*==========================================================================================*/
/* Description    : Supplier table to be used to store all suppliers details                */                                                     
/*==========================================================================================*/
  CREATE TABLE XXBCM_SUPPLIER 
   (	
	SUPP_REF 			VARCHAR2(200), 
    NAME 			    VARCHAR2(200),
    CONTACT_NAME 		VARCHAR2(200),
    ADDRESS 			VARCHAR2(1000),
    CONTACT_NUM_1 		VARCHAR2(200),
    CONTACT_NUM_2 		VARCHAR2(200),
	EMAIL 			    VARCHAR2(200), 

    PRIMARY KEY(SUPP_REF)
   );
  
/*==========================================================================================*/
/* Description    : Order header table to be used to store only main order (header)         */                                                     
/*==========================================================================================*/
  CREATE TABLE XXBCM_ORDER_HEADER 
   (	
	HEADER_REF 			VARCHAR2(200), 
	ORDER_DATE 			DATE, 
	TOTAL_AMT 		    NUMBER, 
	DESCRIPTION 	    VARCHAR2(2000), 
	STATUS 		        VARCHAR2(200), 
    PERIOD              VARCHAR2(200),
	SUPP_REF            VARCHAR2(200),

    PRIMARY KEY(HEADER_REF), 
    FOREIGN KEY (SUPP_REF) REFERENCES XXBCM_SUPPLIER(SUPP_REF)
   );

/*==========================================================================================*/
/* Description    : Order line table to be used to store only corresponding lines order     */                                                     
/*==========================================================================================*/
 CREATE TABLE XXBCM_ORDER_LINE
   (	
	LINE_REF 			VARCHAR2(200), 
    HEADER_REF 			VARCHAR2(200),
    DESCRIPTION 		VARCHAR2(2000),
    LINE_AMT 		    NUMBER, 
	STATUS 		        VARCHAR2(200), 
    INVOICE_REF 		VARCHAR2(200),

    FOREIGN KEY (HEADER_REF) REFERENCES XXBCM_ORDER_HEADER(HEADER_REF)
   );

/*==========================================================================================*/
/* Description    : Invoice table to be used to store all invoices                          */                                                     
/*==========================================================================================*/
CREATE TABLE XXBCM_INVOICE
   (	
	INVOICE_REF 	VARCHAR2(200), 
    DESCRIPTION     VARCHAR2(2000),
	INV_DATE 		DATE, 
	STATUS 	        VARCHAR2(200), 
	HOLD_REASON     VARCHAR2(200), 
    AMOUNT          NUMBER,
   );

/*==========================================================================================*/
/* Description    : Sequence to be used as supplier ref                                     */                                                     
/*==========================================================================================*/
CREATE SEQUENCE BCM.SUPPLIER_SEQ
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    MAXVALUE 1000;

