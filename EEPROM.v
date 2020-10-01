module EEPROM(clk, rst, SDA, SCL, writeData, ready4NewData, done, address);
	input rst;
	input clk;
	output reg SCL;
	reg SCLx4;
	output reg SDA;
	output reg ready4NewData;
	output reg done;
	
	
	reg [12:0] count;
	output reg [14:0] address;
	input [7:0] writeData;
	
	// clock generation
	reg [25:0] countSCL; 
	always @ (posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
		begin
			countSCL <= 26'd0;
			SCLx4 <= 1'b0;
			SCL <= 1'b0;
		end
		else
		begin
			// clock currently running at 250kHz
			if (countSCL >= 26'd99) //8'd2499 for 10kHz clk
				countSCL <= 26'd0;
			else
				countSCL <= countSCL + 26'd1;
				
			if (countSCL == 26'd0)
			begin
				SCLx4 <= ~SCLx4;
				SCL <= ~SCL;
			end
			else if (countSCL == 26'd24) //8'd624
				SCLx4 <= ~SCLx4;
			else if (countSCL == 26'd49) //8'd1249
				SCLx4 <= ~SCLx4;
			else if (countSCL == 26'd74) //8'd1874
				SCLx4 <= ~SCLx4;
		end
	end
	
	always @ (posedge SCLx4 or negedge rst)
	begin
		if (rst == 1'b0)
		begin
			count <= 13'd0;
			address <= 15'd0;
			done <= 1'b0;
		end
		else
		begin
			if (address < 15'd32767)
			begin
				done <= 1'b0;
			
				if (count >= 5155) //Change this if you change the SDL clock, otherwise delay isnt 5ms
				begin
					count <= 13'd0;
					address <= address + 15'd1;
				end
				else
				begin
					count <= count + 13'd1;
					address <= address;
				end
			end
			else
			begin
				done <= 1'b1;
				count <= 13'd5150;
				address <= address;
			end
		end
	end
	
	always @ (*)
	begin
		if (count == 13'd1)
		begin
			SDA = 1'b1;
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd2 && count <= 13'd3)
		begin
			SDA = 1'b0;
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd4 && count <= 13'd7)
		begin
			SDA = 1'b1;
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd8 && count <= 13'd11)
		begin	
			SDA = 1'b0;
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd12 && count <= 13'd15)
		begin	
			SDA = 1'b1;
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd16 && count <= 13'd43) // long boi
		begin	
			SDA = 1'b0;
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd44 && count <= 13'd47)
		begin	
			SDA = address[14];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd48 && count <= 13'd51)
		begin	
			SDA = address[13];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd52 && count <= 13'd55)
		begin	
			SDA = address[12];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd56 && count <= 13'd59)
		begin	
			SDA = address[11];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd60 && count <= 13'd63)
		begin	
			SDA = address[10];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd64 && count <= 13'd67)
		begin	
			SDA = address[9];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd68 && count <= 13'd70)
		begin	
			SDA = address[8];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd71 && count <= 13'd75) // ack1
		begin	
			SDA = 1'b0;
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd76 && count <= 13'd79)
		begin	
			SDA = address[7];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd80 && count <= 13'd83)
		begin	
			SDA = address[6];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd84 && count <= 13'd87)
		begin	
			SDA = address[5];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd88 && count <= 13'd91)
		begin	
			SDA = address[4];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd92 && count <= 13'd95)
		begin	
			SDA = address[3];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd96 && count <= 13'd99)
		begin	
			SDA = address[2];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd100 && count <= 13'd103)
		begin	
			SDA = address[1];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd104 && count <= 13'd106)
		begin	
			SDA = address[0];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd107 && count <= 13'd111) // ack2
		begin	
			SDA = 1'b0;
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd112 && count <= 13'd115)
		begin	
			SDA = writeData[7];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd116 && count <= 13'd119)
		begin	
			SDA = writeData[6];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd120 && count <= 13'd123)
		begin	
			SDA = writeData[5];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd124 && count <= 13'd127)
		begin	
			SDA = writeData[4];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd128 && count <= 13'd131)
		begin	
			SDA = writeData[3];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd132 && count <= 13'd135)
		begin	
			SDA = writeData[2];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd136 && count <= 13'd139)
		begin	
			SDA = writeData[1];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd140 && count <= 13'd142)
		begin	
			SDA = writeData[0];
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd143 && count <= 13'd149) // ack3
		begin	
			SDA = 1'b0;
			ready4NewData = 1'b0;
		end
		else if (count >= 13'd150 && count <= 13'd5155)
		begin	
			SDA = 1'b1;
			ready4NewData = 1'b1;
		end
		else
		begin
			SDA = 1'b1;
			ready4NewData = 1'b0;
		end
	end
endmodule