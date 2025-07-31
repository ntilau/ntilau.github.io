
#include "lab_1.h"


//-----------------------------------------------------------------------
//			MAIN
//-----------------------------------------------------------------------
void main(void)
{
    unsigned int app=0;
    unsigned int i=0;


    myInitDskBorad ();				// Non toccare!



	DB_WR_DISPLAY_REG = 0x3C;	// Scrive sul display della Doughter-board il numero 0x3C
	
	app = DB_RD_DIP_SWITCHES;	// Legge lo stato dei dip-switches presenti nella doughter-board
	DB_WR_DISPLAY_REG = app;	// Copia il numero appena letto sul display 
	            
	            
    while(1) {

		DB_WR_OUTPUT_REG = i;		// Copia nel registro di uscita (74HC574) il contenuto della variabile "i"

		i++;						// incrementa il contenuto della variabile "i"

		app = DB_RD_INPUT_BUFFER;	// Legge dal buffer di ingresso (74AHC245) e copia quanto letto nella variabile "app"

		myDelay_10us();					// Attende 10 us
       }
}





//-----------------------------------------------------------------------
//		MY INIT DSK BOARD
//
// Inizializza la libreria di funzioni e i registri della CPLD
//-----------------------------------------------------------------------
void	myInitDskBorad (void)
{
	DSK5510_init();			

	WRITE_PLL_REGISTER(PLL_REG);	// Non toccare!
	WRITE_WAIT_STATE_GENERATOR;		// Non toccare!
	DB_WR_CONFIGURATION_REG=0;	// Inizializza il configuration-register con 0. Non toccare!
}


//-----------------------------------------------------------------------
//				MY_DELAY
//
//	Attende ms millisecondi (posto MCK=24MHz)
//-----------------------------------------------------------------------
void	myDelay (int ms)
{
	long int	delay;
	
	for (;ms>0;ms--) { 
        for (delay = 0; delay < 1700; delay++);
    }
}

//-----------------------------------------------------------------------
//				MY_DELAY_10us
//
//	Attende ms millisecondi (posto MCK=24MHz)
//-----------------------------------------------------------------------
void	myDelay_10us (void)
{
	long int	delay;
	
        for (delay = 0; delay < 15; delay++);
}
