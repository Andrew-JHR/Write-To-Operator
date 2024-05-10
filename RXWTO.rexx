/* rexx */
/* rxwto sample */

numeric digits(32) /* ensure max precision */
tcb=storage(d2x(540),4) /* psatold in psa */
jscb =storage(d2x(c2d(tcb)+180),4) /* tcbjscb in tcb */
jct = storage(d2x(c2d(jscb)+261),3) /* jscbjcta in jscb */
ascb = c2d(storage(224,4))
assb = c2d(storage(d2x(ascb+336),4))
jsab = c2d(storage(d2x(assb+168),4))
jbnm = storage(d2x(jsab+28),8)

this_step_no = x2d(c2x(storage(d2x(c2d(jscb)+228),1)))
/*above is this step no. */

fsct = storage(d2x(c2d(jct)+48),3) /* jctsdkad in jct */
/*above is first sct */

/* fsct = fsct */
/*find max rc in this job */
rcmax = 0

do i = 1 to (this_step_no - 1)
   step = storage(d2x(c2d(fsct)+68),8)
   rcstep = x2d(c2x(storage(d2x(c2d(fsct)+24),2)))
   /* sctsexec in sct */
   bypass = storage(d2x(c2d(fsct)+188),1)
   if x2d(c2x(bypass)) = 80 then /* check if step was not executed */
     do
       rcstep = 'flushed '
       rcmax  = rcstep
     end
   if rcstep > rcmax  then
     do
       rcmac = rcstep
     end

   fsct = storage(d2x(c2d(fsct)+36),3)

   msg = 'Step: ' || step || ' ended with RC as :' || rcstep
   say rxwto(msg)

end /*  do the loop thru all steps */

msg = 'Job: ' || jbnm || ' ends with Max RC as :' || rcmax
say rxwto(msg)

exit 0

