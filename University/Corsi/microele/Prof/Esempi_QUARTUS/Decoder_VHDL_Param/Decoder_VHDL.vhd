-- Decoder utilizzato per la decodifica degli indirizzi

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Decoder_VHDL IS

	GENERIC
	(
		-- Permetto di generare decoder di 6 bit con uscita a 64bit
		-- Più grandi non ha molto senso
		IN_WIDTH	: natural range 1 to 6 := 3
	);

	PORT
	( 
		Enable 	: IN 	STD_LOGIC;
		Input 	: IN 	STD_LOGIC_VECTOR (IN_WIDTH - 1 DOWNTO 0);
		Output	: OUT 	STD_LOGIC_VECTOR ((2 ** IN_WIDTH)- 1 DOWNTO 0)
	);

END Decoder_VHDL;

ARCHITECTURE generic_decoder OF Decoder_VHDL IS
BEGIN
	PROCESS (Enable, Input)

		VARIABLE temp1 : STD_LOGIC_VECTOR (Output'HIGH DOWNTO 0);
		VARIABLE temp2 : INTEGER RANGE 0 TO Output'HIGH;

	BEGIN

		temp1 := (OTHERS => '1');
		temp2 := 0;

		IF (Enable = '1') THEN
			
			-- Il range di Input è (2 downto 0)
			FOR i IN Input'RANGE LOOP

				-- Conversione binario -> intero (questo algoritmo funziona solo con range decrescenti)			
				IF (Input(i) = '1') THEN
					temp2 := 2 * temp2 + 1;
				ELSE
					temp2 := 2 * temp2;
				END IF;
			
			END LOOP;

			temp1(temp2) := '0';

		END IF;

		Output <= temp1;

	END PROCESS;
END generic_decoder;