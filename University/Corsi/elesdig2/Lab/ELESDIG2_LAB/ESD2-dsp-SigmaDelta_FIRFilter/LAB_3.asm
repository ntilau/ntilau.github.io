;*******************************************************************************
;* TMS320C55x C/C++ Codegen                                    PC Version 2.54 *
;* Date/Time created: Wed May 21 14:15:21 2008                                 *
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
	.file	"LAB_3.C"
;	c:\Programmi\ti\c5500\cgtools\bin\acp55.exe -@C:\DOCUME~1\cc\IMPOST~1\Temp\TI2840_4 

	.sect	".text"
	.align 4
	.global	_main
	.sym	_main,_main, 32, 2, 0
	.func	36
;*******************************************************************************
;* FUNCTION NAME: _main                                                        *
;*                                                                             *
;*   Function Uses Regs : T0,AR1,AR3,XAR3,SP,M40,SATA,SATD,RDM,FRCT,SMUL       *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 2 words                                              *
;*                        (1 return address/alignment)                         *
;*                        (1 local values)                                     *
;*******************************************************************************
_main:
	.line	2
	.sym	_b,0, 4, 1, 16
        AADD #-1, SP
	.line	6
        CALL #_myInitDskBoard ; |41| 
                                        ; call occurs [#_myInitDskBoard]	; |41| 
	.line	7
        MOV #10, T0
        CALL #_TIMER_SET ; |42| 
                                        ; call occurs [#_TIMER_SET]	; |42| 
	.line	9
L1:    
	.line	11
        CALL #_TimerSync ; |46| 
                                        ; call occurs [#_TimerSync]	; |46| 
	.line	12
        AMOV #4194314, XAR3 ; |47| 
        MOV *AR3, AR1 ; |47| 
        MOV AR1, *SP(#0) ; |47| 
	.line	13
        MOV *SP(#0), AR1 ; |48| 
        AMOV #4194310, XAR3 ; |48| 
        MOV AR1, *AR3 ; |48| 
	.line	15
        B L1      ; |50| 
                                        ; branch occurs	; |50| 
	.endfunc	51,000000000h,1


;*******************************************************************************
;* UNDEFINED EXTERNAL REFERENCES                                               *
;*******************************************************************************
	.global	_myInitDskBoard
	.global	_TIMER_SET
	.global	_TimerSync

;*******************************************************************************
;* TYPE INFORMATION                                                            *
;*******************************************************************************
