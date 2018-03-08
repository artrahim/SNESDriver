@ Authors: Artemiss Rahim and Masroor Hussain Syed
.section	.text
@ Text section 
.global main
main:
	buttonW	.req	r5		//name commonly used registers
	gBaser	.req	r6
	
	bl	getGpioPtr		//get GPIO base adress and store in label	
	ldr	r1, =GpioBase
	str	r0, [r1]
	
	ldr	r0, =GpioBase
	ldr	gBaser, [r0]		//save GPIO address to a register
	
	
writeLatch:				//write 0 or 1 to the latch as specified by r0
	mov	r1, #9			//r1 = pin 9 = clock line
	ldr	r2, [GpioBase]		//r2 = base GPIO register
	mov	r3, #1
	lsl	r3, r1			//align pin 9 bit

	teq	r0, #0			//check the value to write

	streq	r3, [r2, #40]		//r3 = GPCLR0, clear the line
	strne	r3, [r2, #28]		//r3 = GPSET0, set the line

	mov	pc, lr			//branch back to main routine

writeClock:				//write 0 or 1 to the clock as specified by r0
	mov	r1, #11			//r1 = pin 11 = clock line
	ldr	r2, =0x3F200000		//r2 = base GPIO register
	mov	r3, #1
	lsl	r3, r1			//align pin 11 bit

	teq	r0, #0			//check the value to write

	streq	r3, [r2, #40]		//r3 = GPCLR0, clear the line
	strne	r3, [r2, #28]		//r3 = GPSET0, set the line

	mov	pc, lr			//branch back to main routine

readData:				/read value stored in GPLEV0
	mov	r0, #10			//r0 = pin 10 = data line
	ldr	r2, =0x3F200000		//r2 = base register
	ldr	r1, [r2, #52]		//r1 = GPLEV0
	mov	r3, #1
	lsl	r3, r0			//align pin 10 bit

	and	r1, r3			//mask everything else
	teq	r1, #0			//test GPLEV0 value to read

	moveq	r4, #0			//r4 = return 0
	movne	r4, #1			//r4 = return 1

	mov	pc, lr			//branch back to main routine

ReadSNES:
	mov	r0, #1
	bl	Write_Clock		// write 1 to clock
	mov	r0, #1
	bl	Write_Latch		// write 1 to LAT
	mov	r0, #12
	bl	delayMircoseconds	// delay 12 us
	mov	r0, #0
	bl	Write_Latch		// write 0 to LAT
	
clockLoop:
	mov	r0, #6
	bl	delayMircoseconds	// 6usec
	mov	r0, #0
	bl	Write_Clock		// write 0 CLK
	mov	r0, #6
	bl	delayMircoseconds	// 6usec
	
@ Data section
.section	.data

GpioBase:
.word		0
