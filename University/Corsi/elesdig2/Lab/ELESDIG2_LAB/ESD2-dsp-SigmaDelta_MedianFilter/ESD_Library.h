
#ifndef _DSK_Esercitazioni_Lab_H_
#define _DSK_Esercitazioni_Lab_H_




//----------------------------------------------------------------------------
//		INCLUDE FILES RICHIESTI PER UTILIZZARE LE FUNZIONI DI LIBRERIA
//----------------------------------------------------------------------------
#include "ledcfg.h"
/*
 *  The 5510 DSK Board Support Library is divided into several modules, each
 *  of which has its own include file.  The file dsk5510.h must be included
 *  in every program that uses the BSL.  This example also includes
 *  dsk5510_led.h and dsk5510_dip.h because it uses the LED and DIP modules.
 */
#include "dsk5510.h"
#include "dsk5510_led.h"
#include "dsk5510_dip.h"



//----------------------------------------------------------------------------
//          SETUP PLL - DEFINIZIONI  DEI VALORI DI DEFAULT			
//----------------------------------------------------------------------------

#define DEFAULTMULT        0x0019  //  25 //
#define DEFAULTDIV         0x0002  //  2 //
#define DEFAULTPLLENABLE   0x0001  //  1 //
#define DEFAULTBYPASSDIV   0x0000  //  1 //
 
#define DEFAULTSETUP  0x000f  //  1 //
#define DEFAULTSTROBE 0x003f  // 63 //
#define DEFAULTHOLD   0x0003  //  3 //

#define XF		0		
#define WAIT	1	//mettere un valore da un minimo di 1 ad un max di 63


//----------------------------------------------------------------------------
//          SETUP EMIF - DEFINIZIONI  DEI VALORI MAX E MIN 			
//----------------------------------------------------------------------------

#define MINPLLMULT    0x0002  //  2 //
#define MAXPLLMULT    0x001f  // 31 //

#define MINPLLDIV     0x0000  //  0 //
#define MAXPLLDIV     0x0003  //  3 //

#define MINPLLENABLE  0x0000  //  0 //
#define MAXPLLENABLE  0x0001  //  1 //

#define MINBYPASSDIV  0x0000  //  0 //
#define MAXBYPASSDIV  0x0003  //  3 //

#define MINSETUP  0x0001      //  1 //
#define MAXSETUP  0x0010      // 15 //

#define MINSTROBE  0x0001     //  1 //
#define MAXSTROBE  0x003f     // 63 //

#define MINHOLD   0x0000      //  0 //
#define MAXHOLD   0x0003      //  3 //

//----------------------------------------------------------------------------
//    DEFINIZIONE DELLE MASCHERE PER IMPOSTAZIONE EMIF
//----------------------------------------------------------------------------

#define METY_8_BIT        0x0000;  // Spazio di memoria a  8 bit asincrono
#define METY_16_BIT       0x1000;  // Spazio di memoria a 16 bit asincrono
#define METY_32_BIT       0x2000;  // Spazio di memoria a 32 bit asincrono


//----------------------------------------------------------------------------
//    DEFINIZIONE DEGLI INDIRIZZI DEI REGISTRI DI CONFIGURAZIONE 
//    DELLA EMIF DELLO SPAZIO I/O
//----------------------------------------------------------------------------

#define REG_CE2_1         0x0809  // PORT ADDRESS //
#define REG_CE2_2         0x080A  // PORT ADDRESS //
#define REG_CE2_3         0x080B  // PORT ADDRESS //
#define CLKMD             0x1c00  // PORT ADDRESS //


//----------------------------------------------------------------------------
//		Daughter card addresses definition
//----------------------------------------------------------------------------
#define	DB_DSPREG	(*(volatile unsigned int *) 0x400002)	// Display register
#define	DB_DSWBUF	(*(volatile unsigned int *) 0x400004)	// Dip switches buffer
#define	DB_OUTREG	(*(volatile unsigned int *) 0x400006)	// Output register
#define	DB_CFGREG	(*(volatile unsigned int *) 0x400008)	// Configuration register
#define	DB_INBUF	(*(volatile unsigned int *) 0x40000A)	// Input buffer


//----------------------------------------------------------------------------
//			Registri e comandi utilizzati per l'accesso al TIMER
//----------------------------------------------------------------------------
#define TIM0	(*(volatile ioport int*) 0x1000)	//Timer 0 Count Register
#define PRD0	(*(volatile ioport int*) 0x1001)	//Timer 0 Period Register
#define TCR0	(*(volatile ioport int*) 0x1002)	//Timer 0 Timer Control Register
#define PRSC0	(*(volatile ioport int*) 0x1003)	//Timer 0 Timer Prescaler Register
#define IFR0 	(*(volatile int*) 0x01)

#define FUNC1	1	// Timer output
					// The signal on pin changes each time the main counter decrements to 0.
					
						//Clock Source: Internal (from DSP clock generator)
#define TLB		1	//Load TIM and PSC until TLB return = 0
#define TSS		1	// Stop timer
#define ARB		1	// Auto-reload bit
#define CP		1	// Signal "TOUT#0" mode: 1:toggle mode

//----------------------------------------------------------------------------
//			PROTOTIPI FUNZIONI DEFINITE IN C
//----------------------------------------------------------------------------
#define NTAP 32

void	myDelay			(int ms);
void	myInitDskBoard	(void);
int		SetMckFreq		(int PllDiv,int PllMult,int PllEnable,int ByPassDiv);
int	 	SetWrAccessTiming (int setup, int strobe, int hold);
int	 	SetRdAccessTiming (int setup, int strobe, int hold);
void	TIMER_SET		(int rep_freq);
void	TimerSync		(void);
int		FiltroFirC		(int *dataBuf, int *hBuff, int index);

//----------------------------------------------------------------------------
//			PROTOTIPI FUNZIONI DEFINITE IN ASSEMBLER
//----------------------------------------------------------------------------
extern void WRITE_XF(int xf_value);
extern int READ_GPIO_4(void);
extern void DATA_OUT(void);





#endif /* _DSK_Esercitazioni_Lab_H_ */ 
