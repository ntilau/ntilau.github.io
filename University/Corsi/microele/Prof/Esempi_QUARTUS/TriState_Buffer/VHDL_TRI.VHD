LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY BufferTriState IS
	PORT
	(
		Input0, Input1				: IN	STD_LOGIC;
		Controllo0, Controllo1		: IN	STD_LOGIC;
		Output						: INOUT	STD_LOGIC
	);
END BufferTriState;


ARCHITECTURE BufferTriStateA OF BufferTriState IS
BEGIN

	PROCESS (Input0, Controllo0)
	BEGIN

		if (Controllo0 = '1') then
			Output <= Input0;
		else
			Output <= 'Z';
		end if;
		
	END PROCESS;

	PROCESS (Input1, Controllo1)
	BEGIN

		if (Controllo1 = '1') then
			Output <= Input1;
		else
			Output <= 'Z';
		end if;

	END PROCESS;

END BufferTriStateA;


ARCHITECTURE BufferTriStateB OF BufferTriState IS
BEGIN

	Output <= Input0 when Controllo0 = '1' else 'Z';
	Output <= Input1 when Controllo1 = '1' else 'Z';
	
END BufferTriStateB;


--------  Attenzione... cosa c'è che non va in questa implementazione ???
--ARCHITECTURE BufferTriStateC OF BufferTriState IS
--	SIGNAL Temp : STD_LOGIC;
--BEGIN

--	PROCESS (Input0, Controllo0)
--	BEGIN

--		if (Controllo0 = '1') then
--			Temp <= Input0;
--		else
--			Temp <= 'Z';
--		end if;
		
--	END PROCESS;

--	PROCESS (Input1, Controllo1)
--	BEGIN

--		if (Controllo1 = '1') then
--			Temp <= Input1;
--		else
--			Temp <= 'Z';
--		end if;

--	END PROCESS;

--	Output <= Temp;

-- END BufferTriStateC;