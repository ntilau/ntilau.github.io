LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY Ritardi IS
	PORT
	(
		clock		: IN	STD_LOGIC;
		A, B		: IN	STD_LOGIC;
		C			: OUT	STD_LOGIC;
		D			: OUT	STD_LOGIC;
		E			: OUT	STD_LOGIC
	);
END Ritardi;


ARCHITECTURE Ritardi OF Ritardi IS
	SIGNAL TEMP : STD_LOGIC;
BEGIN

	C <= A and B AFTER 100ns;
	E <= TRANSPORT A and B  AFTER 100ns ;

	process (clock)
	begin

		if ((clock'event) and (clock = '1')) then
			TEMP <= A AND B AND NOT TEMP AFTER 200ns;
		end if;

		D <= TEMP;

	end process;

END Ritardi;
