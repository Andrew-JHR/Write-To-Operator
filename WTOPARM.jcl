//WTOPARM   PROC NAME=
//*
//CHKDSN    EXEC PGM=CHKDSN
//SEQIN     DD DISP=(SHR,PASS),DSN=CUST.PRODSYS.&NAME
//*
//          IF  (CHKDSN.RC = 1)   THEN
//CHKETSAI  EXEC PGM=USRAIETS,PARM='250'
//SEQIN     DD DISP=(SHR,PASS),DSN=CUST.PRODSYS.&NAME
//PRINT     DD DISP=MOD,DSN=CUST.PRODSYS.USRAI
//*
//          IF  (CHKETSAI.RC = 9)   THEN
//AORSWARN  EXEC PGM=WTOPARM,
//          PARM='WARNING : Something Wrong Has Happened!'
//ENDIN     ENDIF
//*
//USRDATE   EXEC PGM=USRDATE
//SEQIN     DD DISP=(SHR,DELETE,KEEP),DSN=CUST.PRODSYS.&NAME
//PRINT     DD SYSOUT=*
//          ENDIF
//*
//          IF  (CHKDSN.RC = 2)   THEN
//PARSDATA  EXEC PGM=PARSDATA
//DATAFILE  DD DSN=CUST.PRODSYS.&NAME,DISP=(SHR,DELETE,KEEP)
//DATAHOUR  DD DSN=CUST.PRODSYS.DATAHOUR,DISP=MOD
//DATADAY   DD DSN=CUST.PRODSYS.DATADAY,DISP=MOD
//HOUREF    DD DSN=CUST.PRODSYS.DATAHREF,DISP=SHR
//DAYREF    DD DSN=CUST.PRODSYS.DATADREF,DISP=SHR
//DATASMC   DD DSN=CUST.PRODSYS.DATASMC,DISP=SHR
//          ENDIF
