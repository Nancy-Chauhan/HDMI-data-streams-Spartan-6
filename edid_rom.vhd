library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity edid_rom is
   port ( clk      : in    std_logic;
          sclk_raw : in    std_logic;
          sdat_raw : inout std_logic := 'Z';
          edid_debug : out std_logic_vector(2 downto 0) := (others => '0')
  );
end entity;

architecture Behavioral of edid_rom is

   type a_edid_rom is array (0 to 127) of std_logic_vector(7 downto 0);

   signal edid_rom : a_edid_rom := (
	   x"00", x"FF", x"FF", x"FF", x"FF", x"FF", x"FF", x"00", x"3D", x"17", x"32", x"12", x"2A", x"6A", x"BF", x"00",
		x"05", x"17", x"01", x"03", x"80", x"28", x"1E", x"00", x"08", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
		x"00", x"00", x"00", x"2E", x"00", x"00", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01", x"01",
		x"01", x"01", x"01", x"01", x"01", x"01", x"B2", x"0C", x"00", x"40", x"41", x"00", x"26", x"30", x"18", x"88",
		x"36", x"00", x"28", x"1E", x"00", x"00", x"00", x"1E", x"00", x"00", x"00", x"FC", x"00", x"4D", x"31", x"20",
		x"44", x"56", x"49", x"20", x"6D", x"69", x"78", x"65", x"72", x"0A", x"00", x"00", x"00", x"10", x"00", x"00",
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"10",
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"34"
      );

   signal sclk_delay  : std_logic_vector(2 downto 0);
   signal sdat_delay  : unsigned(6 downto 0);
   
   type t_state is (   state_idle, 
                     -- States to support writing the device's address
                     state_start,
                     state_dev7,
                     state_dev6,
                     state_dev5,
                     state_dev4,
                     state_dev3,
                     state_dev2,
                     state_dev1,
                     state_dev0,
                     -- States to support writing the address
                     state_ack_device_write,
                     state_addr7,
                     state_addr6,
                     state_addr5,
                     state_addr4,
                     state_addr3,
                     state_addr2,
                     state_addr1,
                     state_addr0,
                     state_addr_ack,
                     -- States to support the selector device 
                     state_selector_ack_device_write,
                     state_selector_addr7,
                     state_selector_addr6,
                     state_selector_addr5,
                     state_selector_addr4,
                     state_selector_addr3,
                     state_selector_addr2,
                     state_selector_addr1,
                     state_selector_addr0,
                     state_selector_addr_ack,
                     -- States to support reading from the the EDID ROM
                     state_ack_device_read,
                     state_read7,
                     state_read6,
                     state_read5,
                     state_read4,
                     state_read3,
                     state_read2,
                     state_read1,
                     state_read0,
                     state_read_ack);

   signal state           : t_state := state_idle;
   signal data_out_sr     : std_logic_vector(7 downto 0) := (others => '1');
   signal data_shift_reg  : std_logic_vector(7 downto 0) := (others => '0');
   signal addr_reg        : unsigned(7 downto 0) := (others => '0');
   signal selector_reg    : unsigned(7 downto 0) := (others => '0');
   signal data_to_send    : std_logic_vector(7 downto 0) := (others => '0');
   signal data_out_delay  : std_logic_vector(7 downto 0) := (others => '0');
   signal PULL_LOW        : std_logic := '0';
   signal sdat_input      : std_logic := '0';
   signal sdat_delay_last : std_logic := '0';
begin

i_IOBUF: IOBUF
    generic map (
       DRIVE => 12,
       IOSTANDARD => "DEFAULT",
       SLEW => "SLOW")
    port map (
       O  => sdat_input, -- Buffer output
       IO => sdat_raw,   -- Buffer inout port (connect directly to top-level port)
       I  => '0',        -- Buffer input
       T  => data_out_sr(data_out_sr'high)      -- 3-state enable input, high=input, low=output 
    );
    edid_debug(0) <= std_logic(sdat_delay(sdat_delay'high));
    edid_debug(1) <= sclk_raw; 

process(clk)
   begin   
      if rising_edge(clk) then
         
         -- falling edge on SDAT while sclk is held high = START condition
         if sclk_delay(1) = '1' and sclk_delay(0) = '1' and sdat_delay_last  = '1' and sdat_delay(sdat_delay'high) = '0' then
            state <= state_start;
            edid_debug(2) <= '1';
         end if;
         
         -- rising edge on SDAT while sclk is held high = STOP condition
         if sclk_delay(1) = '1' and sclk_delay(0) = '1' and sdat_delay_last = '0' and sdat_delay(sdat_delay'high) = '1' then
            state <= state_idle;
            selector_reg <= (others => '0');
            edid_debug(2) <= '0';
         end if;

         -- rising edge on SCLK - usually a data bit 
         if sclk_delay(1) = '1' and sclk_delay(0) = '0' then
            -- Move data into a shift register
            data_shift_reg <= data_shift_reg(data_shift_reg'high-1 downto 0) & std_logic(sdat_delay(sdat_delay'high));
         end if;
         
         -- falling edge on SCLK - time to change state
         if sclk_delay(1) = '0' and sclk_delay(0) = '1' then
            data_out_sr <= data_out_sr(data_out_sr'high-1 downto 0) & '1'; -- Add Pull up   
            case state is 
               when state_start            => state <= state_dev7;
               when state_dev7             => state <= state_dev6;
               when state_dev6             => state <= state_dev5;
               when state_dev5             => state <= state_dev4;
               when state_dev4             => state <= state_dev3;
               when state_dev3             => state <= state_dev2;
               when state_dev2             => state <= state_dev1;
               when state_dev1             => state <= state_dev0;
               when state_dev0             => if data_shift_reg = x"A1" then
                                                 state <= state_ack_device_read;
                                                 data_out_sr(data_out_sr'high) <= '0'; -- Send Slave ACK
                                              elsif data_shift_reg = x"A0" then
                                                 state <= state_ack_device_write;
                                                 data_out_sr(data_out_sr'high) <= '0'; -- Send Slave ACK
                                              elsif data_shift_reg = x"60" then
                                                 state <= state_selector_ack_device_write;
                                                 data_out_sr(data_out_sr'high) <= '0'; -- Send Slave ACK
                                              else
                                                 state <= state_idle;
                                              end if;               
               when state_ack_device_write => state <= state_addr7;
               when state_addr7            => state <= state_addr6;
               when state_addr6            => state <= state_addr5;
               when state_addr5            => state <= state_addr4;
               when state_addr4            => state <= state_addr3;
               when state_addr3            => state <= state_addr2;
               when state_addr2            => state <= state_addr1;
               when state_addr1            => state <= state_addr0;
               when state_addr0            => state <= state_addr_ack;
                                              addr_reg  <= unsigned(data_shift_reg);
                                              data_out_sr(data_out_sr'high) <= '0'; -- Send Slave ACK
               when state_addr_ack         => state <= state_idle;   -- SLave ACK and ignore any written data
                ------------------------------------
                -- Process the write to the selector
                ------------------------------------
               when state_selector_ack_device_write => state <= state_selector_addr7;
               when state_selector_addr7            => state <= state_selector_addr6;
               when state_selector_addr6            => state <= state_selector_addr5;
               when state_selector_addr5            => state <= state_selector_addr4;
               when state_selector_addr4            => state <= state_selector_addr3;
               when state_selector_addr3            => state <= state_selector_addr2;
               when state_selector_addr2            => state <= state_selector_addr1;
               when state_selector_addr1            => state <= state_selector_addr0;
               when state_selector_addr0            => state <= state_selector_addr_ack;
                                              selector_reg  <= unsigned(data_shift_reg(7 downto 0));
                                              data_out_sr(data_out_sr'high) <= '0'; -- Send Slave ACK
               when state_selector_addr_ack         => state <= state_idle;   -- SLave ACK and ignore any written data
               -------------------------

               when state_ack_device_read  => state <= state_read7;
                                              data_out_sr <=  edid_rom(to_integer(addr_reg));
               when state_read7            => state <= state_read6;
               when state_read6            => state <= state_read5;
               when state_read5            => state <= state_read4;
               when state_read4            => state <= state_read3;
               when state_read3            => state <= state_read2;
               when state_read2            => state <= state_read1;
               when state_read1            => state <= state_read0;
               when state_read0            => state <= state_read_ack; 
               when state_read_ack         => if sdat_delay(sdat_delay'high) = '0' then 
                                                 state <= state_read7;
                                                 data_out_sr <=  edid_rom(to_integer(addr_reg+1));
                                              else 
                                                 state <= state_idle;
                                              end if;                     
                                              addr_reg <= addr_reg+1;
               when others                 => state <= state_idle;
            end case;
         end if;
        sdat_delay_last <= sdat_delay(sdat_delay'high);
         -- Synchronisers for SCLK and SDAT
         sclk_delay <= sclk_raw & sclk_delay(sclk_delay'high downto 1);
         -- Resolve any 'Z' state in simulation - make it pull up. 
         if sdat_input = '0'  then 
            if sdat_delay(sdat_delay'high) = '1' then 
                sdat_delay <= sdat_delay - 1;
            else
                sdat_delay <= (others => '0');
            end if; 
         else
            if sdat_delay(sdat_delay'high) = '0' then 
                 sdat_delay <= sdat_delay + 1;
             else
                 sdat_delay <= (others => '1');
             end if; 
         end if;
      end if;
   end process;
end architecture;
