entity EncoderVHDL is
	port
	(
		-- Input ports
		ToBeEncoded	: in  	BIT_VECTOR(15 downto 0);
		Encoded		: out  	INTEGER range 0 to 15
	);
end EncoderVHDL;

architecture EncoderVHDL of EncoderVHDL is
begin

	process(ToBeEncoded) is
		VARIABLE Temp : INTEGER := 0;
		VARIABLE Temp2 : INTEGER := 0;
	begin
	
		Temp := 0;
		Temp2 := 0;

		for Temp IN ToBeEncoded'RANGE LOOP
			
			if (ToBeEncoded(Temp) = '1') then
				Temp2 := Temp;
			end if;
			
			exit when (ToBeEncoded(Temp) = '1');

		end loop;
		
		Encoded <= Temp2;

	end process;

end EncoderVHDL;
