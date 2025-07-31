LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY TRISTATEDFF IS
	PORT
	(
		IngressoTRI, Enable				: IN	STD_LOGIC;
	
		UscitaTRI1, UscitaTRI2			: INOUT	STD_LOGIC;
	
		IngressoFF, Clock				: IN	STD_LOGIC;
	
		UscitaFF1, UscitaFF2, UscitaFF3	: OUT	STD_LOGIC
	);
END TRISTATEDFF;


ARCHITECTURE TRISTATEDFF OF TRISTATEDFF IS
	SIGNAL Temp  : STD_LOGIC;
	SIGNAL Temp2 : STD_LOGIC;
BEGIN

	TRISTATE :
	PROCESS (IngressoTRI, Enable)	
	BEGIN
	
		if (Enable = '1') then
			UscitaTRI1 <= IngressoTRI;
			Temp <= IngressoTRI;
		else
			UscitaTRI1 <= 'Z';
			Temp <= 'Z';
		end if;
		
		UscitaTRI2 <= Temp;

	END PROCESS;


	FLIPFLOP :
	PROCESS (IngressoFF, Clock)	
	BEGIN
	
		if (Clock'EVENT and Clock = '1') then
			UscitaFF1 <= IngressoFF;
			Temp2 <= IngressoFF;
			UscitaFF3 <= Temp2;
		end if;
		
		UscitaFF2 <= Temp2;

	END PROCESS;

END TRISTATEDFF;
