

ENTITY Decoder0 IS
	PORT
	(
		IN0, IN1				: in 	BIT;
		OUT0, OUT1, OUT2, OUT3	: out	BIT
	);
END Decoder0;


ARCHITECTURE DecoderA OF Decoder0 IS
BEGIN

	OUT0 <= NOT IN0 AND NOT IN1;
	OUT1 <=     IN0 AND NOT IN1;
	OUT2 <= NOT IN0 AND     IN1;
	OUT3 <=     IN0 AND     IN1;


END DecoderA;

ARCHITECTURE DecoderB OF Decoder0 IS
BEGIN

	OUT0 <= '1' when (IN0 = '0' AND IN1 = '0') else '0';
	OUT1 <= '1' when (IN0 = '1' AND IN1 = '0') else '0';
	OUT2 <= '1' when (IN0 = '0' AND IN1 = '1') else '0';
	OUT3 <= '1' when (IN0 = '1' AND IN1 = '1') else '0';

END DecoderB;

ENTITY Decoder1 IS
	PORT
	(
		INPUT	: in 	BIT_VECTOR(0 to 1);
		OUTPUT	: out	BIT_VECTOR(0 to 3)
	);
END Decoder1;


ARCHITECTURE DecoderC OF Decoder1 IS
BEGIN

	OUTPUT <= 	(0 => '1', others => '0') when INPUT = "00" else
				(1 => '1', others => '0') when INPUT = "10" else
				(2 => '1', others => '0') when INPUT = "01" else
				(3 => '1', others => '0') when INPUT = "11";

END DecoderC;
