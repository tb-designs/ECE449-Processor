	ORG  0x0000

	IN R0
	IN R1
	IN R2
	IN R3
	ADD R1, R1, R2
	SUB R2, R1, R0
	SUB R1, R3, R2

	END
