;*******************************************************************************
;* TMS320C55x C/C++ Codegen                                    PC Version 2.54 *
;* Date/Time created: Wed Jun 04 15:47:36 2008                                 *
;*******************************************************************************
	.mmregs
	.cpl_on
	.arms_on
	.c54cm_off
	.asg AR6, FP
	.asg XAR6, XFP
	.asg DPH, MDP
	.model call=c55_std
	.model mem=large
	.noremark 5549  ; code avoids SE CPU_28
	.noremark 5558  ; code avoids SE CPU_33
	.noremark 5570  ; code avoids SE CPU_40
	.noremark 5571  ; code avoids SE CPU_41
	.noremark 5573  ; code avoids SE CPU_43
	.noremark 5584  ; code avoids SE CPU_47
	.noremark 5599  ; code avoids SE CPU_55
	.noremark 5503  ; code avoids SE CPU_84 MMR write
	.noremark 5505  ; code avoids SE CPU_84 MMR read
	.noremark 5673  ; code avoids SE CPU_89
	.noremark 5002  ; code respects overwrite rules
;*******************************************************************************
;* GLOBAL FILE PARAMETERS                                                      *
;*                                                                             *
;*   Architecture       : TMS320C55x                                           *
;*   Optimization       : Always Choose Smaller Code Size                      *
;*   Memory             : Large Model (23-Bit Data Pointers)                   *
;*   Calls              : Normal Library ASM calls                             *
;*   Debug Info         : Standard TI Debug Information                        *
;*******************************************************************************
	.file	"LAB_4.C"

	.sect	".cinit"
	.align	1
	.field  	IR_1,16
	.field  	_h+0,24
	.field  	0,8
	.field  	102,16			; _h[0] @ 0
	.field  	159,16			; _h[1] @ 16
	.field  	207,16			; _h[2] @ 32
	.field  	335,16			; _h[3] @ 48
	.field  	435,16			; _h[4] @ 64
	.field  	597,16			; _h[5] @ 80
	.field  	740,16			; _h[6] @ 96
	.field  	925,16			; _h[7] @ 112
	.field  	1093,16			; _h[8] @ 128
	.field  	1282,16			; _h[9] @ 144
	.field  	1448,16			; _h[10] @ 160
	.field  	1613,16			; _h[11] @ 176
	.field  	1746,16			; _h[12] @ 192
	.field  	1859,16			; _h[13] @ 208
	.field  	1933,16			; _h[14] @ 224
	.field  	1973,16			; _h[15] @ 240
	.field  	1973,16			; _h[16] @ 256
	.field  	1933,16			; _h[17] @ 272
	.field  	1859,16			; _h[18] @ 288
	.field  	1746,16			; _h[19] @ 304
	.field  	1613,16			; _h[20] @ 320
	.field  	1448,16			; _h[21] @ 336
	.field  	1282,16			; _h[22] @ 352
	.field  	1093,16			; _h[23] @ 368
	.field  	925,16			; _h[24] @ 384
	.field  	740,16			; _h[25] @ 400
	.field  	597,16			; _h[26] @ 416
	.field  	435,16			; _h[27] @ 432
	.field  	335,16			; _h[28] @ 448
	.field  	207,16			; _h[29] @ 464
	.field  	159,16			; _h[30] @ 480
	.field  	102,16			; _h[31] @ 496
IR_1:	.set	32

	.sect	".text"
	.global	_h
	.bss	_h,32,0,0
	.sym	_h,_h, 52, 2, 512,, 32
	.global	_BitStream
	.bss	_BitStream,1024,0,0
	.sym	_BitStream,_BitStream, 52, 2, 16384,, 1024
	.global	_BitStreamLPF
	.bss	_BitStreamLPF,1024,0,0
	.sym	_BitStreamLPF,_BitStreamLPF, 52, 2, 16384,, 1024
;	c:\Programmi\ti\c5500\cgtools\bin\acp55.exe -@C:\DOCUME~1\cc\IMPOST~1\Temp\TI3544_4 

	.sect	".text"
	.align 4
	.global	_main
	.sym	_main,_main, 32, 2, 0
	.func	44
;*******************************************************************************
;* FUNCTION NAME: _main                                                        *
;*                                                                             *
;*   Function Uses Regs : AC0,AC0,AC1,AC1,T0,AR1,AR2,XAR2,AR3,XAR3,AR4,SP,     *
;*                        CARRY,TC1,M40,SATA,SATD,RDM,FRCT,SMUL                *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 10 words                                             *
;*                        (2 return address/alignment)                         *
;*                        (8 local values)                                     *
;*******************************************************************************
_main:
	.line	2
	.sym	_b,0, 4, 1, 16
	.sym	_Acc,2, 5, 1, 32
	.sym	_j,4, 4, 1, 16
	.sym	_i,5, 4, 1, 16
	.sym	_n,6, 14, 1, 16
	.sym	_m,7, 4, 1, 16
        AADD #-9, SP
	.line	9
        CALL #_myInitDskBoard ; |52| 
                                        ; call occurs [#_myInitDskBoard]	; |52| 
	.line	10
        MOV #10, T0
        CALL #_TIMER_SET ; |53| 
                                        ; call occurs [#_TIMER_SET]	; |53| 
	.line	11
        AMOV #4194312, XAR3 ; |54| 
        MOV #0, *AR3 ; |54| 
	.line	13
L1:    
	.line	15
        MOV #0, AC0 ; |58| 
        MOV AC0, dbl(*SP(#2)) ; |58| 
	.line	17
        MOV #0, *SP(#7) ; |60| 

        MOV *SP(#7), AR2 ; |60| 
||      MOV #2, AR1

        CMP AR2 >= AR1, TC1 ; |60| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L1,TC1 ; |60| 
                                        ; branch occurs	; |60| 
L2:    
	.line	18
        MOV #0, *SP(#5) ; |61| 
        MOV #1024, AR1 ; |61| 
        MOV *SP(#5), AR2 ; |61| 

        CMP AR2 >= AR1, TC1 ; |61| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L7,TC1 ; |61| 
                                        ; branch occurs	; |61| 
L3:    
	.line	20
        CALL #_TimerSync ; |63| 
                                        ; call occurs [#_TimerSync]	; |63| 
	.line	21
        AMOV #4194314, XAR3 ; |64| 
        MOV *AR3, AR1 ; |64| 
        MOV AR1, *SP(#0) ; |64| 
	.line	22
        AMOV #4194310, XAR3 ; |65| 
        MOV *SP(#0), AR1 ; |65| 
        MOV AR1, *AR3 ; |65| 
	.line	24
        MOV *SP(#5), T0 ; |67| 
        MOV *SP(#0), AR1 ; |67| 
        AMOV #_BitStream, XAR3 ; |67| 
        AND #0x0001, AR1, AR1 ; |67| 
        MOV AR1, *AR3(T0) ; |67| 
	.line	25
        MOV *SP(#5), T0 ; |68| 
        MOV *AR3(T0), AR1 ; |68| 
        BCC L4,AR1 != #0 ; |68| 
                                        ; branch occurs	; |68| 
        MOV #-1, *AR3(T0) ; |68| 
L4:    
	.line	36
        MOV #0, AC0 ; |79| 
        MOV AC0, dbl(*SP(#2)) ; |79| 
	.line	37
        MOV #32, AR2 ; |80| 
        MOV #0, *SP(#4) ; |80| 
        MOV *SP(#4), AR1 ; |80| 

        CMP AR1 >= AR2, TC1 ; |80| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        MOV #32, AR4 ; |83| 
        BCC L6,TC1 ; |80| 
                                        ; branch occurs	; |80| 
L5:    
	.line	38
        SUB AR1, *SP(#5), AR1 ; |81| 
        AND #0x03ff, AR1, AR1 ; |81| 
        MOV AR1, *SP(#6) ; |81| 
	.line	39
        MOV *SP(#6), T0 ; |82| 
        AMOV #_h, XAR3 ; |82| 
        ADD *SP(#4), AR3, AR3
        AMOV #_BitStream, XAR2 ; |82| 
        MPYM *AR3, *AR2(T0), AC0 ; |82| 
        MOV mmap(AC0L), AC0 ; |82| 
        ADD dbl(*SP(#2)), AC0, AC0 ; |82| 
        MOV AC0, dbl(*SP(#2)) ; |82| 
	.line	40
        ADD #1, *SP(#4) ; |83| 
        MOV *SP(#4), AR1 ; |83| 

        CMP AR1 < AR4, TC1 ; |83| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L5,TC1 ; |83| 
                                        ; branch occurs	; |83| 
L6:    
	.line	41
        MOV dbl(*SP(#2)), AC0 ; |84| 
        SFTS AC0, #-1, AC1 ; |84| 
        SFTL AC1, #-30, AC1 ; |84| 
        ADD AC0, AC1 ; |84| 
        SFTS AC1, #-2, AC0 ; |84| 
        MOV AC0, dbl(*SP(#2)) ; |84| 
	.line	44
        MOV *SP(#5), T0 ; |87| 
        AMOV #_BitStreamLPF, XAR3 ; |87| 
        MOV *SP(#3), AR1 ; |87| 
        MOV AR1, *AR3(T0) ; |87| 
	.line	45
        ADD #1, *SP(#5) ; |88| 
        MOV #1024, AR1 ; |88| 
        MOV *SP(#5), AR2 ; |88| 

        CMP AR2 < AR1, TC1 ; |88| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L3,TC1 ; |88| 
                                        ; branch occurs	; |88| 
L7:    
	.line	46
        ADD #1, *SP(#7) ; |89| 

        MOV *SP(#7), AR2 ; |89| 
||      MOV #2, AR1

        CMP AR2 < AR1, TC1 ; |89| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L2,TC1 ; |89| 
                                        ; branch occurs	; |89| 
	.line	47
        B L1      ; |90| 
                                        ; branch occurs	; |90| 
	.endfunc	91,000000000h,9


;*******************************************************************************
;* UNDEFINED EXTERNAL REFERENCES                                               *
;*******************************************************************************
	.global	_myInitDskBoard
	.global	_TIMER_SET
	.global	_TimerSync

;*******************************************************************************
;* TYPE INFORMATION                                                            *
;*******************************************************************************
