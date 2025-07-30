
---- DICHIARAZIONE DI FUNZIONI, PROCEDURE, COMPONENTI, TIPI E COSTANTI IN UN PACKAGE ------

PACKAGE my_package IS

	-- Esempio di dichiarazione di tipo in un package
	TYPE INTEGER_VECTOR is array (POSITIVE range <>) of INTEGER;
	-- Esempio di dichiarazione di costante in un package
	CONSTANT MY_CONSTANT : BIT := '1';
	
	-- Esempio di dichiarazione di "prototipo" di funzione e di procedura in un package
	-- Questa parte assomiglia al file .h del linguaggio C / C++
	-- Devo poi fornire la definizione del corpo della funzione e della procedura in un package body
	FUNCTION INCREMENT(SIGNAL s: INTEGER) RETURN INTEGER;
	PROCEDURE sort_package (SIGNAL in1, in2: IN INTEGER RANGE 0 TO INTEGER'RIGHT; SIGNAL min, max: OUT INTEGER RANGE 0 TO INTEGER'RIGHT);
	
	-- Esempio di dichiarazione di prototipo di componente... 
	-- In questo caso il corpo del componente non si trova nel package body ma fuori da esso...
	-- Possibilmente anche in un altro file.
	COMPONENT reg IS
		PORT (d, clk, rst: IN BIT; q: OUT BIT);
	END COMPONENT;
	
END my_package;


--- I COMPONENTI, LE FUNZIONI E PROCEDURE DEVONO AVERE UN CORPO QUI PRESENTE ---------------

PACKAGE BODY my_package IS

	-- Corpo della funzione INCREMENT
	FUNCTION INCREMENT(SIGNAL s: INTEGER) RETURN INTEGER IS
	BEGIN
		RETURN s + 1;
	END INCREMENT;
	
	-- CORPO della funzione sort_package
	PROCEDURE sort_package (SIGNAL in1, in2: IN INTEGER RANGE 0 TO INTEGER'RIGHT; SIGNAL min, max: OUT INTEGER RANGE 0 TO INTEGER'RIGHT) IS
	BEGIN
		IF (in1 > in2) THEN
			max <= in1;
			min <= in2;
		ELSE
			max <= in2;
			min <= in1;
		END IF;
	END sort_package;
END my_package;



ENTITY reg IS
	PORT (
			d, clk, rst	: IN 	BIT;
			q			: OUT 	BIT
		);
END reg;

ARCHITECTURE reg OF reg IS
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF (rst='1') THEN 
			q <= '0';
		ELSIF (clk'EVENT AND clk='1') 
			THEN q <= d;
		END IF;
	END PROCESS;
END reg;

--------------------------------------------------------------------------------------------

--- dichiaro di utilizzare la libreria work e il package my_package precedentemente definito
--- Il package avrebbe potuto essere in un altro file.

LIBRARY work;				--- Non serve dichiararne l'uso... è implicitamente dichiarato.
USE work.my_package.all;	--- Sto dicendo che ho intenzione di utilizzare tutto il contenuto del package my_package della libreria work



--- Dichiarazione di entità e architettura di esempio

ENTITY VHDL_FuncProc IS
	PORT
	(
		IN1, IN2					: IN	INTEGER;
		OUT_A, OUT_B, OUT_C, OUT_D	: OUT	INTEGER
	);
END VHDL_FuncProc;


ARCHITECTURE VHDL_FuncProc OF VHDL_FuncProc IS

	--- Esempio di dichiarazione di funzione nel corpo dichiarativo dell'architecture.
	--- Notare che il parametro a è una costante, b è un segnale.

	FUNCTION PROVA (a: INTEGER; SIGNAL b: INTEGER) RETURN INTEGER IS
		VARIABLE Temp : INTEGER;
	BEGIN
		Temp := a + b;
		RETURN Temp;
	END PROVA;

	--- Esempio di dichiarazione di procedura nel corpo dichiarativo dell'architecture.
	--- Notare che i parametri in1 e in2 sono SEGNALI in solo INGRESSO
	--- Notare che i parametri min e max sono SEGNALI in sola USCITA
	--- Una procedura dichiarata in questa parte può anche prevedere la dichiarazione di segnali
	PROCEDURE sort (SIGNAL in1, in2: IN INTEGER RANGE 0 TO INTEGER'HIGH; SIGNAL min, max: OUT INTEGER RANGE 0 TO INTEGER'HIGH) IS
	BEGIN
		IF (in1 > in2) THEN
			max <= in1;
			min <= in2;
		ELSE
			max <= in2;
			min <= in1;
		END IF;
	END sort;

BEGIN

	-- CORPO EFFETTIVO DELL'ARCHITETTURA
	-- SOLO CHIAMATE CONCORRENTI A PROCEDURE E FUNZIONI

	OUT_A <= PROVA(IN1, IN2);
	OUT_B <= INCREMENT(IN1);
	sort(IN1, IN2, OUT_C, OUT_D);
	
END VHDL_FuncProc;








