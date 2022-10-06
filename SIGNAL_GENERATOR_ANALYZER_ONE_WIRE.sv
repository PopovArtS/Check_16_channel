module SIGNAL_GENERATOR_ANALYZER_ONE_WIRE
(
	input CLK_100MHz,
	
	input  	MUAFR_MISO_P,
	input  	MUAFR_MISO_N,
	input 	enable_generate,	
	input	flag_signal_P,

	output [11: 0] test_cnt_1,
	output [11: 0] test_cnt_0

);
localparam ITERATION = 1004;//105
localparam FORM_IZP_TI = 8'b00001111;
localparam REFRESH = 104; //64

logic [3: 0] prev_MUAFR_MISO_P;
logic [3: 0] prev_MUAFR_MISO_N;
logic flag_write = 0;
//logic [8:0] cnt_analyzer = 0;
/*always @(posedge CLK_100MHz)
begin
	if (enable_generate == 1)
		begin
			if(cnt_analyzer == ITERATION)
				cnt_analyzer <= 0;
			else
				cnt_analyzer <= cnt_analyzer + 1;
		end else
			cnt_analyzer <= 0;
end*/
//wire
//logic [2:0] prev_MUAFR_MISO;
always @(posedge CLK_100MHz)
begin

	/*prev_MUAFR_MISO[7] <= prev_MUAFR_MISO[6];
	prev_MUAFR_MISO[6] <= prev_MUAFR_MISO[5];
	prev_MUAFR_MISO[5] <= prev_MUAFR_MISO[4];
	prev_MUAFR_MISO[4] <= prev_MUAFR_MISO[3];*/
	prev_MUAFR_MISO_P[3] <= prev_MUAFR_MISO_P[2];
	prev_MUAFR_MISO_P[2] <= prev_MUAFR_MISO_P[1];
	prev_MUAFR_MISO_P[1] <= prev_MUAFR_MISO_P[0];
	prev_MUAFR_MISO_P[0] <= MUAFR_MISO_P;
	
	prev_MUAFR_MISO_N[3] <= prev_MUAFR_MISO_N[2];
	prev_MUAFR_MISO_N[2] <= prev_MUAFR_MISO_N[1];
	prev_MUAFR_MISO_N[1] <= prev_MUAFR_MISO_N[0];
	prev_MUAFR_MISO_N[0] <= MUAFR_MISO_N;
end

logic [3: 0] cnt_sbros = 0;
logic [5: 0] cnt_ref = 0;
logic flag_clear = 0;
logic [15: 0] cnt_analyzer = 0;
logic [11: 0] cnt_skew_P = 0;
logic [11: 0] cnt_skew_N = 0;
always @(posedge CLK_100MHz)
begin
	if (enable_generate == 0)
		begin
			if ((~prev_MUAFR_MISO_P[2] & MUAFR_MISO_P) | (prev_MUAFR_MISO_P[2] & ~MUAFR_MISO_P))
				cnt_skew_P <= cnt_skew_P + 1;
			
			if ((~prev_MUAFR_MISO_N[2] & MUAFR_MISO_N) | (prev_MUAFR_MISO_N[2] & ~MUAFR_MISO_N))
				cnt_skew_N <= cnt_skew_N + 1;
		
			if (cnt_analyzer == (ITERATION - 2))
			begin
				cnt_skew_N <= 0;
				cnt_skew_P <= 0;
				test_cnt_1 <= cnt_skew_P;
				test_cnt_0 <= cnt_skew_N;
			end	
			
			if (cnt_analyzer == ITERATION)
				cnt_analyzer <= 0;
			else
				cnt_analyzer <= cnt_analyzer + 1;
		
		end else
		begin
			cnt_skew_P <= 0;
			cnt_skew_N <= 0;
			cnt_analyzer <= 0;		
		
		end
		
		
		
		
		
		/*begin			
			if (flag_clear == 1)
				begin
					if (cnt_sbros == 0) 
						cnt_skew <= 0;
						
					flag_write <= 1;
					cnt_analyzer <= 0;					
				end
				
			if ((flag_write == 0) & (/*(cnt_skew > 5) |*/ /*(cnt_ref == REFRESH - 1)))
				test_cnt <= cnt_skew;
			else
				cnt_ref <= cnt_ref + 1;
				
			if (flag_clear == 0)
				cnt_sbros <= cnt_sbros + 1;
			
			
			flag_clear <= 1;	
		end else
			begin			
				cnt_analyzer <= cnt_analyzer + 1;
				if (cnt_analyzer > ITERATION)
					flag_write <= 0;
				
				if (MUAFR_MISO ==  1) //({prev_MUAFR_MISO, MUAFR_MISO} ==  FORM_IZP_TI)
					cnt_skew <= cnt_skew + 1;
				flag_clear <= 0;
				
			end*/
			
			
		
		
end		

endmodule
