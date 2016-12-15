module mainVGA
	(
		////////////////////	Clock Input	 	////////////////////	 
		//CLOCK_27,						//	27 MHz
		write_CLK,						//	50 MHz
		////////////////////	VGA		////////////////////////////
		VGA_CLK_in,   						//	VGA Clock
		oHS,							//	VGA H_SYNC
		oVS,							//	VGA V_SYNC
		r_data,   						//	VGA Red[9:0]
		g_data,	 						//	VGA Green[9:0]
		b_data,  						//	VGA Blue[9:0]
		resetn,
		avg_latency,
		avg_frame_length,
		frames_full,
		frames_invalid,
		high_priority_pct
	);

////////////////////////	Clock Input	 	////////////////////////
input			   write_CLK;				//	50 MHz
input 			VGA_CLK_in;				// 50 MHz
input 			resetn;
input [9:0] avg_latency;
input [9:0] avg_frame_length;
input [9:0] frames_full;
input [9:0] frames_invalid;
input [9:0] high_priority_pct;
////////////////////////	VGA			////////////////////////////
output			oHS;					//	VGA H_SYNC
output			oVS;					//	VGA V_SYNC
output	[3:0]	r_data;   				//	VGA Red[9:0]
output	[3:0]	g_data;	 				//	VGA Green[9:0]
output	[3:0]	b_data;   				//	VGA Blue[9:0]

wire			clock;
wire	[11:0] vga_conv_addr;
wire 	[15:0] vga_conv_data;
wire oBLANK_n;

wire writeInMain;
reg[9:0] writeAddressMain;
reg[15:0] input_data;
assign writeInMain = 1'b1;
//assign writeAddressMain = 10'b0000100111;
//assign input_data = 16'b0000000000000001;
reg[31:0] counterToFiftyMil;
reg[2:0] statsCounter;
reg[1:0] addingExtraDigits;
reg busyExtraDigits;
reg[9:0] avg_latency_test;
reg[9:0] avg_frame_length_test;
reg[9:0] frames_full_test;
reg[9:0] frames_invalid_test;
reg[9:0] high_priority_pct_test;
reg[5:0] counterForDivision;

//
initial begin
		input_data <= 16'b1111111111111111;
		counterToFiftyMil <= 0;
		writeAddressMain <= 10'b0000000000;
		statsCounter <= 0;
		addingExtraDigits<=0;
//		busyExtraDigits<=0;
//		avg_latency_test<=0;
//		avg_frame_length_test<=5;
//		frames_full_test<=10;
//		frames_invalid_test<=15;
//		high_priority_pct_test<=20;
//		counterForDivision<=0;
end
////
//////////////////// main RAM logic ////////////////////////////
////
always@(negedge write_CLK) begin
	if(statsCounter == 0) begin
		if(avg_latency<10) begin
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0010110101;
				input_data<=avg_latency;
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0010110100;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0010110011;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end else if(avg_latency>=10 & avg_latency<100) begin
		
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0010110101;
				input_data<=avg_latency % 10;
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0010110100;
				input_data<=avg_latency / 10;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0010110011;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end 
		else begin
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0010110101;
				if(avg_latency % 100 >= 10) begin
					input_data<=(avg_latency % 100) % 10;
				end else begin
					input_data<=avg_latency % 100;
				end
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0010110100;
				input_data<=(avg_latency / 10)%10;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0010110011;
				input_data<=avg_latency/100;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end
	end
	
	// avg_frame_length     --units digit is 245
	else if(statsCounter == 1) begin
		if(avg_frame_length<10) begin
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0011110101;
				input_data<=avg_frame_length;
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0011110100;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0011110011;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end else if(avg_frame_length>=10 & avg_frame_length<100) begin
		
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0011110101;
				input_data<=avg_frame_length % 10;
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0011110100;
				input_data<=avg_frame_length / 10;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0011110011;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end 
		else begin
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0011110101;
				if(avg_frame_length % 100 >= 10) begin
					input_data<=(avg_frame_length % 100) % 10;
				end else begin
					input_data<=avg_frame_length % 100;
				end
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0011110100;
				input_data<=(avg_frame_length / 10)%10;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0011110011;
				input_data<=avg_frame_length/100;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end
	end
	
	// high_priority_pct    --units digit is 309
	else if(statsCounter == 2) begin
		if(high_priority_pct<10) begin
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0100110101;
				input_data<=high_priority_pct;
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0100110100;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0100110011;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end else if(high_priority_pct>=10 & high_priority_pct<100) begin
		
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0100110101;
				input_data<=high_priority_pct % 10;
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0100110100;
				input_data<=high_priority_pct / 10;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0100110011;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end 
		else begin
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0100110101;
				if(high_priority_pct % 100 >= 10) begin
					input_data<=(high_priority_pct % 100) % 10;
				end else begin
					input_data<=high_priority_pct % 100;
				end
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0100110100;
				input_data<=(high_priority_pct / 10)%10;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0100110011;
				input_data<=high_priority_pct/100;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end
	end
	
	
	// frames_invalid       --units digit is 373
	else if(statsCounter == 3) begin
		if(frames_invalid<10) begin
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0101110101;
				input_data<=frames_invalid;
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0101110100;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0101110011;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end else if(frames_invalid>=10 & frames_invalid<100) begin
		
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0101110101;
				input_data<=frames_invalid % 10;
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0101110100;
				input_data<=frames_invalid / 10;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0101110011;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end 
		else begin
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0101110101;
				if(frames_invalid % 100 >= 10) begin
					input_data<=(frames_invalid % 100) % 10;
				end else begin
					input_data<=frames_invalid % 100;
				end
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0101110100;
				input_data<=(frames_invalid / 10)%10;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0101110011;
				input_data<=frames_invalid/100;
				addingExtraDigits <= 0;
				statsCounter <= statsCounter + 1;
			end
		end
	end
	
	// frames_full          --units digit is 437
	else if(statsCounter == 4) begin
		if(frames_full<10) begin
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0110110101;
				input_data<=frames_full;
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0110110100;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0110110011;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 0;
				statsCounter <= 0;
			end
		end else if(frames_full>=10 & frames_full<100) begin
		
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0110110101;
				input_data<=frames_full % 10;
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0110110100;
				input_data<=frames_full / 10;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0110110011;
				input_data<=16'b0000000000000000;
				addingExtraDigits <= 0;
				statsCounter <= 0;
			end
		end 
		else begin
			if(addingExtraDigits == 0) begin
				writeAddressMain<= 10'b0110110101;
				if(frames_full % 100 >= 10) begin
					input_data<=(frames_full % 100) % 10;
				end else begin
					input_data<=frames_full % 100;
				end
				addingExtraDigits <= 1;
			end else if(addingExtraDigits==1) begin
				writeAddressMain<= 10'b0110110100;
				input_data<=(frames_full / 10)%10;
				addingExtraDigits <= 2;
			end else if(addingExtraDigits==2) begin
				writeAddressMain<= 10'b0110110011;
				input_data<=frames_full/100;
				addingExtraDigits <= 0;
				statsCounter <= 0;
			end
		end
	end

// THIS IS WHAT I HAD BEFORE
	// write logic here 
	// avg_latency   --units digit is 181
	
//	if(statsCounter == 0) begin
//		if(avg_latency<10) begin
//			writeAddressMain<= 10'b0010110101;
//			input_data<=avg_latency;
//			statsCounter <= statsCounter + 1;
//		end else if(avg_latency>=10 & avg_latency<100) begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0010110101;
//				input_data<=avg_latency % 10;
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0010110100;
//				input_data<=avg_latency / 10;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end 
//		else begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0010110101;
//				if(avg_latency % 100 >= 10) begin
//					input_data<=(avg_latency % 100) % 10;
//				end else begin
//					input_data<=avg_latency % 100;
//				end
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0010110100;
//				input_data<=(avg_latency / 10)%10;
//				addingExtraDigits <= 2;
//			end else if(addingExtraDigits==2) begin
//				writeAddressMain<= 10'b0010110011;
//				input_data<=avg_latency/100;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end
//	end
//	
//	
//	// avg_frame_length     --units digit is 245
//	else if(statsCounter == 1) begin
//		if(avg_frame_length<10) begin
//			writeAddressMain<= 10'b0011110101;
//			input_data<=avg_frame_length;
//			statsCounter <= statsCounter + 1;
//		end else if(avg_frame_length>=10 & avg_frame_length<100) begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0011110101;
//				input_data<=avg_frame_length % 10;
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0011110100;
//				input_data<=avg_frame_length / 10;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end else begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0011110101;
//				if(avg_frame_length % 100 >= 10) begin
//					input_data<=(avg_frame_length % 100) % 10;
//				end else begin
//					input_data<=avg_frame_length % 100;
//				end
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0011110100;
//				input_data<=(avg_frame_length / 10)%10;
//				addingExtraDigits <= 2;
//			end else if(addingExtraDigits==2) begin
//				writeAddressMain<= 10'b0011110011;
//				input_data<=avg_frame_length/100;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end
//	end
//	
//	// high_priority_pct    --units digit is 309
//	else if(statsCounter == 2) begin
//		if(high_priority_pct<10) begin
//			writeAddressMain<= 10'b0100110101;
//			input_data<=high_priority_pct;
//			statsCounter <= statsCounter + 1;
//		end else if(high_priority_pct>=10 & high_priority_pct<100) begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0100110101;
//				input_data<=high_priority_pct % 10;
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0100110100;
//				input_data<=high_priority_pct / 10;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end else begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0100110101;
//				if(high_priority_pct % 100 >= 10) begin
//					input_data<=(high_priority_pct % 100) % 10;
//				end else begin
//					input_data<=high_priority_pct % 100;
//				end
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0100110100;
//				input_data<=(high_priority_pct / 10)%10;
//				addingExtraDigits <= 2;
//			end else if(addingExtraDigits==2) begin
//				writeAddressMain<= 10'b0100110011;
//				input_data<=high_priority_pct/100;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end
//	end
//	
//	// frames_invalid       --units digit is 373
//	else if(statsCounter == 3) begin
//		if(frames_invalid<10) begin
//			writeAddressMain<= 10'b0101110101;
//			input_data<=frames_invalid;
//			statsCounter <= statsCounter + 1;
//		end else if(frames_invalid>=10 & frames_invalid<100) begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0101110101;
//				input_data<=frames_invalid % 10;
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0101110100;
//				input_data<=frames_invalid / 10;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end else begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0101110101;
//				if(frames_invalid % 100 >= 10) begin
//					input_data<=(frames_invalid % 100) % 10;
//				end else begin
//					input_data<=frames_invalid % 100;
//				end
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0101110100;
//				input_data<=(frames_invalid / 10)%10;
//				addingExtraDigits <= 2;
//			end else if(addingExtraDigits==2) begin
//				writeAddressMain<= 10'b0101110011;
//				input_data<=frames_invalid/100;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end
//	end
//	
//	// frames_full          --units digit is 437
//	else if(statsCounter == 4) begin
//		if(frames_full<10) begin
//			writeAddressMain<= 10'b0110110101;
//			input_data<=frames_full;
//			statsCounter <= 0;
//		end else if(frames_full>=10 & frames_full<100) begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0110110101;
//				input_data<=frames_full % 10;
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0110110100;
//				input_data<=frames_full / 10;
//				addingExtraDigits <= 0;
//				statsCounter <= 0;
//			end
//		end else begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0110110101;
//				if(frames_full % 100 >= 10) begin
//					input_data<=(frames_full % 100) % 10;
//				end else begin
//					input_data<=frames_full % 100;
//				end
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0110110100;
//				input_data<=(frames_full / 10)%10;
//				addingExtraDigits <= 2;
//			end else if(addingExtraDigits==2) begin
//				writeAddressMain<= 10'b0110110011;
//				input_data<=frames_full/100;
//				addingExtraDigits <= 0;
//				statsCounter <= 0;
//			end
//		end
//	end	
//	// avg_latency_test   --units digit is 181
//	if(statsCounter == 0) begin
//		if(avg_latency_test<10) begin
//			writeAddressMain<= 10'b0010110101;
//			input_data<=avg_latency_test;
//			statsCounter <= statsCounter + 1;
//		end else if(avg_latency_test>=10 & avg_latency_test<100) begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0010110101;
//				input_data<=avg_latency_test % 10;
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0010110100;
//				input_data<=avg_latency_test / 10;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end 
//		else begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0010110101;
//				if(avg_latency_test % 100 >= 10) begin
//					input_data<=(avg_latency_test % 100) % 10;
//				end else begin
//					input_data<=avg_latency_test % 100;
//				end
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0010110100;
//				input_data<=(avg_latency_test / 10)%10;
//				addingExtraDigits <= 2;
//			end else if(addingExtraDigits==2) begin
//				writeAddressMain<= 10'b0010110011;
//				input_data<=avg_latency_test/100;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end
//	end
//	
//	
//	// avg_frame_length_test     --units digit is 245
//	else if(statsCounter == 1) begin
//		if(avg_frame_length_test<10) begin
//			writeAddressMain<= 10'b0011110101;
//			input_data<=avg_frame_length_test;
//			statsCounter <= statsCounter + 1;
//		end else if(avg_frame_length_test>=10 & avg_frame_length_test<100) begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0011110101;
//				input_data<=avg_frame_length_test % 10;
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0011110100;
//				input_data<=avg_frame_length_test / 10;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end else begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0011110101;
//				if(avg_frame_length_test % 100 >= 10) begin
//					input_data<=(avg_frame_length_test % 100) % 10;
//				end else begin
//					input_data<=avg_frame_length_test % 100;
//				end
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0011110100;
//				input_data<=(avg_frame_length_test / 10)%10;
//				addingExtraDigits <= 2;
//			end else if(addingExtraDigits==2) begin
//				writeAddressMain<= 10'b0011110011;
//				input_data<=avg_frame_length_test/100;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end
//	end
//	
//	// high_priority_pct    --units digit is 309
//	else if(statsCounter == 2) begin
//		if(high_priority_pct_test<10) begin
//			writeAddressMain<= 10'b0100110101;
//			input_data<=high_priority_pct_test;
//			statsCounter <= statsCounter + 1;
//		end else if(high_priority_pct_test>=10 & high_priority_pct_test<100) begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0100110101;
//				input_data<=high_priority_pct_test % 10;
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0100110100;
//				input_data<=high_priority_pct_test / 10;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end else begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0100110101;
//				if(high_priority_pct_test % 100 >= 10) begin
//					input_data<=(high_priority_pct_test % 100) % 10;
//				end else begin
//					input_data<=high_priority_pct_test % 100;
//				end
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0100110100;
//				input_data<=(high_priority_pct_test / 10)%10;
//				addingExtraDigits <= 2;
//			end else if(addingExtraDigits==2) begin
//				writeAddressMain<= 10'b0100110011;
//				input_data<=high_priority_pct_test/100;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end
//	end
//	
//	// frames_invalid_test       --units digit is 373
//	else if(statsCounter == 3) begin
//		if(frames_invalid_test<10) begin
//			writeAddressMain<= 10'b0101110101;
//			input_data<=frames_invalid_test;
//			statsCounter <= statsCounter + 1;
//		end else if(frames_invalid_test>=10 & frames_invalid_test<100) begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0101110101;
//				input_data<=frames_invalid_test % 10;
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0101110100;
//				input_data<=frames_invalid_test / 10;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end else begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0101110101;
//				if(frames_invalid_test % 100 >= 10) begin
//					input_data<=(frames_invalid_test % 100) % 10;
//				end else begin
//					input_data<=frames_invalid_test % 100;
//				end
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0101110100;
//				input_data<=(frames_invalid_test / 10)%10;
//				addingExtraDigits <= 2;
//			end else if(addingExtraDigits==2) begin
//				writeAddressMain<= 10'b0101110011;
//				input_data<=frames_invalid_test/100;
//				addingExtraDigits <= 0;
//				statsCounter <= statsCounter + 1;
//			end
//		end
//	end
//	
//	// frames_full_test          --units digit is 437
//	else if(statsCounter == 4) begin
//		if(frames_full_test<10) begin
//			writeAddressMain<= 10'b0110110101;
//			input_data<=frames_full_test;
//			statsCounter <= 0;
//		end else if(frames_full_test>=10 & frames_full_test<100) begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0110110101;
//				input_data<=frames_full_test % 10;
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0110110100;
//				input_data<=frames_full_test / 10;
//				addingExtraDigits <= 0;
//				statsCounter <= 0;
//			end
//		end else begin
//			if(addingExtraDigits == 0) begin
//				writeAddressMain<= 10'b0110110101;
//				if(frames_full_test % 100 >= 10) begin
//					input_data<=(frames_full_test % 100) % 10;
//				end else begin
//					input_data<=frames_full_test % 100;
//				end
//				addingExtraDigits <= 1;
//			end else if(addingExtraDigits==1) begin
//				writeAddressMain<= 10'b0110110100;
//				input_data<=(frames_full_test / 10)%10;
//				addingExtraDigits <= 2;
//			end else if(addingExtraDigits==2) begin
//				writeAddressMain<= 10'b0110110011;
//				input_data<=frames_full_test/100;
//				addingExtraDigits <= 0;
//				statsCounter <= 0;
//			end
//		end
//	end	
	
//	if(counterToFiftyMil == 50000000) begin
//		//input_data <= input_data << 1;
//		//writeAddressMain <= 10'b0010110000;
//		avg_latency_test <= avg_latency_test + 1;
//		avg_frame_length_test<=avg_frame_length_test+1;
//		frames_full_test<=frames_full_test+1;
//		frames_invalid_test<=frames_invalid_test+1;
//		high_priority_pct_test<=high_priority_pct_test+1;
//		counterToFiftyMil <= 0;
//	end else begin
//		counterToFiftyMil <= counterToFiftyMil + 1;
//	end
end

///////////////////////////////////////////////////////////

wire antiWriteCLK;
assign antiWriteCLK = ~write_CLK;

numberRAM main_RAM(
		.wrclock(write_CLK),
		.rdclock(antiWriteCLK),
		.data(input_data),
		.rdaddress(vga_conv_addr),
		.wraddress(writeAddressMain),
		.wren(writeInMain),
		.q(vga_conv_data)
		);
		
vga_controller_test controller(.iRST_n(resetn),
							 .write_CLK(write_CLK),
							 .VGA_CLK_in(VGA_CLK_in),
							 .write_address(write_address),
							 .data(value_to_vga),
                      .oBLANK_n(oBLANK_n),
                      .oHS(oHS),
                      .oVS(oVS),
                      .b_data(b_data),
                      .g_data(g_data),
                      .r_data(r_data));			
							

wire new_index;
dmem_addr_controller dmemaddrcontroller(write_CLK, vga_conv_addr, new_index);


reg [4:0] row, col;

always@(posedge write_CLK) begin
	row<=(vga_conv_addr)/32; 
	col<=(vga_conv_addr)%32;
end

wire value_to_vga_0, value_to_vga_1, value_to_vga_2, value_to_vga_3, value_to_vga_4, value_to_vga_5;
wire value_to_vga_6, value_to_vga_7, value_to_vga_8, value_to_vga_9;
wire[18:0] write_address_0, write_address_1, write_address_2, write_address_3, write_address_4, write_address_5;
wire[18:0] write_address_6, write_address_7, write_address_8, write_address_9;

reg[18:0] write_address;
reg value_to_vga;
// creating all the modules for drawing here
index_to_pixels_converter_0 zero(
		.rows(row), 
		.cols(col), 
		.value_to_vga(value_to_vga_0), 
		.new_index(new_index), 
		.clock(write_CLK), 
		.write_address(write_address_0)
	);
index_to_pixels_converter_1 one(
		.rows(row), 
		.cols(col), 
		.value_to_vga(value_to_vga_1), 
		.new_index(new_index), 
		.clock(write_CLK), 
		.write_address(write_address_1)
	);
index_to_pixels_converter_2 two(
		.rows(row), 
		.cols(col), 
		.value_to_vga(value_to_vga_2), 
		.new_index(new_index), 
		.clock(write_CLK), 
		.write_address(write_address_2)
	);
index_to_pixels_converter_3 three(
		.rows(row), 
		.cols(col), 
		.value_to_vga(value_to_vga_3), 
		.new_index(new_index), 
		.clock(write_CLK), 
		.write_address(write_address_3)
	);
index_to_pixels_converter_4 four(
		.rows(row), 
		.cols(col), 
		.value_to_vga(value_to_vga_4), 
		.new_index(new_index), 
		.clock(write_CLK), 
		.write_address(write_address_4)
	);
index_to_pixels_converter_5 five(
		.rows(row), 
		.cols(col), 
		.value_to_vga(value_to_vga_5), 
		.new_index(new_index), 
		.clock(write_CLK), 
		.write_address(write_address_5)
	);
index_to_pixels_converter_6 six(
		.rows(row), 
		.cols(col), 
		.value_to_vga(value_to_vga_6), 
		.new_index(new_index), 
		.clock(write_CLK), 
		.write_address(write_address_6)
	);
index_to_pixels_converter_7 seven(
		.rows(row), 
		.cols(col), 
		.value_to_vga(value_to_vga_7), 
		.new_index(new_index), 
		.clock(write_CLK), 
		.write_address(write_address_7)
	);
index_to_pixels_converter_8 eight(
		.rows(row), 
		.cols(col), 
		.value_to_vga(value_to_vga_8), 
		.new_index(new_index), 
		.clock(write_CLK), 
		.write_address(write_address_8)
	);
index_to_pixels_converter_9 nine(
		.rows(row), 
		.cols(col), 
		.value_to_vga(value_to_vga_9), 
		.new_index(new_index), 
		.clock(write_CLK), 
		.write_address(write_address_9)
	);

always@(posedge write_CLK) begin
	if(vga_conv_data==0) begin
		write_address<=write_address_0;
		value_to_vga<=value_to_vga_0;
	end else if(vga_conv_data==1) begin
		write_address<=write_address_1;
		value_to_vga<=value_to_vga_1;
	end else if(vga_conv_data==2) begin
		write_address<=write_address_2;
		value_to_vga<=value_to_vga_2;
	end else if(vga_conv_data==3) begin
		write_address<=write_address_3;
		value_to_vga<=value_to_vga_3;
	end else if(vga_conv_data==4) begin
		write_address<=write_address_4;
		value_to_vga<=value_to_vga_4;
	end else if(vga_conv_data==5) begin
		write_address<=write_address_5;
		value_to_vga<=value_to_vga_5;
	end else if(vga_conv_data==6) begin
		write_address<=write_address_6;
		value_to_vga<=value_to_vga_6;
	end else if(vga_conv_data==7) begin
		write_address<=write_address_7;
		value_to_vga<=value_to_vga_7;
	end else if(vga_conv_data==8) begin
		write_address<=write_address_8;
		value_to_vga<=value_to_vga_8;
	end else if(vga_conv_data==9) begin
		write_address<=write_address_9;
		value_to_vga<=value_to_vga_9;
	end 
	
end
endmodule

module dmem_addr_controller(clock, dmem_addr, new_index);	
	input clock;
	output reg [11:0] dmem_addr;
	output reg new_index;	
	reg[8:0] count;
	initial begin
		count = 0;
		dmem_addr = 0;
		new_index = 0;
	end
	// counting to 400 and then incrementing the dmem_addr up from 0 -> 767
	// this is because it takes 400 clock ticks to write one block (20 by 20)
	always@(posedge clock) begin
		if(count < 400) begin
			count <= count + 1; // keeping track of which index 
			new_index = 0;
		end else if(dmem_addr < 768) begin
			count <= 0;
			dmem_addr <= dmem_addr + 1;
			new_index = 1;
		end else begin
			count <= 0;
			dmem_addr <= 0;
			new_index = 1;
		end
	end
endmodule

module index_to_pixels_converter_1(rows, cols, value_to_vga, new_index, clock, write_address);
	input[4:0] rows, cols;
	input clock, new_index;
	output reg value_to_vga;
	output reg [18:0] write_address;
	reg[4:0] i,j;
	
	initial begin
			i = 0;
			j = 0;
	end
	always@(posedge clock or posedge new_index) begin
		if(new_index == 1'b1) begin
			i <= 0;
			j <= 0;
		end else if (j<19) begin
			j <= j+1;
		end else if (i<20) begin
			j <= 0;
			i <= i+1;
		end
		write_address<=640*20*rows + 640*i + 20*cols + j;
	end
	always@(posedge clock) begin
		if(i==2 & j>9 & j<11) begin
			value_to_vga <= 1;
		end else if(i==3 & j>8 & j<11) begin
			value_to_vga <= 1;
		end else if(i==4 & j>7 & j<11) begin
			value_to_vga <= 1;
		end else if(i==5 & j>6 & j<11) begin
			value_to_vga <= 1;
		end else if(i==6 & ((j>6 & j<8) |(j>8 & j<11))) begin
			value_to_vga <= 1;
		end else if(i==7 & j>9 & j<11) begin
			value_to_vga <= 1;
		end else if(i==8 & j>9 & j<11) begin
			value_to_vga <= 1;
		end else if(i==9 & j>9 & j<11) begin
			value_to_vga <= 1;
		end else if(i==10 & j>9 & j<11) begin
			value_to_vga <= 1;
		end else if(i==11 & j>9 & j<11) begin
			value_to_vga <= 1;
		end else if(i==12 & j>9 & j<11)begin
			value_to_vga <= 1;
		end else if(i==13 & j>9 & j<11) begin
			value_to_vga <= 1;
		end else if(i==14 & j>9 & j<11) begin
			value_to_vga <= 1;
		end else if(i==15 & j>9 & j<11) begin
			value_to_vga <= 1;
		end else if(i==16 & j>6 & j<14) begin
			value_to_vga <= 1;
		end else if(i==17 & j>6 & j<14) begin
			value_to_vga <= 1;
		end else begin
			value_to_vga <= 0;
		end
	end
endmodule

module index_to_pixels_converter_0(rows, cols, value_to_vga, new_index, clock, write_address);
	input[4:0] rows, cols;
	input clock, new_index;
	output reg value_to_vga;
	output reg [18:0] write_address;
	reg[4:0] i,j;
	
	initial begin
			i = 0;
			j = 0;
	end
	always@(posedge clock or posedge new_index) begin
		if(new_index == 1'b1) begin
			i <= 0;
			j <= 0;
		end else if (j<19) begin
			j <= j+1;
		end else if (i<20) begin
			j <= 0;
			i <= i+1;
		end
		write_address<=640*20*rows + 640*i + 20*cols + j;
	end
	always@(posedge clock) begin
		if(i==2 & j>7 & j<12) begin
			value_to_vga <= 1;
		end else if(i==3 & ((j>6 & j<8) |(j>11 & j<13))) begin
			value_to_vga <= 1;
		end else if(i==4 & ((j>5 & j<7) |(j>12 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==5 & ((j>4 & j<6) |(j>13 & j<15))) begin
			value_to_vga <= 1;
		end else if(i==6 & ((j>4 & j<6) |(j>13 & j<15))) begin
			value_to_vga <= 1;
		end else if(i==7 & ((j>4 & j<6) |(j>13 & j<15))) begin
			value_to_vga <= 1;
		end else if(i==8 & ((j>4 & j<6) |(j>13 & j<15))) begin
			value_to_vga <= 1;
		end else if(i==9 & ((j>4 & j<6) |(j>13 & j<15))) begin
			value_to_vga <= 1;
		end else if(i==10 & ((j>4 & j<6) |(j>13 & j<15))) begin
			value_to_vga <= 1;
		end else if(i==11 & ((j>4 & j<6) |(j>13 & j<15))) begin
			value_to_vga <= 1;
		end else if(i==12 & ((j>4 & j<6) |(j>13 & j<15)))begin
			value_to_vga <= 1;
		end else if(i==13 & ((j>4 & j<6) |(j>13 & j<15))) begin
			value_to_vga <= 1;
		end else if(i==14 & ((j>4 & j<6) |(j>13 & j<15))) begin
			value_to_vga <= 1;
		end else if(i==15 & ((j>5 & j<7) |(j>12 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==16 & ((j>6 & j<8) |(j>11 & j<13))) begin
			value_to_vga <= 1;
		end else if(i==17 & j>7 & j<12) begin
			value_to_vga <= 1;
		end else begin
			value_to_vga <= 0;
		end
	end
endmodule

module index_to_pixels_converter_2(rows, cols, value_to_vga, new_index, clock, write_address, color);
	input[4:0] rows, cols;
	input clock, new_index;
	input[2:0] color;
	output reg  value_to_vga;
	output reg [18:0] write_address;
	reg[4:0] i,j;
	
	initial begin
			i = 0;
			j = 0;
	end
	always@(posedge clock or posedge new_index) begin
		if(new_index == 1'b1) begin
			i <= 0;
			j <= 0;
		end else if (j<19) begin
			j <= j+1;
		end else if (i<20) begin
			j <= 0;
			i <= i+1;
		end
		write_address<=640*20*rows + 640*i + 20*cols + j;
	end
	always@(posedge clock) begin
		if(i==2 & j>8 & j<12) begin
			value_to_vga <= 1;
		end else if(i==3 & j>7 & j<13) begin
			value_to_vga <= 1;
		end else if(i==4 & j>6 & j<14) begin
			value_to_vga <= 1;
		end else if(i==5 & ((j>5 & j<9) |(j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==6 & ((j>5 & j<8) |(j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==7 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==8 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==9 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==10 & j>10 & j<14) begin
			value_to_vga <= 1;
		end else if(i==11 & j>9 & j<13) begin
			value_to_vga <= 1;
		end else if(i==12 & j>8 & j<11)begin
			value_to_vga <= 1;
		end else if(i==13 & j>7 & j<10) begin
			value_to_vga <= 1;
		end else if(i==14 & j>6 & j<9) begin
			value_to_vga <= 1;
		end else if(i==15 & j>5 & j<8) begin
			value_to_vga <= 1;
		end else if(i==16 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else if(i==17 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else begin
			value_to_vga <= 0;
		end
	end
endmodule

module index_to_pixels_converter_3(rows, cols, value_to_vga, new_index, clock, write_address, color);
	input[4:0] rows, cols;
	input clock, new_index;
	input[2:0] color;
	output reg  value_to_vga;
	output reg [18:0] write_address;
	reg[4:0] i,j;
	
	initial begin
			i = 0;
			j = 0;
	end
	always@(posedge clock or posedge new_index) begin
		if(new_index == 1'b1) begin
			i <= 0;
			j <= 0;
		end else if (j<19) begin
			j <= j+1;
		end else if (i<20) begin
			j <= 0;
			i <= i+1;
		end
		write_address<=640*20*rows + 640*i + 20*cols + j;
	end
	always@(posedge clock) begin
		if(i==2 & j>8 & j<12) begin
			value_to_vga <= 1;
		end else if(i==3 & j>7 & j<13) begin
			value_to_vga <= 1;
		end else if(i==4 & ((j>6 & j<8) |(j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==5 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==6 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==7 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==8 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==9 & j>8 & j<14) begin
			value_to_vga <= 1;
		end else if(i==10 & j>8 & j<14) begin
			value_to_vga <= 1;
		end else if(i==11 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==12 & j>11 & j<14)begin
			value_to_vga <= 1;
		end else if(i==13 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==14 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==15 & ((j>6 & j<8) |(j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==16 & j>7 & j<13) begin
			value_to_vga <= 1;
		end else if(i==17 & j>8 & j<12) begin
			value_to_vga <= 1;
		end else begin
			value_to_vga <= 0;
		end
	end
endmodule

module index_to_pixels_converter_4(rows, cols, value_to_vga, new_index, clock, write_address, color);
	input[4:0] rows, cols;
	input clock, new_index;
	input[2:0] color;
	output reg value_to_vga;
	output reg [18:0] write_address;
	reg[4:0] i,j;
	
	initial begin
			i = 0;
			j = 0;
	end
	always@(posedge clock or posedge new_index) begin
		if(new_index == 1'b1) begin
			i <= 0;
			j <= 0;
		end else if (j<19) begin
			j <= j+1;
		end else if (i<20) begin
			j <= 0;
			i <= i+1;
		end
		write_address<=640*20*rows + 640*i + 20*cols + j;
	end
	always@(posedge clock) begin
		if(i==2 & ((j>6 & j<9) |(j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==3 & ((j>6 & j<9) |(j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==4 & ((j>6 & j<9) |(j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==5 & ((j>6 & j<9) |(j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==6 & ((j>6 & j<9) |(j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==7 & ((j>6 & j<9) |(j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==8 & ((j>6 & j<9) |(j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==9 & j>6 & j<14) begin
			value_to_vga <= 1;
		end else if(i==10 & j>6 & j<14) begin
			value_to_vga <= 1;
		end else if(i==11 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==12 & j>11 & j<14)begin
			value_to_vga <= 1;
		end else if(i==13 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==14 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==15 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==16 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==17 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else begin
			value_to_vga <= 0;
		end
	end
endmodule

module index_to_pixels_converter_5(rows, cols, value_to_vga, new_index, clock, write_address, color);
	input[4:0] rows, cols;
	input clock, new_index;
	input[2:0] color;
	output reg value_to_vga;
	output reg [18:0] write_address;
	reg[4:0] i,j;
	
	initial begin
			i = 0;
			j = 0;
	end
	always@(posedge clock or posedge new_index) begin
		if(new_index == 1'b1) begin
			i <= 0;
			j <= 0;
		end else if (j<19) begin
			j <= j+1;
		end else if (i<20) begin
			j <= 0;
			i <= i+1;
		end
		write_address<=640*20*rows + 640*i + 20*cols + j;
	end
	always@(posedge clock) begin
		if(i==2 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else if(i==3 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else if(i==4 & j>5 & j<8) begin
			value_to_vga <= 1;
		end else if(i==5 & j>5 & j<8) begin
			value_to_vga <= 1;
		end else if(i==6 & j>5 & j<8) begin
			value_to_vga <= 1;
		end else if(i==7 & j>5 & j<8) begin
			value_to_vga <= 1;
		end else if(i==8 & j>5 & j<8) begin
			value_to_vga <= 1;
		end else if(i==9 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else if(i==10 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else if(i==11 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==12 & j>11 & j<14)begin
			value_to_vga <= 1;
		end else if(i==13 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==14 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==15 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==16 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else if(i==17 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else begin
			value_to_vga <= 0;
		end
	end
endmodule

module index_to_pixels_converter_6(rows, cols, value_to_vga, new_index, clock, write_address, color);
	input[4:0] rows, cols;
	input clock, new_index;
	input[2:0] color;
	output reg value_to_vga;
	output reg [18:0] write_address;
	reg[4:0] i,j;
	
	initial begin
			i = 0;
			j = 0;
	end
	always@(posedge clock or posedge new_index) begin
		if(new_index == 1'b1) begin
			i <= 0;
			j <= 0;
		end else if (j<19) begin
			j <= j+1;
		end else if (i<20) begin
			j <= 0;
			i <= i+1;
		end
		write_address<=640*20*rows + 640*i + 20*cols + j;
	end
	always@(posedge clock) begin
		if(i==2 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else if(i==3 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else if(i==4 & j>5 & j<8) begin
			value_to_vga <= 1;
		end else if(i==5 & j>5 & j<8) begin
			value_to_vga <= 1;
		end else if(i==6 & j>5 & j<8) begin
			value_to_vga <= 1;
		end else if(i==7 & j>5 & j<8) begin
			value_to_vga <= 1;
		end else if(i==8 & j>5 & j<8) begin
			value_to_vga <= 1;
		end else if(i==9 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else if(i==10 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else if(i==11 & ((j>5 & j<8) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==12 & ((j>5 & j<8) | (j>11 & j<14)))begin
			value_to_vga <= 1;
		end else if(i==13 & ((j>5 & j<8) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==14 & ((j>5 & j<8) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==15 & ((j>5 & j<8) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==16 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else if(i==17 & j>5 & j<14) begin
			value_to_vga <= 1;
		end else begin
			value_to_vga <= 0;
		end
	end
endmodule

module index_to_pixels_converter_7(rows, cols, value_to_vga, new_index, clock, write_address, color);
	input[4:0] rows, cols;
	input clock, new_index;
	input[2:0] color;
	output reg value_to_vga;
	output reg [18:0] write_address;
	reg[4:0] i,j;
	
	initial begin
			i = 0;
			j = 0;
	end
	always@(posedge clock or posedge new_index) begin
		if(new_index == 1'b1) begin
			i <= 0;
			j <= 0;
		end else if (j<19) begin
			j <= j+1;
		end else if (i<20) begin
			j <= 0;
			i <= i+1;
		end
		write_address<=640*20*rows + 640*i + 20*cols + j;
	end
	always@(posedge clock) begin
		if(i==2 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==3 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==4 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==5 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==6 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==7 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==8 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==9 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==10 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==11 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==12 & j>11 & j<14)begin
			value_to_vga <= 1;
		end else if(i==13 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==14 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==15 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==16 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==17 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else begin
			value_to_vga <= 0;
		end
	end
endmodule

module index_to_pixels_converter_8(rows, cols, value_to_vga, new_index, clock, write_address, color);
	input[4:0] rows, cols;
	input clock, new_index;
	input[2:0] color;
	output reg value_to_vga;
	output reg [18:0] write_address;
	reg[4:0] i,j;
	
	initial begin
			i = 0;
			j = 0;
	end
	always@(posedge clock or posedge new_index) begin
		if(new_index == 1'b1) begin
			i <= 0;
			j <= 0;
		end else if (j<19) begin
			j <= j+1;
		end else if (i<20) begin
			j <= 0;
			i <= i+1;
		end
		write_address<=640*20*rows + 640*i + 20*cols + j;
	end
	always@(posedge clock) begin
		if(i==2 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==3 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==4 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==5 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==6 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==7 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==8 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==9 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==10 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==11 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==12 & ((j>4 & j<7) | (j>11 & j<14)))begin
			value_to_vga <= 1;
		end else if(i==13 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==14 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==15 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==16 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==17 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else begin
			value_to_vga <= 0;
		end
	end
endmodule

module index_to_pixels_converter_9(rows, cols, value_to_vga, new_index, clock, write_address, color);
	input[4:0] rows, cols;
	input clock, new_index;
	input[2:0] color;
	output reg value_to_vga;
	output reg [18:0] write_address;
	reg[4:0] i,j;
	
	initial begin
			i = 0;
			j = 0;
	end
	always@(posedge clock or posedge new_index) begin
		if(new_index == 1'b1) begin
			i <= 0;
			j <= 0;
		end else if (j<19) begin
			j <= j+1;
		end else if (i<20) begin
			j <= 0;
			i <= i+1;
		end
		write_address<=640*20*rows + 640*i + 20*cols + j;
	end
	always@(posedge clock) begin
		if(i==2 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==3 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==4 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==5 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==6 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==7 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==8 & ((j>4 & j<7) | (j>11 & j<14))) begin
			value_to_vga <= 1;
		end else if(i==9 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==10 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==11 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==12 & j>11 & j<14)begin
			value_to_vga <= 1;
		end else if(i==13 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==14 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==15 & j>11 & j<14) begin
			value_to_vga <= 1;
		end else if(i==16 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else if(i==17 & j>4 & j<14) begin
			value_to_vga <= 1;
		end else begin
			value_to_vga <= 0;
		end
	end
endmodule
