LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY TriState IS
	PORT 
	(
	 		ena: IN STD_LOGIC;
			input: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			output: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END TriState;

ARCHITECTURE TriState OF TriState IS
BEGIN
	output 	<= 	input WHEN (ena = '0') ELSE
				(OTHERS => 'Z');
END TriState;
