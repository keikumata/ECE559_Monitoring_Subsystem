-- Monitoring Top-Level Module
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


-- Entity declaration for the top level of the monitoring system
entity MonitoringSys is
	port(	
				sys_clock: 					in std_logic; -- Pin M9
				reset_sig:					in std_logic;
				
				--Receive System Signals
--				rx_look_now: 				in std_logic; --Receive system trigger signal to latch frame control block and validity across interface
--				rx_frame_validity:		in std_logic; --Receive system frame validity signal
--				rx_frame_id:				in std_logic_vector(23 downto 0); -- Frame control block signal bits {23,22 receive port id, 23-12 frame sequence ID, 11-0 frame length)
				--rx_frame_t:					out std_logic_vector(23 downto 0);
				--rx_fifo_usedw:				out std_logic_vector(23 downto 0);
				
				--Transmit System Signals
--				tx_look_now:				in std_logic; -- Transmit system trigger signal to latch information acrosss interface
--				tx_discard:					in std_logic; -- inputs from discard_transmit signal 
--				tx_frame_id:				in std_logic_vector(23 downto 0);	-- frame id from transmit system, called control_block on transmit side, 25 bits because validity is appended at front 
				--tx_fifo_usedw:				out std_logic_vector(23 downto 0);

				--Testing System Signals
				test_look_now:				in std_logic; -- Testing system trigger signal
				test_result_correct:		in std_logic;	-- testing system signals
				
				--Forwarding System Signals
				fwd_priority_sig: 		in std_logic; --forwarding 
				fwd_tagged_sig:			in std_logic;
				fwd_look_now:				in	std_logic; --inputs from forwarding system
				fwd_frame_id:				in std_logic_vector(23 downto 0); --Forwarding System Frame ID, 25 bit number {23, validity, 23-12 frame sequence ID, 11-0 frame length
				
				--Table System Signals
				--table_num_misses:			in std_logic_vector(7 downto 0);	-- number of misses from table system
				--table_num_accesses:		in std_logic_vector(7 downto 0);	-- number of accesses from table system
				--table_fullness:				in std_logic_vector(7 downto 0); -- how much the table has been filled
				
				--Acknowledgement Signals
--				rx_ack, tx_ack, test_ck, fwd_ack, table_ack:	out std_logic; -- acknowledgement signals for each set of input signals
				
				test_trigger:  in std_logic;
				latency_select: in std_logic_vector(5 downto 0); 
				debug : out std_logic_vector(23 downto 0);
				-- Working Stats 
				--avg_latency 		: out std_logic_vector (31 downto 0);
				--rcv_valid_frames 	: out std_logic_vector (31 downto 0);
				--avg_frame_length	: out std_logic_vector(31 downto 0);
				--frames_full			: out std_logic_vector(31 downto 0);
				--frames_invalid		: out std_logic_vector(31 downto 0);
				--high_priority_pct	: out std_logic_vector(31 downto 0);
				
				--frameLengthsTest	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
				--numHighPriorityTest: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				--framesOutTest : out STD_LOGIC_VECTOR(31 DOWNTO 0);
				--pct_out_mult : out std_logic_vector (63 downto 0)
				
				avg_latency : buffer STD_LOGIC_VECTOR(31 downto 0);
				Clock_To_Test : OUT STD_LOGIC;
				-- VGA
				VGA_CLK_in    : IN STD_LOGIC; -- Pin H13
				oHS		: OUT STD_LOGIC; -- Pin H8
				oVS      : OUT STD_LOGIC; -- Pin G8
				b_data		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0); 
				-- b_data[3] = Pin A7, b_data[2] = Pin A8, b_data[1] = Pin B7, b_data[0] = Pin B6
				g_data		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
				-- g_data[3] = Pin J8, g_data[2] = Pin J7, g_data[1] = Pin K7, g_data[0] = Pin L7
				r_data		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
				-- b_data[3] = Pin A5, b_data[2] = Pin C9, b_data[1] = Pin B10, b_data[0] = Pin A9
				
				);
end MonitoringSys;


-- Define internal design of the monitoring system; list components, create instances, and connect everything to ports
architecture monitor_internal of MonitoringSys is 


-- list components to be instantiated inside of the monitoring system


component Monitor_Tester is
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
end component;




component final_project_monitoring is 
port (
			Clock					: IN STD_LOGIC;
			Reset					: IN STD_LOGIC;
			frame_number_rcv 	: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
			frame_number_xmt  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
			frameLength			: IN STD_LOGIC_VECTOR(11 DOWNTO 0);

			--signals from receive
			look_now_rcv	: IN STD_LOGIC;
			validity_in		: IN STD_LOGIC;
			
			-- signals from fwd
			look_now_fwd	: IN STD_LOGIC;
			tagged_in		: IN STD_LOGIC;
			priority_in		: IN STD_LOGIC;
			
			--signals from xmt
			look_now_xmt	: IN STD_LOGIC;
			full_buff_in	: IN STD_LOGIC;
			
			-- temporary buffers / outputs
			numer: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			denom: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			quotient: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			timeData: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			numOfCyclesOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			sumOfLatenciesOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			totalFramesOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			numOfHighPriorityOut: buffer STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			-- true outputs
			numOfValidFramesOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			total_average: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			frameLengthAverage: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			sumOfFrameLengthsOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			
			totalFullOut:	buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			totalInvalidOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			percentageHighPriority: buffer STD_LOGIC_VECTOR(31 DOWNTO 0)
			--percentageHighPriorityOut: buffer STD_LOGIC_VECTOR(63 DOWNTO 0)
			);
end component;

component latch_24bit is
  port (
    din   : in std_logic_vector(23 downto 0);
    reset : in std_logic;
    dout  : out std_logic_vector(23 downto 0);
    en    : in std_logic);

end component;

COMPONENT lpm_shiftreg
	PORT (
			aclr	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			data	: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
			enable	: IN STD_LOGIC ;
			load	: IN STD_LOGIC ;
			q	: OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
	);
	END COMPONENT;

component Receive_Buffer is
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0); -- Made this 25 bit signal so that the validity bit is appended to the main 23bit signal and can travel with it
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_full		: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
end component;


component Transmit_Buffer is
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_full		: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
end component;

-- VGA Component
COMPONENT mainVGA is
	PORT
	(
		write_CLK		: IN STD_LOGIC;
		VGA_CLK_in    : IN STD_LOGIC;
		oHS		: OUT STD_LOGIC;
		oVS      : OUT STD_LOGIC;
		r_data		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		g_data		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		b_data		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		resetn		: IN STD_LOGIC;
		avg_latency : IN STD_LOGIC_VECTOR(9 downto 0);
		avg_frame_length: IN STD_LOGIC_VECTOR(9 downto 0);
		frames_full : IN STD_LOGIC_VECTOR (9 downto 0);
		frames_invalid : IN STD_LOGIC_VECTOR(9 downto 0);
		high_priority_pct : IN STD_LOGIC_VECTOR(9 downto 0)
	);
END COMPONENT;

component Forward_Buffer is
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (23 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_full		: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
end component;

component fiftyToTenPLL is 
         port (
            refclk :  in std_logic;
            rst :  in std_logic;
            outclk_0 :  out std_logic
        );
end component; 

component Reset_Delay is 
         port (
            iCLK :  in std_logic;
            oRESET :  out std_logic
        );
end component; 

	signal clk, aclr : std_logic;
	signal rx_rdreq, rx_wrreq, rx_latch_en : std_logic;
	signal rx_empt, rx_fll, rx_afll : std_logic;
	signal rx_d, rx_q, rx_latch_din	  : std_logic_vector(23 downto 0);
	signal rx_usedw : std_logic_vector(7 downto 0);
	signal rx_to_mem : std_logic_vector(11 downto 0);
	signal rx_to_mem_trigger : std_logic;
	
	signal tx_rdreq, tx_wrreq : std_logic;
	signal tx_empt, tx_fll, tx_afll : std_logic;
	signal tx_d, tx_q	  : std_logic_vector(23 downto 0);
	signal tx_usedw : std_logic_vector(9 downto 0);
	signal tx_from_mem : std_logic_vector(11 downto 0);
	signal tx_to_mem_trigger : std_logic; 
	signal tx_latch_din : std_logic_vector(23 downto 0);
	signal tx_latch_en : std_logic;
	
	-- FSM signal definitions for the rx and tx buffer writing and reading
	
	signal fwd_rdreq, fwd_wrreq : std_logic;
	signal fwd_empt, fwd_fll, fwd_afll : std_logic;
	signal fwd_d, fwd_q	  : std_logic_vector(23 downto 0);
	signal fwd_usedw : std_logic_vector(7 downto 0);
	signal fwd_to_mem_trigger : std_logic; 
	signal fwd_latch_din : std_logic_vector(23 downto 0);
	signal fwd_latch_en : std_logic;
	
	
	type state_type1 is   
			(RX1_IDLE,  RX1_CMD_W);
	type state_type2 is
			(RX2_IDLE, RX2_CMD_R);
	type state_type3 is
			(TX1_IDLE, TX1_CMD_W);
	type state_type4 is
			(TX2_IDLE, TX2_CMD_R);
	type state_type5 is
			(FWD1_IDLE, FWD1_CMD_W);
	type state_type6 is
			(FWD2_IDLE, FWD2_CMD_R);
			
	signal fsm_cur1, fsm_nex1: state_type1;
	signal fsm_cur2, fsm_nex2: state_type2;
	signal fsm_cur3, fsm_nex3: state_type3;
	signal fsm_cur4, fsm_nex4: state_type4;
	signal fsm_cur5, fsm_nex5: state_type5;
	signal fsm_cur6, fsm_nex6: state_type6;
	
	--signal 		writeNowTest:  STD_LOGIC;
	signal 		numerTest:  STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal		denomTest:  STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal		quotientTest:  STD_LOGIC_VECTOR(31 DOWNTO 0);
	--signal		numOfValidFramesOutTest:  STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal		timeDataTest:  STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal		numOfCyclesOutTest:  STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal		sumOfLatenciesOutTest:  STD_LOGIC_VECTOR(31 DOWNTO 0);
	--signal		framesOutTest : STD_LOGIC_VECTOR(31 DOWNTO 0);

   signal frameLengthsTest	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal numHighPriorityTest: STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal framesOutTest : STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal pct_out_mult :  std_logic_vector (63 downto 0);
	
	--signal avg_latency 		: std_logic_vector (31 downto 0);
	signal rcv_valid_frames 	: std_logic_vector (31 downto 0);
	signal avg_frame_length	:  std_logic_vector(31 downto 0);
	signal frames_full			:  std_logic_vector(31 downto 0);
	signal frames_invalid		:  std_logic_vector(31 downto 0);
	signal high_priority_pct	:  std_logic_vector(31 downto 0);
	
	--Signal for the rx and tx test frames
	signal rx_frame_id, tx_frame_id: std_logic_vector(23 downto 0); 
	signal ddummy_wire: std_logic;
	signal rx_frame_validity, tx_discard: std_logic;
	signal rx_look_now, tx_look_now: std_logic;
	
-- TEST ONLY --
	signal tx_frame_id_test : STD_LOGIC_VECTOR(23 downto 0) := "000000000001000000111111";
	signal rx_frame_id_test : STD_LOGIC_VECTOR(23 downto 0) := "000000000001000000111111";
	signal rx_look_now_test : STD_LOGIC;
	signal tx_look_now_test : STD_LOGIC;
	signal counter : unsigned(23 downto 0) := "000000000000000000000000";
	signal counter2: unsigned(23 downto 0) := "000000000000000000000000";
	signal tx_discard_test : STD_LOGIC;
	signal rx_frame_validity_test : STD_LOGIC;
	
begin

-- Create instances of the components 
aclr <= reset_sig;
clk <= sys_clock;
--tx_fifo_usedw <= tx_q;
--rx_fifo_usedw <= rx_q;
	  
	  
Clock_To_Test<= clk;

IMEM : final_project_monitoring port map
(
			Clock	=> clk,
			Reset	=> aclr,
--			frame_number_rcv => rx_q (23 downto 12),
--			frame_number_xmt => tx_q (23 downto 12),
--			frameLength 	  => tx_q (11 downto 0),
			frame_number_rcv => rx_frame_id(23 downto 12),
			frame_number_xmt => tx_frame_id (23 downto 12),
			frameLength 	  => rx_frame_id (11 downto 0),

			--signals from receive
			look_now_rcv => rx_look_now,
			validity_in	 => rx_frame_validity, 
			
			-- signals from fwd
			look_now_fwd => fwd_look_now, 
			tagged_in	=> fwd_tagged_sig, 
			priority_in	=> fwd_priority_sig, 
			
			
			--signals from xmt
			look_now_xmt	=> tx_look_now, 
			full_buff_in	=> tx_discard, 
			
			-- true outputs
			total_average => avg_latency,
			numOfValidFramesOut => rcv_valid_frames,
			frameLengthAverage => avg_frame_length,
			
			totalFullOut => frames_full,
			totalInvalidOut => frames_invalid,
			percentageHighPriority => high_priority_pct,

			-- test outputs
			--writeNow => writeNowTest,
			numer=> numerTest, 
			denom => denomTest, 
			quotient => quotientTest,
			timeData => timeDataTest, 
			numOfCyclesOut => timeDataTest, 
			sumOfLatenciesOut => sumOfLatenciesOutTest,
			sumOfFrameLengthsOut => FrameLengthsTest,
			numOfHighPriorityOut => numHighPriorityTest,
			totalFramesOut => framesOutTest
			--percentageHighPriority => pct_out_mult
			);

RX_buff : Receive_Buffer port map 
	(
		aclr => aclr,
		clock	=>	clk, 
		data	=>	rx_d,
		rdreq	=>	rx_rdreq,
		wrreq	=>	rx_wrreq,
		almost_full	=>	rx_afll,
		empty	=>	rx_empt, 
		full	=>	rx_fll, 
		q	=>	rx_q,
		usedw	=>	rx_usedw
	);
	
TX_buff : Transmit_Buffer port map
	(
		aclr => aclr,
		clock => clk,
		data => tx_d,
		rdreq => tx_rdreq,
		wrreq => tx_wrreq,
		almost_full => tx_afll,
		empty => tx_empt,
		full => tx_fll,
		q => tx_q,
		usedw => tx_usedw
	);
FWD_buff : Forward_Buffer port map
	(
		aclr => aclr,
		clock => clk,
		data => fwd_d,
		rdreq => fwd_rdreq,
		wrreq => fwd_wrreq,
		almost_full => fwd_afll,
		empty => fwd_empt,
		full => fwd_fll,
		q => fwd_q,
		usedw => fwd_usedw
	);
	
RX_Latch : lpm_shiftreg port map
  (
   aclr => aclr,
	clock	=> clk,
	data => rx_latch_din, 
	enable => rx_latch_en, 
	load	=> rx_latch_en,
	q => rx_d
	);
	
TX_Latch : lpm_shiftreg port map
  (
   aclr => aclr,
	clock	=> clk,
	data => tx_latch_din, 
	enable => tx_latch_en, 
	load	=> tx_latch_en,
	q => tx_d
	);
	
FWD_Latch : lpm_shiftreg port map
  (
   aclr => aclr,
	clock	=> clk,
	data => fwd_latch_din, 
	enable => fwd_latch_en, 
	load	=> fwd_latch_en,
	q => fwd_d
	);
	
VGA: mainVGA port map
	(
		write_CLK	=>sys_clock,
		VGA_CLK_in   => VGA_CLK_in,
		oHS		=> oHS,
		oVS      => oVS,
		r_data	=> r_data,
		g_data	=> g_data,
		b_data	=> b_data,
		resetn	=> not reset_sig,
		avg_latency => avg_latency(9 downto 0),
		avg_frame_length => avg_frame_length(9 downto 0),
		frames_full => frames_full(9 downto 0),
		frames_invalid => frames_invalid(9 downto 0),
		high_priority_pct => high_priority_pct(9 downto 0)
	);
	
	
Test_Harness : Monitor_Tester port map(
	
				sys_clock_in => clk,
				reset_sig_in => aclr,
				test_trigger => test_trigger,
				latency_select => latency_select,
				
				
				
	--			RX_ctrl_blockin: in std_logic_vector(23 downto 0); -- Tie these two input signals together on the 
	--			TX_ctrl_blockin: in std_logic_vector(23 downto 0);
				
				debug => debug,

				RX_look_now => rx_look_now,
				TX_look_now => tx_look_now,
				
				RX_ctrl_blockout => rx_frame_id,
				TX_ctrl_blockout =>tx_frame_id,
				
				RX_frame_validity =>rx_frame_validity,
				TX_frame_discard => tx_discard
				
			);

	
	
	
	
	
	
--	
	process(clk) 
	begin
		if(clk'event and clk='1') then		
			if(counter2 = 0 and counter = 0) then
				rx_look_now_test <= '1';
				rx_frame_validity_test<='1';
			elsif(counter2 = 1 and counter = 0) then
				tx_frame_id_test <= "000000000010000000000001";
				rx_frame_id_test <= "000000000010000000000001";
				rx_look_now_test <= '1';
				rx_frame_validity_test<='1';
			else
				rx_look_now_test <= '0';
				rx_frame_validity_test<='1';
				tx_look_now_test <= '0';
				tx_discard_test<='0';
			end if;
			
			
			if(counter = 10) then
				tx_look_now_test <= '1';
				tx_discard_test<='0';
				counter2<="000000000000000000000001";
				counter <= "000000000000000000000000";
			elsif(counter = 20 and counter2 = 1) then
				tx_look_now_test <= '1';
				tx_discard_test<='0';
				counter2<="000000000000000000000010";
			elsif(counter2 = 0 or counter2 = 1) then
				counter<=counter+1;
			end if;
			
--			if(counter=10000010) then
--				counter <= "000000000000000000000000000";
--			end if;
			
			
			
			
		end if;
	end process;
	



end monitor_internal;