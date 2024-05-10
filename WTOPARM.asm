//ANDREWJA JOB  CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID,REGION=0M
//STEP1  EXEC ASMACLG,PARM.C='FLAG(NOCONT)',PARM.L='MAP,LET,LIST,AC=1',
//       PARM.G='Test Messages on MVS console'
//C.SYSLIB DD   DSN=SYS1.MACLIB,DISP=SHR
//SYSIN    DD   *
*----------------------------------------------------------------*
* Purpose:
* This program is used to WTO white, held msg to the MVS console
* The descriptor code is 02. However, APF and AC=1 is a must
* Message to be displayed is passed by PARM='...........
* This is developed because there is APF authority problem with
* either a WTO REXX function or the LINKMVS interface.
* Even you put the WTO program into an APF library with AC=1,
* if this program is called through a REXX function or the LINKMVS
* interface, the APF authority is deprieved and the message will
* not be able to be displayed as descriptor code 02
* Creation date: 20080811
* Author       : Andrew Jan
*----------------------------------------------------------------*
         PRINT NOGEN
*------------------------------------------------*

         PRINT OFF
         LCLA  &REG
.LOOP    ANOP                     generate reg equates
R&REG    EQU   &REG
&REG     SETA  &REG+1
         AIF   (&REG LE 15).LOOP
         PRINT ON


*------------------------------------------------*

*------------------------------------------------*
WORKDATA DSECT ,
REGSAVE  DS    18F

OUTMWTO  DC    0F'0'
OUTMLNG  DC    Y(0)
OUTMMCS  DC    B'1000000000000000' mcs flags
*
OUTMTXT  DS    CL260               reserved 256 bytes (256+4=260)
*
WORKLEN  EQU   *-WORKDATA

WTOPARM  CSECT

         STM   R14,R12,12(R13)    save caller's reg values
         LR    R12,R15            set base reg
         USING WTOPARM,R12        setup addressibility
         LR    R8,R1              save parmlist addr
         B     CMNTTAIL           skip over the remarks

CMNTHEAD EQU   *
         PRINT GEN                print out remarks
         DC    CL8'&SYSDATE'      compiling date
         DC    C' '
         DC    CL5'&SYSTIME'      compiling time
         DC    C'ANDREW JAN'      author
         CNOP  2,4                ensure half word boundary
         PRINT NOGEN              disable macro expansion
CMNTTAIL EQU   *

*-start code ----------------------------*

         L     R1,0(,R1)          parm address
         LH    R9,0(,R1)          parm length
         LA    R10,2(,R1)         start addr

         GETMAIN RU,LV=WORKLEN,LOC=BELOW  blk addr returned in r1
         ST    R13,4(,R1)         chain save areas
         ST    R1,8(,R13)         save ours to caller's area
         LR    R13,R1             set our save addr
         USING WORKDATA,R13       addressibility for data

*####### OPEN  (PRINT,OUTPUT)     ###############

         LTR   R9,R9              no input argument?
         BZ    DEFAULT_TXT        yes, branch

         C     R9,=F'256'         control the len of arg1 < 256
         BNH   ARG_0              within 256, branch
         L     R9,=F'256'         the maximum allowed

ARG_0    EQU   *
         BCTR  R9,0               minus 1 for ex

EXMVC    MVC   OUTMTXT(0),0(R10)  mask for ex
         EX    R9,EXMVC           do the mvc according the length
         LA    R9,1(,R9)          restore the len
         B     CONTINUE           branch

DEFAULT_TXT    EQU  *
         MVC   OUTMTXT(24),=C'No Input Msg for WTOPARM'
         LA    R9,24              no parm, send the default msg

CONTINUE       EQU  *
         LA    R5,OUTMTXT         start addr of out msg text
         AR    R5,R9              next addr to the end of msg

         MVC   0(L'WTOMDRC,R5),WTOMDRC   set up desc.& rout. codes


         MVC   OUTMMCS,WTOMMCS    setup mmcs

         LA    R9,L'WTOMDRC(,R9)  add len. of desc.& rout. codes
         STH   R9,OUTMLNG         set up length

         LA    R5,OUTMWTO         wto msg pack
         WTO   MF=(E,(R5))        issue high-lighted console msg

         B     GO_BACK            branch to return

*--go back-------------------------------*
GO_BACK  EQU   *

*####### CLOSE  PRINT             #############

         L     R13,4(,R13)        restore caller's save area
         L     R1,8(,R13)         our work area's addr in r1

         FREEMAIN RU,LV=WORKLEN,A=(1)   free out work area

         LM    R14,R12,12(R13)     restore caller's reg values
         SR    R15,R15             rc = 0
         BR    R14                 go back

         LTORG

WTOMWTO  DC    0F'0'
WTOMLNG  DC    Y(0)
WTOMMCS  DC    B'1000000000000000' MCS FLAGS
*
WTOMDRC  DC    0BL4'0'             descriptor and routing code
WTODSC02 DC    B'0100000000000000' descriptor code = 2
WTOUROUT DC    B'0100000000000000' routing code = 2

*----------------------------------------*
*##PRINT DCB   DSORG=PS,DDNAME=SYSTSPRT,MACRF=PM,RECFM=F,LRECL=80
         END
/*
//L.SYSLMOD  DD  DSN=SYS1.SS.LINKLIB(WTOPARM),DISP=SHR
//
