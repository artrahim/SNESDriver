@ Authors: Artemiss Rahim and Masroor Hussain Syed
.section	.text
@ Text section 
.global main
main:
	buttonW	.req	r5		//name commonly used registers
	gBaseR	.req	r6
	
	bl	getGpioPtr		//get GPIO base adress and store in label	
	ldr	r1, =GpioBase
	str	r0, [r1]
	
	ldr	r0, =GpioBase
	ldr	gBaser, [r0]		//save GPIO address to a register

	// init latch(GPIO  9) to output
	mov	r0, #9
	mov 	r1, #0
	bl 	initGPIO
 
	// init latch(GPIO 10) to input
	mov	r0, #10
	mov 	r1, #1
	bl 	initGPIO

 	// init latch(GPIO 11) to output
 	mov	r0, #11
	mov 	r1, #0
	bl 	initGPIO


mainLoop:
	// promt press a button

	// write 1 to clock
	mov 	r0, #1
	bl 	Write_Clock

	// write 1 to latch
	mov 	r0, #1
	bl 	Write_Latch
	
	// delay by 12 ms
	mov	r0, #12
	bl 	delayMircoseconds	
	
	// write 0 to latch
	mov	r0, #0
	bl 	Write_Latch
	
	bl 	readSNES



	b mainLoop

haltLoop$:
	b		haltLoop$

initGPIO:
	// check for the gpio 9
	cmp 	r0,#9
	beq 	setGPIO9
	
	// check for the gpio 10
	cmp 	r0,#10
	beq 	setGPIO10
		
	// because the gpio is not 9 or 10 then it must be GPIO 11
	b 	setGPIO11
	
setGPIO9:
	ldr 	r3,[gBaseR]		// r3 has the the value of FSR 0
	
	mov 	r4, #0b111		// r4 = output function code
	bic	r3,r4,lsl #27		// clear the bit 27,28,29 in the FSR 0

	orr 	r3,r2,lsl #27		// the the bit 27-29 to output
	str 	r3,[gBaseR]		// store it back to FSR 0
 	
	b	returnInitGPIO		// goto the return of the function

setGPIO10:
	ldr 	r3,[gBaseR, #0x04]	// r3 has the the value of FSR 1
	
	mov 	r4, #0b111		// r4 = output function code
	bic	r3,r4			// clear the bit 0-2 in the FSR 1

	orr 	r3,r2			// the the bit 27-29 to output
	str 	r3,[gBaseR, #0x04]	// store it back to FSR 0
 	
	b	returnInitGPIO		// goto the return of the function

setGPIO11:
	ldr 	r3,[gBaseR, #0x04]	// r3 has the the value of FSR 1
	
	mov 	r4, #0b111		// r4 = output function code
	bic	r3,r4,lsl #3			// clear the bit 3-5 in the FSR 1

	orr 	r3,r2,lsl #3		// the the bit 27-29 to output
	str 	r3,[gBaseR, #0x04]	// store it back to FSR 0
 	
	b	returnInitGPIO		// goto the return of the function
	
	// return to the caller
returnInitGPIO:
	mov pc,lr
	
writeLatch:				//write 0 or 1 to the latch as specified by r0
	mov	r1, #9			//r1 = pin 9 = clock line
	ldr	r2, [gBaseR]		//r2 = base GPIO register
	mov	r3, #1
	lsl	r3, r1			//align pin 9 bit

	teq	r0, #0			//check the value to write

	streq	r3, [r2, #40]		//r3 = GPCLR0, clear the line
	strne	r3, [r2, #28]		//r3 = GPSET0, set the line

	mov	pc, lr			//branch back to main routine

writeClock:				//write 0 or 1 to the clock as specified by r0
	mov	r1, #11			//r1 = pin 11 = clock line
	ldr	r2, [gBaseR, #0x04]	//r2 = base GPIO register
	mov	r3, #1
	lsl	r3, r1			//align pin 11 bit

	teq	r0, #0			//check the value to write

	streq	r3, [r2, #40]		//r3 = GPCLR0, clear the line
	strne	r3, [r2, #28]		//r3 = GPSET0, set the line

	mov	pc, lr			//branch back to main routine

readData:				/read value stored in GPLEV0
	mov	r0, #10			//r0 = pin 10 = data line
	ldr	r2, [gBaseR, #0x04]	//r2 = base register
	ldr	r1, [r2, #52]		//r1 = GPLEV0
	mov	r3, #1
	lsl	r3, r0			//align pin 10 bit

	and	r1, r3			//mask everything else
	teq	r1, #0			//test GPLEV0 value to read

	moveq	r0, #0			//r0 = return 0
	movne	r0, #1			//r0 = return 1

	mov	pc, lr			//branch back to main routine

ReadSNES:
	mov	r0, #1
	bl	writeClock		//write 1 to the clock
	mov	r0, #1
	bl	writeLatch		//write 1 to the latch
	mov	r0, #12
	bl	delayMircoseconds	//delay 12 usec
	mov	r0, #0
	bl	writeLatch		//write 0 to the latch
	mov	r7, #0			//initialize loop variables
	mov	r8, #0		
	
clockLoop:
	mov	r0, #6
	bl	delayMircoseconds	//delay 6 usec
	mov	r0, #0
	bl	writeClock		//write 0 to the clock
	mov	r0, #6
	bl	delayMircoseconds	//delay 6 usec
	
	mov	r0, #1			//write 1 to the clock
	bl	writeClock
	bl	readData		//read data during rising edge of the clock
	lsl	r0, r7			//shift the  bit to its appropriate location in buttonW
	and	r8, r0		//put the bit in the right location in buttonW
	add	r7, #1
	cmp	r7, #16			
	blt	clockLoop		//if full data is not built loop again
	mov	r0, r8
	mov	pc, lr
	
printPressed:
	mov	r7, #1			//initialize r7 = 1 to check for buttons pressed
	ldr	r0, =HavePressed	//print the prompt
	bl	printf

buttonOneCheck:				//test if the B button is pressed
	teq	r7, buttonW
	lsl	r7, #1
	beq	buttonTwoCheck		//if pressed print indication
	mov	r0, =PressB
	bl	printf
	
buttonTwoCheck:				//test if the Y	button is pressed

	
	mov	r0, #6
	bl	delayMicroseconds	//delay 6 usec



@ Data section
.section	.data

GpioBase:
.word		0

HavePressed:
.asciz		"Please press a button..."

PressB:
.asciz		"You have pressed B"

PressY:
.asciz		"You have pressed Y"

PressSelect:
.asciz		"You have pressed Select"

PressStart:
.asciz		"You have pressed Start"

PressUp:
.asciz		"You have pressed Joy-pad UP"

PressDown:
.asciz		"You have pressed Joy-pad DOWN"

PressLeft:
.asciz		"You have pressed Joy-pad LEFT"

PressRight:
.asciz		"You have pressed Joy-pad RIGHT"

PressA:
.asciz		"You have pressed A"

PressX:
.asciz		"You have pressed X"

PressLeftTrigger:
.asciz		"You have pressed Left Trigger"

PressRightTrigger:
.asciz		"You have pressed Right Trigger"
