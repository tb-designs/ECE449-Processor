	ORG	0x0000
		IN r1
		IN r2
		MUL r1, r1, r2
		ADD r2, r1, r2
		TEST r1
		BRR.V 7
		NOP
		NOP
		NOP
		NOP
		NOP
		MOV r3, r1
		OUT r1
		TEST r2
		BR.V r0, 0
	END
