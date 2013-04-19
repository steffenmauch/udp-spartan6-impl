--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:26:01 01/22/2013
-- Design Name:   
-- Module Name:   /home/steffen/Xilinx/DDR3-Network/par/tb_ethernet.vhd
-- Project Name:  test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MAC_top
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
 
ENTITY tb_ethernet IS
END tb_ethernet;
 
ARCHITECTURE behavior OF tb_ethernet IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MAC_top
    PORT(
         Reset : IN  std_logic;
         Clk_125M : IN  std_logic;
         Clk_user : IN  std_logic;
         Clk_reg : IN  std_logic;
         Speed : OUT  std_logic_vector(2 downto 0);
         Rx_mac_ra : OUT  std_logic;
         Rx_mac_rd : IN  std_logic;
         Rx_mac_data : OUT  std_logic_vector(31 downto 0);
         Rx_mac_BE : OUT  std_logic_vector(1 downto 0);
         Rx_mac_pa : OUT  std_logic;
         Rx_mac_sop : OUT  std_logic;
         Rx_mac_eop : OUT  std_logic;
         Tx_mac_wa : OUT  std_logic;
         Tx_mac_wr : IN  std_logic;
         Tx_mac_data : IN  std_logic_vector(31 downto 0);
         Tx_mac_BE : IN  std_logic_vector(1 downto 0);
         Tx_mac_sop : IN  std_logic;
         Tx_mac_eop : IN  std_logic;
         Pkg_lgth_fifo_rd : IN  std_logic;
         Pkg_lgth_fifo_ra : OUT  std_logic;
         Pkg_lgth_fifo_data : OUT  std_logic_vector(15 downto 0);
         Gtx_clk : OUT  std_logic;
         Rx_clk : IN  std_logic;
         Tx_clk : IN  std_logic;
         Tx_er : OUT  std_logic;
         Tx_en : OUT  std_logic;
         Txd : OUT  std_logic_vector(7 downto 0);
         Rx_er : IN  std_logic;
         Rx_dv : IN  std_logic;
         Rxd : IN  std_logic_vector(7 downto 0);
         Crs : IN  std_logic;
         Col : IN  std_logic;
         CSB : IN  std_logic;
         WRB : IN  std_logic;
         CD_in : IN  std_logic_vector(15 downto 0);
         CD_out : OUT  std_logic_vector(15 downto 0);
         CA : IN  std_logic_vector(7 downto 0);
         Mdo : OUT  std_logic;
         MdoEn : OUT  std_logic;
         Mdi : IN  std_logic;
         Mdc : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Reset : std_logic := '0';
   signal Clk_125M : std_logic := '0';
   signal Clk_user : std_logic := '0';
   signal Clk_reg : std_logic := '0';
   signal Rx_mac_rd : std_logic := '0';
   signal Tx_mac_wr : std_logic := '0';
   signal Tx_mac_data : std_logic_vector(31 downto 0) := (others => '0');
   signal Tx_mac_BE : std_logic_vector(1 downto 0) := (others => '0');
   signal Tx_mac_sop : std_logic := '0';
   signal Tx_mac_eop : std_logic := '0';
   signal Pkg_lgth_fifo_rd : std_logic := '0';
   signal Rx_clk : std_logic := '0';
   signal Tx_clk : std_logic := '0';
   signal Rx_er : std_logic := '0';
   signal Rx_dv : std_logic := '0';
   signal Rxd : std_logic_vector(7 downto 0) := (others => '0');
   signal Crs : std_logic := '0';
   signal Col : std_logic := '0';
   signal CSB : std_logic := '0';
   signal WRB : std_logic := '0';
   signal CD_in : std_logic_vector(15 downto 0) := (others => '0');
   signal CA : std_logic_vector(7 downto 0) := (others => '0');
   signal Mdi : std_logic := '0';

 	--Outputs
   signal Speed : std_logic_vector(2 downto 0);
   signal Rx_mac_ra : std_logic;
   signal Rx_mac_data : std_logic_vector(31 downto 0);
   signal Rx_mac_BE : std_logic_vector(1 downto 0);
   signal Rx_mac_pa : std_logic;
   signal Rx_mac_sop : std_logic;
   signal Rx_mac_eop : std_logic;
   signal Tx_mac_wa : std_logic;
   signal Pkg_lgth_fifo_ra : std_logic;
   signal Pkg_lgth_fifo_data : std_logic_vector(15 downto 0);
   signal Gtx_clk : std_logic;
   signal Tx_er : std_logic;
   signal Tx_en : std_logic;
   signal Txd : std_logic_vector(7 downto 0);
   signal CD_out : std_logic_vector(15 downto 0);
   signal Mdo : std_logic;
   signal MdoEn : std_logic;
   signal Mdc : std_logic;

   -- Clock period definitions
   constant Clk_125M_period : time := 8 ns;
   constant Clk_user_period : time := 20 ns;
   constant Clk_reg_period : time := 20 ns;
   constant Gtx_clk_period : time := 8 ns;
   constant Rx_clk_period : time := 8 ns;
   constant Tx_clk_period : time := 8 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MAC_top PORT MAP (
          Reset => Reset,
          Clk_125M => Clk_125M,
          Clk_user => Clk_user,
          Clk_reg => Clk_reg,
          Speed => Speed,
          Rx_mac_ra => Rx_mac_ra,
          Rx_mac_rd => Rx_mac_rd,
          Rx_mac_data => Rx_mac_data,
          Rx_mac_BE => Rx_mac_BE,
          Rx_mac_pa => Rx_mac_pa,
          Rx_mac_sop => Rx_mac_sop,
          Rx_mac_eop => Rx_mac_eop,
          Tx_mac_wa => Tx_mac_wa,
          Tx_mac_wr => Tx_mac_wr,
          Tx_mac_data => Tx_mac_data,
          Tx_mac_BE => Tx_mac_BE,
          Tx_mac_sop => Tx_mac_sop,
          Tx_mac_eop => Tx_mac_eop,
          Pkg_lgth_fifo_rd => Pkg_lgth_fifo_rd,
          Pkg_lgth_fifo_ra => Pkg_lgth_fifo_ra,
          Pkg_lgth_fifo_data => Pkg_lgth_fifo_data,
          Gtx_clk => Gtx_clk,
          Rx_clk => Rx_clk,
          Tx_clk => Tx_clk,
          Tx_er => Tx_er,
          Tx_en => Tx_en,
          Txd => Txd,
          Rx_er => Rx_er,
          Rx_dv => Rx_dv,
          Rxd => Rxd,
          Crs => Crs,
          Col => Col,
          CSB => CSB,
          WRB => WRB,
          CD_in => CD_in,
          CD_out => CD_out,
          CA => CA,
          Mdo => Mdo,
          MdoEn => MdoEn,
          Mdi => Mdi,
          Mdc => Mdc
        );

   -- Clock process definitions
   Clk_125M_process :process
   begin
		Clk_125M <= '0';
		wait for Clk_125M_period/2;
		Clk_125M <= '1';
		wait for Clk_125M_period/2;
   end process;
 
   Clk_user_process :process
   begin
		Clk_user <= '0';
		wait for Clk_user_period/2;
		Clk_user <= '1';
		wait for Clk_user_period/2;
   end process;
 
   Clk_reg_process :process
   begin
		Clk_reg <= '0';
		wait for Clk_reg_period/2;
		Clk_reg <= '1';
		wait for Clk_reg_period/2;
   end process;
 
   Gtx_clk_process :process
   begin
		Gtx_clk <= '0';
		wait for Gtx_clk_period/2;
		Gtx_clk <= '1';
		wait for Gtx_clk_period/2;
   end process;
 
   Rx_clk_process :process
   begin
		Rx_clk <= '0';
		wait for Rx_clk_period/2;
		Rx_clk <= '1';
		wait for Rx_clk_period/2;
   end process;
 
   Tx_clk_process :process
   begin
		Tx_clk <= '0';
		wait for Tx_clk_period/2;
		Tx_clk <= '1';
		wait for Tx_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';
      wait for Clk_125M_period*10;
		Tx_mac_sop <= '1';
		Tx_mac_eop <= '0';
		Tx_mac_wr <= '1';
      wait for Clk_125M_period*10;
		Tx_mac_sop <= '0';
		Tx_mac_eop <= '1';
		Tx_mac_wr <= '1';
      wait for Clk_125M_period*1;
		Tx_mac_sop <= '0';
		Tx_mac_eop <= '1';
		Tx_mac_wr <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
