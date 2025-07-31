;*******************************************************************************
;* TMS320C55x C/C++ Codegen                                    PC Version 2.54 *
;* Date/Time created: Wed May 28 16:02:11 2008                                 *
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
	.file	"ESD_Library.c"
;	c:\Programmi\ti\c5500\cgtools\bin\acp55.exe -@C:\DOCUME~1\cc\IMPOST~1\Temp\TI3504_4 

	.sect	".text"
	.align 4
	.global	_SetMckFreq
	.sym	_SetMckFreq,_SetMckFreq, 36, 2, 0
	.func	19
;*******************************************************************************
;* FUNCTION NAME: _SetMckFreq                                                  *
;*                                                                             *
;*   Function Uses Regs : AC0,AC1,T0,T1,AR0,AR1,AR2,AR3,SP,TC1,M40,SATA,SATD,  *
;*                        RDM,FRCT,SMUL                                        *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 6 words                                              *
;*                        (1 return address/alignment)                         *
;*                        (5 local values)                                     *
;*******************************************************************************
_SetMckFreq:
	.line	2
;* T0    assigned to _PllDiv
	.sym	_PllDiv,12, 4, 17, 16
;* T1    assigned to _PllMult
	.sym	_PllMult,13, 4, 17, 16
;* AR0   assigned to _PllEnable
	.sym	_PllEnable,16, 4, 17, 16
;* AR1   assigned to _ByPassDiv
	.sym	_ByPassDiv,18, 4, 17, 16
	.sym	_PllDiv,0, 4, 1, 16
	.sym	_PllMult,1, 4, 1, 16
	.sym	_PllEnable,2, 4, 1, 16
	.sym	_ByPassDiv,3, 4, 1, 16
	.sym	_PORT,4, 20, 1, 16
        AADD #-5, SP
        MOV AR1, *SP(#3) ; |20| 
        MOV AR0, *SP(#2) ; |20| 
        MOV T1, *SP(#1) ; |20| 
        MOV T0, *SP(#0) ; |20| 
	.line	5
        MOV T0, AR1
        BCC L1,AR1 < #0 ; |23| 
                                        ; branch occurs	; |23| 

        MOV T0, AR2
||      MOV #3, AR1

        CMP AR2 > AR1, TC1 ; |23| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L1,TC1 ; |23| 
                                        ; branch occurs	; |23| 

        MOV *SP(#1), AR2 ; |23| 
||      MOV #2, AR1

        CMP AR2 < AR1, TC1 ; |23| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L1,TC1 ; |23| 
                                        ; branch occurs	; |23| 
        MOV #31, AR1 ; |23| 

        CMP AR2 > AR1, TC1 ; |23| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L1,TC1 ; |23| 
                                        ; branch occurs	; |23| 
        MOV *SP(#2), AR1 ; |23| 
        BCC L1,AR1 < #0 ; |23| 
                                        ; branch occurs	; |23| 
        MOV #1, AR2

        CMP AR1 > AR2, TC1 ; |23| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L1,TC1 ; |23| 
                                        ; branch occurs	; |23| 
        MOV *SP(#3), AR1 ; |23| 
        BCC L1,AR1 < #0 ; |23| 
                                        ; branch occurs	; |23| 

        MOV *SP(#3), AR2 ; |23| 
||      MOV #3, AR1

        CMP AR2 > AR1, TC1 ; |23| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L1,TC1 ; |23| 
                                        ; branch occurs	; |23| 
	.line	10
        MOV #7168, *SP(#4) ; |28| 
        NOP       ; 	avoids Silicon Exception CPU_90
        NOP       ; 	avoids Silicon Exception CPU_90
	.line	11
        MOV *SP(#1), AR1 ; |29| 

        MOV *SP(#3), AR1 ; |29| 
||      AND #0x001f, AR1, AC0 ; |29| 

        SFTS AC0, #7, AC1 ; |29| 
        AND #0x0003, AR1, AC0 ; |29| 

        MOV *SP(#2), AR1 ; |29| 
||      SFTS AC0, #2, AC0 ; |29| 

        OR AC1, AC0 ; |29| 
        AND #0x0001, AR1, AC1 ; |29| 

        MOV *SP(#0), AR1 ; |29| 
||      SFTS AC1, #4, AC1 ; |29| 

        MOV *SP(#4), AR3 ; |29| 
||      OR AC0, AC1 ; |29| 

        AND #0x0003, AR1, AC0 ; |29| 
        SFTS AC0, #5, AC0 ; |29| 
        OR AC1, AC0 ; |29| 
        BSET @#13, AC0 ; |29| 
        MOV AC0, port(*AR3) ; |29| 
	.line	16
        MOV #0, T0
        B L2      ; |34| 
                                        ; branch occurs	; |34| 
L1:    
	.line	20
        MOV #1, T0
L2:    
	.line	22
        AADD #5, SP ; |38| 
        RET       ; |38| 
                                        ; return occurs	; |38| 
	.endfunc	40,000000000h,5



	.sect	".text"
	.align 4
	.global	_SetWrAccessTiming
	.sym	_SetWrAccessTiming,_SetWrAccessTiming, 36, 2, 0
	.func	57
;*******************************************************************************
;* FUNCTION NAME: _SetWrAccessTiming                                           *
;*                                                                             *
;*   Function Uses Regs : AC0,AC1,T0,T1,AR0,AR1,AR2,AR3,SP,TC1,M40,SATA,SATD,  *
;*                        RDM,FRCT,SMUL                                        *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 6 words                                              *
;*                        (1 return address/alignment)                         *
;*                        (5 local values)                                     *
;*******************************************************************************
_SetWrAccessTiming:
	.line	2
;* T0    assigned to _setup
	.sym	_setup,12, 4, 17, 16
;* T1    assigned to _strobe
	.sym	_strobe,13, 4, 17, 16
;* AR0   assigned to _hold
	.sym	_hold,16, 4, 17, 16
	.sym	_setup,0, 4, 1, 16
	.sym	_strobe,1, 4, 1, 16
	.sym	_hold,2, 4, 1, 16
	.sym	_PORT,3, 20, 1, 16
	.sym	_app,4, 4, 1, 16
        AADD #-5, SP
        MOV AR0, *SP(#2) ; |58| 
        MOV T1, *SP(#1) ; |58| 
        MOV T0, *SP(#0) ; |58| 
	.line	6
        MOV T0, AR1
        BCC L3,AR1 <= #0 ; |62| 
                                        ; branch occurs	; |62| 
        MOV #16, AR2 ; |62| 

        CMP AR1 > AR2, TC1 ; |62| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L3,TC1 ; |62| 
                                        ; branch occurs	; |62| 
        MOV *SP(#1), AR1 ; |62| 
        BCC L3,AR1 <= #0 ; |62| 
                                        ; branch occurs	; |62| 
        MOV #63, AR1 ; |62| 
        MOV *SP(#1), AR2 ; |62| 

        CMP AR2 > AR1, TC1 ; |62| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L3,TC1 ; |62| 
                                        ; branch occurs	; |62| 
        MOV *SP(#2), AR1 ; |62| 
        BCC L3,AR1 < #0 ; |62| 
                                        ; branch occurs	; |62| 

        MOV *SP(#2), AR2 ; |62| 
||      MOV #3, AR1

        CMP AR2 > AR1, TC1 ; |62| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L3,TC1 ; |62| 
                                        ; branch occurs	; |62| 
	.line	11
        MOV #2058, *SP(#3) ; |67| 
	.line	13
        MOV *SP(#3), AR3 ; |69| 
        MOV port(*AR3), AR1 ; |69| 
        AND #0xf000, AR1, AR1 ; |69| 
        MOV AR1, *SP(#4) ; |69| 
        NOP       ; 	avoids Silicon Exception CPU_90
        NOP       ; 	avoids Silicon Exception CPU_90
	.line	14
        MOV *SP(#0), AR1 ; |70| 

        MOV *SP(#1), AR1 ; |70| 
||      AND #0x000f, AR1, AC0 ; |70| 

        SFTS AC0, #8, AC1 ; |70| 

        MOV *SP(#3), AR3 ; |70| 
||      AND #0x003f, AR1, AC0 ; |70| 

        OR *SP(#4), AC1, AC1 ; |70| 

        SFTS AC0, #2, AC0 ; |70| 
||      MOV *SP(#2), AR1 ; |70| 

        OR AC1, AC0 ; |70| 
||      AND #0x0003, AR1, AR1 ; |70| 

        OR AC0, AR1 ; |70| 
        MOV AR1, port(*AR3) ; |70| 
	.line	16
        MOV #0, T0
        B L4      ; |72| 
                                        ; branch occurs	; |72| 
L3:    
	.line	19
        MOV #1, T0
L4:    
	.line	21
        AADD #5, SP ; |75| 
        RET       ; |75| 
                                        ; return occurs	; |75| 
	.endfunc	77,000000000h,5



	.sect	".text"
	.align 4
	.global	_SetRdAccessTiming
	.sym	_SetRdAccessTiming,_SetRdAccessTiming, 36, 2, 0
	.func	94
;*******************************************************************************
;* FUNCTION NAME: _SetRdAccessTiming                                           *
;*                                                                             *
;*   Function Uses Regs : AC0,AC1,T0,T1,AR0,AR1,AR2,AR3,SP,TC1,M40,SATA,SATD,  *
;*                        RDM,FRCT,SMUL                                        *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 6 words                                              *
;*                        (1 return address/alignment)                         *
;*                        (5 local values)                                     *
;*******************************************************************************
_SetRdAccessTiming:
	.line	2
;* T0    assigned to _setup
	.sym	_setup,12, 4, 17, 16
;* T1    assigned to _strobe
	.sym	_strobe,13, 4, 17, 16
;* AR0   assigned to _hold
	.sym	_hold,16, 4, 17, 16
	.sym	_setup,0, 4, 1, 16
	.sym	_strobe,1, 4, 1, 16
	.sym	_hold,2, 4, 1, 16
	.sym	_PORT,3, 20, 1, 16
	.sym	_app,4, 4, 1, 16
        AADD #-5, SP
        MOV AR0, *SP(#2) ; |95| 
        MOV T1, *SP(#1) ; |95| 
        MOV T0, *SP(#0) ; |95| 
	.line	6
        MOV T0, AR1
        BCC L5,AR1 <= #0 ; |99| 
                                        ; branch occurs	; |99| 
        MOV #16, AR2 ; |99| 

        CMP AR1 > AR2, TC1 ; |99| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L5,TC1 ; |99| 
                                        ; branch occurs	; |99| 
        MOV *SP(#1), AR1 ; |99| 
        BCC L5,AR1 <= #0 ; |99| 
                                        ; branch occurs	; |99| 
        MOV #63, AR1 ; |99| 
        MOV *SP(#1), AR2 ; |99| 

        CMP AR2 > AR1, TC1 ; |99| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L5,TC1 ; |99| 
                                        ; branch occurs	; |99| 
        MOV *SP(#2), AR1 ; |99| 
        BCC L5,AR1 < #0 ; |99| 
                                        ; branch occurs	; |99| 

        MOV *SP(#2), AR2 ; |99| 
||      MOV #3, AR1

        CMP AR2 > AR1, TC1 ; |99| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L5,TC1 ; |99| 
                                        ; branch occurs	; |99| 
	.line	11
        MOV #2057, *SP(#3) ; |104| 
	.line	13
        MOV *SP(#3), AR3 ; |106| 
        MOV port(*AR3), AR1 ; |106| 
        AND #0xf000, AR1, AR1 ; |106| 
        MOV AR1, *SP(#4) ; |106| 
        NOP       ; 	avoids Silicon Exception CPU_90
        NOP       ; 	avoids Silicon Exception CPU_90
	.line	14
        MOV *SP(#0), AR1 ; |107| 

        MOV *SP(#1), AR1 ; |107| 
||      AND #0x000f, AR1, AC0 ; |107| 

        SFTS AC0, #8, AC1 ; |107| 

        MOV *SP(#3), AR3 ; |107| 
||      AND #0x003f, AR1, AC0 ; |107| 

        OR *SP(#4), AC1, AC1 ; |107| 

        SFTS AC0, #2, AC0 ; |107| 
||      MOV *SP(#2), AR1 ; |107| 

        OR AC1, AC0 ; |107| 
||      AND #0x0003, AR1, AR1 ; |107| 

        OR AC0, AR1 ; |107| 
        MOV AR1, port(*AR3) ; |107| 
	.line	16
        MOV #0, T0
        B L6      ; |109| 
                                        ; branch occurs	; |109| 
L5:    
	.line	19
        MOV #1, T0
L6:    
	.line	20
        AADD #5, SP ; |112| 
        RET       ; |112| 
                                        ; return occurs	; |112| 
	.endfunc	113,000000000h,5



	.sect	".text"
	.align 4
	.global	_myInitDskBoard
	.sym	_myInitDskBoard,_myInitDskBoard, 32, 2, 0
	.func	127
;*******************************************************************************
;* FUNCTION NAME: _myInitDskBoard                                              *
;*                                                                             *
;*   Function Uses Regs : T0,T1,AR0,AR1,SP,M40,SATA,SATD,RDM,FRCT,SMUL         *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 2 words                                              *
;*                        (2 return address/alignment)                         *
;*******************************************************************************
_myInitDskBoard:
	.line	2
        AADD #-1, SP
	.line	3
        CALL #_DSK5510_init ; |129| 
                                        ; call occurs [#_DSK5510_init]	; |129| 
	.line	4
        CALL #_DSK5510_LED_init ; |130| 
                                        ; call occurs [#_DSK5510_LED_init]	; |130| 
	.line	5
        CALL #_DSK5510_DIP_init ; |131| 
                                        ; call occurs [#_DSK5510_DIP_init]	; |131| 
	.line	6
        MOV #0, AR1
        MOV #1, AR0
        MOV #25, T1 ; |132| 
        MOV #2, T0
        CALL #_SetMckFreq ; |132| 
                                        ; call occurs [#_SetMckFreq]	; |132| 
	.line	7
        MOV #3, AR0
        MOV #63, T1 ; |133| 
        MOV #15, T0
        CALL #_SetWrAccessTiming ; |133| 
                                        ; call occurs [#_SetWrAccessTiming]	; |133| 
	.line	8
        MOV #15, T0
        CALL #_SetRdAccessTiming ; |134| 
                                        ; call occurs [#_SetRdAccessTiming]	; |134| 
	.line	9
        AADD #1, SP
        RET
                                        ; return occurs
	.endfunc	135,000000000h,1



	.sect	".text"
	.align 4
	.global	_myDelay
	.sym	_myDelay,_myDelay, 32, 2, 0
	.func	143
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
        MOV T0, *SP(#0) ; |144| 
	.line	5
        MOV T0, AR1
        BCC L10,AR1 <= #0 ; |147| 
                                        ; branch occurs	; |147| 
L7:    
	.line	6
        MOV #0, AC0 ; |148| 
        MOV AC0, dbl(*SP(#2)) ; |148| 
        MOV dbl(*SP(#2)), AC1 ; |148| 
        MOV #1700, AC0 ; |148| 
        CMP AC1 >= AC0, TC1 ; |148| 
        BCC L9,TC1 ; |148| 
                                        ; branch occurs	; |148| 
L8:    
        MOV dbl(*SP(#2)), AC0 ; |148| 
        ADD #1, AC0 ; |148| 
        MOV AC0, dbl(*SP(#2)) ; |148| 
        MOV dbl(*SP(#2)), AC1 ; |148| 
        MOV #1700, AC0 ; |148| 
        CMP AC1 < AC0, TC1 ; |148| 
        BCC L8,TC1 ; |148| 
                                        ; branch occurs	; |148| 
L9:    
	.line	7
        SUB #1, *SP(#0) ; |149| 
        MOV *SP(#0), AR1 ; |149| 
        BCC L7,AR1 > #0 ; |149| 
                                        ; branch occurs	; |149| 
L10:    
	.line	8
        AADD #5, SP
        RET
                                        ; return occurs
	.endfunc	150,000000000h,5



	.sect	".text"
	.align 4
	.global	_TIMER_SET
	.sym	_TIMER_SET,_TIMER_SET, 32, 2, 0
	.func	167
;*******************************************************************************
;* FUNCTION NAME: _TIMER_SET                                                   *
;*                                                                             *
;*   Function Uses Regs : T0,T1,AR1,AR3,SP,CARRY,M40,SATA,SATD,RDM,FRCT,SMUL   *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 2 words                                              *
;*                        (1 return address/alignment)                         *
;*                        (1 local values)                                     *
;*******************************************************************************
_TIMER_SET:
	.line	2
;* T0    assigned to _rep_freq
	.sym	_rep_freq,12, 4, 17, 16
	.sym	_rep_freq,0, 4, 1, 16
        AADD #-1, SP
        MOV T0, *SP(#0) ; |168| 
	.line	4
        MOV #4099, AR3 ; |170| 
        MOV #9, port(*AR3) ; |170| 
	.line	6
        MOV #20000, T0 ; |172| 
        MOV *SP(#0), T1 ; |172| 
        CALL #I$$DIV ; |172| 
                                        ; call occurs [#I$$DIV]	; |172| 
        MOV #4097, AR3 ; |172| 
        SUB #1, T0, AR1 ; |172| 
        MOV AR1, port(*AR3) ; |172| 
	.line	8
        MOV #4098, AR3 ; |174| 
        MOV #2088, port(*AR3) ; |174| 
	.line	9
        AADD #1, SP
        RET
                                        ; return occurs
	.endfunc	175,000000000h,1



	.sect	".text"
	.align 4
	.global	_TimerSync
	.sym	_TimerSync,_TimerSync, 32, 2, 0
	.func	188
;*******************************************************************************
;* FUNCTION NAME: _TimerSync                                                   *
;*                                                                             *
;*   Function Uses Regs : AC0,AC0,AR1,AR3,XAR3,SP,TC1,M40,SATA,SATD,RDM,FRCT,  *
;*                        SMUL                                                 *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 1 word                                               *
;*                        (1 return address/alignment)                         *
;*******************************************************************************
_TimerSync:
	.line	2
;* AR1   assigned to _temp
	.sym	_temp,18, 4, 4, 16
	.line	5
        MOV #1, AC0 ; |192| 
        MOV AC0, XAR3
        MOV *AR3, AR1 ; |192| 
	.line	6
        MOV AR1, *AR3 ; |193| 
	.line	8
        BTST #4, *AR3, TC1 ; |195| 
        BCC L12,TC1 ; |195| 
                                        ; branch occurs	; |195| 
L11:    
        BTST #4, *AR3, TC1 ; |195| 
        BCC L11,!TC1 ; |195| 
                                        ; branch occurs	; |195| 
L12:    
	.line	10
        MOV *AR3, AR1 ; |197| 
	.line	11
        MOV AR1, *AR3 ; |198| 
	.line	12
        RET
                                        ; return occurs
	.endfunc	199,000000000h,0



	.sect	".text"
	.align 4
	.global	_FiltroFirC
	.sym	_FiltroFirC,_FiltroFirC, 36, 2, 0
	.func	216
;*******************************************************************************
;* FUNCTION NAME: _FiltroFirC                                                  *
;*                                                                             *
;*   Function Uses Regs : AC0,AC0,T0,AR0,XAR0,AR1,XAR1,AR2,XAR2,AR3,XAR3,SP,   *
;*                        CARRY,TC1,M40,SATA,SATD,RDM,FRCT,SMUL                *
;*   Stack Frame        : Compact (No Frame Pointer, w/ debug)                 *
;*   Total Frame Size   : 44 words                                             *
;*                        (2 return address/alignment)                         *
;*                        (42 local values)                                    *
;*******************************************************************************
_FiltroFirC:
	.line	2
;* AR0   assigned to _dataBuf
	.sym	_dataBuf,17, 20, 17, 23
;* AR1   assigned to _hBuff
	.sym	_hBuff,19, 20, 17, 23
;* T0    assigned to _index
	.sym	_index,12, 4, 17, 16
	.sym	_dataBuf,0, 20, 1, 23
	.sym	_hBuff,2, 20, 1, 23
	.sym	_index,4, 4, 1, 16
	.sym	_xLin,5, 52, 1, 512,, 32
	.sym	_j,37, 4, 1, 16
	.sym	_k,38, 4, 1, 16
	.sym	_pippo,39, 4, 1, 16
	.sym	_accVar,40, 5, 1, 32
        AADD #-43, SP
        MOV T0, *SP(#4) ; |217| 
        MOV XAR1, dbl(*SP(#2))
        MOV XAR0, dbl(*SP(#0))
	.line	10
        MOV *SP(#4), AR1 ; |225| 
        MOV AR1, *SP(#37) ; |225| 
        MOV #0, *SP(#38) ; |225| 
        MOV *SP(#37), AR1 ; |225| 
        BCC L14,AR1 < #0 ; |225| 
                                        ; branch occurs	; |225| 
L13:    
        MOV XSP, XAR3
        MOV dbl(*SP(#0)), XAR2
        MOV AR1, T0
        AMAR *+AR3(#5)
        ADD *SP(#38), AR3, AR3
        MOV *AR2(T0), *AR3 ; |225| 
        SUB #1, *SP(#37) ; |225| 
        ADD #1, *SP(#38) ; |225| 
        MOV *SP(#37), AR1 ; |225| 
        BCC L13,AR1 >= #0 ; |225| 
                                        ; branch occurs	; |225| 
L14:    
	.line	11
        MOV #31, *SP(#37) ; |226| 
        MOV *SP(#4), AR1 ; |226| 
        MOV *SP(#37), AR2 ; |226| 

        CMP AR2 <= AR1, TC1 ; |226| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L16,TC1 ; |226| 
                                        ; branch occurs	; |226| 
L15:    
        MOV XSP, XAR3
        MOV dbl(*SP(#0)), XAR2
        MOV *SP(#37), T0 ; |226| 
        AMAR *+AR3(#5)
        ADD *SP(#38), AR3, AR3
        MOV *AR2(T0), *AR3 ; |226| 
        SUB #1, *SP(#37) ; |226| 
        MOV *SP(#4), AR1 ; |226| 
        ADD #1, *SP(#38) ; |226| 
        MOV *SP(#37), AR2 ; |226| 

        CMP AR2 > AR1, TC1 ; |226| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L15,TC1 ; |226| 
                                        ; branch occurs	; |226| 
L16:    
	.line	13
        MOV #0, AC0 ; |228| 
        MOV AC0, dbl(*SP(#40)) ; |228| 
	.line	15
        MOV #32, AR2 ; |230| 
        MOV #0, *SP(#37) ; |230| 
        MOV *SP(#37), AR1 ; |230| 

        CMP AR1 >= AR2, TC1 ; |230| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        MOV #32, AR1 ; |231| 
        BCC L18,TC1 ; |230| 
                                        ; branch occurs	; |230| 
L17:    
	.line	16
        MOV XSP, XAR2
        MOV dbl(*SP(#2)), XAR3
        MOV *SP(#37), T0 ; |231| 
        ADD *SP(#37), AR3, AR3
        AMAR *+AR2(#5)
        MPYM *AR3, *AR2(T0), AC0 ; |231| 
        ADD dbl(*SP(#40)), AC0, AC0 ; |231| 
        MOV AC0, dbl(*SP(#40)) ; |231| 
        ADD #1, *SP(#37) ; |231| 
        MOV *SP(#37), AR2 ; |231| 

        CMP AR2 < AR1, TC1 ; |231| 
||      NOP       ; 	avoids Silicon Exception CPU_24

        BCC L17,TC1 ; |231| 
                                        ; branch occurs	; |231| 
L18:    
	.line	18
        MOV dbl(*SP(#40)), AC0 ; |233| 
        SFTS AC0, #-4, AC0 ; |233| 
        MOV AC0, *SP(#39) ; |233| 
	.line	20
        MOV AC0, T0
	.line	21
        AADD #43, SP ; |235| 
        RET       ; |235| 
                                        ; return occurs	; |235| 
	.endfunc	236,000000000h,43


;*******************************************************************************
;* UNDEFINED EXTERNAL REFERENCES                                               *
;*******************************************************************************
	.global	_DSK5510_init
	.global	_DSK5510_LED_init
	.global	_DSK5510_DIP_init
	.global	I$$DIV

;*******************************************************************************
;* TYPE INFORMATION                                                            *
;*******************************************************************************
