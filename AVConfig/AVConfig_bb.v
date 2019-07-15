
module AVConfig (
	address,
	byteenable,
	read,
	write,
	writedata,
	readdata,
	waitrequest,
	clk,
	I2C_SDAT,
	I2C_SCLK,
	reset);	

	input	[1:0]	address;
	input	[3:0]	byteenable;
	input		read;
	input		write;
	input	[31:0]	writedata;
	output	[31:0]	readdata;
	output		waitrequest;
	input		clk;
	inout		I2C_SDAT;
	output		I2C_SCLK;
	input		reset;
endmodule
