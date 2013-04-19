--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:54:14 01/27/2013
-- Design Name:   
-- Module Name:   /home/steffen/Xilinx/DDR3-Network/par/header_checksum_TB.vhd
-- Project Name:  test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: calc_ipv4_checksum
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY header_checksum_TB IS
END header_checksum_TB;
 
ARCHITECTURE behavior OF header_checksum_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT calc_ipv4_checksum
    PORT(
         clk : IN  std_logic;
         data : IN  std_logic_vector(159 downto 0);
         ready : OUT  std_logic;
         checksum : OUT  std_logic_vector(15 downto 0);
         reset : IN  std_logic
        );
    END COMPONENT;
    
	function invert (S : std_logic_vector) return std_logic_vector is
	  variable Y : std_logic_vector(S'range);
		begin
		  for i in S'range loop
			 Y(i) := S(S'high-i);
		  end loop;

		  return Y;
	end function;

   --Inputs
   signal clk : std_logic := '0';
   signal data : std_logic_vector(159 downto 0) := (others => '0');

   signal reset : std_logic := '0';

 	--Outputs
   signal ready : std_logic;
   signal checksum : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	constant length_ethernet_frame    : integer := 12; 
	type array_network is array (0 to length_ethernet_frame-1) of std_logic_vector(31 downto 0); 
	signal eth_array : array_network;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: calc_ipv4_checksum PORT MAP (
          clk => clk,
          data => data,
          ready => ready,
          checksum => checksum,
          reset => reset
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
				-- PC eth1 has the following MAC addr: 00:1d:7e:01:86:09
		eth_array(0) <= x"001d7e01";
						-- MAC (PC) | now MAC (FPGA)
		eth_array(1) <= x"8609" & x"001d";
							-- MAC (FPGA)
		eth_array(2) <= x"7e018619";
							--  ethernet type      | Version / Header length | diff Services 
		eth_array(3) <= "00001000"&"00000000" & "0100" & "0101"         & "00000000"    ;
							-- total length        |  identification
		eth_array(4) <= "00000000"&"00100010" & x"0000";
							-- Flags , Fragment Offeset  | time to live | protocol
		eth_array(5) <= "0100000000000000"          &  "01000000"  & "00010001";
							-- header checksum |  Source IP: 192  |  168
		--eth_array(6) <= x"b777"           &            x"C0" & x"A8";
		eth_array(6) <= x"b777"           &            x"C0" & x"A8";
							-- 1   |  1    | Destin IP: 192  | 168
		eth_array(7) <= x"01" & x"01" &           x"C0" & x"A8";
							-- 1   |   2   | source port
		eth_array(8) <= x"01" & x"02" &  x"1FA4" ;
							-- dest port | length
		eth_array(9) <= x"1FA4"     & "00000000" & "00001110" ;
							-- checksum |  data
		eth_array(10) <= x"1944"    &  x"4865";
							-- data
		eth_array(11) <= x"6c6c6f20";
		
		wait for 10ns;
		
		--data <= invert( x"45000073000040004011b861c0a80001c0a800c7" );
		--data <= x"00c7c0a80001c0a8b86140114000000000734500" ;
		data <= eth_array(8)(31 downto 16) & eth_array(7) & eth_array(6) &
				eth_array(5) & eth_array(4)& eth_array(3)(15 downto 0);
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
