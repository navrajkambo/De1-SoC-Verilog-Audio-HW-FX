module SampleStorage (
		clk50,
		clk100,
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
		lrclk
	);
	
	parameter      ADDR_W             =     25;
	parameter      DATA_W             =     16;

	input logic clk50, clk100, rst, busy, ivalid, oready, read_ready;
	input logic signed [DATA_W-1:0]  idata;
	input logic [DATA_W-1:0] rdata;
	input logic channel, lrclk;
	
	output logic ovalid, iready, read, write;
	output logic signed[DATA_W-1:0]	odata;
	output logic [DATA_W-1:0] wdata;
	output logic [ADDR_W-1:0] waddr, raddr;
	
	logic signed [DATA_W-1:0] odata_next;
	logic [ADDR_W-2:0] raddress, waddress;
	logic ovalid_next, iready_next, flg;
	logic [4:0] state;
	
	logic wmax_next, wmax, wmax_address, rmax_address;
	logic busy_last;
	
	
	assign rmax_address = &raddress;
	assign wmax_address = &waddress;
	
	assign waddr = {channel,waddress};
	assign raddr = {channel,raddress};
	
	always@(posedge clk100) begin
		if(rst) begin
			wmax_next <= 0;
		end else begin
			if(waddress > 'd96000)
				wmax_next <= 1;
			else
				wmax_next <= wmax;
		end
	end
	always@(posedge clk100)	begin
		if(rst) begin
			state <= 'd0;
			
			raddress <= '0;
			waddress <= '0;
			iready_next <= 0;
			ovalid_next <= 0;
			odata_next <= '0;
			read <= 0;
			write <= 0;
			flg <=0;
		end else begin
			case(state)
				0: begin //Idle
					ovalid_next <= '0;
					odata_next <= odata;
					flg <= 0;
					if(ivalid) begin
						state <= 1;
						iready_next <= 1;
					end else
						state <= 0;
				end
				1: begin //New data on bus
					iready_next <= 0;
					odata_next <= odata;
					wdata = idata;
					state <= 2;
				end
				2: begin //Write Data
					odata_next <= odata;
					if(busy || ~lrclk) state <= 2;
					else begin
						write <= 1;
						state <= 3;
					end
				end
				3: begin //After Write Data
					odata_next <= odata;
					if(busy && ~busy_last) begin
						write <= 0;
						state <= 4;
					end else
						state <= 2;
				end
				4: begin //After Write Data and Busy
					odata_next <= odata;
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
					odata_next <= odata;
					if(busy || ~lrclk) state <= 5;
					else begin
						read <= 1;
						state <= 6;
					end
				end
				6: begin //After Read Data
					odata_next <= odata;
					if(busy && ~busy_last) begin
						read <= 0;
						state <= 7;
					end else
						state <= 6;
				end
				7: begin //Wait for read ready signal
					if(read_ready) begin
						odata_next <= rdata;
						state <= 8;
					end else begin
						state <= 7;
						odata_next <= odata;
					end
				end
				8: begin //After Read Data and Read Ready signal
					//if(lrclk) odata = (odata >> 1) + internal_data; // mix data and sample delay
					//else odata = internal_data;
					odata_next <= odata;
					if(lrclk) begin
						ovalid_next <= 1;
						if(~flg) begin
							flg <= '1;
							if(rmax_address)
								raddress <= '0;
							else
								raddress <= raddress + 1'd1;
						end
						if(ovalid && oready)
							state <= 0;
						else
							state <= 8;
					end else state <= 8;
				end
				default: begin //Idle
					odata_next <= odata;
					iready_next <= iready;
					ovalid_next <= ovalid;
					state <= 0;
				end
			endcase
		end
	end
	always@(posedge clk100) begin //100MHz clock?
		wmax <= wmax_next;
		busy_last <= busy;
	end
	always@(posedge clk100) begin //50MHz clock
		iready <= iready_next;
		ovalid <= ovalid_next;
		odata <= odata_next;
	end
endmodule