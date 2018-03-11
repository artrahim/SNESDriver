@ Authors: Artemiss Rahim and Masroor Hussain Syed
.section	.text
@ Text section 
.global main
main:
	buttonW	.req	r5		//name commonly used registers
	gBaseR	.req	r6

	ldr	r0, =PrintNames
	bl	printf
	
	bl	getGpioPtr		//get GPIO base adress and store in label	
	ldr	r1, =GpioBase
	str	r0, [r1]
	
	ldr	r0, =GpioBase
	ldr	gBaseR, [r0]		//save GPIO address to a register

	// init latch(GPIO  9) to output
	mov	r0, #9
	mov 	r1, #1
	bl 	initGPIO
 
	// init data(GPIO 10) to input
	mov	r0, #10
	mov 	r1, #0
	bl 	initGPIO

 	// init clock(GPIO 11) to output
 	mov	r0, #11
	mov 	r1, #1
	bl 	initGPIO

	mov	r4, #0xffff		//store no button into register for comparison
mainLoop:
	
	// prompt press a button
	ldr	r0, =UserPrompt
	bl	printf

	
waitForInput:
	bl 	readSNES
	mov	buttonW, r0		//store user input into register

	mov 	r0,#10000		// wait for 0.01 sec
	bl	delayMicroseconds
	
	bl 	readSNES
	cmp	buttonW, r0		//store user input into register
	beq 	waitForInput		//if input hasn't changed or is empty loop again
	cmp	r0, r4		
	beq	waitForInput
	mov 	buttonW, r0
	mov 	r0,buttonW		//pass the button to print button
	bl	printButton
	
	// go to haltLoop$ if the button is start
	cmp		buttonW,#0bfff8
	beq		haltLoop$

	b 	mainLoop

haltLoop$:
	b		haltLoop$

initGPIO:
	push	{r4,r7}
	
	cmp 	r0,#9
	ble 	setGPIOS0TO9
	cmp 	r0,#19
	ble 	setGPIOS10T19
	cmp 	r0,#29
	ble		setGPIOS20T29
	cmp		r0,#39
	b 		setGPIOS30T39
	cmp 	r0,#49
	b		setGPIOS40T49
	cmp 	r0,#54
	ble 	setGPIOS50T54
	b 		returnInitGPIO


setGPIOS0TO9:
	ldr 	r3,[gBaseR]		// r3 has the the value of FSR 0
	mov 	r4, #0b111		// r4 = output function code
	mul		r7, r0, #3
	bic		r3,r4,lsl r7		// clear the bit 27,28,29 in the FSR 0

	orr 	r3,r1,lsl r7		// the the bit 27-29 to output
	str 	r3,[gBaseR]		// store it back to FSR 0
 	
	b	returnInitGPIO		// goto the return of the function

setGPIOS10T19:
	ldr 	r3,[gBaseR, #0x04]	// r3 has the the value of FSR 1
	mov 	r4, #0b111		// r4 = output function code
	sub 	r7,	r0, #10
	mul		r7, r7, #3
	bic		r3,r4,lsl r7	// clear the bit 3-5 in the FSR 1

	orr 	r3,r1,lsl r7		// the the bit 27-29 to output
	str 	r3,[gBaseR, #0x04]	// store it back to FSR 0
 	
	b	returnInitGPIO		// goto the return of the function
	
setGPIOS20T29:
	ldr 	r3,[gBaseR, #0x08]	// r3 has the the value of FSR 2
	mov 	r4, #0b111		// r4 = output function code
	sub 	r7,	r0, #20
	mul		r7, r7, #3
	bic	r3,r4,lsl r7			// clear the bit 3-5 in the FSR 1

	orr 	r3,r1,lsl r7		// the the bit 27-29 to output
	str 	r3,[gBaseR, #0x08]	// store it back to FSR 0
 	
	b	returnInitGPIO		// goto the return of the function
	
setGPIOS30T39:
	ldr 	r3,[gBaseR, #0x0c]	// r3 has the the value of FSR 3
	mov 	r4, #0b111		// r4 = output function code
	sub 	r7,	r0, #30
	mul		r7, r7, #3
	bic	r3,r4,lsl r7			// clear the bit 3-5 in the FSR 1

	orr 	r3,r1,lsl r7		// the the bit 27-29 to output
	str 	r3,[gBaseR, #0x0c]	// store it back to FSR 0
 	
	b	returnInitGPIO		// goto the return of the function
	
setGPIOS40T49:
	ldr 	r3,[gBaseR, #0x10]	// r3 has the the value of FSR 4
	mov 	r4, #0b111		// r4 = output function code
	sub 	r7,	r0, #40
	mul		r7, r7, #3
	bic	r3,r4,lsl r7			// clear the bit 3-5 in the FSR 1

	orr 	r3,r1,lsl r7		// the the bit 27-29 to output
	str 	r3,[gBaseR, #0x10]	// store it back to FSR 0
 	
	b	returnInitGPIO		// goto the return of the function
setGPIOS50T54:
	ldr 	r3,[gBaseR, #0x14]	// r3 has the the value of FSR 4
	mov 	r4, #0b111		// r4 = output function code
	sub 	r7,	r0, #50
	mul		r7, r7, #3
	bic	r3,r4,lsl r7			// clear the bit 3-5 in the FSR 1

	orr 	r3,r1,lsl r7		// the the bit 27-29 to output
	str 	r3,[gBaseR, #0x14]	// store it back to FSR 0
 	
	b	returnInitGPIO		// goto the return of the function
	
	// return to the caller
returnInitGPIO:
	pop		{r4,r7}
	mov 	pc,lr
	
writeLatch:				//write 0 or 1 to the latch as specified by r0
	push	{r4}
	mov	r1, #9			//r1 = pin 9 = clock line
	ldr	r4, =GpioBase
	ldr	r2, [r4]		//save GPIO address to a register
	mov	r3, #1
	lsl	r3, r1			//align pin 9 bit

	teq	r0, #0			//check the value to write

	streq	r3, [r2, #40]		//r3 = GPCLR0, clear the line
	strne	r3, [r2, #28]		//r3 = GPSET0, set the line
	pop	{r4}

	mov	pc, lr			//branch back to main routine

writeClock:				//write 0 or 1 to the clock as specified by r0
	push	{r4}
	mov	r1, #11			//r1 = pin 11 = clock line
	ldr	r4, =GpioBase
	ldr	r2, [r4]		//save GPIO address to a register

	mov	r3, #1
	lsl	r3, r1			//align pin 11 bit

	teq	r0, #0			//check the value to write

	streq	r3, [r2, #40]		//r3 = GPCLR0, clear the line
	strne	r3, [r2, #28]		//r3 = GPSET0, set the line
	pop	{r4}

	mov	pc, lr			//branch back to main routine

readData:				//read value stored in GPLEV0
	push	{r4,r7}
	mov	r0, #10			//r0 = pin 10 = data line
	
	ldr	r4, =GpioBase
	ldr	r7, [r4]		//save GPIO address to a register
	
	ldr	r1, [r7, #52]		//r1 = GPLEV0
	
	mov	r3, #1
	lsl	r3, r0			//align pin 10 bit

	and	r1, r3			//mask everything else
	teq	r1, #0			//test GPLEV0 value to read

	moveq	r0, #0			//r0 = return 0
	movne	r0, #1			//r0 = return 1
	pop	{r4,r7}

	mov	pc, lr			//branch back to main routine

readSNES:
	push	{r7,r8,lr}

	mov	r0, #1
	bl	writeClock		//write 1 to the clock
	
	mov	r0, #1
	bl	writeLatch		//write 1 to the latch
	
	mov	r0, #12
	bl	delayMicroseconds	//delay 12 usec
	
	mov	r0, #0
	bl	writeLatch		//write 0 to the latch
	
	mov	r7, #0			//loop counter
	mov	r8, #0			//buttons sample		
	
clockLoop:

	mov	r0, #6
	bl	delayMicroseconds	//delay 6 usec

	mov	r0, #0
	bl	writeClock		//write 0 to the clock
	
	mov	r0, #6
	bl	delayMicroseconds	//delay 6 usec
	
	bl	readData		//read data during rising edge of the clock
	lsl	r0, r7			//shift the  bit to its appropriate location in buttonW
	orr	r8, r0			//put the bit in the right location in buttonW

	mov	r0, #1
	bl	writeClock		//write 0 to the clock

	add	r7, #1
	cmp	r7, #16			
	blt	clockLoop		//if full data is not built loop again
	mov	r0, r8
	pop 	{r7,r8,pc}

	
printButton:
	push	{lr}
	mov	r1, #1			//initialize r7 = 1 to check for buttons pressed

bCheck:					//test if the B button is pressed
	tst	r1, buttonW
	bne 	yCheck
	// print b
	ldr	r0, =PressB
	bl	printf
	// branch return 	
	b	returnPrintButton
yCheck:					//test if the Y button is pressed
	lsl	r1, #1
	tst	r1, buttonW
	bne 	selectCheck
	// print b
	ldr	r0, =PressY
	bl	printf
	// branch return 
	b	returnPrintButton
selectCheck:				//test if the select button is pressed
	lsl	r1, #1
	tst	r1, buttonW
	bne 	startCheck
	// print b
	ldr	r0, =PressSelect
	bl	printf
	// branch return 
	b	returnPrintButton
startCheck:				//test if the start button is pressed
	lsl	r1, #1
	tst	r1, buttonW
	bne 	upCheck
	// print b
	ldr	r0, =PressStart
	bl	printf
	// branch return 
	b	haltLoop$
upCheck:				//test if the up button is pressed
	lsl	r1, #1
	tst	r1, buttonW
	bne 	downCheck
	// print b
	ldr	r0, =PressUp
	bl	printf
	// branch return 
	b	returnPrintButton
downCheck:				//test if the down button is pressed
	lsl	r1, #1
	tst	r1, buttonW
	bne 	leftCheck
	// print b
	ldr	r0, =PressDown
	bl	printf
	// branch return 
	b	returnPrintButton
leftCheck:				//test if the left button is pressed
	lsl	r1, #1
	tst	r1, buttonW
	bne 	rightCheck
	// print b
	ldr	r0, =PressLeft
	bl	printf
	// branch return 
	b	returnPrintButton
rightCheck:				//test if the right button is pressed
	lsl	r1, #1
	tst	r1, buttonW
	bne 	aCheck
	// print b
	ldr	r0, =PressRight
	bl	printf
	// branch return 
	b	returnPrintButton
aCheck:					//test if the A button is pressed
	lsl	r1, #1
	tst	r1, buttonW
	bne 	xCheck
	// print b
	ldr	r0, =PressA
	bl	printf
	// branch return 
	b	returnPrintButton
xCheck:					//test if the X button is pressed
	lsl	r1, #1
	tst	r1, buttonW
	bne 	leftTriggerCheck
	// print b
	ldr	r0, =PressX
	bl	printf
	// branch return 
	b	returnPrintButton
	
leftTriggerCheck:			//test if the left trigger is pressed
	lsl	r1, #1
	tst	r1, buttonW
	bne 	rightTriggerCheck
	// print b
	ldr	r0, =PressLeftTrigger
	bl	printf
	// branch return 
	b	returnPrintButton
	
rightTriggerCheck:			//test if the right trigger is pressed
	lsl	r1, #1
	tst	r1, buttonW
	bne 	returnPrintButton
	// print b
	ldr	r0, =PressRightTrigger
	bl	printf

returnPrintButton:
	pop	{pc}			//branch back to main

@ Data section
.section	.data

GpioBase:
.word		0

PrintNames:
.asciz		"Created by: Artemiss Rahim and Masroor Hussain Syed\n"

UserPrompt:
.asciz		"Please press a button...\n"

PressB:
.asciz		"You have pressed B\n"

PressY:
.asciz		"You have pressed Y\n"

PressSelect:
.asciz		"You have pressed Select\n"

PressStart:
.asciz		"Program is terminating...\n"

PressUp:
.asciz		"You have pressed Joy-pad UP\n"

PressDown:
.asciz		"You have pressed Joy-pad DOWN\n"

PressLeft:
.asciz		"You have pressed Joy-pad LEFT\n"

PressRight:
.asciz		"You have pressed Joy-pad RIGHT\n"

PressA:
.asciz		"You have pressed A\n"

PressX:
.asciz		"You have pressed X\n"

PressLeftTrigger:
.asciz		"You have pressed Left Trigger\n"

PressRightTrigger:
.asciz		"You have pressed Right Trigger\n"
