         keep  obj/orca
         mcopy orca.macros
         case  on

****************************************************************
*
*  ORCA - ORCA/C specific libraries
*
*  This code implements the tables and subroutines needed to
*  support the ORCA/C library ORCA.
*
*  March 1989
*  Mike Westerfield
*
*  Copyright 1989
*  Byte Works, Inc.
*
****************************************************************
*
ORCA     start                          dummy segment
         end

****************************************************************
*
*  char *commandline(void)
*
*  Inputs:
*        ~CommandLine - address of the command line
*
****************************************************************
*
commandline start

         ldx   #0
         lda   ~COMMANDLINE
         ora   ~COMMANDLINE+2
         beq   lb1

         lda   ~COMMANDLINE
         ldx   ~COMMANDLINE+2
         clc
         adc   #8
         bcc   lb1
         inx
lb1      rtl
         end

****************************************************************
*
*  void enddesk(void)
*
****************************************************************
*
enddesk  start

         jmp   ~ENDDESK
         end

****************************************************************
*
*  void endgraph(void)
*
****************************************************************
*
endgraph start

         jmp   ~ENDGRAPH
         end

****************************************************************
*
*  char *shellid(void)
*
*  Inputs:
*        ~CommandLine - address of the command line
*
****************************************************************
*
shellid  start

         ldx   #0                       return NULL if there is no command line
         lda   >~COMMANDLINE
         ora   >~COMMANDLINE+2
         bne   lb1
         rtl

lb1      lda   >~COMMANDLINE+2
	pha
	lda   >~COMMANDLINE
	pha
         phd
         tsc
         tcd
         phb
         phk
         plb
         ldy   #6
lb2      lda   [3],Y
         sta   id,Y
         dey
         dey
         bpl   lb2
         plb
         pld
         pla
         pla
         lda   #id
         ldx   #^id
         rtl

id       dc    8c' ',i1'0'
         end

****************************************************************
*
*  void startdesk(int width)
*
****************************************************************
*
startdesk start

         jmp   ~STARTDESK
         end

****************************************************************
*
*  void startgraph(int width)
*
****************************************************************
*
startgraph start

         jmp   ~STARTGRAPH
         end

****************************************************************
*
*  int toolerror(void)
*
****************************************************************
*
toolerror start

         lda   >~TOOLERROR
         rtl
         end

****************************************************************
*
*  int userid(void)
*
****************************************************************
*
userid   start

         lda   >~USER_ID
         rtl
         end
