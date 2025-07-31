;*******************************************************************************
;* TMS320C55x C/C++ Codegen                                    PC Version 2.54 *
;* Date/Time created: Thu Mar 22 12:28:20 2007                                 *
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
	.file	"LAB_1.C"
;	c:\Programmi\ti\c5500\cgtools\bin\acp55.exe -@C:\DOCUME~1\cc\IMPOST~1\Temp\TI3464_4 

	.sect	".text"
	.align 4
	.global	_main
	.sym	_main,_main, 32, 2, 0
	.func	8
;*******************************************************************************
;* FUNCTION NAME: _main                                                        *
;*                                                                             *
;*   Function Uses Regs : AR1,AR3,XAR3,SP,CARRY,M40,SATA,SATD,RDM,FRCT,SMUL    *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 4 words                                              *
;*                        (2 return address/alignment)                         *
;*                        (2 local values)                                     *
;*******************************************************************************
_main:
	.line	2
	.sym	_app,0, 14, 1, 16
	.sym	_i,1, 14, 1, 16
        AADD #-3, SP
	.line	3
        MOV #0, *SP(#0) ; |10| 
	.line	4
        MOV #0, *SP(#1) ; |11| 
	.line	7
        CALL #_myInitDskBorad ; |14| 
                                        ; call occurs [#_myInitDskBorad]	; |14| 
	.line	11
        AMOV #4194306, XAR3 ; |18| 
        MOV #60, *AR3 ; |18| 
	.line	13
        AMOV #4194308, XAR3 ; |20| 
        MOV *AR3, AR1 ; |20| 
        MOV AR1, *SP(#0) ; |20| 
	.line	14
        AMOV #4194306, XAR3 ; |21| 
        MOV AR1, *AR3 ; |21| 
	.line	17
L1:    
	.line	19
        MOV *SP(#1), AR1 ; |26| 
        AMOV #4194310, XAR3 ; |26| 
        MOV AR1, *AR3 ; |26| 
	.line	21
        ADD #1, *SP(#1) ; |28| 
	.line	23
        AMOV #4194314, XAR3 ; |30| 
        MOV *AR3, AR1 ; |30| 
        MOV AR1, *SP(#0) ; |30| 
	.line	25
        CALL #_myDelay_10us ; |32| 
                                        ; call occurs [#_myDelay_10us]	; |32| 
	.line	26
        B L1      ; |33| 
                                        ; branch occurs	; |33| 
	.endfunc	34,000000000h,3



	.sect	".text"
	.align 4
	.global	_myInitDskBorad
	.sym	_myInitDskBorad,_myInitDskBorad, 32, 2, 0
	.func	45
;*******************************************************************************
;* FUNCTION NAME: _myInitDskBorad                                              *
;*                                                                             *
;*   Function Uses Regs : T0,AR3,XAR3,SP,M40,SATA,SATD,RDM,FRCT,SMUL           *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 2 words                                              *
;*                        (2 return address/alignment)                         *
;*******************************************************************************
_myInitDskBorad:
	.line	2
        AADD #-1, SP
	.line	3
        CALL #_DSK5510_init ; |47| 
                                        ; call occurs [#_DSK5510_init]	; |47| 
	.line	5
        MOV #256, T0 ; |49| 
        CALL #_WRITE_PLL_REGISTER ; |49| 
                                        ; call occurs [#_WRITE_PLL_REGISTER]	; |49| 
	.line	6
	.line	7
        AMOV #4194312, XAR3 ; |51| 
        MOV #0, *AR3 ; |51| 
	.line	8
        AADD #1, SP
        RET
                                        ; return occurs
	.endfunc	52,000000000h,1



	.sect	".text"
	.align 4
	.global	_myDelay
	.sym	_myDelay,_myDelay, 32, 2, 0
	.func	60
;*******************************************************************************
;* FUNCTION NAME: _myDelay                                                     *
;*                                                                             *
;*   Function Uses Regs : AC0,AC0,AC1,AC1,T0,AR1,SP,CARRY,TC1,M40,SATA,SATD,   *
;*                        RDM,FRCT,SMUL                                        *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 6 words                                              *
;*                        (2 return address/alignment)                         *
;*                        (4 local values)                                     *
;*******************************************************************************
_myDelay:
	.line	2
;* T0    assigned to _ms
	.sym	_ms,12, 4, 17, 16
	.sym	_ms,0, 4, 1, 16
	.sym	_delay,2, 5, 1, 32
        AADD #-5, SP
        MOV T0, *SP(#0) ; |61| 
	.line	5
        MOV T0, AR1
        BCC L5,AR1 <= #0 ; |64| 
                                        ; branch occurs	; |64| 
L2:    
	.line	6
        MOV #0, AC0 ; |65| 
        MOV AC0, dbl(*SP(#2)) ; |65| 
        MOV dbl(*SP(#2)), AC1 ; |65| 
        MOV #1700, AC0 ; |65| 
        CMP AC1 >= AC0, TC1 ; |65| 
        BCC L4,TC1 ; |65| 
                                        ; branch occurs	; |65| 
L3:    
        MOV dbl(*SP(#2)), AC0 ; |65| 
        ADD #1, AC0 ; |65| 
        MOV AC0, dbl(*SP(#2)) ; |65| 
        MOV dbl(*SP(#2)), AC1 ; |65| 
        MOV #1700, AC0 ; |65| 
        CMP AC1 < AC0, TC1 ; |65| 
        BCC L3,TC1 ; |65| 
                                        ; branch occurs	; |65| 
L4:    
	.line	7
        SUB #1, *SP(#0) ; |66| 
        MOV *SP(#0), AR1 ; |66| 
        BCC L2,AR1 > #0 ; |66| 
                                        ; branch occurs	; |66| 
L5:    
	.line	8
        AADD #5, SP
        RET
                                        ; return occurs
	.endfunc	67,000000000h,5



	.sect	".text"
	.align 4
	.global	_myDelay_10us
	.sym	_myDelay_10us,_myDelay_10us, 32, 2, 0
	.func	74
;*******************************************************************************
;* FUNCTION NAME: _myDelay_10us                                                *
;*                                                                             *
;*   Function Uses Regs : AC0,AC0,AC1,AC1,SP,CARRY,TC1,M40,SATA,SATD,RDM,FRCT, *
;*                        SMUL                                                 *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 4 words                                              *
;*                        (2 return address/alignment)                         *
;*                        (2 local values)                                     *
;*******************************************************************************
_myDelay_10us:
	.line	2
	.sym	_delay,0, 5, 1, 32
        AADD #-3, SP
	.line	5
        MOV #0, AC0 ; |78| 
        MOV AC0, dbl(*SP(#0)) ; |78| 
        MOV dbl(*SP(#0)), AC1 ; |78| 
        MOV #15, AC0 ; |78| 
        CMP AC1 >= AC0, TC1 ; |78| 
        BCC L7,TC1 ; |78| 
                                        ; branch occurs	; |78| 
L6:    
        MOV dbl(*SP(#0)), AC0 ; |78| 
        ADD #1, AC0 ; |78| 
        MOV AC0, dbl(*SP(#0)) ; |78| 
        MOV dbl(*SP(#0)), AC1 ; |78| 
        MOV #15, AC0 ; |78| 
        CMP AC1 < AC0, TC1 ; |78| 
        BCC L6,TC1 ; |78| 
                                        ; branch occurs	; |78| 
L7:    
	.line	6
        AADD #3, SP
        RET
                                        ; return occurs
	.endfunc	79,000000000h,3


;*******************************************************************************
;* UNDEFINED EXTERNAL REFERENCES                                               *
;*******************************************************************************
	.global	_DSK5510_init
	.global	_WRITE_PLL_REGISTER
	.global	_WRITE_WAIT_STATE_GENERATOR

;*******************************************************************************
;* TYPE INFORMATION                                                            *
;*******************************************************************************
