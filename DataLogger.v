module DataLogger(clk, rst, EEPROM_SDA, EEPROM_SCL, ADC_CS, ADC_output, ADC_input, ADC_clk, addr, writeData);
	input clk;
	input rst;
	output EEPROM_SDA;
	output EEPROM_SCL;
	output ADC_CS;
	input ADC_output;
	output ADC_input;
	output ADC_clk;
	
	output reg [7:0] writeData;
	wire [9:0] dataSampled;
	wire dataCanChange;
	wire EEPROM_full;
	output [14:0] addr;
	
	EEPROM Memory(clk, rst, EEPROM_SDA, EEPROM_SCL, writeData, dataCanChange, EEPROM_full, addr);
	ADC DataReader(clk, ADC_CS, ADC_clk, ADC_output, ADC_input, dataSampled);
	
	always @ (posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
		begin
			writeData <= 8'hFF;
		end
		else
		begin
			if (dataCanChange && !EEPROM_full)
				writeData <= dataSampled[9:2];
			else
				writeData <= writeData;
		end
	end

endmodule
