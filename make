unset exit
unset cc >&/work
unset cg >&/work

if {#} == 0
   Newer obj/stdio.a stdio.asm equates.asm
   if {Status} != 0
      set exit on
      echo assemble +e +t stdio.asm
      assemble +e +t stdio.asm
      unset exit
   end

   Newer obj/assert.a assert.asm
   if {Status} != 0
      set exit on
      echo assemble +e +t assert.asm
      assemble +e +t assert.asm
      unset exit
   end

   for i in cc ctype string stdlib time setjmp orca fcntl vars toolglue signal
      Newer obj/{i}.a {i}.asm
      if {Status} != 0
         set exit on
         echo assemble +e +t {i}.asm
         assemble +e +t {i}.asm
         unset exit
      end
   end
else
   set exit on
   for i
      assemble +e +t {i}.asm
   end
end

echo delete orcalib
delete orcalib

set list        vars.a assert.a cc.a setjmp.a ctype.a string.a stdlib.a
set list {list} time.a signal.a toolglue.a orca.a fcntl.a stdio.a
for i in {list}
   echo makelib orcalib +obj/{i}
   makelib orcalib +obj/{i}
end

set echo on
