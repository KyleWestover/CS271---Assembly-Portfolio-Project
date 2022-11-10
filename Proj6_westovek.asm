TITLE Project 6 - String Primitives and Macros     (Proj6_westovek.asm)

; Author: Kyle Westover
; Last Modified: 13Mar22
; OSU email address: westovek@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: Project 6                Due Date: 13Mar22
; Description: Program takes 10 signed integers entered by user,
;				displays them, displays their sum, and displays
;				their rounded average

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Gets string from user
;
; Preconditions: none
;
; Receives:
; displayPrompt = prompt for user to enter number
; inputCount = size of array
;
; returns: 
; bytesRead = length of string entered by user
; userInput = array holding user input
; ---------------------------------------------------------------------------------
mGetString		MACRO	displayPrompt, inputCount, bytesRead, userInput
PUSH	EAX
PUSH	ECX
PUSH	EDX

MOV		EDX, displayPrompt
CALL	WriteString
MOV		EDX, userInput
MOV		ECX, inputCount
CALL	ReadString
MOV		bytesRead, EAX

POP		EDX
POP		ECX
POP		EAX
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays string 
;
; Preconditions: none
;
; Receives:
; displayString = string to be displayed
;
; returns: none
; ---------------------------------------------------------------------------------
mDisplayString	MACRO	displayString

MOV		EDX, displayString
CALL	WriteString

ENDM

INTARRAYSIZE = 10

.data

	programTitle			BYTE	"Program Title: Program 6 - String Primitives and Macros", 0
	programmerName			BYTE	"Programmer: Kyle Westover", 0
	programInstructions1	BYTE	"Please enter 10 signed decimal integers.", 0
	programInstructions2	BYTE	"Each value entered must fit into a 32-bit register. ", 10, 13
							BYTE	"After all 10 numbers have been entered, the program will display ", 10, 13 
							BYTE	"a list of the integers, their sum, and their rounded average.", 0
	inputPrompt				BYTE	"Please enter a signed integer: ", 0
	wrongInputError			BYTE	"ERROR: Input was either not a signed integer or number was too large. ", 0
	noInputError			BYTE	"ERROR: No input entered. ", 0
	integerArray			SDWORD	10 DUP(0)
	sum						SDWORD	?
	average					SDWORD	?
	numInt					DWORD	0
	stringBuffer			BYTE	21 DUP(0)
	bufferSize				DWORD	SIZEOF	stringBuffer
	printString				BYTE	11 DUP(0)
	printStringSize			DWORD	SIZEOF	printString
	intermediateCalcs		SDWORD	0
	outerLoopCounter		DWORD	0
	commaSpace				BYTE	", ", 0
	numberDisplay			BYTE	"You entered the following numbers:", 10, 13, 0
	sumDisplay				BYTE	"Sum of entered numbers: ", 0
	avgDisplay				BYTE	"Truncated average of entered numbers: ", 0
	farewell				BYTE	"See you later!", 0

.code
main PROC

_CallIntro:				; call intro procedure
	PUSH	OFFSET	programTitle
	PUSH	OFFSET	programmerName
	PUSH	OFFSET	programInstructions1
	PUSH	OFFSET	programInstructions2
	CALL	intro

_InitiateReadVal:		; set up registers for ReadValLoop
	MOV		ECX, INTARRAYSIZE
	MOV		EAX, INTARRAYSIZE
	
_ReadValLoop:			; call readVal procedure, maintain loop
	PUSH	outerLoopCounter
	PUSH	OFFSET	intermediateCalcs
	PUSH	OFFSET	noInputError
	PUSH	OFFSET	wrongInputError
	PUSH	OFFSET	integerArray
	PUSH	OFFSET	sum
	PUSH	OFFSET	average
	PUSH	OFFSET	stringBuffer
	PUSH	OFFSET	numInt
	PUSH	bufferSize
	PUSH	OFFSET	inputPrompt
	CALL	readVal
	ADD		outerLoopCounter, 4
	MOV		intermediateCalcs, 0
	LOOP	_ReadValLoop
	CALL	CrLF

_ListDisplaySetup:		; set up display for strings
	MOV		EDX, OFFSET numberDisplay
	Call	WriteString
	MOV		EDI, OFFSET integerArray
	MOV		ECX, INTARRAYSIZE
	
_ListDisplayLoop:		; display user-entered strings
	PUSH	bufferSIZE
	PUSH	OFFSET printString
	PUSH	printStringSize
	PUSH	OFFSET	numInt
	PUSH	[EDI]
	PUSH	OFFSET stringBuffer
	CALL	writeVal
	ADD		EDI, 4
	CMP		ECX, 1
	JE		_CallLoop
	MOV		EDX, OFFSET commaSpace
	CALL	WriteString

_CallLoop:				; handle loop
	LOOP	_ListDisplayLoop
	CALL	CrLF
	CALL	CrLF

_CallCalcSum:			; calculate sum
	PUSH	OFFSET	sum
	PUSH	OFFSET	integerArray
	CALL	calcSum

_SumDisplay:			; diplay sum
	MOV		EDX, OFFSET sumDisplay
	Call	WriteString

	PUSH	bufferSize
	PUSH	OFFSET printString
	PUSH	printStringSize
	PUSH	OFFSET numInt
	PUSH	sum
	PUSH	OFFSET stringBuffer
	Call	WriteVal
	CALL	CrLf
	Call	CrLF

_CallCalcAvg:			; calculate average
	PUSH	OFFSET	average
	PUSH	sum
	call	calcAvg

_AvgDisplay:			; display average
	MOV		EDX, OFFSET avgDisplay
	Call	WriteString

	PUSH	bufferSize
	PUSH	OFFSET printString
	PUSH	printStringSize
	PUSH	OFFSET numInt
	PUSH	average
	PUSH	OFFSET stringBuffer
	Call	WriteVal
	call	CrLF
	CALL	CrLF
	
_Farewell:				; say goodbye to user
	MOV		EDX, OFFSET farewell
	CALL	WriteString

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
;	Name: introduction
;	
;	introduces the programmer and program by name and displays program description
;	
;	Preconditions: none
;
;	Postconditions: none
;
;	Receives: 
;		[EBP+20] = title of program
;		[EBP+16] = name of programmer
;		[EBP+12] = first part of description for user
;		[EBP+8] = second part of description for user
;		
;	Returns: none
; ---------------------------------------------------------------------------------
intro	PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX
	MOV		EDX, [EBP+20]
	CALL	WriteString
	CALL	CrLF
	MOV		EDX, [EBP+16]
	CALL	WriteString
	CaLL	CrLF
	CALL	CrLF
	MOV		EDX, [EBP+12]
	CALL	WriteString
	CALL	CrLF
	MOV		EDX, [EBP+8]
	CALL	WriteString
	Call	CrLF
	Call	CrLF
	POP		EDX
	POP		EBP
	RET		16
intro		ENDP

; ---------------------------------------------------------------------------------
;	Name: readVal
;	
;	Takes user input string and converts to integer
;	
;	Preconditions: User must enter signed integer that fits in 32-bit register
;
;	Postconditions: none
;
;	Receives:
;		[EBP+8] = prompt for user to enter string
;		[EBP+12] = size of stringBuffer array
;		[EBP+16] = digit counter
;		[EBP+20] = stringBuffer array to hold string
;		[EBP+24] = variable to hold average
;		[EBP+28] = variable to hold sum
;		[EBP+32] = array to hold converted integers
;		[EBP+36] = error message for non-integers and too large values
;		[EBP+40] = error message for no value entered
;		[EBP+44] = holder for intermediate calculations
;		[EBP+48] = counter for loop in main
;		
;
;	Returns: 
;		[EBP+32] = array with integer entered by user
; ---------------------------------------------------------------------------------
readVal	PROC
	LOCAL	NegFlag:DWORD
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

_GetString:				; invoke mGetString macro to get and store user input
	mGetString	[EBP+8], [EBP+12], [EBP+16], [EBP+20]
	MOV		ECX, [EBP+16]				; numInt OFFSET to ECX
	CLD
	MOV		ESI, [EBP+20]				; stringBuffer OFFSET to ESI
	MOV		EDI, [EBP+20]				; stringBuffer OFFSET to EDI

_ToInt:					; check strings for non-integers
	LODSB
	CMP		AL, 48
	JL		_NotInt
	CMP		AL, 57
	JG		_NotInt
	SUB		AL,	48
	STOSB
	LOOP	_ToInt

_InitIntermediateSum:	; set up registers to calculate sum
	MOV		ECX, [EBP+16]				; numInt OFFSET to ECX
	MOV		ESI, [EBP+20]				; stringBuffer OFFSET to ESI
	MOV		EDI, [EBP+44]				; intermediateCalcs OFFSET to EDI
	
_MultLoopOutside:		; Outside loop of integer multiplication
	MOV		EBX, 10
	MOV		EAX, 10
	MOV		EDX, ECX

_MultiplierLoop:		; multiply inividual digits to make one integer value
	DEC		EDX
	CMP		EDX, 0
	JE		_ZeroMultiplier
	CMP		EDX, 1
	JE		_AddToIntermediateSum
	PUSH	EDX
	MUL		EBX
	POP		EDX
	JMP		_MultiplierLoop

_AddToIntermediateSum:	; Add each digit's multiplied values
	MOV		EBX, 0
	MOV		BL, BYTE PTR [ESI]
	PUSH	EDX
	MUL		EBX
	POP		EDX
	ADD		[EDI], EAX
	INC		ESI
	LOOP	_MultLoopOutside

_ZeroMultiplier:		; add number in ones place (no multiplication)
	MOV		EAX, 0
	MOV		AL, BYTE PTR [ESI]
	ADD		[EDI], EAX
	MOV		EAX, [EDI]
	; check positive overflow
	CMP		NegFlag, 1
	JNE		_IntArray
	MOV		EAX, [EDI]
	MOV		EBX, -1
	IMUL	EBX
	; check negative oveflow
	MOV		[EDI], EAX
	JMP		_IntArray
	
_NotInt:				; handle non-integers
	CMP		AL, 43
	JE		_PositiveInt
	CMP		AL, 45
	JE		_NegativeInt
	JMP		_IntErrorMessage

_NegativeInt:			; handle conversion of negative integers
	MOV		NegFlag, 1
	MOV		AL, 0
	PUSH	EAX
	MOV		EAX, [EBP+16]
	DEC		EAX
	MOV		[EBP+16], EAX
	DEC		ECX
	POP		EAX

	JMP		_ToInt

_PositiveInt:			; handle conversion of positive integers
	MOV		AL, 0
	PUSH	EAX
	MOV		EAX, [EBP+16]
	DEC		EAX
	MOV		[EBP+16], EAX
	DEC		ECX
	POP		EAX
	JMP		_ToInt


_IntErrorMessage:		; display error message for non-integers
	MOV		EDX, [EBP+36]
	CALL	WriteString
	MOV		EAX, 0
	MOV		ECX, [EBP+12]
	MOV		EDI, [EBP+20]
	CLD
	REP		STOSB
	JMP		_GetString

_IntArray:				; add integer to array
	MOV		ESI, EDI
	MOV		EBX, [ESI]
	MOV		EAX, [EBP+48]				; outer loop counter
	MOV		EDI, [EBP+32]				; integer array
	MOV		[EDI+EAX], EBX

_ClearArray:			; clear string array
	MOV		EAX, 0
	MOV		ECX, [EBP+12]
	MOV		EDI, [EBP+20]
	CLD
	REP		STOSB

_ClearFlag:				; clear negative flag
	MOV		NegFlag, 0

_EndReadVal:			; end procedure
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		44
readVal		ENDP

; ---------------------------------------------------------------------------------
;	Name: writeVal
;	
;	Converts integer to string and writes it to output
;	
;	Preconditions: none
;
;	Postconditions: none
;
;	Receives:
;		[EBP+8] = empty stringBuffer array to hold semi-converted strings
;		[EBP+12] = value to be converted from int to string
;		[EBP+16] = digit counter
;		[EBP+20] = size of printString array
;		[EBP+24] = printString array to hold fully converted string
;		[EBP+28] = size of stringBuffer array
;
;	Returns: 
;		none
; ---------------------------------------------------------------------------------
writeVal PROC
	LOCAL	Minus:DWORD
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	MOV		EAX, [EBP+12]				; integerArray/sum/average value
	MOV		EDI, [EBP+8]				; stringBuffer OFFSET to EDI
	MOV		ESI, [EBP+8]				; stringBuffer OFFSET to ESI
	MOV		ECX, 0
	MOV		EBX, 10
	MOV		Minus, 45					; minusSign to LOCAL Minus

_CheckSign:								; checks if negative int
	CMP		EAX, 0
	JGE		_SplitInt

_NegateString:							; adds '-', makes integer positive, increments EDI
	MOV		EBX, Minus
	MOV		[EDI], EBX
	MOV		EBX, -1
	IMUL	EBX
	INC		EDI
	MOV		EBX, 10

_SplitInt:								; splits integer value into digits
	INC		ECX							; digit counter
	MOV		EDX, 0
	CDQ
	IDIV	EBX
	MOV		[EDI], EDX
	INC		EDI
	CMP		EAX, 1
	JGE		_SplitInt
	CMP		EAX, -1
	JLE		_SplitInt
	MOV		[EBP+16], ECX				; ECX to numInt 


_NegString:								; negates string
	MOV		EDI, [EBP+24]				; printString to EDI
	MOV		ESI, [EBP+8]				; stringBuffer to ESI
	MOV		ECX, [EBP+16]				; numInt to ECX
	CLD
	LODSB
	CMP		AL, 45
	JNE		_NegCleanup
	STOSB
	JMP		_ConvertStringSetup

_NegCleanup:							; alters ESI as needed for negative string
	DEC		ESI

_ConvertStringSetup:					; set up loop to convert int to string
	ADD		ESI, ECX
	DEC		ESI

_ConvertToString:						; convert each int digit to string
	STD
	LODSB
	ADD		AL, 48
	CLD
	STOSB
	LOOP	_ConvertToString

_WriteStrings:							; invoke mDisplayString macro to display string to user
	mDisplayString	[EBP+24]

_ClearPrintString:						; clear printString array
	MOV		EAX, 0
	MOV		ECX, [EBP+20]
	MOV		EDI, [EBP+24]
	CLD
	REP		STOSB

_ClearStringBuffer:						; clear stringBuffer array
	MOV		EAX, 0
	MOV		ECX, [EBP+28]
	MOV		EDI, [EBP+8]
	CLD
	REP		STOSB
	
	
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		24
writeVal	ENDP

; ---------------------------------------------------------------------------------
;	Name: calcSum
;	
;	calculate sum of 10 user-entered numbers
;	
;	Preconditions: none
;
;	Postconditions: none
;
;	Receives:
;		[EBP+8] = sum variable
;		[EBP+12] = array countaining all 10 user entered values in int form
;
;	Returns: 
;		[EBP+8] = sum variable with sum of all 10 numbers
; ---------------------------------------------------------------------------------
calcSum		PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	ECX
	PUSH	EDI
	PUSH	ESI

_CalcSumSetup:							; initialize sum calculation
	MOV		EDI, [EBP+12]				; sum OFFSET to EDI
	MOV		EAX, [EDI]					; sum accumulator
	MOV		ESI, [EBP+8]				; integerArray OFFSET to ESI
	MOV		ECX, INTARRAYSIZE			; ECX = 10

_CalcSumLoop:							; add all 10 digits to sum
	ADD		EAX, [ESI]
	ADD		ESI, 4
	LOOP	_CalcSumLoop
	MOV		[EDI], EAX

	POP		ESI
	POP		EDI
	POP		ECX
	POP		EAX
	POP		EBP
	RET		8
calcSum		ENDP

; ---------------------------------------------------------------------------------
;	Name: calcAvg
;	
;	calculate truncated average of 10 user-entered numbers
;	
;	Preconditions: sum must already be calculated
;
;	Postconditions: none
;
;	Receives:
;		[EBP+8] = value of sum variable
;		[EBP+12] = average variable
;
;	Returns: 
;		[EBP+8] = average variable with truncated average of all 10 numbers
; ---------------------------------------------------------------------------------
calcAvg		PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	EDI

	MOV		EAX, [EBP+8]				; sum to EAX
	MOV		EDI, [EBP+12]				; average OFFSET to EDI
	CDQ
	MOV		EBX, INTARRAYSIZE
	IDIV	EBX
	MOV		[EDI], EAX

	POP		EDI
	POP		EBX
	POP		EAX
	POP		EBP
	RET		8
calcAvg		ENDP

END main
