         keep  obj/assert
         mcopy assert.macros
         case  on
****************************************************************
*
*  Assert - Condition assertion macro
*
*  This code implements the subroutines needed to support the
*  standard C library assert.
*
*  October 1991
*  Mike Westerfield
*
*  Copyright 1991
*  Byte Works, Inc.
*
****************************************************************
*
Assert   start                          dummy routine

         end

****************************************************************
*
*  void __assert (char *f, unsigned l, char *s)
*
*  Inputs:
*        f - pointer to the file name
*        l - line number
*        s - assertion string
*
****************************************************************
*
__assert start

         csubroutine (4:f,2:l,4:s),0

         ph4   <s
         ph2   <l
         ph4   <f
         ph4   #msg
         ph4	>__assertfp
         jsl   fprintf
         jsl   abort

         creturn

msg      dc    c'Assertion failed: file %s, line %u; assertion: %s',i1'10,0'
         end

****************************************************************
*
*  void __assert2 (char *f, unsigned l, char *fn, char *s)
*
*  Inputs:
*        f - pointer to the file name
*        l - line number
*        fn - function name
*        s - assertion string
*
****************************************************************
*
__assert2 start

         csubroutine (4:f,2:l,4:fn,4:s),0

         ph4   <s
         ph4   <fn
         ph2   <l
         ph4   <f
         ph4   #msg
         ph4   >stderr
         jsl   fprintf
         jsl   abort

         creturn

msg      dc    c'Assertion failed: file %s, line %u, function %s; assertion: %s',i1'10,0'
         end
