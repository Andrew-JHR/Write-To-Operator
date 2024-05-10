//ANDREWJA JOB  CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID,REGION=0M
//STEP1    EXEC ASMACL,PARM.C='FLAG(NOCONT)'
//C.SYSLIB DD   DSN=SYS1.MACLIB,DISP=SHR
//SYSIN    DD   *
*-----------------------------------------------------------------*
* Program function :
*   This program provides a REXX function to write message to MVS
*   console in high-lighted color.
*
*   The message to WTO is passed in the form of ' rxwto('message...')
*   or rxwto(var), where var is the variable to contain the message
*   string.
*
*   The length of the message to send to console should be within
*   256 bytes.
*
*   The program passes on result back to the REXX caller, unless there
*   is no input passed from the caller. In that case, the result passed
*   back to the caller is a warning message
*
* Assember : High Level Assembler 1.2 or above
* Author :   Andrew Jan
* Completion Date : 28/Jun/2002
* Update     Date :
*
*-----------------------------------------------------------------*
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

         IRXEFPL ,                efpl, external function parm list
         IRXARGTB ,               argument list map
         IRXEVALB ,               evaluation block map

RXWTO    CSECT
*XWTO    AMODE 31
*XWTO    RMODE ANY

         STM   R14,R12,12(R13)    save caller's reg values
         LR    R12,R15            set base reg
         USING RXWTO,R12          setup addressibility
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

         GETMAIN RU,LV=WORKLEN,LOC=BELOW  blk addr returned in r1
         ST    R13,4(,R1)         chain save areas
         ST    R1,8(,R13)         save ours to caller's area
         LR    R13,R1             set our save addr
         USING WORKDATA,R13       addressibility for data

*####### OPEN  (PRINT,OUTPUT)     ###############

         USING EFPL,R8            r8 was saved from r1 earlier

         L     R9,EFPLARG         argument list  addr

         USING ARGTABLE_ENTRY,R9  addressibility
*ARGTABLE_ARGSTRING_PTR    DS  A        Address of the argument string
*ARGTABLE_ARGSTRING_LENGTH DS  F        Length of the argument string
*ARGTABLE_NEXT             DS  0D       Next ARGTABLE entry
*ARGTABLE_END DC  XL8'FFFFFFFFFFFFFFFF' End of ARGTABLE marker

         L     R11,EFPLEVAL       addr of evaluation block addr
         L     R11,0(,R11)        evaluation blk for result to return
         USING EVALBLOCK,R11      addressibility
*EVALBLOCK_EVSIZE DS  F           Size of EVALBLK in double word
*EVALBLOCK_EVLEN  DS  F           Length of data
*EVALBLOCK_EVDATA DS  C           Result

* check if any arg provided ?
         CLC   ARGTABLE_ARGSTRING_PTR(8),=XL8'FFFFFFFFFFFFFFFF'
         BZ    NO_ARG             yes, get current tod


* there is only 1 parm  needed
         L     R10,ARGTABLE_ARGSTRING_PTR addr of arg 1
         L     R9,ARGTABLE_ARGSTRING_LENGTH  len of arg 1

         C     R9,=F'256'         control the len of arg1 < 256
         BNH   ARG_0              within 256, branch
         L     R9,=F'256'         the maximum allowed

ARG_0    EQU   *
         BCTR  R9,0               minus 1 for ex

EXMVC    MVC   OUTMTXT(0),0(R10)  mask for ex
         EX    R9,EXMVC           do the mvc according the length
         LA    R9,1(,R9)          restore the len

         LA    R5,OUTMTXT         start addr of out msg text
         AR    R5,R9              next addr to the end of msg

         MVC   0(L'WTOMDRC,R5),WTOMDRC   set up desc.& rout. codes

         MVC   OUTMMCS,WTOMMCS    setup mmcs

         LA    R9,L'WTOMDRC(,R9)  add len. of desc.& rout. codes
         STH   R9,OUTMLNG         set up length

         LA    R5,OUTMWTO         wto msg pack
         WTO   MF=(E,(R5))        issue high-lighted console msg

         MVC   EVALBLOCK_EVDATA(L'OK_MSG),OK_MSG  successful msg
         L     R1,=A(L'OK_MSG)    length of warning message
         ST    R1,EVALBLOCK_EVLEN save back
         B     GO_BACK            branch to return

NO_ARG   EQU   *
         MVC   EVALBLOCK_EVDATA(L'NO_ARG_MSG),NO_ARG_MSG  warning msg
         L     R1,=A(L'NO_ARG_MSG)  length of warning message
         ST    R1,EVALBLOCK_EVLEN   save back

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
WTODSC11 DC    B'0000000000100000' descriptor code = 11
WTOUROUT DC    B'0100000000000000' routing code = 2

NO_ARG_MSG  DC  C'No Input Message !'
OK_MSG      DC  C'OK'

*----------------------------------------*
*##PRINT DCB   DSORG=PS,DDNAME=SYSTSPRT,MACRF=PM,RECFM=F,LRECL=80
         END
/*
//L.SYSLMOD  DD  DSN=SYS1.SS.LINKLIB(RXWTO),DISP=SHR
//
