;-----------------------------------------------------------------------
;		Funzioni assembler di supporto al programma C
;-----------------------------------------------------------------------

	.text
	.def _WRITE_PLL_REGISTER, _WRITE_WAIT_STATE_GENERATOR


;-----------------------------------------------------------------------
;			WRITE PLL REGISTER
;
;	Copia il parametro passato nel registro CLKMD
;-----------------------------------------------------------------------
_WRITE_PLL_REGISTER
	OR #2000h,T0
	MOV T0,port(#1C00h)
	RET
	

;-----------------------------------------------------------------------
;		WRITE WAIT STATE GENERATOR
;
;	Parametro: WAIT
;	...................
;-----------------------------------------------------------------------
_WRITE_WAIT_STATE_GENERATOR

	SFTL T0, #1
	SFTL T0, #1
	MOV T0,AR0
	OR #3103h,T0
	MOV T0,port(#0804h)
	OR #5103h,AR0
	MOV AR0,port(#0803h)
	RET