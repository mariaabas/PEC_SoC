LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY sisa IS
    PORT (CLOCK_50  : IN    STD_LOGIC;
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '1';
          SRAM_OE_N : out   std_logic := '1';
          SRAM_WE_N : out   std_logic := '1';
			 LEDG		  : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
			 LEDR		  : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
          SW        : in std_logic_vector(9 downto 0);
			 KEY		  : IN STD_LOGIC_VECTOR(3 downto 0);
			 HEX0		  : OUT STD_LOGIC_VECTOR(6 downto 0);
			 HEX1		  : OUT STD_LOGIC_VECTOR(6 downto 0);
			 HEX2		  : OUT STD_LOGIC_VECTOR(6 downto 0);
			 HEX3		  : OUT STD_LOGIC_VECTOR(6 downto 0);
			 PS2_CLK   : INOUT std_logic;
			 PS2_DAT   : INOUT std_logic;
			 VGA_R	  : OUT std_logic_vector(3 downto 0);
			 VGA_G	  : OUT std_logic_vector(3 downto 0);
			 VGA_B	  : OUT std_logic_vector(3 downto 0);
			 VGA_HS	  : OUT std_logic;
			 VGA_VS	  : OUT std_logic);
END sisa;

ARCHITECTURE Structure OF sisa IS

SIGNAL datard_mAux:  STD_LOGIC_VECTOR(15 downto 0);
SIGNAL addr_mAux: 	 STD_LOGIC_VECTOR(15 downto 0);
SIGNAL data_wrAux: 	 STD_LOGIC_VECTOR(15 downto 0);
SIGNAL wr_mAux: 	 STD_LOGIC;
SIGNAL word_byteAux: STD_LOGIC;
SIGNAL clock_count: STD_LOGIC_VECTOR(4 downto 0):= "00000";
SIGNAL clockAux: STD_LOGIC;
SIGNAL clockVGA: STD_LOGIC;
SIGNAL addr_ioAux : std_logic_vector(7 downto 0);
SIGNAL wr_ioAux : std_logic_vector(15 downto 0);
SIGNAL rd_ioAux : std_logic_vector(15 downto 0);
SIGNAL wr_outAux : std_logic;
SIGNAL rd_inAux : std_logic;
SIGNAL visor0Aux : std_logic_vector(4 downto 0);
SIGNAL visor1Aux : std_logic_vector(4 downto 0);
SIGNAL visor2Aux : std_logic_vector(4 downto 0);
SIGNAL visor3Aux : std_logic_vector(4 downto 0);
SIGNAL addr_vgaAux : std_logic_vector(12 downto 0);
SIGNAL weAux       : std_logic;
SIGNAL wr_dataAux  : std_logic_vector(15 downto 0);
SIGNAL rd_dataAux  : std_logic_vector(15 downto 0);
SIGNAL byte_mAux   : std_logic;
SIGNAL intrAux   : std_logic;
SIGNAL intaAux   : std_logic;
SIGNAL div_zeroAux : std_logic;
SIGNAL ilegal_irAux : std_logic;
SIGNAL exceptAux : std_logic;
SIGNAL codigoExAux : std_logic_vector(3 downto 0);
SIGNAL invalid_accessAux : std_logic;
SIGNAL excep_protecAux : std_logic;
SIGNAL callsAux : std_logic;
SIGNAL systemModeAux : std_logic;
SIGNAL mem_protecAux : std_logic;
SIGNAL MissTLBInstrAux : std_logic;
SIGNAL MissTLBDataAux : std_logic;
SIGNAL InvTLBInstrAux : std_logic;
SIGNAL InvTLBDataAux :  std_logic;
SIGNAL ProtTBLInstrAux : std_logic;
SIGNAL ProtTBLDataAux :  std_logic;
SIGNAL RoTLBDataAux : std_logic;
SIGNAL ld_stAux : std_logic;
SIGNAL INTERAux : std_logic;
SIGNAL c_interrAux : std_logic;



COMPONENT proc is
    PORT (clk       : IN  STD_LOGIC;
          boot      : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rd_io	  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_io	  : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
			 addr_io   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 rd_in	  : OUT STD_LOGIC;
			 wr_out	  : OUT STD_LOGIC;
			 intr		  : IN STD_LOGIC;
			 inta 	  : OUT STD_LOGIC;
			 div_zero  : OUT STD_LOGIC;
			 ilegal_ir : OUT STD_LOGIC;
			 except 	  : IN STD_LOGIC;
			 codigoEx  : IN STD_LOGIC_VECTOR(3 downto 0);
			 excep_protec : OUT STD_LOGIC;
			 calls 	     : OUT STD_LOGIC;
			 systemMode   : OUT STD_LOGIC;
			 MissTLBInstr : OUT STD_LOGIC;
			 MissTLBData  : OUT STD_LOGIC;
			 InvTLBInstr  : OUT STD_LOGIC;
			 InvTLBData   : OUT STD_LOGIC;
			 ProtTBLInstr : OUT STD_LOGIC;
			 ProtTBLData  : OUT STD_LOGIC;
			 RoTLBData    : OUT STD_LOGIC;
			 ld_st		  : OUT STD_LOGIC;
			 INTER : OUT STD_LOGIC;
			 c_interr : OUT STD_LOGIC);
END COMPONENT;

COMPONENT MemoryController is
		port (CLOCK_50 : in  std_logic;
	       addr       : in  std_logic_vector(15 downto 0);
          wr_data    : in  std_logic_vector(15 downto 0);
          rd_data    : out std_logic_vector(15 downto 0);
          we         : in  std_logic;
          byte_m     : in  std_logic;
          -- señales para la placa de desarrollo
          SRAM_ADDR  : out   std_logic_vector(17 downto 0);
          SRAM_DQ    : inout std_logic_vector(15 downto 0);
          SRAM_UB_N  : out   std_logic;
          SRAM_LB_N  : out   std_logic;
          SRAM_CE_N  : out   std_logic := '1';
          SRAM_OE_N  : out   std_logic := '1';
          SRAM_WE_N  : out   std_logic := '1';
			 vga_addr   : out std_logic_vector(12 downto 0);
			 vga_we     : out std_logic;
			 vga_wr_data : out std_logic_vector(15 downto 0);
			 vga_rd_data : in std_logic_vector(15 downto 0);
			 vga_byte_m  : out std_logic;
			  invalid_acces: out std_logic;
			 systemMode : in std_logic;
			 mem_protec : out std_logic;
			 ld_st      : in std_logic);
END COMPONENT;

COMPONENT controladores_IO IS
		PORT (boot 	   : IN STD_LOGIC;
				CLOCK_50 : IN std_logic;
				addr_io 	: IN std_logic_vector(7 downto 0);
				wr_io 	: in std_logic_vector(15 downto 0);
				rd_io 	: out std_logic_vector(15 downto 0);
				wr_out 	: in std_logic;
				rd_in 	: in std_logic;
				led_verdes : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				led_rojos  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				pulsadores : IN STD_LOGIC_VECTOR(3 downto 0);
				interruptores : IN STD_LOGIC_VECTOR(7 downto 0);
				visor0		  : OUT STD_LOGIC_VECTOR(4 downto 0);
				visor1		  : OUT STD_LOGIC_VECTOR(4 downto 0);
				visor2		  : OUT STD_LOGIC_VECTOR(4 downto 0);
				visor3		  : OUT STD_LOGIC_VECTOR(4 downto 0);
				ps2_clk  : inout std_logic;
				ps2_data : inout std_logic;
				--vga_cursor : out std_logic_vector(15 downto 0);
				--vga_cursor_enable : out std_logic
				intr 		: OUT	STD_LOGIC;
				inta 		: IN 	STD_LOGIC);
END COMPONENT;

COMPONENT driver7Segmentos IS
	PORT( codigoCaracter : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
			bitsCaracter   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END COMPONENT;

COMPONENT vga_controller is
    port(clk_50mhz      : in  std_logic; -- system clock signal
         reset          : in  std_logic; -- system reset
         blank_out      : out std_logic; -- vga control signal
         csync_out      : out std_logic; -- vga control signal
         red_out        : out std_logic_vector(7 downto 0); -- vga red pixel value
         green_out      : out std_logic_vector(7 downto 0); -- vga green pixel value
         blue_out       : out std_logic_vector(7 downto 0); -- vga blue pixel value
         horiz_sync_out : out std_logic; -- vga control signal
         vert_sync_out  : out std_logic; -- vga control signal
         --
         addr_vga          : in std_logic_vector(12 downto 0);
         we                : in std_logic;
         wr_data           : in std_logic_vector(15 downto 0);
         rd_data           : out std_logic_vector(15 downto 0);
         byte_m            : in std_logic
         --vga_cursor        : in std_logic_vector(15 downto 0);  -- simplemente lo ignoramos, este controlador no lo tiene implementado
         --vga_cursor_enable : in std_logic
			);                     -- simplemente lo ignoramos, este controlador no lo tiene implementado
END COMPONENT;  

COMPONENT exception_controller is 
	PORT (boot : IN STD_LOGIC;
			intr 			: IN STD_LOGIC;
			div_zero		: IN std_logic;
			ilegal_ir 	: in std_logic;
			invalid_access: IN STD_LOGIC;
			except 		: OUT STD_LOGIC;
			codigoEx		: OUT STD_LOGIC_VECTOR(3 downto 0);
			excep_protec : IN STD_LOGIC;
			calls : IN STD_LOGIC;
			mem_protec : in std_logic;
			MissTLBInstr : IN STD_LOGIC;
			MissTLBData : IN STD_LOGIC;
			InvTLBInstr : IN STD_LOGIC;
			InvTLBData : IN STD_LOGIC;
			ProtTBLInstr : IN STD_LOGIC;
			ProtTBLData : IN STD_LOGIC;
			RoTLBData : IN STD_LOGIC;
			INTER : IN STD_LOGIC;
			c_interr : IN STD_LOGIC);
END COMPONENT;

BEGIN
	process (CLOCK_50) begin
		if rising_edge(CLOCK_50) then	
			clock_count <= clock_count + 1;
		end if;
	end process;
	
	clockAux <= clock_count(2);
	clockVGA <= clock_count(4);

	proc0: proc
			Port Map(clk => clockAux, boot => SW(9), datard_m => datard_mAux,
					 rd_io => rd_ioAux, wr_io => wr_ioAux, 
					 addr_m => addr_mAux, data_wr => data_wrAux,
					 wr_m => wr_mAux, word_byte => word_byteAux,
					 addr_io => addr_ioAux, rd_in => rd_inAux, wr_out => wr_outAux,
					 intr => intrAux, inta => intaAux, div_zero => div_zeroAux, 
					 ilegal_ir => ilegal_irAux, except=> exceptAux, codigoEx=> codigoExAux, 
					 excep_protec=> excep_protecAux, calls => callsAux, systemMode=> systemModeAux,
					 MissTLBInstr => MissTLBInstrAux, MissTLBData => MissTLBDataAux, InvTLBInstr => InvTLBInstrAux,
					 InvTLBData => InvTLBDataAux, ProtTBLInstr => ProtTBLInstrAux, ProtTBLData => ProtTBLDataAux,
					 RoTLBData => RoTLBDataAux, ld_st=>ld_stAux, INTER=> INTERAux, c_interr=> c_interrAux);
			
	mem0: MemoryController
			Port Map(CLOCK_50 => CLOCK_50, addr => addr_mAux,
					 wr_data => data_wrAux, rd_data => datard_mAux,
					 we => wr_mAux, byte_m => word_byteAux,
					 SRAM_ADDR => SRAM_ADDR, SRAM_DQ => SRAM_DQ,
					 SRAM_UB_N => SRAM_UB_N, SRAM_LB_N => SRAM_LB_N,
					 SRAM_CE_N => SRAM_CE_N, SRAM_OE_N => SRAM_OE_N,
					 SRAM_WE_N => SRAM_WE_N, vga_addr => addr_vgaAux,
					 vga_we => weAux, vga_wr_data => wr_dataAux,
					 vga_rd_data => rd_dataAux, vga_byte_m => byte_mAux, invalid_acces=>invalid_accessAux,
					 systemMode => systemModeAux, mem_protec => mem_protecAux,
					 ld_st=>ld_stAux);

	con_IO: controladores_IO
			Port Map(boot => SW(9), CLOCK_50 => CLOCK_50, addr_io => addr_ioAux,
						wr_io => wr_ioAux, rd_io => rd_ioAux, wr_out => wr_outAux, 
						rd_in => rd_inAux, led_verdes => LEDG, led_rojos => LEDR, 
						pulsadores => KEY, interruptores => SW(7 downto 0),
						visor0 => visor0Aux, visor1 => visor1Aux, visor2 => visor2Aux, visor3 => visor3Aux,
						ps2_clk => ps2_clk, ps2_data => ps2_dat, intr => intrAux, inta => intaAux); 
						
	driverVisor0: driver7Segmentos
			Port Map(codigoCaracter => visor0Aux, bitsCaracter => HEX0);
			
	driverVisor1: driver7Segmentos
			Port Map(codigoCaracter => visor1Aux, bitsCaracter => HEX1);
			
	driverVisor2: driver7Segmentos
			Port Map(codigoCaracter => visor2Aux, bitsCaracter => HEX2);
			
	driverVisor3: driver7Segmentos
			Port Map(codigoCaracter => visor3Aux, bitsCaracter => HEX3);
			
	vga_contr: vga_controller
			Port Map(clk_50mhz =>  CLOCK_50, reset => SW(9), csync_out => clockVGA,
						red_out(3 downto 0) => VGA_R, green_out(3 downto 0) => VGA_G, blue_out(3 downto 0) => VGA_B,
						horiz_sync_out => VGA_HS, vert_sync_out => VGA_VS, addr_vga => addr_vgaAux, we => weAux,
						wr_data => wr_dataAux, rd_data => rd_dataAux, byte_m => byte_mAux); --Pasar los cursor y blank_out???
	
	excep_control: exception_controller
			Port Map(boot => SW(9), intr => intrAux, div_zero => div_zeroAux, ilegal_ir=> ilegal_irAux, 
						invalid_access => invalid_accessAux , except =>exceptAux , codigoEx => codigoExAux,
						excep_protec => excep_protecAux, calls => callsAux, mem_protec=> mem_protecAux,
						MissTLBInstr => MissTLBInstrAux, MissTLBData => MissTLBDataAux, InvTLBInstr => InvTLBInstrAux,
						InvTLBData => InvTLBDataAux, ProtTBLInstr => ProtTBLInstrAux, ProtTBLData => ProtTBLDataAux,
					   RoTLBData => RoTLBDataAux, INTER => INTERAux, c_interr=>c_interrAux);	

	
END Structure;