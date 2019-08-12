`timescale 1ns / 1ns
module SampleStorage_tb();
	logic clk_25m, clk_50m, clk_100m, clk_aud, clk_lr_aud;
	logic ivalid, oready;
	logic ovalid, iready;
	logic read, write, read_last;
	logic [24:0] waddr, raddr; 
	logic busy, busy_next;
	logic [15:0] idata, odata, wdata, rdata;
	logic [4:0] state;
	logic rst, rdy;
	logic flg;
	
	SampleStorage u0(
		.clk50(clk_50m),
		.rst(rst),
		.idata(idata),
		.odata(odata),
		.iready(iready),
		.ivalid(ivalid),
		.oready(oready),
		.ovalid(ovalid),
		.read(read),
		.read_ready(rdy),
		.write(write),
		.raddr(raddr),
		.waddr(waddr),
		.wdata(wdata),
		.rdata(rdata),
		.busy(busy),
		.channel(~clk_lr_aud),
		.lrclk(clk_lr_aud),
		.state(state)
	);
	
	initial begin // generate reset signal
		rst  = '0;
		#20ns rst  = '1;
		#40ns rst  = '0;	
	end
	initial begin
		clk_25m = '1;
		forever begin
			#20ns clk_25m = ~clk_25m;
		end
	end
	initial begin // generate 50MHz clock
		clk_50m = '1;
		forever begin
			#10ns clk_50m = ~clk_50m;
		end
	end
	initial begin // generate 100MHz clock
		clk_100m = '1;
		forever begin
			#5ns clk_100m = ~clk_100m;
		end
	end
	initial begin // generate audio sample clock
		clk_aud = '1;
		forever begin
			//#10.416us clk_aud = ~clk_aud;
			#220ns clk_aud = ~clk_aud;
		end
	end
	initial begin
		clk_lr_aud = '0;
		forever begin
			#440ns clk_lr_aud = ~clk_lr_aud;
		end
	end
	initial begin // create audio samples and handshake signals
		wait(rst) begin
			idata = '0;
			flg = '0;
			wait(~rst) $display("***** Starting... *****");
		end
		forever @(posedge clk_lr_aud)	begin
			if(idata == 'd24000) begin idata = '0; flg = '1; end
			else idata = idata + 1'd1;
			ivalid = '1;
			wait(iready) begin
				wait(~iready) ivalid = '0;
			end
			wait(ovalid) begin
				#20ns oready = '1;
				#20ns oready= '0;
			end
		end
	end
	initial begin
		forever @(posedge clk_50m) rdata <= idata + 'd3;
	end
	initial begin // create SDRAM busy signal
		wait(rst) begin
			busy_next <= '0;
			wait(~rst) $display("***** Starting... *****");
		end
		forever @(posedge clk_50m) begin
			if(read || write)
				busy_next <= '1;
			else 
				busy_next <= '0;
		end
	end
	initial begin // create read_ready signal
		wait(rst) begin
			rdy <= '0;
		end
		forever @(posedge busy) begin
			if(read_last) begin
				
				#20ns rdy <='1;
				wait(~busy) rdy <= '0;
			end else
				rdy <= '0;
		end
	end
	initial begin // create SDRAM busy signal
		forever @(posedge clk_50m) begin
			busy <= busy_next;
		end
	end
	initial begin // create register for read_last
		forever @(posedge clk_25m) begin
			read_last <= read;
		end
	end
	initial begin // wait till you get 48000 delayed samples out of RAM
		wait(flg && odata == 'd24000) $stop;
	end
endmodule