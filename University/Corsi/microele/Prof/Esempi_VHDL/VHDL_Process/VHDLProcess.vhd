LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY VHDLProcess IS
	PORT
	(
		A, B				: IN	STD_LOGIC;
		Clock				: IN	STD_LOGIC;
		Vettore				: IN	STD_LOGIC_VECTOR(15 DOWNTO 0);
		OUT1, OUT2, OUT3	: OUT	STD_LOGIC
	);
END VHDLProcess;


ARCHITECTURE VHDLProcess OF VHDLProcess IS
BEGIN

	OUT1 <= A and B;

	MIO_PROCESSO:
	PROCESS
		VARIABLE Temp1	: integer;
		VARIABLE Temp2	: integer;
	BEGIN
	
		WAIT UNTIL A = '1';
		
		Temp2 := 0;

		FOR Temp1 IN 0 TO 15 LOOP
			if (Vettore(Temp1) = '1') then
				Temp2 := Temp2 + 1;
			end if;
		END LOOP;

		if (Temp2 >= 3) then
			OUT2 <= '1';
		else
			OUT2 <= '0';
		end if;

	END PROCESS MIO_PROCESSO;


	MIO_PROCESSO2:
	PROCESS
		VARIABLE Temp1	: integer;
		VARIABLE Temp2	: integer;
	BEGIN
	
		WAIT UNTIL A = '1';
		
		Temp1 := 0;
		Temp2 := 0;

		WHILE Temp1 <= 15 LOOP
			if (Vettore(Temp1) = '1') then
				Temp2 := Temp2 + 1;
			end if;
			Temp1 := Temp1 + 1;
		END LOOP;

		if (Temp2 >= 4) then
			OUT3 <= '1';
		else
			OUT3 <= '0';
		end if;

	END PROCESS MIO_PROCESSO2;


END VHDLProcess;
