module SIGNAL_GENERATOR_ANALYZER
(
	input CLK_100MHz,
	input CLK_25MHz,
	
	output [15:0] MUAFR_MOSI_P,
	output [15:0] MUAFR_MOSI_N,
	input  logic [15:0] MUAFR_MISO_P,
	input  logic [15:0] MUAFR_MISO_N,
	
	input enable_generate,
	output [15:0] status_wire,
	output [15:0] status_gen
);
//assign status_gen [15: 0] = status_gen_0 [15: 0] & status_gen_1 [15: 0];
assign status_gen [15: 0] = status_gen_P [15: 0] & status_gen_N [15: 0];
assign kz = kz_N & kz_P;

localparam cnt_ETALON_WIRE_min = 48;
localparam cnt_ETALON_WIRE_max = 51;
localparam cnt_ETALON_GEN_min = 20;
localparam cnt_ETALON_GEN_max = 250;
localparam cnt_TRUE_SIGNAL_max = 120;
localparam cnt_TRUE_SIGNAL_min = 50;

assign MUAFR_MOSI_N [15: 0]  = ~ MUAFR_MOSI_P [15: 0];

localparam ITERATION = 102;
localparam FORM_MISO = 4'b1100;
logic [2: 0] prev_flag_signal_P;

//logic [15: 0] status_gen_0;
//logic [15: 0] status_gen_1;
logic [15: 0] status_gen_P;
logic [15: 0] status_gen_N;

logic [7: 0] cnt_kz_signal_P = 0;
logic [7: 0] cnt_kz_signal_N = 0;

logic kz;
logic kz_P;
logic kz_N;
logic [15: 0] fail = 16'hFFFF;
logic [3: 0] j;

logic flag_signal_P = 1;

logic [9: 0] cnt_true_channel [15: 0];
//logic [15: 0] cnt_true_channel [9: 0];
logic [9: 0] cnt_status_true; 

//wire [3: 0] prev_MUAFR_MISO [15: 0];
wire [8:0] test_cnt_1 [15: 0];
wire [8:0] test_cnt_0 [15: 0];
genvar i;
generate
	for (i = 0; i < 16; i = i + 1) 
	begin : generator
		SIGNAL_GENERATOR_ANALYZER_ONE_WIRE signal_generator_analyzer_one_wire
		(
			.CLK_100MHz(CLK_100MHz),
			.enable_generate(enable_generate),
			.MUAFR_MISO_P(MUAFR_MISO_P[i]),
			.MUAFR_MISO_N(MUAFR_MISO_N[i]),
			.test_cnt_1(test_cnt_1[i]),
			.test_cnt_0(test_cnt_0[i])
		);
		
		
	always @(posedge CLK_100MHz)
	if (enable_generate == 0)	
		if ((test_cnt_1 [i] > cnt_ETALON_GEN_min - 1) & (test_cnt_1 [i] < cnt_ETALON_GEN_max + 1))
			status_gen_P [i] <= 1; 
		else
			status_gen_P [i] <= 0;
			
	always @(posedge CLK_100MHz)
	if (enable_generate == 0)
		if ((test_cnt_0 [i] > cnt_ETALON_GEN_min - 1) & (test_cnt_0 [i] < cnt_ETALON_GEN_max + 1))
			status_gen_N [i] <= 1; 
		else
			status_gen_N [i] <= 0;
			
			
	
	end
endgenerate



always @(posedge CLK_100MHz)
begin
	if (enable_generate == 1)
	begin
		if (flag_signal_P == 1)		//генерация выходного сигнала
		begin
			if (prev_flag_signal_P [0] != flag_signal_P)
			begin
				MUAFR_MOSI_P [15: 0] <= 16'h0;
				//MUAFR_MOSI_N [15: 0] <= 16'h0;
			end else
			begin
				MUAFR_MOSI_P [j] <= (enable_generate == 1) ? (/*(flag_signal_P == 1) & */((cnt_status_true  < (ITERATION - 6)) & (cnt_status_true >= 0)) ? 1 : 0) : 1'bz; //CLK_25MHz       1'bz
				//MUAFR_MOSI_N [j] <= (enable_generate == 1) ? (/*(flag_signal_P == 1) & */((cnt_status_true  < (ITERATION - 5)) & (cnt_status_true >= 0)) ? 1 : 0) : 1'bz; //~CLK_25MHz      1'bz
			end
		end	else                                                                                                                                      
		begin 
			if (prev_flag_signal_P [0] != flag_signal_P)
			begin
				MUAFR_MOSI_P [15: 0] <= 16'hFFFF;
				//MUAFR_MOSI_N [15: 0] <= 16'hFFFF;
			end else
			begin			
				MUAFR_MOSI_P [j] <= (enable_generate == 1) ? (/*(flag_signal_P == 0) & */((cnt_status_true  < (ITERATION - 6)) & (cnt_status_true >= 0)) ? 0 : 1) : 1'bz; //CLK_25MHz       1'bz
				//MUAFR_MOSI_N [j] <= (enable_generate == 1) ? (/*(flag_signal_P == 0) & */((cnt_status_true  < (ITERATION - 5)) & (cnt_status_true >= 0)) ? 0 : 1) : 1'bz; //~CLK_25MHz      1'bz	
			end
		end
		
		prev_flag_signal_P [2] <= prev_flag_signal_P [1];
		prev_flag_signal_P [1] <= prev_flag_signal_P [0];
		prev_flag_signal_P [0] <= flag_signal_P;
		//prev_flag_signal_P <= flag_signal_P;
				
	
		if (cnt_status_true  == (ITERATION - 3)) //смена канала
		begin
			j <= j + 1;
			cnt_status_true <= 0;
			
			if (j == 15)
				flag_signal_P <= flag_signal_P + 1;
				
			//if (cnt_status_true  == (ITERATION - 4))
			if (fail[j] == 0)
				status_wire [j] <= 1; 
			else
				status_wire [j] <= 0;
			
		end else		
			cnt_status_true <= cnt_status_true + 1;
					
		if ((cnt_status_true  == (ITERATION - 4)) & (flag_signal_P == 0)) //подведение итога
			if ((cnt_true_channel [j] > (ITERATION >> 1)) & (cnt_true_channel [j] < (ITERATION << 1)) & (kz == 1)) //search min 
				fail[j] <= 0;
			else 
				fail[j] <= 1;
		
					
		if ((cnt_status_true  > (ITERATION - 7)) & (flag_signal_P == 0)) //проверка кз на линии Р		
			if (cnt_kz_signal_P > (ITERATION - 15))						
				kz_P <= 1;
			else
				kz_P <= 0;
		
		if ((cnt_status_true  > (ITERATION - 7)) & (flag_signal_P == 0))	//проверка кз на линии N
			if (cnt_kz_signal_N > (ITERATION - 15))						
				kz_N <= 1;
			else
				kz_N <= 0;
					
		if (cnt_status_true  == (ITERATION - 4)) //проверка что на двух каналах одиноковый сигнал
			cnt_true_channel [j] <= 0;
		else	
			if ((MUAFR_MISO_P [j] == flag_signal_P) & (MUAFR_MISO_N [j] != flag_signal_P))//FORM_MISO // MUAFR_MISO_N [j] == flag_signal_P
				cnt_true_channel [j] <= cnt_true_channel [j] + 1;
			
		if (cnt_status_true  == (ITERATION - 4)) //счётчик на кз
			cnt_kz_signal_P <= 0;
		else	
			if (((MUAFR_MISO_P [0] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [1] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [2] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [3] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [4] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [5] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [6] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [7] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [8] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [9] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [10] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [11] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [12] == MUAFR_MISO_P [j]) + (MUAFR_MISO_P [13] == MUAFR_MISO_P [j])) == 1) //search errror input on no one channel
				cnt_kz_signal_P <= cnt_kz_signal_P + 1;
				
		if (cnt_status_true  == (ITERATION - 3))//счётчик на кз
			cnt_kz_signal_N <= 0;
		else	
			if (((MUAFR_MISO_N [0] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [1] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [2] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [3] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [4] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [5] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [6] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [7] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [8] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [9] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [10] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [11] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [12] == MUAFR_MISO_N [j]) + (MUAFR_MISO_N [13] == MUAFR_MISO_N [j])) > 13) //search errror input on no one channel
				cnt_kz_signal_N <= cnt_kz_signal_N + 1;		
		end else
		begin	
			j <= 0; 
			cnt_true_channel [j] <= 0;
			cnt_status_true <= 0;
			flag_signal_P <= 0;
			MUAFR_MOSI_P <= 16'h0; //16'hFFFF
			//MUAFR_MOSI_N <= 16'h0; //16'hFFFF
			
		end
		
		

end
endmodule
