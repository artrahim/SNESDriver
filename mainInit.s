
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

@ Data section
.section	.data

GpioBase:
.word		0
