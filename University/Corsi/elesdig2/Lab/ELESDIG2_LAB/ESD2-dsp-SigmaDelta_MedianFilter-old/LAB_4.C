#include "ESD_Library.h"

//----------------------------------------------------------------------------
//			Sigma Delta Converter - prima parte
//
//			File: LAB_4
//----------------------------------------------------------------------------
//
//		Questo programma costituisce il punto di partenza sul quale basare la gestione
//		del modulatore del primo ordine realizzato.
//		Le funzioni implementate sono le seguenti:
//
//		1. Inizializzazione della scheda DSK
//		2. programmazione del PLL (interno al DSP) per impostare la frequenza di clock del DSP = 200 MHz
//		3. Programmazione del TIMER interno al DSP per cadenzare l'esecuzione del loop
//		4. Implementazione di un semplice loop infinito, che si limita a:

//		4.a	aspettare il consenso del timer;
//		4.b	leggere il livello logico prodotto dall'uscita dell'A/D ad 1 bit;
//		4.c	riportare lo stesso livello in ingresso al D/A ad 1 bit;
//		4.d	

//
//		Note varie:
//		- se vengono inserite nuove funzioni, ricordarsi che queste devono introdurre un costo computazionale modesto, 
//		  in modo tale che il tempo complessivo di esecuzione di tutte le funzioni inserite nel loop sia minore o uguale 
//		  al periodo impostato nel timer.
//		- se necessario, è possibile utilizzare i DIP_SWITCHES e i LED presenti sul DSK e sulla Daugther card attraverso specifiche funzioni.
//----------------------------------------------------------------------------

#define	BS_LENG	1024
#define	K		4

int	BitStream [BS_LENG];
int	BitStreamLPF [BS_LENG];

//----------------------------------------------------------------------------
//					MAIN
//----------------------------------------------------------------------------
void main()
{
	int	b;
	int	Acc;
	int	j, i;
	unsigned int n;
	int	m;

	myInitDskBoard ();
	TIMER_SET(10);			// Fissa la frequenza del timer [kHz]
	DB_CFGREG = 0;
 
    while (TRUE) {
    
    	Acc = 0;
    	
    	for (m=0; m<1; m++) {
 		   	for (i=0; i<BS_LENG; i++) {

				TimerSync ();
				b = DB_INBUF;		// Legge l’ingresso del buffer
				DB_OUTREG = b;		// Scrive il bit (0 o 1) nell’output register

				BitStream[i] = b&1;
//				Acc += BitStream[i];
//				Acc -= BitStream[unsigned(i-K)&(BS_LENG-1)];

				Acc = 0;
				for (j=0;j<K;j++) {
					n = ((unsigned int)(i-j)) & (BS_LENG-1);
					Acc += BitStream[n];
				}
				BitStreamLPF[i] = Acc;
			}
		}
	}
}

