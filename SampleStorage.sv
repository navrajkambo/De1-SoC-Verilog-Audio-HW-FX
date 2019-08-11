module SampleStorage (
		clk50,
		rst,
		idata,
		odata,
		iready,
		ivalid,
		oready,
		ovalid,
		read,
		write,
		read_ready,
		raddr,
		waddr,
		wdata,
		rdata,
		busy,
		channel,
		lrclk,
		state
	);
	
	parameter      ADDR_W             =     24;
	parameter      DATA_W             =     16;

	input logic clk50, rst, busy, ivalid, oready, read_ready;
	input logic signed [DATA_W-1:0]  idata;
	input logic [DATA_W-1:0] rdata;
	input logic channel, lrclk;
	
	output logic ovalid, iready, read, write;
	output logic signed[DATA_W-1:0]	odata;
	output logic [DATA_W-1:0] wdata;
	output logic [ADDR_W-1:0] waddr, raddr;
	
	logic signed [DATA_W-1:0] odata_next, wdata_next;
	logic [ADDR_W-2:0] raddress, waddress;
	logic ovalid_next, iready_next, flg;
	output logic [4:0] state;
	
	logic wmax_next, wmax, wmax_address, rmax_address;
	logic busy_last;
	
	
	assign rmax_address = &raddress;
	assign wmax_address = &waddress;
	
	assign waddr = {channel,waddress};
	assign raddr = {channel,raddress};
	
	always@(posedge clk50) begin
		if(rst) begin
			wmax_next <= 0;
		end else begin
			if(waddress > 'd48000)
				wmax_next <= 1;
		end
	end
	always@(posedge clk50)	begin
		if(rst) begin
			state <= 'd0;
			
			raddress <= '0;
			waddress <= '0;
			iready_next <= 0;
			ovalid_next <= 0;
			odata_next <= '0;
			wdata_next <= '0;
			read <= 0;
			write <= 0;
			flg <=0;
		end else begin
			case(state)
				0: begin //Idle
					ovalid_next <= '0;
					flg <= 0;
					if(ivalid) begin
						state <= 1;
						iready_next <= 1;
					end else
						state <= 0;
				end
				1: begin //New data on bus
					iready_next <= 0;
					wdata_next <= idata;
					state <= 2;
				end
				2: begin //Write Data
					if(busy || ~lrclk) state <= 2;
					else begin
						write <= 1;
						state <= 3;
					end
				end
				3: begin //After Write Data
					if(busy && ~busy_last) begin
						write <= 0;
						state <= 4;
					end else
						state <= 3;
				end
				4: begin //After Write Data and Busy
					if(~busy) begin
						if(wmax_address)
							waddress <= '0;
						else
							waddress <= waddress + 1'd1;
						if(wmax)
							state <= 5;
						else begin
							state <= 8;
							flg <= '1;
						end
					end else
						state <= 4;
				end
				5: begin //Read Data
					if(busy || ~lrclk) state <= 5;
					else begin
						read <= 1;
						state <= 6;
					end
				end
				6: begin //After Read Data
					if(busy && ~busy_last) begin
						read <= 0;
						state <= 7;
					end else
						state <= 6;
				end
				7: begin //Wait for read ready signal
					if(read_ready) begin
						odata_next = rdata;
						state <= 8;
					end else begin
						state <= 7;
					end
				end
				8: begin //After Read Data and Read Ready signal
					if(lrclk) begin
						ovalid_next <= 1;
						if(~flg) begin
							flg <= '1;
							if(rmax_address)
								raddress <= '0;
							else
								raddress <= raddress + 1'd1;
						end
						if(ovalid && oready) begin
							ovalid_next <= '0;
							state <= 0;
						end else
							state <= 8;
					end else state <= 8;
				end
				default: begin //Idle
					iready_next <= iready;
					ovalid_next <= ovalid;
					state <= 0;
				end
			endcase
		end
	end
	always@(posedge clk50) begin //50MHz clock
		wmax <= wmax_next;
		busy_last <= busy;
	end
	always@(posedge clk50) begin //50MHz clock
		iready <= iready_next;
		ovalid <= ovalid_next;
		odata <= odata_next;
		wdata <= wdata_next;
	end
endmodule