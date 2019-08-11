// Created by Navraj Kambo
// nkambo1@my.bcit.ca
// 2019-07-14
// Altera DE1-SoC, System Verilog
// Basic audio hardware loopback in verilog using Altera University IP catalog
// So that you can you can add your own DSP hardware in-between ADC and DAC
// 16-Bit audio
 
// I/O assignments
module AudioFX(
	// Inputs
	SW, 
	KEY,  
	CLOCK_50,
	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,
	FPGA_I2C_SDAT,
	DRAM_DQ,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,
	LEDR,
	FPGA_I2C_SCLK,
	GPIO_0,
	GPIO_1,
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CAS_N, 
	DRAM_RAS_N, 
	DRAM_CLK,
	DRAM_CKE, 
	DRAM_CS_N, 
	DRAM_WE_N,
	DRAM_UDQM,
	DRAM_LDQM
	);
	
	// params
	parameter DATA_W = 16;
	parameter ADDR_W = 24;
	
	// signals				
	input [9:0] SW;
	input CLOCK_50;
	input [3:0]	KEY;
	input	AUD_ADCDAT;

	inout	AUD_BCLK;
	inout	AUD_ADCLRCK;
	inout	AUD_DACLRCK;
	inout FPGA_I2C_SDAT;
	inout [15:0] DRAM_DQ;

	output AUD_XCK;
	output AUD_DACDAT;
	output FPGA_I2C_SCLK;
	output [9:0] LEDR;
	output [35:0] GPIO_0;
	output [35:0] GPIO_1;
	
	output [12:0] DRAM_ADDR;
	output [1:0] DRAM_BA;
	output DRAM_CAS_N, DRAM_RAS_N, DRAM_CLK;
	output DRAM_CKE, DRAM_CS_N, DRAM_WE_N;
	output DRAM_UDQM;
	output DRAM_LDQM;
	
	// registers
	reg [22:0] count;
	
	// logic & wires for ADC/DAC
	logic [1:0] reset_out;
	logic signed [1:0][DATA_W-1:0] DAC_Data, ADC_Data;
	logic [1:0] DAC_Ready, ADC_Ready, DAC_Valid, ADC_Valid;
	
	// These signals are for the Avalon Bus (not used in streaming interface)
	//  (Therefore, I just made random signals for to satify I/O)
	logic [31:0] i2c_data = 32'd0, i2c_read_data = 32'd0;
	logic [3:0] i2c_byte_enable = 4'b1111;
	logic i2c_read=0, i2c_write = 0, i2c_waitrequest;
	
	// logic for RAM
	logic [1:0][ADDR_W-1:0] waddr, raddr;
	logic [1:0][DATA_W-1:0] wdata;
	logic [ADDR_W-1:0] waddress, raddress;
	logic signed [DATA_W-1:0] writedata, readdata;
	logic [1:0] write, read;
	logic read_ready, busy, we, re;
	logic CLOCK_50_D;
	logic [1:0][4:0] state;
 	
	// logic for Effects
	logic signed [1:0][DATA_W-1:0] FX_AUD_OUT, Latched_Data;
	logic cnt[1:0];
	
	// debugging read command
	logic [1:0] [15:0] D;
	always@(posedge AUD_ADCLRCK) begin
		if(reset_out[1])
			cnt[0] = '0;
		else begin
			cnt[0] =~cnt[0];
				if(cnt[0])
				D[0] = 'h0001;
			else
				D[0] = 'h0002;
		end
	end
	always@(negedge AUD_ADCLRCK) begin
		if(reset_out[1])
			cnt[1] = '0;
		else begin
			cnt[1] =~cnt[1];
			if(cnt[1])
				D[1] = 'h0003;
			else
				D[1] = 'h0004;
		end
	end
	
	// instantiations
	
	// Audio PLL
	AudioPLL u0 (
		.ref_clk_clk        (CLOCK_50_D),        //      ref_clk.clk
		.ref_reset_reset    (reset_out[1]),    //    ref_reset.reset
		.audio_clk_clk      (AUD_XCK),      //    audio_clk.clk
		.reset_source_reset (reset_out[0])  // reset_source.reset
	);
	// RAM PLL
	SDRAMPLL u1 (
		.ref_clk_clk        (CLOCK_50),        //      ref_clk.clk
		.ref_reset_reset    (~KEY[0]),    //    ref_reset.reset
		.sys_clk_clk        (CLOCK_50_D),        //      sys_clk.clk
		.sdram_clk_clk      (DRAM_CLK),      //    sdram_clk.clk
		.reset_source_reset (reset_out[1])  // reset_source.reset
	);
	// Audio Config (16bit audio, you can change this with QSYS)
	AVConfig u2 (
		.clk         (CLOCK_50_D),         //                    clk.clk
		.reset       (reset_out[1]),       //                  reset.reset
		.address     (i2c_read_data),     // avalon_av_config_slave.address
		.byteenable  (i2c_byte_enable),  //                       .byteenable
		.read        (i2c_read),        //                       .read
		.write       (i2c_write),       //                       .write
		.writedata   (i2c_data),   //                       .writedata
		.readdata    (i2c_data),    //                       .readdata
		.waitrequest (i2c_waitrequest), //                       .waitrequest
		.I2C_SDAT    (FPGA_I2C_SDAT),    //     external_interface.SDAT
		.I2C_SCLK    (FPGA_I2C_SCLK)     //                       .SCLK
	);
	// Audio Codec
	AudioCodec u3 (
		.clk                          (CLOCK_50_D),                          //                         clk.clk
		.reset                        (reset_out[1]),                        //                       reset.reset
		.AUD_ADCDAT                   (AUD_ADCDAT),                   //          external_interface.ADCDAT
		.AUD_ADCLRCK                  (AUD_ADCLRCK),                  //                            .ADCLRCK
		.AUD_BCLK                     (AUD_BCLK),                     //                            .BCLK
		.AUD_DACDAT                   (AUD_DACDAT),                   //                            .DACDAT
		.AUD_DACLRCK                  (AUD_DACLRCK),                  //                            .DACLRCK
		.from_adc_left_channel_ready  (ADC_Ready[0]),  //  avalon_left_channel_source.ready
		.from_adc_left_channel_data   (ADC_Data[0]),   //                            .data
		.from_adc_left_channel_valid  (ADC_Valid[0]),  //                            .valid
		.from_adc_right_channel_ready (ADC_Ready[1]), // avalon_right_channel_source.ready
		.from_adc_right_channel_data  (ADC_Data[1]),  //                            .data
		.from_adc_right_channel_valid (ADC_Valid[1]), //                            .valid
		.to_dac_left_channel_data     (DAC_Data[0]),     //    avalon_left_channel_sink.data
		.to_dac_left_channel_valid    (DAC_Valid[0]),    //                            .valid
		.to_dac_left_channel_ready    (DAC_Ready[0]),    //                            .ready
		.to_dac_right_channel_data    (DAC_Data[1]),    //   avalon_right_channel_sink.data
		.to_dac_right_channel_valid   (DAC_Valid[1]),   //                            .valid
		.to_dac_right_channel_ready   (DAC_Ready[1])    //                            .ready
	);
	// SDRAM hardware-only controller
	sdram_controller u4(
		/* HOST INTERFACE */
		.wr_addr(waddress),
		.wr_data(writedata),
		.wr_enable(we),

		.rd_addr(raddress),
		.rd_data(readdata),
		.rd_ready(read_ready),
		.rd_enable(re),

		.busy(busy), 
		.rst_n(~reset_out[1]), 
		.clk(CLOCK_50_D),

		/* SDRAM SIDE */
		.addr(DRAM_ADDR), 
		.bank_addr(DRAM_BA), 
		.data(DRAM_DQ), 
		.clock_enable(DRAM_CKE), 
		.cs_n(DRAM_CS_N), 
		.ras_n(DRAM_RAS_N), 
		.cas_n(DRAM_CAS_N), 
		.we_n(DRAM_WE_N),
		.data_mask_low(DRAM_LDQM), 
		.data_mask_high(DRAM_UDQM)
	);
	
	//Left and Right channel effects
	SampleStorage LChan(
		.clk50(CLOCK_50_D),
		.rst(reset_out[1]),
		.idata(ADC_Data[0]),//.idata(D[0]),//.idata(ADC_Data[0]),//
		.odata(FX_AUD_OUT[0]),
		.iready(ADC_Ready[0]),
		.ivalid(ADC_Valid[0]),
		.oready(DAC_Ready[0]),
		.ovalid(DAC_Valid[0]),
		.read(read[0]),
		.write(write[0]),
		.read_ready(read_ready),
		.raddr(raddr[0]),
		.waddr(waddr[0]),
		.wdata(wdata[0]),
		.rdata(readdata),
		.busy(busy),
		.channel('0),
		.lrclk(AUD_ADCLRCK),
		.state(state[0])
	);
	SampleStorage RChan(
		.clk50(CLOCK_50_D),
		.rst(reset_out[1]),
		.idata(ADC_Data[1]),//.idata(D[1]),//.idata(ADC_Data[1]),//
		.odata(FX_AUD_OUT[1]),
		.iready(ADC_Ready[1]),
		.ivalid(ADC_Valid[1]),
		.oready(DAC_Ready[1]),
		.ovalid(DAC_Valid[1]),
		.read(read[1]),
		.write(write[1]),
		.read_ready(read_ready),
		.raddr(raddr[1]),
		.waddr(waddr[1]),
		.wdata(wdata[1]),
		.rdata(readdata),
		.busy(busy),
		.channel('1),
		.lrclk(~AUD_ADCLRCK),
		.state(state[1])
	);
	
	// Useful for signal tap or scope debugging and
	assign GPIO_0[DATA_W-1:0] = readdata;
	assign GPIO_0[16] = busy;
	assign GPIO_0[17] = read_ready;
	assign GPIO_0[26] = we;
	assign GPIO_0[27] = re;
	assign GPIO_0[18] = ADC_Ready[0];
	assign GPIO_0[19] = ADC_Valid[0];
	assign GPIO_0[20] = DAC_Ready[0];
	assign GPIO_0[21] = DAC_Valid[0];
	assign GPIO_0[22] = ADC_Ready[1];
	assign GPIO_0[23] = ADC_Valid[1];
	assign GPIO_0[24] = DAC_Ready[1];
	assign GPIO_0[25] = DAC_Valid[1];
	assign GPIO_0[31:28] = state[0];
	assign GPIO_0[35:32] = state[1];
	
	//
	assign GPIO_1[DATA_W-1:0] = writedata;
	assign GPIO_1[23:16] = FX_AUD_OUT[0][7:0];
	assign GPIO_1[31:24] = FX_AUD_OUT[1][7:0];
	
	// Logic for blinking LED on Switch 0
	always@(posedge(CLOCK_50_D)) begin
		if(SW[0]==1) begin
			if(count ==0) begin
				LEDR[0] <= ~LEDR[0];
			end
			count <= count +1;
		end else begin
			LEDR[0] <= 0;
			count <= 1;
		end
	end
	
	assign LEDR[2] = (Latched_Data[0] && wdata[0]);
	assign LEDR[3] = (Latched_Data[1] && wdata[1]); 
	
	// Logic for using SDRAM
	always@(posedge CLOCK_50_D) begin
		if(ADC_Ready[0] && ADC_Valid[0])
			Latched_Data[0] <= ADC_Data[0];
		if(ADC_Ready[1] && ADC_Valid[1])
			Latched_Data[1] <= ADC_Data[1];
	end
	always@(posedge CLOCK_50_D) begin
		LEDR[1] = SW[1];
		LEDR[9] = SW[9];
		
		if(SW[9]) begin
			DAC_Data[0] <= '0;
			DAC_Data[1] <= '0;
		end else begin
			if(SW[1]) begin
				//DAC_Data[0] <= Latched_Data[0] + (FX_AUD_OUT[0] >>> 2);
				//DAC_Data[1] <= Latched_Data[1] + (FX_AUD_OUT[1] >>> 2);
				DAC_Data[0] <= (signed'(FX_AUD_OUT[0]) >>> 1);
				DAC_Data[1] <= (signed'(FX_AUD_OUT[1]) >>> 1);
			end else begin
				DAC_Data[0] <= Latched_Data[0];
				DAC_Data[1] <= Latched_Data[1];
			end
		end
		if(AUD_ADCLRCK) begin
			re <=	read[0];
			we <=	write[0];
			raddress <= raddr[0];
			waddress <= waddr[0];
			writedata <= wdata[0];
		end else begin
			re <=	read[1];
			we <=	write[1];
			raddress <= raddr[1];
			waddress <= waddr[1];
			writedata <= wdata[1];
		end
	end
	
	/*
	// Basic tie-back for audio ADC -> DAC
	always@(posedge(CLOCK_50)) begin
		// Mute Condition using switch 9
		if(SW[9] ==1) begin
			DAC_Data[0] <= 0;
			DAC_Data[1] <= 0;
			DAC_Valid[0] <= ADC_Valid[1];
			DAC_Valid[1] <= ADC_Valid[0];
			ADC_Ready[0] <= DAC_Ready[1];
			ADC_Ready[1] <= DAC_Ready[0];
			LEDR[9] <= 1;
		end else begin
			// Normal operation
			LEDR[9] <= 0;
			DAC_Data[0] <= ADC_Data[0];
			DAC_Data[1] <= ADC_Data[1];
			DAC_Valid[0] <= ADC_Valid[0];
			DAC_Valid[1] <= ADC_Valid[1];
			ADC_Ready[0] <= DAC_Ready[0];
			ADC_Ready[1] <= DAC_Ready[1];
		end
	end
	*/
endmodule
