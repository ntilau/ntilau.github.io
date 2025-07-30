;*******************************************************************************
;* TMS320C55x C/C++ Codegen                                    PC Version 2.54 *
;* Date/Time created: Wed May 28 16:07:56 2008                                 *
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
	.global	_BitStream
	.bss	_BitStream,1024,0,0
	.sym	_BitStream,_BitStream, 52, 2, 16384,, 1024
	.global	_BitStreamLPF
	.bss	_BitStreamLPF,1024,0,0
	.sym	_BitStreamLPF,_BitStreamLPF, 52, 2, 16384,, 1024
;	c:\Programmi\ti\c5500\cgtools\bin\acp55.exe -@C:\DOCUME~1\cc\IMPOST~1\Temp\TI932_4 

	.sect	".text"
	.align 4
	.global	_main
	.sym	_main,_main, 32, 2, 0
	.func	40
;*******************************************************************************
;* FUNCTION NAME: _main                                                        *
;*                                                                             *
;*   Function Uses Regs : T0,AR1,AR2,AR3,XAR3,SP,CARRY,TC1,M40,SATA,SATD,RDM,  *
;*                        FRCT,SMUL                                            *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 8 words                                              *
;*                        (2 return address/alignment)                         *
;*                        (6 local values)                                     *
;*******************************************************************************
_main:
	.line	2
	.sym	_b,0, 4, 1, 16
	.sym	_Acc,1, 4, 1, 16
	.sym	_j,2, 4, 1, 16
	.sym	_i,3, 4, 1, 16
	.sym	_n,4, 14, 1, 16
	.sym	_m,5, 4, 1, 16
        AADD #-7, SP
	.line	9
        CALL #_myInitDskBoard ; |48| 
                                        ; call occurs [#_myInitDskBoard]	; |48| 
	.line	10
        MOV #10, T0
        CALL #_TIMER_SET ; |49| 
                                        ; call occurs [#_TIMER_SET]	; |49| 
	.line	11
        AMOV #4194312, XAR3 ; |50| 
        MOV #0, *AR3 ; |50| 
	.line	13
L1:    
	.line	15
        MOV #0, *SP(#1) ; |54| 
	.line	17
        MOV #0, *SP(#5) ; |56| 
        MOV *SP(#5), AR1 ; |56| 
        BCC L1,AR1 > #0 ; |56| 
                                        ; branch occurs	; |56| 
L2:    
	.line	18
        MOV #0, *SP(#3) ; |57| 
        MOV #1024, AR1 ; |57| 
        MOV *SP(#3), AR2 ; |57| 

        CMP AR2 >= AR1, TC1 ; |57| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L6,TC1 ; |57| 
                                        ; branch occurs	; |57| 
L3:    
	.line	20
        CALL #_TimerSync ; |59| 
                                        ; call occurs [#_TimerSync]	; |59| 
	.line	21
        AMOV #4194314, XAR3 ; |60| 
        MOV *AR3, AR1 ; |60| 
        MOV AR1, *SP(#0) ; |60| 
	.line	22
        AMOV #4194310, XAR3 ; |61| 
        MOV *SP(#0), AR1 ; |61| 
        MOV AR1, *AR3 ; |61| 
	.line	24
        MOV *SP(#3), T0 ; |63| 
        MOV *SP(#0), AR1 ; |63| 
        AMOV #_BitStream, XAR3 ; |63| 
        AND #0x0001, AR1, AR1 ; |63| 
        MOV AR1, *AR3(T0) ; |63| 
	.line	28
        MOV #0, *SP(#1) ; |67| 
	.line	29
        MOV #0, *SP(#2) ; |68| 

        MOV *SP(#2), AR1 ; |68| 
||      MOV #4, AR2

        CMP AR1 >= AR2, TC1 ; |68| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L5,TC1 ; |68| 
                                        ; branch occurs	; |68| 
L4:    
	.line	30
        SUB AR1, *SP(#3), AR1 ; |69| 
        AND #0x03ff, AR1, AR1 ; |69| 
        MOV AR1, *SP(#4) ; |69| 
	.line	31
        MOV *SP(#4), T0 ; |70| 
        MOV *AR3(T0), AR1 ; |70| 
        ADD *SP(#1), AR1, AR1 ; |70| 
        MOV AR1, *SP(#1) ; |70| 
	.line	32
        ADD #1, *SP(#2) ; |71| 
        MOV *SP(#2), AR1 ; |71| 

        CMP AR1 < AR2, TC1 ; |71| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L4,TC1 ; |71| 
                                        ; branch occurs	; |71| 
L5:    
	.line	33
        MOV *SP(#3), T0 ; |72| 
        MOV *SP(#1), AR1 ; |72| 
        AMOV #_BitStreamLPF, XAR3 ; |72| 
        MOV AR1, *AR3(T0) ; |72| 
	.line	34
        MOV #1024, AR2 ; |73| 
        ADD #1, *SP(#3) ; |73| 
        MOV *SP(#3), AR1 ; |73| 

        CMP AR1 < AR2, TC1 ; |73| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L3,TC1 ; |73| 
                                        ; branch occurs	; |73| 
L6:    
	.line	35
        ADD #1, *SP(#5) ; |74| 
        MOV *SP(#5), AR1 ; |74| 
        BCC L2,AR1 <= #0 ; |74| 
                                        ; branch occurs	; |74| 
	.line	36
        B L1      ; |75| 
                                        ; branch occurs	; |75| 
	.endfunc	76,000000000h,7


;*******************************************************************************
;* UNDEFINED EXTERNAL REFERENCES                                               *
;*******************************************************************************
	.global	_myInitDskBoard
	.global	_TIMER_SET
	.global	_TimerSync

;*******************************************************************************
;* TYPE INFORMATION                                                            *
;*******************************************************************************
