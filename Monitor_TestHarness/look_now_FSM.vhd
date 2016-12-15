library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity look_now_FSM is
	port (
	
	clk: in std_logic;
	reset: in std_logic;
	trigger: in std_logic;
	output: out std_logic);
	
end look_now_FSM;


architecture internal of look_now_FSM is


		type state_type is (IDLE, SET);
		signal scur, snex: state_type;
		signal counter: std_logic_vector(2 downto 0);
		--signal counter2: std_logic_vector(3 downto 0); 
		--SIGNAL counter : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0'); --counter output



begin 

process(clk, reset)
	begin
		if(reset = '1') then
			scur <= IDLE;
		elsif(clk'event and clk = '0') then
			scur<= snex;
			if(scur = IDLE) then
				output <= '0';
				counter <= (others => '0');
			--counter <= (others => '0');
			elsif( scur <= SET) then
				output <= '1';
				--counter2 <= (others => '0');
--				counter <= (others => '0');
--			elsif (scur <= IDLE1) then
--				output <= '0';
--				counter <= counter+1;
--			else
--				--counter2 <= counter2+1;
--				output <= '0';
--			--	counter <= (others => '0');
			end if;
		end if;
end process;

process(scur)
	begin
		case scur is
			when IDLE =>
				if(trigger = '1') then
					snex <= SET;
				else
					snex <= IDLE;
				end if;
--			when IDLE1 =>
--				if(counter = 4) then
--					snex <= SET;
--				else 
--					snex <= IDLE1;
--				end if;
			when SET =>
				if(trigger = '1') then
					snex <= SET;
				else
					snex <= IDLE;
				end if;
--			when DELAY =>
--				if(counter2 = 10) then
--					snex <= IDLE;
--				else 
--					snex <= DELAY;
--				end if; 
		end case;
end process;
	
	
end internal;