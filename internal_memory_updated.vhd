LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY final_project_monitoring IS
	PORT (Clock					: IN STD_LOGIC;
			Reset					: IN STD_LOGIC;
			frame_number_rcv 	: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
			frame_number_xmt  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
			frameLength			: IN STD_LOGIC_VECTOR(11 DOWNTO 0);

			--signals from receive
			look_now_rcv		: IN STD_LOGIC;
			validity_in			: IN STD_LOGIC;
			
			-- signals from fwd
			look_now_fwd		: IN STD_LOGIC;
			tagged_in			: IN STD_LOGIC;
			priority_in			: IN STD_LOGIC;
			
			--signals from xmt
			look_now_xmt		: IN STD_LOGIC;
			full_buff_in		: IN STD_LOGIC;
			
			-- temporary buffers / outputs
			numer: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			denom: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			quotient: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			numOfValidFramesOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0):= "00000000000000000000000000000000";
			timeData: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			numOfCyclesOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			sumOfLatenciesOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000000000";
			sumOfFrameLengthsOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			totalFramesOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			numOfHighPriorityOut: buffer STD_LOGIC_VECTOR(15 DOWNTO 0);
			
			--true outputs
			total_average: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			frameLengthAverage: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			totalFullOut:	buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			totalInvalidOut: buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
			percentageHighPriority: buffer STD_LOGIC_VECTOR(31 DOWNTO 0)
			--percentageHighPriorityOut: buffer STD_LOGIC_VECTOR(63 DOWNTO 0)
			);
END final_project_monitoring;

ARCHITECTURE mem OF final_project_monitoring IS
	
	COMPONENT lpm_div IS
		PORT(	denom			: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
				numer			: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
				quotient		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
				);
	END COMPONENT;
	
	COMPONENT lpm_div_32 IS
		PORT(denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				quotient	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
				);
	END COMPONENT;

	COMPONENT reg32 IS 
		PORT(Clk_sig	: IN STD_LOGIC;
			  Reset		: IN STD_LOGIC;
			  D_sig		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			  Q 			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			  );
	END COMPONENT;
	 
	COMPONENT reg16 is
		PORT(Clk_sig	: in std_logic;
			Reset			: in std_logic;
			D_sig 		: in std_logic_vector(15 DOWNTO 0);
			Q 				: out std_logic_vector(15 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT monitoring_ram IS
		PORT(clock			: IN STD_LOGIC;
				data			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				rdaddress	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				wraddress	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				wren			: IN STD_LOGIC;
				q				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
				);
	END COMPONENT;
	
	-------------------------Internal timer--------------------------------------
	signal numOfCycles : STD_LOGIC_VECTOR(31 DOWNTO 0); -- 16 bits (what Derby said)
	--signal numOfCyclesOut : STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16 bits
	--signal timeData: STD_LOGIC_VECTOR(15 DOWNTO 0); 
	signal timeDataOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	-------------------------Counts of Types of Frames------------------------------
  	signal numOfInvalid : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal numOfInvalidOut : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal numOfFull: STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal numOfFullOut: STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal numOfLowPriority: STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal numOfLowPriorityOut: STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal numOfHighPriority: STD_LOGIC_VECTOR(15 DOWNTO 0);
	--signal numOfHighPriorityOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	------------------------------Latency--------------------------------------------
	signal numOfValidFrames: STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000000000";
	--signal numOfValidFramesOut: STD_LOGIC_VECTOR(31 DOWNTO 0); 
	signal sumOfLatencies: STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000000000";
	--signal sumOfLatenciesOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	--signal denom: STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal denomOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
	--signal numer: STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal numerOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
	--signal quotient: STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	----------------------------------Other Stats------------------------------------
	
	signal sumOfFrameLengths: STD_LOGIC_VECTOR(31 DOWNTO 0);
	--signal sumOfFrameLengthsOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
	--signal frameLengthExtended: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal frameLengthExtendedOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal totalFull: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal totalInvalid: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal totalFrames: STD_LOGIC_VECTOR(31 DOWNTO 0);
	--signal totalFramesOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	
	-- writeNow is to write (1) in the RAM at receive, and read (0) at transmit / forwarding
	signal writeNow: STD_LOGIC;
	
	
	-- later on uncomment all the buffers --> signals!!!!!!!!!!!!
	
	--signal tag: array1;
	--signal priority: array1;
	------------------DONE signal full: array1;
	-------------DONT THINK WE NEED THIS ANYMORE signal used: array1;
	
	
	-------------------------------------------------------------------------						
						
BEGIN
	 
	counter_inst_lpmdiv: lpm_div_32 PORT MAP(
					numer => numer, 
					denom => denom, 
					quotient => quotient
					);
					
	counter_inst_lpmdiv_32: lpm_div_32 PORT MAP(
					numer => sumOfLatenciesOut, 
					denom => numOfValidFramesOut,
					quotient => total_average
					);
					
	counter_inst_lpmdiv_frameLength: lpm_div_32 PORT MAP(
					numer => sumOfFrameLengthsOut,
					--denom => numOfValidFramesOut,
					denom => STD_LOGIC_VECTOR(unsigned(numOfValidFramesOut)), 

					quotient => frameLengthAverage
					);
	
	mem_ram: monitoring_ram PORT MAP(
					clock => Clock, 
					data => numOfCyclesOut, 
					rdaddress => frame_number_xmt, 
					wraddress => frame_number_rcv,
					wren => writeNow, 
					q => timeData
					);
					
	counter_inst_highPriority: lpm_div_32 PORT MAP(
					numer => std_logic_vector(resize(unsigned(numOfHighPriorityOut)*100, 32)), 
					denom => totalFramesOut, 
					quotient => percentageHighPriority
					);
					
					--percentageHighPriorityOut <= std_logic_vector(unsigned(percentageHighPriority) * 100);



	PROCESS (Clock,Reset) -- state register update
		BEGIN
		IF (Reset = '1') THEN 
			-- TODO
		ELSIF (Clock'event) AND (Clock = '1') THEN
			numOfCycles <= std_logic_vector(unsigned(numOfCyclesOut) + 1);
			IF((unsigned(numOfCyclesOut)) = 50000000) THEN -- when it goes to 2^16-1
				numOfCycles <= (others=>'0');
			END IF;
		END IF;
	END PROCESS;
	
	reg_numCycles: reg32 PORT MAP(
					Reset => not Reset,
					Clk_sig => not Clock,
					D_sig => numOfCycles,
					Q => numOfCyclesOut
					);
	
	reg_timeData: reg32 PORT MAP(
					Reset => not Reset,
					Clk_sig => not Clock,
					D_sig => timeData,
					Q => timeDataOut
					);	
					
	reg_num: reg32 PORT MAP(
					Reset => not Reset,
					Clk_sig => not Clock,
					D_sig => numer,
					Q => numerOut
					);
					
	reg_denom: reg32 PORT MAP(
					Reset => not Reset,
					Clk_sig => not Clock,
					D_sig => denom,
					Q => denomOut
					);
						
	reg_numOfFull: reg16 PORT MAP( 
					Reset => not Reset,
					Clk_sig => not Clock,
					D_sig => numOfFull,
					Q => numOfFullOut
					);
	
	reg_numOfValidFrames: reg32 PORT MAP( 
					Clk_sig => not Clock,
					Reset => not Reset,
					D_sig => numOfValidFrames,
					Q => numOfValidFramesOut
					);
						
			  
	reg_sumOfLatencies: reg32 PORT MAP( 	
					Clk_sig => not Clock,
					Reset => not Reset,
					D_sig => sumOfLatencies,
					Q => sumOfLatenciesOut
					);
					
	reg_sumOfFrameLengths: reg32 PORT MAP(
					clk_sig => not Clock,
					Reset => not Reset,
					D_sig => sumOfFrameLengths,
					Q => sumOfFrameLengthsOut
					);
					
--	reg_frameLengths: reg32 PORT MAP(
--					clk_sig => not Clock,
--					Reset => not Reset,
--					D_sig => "00000000000000000000" & frameLength,
--					Q => frameLengthExtendedOut
--					);
					
	reg_full: reg32 PORT MAP(
					Reset => not Reset,
					Clk_sig => not Clock,
					D_sig => totalFull,
					Q => totalFullOut
					);
					
	reg_invalid: reg32 PORT MAP(
					Reset => not Reset,
					Clk_sig => not Clock,
					D_sig => totalInvalid,
					Q => totalInvalidOut
					);
					
	reg_totalFrames: reg32 PORT MAP(
					Reset => not Reset,
					Clk_sig => not Clock,
					D_sig => totalFrames,
					Q => totalFramesOut
					);
					
	reg_highPriority: reg16 PORT MAP(
					Reset => not Reset,
					Clk_sig => not Clock,
					D_sig => numOfHighPriority,
					Q => numOfHighPriorityOut
					);
					
	PROCESS(look_now_rcv)
		BEGIN
		IF(look_now_rcv = '1') THEN
			writeNow <= '1';
			totalFrames <= std_logic_vector(unsigned(totalFramesOut) + 1);
		ELSE
			writeNow <= '0';
			totalFrames <= totalFramesOut;
		END IF;
	END PROCESS;

--————————————————————————————————RECEIVE——————————————————————————————————————

	PROCESS (look_now_rcv, validity_in)
		BEGIN
			IF (look_now_rcv = '1' and validity_in = '1') THEN
				totalInvalid <= totalInvalidOut;
			ELSIF (look_now_rcv = '1' and validity_in = '0') THEN
				totalInvalid <= std_logic_vector(unsigned(totalInvalidOut) + to_unsigned(1, 32));
			ELSE
				totalInvalid <= totalInvalidOut;
			END IF;
	END PROCESS;
	
--————————————————————————————————FORWARD——————————————————————————————————————
	PROCESS (look_now_fwd, priority_in)
		BEGIN
		IF (look_now_fwd = '1' and priority_in = '1') THEN
			numOfHighPriority <= std_logic_vector(unsigned(numOfHighPriorityOut) + to_unsigned(1, 16));
		ELSE
			numOfHighPriority <= numOfHighPriorityOut;
		END IF;
	END PROCESS;
	
	
--		-- counting the number of discarded frames from TX
--	PROCESS (full_buff_in)
--		BEGIN
--		IF (full_buff_in = '1') THEN 
--			totalFull <= std_logic_vector(unsigned(totalFullOut) + to_unsigned(1, 32));
--		ELSE 
--			totalFull <= totalFullOut;
--		END IF;
--	END PROCESS;
--	
--	--assuming we are counting valid frames during transmit
--	PROCESS (look_now_xmt, frameLength, numOfValidFramesOut, numerOut, denomOut, quotient, sumOfLatenciesOut, full_buff_in , timeDataOut, numOfCyclesOut, timeData, sumOfFrameLengthsOut)  -- when look now then create / update table
--		BEGIN 
--		IF (look_now_xmt = '1') THEN
--			IF(unsigned(numOfCyclesOut) < unsigned(timeData)) THEN
--				numer <= std_logic_vector(unsigned(50000000 - (unsigned(timeDataOut) - unsigned(numOfCyclesOut))));
--			ELSE
--				numer <= std_logic_vector(unsigned(numOfCyclesOut) - unsigned(timeDataOut));
--			END IF;
--			denom <= std_logic_vector(to_unsigned(50, 32));
--			--numOfFull <= numOfFullOut;
--			numOfValidFrames <= std_logic_vector(unsigned(numOfValidFramesOut) + to_unsigned(1, 32));
--			sumOfLatencies <= std_logic_vector(unsigned(sumOfLatenciesOut) + unsigned(quotient));
--			sumOfFrameLengths <= std_logic_vector(unsigned(sumOfFrameLengthsOut) + unsigned("00000000000000000000" & frameLength));
--			--sumOfFrameLengths <= std_logic_vector(unsigned(sumOfFrameLengthsOut) + 1);
--			--totalFull <= totalFullOut;
--			
--		ELSE 
--			numer <= numerOut;
--			denom <= denomOut;
--			--numOfFull <= numOfFullOut;
--			numOfValidFrames <= numOfValidFramesOut;
--			sumOfLatencies <= sumOfLatenciesOut;
--			sumOfFrameLengths <= sumOfFrameLengthsOut;
--			--totalFull <= totalFullOut;
--		END IF;
--	END PROCESS;
--	
 --————————————————————————————————TRANSMIT——————————————————————————————————————
	--assuming we are counting valid frames during transmit
	PROCESS (look_now_xmt, total_average, frameLength, numOfValidFramesOut, numerOut, denomOut, quotient, sumOfLatenciesOut, full_buff_in , timeDataOut, numOfCyclesOut, timeData, sumOfFrameLengthsOut)  -- when look now then create / update table
		BEGIN 
		IF (look_now_xmt = '1' and full_buff_in = '0') THEN
			IF(unsigned(numOfCyclesOut) < unsigned(timeData)) THEN
				numer <= std_logic_vector(unsigned(50000000 - (unsigned(timeDataOut) - unsigned(numOfCyclesOut))));
				IF((unsigned(sumOfLatenciesOut)) > 40000000) THEN -- when it goes to 2^16-1
					sumOfLatencies <= total_average;
					numOfValidFrames <= std_logic_vector(to_unsigned(1,32));
					sumOfFrameLengths <= frameLengthAverage;
				ELSE
					sumOfLatencies <= std_logic_vector(unsigned(sumOfLatenciesOut) + unsigned(50000000 - (unsigned(timeDataOut) - unsigned(numOfCyclesOut))));
					numOfValidFrames <= std_logic_vector(unsigned(numOfValidFramesOut) + to_unsigned(1, 32));
					sumOfFrameLengths <= std_logic_vector(unsigned(sumOfFrameLengthsOut) + unsigned("00000000000000000000" & frameLength));
				END IF;
			ELSE
				numer <= std_logic_vector(unsigned(numOfCyclesOut) - unsigned(timeDataOut));
				IF((unsigned(sumOfLatenciesOut)) > 40000000) THEN -- when it goes to 2^16-1
					sumOfLatencies <= total_average;
					numOfValidFrames <= std_logic_vector(to_unsigned(1,32));
					sumOfFrameLengths <= frameLengthAverage;
				ELSE
					sumOfLatencies <= std_logic_vector(unsigned(sumOfLatenciesOut) + unsigned(numOfCyclesOut) - unsigned(timeDataOut));
					numOfValidFrames <= std_logic_vector(unsigned(numOfValidFramesOut) + to_unsigned(1, 32));
					sumOfFrameLengths <= std_logic_vector(unsigned(sumOfFrameLengthsOut) + unsigned("00000000000000000000" & frameLength));
				END IF;
			END IF;
			denom <= std_logic_vector(to_unsigned(50, 32));
			numOfFull <= numOfFullOut;
			
			--sumOfLatencies <= std_logic_vector(unsigned(sumOfLatenciesOut) + unsigned(quotient));
			--sumOfFrameLengths <= std_logic_vector(unsigned(sumOfFrameLengthsOut) + 1);
			totalFull <= totalFullOut;
			
		ELSIF (look_now_xmt = '1' and full_buff_in = '1') THEN
			numer <= numerOut;
			denom <= denomOut;
			numOfFull <= std_logic_vector(unsigned(numOfFullOut) + 1);
			numOfValidFrames <= numOfValidFramesOut;
			sumOfLatencies <= sumOfLatenciesOut;
			sumOfFrameLengths <= sumOfFrameLengthsOut;
			totalFull <= std_logic_vector(unsigned(totalFullOut) + to_unsigned(1, 32));
			
		ELSE 
			numer <= numerOut;
			denom <= denomOut;
			numOfFull <= numOfFullOut;
			numOfValidFrames <= numOfValidFramesOut;
			sumOfLatencies <= sumOfLatenciesOut;
			sumOfFrameLengths <= sumOfFrameLengthsOut;
			totalFull <= totalFullOut;
		END IF;
	END PROCESS;	
END mem;
