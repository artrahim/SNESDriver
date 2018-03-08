@author: Artemiss Rahim and Masroor Hussain Syed
@Masroor  Student ID: 30023900
@Artemiss Student ID: 30016929
@Tutorial: T-02


@ Code section
.section    .text

.global main
main:
	@ Prints the creator names
        bl      InitUART        	@ Initialize the UART

        ldr     r0, =creator    	@ String pointer
        mov     r1, #56        		@ String's length
        bl      WriteStringUART 	@ Write the string to the UART


	@ main Loop
	haltLoop$:

	@ print the promt for the command
	ldr     r0, =cmdPmt    		@ String pointer
	mov     r1, #36        		@ String's length
	bl      WriteStringUART 	@ Write the string to the UART


	@ reads the command
        ldr     r0, =userCmd     	@ buffer address
        mov     r1, #64    		@ buffer size
        bl      ReadLineUART 		@ Read from the UART until a new line is encountered.
					@ R0 = number of ASCII characters read.

	@ checks the length of the user input
	@ if the len(userInput) > 3 then promts invalid Cmd
	@ if the len(userInput) = 3 then goto andCheck
	@ if the len(userInput) = 2 then goto orCheck
	cmp	r0, #3
	beq	andCheck
	bgt	invalidCmd
	cmp	r0, #2
	beq 	orCheck

	andCheck:

		ldr    	r0, =userCmd     	@ base address of userCmd
		ldr    	r1, =andCmd     	@ base address of andCmd


		ldrb	r2, [r0, #0] 		@r2 is the userCmd[0]
		ldrb	r3, [r1, #0] 		@r4 is the andCmd[0]

		cmp 	r2, r3
		bne	invalidCmd

		ldrb	r2, [r0, #1] 		@r2 is the userCmd[1]
		ldrb	r3, [r1, #1] 		@r4 is the andCmd[1]

		cmp 	r2, r3
		bne	invalidCmd

		ldrb	r2, [r0, #2] 		@r2 is the userCmd[2]
		ldrb	r3, [r1, #2] 		@r4 is the andCmd[2]

		cmp 	r2, r3
		bne	invalidCmd

		mov 	r10, #1			@ r10 = 1,so remember user entered AND
		b 	getFirst


	orCheck:

		ldr    	r0, =userCmd     	@ base address of userCmd
		ldr    	r1, =orCmd     		@ base address of orCmd

		ldrb	r2, [r0, #0] 		@r2 is the userCmd[0]
		ldrb	r3, [r1, #0] 		@r4 is the orCmd[0]

		cmp 	r2, r3
		bne	invalidCmd

		ldrb	r2, [r0, #1] 		@r2 is the userCmd[1]
		ldrb	r3, [r1, #1] 		@r4 is the orCmd[1]

		cmp 	r2, r3
		bne	invalidCmd


		mov 	r10, #0			@ r10 = 0, so we remember user entered OR
		b 	getFirst

	@ gets the first binary number
	getFirst:
		ldr	r0, =fir_prompt		@ prompts for the first binary number
		mov	r1, #39
		bl	WriteStringUART

		ldr	r0, =firstBuffer	@ reads the first binary number
		mov	r1, #64
		bl	ReadLineUART

		@ loads the number entered by user for error checking
		ldr	r4, =firstBuffer	@ R4 = buffer address
		mov	r6, r0			@ R6 = size of first array
		mov	r1, #0			@ R1 = offset

	checkBin1:			@ check whether first number is valid
		ldrb	r2, [r4, r1]
		cmp	r2, #48		@ check if input is 1 or 0, otherwise print error and ask for new command
		beq	corrBin1
		cmp	r2, #49
		beq	corrBin1

		ldr     r0, =wrong_num		@ Write error message to UART
		mov	r1, #22
		bl	WriteStringUART
		b	getFirst		@ branch back to first for prompt
	
	@ loops over the whole input to see if the first number is valid
	corrBin1:
		add	r1, #1		@ Increment offset by one
		cmp	r1, r6
		blt	checkBin1

		@ loads the first number to convert it to binary
		mov	r5, #0			@ R5 = first binary register
		mov	r0, #0			@ R0 = offset/index
		ldr	r1, =firstBuffer	@ R1 = first input

	@ convert first number from ASCII to binary
	asciiConv1:
		lsl	r5, #1
		ldrb	r2, [r1, r0]	@ load bit from input
		and	r2, r2, #1	@ save the least significant bit
		orr	r5, r5, r2

		add	r0, #1		@ increment offset
		cmp 	r0, r6		@ exit loop if offset is greater than input
		blt	asciiConv1
	
	@ gets the second binary number
	getSecond:
		ldr	r0, =sec_prompt		@ prompts for the second binary number
		mov	r1, #40
		bl	WriteStringUART

		ldr	r0, =secondBuffer	@ reads the second binary number
		mov	r1, #64
		bl	ReadLineUART

		ldr	r4, =secondBuffer	@ R4 = buffer address
		mov	r8, r0			@ R8 = size of second array
		mov	r1, #0			@ R1 = offset

	checkBin2:				@ check whether first number is valid
		ldrb    r2, [r4, r1]
		cmp	r2, #48			@ check if input is 1 or 0, otherwise print error and ask for new command
		beq	corrBin2
		cmp	r2, #49
		beq	corrBin2

		ldr     r0, =wrong_num		@ Write error message to UART
		mov	r1, #22
		bl	WriteStringUART
		b	getSecond		@ branch back to first for prompt
	
	@ loops over the whole input to see if the first number is valid
	corrBin2:
		add	r1, #1		@ Increment offset
		cmp	r1, r8
		blt	checkBin2

		@ loads the second number to convert it to binary
		mov	r7, #0			@ R7 = second binary register
		mov	r0, #0			@ R0 = offset
		ldr	r1, =secondBuffer	@ R1 = second input

	@ convert second number to from ASCII to binary
	asciiConv2:	
		lsl	r7, #1
		ldrb	r2, [r1, r0]	@ load bit from input
		and	r2, r2, #1	@ save the least significant bit
		orr	r7, r7, r2

		add	r0, #1		@ increment offset
		cmp 	r0, r8		@ exit loop if offset is greater than input
		blt	asciiConv2

	calculation:
		@ if r10 == 1 do AND otherwise do OR
		cmp 	r10,# 1
		beq	andOp
		orr 	r9,r5,r7	@ do OR
		b 	binConv		@ branch to convert binary to acii

	@ do AND
	andOp:	
		and 	r9, r5,r7
		b 	binConv		@ branch to convert binary to acii

	@ convert binary to acii
	binConv:
		ldr	r2, =resultBuffer	@ R2 = result buffer address
		mov 	r4, #0		 	@ r4 is the index i = 0
		cmp 	r6,r8			@ store the len of the larger number in r6
		bgt	contBin		
		mov 	r6, r8

	contBin:
		mov 	r0, #1		@ store 1 in r0
		lsl	r0,r6 		@ shift it left by the size of the larger number
	
	@ Conversion Loop
	binLoop:
		asr	r0, #1		@ right shift r0 by 1
		and 	r1, r9, r0	@ and r0 and r1 to see where the number at the location is 49 or 48
		
		cmp 		r1 , #0		@ if r1 > 0 then put 1 in the corresponding result buffer index otherwise but 0 
		bgt 		andOne		
		mov 		r8, #48
		strb		r8,[r2,r4]	
		b 		endLoop
	
	andOne:
		mov 		r8,#49
		strb		r8,[r2,r4]
	
	@ end the conversion loop
	endLoop:	
		add 		r4, #1		@ i++
		cmp 		r4,r6
		blt		binLoop

		
	@ print the result promt for the command

	ldr     r0, =resultPmt   	@ String pointer
	mov     r1, #15        		@ String's length
	bl      WriteStringUART 	@ Write the string to the UART

	ldr     r0, =resultBuffer   	@ String pointer
	mov     r1, r6        		@ String's length
	bl      WriteStringUART 	@ Write the string to the UART

	ldr     r0, =newLine   		@ String pointer
	mov     r1, #2       		@ String's length
	bl      WriteStringUART 	@ Write the string to the UART
		
	b       haltLoop$		@ go back to the top of the loop

	invalidCmd:
		// print the promt for the command
		ldr     r0, =cmdErr    		@ String pointer
		mov     r1, #25        		@ String's length
		bl      WriteStringUART 	@ Write the string to the UART
		b       haltLoop$		@ go back to the top of the loop


@ Data section
.section    .data

creator:
.ascii		"Creator Names: Artemiss Rahim and Masroor Hussain Syed\r\n"

cmdPmt:
.ascii		"Please enter a command (AND, OR): \r\n"

resultPmt:
.ascii		"The result is: "

newLine:	
.ascii		"\r\n"

cmdErr:
.ascii 		"Command not recognized!\r\n"


andCmd:
.ascii		"A", "N", "D"

orCmd:
.ascii 		"O","R"

userCmd:
.rept		64
.ascii 		" "
.endr

wrong_num:
.ascii		"Wrong number format!\r\n"

fir_prompt:
.ascii		"Please enter the first binary number:\r\n"

sec_prompt:
.ascii		"Please enter the second binary number:\r\n"

firstBuffer:
.rept		64
.byte		0
.endr

secondBuffer:
.rept		64
.byte		0
.endr

resultBuffer:
.rept		64
.byte		0
.endr
