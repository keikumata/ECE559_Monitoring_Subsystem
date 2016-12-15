library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_misc.all;

entity ROM_ADDR_GEN_rx is 
	GENERIC(
    counter_size  :  INTEGER := 11);
	port(
	
		clk: in std_logic;
		enable_count: in std_logic;
		reset: in std_logic;
		read_enable: out std_logic;
		ROM_ADDR: out std_logic_vector(11 downto 0));
		
end ROM_ADDR_GEN_rx;

architecture internal of ROM_ADDR_GEN_rx is

	type state_type is (IDLE0, IDLE1, SET, GEN, DELAY);
		signal scur, snex: state_type;

	signal internal_clk: std_logic;
	signal counter_flag: std_logic;
	SIGNAL counter : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0'); --counter output
	signal counter2: std_logic_vector(3 downto 0);


begin 
	 internal_clk <= clk;
	-- rst <= reset when (SEL = '0') else '1';

	 
--ROM_Addr generator FSM 
	 
process(reset, internal_clk)
	begin
		if(reset = '1') then
			scur <= IDLE0;
			--SEL <= '1';
		elsif(internal_clk'event and internal_clk = '0') then
			scur <= snex;
			if(scur = GEN) then
				counter <= counter +1;
				read_enable <= '1';
				counter2 <= (others => '0');
			elsif(scur = IDLE0) then
				counter <= (others => '0');
				read_enable <= '0';
			elsif(scur = SET) then
				counter2 <= (others=>'0');
				counter <= (others=> '0');
				read_enable <= '1';
			elsif(scur = DELAY) then
				counter2 <= counter2 +1;
			else
				counter <= (others => '0');
				read_enable <= '0';
			end if;
		end if;
end process;

process(scur)
	begin
		case scur is
			when IDLE0 =>
			
				if(enable_count = '0') then
					snex <= IDLE1;
				
				else
					snex <= IDLE0;
					
				end if;
			when IDLE1 =>
		
				if(enable_count = '1') then
					snex <= SET;
				
				else 
					snex <= IDLE1;
				
				end if;
			when SET =>
				snex <= GEN;
			when GEN =>
				if(and_reduce(counter) = '1') then -- controls what address is counted to
				--if(counter = 30) then
				--and_reduce(counter) = '1'
					--snex <= IDLE0; -- change this to Delay if you want to have a specific address asserted for a given amount of time
					snex<=SET;
				else
					snex <= DELAY;
				end if;
			when	DELAY =>
				if (counter2 = 3) then
					snex <= GEN;
				else 
					snex <= DELAY;
				end if;
		end case;
end process;
					
			


	ROM_ADDR <= counter;

end internal; 
		
		