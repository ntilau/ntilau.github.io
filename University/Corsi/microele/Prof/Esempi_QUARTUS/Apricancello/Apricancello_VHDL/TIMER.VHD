LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Timer IS
	PORT
	(
		clk			: IN	STD_LOGIC;
		reset		: IN	STD_LOGIC;
		value		: IN	INTEGER range 0 to 255;
		timeout		: OUT	STD_LOGIC
	);
END Timer;


ARCHITECTURE Timer OF Timer IS
BEGIN

	PROCESS (clk, reset)	
		VARIABLE Temp	:	INTEGER range value'range;
	BEGIN

		IF (reset = '1') THEN
			timeout <= '0';
			Temp := 0;
		ELSIF RISING_EDGE(clk) THEN
			
			IF (Temp = value) THEN
				Temp := 0;
				Timeout <= '1';
			ELSE
				Temp := Temp + 1;
				Timeout <= '0';
			END IF;
		END IF;

	END PROCESS;

END Timer;
