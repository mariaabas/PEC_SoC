library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MemoryController is
    port (CLOCK_50  : in  std_logic;
	       addr      : in  std_logic_vector(15 downto 0);
          wr_data   : in  std_logic_vector(15 downto 0);
          rd_data   : out std_logic_vector(15 downto 0);
          we        : in  std_logic;
          byte_m    : in  std_logic;
          -- se�ales para la placa de desarrollo
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '1';
          SRAM_OE_N : out   std_logic := '1';
          SRAM_WE_N : out   std_logic := '1';
			 vga_addr : out std_logic_vector(12 downto 0);
			 vga_we   : out std_logic;
			 vga_wr_data : out std_logic_vector(15 downto 0);
			 vga_rd_data : in std_logic_vector(15 downto 0);
			 vga_byte_m  : out std_logic;
			 invalid_acces: out std_logic;
			 systemMode : in std_logic;
			 mem_protec : out std_logic;
			 ld_st : in std_logic);
end MemoryController;

architecture comportament of MemoryController is
signal WEAux: std_logic;
SIGNAL rd_dataAux: std_logic_vector(15 downto 0);

COMPONENT SRAMController is
    port (clk         : in    std_logic;
          -- se�ales para la placa de desarrollo
          SRAM_ADDR   : out   std_logic_vector(17 downto 0);
          SRAM_DQ     : inout std_logic_vector(15 downto 0);
          SRAM_UB_N   : out   std_logic;
          SRAM_LB_N   : out   std_logic;
          SRAM_CE_N   : out   std_logic := '1';
          SRAM_OE_N   : out   std_logic := '1';
          SRAM_WE_N   : out   std_logic := '1';
          -- se�ales internas del procesador
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(15 downto 0);
          dataToWrite : in    std_logic_vector(15 downto 0);
          WR          : in    std_logic;
          byte_m      : in    std_logic := '0');
END COMPONENT;

begin


WEAux <= we when addr < x"C000" else '0';

mem_protec <= '1' when systemMode = '0' and addr(15) = '1' and ld_st = '1' else '0';-- Acceso a memoria de sistema en modo usuario, except: 13
invalid_acces <= '1' when byte_m = '0' and addr(0) = '1' and ld_st = '1' else '0'; --Acceso a memoria de word a posicion impar, Except: 1

vga_addr <= addr(12 downto 0);
vga_we <= we  when addr >= x"A000" and addr <= x"BFFF" else '0';
vga_wr_data <= wr_data;
rd_data <= vga_rd_data when addr >= x"A000" and addr <= x"BFFF" else rd_dataAux;
vga_byte_m  <= byte_m;

sram: SRAMController
			Port Map(clk => CLOCK_50, SRAM_ADDR => SRAM_ADDR, SRAM_DQ => SRAM_DQ,
					 SRAM_UB_N => SRAM_UB_N, SRAM_LB_N => SRAM_LB_N, SRAM_CE_N => SRAM_CE_N,
					 SRAM_OE_N => SRAM_OE_N, SRAM_WE_N => SRAM_WE_N, address => addr,
					 dataReaded => rd_dataAux, dataToWrite => wr_data, WR => WEAux, byte_m => byte_m);


end comportament;
