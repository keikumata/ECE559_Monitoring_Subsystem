-- RX/TX Simulator

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;



entity Monitor_Tester is
	port(
				sys_clock_in:	in std_logic;
				reset_sig_in:	in std_logic;
				test_trigger:  in std_logic;
				latency_select: in std_logic_vector(5 downto 0); 
				
				
				
	--			RX_ctrl_blockin: in std_logic_vector(23 downto 0); -- Tie these two input signals together on the 
	--			TX_ctrl_blockin: in std_logic_vector(23 downto 0);
				
				debug: out std_logic_vector(23 downto 0);

				
				RX_look_now: 	out std_logic;
				TX_look_now:	out std_logic;
				
				RX_ctrl_blockout: out std_logic_vector(23 downto 0);
				TX_ctrl_blockout: out std_logic_vector(23 downto 0);
				
				RX_frame_validity: out std_logic;
				TX_frame_discard: out std_logic
				
			);
end Monitor_Tester;

architecture internal of Monitor_Tester is

	signal clk, aclr: std_logic;
	signal debounce_result: std_logic;
	signal RCVROM_ADDR_IN: std_logic_vector(11 downto 0);
	signal XMTROM_ADDR_IN: std_logic_vector(11 downto 0);
	signal RCVROM_read_enable: std_logic;
	signal XMTROM_read_enable: std_logic;
	signal XMT_ROM_Trigger: std_logic;
	signal RX_look_now_wire: std_logic;
	signal TX_look_now_wire: std_logic;

	
component debounce is
	port(
	 clk     : IN  STD_LOGIC;  --input clock
    button  : IN  STD_LOGIC;  --input signal to be debounced
    result  : OUT STD_LOGIC); --debounced signal
end component; 

component Test_Frames IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		rden		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	);
END component;


component ROM_ADDR_GEN_tx is 
	port(
	
		clk: in std_logic;
		enable_count: in std_logic;
		reset: in std_logic;
		read_enable: out std_logic;
		ROM_ADDR: out std_logic_vector(11 downto 0));
		
end component;

component ROM_ADDR_GEN_rx is 
	port(
	
		clk: in std_logic;
		enable_count: in std_logic;
		reset: in std_logic;
		read_enable: out std_logic;
		ROM_ADDR: out std_logic_vector(11 downto 0));
		
end component;

component XMT_Counter is
	port(
		
		clk: in std_logic;
		enable_count: in std_logic;
		reset: in std_logic;
		latency_select: in std_logic_vector(5 downto 0); 
		ADDR_enable: out std_logic);

end component; 

component look_now_FSM_tx is
	port (
	
	clk: in std_logic;
	reset: in std_logic;
	trigger: in std_logic;
	output: out std_logic);
	
end component;

component look_now_FSM_rx is
	port (
	
	clk: in std_logic;
	reset: in std_logic;
	trigger: in std_logic;
	output: out std_logic);
	
end component;


begin

trigger_debounce : debounce port map(

	 clk    => sys_clock_in,
    button  => test_trigger,
    result  => debounce_result
); 

RCVROM_Test_Frame : Test_Frames port map(
	
		address => RCVROM_ADDR_IN,
		clock		=> sys_clock_in,
		rden		=> RCVROM_read_enable,
		q		=> RX_ctrl_blockout
	);

RCVROM_ADDR_GENERATOR : ROM_ADDR_GEN_rx port map(

		clk => sys_clock_in,
		enable_count => debounce_result,
		reset => reset_sig_in,
		read_enable => RCVROM_read_enable,
		ROM_ADDR => RCVROM_ADDR_IN

);


-- want to be able to generate:  2.5 (16), 5 (17), 10 (18), 20 (19) , 40 (20), 80 (21) ms latency frames
XMT_LatencyCounter : XMT_Counter port map(

	clk => sys_clock_in,
	enable_count => debounce_result,
	reset => reset_sig_in,
	latency_select => latency_select,
	ADDR_Enable => XMT_ROM_Trigger

);

XMTROM_ADDR_GENERATOR : ROM_ADDR_GEN_tx port map(

		clk => sys_clock_in,
		enable_count => XMT_ROM_Trigger,
		reset => reset_sig_in,
		read_enable => XMTROM_read_enable,
		ROM_ADDR => XMTROM_ADDR_IN

);

XMTROM_Test_Frame : Test_Frames port map(
	
		address => XMTROM_ADDR_IN,
		clock		=> sys_clock_in,
		rden		=> XMTROM_read_enable,
		q		=> TX_ctrl_blockout
	);
	
RCV_Look_Now : look_now_FSM_rx port map(

	clk => sys_clock_in,
	reset => reset_sig_in,
	trigger => RCVROM_read_enable,
	output => RX_look_now_wire

	);
	
XMT_Look_Now : look_now_FSM_tx port map(

	clk => sys_clock_in,
	reset => reset_sig_in,
	trigger => XMTROM_read_enable,
	output => TX_look_now_wire

	);


	--latency_selectwire <= latency_select;
	

	--debug <= RCVROM_read_enable;
	
	RX_frame_validity <= '1';
	RX_look_now <= RX_look_now_wire; 
	
	TX_frame_discard <= '0';
	TX_look_now <= TX_look_now_wire;
	
	debug(23 downto 12) <= RCVROM_ADDR_IN(11 downto 0);
	debug(11 downto 0) <= XMTROM_ADDR_IN(11 downto 0);
--	sys_clock_out <= sys_clock_in;
	
end internal;
				