entity Contatore is
	port
	(
		clk				: in  bit;
		reset			: in  bit;

		time_to_wait	: in  integer range 0 to 255;

		timeout			: out bit
	);
end Contatore;


architecture Contatore of Contatore is
begin

	process (clk, reset)
		variable Count : integer range 0 to 255;
	begin
		
		if (reset = '1') then
			Count := 0;
		elsif (clk'event and clk = '1') then
			if Count = time_to_wait then
				Count := 0;
			else
				Count := Count + 1;
			end if;
		end if;

		if (clk'event and clk = '1') then
			if Count = time_to_wait then
				timeout <= '1';
			else
				timeout <= '0';
			end if;
		end if;

	end process;

end Contatore;
