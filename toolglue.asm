         keep  obj/toolglue
         mcopy toolglue.macros
         case  on
****************************************************************
*
*  ToolGlue - Glue routines for tools that return records
*
*  June 1989
*  Mike Westerfield
*
*  Copyright 1989, 1990, 1992
*  Byte Works, Inc.
*
****************************************************************
*
*  November 1992
*
*  Parameter orders corrected.
*
****************************************************************
*
*  August 1990
*
*  1.  Restart() has been corrected to expect a single
*      parameter.  In the previous version of the library,
*      it expected the same parameter list as InitialLoad().
*
*  2.  All tool calls now store the tool error number returned
*      by the toolbox in ~toolError.
*
****************************************************************
*
ToolGlue start                          dummy routine

         end

****************************************************************
*
*  MiscTool - Miscelaneous tool kit
*
****************************************************************
*
*  FWEntry - Firmware Entry
*
*  Inputs:
*        aRegValue, xRegValue, yRegValue - registers on entry
*        eModeEntryPt - call address
*
*  Outputs:
*        Returns a pointer to a record with the following
*        structure:
*
*  typedef struct FWRec  {
*       int yRegExit;
*       int xRegExit;
*       int aRegExit;
*       int status;
*       }
*
****************************************************************
*
FWEntry  start
addr     equ   1                        work pointer

         csubroutine (2:aRegValue,2:xRegValue,2:yRegValue,2:eModeEntryPt),4

         pha
         pha
         pha
         pha
         ph2   aRegValue
         ph2   xRegValue
         ph2   yRegValue
         ph2   eModeEntryPt
         _FWEntry
         sta   >~TOOLERROR
         pl2   >yRegExit
         pl2   >xRegExit
         pl2   >aRegExit
         pl2   >status
         lla   addr,yRegExit

         creturn 4:addr

yRegExit ds    2                        record returned
xRegExit ds    2
aRegExit ds    2
status   ds    2
         end

****************************************************************
*
*  GetAbsClamp - returns the absolute device clamp
*
*  Outputs:
*        Returns a pointer to a record with the following
*        structure:
*
*  typedef struct ClampRec  {
*        int yMaxClamp;
*        int yMinClamp;
*        int xMaxClamp;
*        int xMinClamp;
*        }
*
****************************************************************
*
GetAbsClamp start

         pha
         pha
         pha
         pha
         _GetAbsClamp
         sta   >~TOOLERROR
         pl2   >yMaxClamp
         pl2   >yMinClamp
         pl2   >xMaxClamp
         pl2   >xMinClamp

         lda   #yMaxClamp
         ldx   #^yMaxClamp
         rtl

yMaxClamp ds   2                        record returned
yMinClamp ds   2
xMaxClamp ds   2
xMinClamp ds   2
         end

****************************************************************
*
*  GetMouseClamp - returns the mouse clamp
*
*  Outputs:
*        Returns a pointer to a record with the following
*        structure:
*
*  typedef struct ClampRec  {
*        int yMaxClamp;
*        int yMinClamp;
*        int xMaxClamp;
*        int xMinClamp;
*        }
*
****************************************************************
*
GetMouseClamp start

         pha
         pha
         pha
         pha
         _GetMouseClamp
         sta   >~TOOLERROR
         pl2   >yMaxClamp
         pl2   >yMinClamp
         pl2   >xMaxClamp
         pl2   >xMinClamp

         lda   #yMaxClamp
         ldx   #^yMaxClamp
         rtl

yMaxClamp ds   2                        record returned
yMinClamp ds   2
xMaxClamp ds   2
xMinClamp ds   2
         end

****************************************************************
*
*  ReadMouse - return mouse statistics
*
*  Outputs:
*        Returns a pointer to a record with the following
*        structure:
*
*  typedef struct MouseRec  {
*        char mouseMode;
*        char mouseStatus;
*        int  yPos;
*        int  xPos;
*        }
*
****************************************************************
*
ReadMouse start

         pha
         pha
         pha
         _ReadMouse
         sta   >~TOOLERROR
         pl2   >mouseMode
         pl2   >yPos
         pl2   >xPos

         lda   #mouseMode
         ldx   #^mouseMode
         rtl

mouseMode ds   1
mouseStatus ds 1
yPos     ds    2
xPos     ds    2
         end

****************************************************************
*
*  ReadTimeHex - returns the time in hex format
*
*  Outputs:
*        Returns a pointer to a record with the following
*        structure:
*
*  typedef struct TimeRec  {
*        char second;
*        char minute;
*        char hour;
*        char year;
*        char day;
*        char month;
*        char extra;
*        char weekDay;
*        }
*
****************************************************************
*
ReadTimeHex start

         pha
         pha
         pha
         pha
         _ReadTimeHex
         sta   >~TOOLERROR
         pl2   >second
         pl2   >hour
         pl2   >day
         pl2   >extra

         lda   #second
         ldx   #^second
         rtl

second   ds    1
minute   ds    1
hour     ds    1
year     ds    1
day      ds    1
month    ds    1
extra    ds    1
weekDay  ds    1
         end

****************************************************************
*
*  IntMath - Integer Math Tool Kit
*
****************************************************************
*
*  extern LongDivRec LongDivide();
*
*  typedef struct LongDivRec  {
*        Longint     quotient;     /* LongDivRec - Quotient from LongDiv*/
*        Longint     remainder;     /* LongDivRec - remainder from LongDiv*/
*        }
*
****************************************************************
*
LongDivide start
addr     equ   1

         csubroutine (4:dividend,4:divisor),4

         tsc
         sec
         sbc   #8
         tcs
         ph4   dividend
         ph4   divisor
         _LongDivide
         sta   >~TOOLERROR
         pl4   >quotient
         pl4   >remainder

         lla   addr,quotient

         creturn 4:addr

quotient ds    4
remainder ds   4
         end

****************************************************************
*
*  extern LongMulRec LongMul();
*
*  typedef struct LongMulRec  {
*        Longint  lsResult; /* LongMulRec - Low Long of result*/
*        Longint  msResult;  /* LongMulRec - High long of result*/
*        }
*
****************************************************************
*
LongMul  start
addr     equ   1

         csubroutine (4:multiplicand,4:multiplier),4

         tsc
         sec
         sbc   #8
         tcs
         ph4   multiplicand
         ph4   multiplier
         _LongMul
         sta   >~TOOLERROR
         pl4   >lsResult
         pl4   >msResult

         lla   addr,lsResult

         creturn 4:addr

lsResult ds    4
msResult ds    4
         end

****************************************************************
*
*  extern IntDivRec SDivide();
*
*  typedef struct IntDivRec  {
*        Integer     quotient;     /* IntDivRec - quotient from SDivide*/
*        Integer     remainder;     /* IntDivRec - remainder from SDivide*/
*        } IntDivRec,  *IntDivRecPtr ;
*
****************************************************************
*
SDivide  start
addr     equ   1

         csubroutine (2:dividend,2:divisor),4

         pha
         pha
         ph2   dividend
         ph2   divisor
         _SDivide
         sta   >~TOOLERROR
         pl2   >quotient
         pl2   >remainder

         lla   addr,quotient

         creturn 4:addr

quotient ds    2
remainder ds   2
         end

****************************************************************
*
*  extern IntDivRec UDivide();
*
*  typedef struct IntDivRec  {
*        Integer     quotient;     /* IntDivRec - quotient from SDivide*/
*        Integer     remainder;     /* IntDivRec - remainder from SDivide*/
*        } IntDivRec,  *IntDivRecPtr ;
*
****************************************************************
*
UDivide  start
addr     equ   1

         csubroutine (2:dividend,2:divisor),4

         pha
         pha
         ph2   dividend
         ph2   divisor
         _UDivide
         sta   >~TOOLERROR
         pl2   >quotient
         pl2   >remainder

         lla   addr,quotient

         creturn 4:addr

quotient ds    2
remainder ds   2
         end

****************************************************************
*
*  Loader
*
****************************************************************
*
*  extern InitialLoadOutputRec InitialLoad();
*
*  typedef struct InitialLoadOutputRec  {
*        Word     userID;
*        Pointer  startAddr;
*        Word     dPageAddr;
*        Word     buffSize;
*        }
*
****************************************************************
*
InitialLoad start

addr     equ   1

         csubroutine (2:uID,4:stAddr,2:dpAddr),4

         tsc
         sec
         sbc   #10
         tcs
         ph2   uID
         ph4   stAddr
         ph2   dpAddr
         _InitialLoad
         sta   >~TOOLERROR
         pl2   >userID
         pl4   >startAddr
         pl2   >dPageAddr
         pl2   >buffSize

         lla   addr,userID

         creturn 4:addr

userID   ds    2
startAddr ds   4
dPageAddr ds   2
buffSize ds    2
         end

****************************************************************
*
*  extern InitialLoadOutputRec InitialLoad2();
*
*  typedef struct InitialLoadOutputRec  {
*        Word     buffSize;
*        Word     dPageAddr;
*        Pointer  startAddr;
*        Word     userID;
*        }
*
****************************************************************
*
InitialLoad2 start

addr     equ   1

         csubroutine (2:uID,4:buffAddr,2:flagWord,2:inputType),4

         tsc
         sec
         sbc   #10
         tcs
         ph2   uID
         ph4   buffAddr
         ph2   flagWord
         ph2   inputType
         _InitialLoad2
         sta   >~TOOLERROR
         pl2   >userID
         pl4   >startAddr
         pl2   >dPageAddr
         pl2   >buffSize

         lla   addr,userID

         creturn 4:addr

userID   ds    2
startAddr ds   4
dPageAddr ds   2
buffSize ds    2
         end

****************************************************************
*
*  extern LoadSegNameOut LoadSegName();
*
*  typedef struct LoadSegNameOut  {
*        Pointer  segAddr;
*        Word     userID;
*        Word     fileNum;
*        Word     segNum;
*        }
*
****************************************************************
*
LoadSegName start

addr     equ   1

         csubroutine (2:uID,4:fName,4:sName),4

         tsc
         sec
         sbc   #10
         tcs
         ph2   uID
         ph4   fName
         ph4   sName
         _LoadSegName
         sta   >~TOOLERROR
         pl4   >segAddr
         pl2   >userID
         pl2   >fileNum
         pl2   >segNum

         lla   addr,segAddr

         creturn 4:addr

segAddr  ds    4
userID   ds    2
fileNum  ds    2
segNum   ds    2
         end

****************************************************************
*
*  extern InitialLoadOutputRec Restart();
*
*  typedef struct InitialLoadOutputRec  {
*        Word     userID;
*        Pointer  startAddr;
*        Word     dPageAddr;
*        Word     buffSize;
*        }
*
****************************************************************
*
Restart  start

addr     equ   1

         csubroutine (2:uID),4

         tsc
         sec
         sbc   #10
         tcs
         ph2   uID
         _Restart
         sta   >~TOOLERROR
         pl2   >userID
         pl4   >startAddr
         pl2   >dPageAddr
         pl2   >buffSize

         lla   addr,userID

         creturn 4:addr

userID   ds    2
startAddr ds   4
dPageAddr ds   2
buffSize ds    2
         end

****************************************************************
*
*  extern UnloadSegOutRec UnloadSeg();
*
*  typedef struct UnloadSegOutRec  {
*        Word     userID;
*        Word     fileNum;
*        Word     segNum;
*        } UnloadSegOutRec,  *UnloadSegOutRecPtr ;
*
****************************************************************
*
UnloadSeg start

addr     equ   1

         csubroutine (4:segaddr),4

         pha
         pha
         pha
         ph4   segaddr
         _UnloadSeg
         sta   >~TOOLERROR
         pl2   >userID
         pl2   >fileNum
         pl2   >segNum

         lla   addr,userID

         creturn 4:addr

userID   ds    2
fileNum  ds    2
segNum   ds    2
         end

****************************************************************
*
*  midiSynth - MIDI Synth Tool Kit
*
****************************************************************
*
*  extern LongDivRec LongDivide();
*
*  typedef struct LongDivRec  {
*        Longint     quotient;     /* LongDivRec - Quotient from LongDiv*/
*        Longint     remainder;     /* LongDivRec - remainder from LongDiv*/
*        }
*
****************************************************************
*
GetMSData start

         csubroutine (4:reserved,4:DP),0

	tsc
	sec
	sbc	#8
	tcs
	_GetMSData
         sta   >~TOOLERROR
	ldy	#2
	pla
	sta	[DP]
	pla
	sta	[DP],Y
	pla
	sta	[reserved]
	pla
	sta	[reserved],Y

         creturn
         end

****************************************************************
*
*  Note Sequencer
*
****************************************************************
*
*  extern LocRec GetLoc();
*
*  typedef struct LocRec { 
*     Word curPhraseItem;
*     Word curPattItem;
*     Word curLevel;
*     } LocRec, *LocRecPtr, **LocRecHndl; 
*
****************************************************************
*
GetLoc   start

         pha
         pha
         pha
         _GetLoc
         sta   >~TOOLERROR
         pl2   >curLevel
         pl2   >curPattItem
         pl2   >curPhraseItem
         lda   #curPhraseItem
         ldx   #^curPhraseItem
         rtl

curPhraseItem ds 2
curPattItem ds 2
curLevel ds    2
         end

****************************************************************
*
*  TextTools
*
****************************************************************
*
*  extern TxtMaskRec  GetErrGlobals();
*
*  typedef struct TxtMaskRec  {
*        Word     orMask;
*        Word     andMask;
*        } TxtMaskRec,  *TxtMaskRecPtr,  **TxtMaskRecHndl ;
*
****************************************************************
*
GetErrGlobals start

         pha
         pha
         _GetErrGlobals
         sta   >~TOOLERROR
         pl2   >orMask
         pl2   >andMask
         lda   #orMask
         ldx   #^orMask
         rtl

orMask   ds    2
andMask  ds    2
         end

****************************************************************
*
*  extern DeviceRec  GetErrorDevice();
*
*  typedef struct DeviceRec  {
*        LongWord     ptrOrSlot; /* DeviceRec - slot number or jump table ptr*/
*        Word     deviceType;     /* DeviceRec - type of input device*/
*        } DeviceRec,  *DeviceRecPtr,  **DeviceRecHndl ;
*
****************************************************************
*
GetErrorDevice start

         pha
         pha
         pha
         _GetErrorDevice
         sta   >~TOOLERROR
         pl4   >ptrOrSlot
         pl2   >deviceType
         lda   #ptrOrSlot
         ldx   #^ptrOrSlot
         rtl

ptrOrSlot ds   4
deviceType ds  2
         end

****************************************************************
*
*  extern TxtMaskRec  GetInGlobals();
*
*  typedef struct TxtMaskRec  {
*        Word     orMask;
*        Word     andMask;
*        } TxtMaskRec,  *TxtMaskRecPtr,  **TxtMaskRecHndl ;
*
****************************************************************
*
GetInGlobals start

         pha
         pha
         _GetInGlobals
         sta   >~TOOLERROR
         pl2   >orMask
         pl2   >andMask
         lda   #orMask
         ldx   #^orMask
         rtl

orMask   ds    2
andMask  ds    2
         end

****************************************************************
*
*  extern DeviceRec  GetInputDevice();
*
*  typedef struct DeviceRec  {
*        LongWord     ptrOrSlot; /* DeviceRec - slot number or jump table ptr*/
*        Word     deviceType;     /* DeviceRec - type of input device*/
*        } DeviceRec,  *DeviceRecPtr,  **DeviceRecHndl ;
*
****************************************************************
*
GetInputDevice start

         pha
         pha
         pha
         _GetInputDevice
         sta   >~TOOLERROR
         pl4   >ptrOrSlot
         pl2   >deviceType
         lda   #ptrOrSlot
         ldx   #^ptrOrSlot
         rtl

ptrOrSlot ds   4
deviceType ds  2
         end

****************************************************************
*
*  extern TxtMaskRec  GetOutGlobals();
*
*  typedef struct TxtMaskRec  {
*        Word     orMask;
*        Word     andMask;
*        } TxtMaskRec,  *TxtMaskRecPtr,  **TxtMaskRecHndl ;
*
****************************************************************
*
GetOutGlobals start

         pha
         pha
         _GetOutGlobals
         sta   >~TOOLERROR
         pl2   >orMask
         pl2   >andMask
         lda   #orMask
         ldx   #^orMask
         rtl

orMask   ds    2
andMask  ds    2
         end

****************************************************************
*
*  extern DeviceRec  GetOutputDevice();
*
*  typedef struct DeviceRec  {
*        LongWord     ptrOrSlot; /* DeviceRec - slot number or jump table ptr*/
*        Word     deviceType;     /* DeviceRec - type of input device*/
*        } DeviceRec,  *DeviceRecPtr,  **DeviceRecHndl ;
*
****************************************************************
*
GetOutputDevice start

         pha
         pha
         pha
         _GetOutputDevice
         sta   >~TOOLERROR
         pl4   >ptrOrSlot
         pl2   >deviceType
         lda   #ptrOrSlot
         ldx   #^ptrOrSlot
         rtl

ptrOrSlot ds   4
deviceType ds  2
         end
