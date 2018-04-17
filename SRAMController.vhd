library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SRAMController is
    port (clk         : in    std_logic;
          -- seï¿½ales para la placa de desarrollo
          SRAM_ADDR   : out   std_logic_vector(17 downto 0);
          SRAM_DQ     : inout std_logic_vector(15 downto 0);
          SRAM_UB_N   : out   std_logic;
          SRAM_LB_N   : out   std_logic;
          SRAM_CE_N   : out   std_logic := '1';
          SRAM_OE_N   : out   std_logic := '1';
          SRAM_WE_N   : out   std_logic := '1';
          -- seï¿½ales internas del procesador
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(15 downto 0);
          dataToWrite : in    std_logic_vector(15 downto 0);
          WR          : in    std_logic;
          byte_m      : in    std_logic := '0');
end SRAMController;

architecture comportament of SRAMController is

	type state_type is (inic, escr, lect);

	signal state : state_type := inic;

     signal aux_extensio_signe: std_logic_vector(7 downto 0);
signal aux: std_logic_vector(2 downto 0):="000";

begin
    SRAM_CE_N <='0';
    SRAM_OE_N <='0';
	SRAM_ADDR <= "000" & address(15 downto 1); 
	SRAM_LB_N <= '1' when (address(0)='1' and byte_m='1') else '0';
    SRAM_UB_N <= '1' when (address(0)='0' and byte_m='1') else '0';

	SRAM_DQ <= (others => 'Z') when WR='0' else 
	           dataToWrite     when (WR='1' and byte_m='0') else
	           "ZZZZZZZZ"&dataToWrite(7 downto 0) when (WR='1' and byte_m='1' and address(0)='0') else
	           dataToWrite(7 downto 0)&"ZZZZZZZZ" when (WR='1' and byte_m='1' and address(0)='1');

	dataReaded <= SRAM_DQ   								 when byte_m='0' else
	             aux_extensio_signe&SRAM_DQ(7 downto 0) when byte_m='1' and address(0)='0' else 
	             aux_extensio_signe&SRAM_DQ(15 downto 8) when byte_m='1' and address(0)='1';

    aux_extensio_signe <= (others => SRAM_DQ(7)) when address(0)='0' else 
						  (others => SRAM_DQ(15));

	SRAM_WE_N <= '0' when (aux>="010" and aux<="110") else '1';			  
						  
	process (clk)
		begin
		if (rising_edge(clk)) then
			if WR = '0' then
				aux <="000";
			end if;
			if (WR = '1') then
				aux<=aux+1;
			end if;
		end if;
	end process;
	
	
end comportament;
