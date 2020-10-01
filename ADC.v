/*
	CHANGE THE FUNCTION GENERATOR TO HIGH-Z MODE YOU FUCK

*/
module ADC(clk, cs, clk_1_20, dout, din, data_out);
input 	clk; 				//FPGA local clock
output 	cs;				//MCP3002's Chip Select input (no user interaction needed)
output 	clk_1_20; 		        //MCP3002's Clock input (no user interaction needed)
input 	dout;				//MCP3002's Data output (no user interaction needed)
output 	din;				//MCP3002's Data input (no user interaction needed)                        //Indicates what channel the output is coming from
output data_out;                        //The latched 10-bit sample data. We have 16 clock cycles at 1.2MHz to access each sample                         //Helps us determine when we should be sampling

wire clk;
wire dout;

reg [9:0] data_out;
reg clk_1_20;
reg din;
reg cs;
reg dataRec;

//----------------------------------------------------
//First generate the 1.2MHz clock from the 24MHz clock
//To do this we must create a counter that counts to 20
reg [7:0] cnt20; //This will create 32 values but we only want 20
reg [7:0] cnt20_next;
//Lets create the top level state update to cnt20
always @(posedge clk) cnt20<=cnt20_next;
//Lets create a simple process to limit this range
always @(posedge clk) 
begin
	if (cnt20==8) // 8 for the 3.2 MHz clk
	begin
		cnt20_next<=0; //Reset to zero
		clk_1_20<=~clk_1_20; //Flip the state of clk_1_20
	end
	else	
	begin
		cnt20_next<=cnt20_next+1; //Continue with increment
		clk_1_20<=clk_1_20; //Maintain the state of clk_1_20
	end
end

//----------------------------------------------------
//In this code we will be using both the positive and negative edge 
//of the clk_1_20 signal. The order that these processes execute are important
//because of this we need to ensure that the negative edge processes start 
//before the postive edge processes. To do this we must create a latch signal.
reg init_latch;
always @(posedge clk_1_20) init_latch<=1;

//----------------------------------------------------
//Now that we have the 1.2MHz clock, we can generate
//another counter that counts to 16 at 1.2MHz
reg [3:0] cnt16;
always @(posedge clk_1_20) if (init_latch==1) cnt16<=cnt16+1; 


//----------------------------------------------------
//With the newly created counter, cnt16, 
//we can now create the 16 step SPI
//The input signals to the SPI should operate on the negative edge
//This is because the SPI on the ADC samples on the positive edge
//We want to maximize the settling time of the signal as to avoid
//communication errors
always @(negedge clk_1_20)
begin
	if (init_latch==1)
	begin
		case (cnt16)
		0://Bring cs high to initialize
			begin 
				cs<=1;
				din<=0;
			end
		1://START BIT :: Bring cs low and din high to initiate communication
			begin 
				cs<=0;
				din<=1;
			end
		2://MODE BIT :: Bring din high to set the mode to single-ended
			begin 
				cs<=0;
				din<=1;
			end
		3://CHANNEL BIT :: Bring din low to select channel 0
			begin 
				cs<=0;
				din<=1'b0;
			end
		4://MSBF BIT :: Bring din high to set the output in MSB First format
			begin 
				cs<=0;
				din<=1;
			end
		default://Maintain cs low for the remainder of the 16 clocks
			begin 
				cs<=0;
				din<=0;
			end		
		endcase
	end
end

//----------------------------------------------------
//Now that the input into the ADC's SPI has been created
//we can now grab the output
//First create the sample signal which will act as a 10-bit FIFO
reg [9:0] sample;

//----------------------------------------------------
//Now with the sample signal created, start sampling dout
//The output is only valid on clock 6-15
//This data should be grabbed on the positive edge so that
//the ADC's output has time to settle
//
always @(posedge clk_1_20)
begin
	if (init_latch==1)
	begin
		if (cnt16>=6)
		begin
			sample[9:1]<=sample[8:0];
			sample[0]<=dout;
		end
		else sample<=sample;
	end
end

//----------------------------------------------------
//Finally latch onto the data after the end of each process
always @(posedge clk_1_20) 
begin
	if (cnt16==0) 
		begin
			data_out<=sample; 
			dataRec<=1'b1;
		end
	else 
		begin
			data_out<=data_out;
			dataRec<=1'b0;
		end
end

endmodule