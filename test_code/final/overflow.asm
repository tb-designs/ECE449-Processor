	ORG	0x0000
		IN r1
		IN r2
		MUL r3, r1, r2
		ADD r4, r1, r2
		TEST r3
		NOP
		NOP
		NOP
		NOP
		TEST r4
		NOP
		NOP
		NOP
		NOP
	END
