-- In questo esempio di progetto VHDL vengono mostrate le differenze
-- Fra l'uso di variabili e l'uso di segnali all'interno dei processi

entity VHDL_VAR_SIG is
	port
	(
		rst 		: in  BIT;
		clk			: in  BIT;
	
		num_var		: out integer range 0 to 255 := 0;
		num_sig		: out integer range 0 to 255 := 0;
		sum_var		: out integer range 0 to 255 := 0;
		sum_sig		: out integer range 0 to 255 := 0
	);
end VHDL_VAR_SIG;


architecture VHDL_VAR_SIG of VHDL_VAR_SIG is

	signal num_tmp : integer RANGE 0 to 255 := 0;
	signal sum_tmp : integer RANGE 0 to 255 := 0;

begin

-- Nel seguente processo vengono effettuate le stesse operazioni del successivo
-- In questo caso però facendo uso di soli variabili e non di segnali

	Prova_Variabili : process(rst, clk) is 

		variable num : integer RANGE 0 to 255 := 0;
		variable sum : integer RANGE 0 to 255 := 0;

	begin
		if (rst = '1') then
			num := 0;
			sum := 0;
		elsif (clk'event and clk = '1') then
			num := num + 1;
			sum := sum + num;
		end if;

		num_var <= num;
		sum_var <= sum;

	end process; 


-- Nel seguente processo vengono effettuate le stesse operazioni del precedente
-- In questo caso però facendo uso di soli segnali e non variabili

	Prova_Segnali : process(rst, clk) is 

	begin 
		if (rst = '1') then
			num_tmp <= 0;
			sum_tmp <= 0;
		elsif (clk'event and clk = '1') then
			num_tmp <= num_tmp + 1;
			sum_tmp <= sum_tmp + num_tmp;
		end if;

		num_sig <= num_tmp;
		sum_sig <= sum_tmp;

	end process; 
	
end VHDL_VAR_SIG;

