#include "ESD_Library.h"

//-----------------------------------------------------------------------
//		SET MASTER CLOCK FREQUENCY
//-----------------------------------------------------------------------
//	Imposta i principali campi del registro CLKMD che permettono di 
//	specificare la modalità operativa del PLL interno al DSP
//
//	Input parameters:
//		PllDiv    = 0..3
//		PllMult   = 0..31
//		PllEnable = 0..1
//		BypassDiv = 0..3
//
//	return value:
//		0: No error, 1: Error
//-----------------------------------------------------------------------

int	SetMckFreq (int PllDiv,int PllMult, int PllEnable, int ByPassDiv)
{
     ioport int *PORT;

      if(	((PllDiv>=MINPLLDIV)&&(PllDiv<=MAXPLLDIV))&&
      		((PllMult>=MINPLLMULT)&&(PllMult<=MAXPLLMULT))&&
      		((PllEnable>=MINPLLENABLE)&&(PllEnable<=MAXPLLENABLE))&&
      		((ByPassDiv>=MINBYPASSDIV)&&(ByPassDiv<=MAXBYPASSDIV)) )
               {
	           	PORT = (int*) CLKMD;
		        (*PORT) =	(PllMult&0x1f)<<7 |
		        			(ByPassDiv&3)<<2 |
		        			(PllEnable&1)<<4 |
		        			(PllDiv&3)<<5 |
		        			0x2000; 
		        return(0);
               } 
       else 
               {
		        return(1);
               }
}


//-----------------------------------------------------------------------
//		SET WR ACCESS TIMING
//-----------------------------------------------------------------------
//	Imposta il registro CE2_1 che specifica le temporizzazioni relative 
//	allo spazio CE2 in modalità scrittura durante un accesso asincrono.

//	Input parameters:
//   	0 <=  setup <= 15
//   	0 <= strobe <= 63 
//   	0 <=   hold <=  3

//	return value:
//		0: No error, 1: Error
//-----------------------------------------------------------------------
int	SetWrAccessTiming (int setup, int strobe, int hold)
    {
     ioport int *PORT;
     int app;
     
     if(((setup>=MINSETUP)&&(setup<=MAXSETUP))&&
     	((strobe>=MINSTROBE)&&(strobe<=MAXSTROBE))&&
     	((hold>=MINHOLD)&&(hold<=MAXHOLD)) )
            {
             
             PORT = (int*) REG_CE2_2;
             
             app  = (*PORT) & 0xf000;
             (*PORT) = app | ((setup&0x0f)<<8) | ((strobe&0x3f)<<2) | (hold&0x3); 
             
             return(0);
            }
     else
             return(1);       
     
    }


//-----------------------------------------------------------------------
//		SET RD ACCESS TIMING
//-----------------------------------------------------------------------
//	Imposta il registro CE2_2 che specifica le temporizzazioni relative 
//	allo spazio CE2 in modalità lettura durante un accesso asincrono.

//	Input parameters:
//   	0 <=  setup <= 15
//   	0 <= strobe <= 63 
//   	0 <=   hold <=  3

//	return value:
//		0: No error, 1: Error
//-----------------------------------------------------------------------
int	SetRdAccessTiming (int setup, int strobe, int hold)
    {
     ioport int *PORT;
     int app;
     
     if(((setup>=MINSETUP)&&(setup<=MAXSETUP))&&
     	((strobe>=MINSTROBE)&&(strobe<=MAXSTROBE))&&
     	((hold>=MINHOLD)&&(hold<=MAXHOLD)))
            {

             PORT = (int*) REG_CE2_1;
             
             app  = (*PORT) & 0xf000;
             (*PORT) = app | ((setup&0x0f)<<8) | ((strobe&0x3f)<<2) | (hold&0x3);

             return(0);
            }
     else
             return(1);       
    }



//-----------------------------------------------------------------------
//		MY INIT DSK BOARD
//
//	Inizializza i seguenti moduli e/o dispositivi:
//		la libreria di funzioni associata al DSK,
//		i registri della CPLD presente nel DSK,
//		il PLL interno al DSP,
//		i registri del bus EMIF che determinano le temporizzazioni di accesso 
//		verso le risorse collegate al medesimo bus.
//-----------------------------------------------------------------------
void	myInitDskBoard (void)
{
	DSK5510_init();			
	DSK5510_LED_init();
	DSK5510_DIP_init();
	SetMckFreq       (DEFAULTDIV,DEFAULTMULT,DEFAULTPLLENABLE,DEFAULTBYPASSDIV);
	SetWrAccessTiming(DEFAULTSETUP,DEFAULTSTROBE,DEFAULTHOLD);
	SetRdAccessTiming(DEFAULTSETUP,DEFAULTSTROBE,DEFAULTHOLD);
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




//--------------------------------------------------------------------
//				TIMER SET
//--------------------------------------------------------------------
//	Inizializza i registri del TIMER e imposta la frequenza del segnale prodotto
//	nel seguente modo:
//
//		TOUT#0 [Hz] = CPU_Clock / ((1+TDDR) *(1+PRD))
//		
//	Assumendo CPU_Clock=200MHz, il parametro in ingresso rappresenta in KHz la frequenza
//	di TOUT#0.
//--------------------------------------------------------------------

void TIMER_SET(int rep_freq)
{

	PRSC0 = 0x0009;		// Pone TDDR = 9

	PRD0 = 20000/rep_freq-1;	// Pone PRD=...

	TCR0 = (FUNC1<<11) | (ARB<<5) | (CP<<3);
}



//----------------------------------------------------------------------------
//			TIMER SYNC
//----------------------------------------------------------------------------
//	La funzione esegue le seguenti attività:
//		1. Azzera il bit n.4 del registro IFR0
//		2. Attende la fine conteggio del Timer #0 segnalato dallo stato del bit n.4 del registro IFR0	
//		3. Azzera il bit n.4 del registro IFR0
//--------------------------------------------------------------------

void	TimerSync (void)
{
	register int	temp;
	
	temp = IFR0;
	IFR0 = temp;	//Reset del FlagRegister0

	while(!(IFR0&0x0010)){};

	temp = IFR0;
	IFR0 = temp;	//Reset del FlagRegister0
}


//----------------------------------------------------------------------------
//			FILTRO FIR scritto in C
//----------------------------------------------------------------------------
//	Parametri:
//	dataBuf	puntatore all'inizio del buffer circolare contenente i campioni di ingresso
//	hBuff	puntatore all'inizio del buffer contenente i coefficienti del filtro
//	index	indice della cella del vettore dataBuf contenente l'ultimo campione
//			convertito e scritto nel vettore.
//	out		valore in uscita dal filtro
//
//	Note:	La funzione preleva la sequenza di campioni di ingresso (contenuta in dataBuf e lunga NTAP)
//			e la inserisce nel buffer xLin, quindi moltiplica la sequenza per la maschera del filtro
//----------------------------------------------------------------------------

int	FiltroFirC (int *dataBuf, int *hBuff, int index)
{
	int		xLin[NTAP];
	int		j;
	int		k;
	int		pippo;
	long int	accVar;
												// Estrae i campioni dal buffer circolare 
												// e li dispone nel buffer lineare xLin
	for (j=index, k=0; j>=0; j--, k++)	xLin[k] = dataBuf[j];
	for (j=NTAP-1; j>index; j--, k++)	xLin[k] = dataBuf[j];

    accVar = 0;									// Inizializza l'accumulatore

    for (j=0; j<NTAP; j++)
    	accVar += (long int)xLin[j] * hBuff[j];	// FIR
	    	
    pippo = accVar >> 4;						// Riscala l'accumulatore

    return (pippo);
}
