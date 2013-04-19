----------------------------------------------------------------------
-- Title      : UDP network implementation with tri mac core from opencore
-- Project    : 
----------------------------------------------------------------------
-- File       : example_top.vhd
-- Author     : Steffen Mauch
-- Company    : TU Ilmenau
-- Created    : 2013-02-03
-- Last update: 2013-04-19
-- Platform   : ISE 13.4
-- Standard   : VHDL'93
----------------------------------------------------------------------
-- Description: 
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2013 Steffen Mauch                             ----
----     steffen.mauch (at) gmail.com                             ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity example_top is
  port(
	Ethernet_COL			: in std_logic;
	Ethernet_CRS			: in std_logic;
	Ethernet_MDC			: out std_logic;
	Ethernet_MDIO			: inout std_logic;
	Ethernet_MII_TX_CLK	: in std_logic;
	Ethernet_PHY_RST_N	: out std_logic;
	Ethernet_RXD			: in std_logic_vector( 7 downto 0 );
	Ethernet_RX_CLK		: in std_logic;
	Ethernet_RX_DV			: in std_logic;
	Ethernet_RX_ER			: in std_logic;
	Ethernet_TXD			: out std_logic_vector( 7 downto 0 );
	Ethernet_TX_CLK 		: out std_logic;
	Ethernet_TX_EN			: out std_logic;
	Ethernet_TX_ER			: out std_logic;

   LED						: out std_logic_vector( 3 downto 0);

   c3_sys_clk           : in  std_logic;
   c3_sys_rst_i         : in  std_logic
  );
end example_top;

architecture arc of example_top is	
	
	component MAC_top
	port(
		--//system signals
		Reset		: in std_logic;
		Clk_125M	: in std_logic;
		Clk_user	: in std_logic;
		Clk_reg	: in std_logic;
		Speed		: out std_logic_vector( 2 downto 0);
		--//user interface 
		Rx_mac_ra 	: out std_logic;
		Rx_mac_rd	: in std_logic;
		Rx_mac_data	: out std_logic_vector( 31 downto 0 );
		Rx_mac_BE	: out std_logic_vector( 1 downto 0 );
		Rx_mac_pa	: out std_logic;
		Rx_mac_sop	: out std_logic;
		Rx_mac_eop	: out std_logic;
		--//user interface
		Tx_mac_wa	: out std_logic;
		Tx_mac_wr	: in std_logic;
		Tx_mac_data	: in std_logic_vector( 31 downto 0 );
		Tx_mac_BE	: in std_logic_vector( 1 downto 0 );--//big endian
		Tx_mac_sop	: in std_logic;
		Tx_mac_eop	: in std_logic;
		--//pkg_lgth fifo
		Pkg_lgth_fifo_rd		: in std_logic;
		Pkg_lgth_fifo_ra		: out std_logic;
		Pkg_lgth_fifo_data	: out std_logic_vector( 15 downto 0 );
		--//Phy interface
		--//Phy interface
		Gtx_clk	: out std_logic;--//used only in GMII mode
		Rx_clk	: in std_logic;
		Tx_clk	: in std_logic; --//used only in MII mode
		Tx_er		: out std_logic;
		Tx_en		: out std_logic;
		Txd		: out std_logic_vector( 7 downto 0 );
		Rx_er		: in std_logic;
		Rx_dv		: in std_logic;
		Rxd		: in std_logic_vector( 7 downto 0 );
		Crs		: in std_logic;
		Col		: in std_logic;
		--//host interface
		CSB		: in std_logic;
		WRB		: in std_logic;
		CD_in		: in std_logic_vector( 15 downto 0 );
		CD_out	: out std_logic_vector( 15 downto 0 );
		CA	: in std_logic_vector( 7 downto 0 );
		--//mdx
		Mdo	: out std_logic; --// MII Management Data Output
		MdoEn	: out std_logic; --// MII Management Data Output Enable
		Mdi	: in std_logic;
		Mdc	: out std_logic --// MII Management Data Clock
	); 
	end component;

	component dcm
	port(-- Clock in ports
		  dcm_125mhz_in           : in     std_logic;
		  -- Clock out ports
		  dcm_125mhz          : out    std_logic;
		  dcm_50mhz          : out    std_logic;
		  dcm_25mhz          : out    std_logic;
		  dcm_6_25mhz          : out    std_logic;
		  dcm_3_125mhz          : out    std_logic;
		  -- Status and control signals
		  RESET             : in     std_logic;
		  LOCKED            : out    std_logic
		 );
	end component;

	component calc_ipv4_checksum
	port ( 
		clk : in  STD_LOGIC;
      data : in  STD_LOGIC_VECTOR (159 downto 0);
		ready : out STD_LOGIC;
      checksum : out  STD_LOGIC_VECTOR (15 downto 0);
      reset : in  STD_LOGIC);
	end component;
  
  
	attribute S: string;
	attribute keep : string;

	signal  c3_rst0                                  : std_logic;	
	signal c3_sys_clk_ibufg 	: std_logic;
	signal clk_125mhz : std_logic;
	signal clk_50mhz : std_logic;
	signal clk_25mhz : std_logic;
	signal clk_6_25mhz : std_logic;
	signal clk_3_125mhz : std_logic;
	signal reset : std_logic;
	

	signal locked : std_logic;


	signal Rx_mac_ra 	: std_logic;
	attribute S of Rx_mac_ra : signal is "TRUE";
	signal Rx_mac_rd	: std_logic;
	attribute S of Rx_mac_rd : signal is "TRUE";
	signal Rx_mac_data: std_logic_vector( 31 downto 0 );
	attribute S of Rx_mac_data : signal is "TRUE";
   signal Rx_mac_BE	: std_logic_vector( 1 downto 0 );
	attribute S of Rx_mac_BE : signal is "TRUE";
	signal Rx_mac_pa	: std_logic;
	attribute S of Rx_mac_pa : signal is "TRUE";
	signal Rx_mac_sop	: std_logic;
	attribute S of Rx_mac_sop : signal is "TRUE";
	signal Rx_mac_eop	: std_logic;
	attribute S of Rx_mac_eop : signal is "TRUE";
	
	--//user interface
	signal Tx_mac_wa	: std_logic;
	attribute S of Tx_mac_wa : signal is "TRUE";
	signal Tx_mac_wr	: std_logic;
	attribute S of Tx_mac_wr : signal is "TRUE";
	signal Tx_mac_data: std_logic_vector( 31 downto 0 );
	attribute S of Tx_mac_data : signal is "TRUE";
	signal Tx_mac_BE	: std_logic_vector( 1 downto 0 );--//big endian
	attribute S of Tx_mac_BE : signal is "TRUE";
	signal Tx_mac_sop	: std_logic;
	attribute S of Tx_mac_sop : signal is "TRUE";
	signal Tx_mac_eop	: std_logic;
	attribute S of Tx_mac_eop : signal is "TRUE";
	--//pkg_lgth fifo
	signal Pkg_lgth_fifo_rd		: std_logic;
	signal Pkg_lgth_fifo_ra		: std_logic;
	signal Pkg_lgth_fifo_data	: std_logic_vector( 15 downto 0 );

	signal CSB		: std_logic;
	signal WRB		: std_logic;
	signal CD_in	: std_logic_vector( 15 downto 0 );
	signal CD_out	: std_logic_vector( 15 downto 0 );
	signal CA		: std_logic_vector( 7 downto 0 );
	--//mdx
	signal Mdo		: std_logic; --// MII Management Data Output
	signal MdoEn	: std_logic; --// MII Management Data Output Enable
	signal Mdi		: std_logic;

	signal ethernet_speed : std_logic_vector( 2 downto 0);
	attribute S of ethernet_speed : signal is "TRUE";

	signal Ethernet_TX_CLK_buf	: std_logic;
	
	
	
	type state_type_ethernet is (arp,arp_wait,idle,wait_state,wait_state2);  --type of state machine.
	signal state_ethernet : state_type_ethernet;  --current and next state declaration.
	
   constant length_ethernet_frame    : integer := 12; 
	constant length_ethernet_arp_frame    : integer := 11;
	constant length_ethernet_arp_request_frame    : integer := 11;
	
	type array_network is array (0 to length_ethernet_frame-1) of std_logic_vector(31 downto 0); 
	type array_network_arp is array (0 to length_ethernet_arp_frame-1) of std_logic_vector(31 downto 0); 
	type array_network_arp_request is array (0 to length_ethernet_arp_request_frame-1) of std_logic_vector(31 downto 0); 
	signal eth_array : array_network; 
	signal arp_array : array_network_arp; 
	signal arp_request_array : array_network_arp_request; 
	signal counter_ethernet : integer range 0 to length_ethernet_frame-1;
	
	
	
	signal Rx_clk 	: std_logic;
	attribute S of Rx_clk : signal is "TRUE";
	signal Tx_clk 	: std_logic;
	attribute S of Tx_clk : signal is "TRUE";	
	signal Tx_er	: std_logic;
	attribute S of Tx_er : signal is "TRUE";
	signal Tx_en	: std_logic;
	attribute S of Tx_en : signal is "TRUE";
	signal Txd		: std_logic_vector( 7 downto 0 );
	attribute S of Txd : signal is "TRUE";
	signal Rx_er	: std_logic;
	attribute S of Rx_er : signal is "TRUE";
	signal Rx_dv	: std_logic;
	attribute S of Rx_dv : signal is "TRUE";
	signal Rxd		: std_logic_vector( 7 downto 0 );
	attribute S of Rxd : signal is "TRUE";

	signal MDC_sig		: std_logic;

	signal calc_checksum		: std_logic_vector( 15 downto 0);
	attribute S of calc_checksum : signal is "TRUE";
	
	signal LED_sig : std_logic;
	attribute S of LED_sig : signal is "TRUE";

	signal counter_ethernet_delay : integer range 0 to 2**31-1;
	
	signal counter_ethernet_rec : integer range 0 to 15;
	signal packet_valid : std_logic;
	attribute S of packet_valid : signal is "TRUE";
	
	signal LED_data : std_logic_vector( 3 downto 0);
	attribute S of LED_data : signal is "TRUE";
	
	signal Rx_mac_rd_sig : std_logic;


	signal arp_valid_response 	: std_logic;
	signal arp_valid_response_recieved 	: std_logic;
	signal arp_valid 	: std_logic;
	attribute S of arp_valid : signal is "TRUE";

	signal arp_mac 	: std_logic_vector(47 downto 0);
	attribute S of arp_mac : signal is "TRUE";

	signal arp_ip		: std_logic_vector(31 downto 0);
	attribute S of arp_ip : signal is "TRUE";

	signal arp_send 	: std_logic;
	attribute S of arp_send : signal is "TRUE";

	signal arp_clear 	: std_logic;
	attribute S of arp_clear : signal is "TRUE";


	-- signal for destination MAC address
	signal dst_mac_addr : std_logic_vector( 47 downto 0 );
	
	-- definition of our own MAC address
	constant mac_addr : std_logic_vector( 47 downto 0 ) := x"002d7e018619";
	-- definition of our own IP address
	constant own_ip_addr : std_logic_vector( 31 downto 0 ) := x"c0a80101";
	-- definition of destination IP address
	constant dst_ip_addr : std_logic_vector( 31 downto 0 ) := x"c0a80102";
	
	constant source_port : std_logic_vector( 15 downto 0 ) := x"1FA4";
	constant dest_port 	: std_logic_vector( 15 downto 0 ) := x"1FA4";

begin
	 
	ibufg_sysclk : IBUFG
		port map (
			I  => c3_sys_clk,
         O  => c3_sys_clk_ibufg
	);
	
	dcm_inst : dcm
		port map(-- Clock in ports
		  dcm_125mhz_in         => c3_sys_clk_ibufg,
		  -- Clock out ports
		  dcm_125mhz         => clk_125mhz,
		  dcm_50mhz          => clk_50mhz,
		  dcm_25mhz          => clk_25mhz,
		  dcm_6_25mhz			=> clk_6_25mhz,
		  dcm_3_125mhz			=> clk_3_125mhz,
		  -- Status and control signals
		  RESET             => c3_sys_rst_i,
		  LOCKED            => locked
	);

	reset <= not locked;

	-- settings for ethernet MAC
	Ethernet_MAC_top : MAC_top
	port map(
		--//system signals
		Reset		=> reset,
		Clk_125M	=> clk_125mhz,
		Clk_user	=> clk_50mhz,--!!!!!!!!!!!
		Clk_reg	=> clk_50mhz,--!!!!!!!!!!!
		
		-- speed settings after opencore tri-mode (PDF)!
		-- b100 : 1000Mbit
		-- b010 :  100Mbit
		-- b001 :   10Mbit
		Speed		=> ethernet_speed,
		
		--//user interface 
		Rx_mac_ra 	=> Rx_mac_ra,
		Rx_mac_rd	=> Rx_mac_rd,
		Rx_mac_data	=> Rx_mac_data,
		Rx_mac_BE	=> Rx_mac_BE,
		Rx_mac_pa	=> Rx_mac_pa,
		Rx_mac_sop	=> Rx_mac_sop,
		Rx_mac_eop	=> Rx_mac_eop,
		--//user interface
		Tx_mac_wa	=> Tx_mac_wa,
		Tx_mac_wr	=> Tx_mac_wr,
		Tx_mac_data	=> Tx_mac_data,
		Tx_mac_BE	=> Tx_mac_BE, --//big endian
		Tx_mac_sop	=> Tx_mac_sop,
		Tx_mac_eop	=> Tx_mac_eop,
		
		--//pkg_lgth fifo
		-- signals for FIFO implementation of RX in core
		-- with clock Clk_user!!
		Pkg_lgth_fifo_rd		=> Pkg_lgth_fifo_rd,
		Pkg_lgth_fifo_ra		=> Pkg_lgth_fifo_ra,
		Pkg_lgth_fifo_data	=> Pkg_lgth_fifo_data,

		--//Phy interface
		Gtx_clk	=> Ethernet_TX_CLK_buf,--//used only in GMII mode
		Crs		=> Ethernet_CRS,
		Col		=> Ethernet_COL,
		
		Rx_clk	=> Rx_clk,
		--Tx_clk	=> Tx_clk, --//used only in MII mode
		Tx_clk	=> Ethernet_MII_TX_CLK, --//used only in MII mode
		--Tx_clk	=> '0',
		Tx_er		=> Tx_er,
		Tx_en		=> Tx_en,
		Txd		=> Txd,
		Rx_er		=> Rx_er,
		Rx_dv		=> Rx_dv,
		Rxd		=> Rxd,

		
		--//host interface
		CSB		=> CSB,
		WRB		=> WRB,
		CD_in		=> CD_in,
		CD_out	=> CD_out,
		CA			=> CA,
		
		--//mdx
		Mdo		=> Mdo, --// MII Management Data Output
		MdoEn		=> MdoEn, --// MII Management Data Output Enable
		Mdi		=> Mdi,
		Mdc		=> MDC_sig --// MII Management Data Clock
	); 
	
	-- be careful!
	Ethernet_PHY_RST_N <= not reset;
	
	Ethernet_TX_ER <= Tx_er;
	Ethernet_TX_EN <= Tx_en;
	Ethernet_TXD <= Txd;
	
	Rx_er <= Ethernet_RX_ER;
	Rx_dv <= Ethernet_RX_DV;
	Rxd <= Ethernet_RXD;
	Rx_clk <= Ethernet_RX_CLK;

	
	MDIO_process : process(MdoEn)
	begin
		if( MdoEn = '1' ) then
			Ethernet_MDIO <= Mdo;
		else
			Mdi <= Ethernet_MDIO;
		end if;
		
	end process;

	--LED(3) <= Ethernet_MDIO;
	--LED(2) <= Ethernet_MDIO;
	--LED(1) <= ethernet_speed(1);
	--LED(0) <= MDC_sig;
	
	Ethernet_MDC <= Ethernet_MDIO;
	
	CSB	<= '0';
	WRB	<= '1';
	
	calc_ipv4_checksum_inst : calc_ipv4_checksum
	port map (
		clk => clk_50mhz,--!!!!!!!!!!!
      data => eth_array(8)(31 downto 16) & eth_array(7) & eth_array(6) &
				eth_array(5) & eth_array(4)& eth_array(3)(15 downto 0),
		--ready : out STD_LOGIC;
      checksum => calc_checksum,
      reset => reset
	);
	
	Rx_mac_rd <= Rx_mac_rd_sig AND Rx_mac_ra;
	
	ethernet_data_rec_process : process(c3_rst0,clk_50mhz)
	begin
		if( c3_rst0 = '1' ) then
			counter_ethernet_rec <= 0;
			packet_valid <= '0';
			Rx_mac_rd_sig <= '0';
			
			arp_send <= '0';
			arp_mac <= (others => '0');
			arp_ip <= (others => '0');
			dst_mac_addr <= (others => '0');
			arp_valid <= '0';
			arp_valid_response <= '0';
			arp_valid_response_recieved <= '0';
		elsif( rising_edge(clk_50mhz) ) then
			Rx_mac_rd_sig <= '0';
			
			if( arp_clear = '1' ) then
				arp_send <= '0';
			end if;
			
			if( Rx_mac_ra = '1' ) then
				
				Rx_mac_rd_sig <= '1';
				if( Rx_mac_pa = '1' ) then
					
					counter_ethernet_rec <= counter_ethernet_rec+1;
					
					-- check if dest. is our FPGA device!!
					-- when true then packet_valid is high else low
					if( counter_ethernet_rec = 0 ) then
						if( Rx_mac_data = mac_addr(47 downto 16) ) then
							packet_valid <= '1';
						else
							packet_valid <= '0';
						end if;
					elsif( counter_ethernet_rec = 1 ) then
						if( Rx_mac_data(31 downto 16) = mac_addr(15 downto 0) ) then
							packet_valid <= '1';
						else
							packet_valid <= '0';
						end if;
					end if;
					
					-- check if it is an ARP request, then arp_valid = '1'!!
					if( counter_ethernet_rec = 3 ) then
						--if( Rx_mac_data = ( x"0806" & x"0001" ) AND arp_send = '0' ) then
						if( Rx_mac_data = ( x"0806" & x"0001" ) ) then
							arp_valid <= '1';
						else
							arp_valid <= '0';
						end if;
					end if;
					
					-- if ARP request, process packet further
					if( arp_valid = '1' ) then
						if( counter_ethernet_rec = 4 ) then
							if( Rx_mac_data = ( x"0800" & x"06" & x"04" ) ) then
								arp_valid <= '1';
							else
								arp_valid <= '0';
							end if;
							
						elsif( counter_ethernet_rec = 5 ) then
							if( Rx_mac_data(31 downto 16) = x"0001" ) then 
								arp_valid <= '1';
								arp_mac(47 downto 32) <= Rx_mac_data(15 downto 0);
							elsif( Rx_mac_data(31 downto 16) = x"0002" ) then
								arp_valid_response <= '1';
								arp_mac(47 downto 32) <= Rx_mac_data(15 downto 0);
								arp_valid <= '1';
							else
								arp_valid <= '0';
							end if;
							
						elsif( counter_ethernet_rec = 6 ) then	
							arp_mac(31 downto 0) <= Rx_mac_data;
							
						elsif( counter_ethernet_rec = 7 ) then
							arp_ip <= Rx_mac_data;
							arp_valid_response <= '0';
							if( Rx_mac_data = dst_ip_addr ) then
								arp_valid_response <= '1';
							end if;
							
						elsif( counter_ethernet_rec = 8 ) then
							arp_valid_response <= '0';
							if( Rx_mac_data = mac_addr(47 downto 16) ) then
								arp_valid_response <= '1';
							end if;
							
						elsif( counter_ethernet_rec = 9 ) then
							if( Rx_mac_data(15 downto 0) = own_ip_addr(31 downto 16) ) then
								arp_valid <= '1';
							else
								arp_valid <= '0';
							end if;
							
							arp_valid_response <= '0';
							if( Rx_mac_data(31 downto 16) = mac_addr(15 downto 0) ) then
								arp_valid_response <= '1';
							end if;
							
						elsif( counter_ethernet_rec = 10 ) then
							arp_valid <= '0';
							arp_valid_response <= '0';
							if( Rx_mac_data(31 downto 16) = own_ip_addr(15 downto 0) ) then
								if( arp_valid_response = '1' ) then
									arp_valid_response_recieved <= '1';
									arp_send <= '0';
									dst_mac_addr <= arp_mac;
								else
									arp_send <= '1';
									arp_valid_response_recieved <= '0';
								end if;
							end if;		
							
						end if;
					end if;
						
				end if;

			else
				counter_ethernet_rec <= 0;
			end if;

		end if;
	
	end process;
		
	LED <= LED_data;

	led_process : process(c3_rst0,clk_50mhz)
	begin
		if( c3_rst0 = '1' ) then
			LED_data <= (others => '0');
			LED_sig <= '0';
		elsif( falling_edge(clk_50mhz) ) then
				if( counter_ethernet_rec = 10 and packet_valid = '1' ) then
					LED_data <= Rx_mac_data( 11 downto 8 );
					LED_sig <= '1';
				else
					LED_sig <= '0';
				end if;
		end if;
	end process;
	
	
	
	ethernet_data_process : process(c3_rst0,clk_50mhz)
	begin
		Tx_mac_BE <= "00";
		
		-- UDP packet
		eth_array(0) <= dst_mac_addr(47 downto 16);
		eth_array(1) <= dst_mac_addr(15 downto 0) & mac_addr(47 downto 32);
		eth_array(2) <= mac_addr(31 downto 0);
						--  ethernet type    | Version / Header length | diff Services 
		eth_array(3) <= x"0800"          & "0100" & "0101"         & "00000000"    ;
							-- total length        |  identification
		eth_array(4) <= "00000000"&"00100010" & x"0000";
							-- Flags , Fragment Offeset  | time to live | protocol
		eth_array(5) <= "0100000000000000"          &  "01000000"  & "00010001";
							-- header checksum |  Source IP:
		eth_array(6) <= calc_checksum     &  own_ip_addr(31 downto 16);
							--          			     |  Destin IP: 
		eth_array(7) <= own_ip_addr(15 downto 0) &  dst_ip_addr(31 downto 16);
							--             				| source port
		eth_array(8) <= dst_ip_addr(15 downto 0)  &  source_port ;
							-- dest port | length
		eth_array(9) <= dest_port   & "00000000" & "00001110" ;
							-- checksum  |  data
		eth_array(10) <= x"0000"    &  x"4865";
							-- data
		eth_array(11) <= x"6c6c6f20";
	
		-- answer to ARP request from any computer
		arp_array(0) <= arp_mac(47 downto 16);
		arp_array(1) <= arp_mac(15 downto 0) & mac_addr(47 downto 32);
		arp_array(2) <= mac_addr(31 downto 0);
		arp_array(3) <= x"0806" & x"0001";
		arp_array(4) <= x"0800" & x"06" & x"04";
		arp_array(5) <= x"0002" & mac_addr(47 downto 32);
		arp_array(6) <= mac_addr(31 downto 0);
		arp_array(7) <= own_ip_addr;
		arp_array(8) <= arp_mac(47 downto 16);
		arp_array(9) <= arp_mac(15 downto 0) & arp_ip(31 downto 16);
		arp_array(10) <= arp_ip(15 downto 0) & x"0000";
		
		-- init ARP request array
		arp_request_array(0) <= x"FFFFFFFF";
		arp_request_array(1) <= x"FFFF" & mac_addr(47 downto 32);
		arp_request_array(2) <= mac_addr(31 downto 0);
		arp_request_array(3) <= x"0806" & x"0001";
		arp_request_array(4) <= x"0800" & x"06" & x"04";
		arp_request_array(5) <= x"0001" & mac_addr(47 downto 32);
		arp_request_array(6) <= mac_addr(31 downto 0);
		arp_request_array(7) <= own_ip_addr;
		arp_request_array(8) <= x"00000000";
		arp_request_array(9) <= x"0000" & dst_ip_addr(31 downto 16);
		arp_request_array(10) <= dst_ip_addr(15 downto 0) & x"0000";
		
		
		if( c3_rst0 = '1' ) then
			Tx_mac_wr <= '0';
			Tx_mac_sop <= '0';
			Tx_mac_eop <= '0';
			counter_ethernet <= 0;
			counter_ethernet_delay <= 0;
			state_ethernet <= arp;
			arp_clear <= '0';
		elsif( rising_edge(clk_50mhz) ) then
			Tx_mac_sop <= '0';
			Tx_mac_eop <= '0';
			Tx_mac_wr <= '0';
			arp_clear <= '0';


			-- signal start of the frame
			if( Tx_mac_wa = '1' AND counter_ethernet = 0 AND counter_ethernet_delay = 0) then
				Tx_mac_sop <= '1';
			end if;	
		
			case state_ethernet is
			
				-- send ARP request to recieve the MAC of dst_ip_addr
				when arp =>

					if( Tx_mac_wa = '1' ) then
						state_ethernet <= arp;
						Tx_mac_wr <= '1';
						
						if( counter_ethernet < length_ethernet_arp_request_frame-1 ) then
							counter_ethernet <= counter_ethernet + 1;
						else
							counter_ethernet <= 0;
							state_ethernet <= arp_wait;
							-- signal end of the frame
							Tx_mac_eop <= '1';
						end if;
						Tx_mac_data <= arp_request_array(counter_ethernet);
						
					else
						state_ethernet <= arp_wait;
					end if;
					
				-- wait some time to recieve answer to ARP request
				when arp_wait =>
					if( counter_ethernet_delay < 2**21-1 ) then
						counter_ethernet_delay <= counter_ethernet_delay + 1;
						state_ethernet <= arp_wait;
					else
						state_ethernet <= arp;
						counter_ethernet_delay <= 0;
					end if;
					
					if( arp_valid_response_recieved = '1' ) then
						state_ethernet <= idle;
					end if;
				
				-- respond to ARP request or send UDP frame
				when idle =>  
				
					if( Tx_mac_wa = '1' ) then
						state_ethernet <= idle;
						Tx_mac_wr <= '1';
						
						if( arp_send = '0' ) then
							if( counter_ethernet < length_ethernet_frame-1 ) then
								counter_ethernet <= counter_ethernet + 1;
							else
								counter_ethernet <= 0;
								Tx_mac_eop <= '1';
								-- signal end of the frame
								state_ethernet <= wait_state2;
							end if;
							Tx_mac_data <= eth_array(counter_ethernet);
						else
							if( counter_ethernet < length_ethernet_arp_frame-1 ) then
								counter_ethernet <= counter_ethernet + 1;
							else
								counter_ethernet <= 0;
								state_ethernet <= wait_state2;
								arp_clear <= '1';
								-- signal end of the frame
								Tx_mac_eop <= '1';
							end if;
							Tx_mac_data <= arp_array(counter_ethernet);
						end if;
					else
						state_ethernet <= wait_state;
					end if;
					
				-- wait some till Tx_mac_wa is high again
				when wait_state =>
					if( Tx_mac_wa = '1' ) then
						state_ethernet <= idle;
					else
						state_ethernet <= wait_state;
					end if;
					
				-- wait such that throughput is not as high as possible
				when wait_state2 =>
					if( counter_ethernet_delay < 2**24-1 ) then
						counter_ethernet_delay <= counter_ethernet_delay + 1;
						state_ethernet <= wait_state2;
					else
						state_ethernet <= idle;
						counter_ethernet_delay <= 0;
					end if;
						
			end case;
		end if;
		
	end process;
	
	-- ODDR2 is needed instead of the following
	--   Ethernet_TX_CLK <= Ethernet_TX_CLK_buf;
	-- because Ethernet_TX_CLK is dcm_vga_clk_125mhz
	-- and limiting in Spartan 6
	txclk_ODDR2_inst : ODDR2
	generic map (
		DDR_ALIGNMENT => "NONE",
		INIT => '0',
		SRTYPE => "SYNC")
	port map (
		Q => Ethernet_TX_CLK, -- 1-bit DDR output data
		C0 => Ethernet_TX_CLK_buf, -- clock is your signal from PLL
		C1 => not(Ethernet_TX_CLK_buf), -- n
		D0 => '1', -- 1-bit data input (associated with C0)
		D1 => '0' -- 1-bit data input (associated with C1)
	);
	
 end  arc;