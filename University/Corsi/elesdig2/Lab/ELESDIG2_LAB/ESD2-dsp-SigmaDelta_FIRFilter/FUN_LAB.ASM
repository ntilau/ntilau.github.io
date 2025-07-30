;-----------------------------------------------------------------------
;		Funzioni assembler di supporto al programma C
;-----------------------------------------------------------------------

	.text
	.def _WRITE_XF, _READ_GPIO_4,_DATA_OUT


;-----------------------------------------------------------------------
;			WRITE_XF
;
;	Assegna al segnale XF il valore passato come argomento della
;	funzione che viene dal compilatore assegnato al registro T0
;-----------------------------------------------------------------------
_WRITE_XF	
	BCC WRITE_CLR, T0 == #0
	BSET XF
	RET

WRITE_CLR:
	BCLR XF
	RET


;-----------------------------------------------------------------------
;			READ_GPIO_4
;
;	Legge, attraverso lo spazio di I/O, il registro IODATA,
;	copia il valore nel registro T0
;	effettua una mascheraura per azzerare tutti i bit escluso il gpio_4
;	resituisce alla funzione chiamante il parametro attraverso il 
;	registro T0. Detto registro costituisce parametro restituito dalla
;	funzione chiamata in 'C'.
;-----------------------------------------------------------------------
_READ_GPIO_4
	MOV port(#3401h),T0
	AND #0010h,T0
	RET


;-----------------------------------------------------------------------
;			WRITE PLL REGISTER
;
;	Copia il parametro passato nel registro CLKMD
;-----------------------------------------------------------------------
;_WRITE_PLL_REGISTER
;	OR #2000h,T0
;	MOV T0,port(#1C00h)
;	RET
	


;-----------------------------------------------------------------------
;		WRITE WAIT STATE GENERATOR
;
;	Parametro: WAIT
;	...................
;-----------------------------------------------------------------------
;_WRITE_WAIT_STATE_GENERATOR
;
;	SFTL T0, #1
;	SFTL T0, #1
;	MOV T0,AR0
;	OR #3103h,T0
;	MOV T0,port(#0804h)
;	OR #5103h,AR0
;	MOV AR0,port(#0803h)
;	RET

;-----------------------------------------------------------------------
;		DATA_OUT
;-----------------------------------------------------------------------
_DATA_OUT

	MOV #00FFh,0x600000
	RET
