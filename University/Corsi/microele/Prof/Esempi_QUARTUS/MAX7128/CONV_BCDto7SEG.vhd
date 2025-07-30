LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY CONV_BCDto7SEG IS
	PORT( DataIn	  : IN	INTEGER RANGE 0 TO 15;
    	  DataOut     : OUT   STD_LOGIC_VECTOR(6 downto 0));
END CONV_BCDto7SEG;

ARCHITECTURE CONV_BCDto7SEG_arc OF CONV_BCDto7SEG IS
BEGIN

		        WITH DataIn SELECT
                        DataOut	<=	"1111110"	WHEN	0,  --  0
				                 	"0110000"	WHEN	1,  --  1
					                "1101101"	WHEN	2,  --  2
					                "1111001"	WHEN	3,  --  3
					                "0110011"	WHEN	4,  --  4
					                "1011011"	WHEN	5,  --  5
					                "1011111"	WHEN	6,  --  6
					                "1110000"	WHEN	7,  --  7
					                "1111111"	WHEN	8,  --  8
					                "1111011"	WHEN	9,  --  9
					                "1110111"	WHEN   10,  --  10
					                "0011111"	WHEN   11,  --  11
					                "1001110"	WHEN   12,  --  12
					                "0111101"	WHEN   13,  --  13
					                "1001111"	WHEN   14,  --  14
					                "1000111"	WHEN   15;  --  15

END CONV_BCDto7SEG_arc;