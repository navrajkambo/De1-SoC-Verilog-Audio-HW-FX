	component AVConfig is
		port (
			address     : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- address
			byteenable  : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			read        : in    std_logic                     := 'X';             -- read
			write       : in    std_logic                     := 'X';             -- write
			writedata   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			readdata    : out   std_logic_vector(31 downto 0);                    -- readdata
			waitrequest : out   std_logic;                                        -- waitrequest
			clk         : in    std_logic                     := 'X';             -- clk
			I2C_SDAT    : inout std_logic                     := 'X';             -- SDAT
			I2C_SCLK    : out   std_logic;                                        -- SCLK
			reset       : in    std_logic                     := 'X'              -- reset
		);
	end component AVConfig;

	u0 : component AVConfig
		port map (
			address     => CONNECTED_TO_address,     -- avalon_av_config_slave.address
			byteenable  => CONNECTED_TO_byteenable,  --                       .byteenable
			read        => CONNECTED_TO_read,        --                       .read
			write       => CONNECTED_TO_write,       --                       .write
			writedata   => CONNECTED_TO_writedata,   --                       .writedata
			readdata    => CONNECTED_TO_readdata,    --                       .readdata
			waitrequest => CONNECTED_TO_waitrequest, --                       .waitrequest
			clk         => CONNECTED_TO_clk,         --                    clk.clk
			I2C_SDAT    => CONNECTED_TO_I2C_SDAT,    --     external_interface.SDAT
			I2C_SCLK    => CONNECTED_TO_I2C_SCLK,    --                       .SCLK
			reset       => CONNECTED_TO_reset        --                  reset.reset
		);

