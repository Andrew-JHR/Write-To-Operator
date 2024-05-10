# Writing Messages to MVS Console 

This repository demonstrates how to make use of the MVS provided API: WTO by coding programs in Assembler.

1. **WTOPARM.asm** sends the message from the JCL job step's PARM field to the MVS console where the message in White color (use 'D MPF,C' to show your current settings or check '.MSGCOLR' definitions in your effective MPFLST PARMLIB member) will be held on the screen and stay there until the on-duty operator delete it manually -- Unless the console's Mode has been set as wrapped (MODE=W by issuing 'K S,DEL=W'). 

2. The Descriptor code of **WTOPARM.asm** is '2', which means the program should be compiled and link-edited into an APF (Authorized Program Facility) enabled PDS/PDSE (Partitioned Data Set / Partitioned Data Set Extended) with AC code equal to '1'.

3. The maximum length of the parameter that **WTOPARM.asm** can accept is 100. Leave the column 72 of the first line as blank and continue from the 16th column of the second line to specify the remaining argument to be displayed.

4. Sample JCL for executing **WTOPARM LMD** is as follows: * Please note that WTOPARM LMD must be put into an APF library in the Link List concatenation -- using 'D PROG,APF' and 'D PROG,LNKLST' to ensure and 'F LLA,REFHRESH' to take effect * 


	----+----1----+----2----+----3----+----4----+----5----+----6----+----7--

	***************************** Top of Data ******************************

	//ANDREWJR JOB CLASS=A,NOTIFY=&SYSUID,MSGCLASS=X

	//WTOPARM EXEC PGM=WTOPARM,

	// PARM='01234567891123456789212345678931234567894123456789512345678961

	//              23456789712345678981234567899123456789'

	**************************** Bottom of Data ****************************
                 

6. Also refer to **WTOPARM.jcl** for a sample JCL.

7. **WTOPARM.jpg** is the sample display of the MVS console when executing **WTOPARM** LMD. 

8. **RXWTO.asm** is the program to create a REXX function: **RXWTO**

9. The descriptor code of **RXWTO.asm** is 11 which means the color of the message displayed will be in Red (use 'D MPF,C' to show your current settings or check '.MSGCOLR' definitions in your effective MPFLST PARMLIB member) and without the hold-on feature like that of **WTOPARM.asm**. Setting it as descriptor 11 will have no effect at all because the REXX environment will take away the privilege. 

10. **RXWTO.rexx** shows how to invoke the **RXWTO** function in a REXX Exec.
 
11. **RXWTO.jcl** shows a way to execute **RXWTO.rexx** where the last step with 'COND=EVEN' of a job can be used to display the results of running a job's steps on the MVS console.

12. **RXWTO.jpg** shows the resulted MVS console image when running **RXWTO.jcl**

13. Also note that the LMD of **RXWTO** REXX function must be put into an LMD PDS that is in the link List concatenation or being added as a STEPLIB DD card in the JCL that invokes the REXX Exec. 
