LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Prova is
	port
	(

		-- Input ports
		Clock		: in  bit;
		Control		: in  bit;
		Control2	: in  bit;
		Control3	: in  boolean;
		NumeroIN	: in  integer range 0 to 255;
		NumeroIn2	: in  integer range 0 to 255;
		
		-- Output ports
		NumeroOUT	: out  integer range 0 to 511;
		TestVector	: out  bit_vector (0 to 7);
		TestVector2	: out  bit_vector (0 to 3);
		Uscita		: out  boolean;
		Uscita2		: out  bit;
		Uscita3		: out  bit
	);
end Prova;


architecture ProvaProva of Prova is
	
	-- I tipi di dati o li dichiaro in libreria oppure li dichiaro qui...
	-- Se li dichiaro in libreria posso usarli anche nella definizione di porta.
	TYPE integer_vector is array (0 to 15) of integer;		-- Non esiste un tipo di default per i vettori di interi
	
	CONSTANT Costante : integer := 10;
	SIGNAL Segnale : bit;
	SIGNAL VettoreDiInteri : integer_vector;				-- Dichiaro un segnale del tipo qui definito
	SIGNAL VettoreDiInteri2 : integer_vector;				-- Dichiaro un segnale del tipo qui definito
	
	COMPONENT MIA_AND IS
--		GENERIC
--		(
--			parameter1 : string := default_value1;
--			parameter2 : integer := default_value2
--		);
		PORT
		(
			A, B		: IN	BIT;
			C			: OUT	BIT
		);
	END COMPONENT;

begin

		-- Esempio di utilizzo di un componente (in altre parole esempio di uso di una entity definita in questo o altro foglio)
		-- Rappresenta una descrizione STRUTTURALE
		-- La parte GENERIC MAP effettua la "mappatura" dei GENERIC definiti nella entity del componente a valori definiti in questa architecture
		-- La parte PORT MAP effettua la "mappatura" dei segnali della presente architecture alle porte del componente

		LaMiaNand : MIA_AND
--		GENERIC MAP
--		(
--			parameter1	=>	value1, 
--			parameter2	=>	value2
--		) 
		PORT MAP
		(
			A	=>	Control, 
			B	=>	Control2,
			C	=>	Uscita3
		);

		-- Di seguito sono riportati esempi di utilizzo di STATEMENT CONCORRENTI (ESECUZIONE PARALLELA A LIVELLO DI SIMULAZIONE)
		-- E' una descrizione di tipo COMPORTAMENTALE (BEHAVIOURAL)
		Uscita 		<=	NumeroIN < NumeroIn2;

		Uscita2		<=	Segnale;
		Segnale		<=	Clock and Control;		-- Notare che assegno dati a Segnale dopo averlo usato...! Statements concorrenti


		VettoreDiInteri(0) 	<= 10;				-- Esempio di assegnazione di un elemento del vettore di interi dichiarato
		VettoreDiInteri2	<= (0 => 55, 2 => 77, others => 33);
		
--		VettoreDiInteri2	<= (others => 11);

		-- Esempio di utilizzo di WHEN
		TestVector2 <= 		("1111") when (Control3 and (NumeroIN = 14)) else
							("0000") when (Control3 and (NumeroIN = 12)) else
							("0110");

		-- Esempio di utilizzo di WHIT, SELECT, WHEN 
		with NumeroIn select
			TestVector <= 	("10101010") when 0,
							("00000000") when 1,
							("11111111") when 2,
							("00110011") when 10 to 20,
							("11000011") when 30 | 31 | 32 | 51,
			unaffected when others;

		-- Esempio di utilizzo di un processo
		process (Clock)
		begin
		
			if (Clock'Event and Clock = '1') then
				NumeroOUT <= NumeroIN + NumeroIn2 + Costante;
			end if;

		end process;

end ProvaProva;
