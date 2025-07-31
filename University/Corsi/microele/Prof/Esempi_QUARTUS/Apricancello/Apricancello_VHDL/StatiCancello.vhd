-- Quartus VHDL Template
-- State Machine with Asynchronous Reset (2 block)

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Stati_Cancello IS
	PORT
	(
		ch, fs, fa, fc, tm		: IN	STD_LOGIC := '0';
		clk, reset				: IN	STD_LOGIC := '0';

		ma, mc, et				: OUT	STD_LOGIC;
		value					: OUT	INTEGER range 0 to 255
	);
END Stati_Cancello;

ARCHITECTURE rtl OF Stati_Cancello IS
	TYPE state_type IS (CHIUSO, APERTURA, APERTO, CHIUSURA, PAUSA);
	SIGNAL StatoCorrente: state_type;
BEGIN

	-- Sequential block to create state registers and state transitions
	PROCESS (clk, reset)
	BEGIN
		IF reset = '1' THEN

			StatoCorrente <= CHIUSO;

		ELSIF clk'EVENT AND clk = '1' THEN
		
			CASE StatoCorrente IS
				WHEN CHIUSO =>
					IF ch = '1' THEN
						StatoCorrente <= APERTURA;
					END IF;

				WHEN APERTURA =>
					IF fa = '1' THEN
						StatoCorrente <= APERTO;
					END IF;

				WHEN APERTO =>
					IF ((ch = '0') and (fs = '0') and (tm = '1')) THEN
						StatoCorrente <= CHIUSURA;
					END IF;

				WHEN CHIUSURA =>
					IF ((fs = '1') or (fc = '1')) THEN
						StatoCorrente <= PAUSA;
					END IF;

				WHEN PAUSA =>
					IF ((fc = '1') and (tm = '1')) THEN
						StatoCorrente <= CHIUSO;
					END IF;

					IF ((fc = '0') and (tm = '1')) THEN
						StatoCorrente <= APERTURA;
					END IF;

			END CASE;
		END IF;

	END PROCESS;

	-- Combinational logic to create outputs for each state
	WITH StatoCorrente SELECT
		ma		<=	'0'	WHEN	CHIUSO,
					'1'	WHEN	APERTURA,
					'0'	WHEN	APERTO,
					'0'	WHEN	CHIUSURA,
					'0'	WHEN	PAUSA;

	WITH StatoCorrente SELECT
		mc		<=	'0'	WHEN	CHIUSO,
					'0'	WHEN	APERTURA,
					'0'	WHEN	APERTO,
					'1'	WHEN	CHIUSURA,
					'0'	WHEN	PAUSA;

	-- Attenzione, per questo c'è una leggera differenza dalla versione AHDL
	-- In AHDL et va basso quando ch = '1' oppure fs = '1'
	-- In questo sorgente non viene mandato basso
	WITH StatoCorrente SELECT
		et		<=	'0'	WHEN	CHIUSO,
					'0'	WHEN	APERTURA,
					'1'	WHEN	APERTO,
					'0'	WHEN	CHIUSURA,
					'1'	WHEN	PAUSA;

	WITH StatoCorrente SELECT
		value	<=	255	WHEN	CHIUSO,
					255	WHEN	APERTURA,
					7	WHEN	APERTO,
					255	WHEN	CHIUSURA,
					3	WHEN	PAUSA;

END rtl;
