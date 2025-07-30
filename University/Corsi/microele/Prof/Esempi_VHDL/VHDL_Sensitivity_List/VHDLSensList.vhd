

ENTITY VHDLSensList IS
	PORT
	(
		A, B			: IN	BIT;
		C, D, E, F, G	: OUT	BIT
	);
END VHDLSensList;


ARCHITECTURE VHDLSensList OF VHDLSensList IS
BEGIN

	-- La seguente è un esempio di operazione "concorrente" di assegnazione al segnale C.
	-- L'esecuzione del calcolo dell' AND logico di A e B viene attivata da un evento di variazione di A e/o B.
	-- In generale una qualunque operazione "concorrente" viene attivata da un evento
	-- di variazione di uno qualunque degli operandi in ingresso.
	-- Ogni operazione di assegnazione di segnali e porte avviene in un tempo fisico diverso da zero.

	C <= A and B;

	-- Esiste la possibilità di definire un hardware dal punto di vista sequenziale.
	-- Questo viene effettuato in un blocco PROCESS. Tali blocchi sono eseguiti in parallelo
	-- alle altre operazioni concorrenti come ad esempio la precedente.
	-- L'esecuzione del blocco process avviene in un tempo fisico diverso da zero.
	-- La descrizione hardware nei blocchi process viene effettuata SOLO tramite
	-- statement sequenziali. Indipendentemente dal numero di passi sequenziali necessari alla
	-- esecuzione di un process, il tempo fisico è sempre considerato lo stesso.
	
	-- Il blocco process può essere visto come un ambiente in cui inserire un 
	-- algoritmo seguenziale come se fosse un programma C / C++.
	-- Il sintetizzatore si occuperà di convertire il progetto in una rete logica
	-- che implementa l'algoritmo in modo parallelo.
	
	-- Ogni processo deve avere un TEMPO FINITO DI ESECUZIONE. Quindi tutto quello che è presente fra 
	-- BEGIN ed END PROCESS può essere visto come se fosse inserito in un LOOP implicitamente dichiarato
	-- (un PROCESS arrivato al termine non può che essere eseguito nuovamente).
	-- Un PROCESS non può però essere mantenuto in esecuizione continua!!!
	-- Diversamente dalle operazioni concorrenti, le quali sono implicitamente attivate da un qualunque evento 
	-- di variazione di uno qualunque degli operandi ingresso, per i PROCESS è necessario indicare esplicitamente
	-- quali sono gli operandi che attivano l'esecuzione del process stesso.
	-- Questa operazione viene effettuata in più modi...
	
	-- Modo 1) : La parte (A, B) dopo process è detta SENSITIVITY LIST. Questo è un elenco esplicito di sengali, di qualunque tipo,
	-- i quali causano l'attivazione del processo. Nell'esempio seguente una qualunque variazione di A e/o B causa
	-- l'esecuzione del processo e l'assegnazione a D dell' AND logico dei segnali.
	
	PROCESS (A, B)
	BEGIN
	
		D <= A and B;
	
	END PROCESS;
	
	-- NOTA : Nel seguente ESEMPIO la sensitivity list è composta dal solo segnale A.
	-- L'esecuzione del processo è quindi effettuata solo a seguito di eventi di A.
	-- Variazioni di B non vengono prese in considerazione. L'operazione di AND logico viene effettuata ma solo su eventi di A.
	-- QUARTUS II non sintetizza una rete del genere e considera che la sensitivity list sia in realtà composta da A e B... 
	-- sintetizzando di fatto una rete diversa da quella richiesta.
	-- Di questo viene dato notizia all'utente nel log di compilazione tramite un WARNING opportuno.


--	PROCESS (A)
--	BEGIN
--
--		D <= A and B;
--
--	END PROCESS;

	-- Modo 2) : In questo modo non si specifica la SENSITIVITY LIST. 
	-- Si suppone che il processo sia in esecuzione continua ma lo si mantiene bloccato tramite uno statement WAIT
	-- Lo statemente WAIT può essere utilizzato tramite tre differenti modalità. In questo caso è la WAIT ON <sensitivity list>.
	-- Il seguente esempio è del tutto analogo al primo modo (PROCESS (A, B)). Il vantaggio è che posso posizionare il WAIT ON 
	-- in qualunque parte dell'elenco di statement sequenziali. Anche più di uno per process.

	-- NOTA : QUARTUS II non sintetizza l'istruzione WAIT ON...!
	
	PROCESS
	BEGIN
		WAIT ON A, B;
	
		E <= A and B;
	
	END PROCESS;
	
	-- Modo 3) : Anche in questo modo non si specifica la SENSITIVITY LIST. Come per il caso precedente si suppone che il processo sia in 
	-- esecuzione continua ma lo si mantiene bloccato tramite uno statement WAIT. In questo caso WAIT UNTIL <condizione>.
	-- Il seguente esempio è del tutto analogo al primo modo (PROCESS (A, B)). Anche in questo caso posso posizionare il WAIT FOR
	-- in qualunque parte dell'elenco di statement sequenziali. Anche più di uno per process.
	-- L'esecuzione è attivata quando la condizione è verificata.

	-- NOTA : In questo caso QUARTUS II è in grado di sintetizzare l'istruzione WAIT UNTIL...! L'unica differenza è che,
	-- mentre ci si aspetterebbe una esecuzione continua quando A e B sono entrambi '1', di fatto l'esecuzione viene attivata solo 
	-- all'attivarsi della condizione e non sul suo "livello".
	-- In altre parole la sintesi di questo prevede di mandare in ingresso ad un FLIP-FLOP tipo D il risultato della AND dei due segnali
	-- e utilizzare come ingresso di clock la condizione del WAIT UNTIL...
	-- Viene di fatto sintetizzata una rete il cui comportamento è leggermente differente da quello atteso...!!!!
	
	PROCESS
	BEGIN
		WAIT UNTIL ((A = '1') and (B = '1'));
	
		F <= A and B;
	
	END PROCESS;
	
	
	-- Modo 4) : Questo modo non è sintetizzabile a prescindere da Quartus II ma solo sintetizzabile.
	-- Non prevede di esplicitare una sensitivity list ma solo di indicare ogni quanto tempo avviare il processo.
	-- Questo si ottiene tramite l'uso di WAIT FOR <time>.

	PROCESS
	BEGIN
		WAIT FOR 100ns;
	
		G <= A and B;
	
	END PROCESS;
	

END VHDLSensList;
