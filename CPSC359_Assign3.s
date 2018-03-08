writeClock:     //write 0 or 1 to the clock as specified by r1
	mov  r0, #11      //r0 = pin 11 = clock line
	ldr  r2, =0x3F200000     //r2 = base GPIO register
	mov  r3, #1
	lsl  r3, r0     //align pin11 bit

	teq  r1, #0     //check the value to write

	streq  r3, [r2, #40]      //r3 = GPCLR0, clear the line
	strne  r3, [r2, #28]      //r3 = GPSET0, set the line

	mov  pc, lr      //branch back to main routine

readData:     //read value stored in GPLEV0
	mov  r0, #10     //r0 = pin 10 = data line
	ldr  r2, =0x3F200000     //r2 = base register
	ldr  r1, [r2, #52]     //r1 = GPLEV0
	mov  r3, #1
	lsl  r3, r0     //align pin10 bit

	and  r1, r3			//mask everything else
	teq  r1, #0			//test GPLEV0 value to read

	moveq  r4, #0			//r4 = return 0
	movne  r4, #1			//r4 = return 1

	mov  pc, lr			//branch back to main routine
