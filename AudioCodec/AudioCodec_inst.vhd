	component AudioCodec is
		port (
			to_dac_left_channel_data     : in  std_logic_vector(23 downto 0) := (others => 'X'); -- data
			to_dac_left_channel_valid    : in  std_logic                     := 'X';             -- valid
			to_dac_left_channel_ready    : out std_logic;                                        -- ready
			from_adc_left_channel_ready  : in  std_logic                     := 'X';             -- ready
			from_adc_left_channel_data   : out std_logic_vector(23 downto 0);                    -- data
			from_adc_left_channel_valid  : out std_logic;                                        -- valid
			to_dac_right_channel_data    : in  std_logic_vector(23 downto 0) := (others => 'X'); -- data
			to_dac_right_channel_valid   : in  std_logic                     := 'X';             -- valid
			to_dac_right_channel_ready   : out std_logic;                                        -- ready
			from_adc_right_channel_ready : in  std_logic                     := 'X';             -- ready
			from_adc_right_channel_data  : out std_logic_vector(23 downto 0);                    -- data
			from_adc_right_channel_valid : out std_logic;                                        -- valid
			clk                          : in  std_logic                     := 'X';             -- clk
			AUD_ADCDAT                   : in  std_logic                     := 'X';             -- ADCDAT
			AUD_ADCLRCK                  : in  std_logic                     := 'X';             -- ADCLRCK
			AUD_BCLK                     : in  std_logic                     := 'X';             -- BCLK
			AUD_DACDAT                   : out std_logic;                                        -- DACDAT
			AUD_DACLRCK                  : in  std_logic                     := 'X';             -- DACLRCK
			reset                        : in  std_logic                     := 'X'              -- reset
		);
	end component AudioCodec;

	u0 : component AudioCodec
		port map (
			to_dac_left_channel_data     => CONNECTED_TO_to_dac_left_channel_data,     --    avalon_left_channel_sink.data
			to_dac_left_channel_valid    => CONNECTED_TO_to_dac_left_channel_valid,    --                            .valid
			to_dac_left_channel_ready    => CONNECTED_TO_to_dac_left_channel_ready,    --                            .ready
			from_adc_left_channel_ready  => CONNECTED_TO_from_adc_left_channel_ready,  --  avalon_left_channel_source.ready
			from_adc_left_channel_data   => CONNECTED_TO_from_adc_left_channel_data,   --                            .data
			from_adc_left_channel_valid  => CONNECTED_TO_from_adc_left_channel_valid,  --                            .valid
			to_dac_right_channel_data    => CONNECTED_TO_to_dac_right_channel_data,    --   avalon_right_channel_sink.data
			to_dac_right_channel_valid   => CONNECTED_TO_to_dac_right_channel_valid,   --                            .valid
			to_dac_right_channel_ready   => CONNECTED_TO_to_dac_right_channel_ready,   --                            .ready
			from_adc_right_channel_ready => CONNECTED_TO_from_adc_right_channel_ready, -- avalon_right_channel_source.ready
			from_adc_right_channel_data  => CONNECTED_TO_from_adc_right_channel_data,  --                            .data
			from_adc_right_channel_valid => CONNECTED_TO_from_adc_right_channel_valid, --                            .valid
			clk                          => CONNECTED_TO_clk,                          --                         clk.clk
			AUD_ADCDAT                   => CONNECTED_TO_AUD_ADCDAT,                   --          external_interface.ADCDAT
			AUD_ADCLRCK                  => CONNECTED_TO_AUD_ADCLRCK,                  --                            .ADCLRCK
			AUD_BCLK                     => CONNECTED_TO_AUD_BCLK,                     --                            .BCLK
			AUD_DACDAT                   => CONNECTED_TO_AUD_DACDAT,                   --                            .DACDAT
			AUD_DACLRCK                  => CONNECTED_TO_AUD_DACLRCK,                  --                            .DACLRCK
			reset                        => CONNECTED_TO_reset                         --                       reset.reset
		);

