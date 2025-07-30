

ENTITY ProvaVHDL IS
	GENERIC
	(
		Larghezza			: integer :=	8;
		Carry				: bit 	  :=	'0'
	);
	PORT
	(
		A, B							: IN	BIT;
		C								: IN	BOOLEAN := true;
		NumeroIN						: IN 	INTEGER;
		NumeroIN2						: IN	INTEGER range 0 to 255;
		NumeroIN3						: IN	INTEGER := 100;
		ADDRESS							: IN	BIT_VECTOR(15 downto 0);
		
		Uscita							: OUT	BIT;
		Uscita2							: OUT	BOOLEAN;
		NumeroOUT						: OUT	INTEGER;
		NumeroOUT2						: OUT	INTEGER;
		ArrayOUT						: OUT	BIT_VECTOR(3 downto 0);
		ArrayOUT2						: OUT	BIT_VECTOR(3 downto 0)
	);
END ProvaVHDL;


ARCHITECTURE a OF ProvaVHDL IS

	CONSTANT Costante1 : BIT := '0';

	SIGNAL Segnale1 : INTEGER;


BEGIN

	Uscita  <= A and B;
	Uscita2  <= NumeroIN > NumeroIN3;
	
	NumeroOUT <= NumeroIN + NumeroIN3;
--	NumeroOUT2 <= NumeroIN mod NumeroIN3;
	
	
	ArrayOUT	<= 	("0000") 	WHEN  NumeroIN2 = 10 else
					("1111")	WHEN  NumeroIN2 = 20 else
					("1111")	WHEN  NumeroIN2 = 40 else
					(0 => '1', 3 => '1', others => '0');
	
WITH NumeroIN2 SELECT
	ArrayOUT2	<=	("0000") 	WHEN	10,
					("1111")	WHEN	20,
					("1001")	WHEN	30 to 40,
					("1100")	WHEN	50 | 60 | 70,
					unaffected when others;

	
	
	
		
		
END a;
