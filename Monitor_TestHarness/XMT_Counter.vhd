library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity XMT_Counter is 
	GENERIC(
    counter_size  :  INTEGER := 12);
	port(
	
		clk: in std_logic;
		enable_count: in std_logic;
		reset: in std_logic;
		latency_select: in std_logic_vector(5 downto 0); 
		ADDR_enable: out std_logic);
		
		
end XMT_Counter;

architecture internal of XMT_Counter is

	type state_type is (IDLE0, SET, OVRFLW);
		signal scur, snex: state_type;
	
	signal internal_clk: std_logic;
	signal counter_flag: std_logic;
	SIGNAL counter : STD_LOGIC_VECTOR(counter_size DOWNTO 0) := (OTHERS => '0'); --counter output
	signal actual_latency: std_logic_vector(counter_size downto 0); --full vector for controlling the number of cycles


begin 
	 internal_clk <= clk;
	-- rst <= reset when (SEL = '0') else '1';

	 
--ROM_Addr generator FSM 
	 
process(reset, internal_clk)
	begin
		if(reset = '1') then
			scur <= IDLE0;
			
		elsif(internal_clk'event and internal_clk = '1') then
			scur <= snex;
			if(scur = IDLE0) then
				counter <= (others => '0');
				ADDR_enable <= '0';
			elsif(scur = SET) then
				ADDR_enable <= '0';
				counter <= counter + 1; 
			elsif(scur = OVRFLW) then
				ADDR_enable <= '1';
				counter <= (others => '0');
			end if;
		end if;
end process;

process(scur)
	begin
		case scur is
			when IDLE0 =>
				if(enable_count = '0') then
					snex <= IDLE0;
				else
					snex <= SET;
				end if;
			when SET =>
				if(counter = latency_select-3) then
				-- 3 is for tester, actual_latency
					snex <= OVRFLW;
				else
					snex <= SET; 
				end if;
			when OVRFLW =>
				snex <= IDLE0;
			end case;
end process;
--
actual_latency(counter_size downto counter_size-5) <= latency_select(5 downto 0);
actual_latency(counter_Size-6 downto 0) <= (others => '0');

end internal; 
		
		