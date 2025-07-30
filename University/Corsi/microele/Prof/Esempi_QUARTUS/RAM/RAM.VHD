
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY RAM IS
	GENERIC 
	( 		
		bits: INTEGER := 8; 	-- # Larghezza del bus dati
		words: INTEGER := 16	-- # Larghezza del bus indirizzi
	); 	

	PORT 
	( 	
		clk, wr_ena: IN STD_LOGIC;
		addr: IN INTEGER RANGE 0 TO words-1;
		data: INOUT STD_LOGIC_VECTOR (bits-1 DOWNTO 0)
	);
END RAM;


ARCHITECTURE RAM OF RAM IS
	TYPE vector_array IS ARRAY (0 TO words-1) OF STD_LOGIC_VECTOR (bits-1 DOWNTO 0);

	SIGNAL memory : vector_array;

BEGIN
	PROCESS (clk, wr_ena)
	BEGIN

		IF (wr_ena = '0') THEN
			data <= memory(addr);
		ELSE
			data <= (OTHERS => 'Z');

			IF (clk'EVENT AND clk='1') THEN
				memory(addr) <= data;
			END IF;

		END IF;

	END PROCESS;

END RAM;
