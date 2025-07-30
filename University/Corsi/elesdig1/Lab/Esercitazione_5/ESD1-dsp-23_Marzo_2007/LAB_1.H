
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
//			PROTOTIPI FUNZIONI DEFINITE IN C
//----------------------------------------------------------------------------
void	myDelay (int ms);
void	myDelay_10us (void);
void	myInitDskBorad (void);


//----------------------------------------------------------------------------
//			PROTOTIPI FUNZIONI DEFINITE IN ASSEMBLER
//----------------------------------------------------------------------------
extern void WRITE_PLL_REGISTER(int pll_value);
extern void WRITE_WAIT_STATE_GENERATOR(int wait_value);

//----------------------------------------------------------------------------
//		DEFINIZIONE DI SIMBOLI UTILIZZATI NEL PROGRAMMA
//----------------------------------------------------------------------------
#define PLL_MULT		0x0100	
#define PLL_DIV			0x0000	
#define PLL_EN			0x0000		// PLL disabilitato
#define PLL_BYPASS_DIV	0x0000
#define PLL_REG			PLL_MULT | PLL_DIV | PLL_EN | PLL_BYPASS_DIV

#define XF		0		
#define WAIT	1	//mettere un valore da un minimo di 1 ad un max di 63



//----------------------------------------------------------------------------
//		DEFINIZIONE DEGLI INDIRIZZI DEI REGISTRI SULLA DOUGHTER-BOARD
//----------------------------------------------------------------------------

#define DB_WR_DISPLAY_REG    	(*(volatile unsigned int *) 0x400002)
#define DB_RD_DIP_SWITCHES      (*(volatile unsigned int *) 0x400004)
#define DB_WR_OUTPUT_REG        (*(volatile unsigned int *) 0x400006)
#define DB_WR_CONFIGURATION_REG (*(volatile unsigned int *) 0x400008)
#define DB_RD_INPUT_BUFFER      (*(volatile unsigned int *) 0x40000A)


