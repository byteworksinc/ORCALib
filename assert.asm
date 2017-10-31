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
*  void __assert (char *f, int l)
*
*  Inputs:
*        f - pointer to the file name
*        l - line number
*
****************************************************************
*
__assert start

         csubroutine (4:f,2:l,4:s),0

	ph4	s
         ph2   l
         ph4   f
         ph4   #msg
	ph4	>stderr
         jsl   fprintf
         jsl   abort

         creturn

msg      dc    c'Assertion failed: file %s, line %d; assertion: %s',i1'10,0'
         end
