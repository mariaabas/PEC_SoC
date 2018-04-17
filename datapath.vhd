LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY datapath IS
    PORT (clk      : IN  STD_LOGIC;
  		    boot	    : IN  STD_LOGIC;
          op       : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
          wrd      : IN  STD_LOGIC;
          addr_a   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          immed_x2 : IN  STD_LOGIC;
          datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          ins_dad  : IN  STD_LOGIC;
          pc       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          in_d     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
          rb_n     : IN  STD_LOGIC;
          newPCJAL : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
 		    pcint2   : in  STD_LOGIC_VECTOR(15 DOWNTO 0);			 
			 rd_io	 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_io	 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          data_wr  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          newPCj   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          z        : OUT STD_LOGIC;
			 RSlect	 : IN STD_LOGIC;
			 RSescr	 : IN STD_LOGIC;
			 EIntrr	 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			 RETI		 : IN STD_LOGIC;
			 INTER	 : OUT STD_LOGIC;
			 c_interr : IN STD_LOGIC;
			 div_zero : OUT STD_LOGIC;
			 codigoEx : IN STD_LOGIC_VECTOR(3 downto 0);
			 systemMode : OUT STD_LOGIC;
			 irTLB : IN STD_LOGIC_VECTOR(3 downto 0);
			 wr_m  : IN STD_LOGIC;
			 MissTLBInstr : OUT STD_LOGIC;
			 MissTLBData : OUT STD_LOGIC;
			 InvTLBInstr : OUT STD_LOGIC;
			 InvTLBData : OUT STD_LOGIC;
			 ProtTBLInstr : OUT STD_LOGIC;
			 ProtTBLData : OUT STD_LOGIC;
			 RoTLBData : OUT STD_LOGIC;
			 TAG_ADDRESSIr: OUT STD_LOGIC_VECTOR(3 downto 0);
			 ld_st : IN STD_LOGIC);
END datapath;


ARCHITECTURE Structure OF datapath IS

COMPONENT alu IS
   PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
         y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
         op : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
         w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		   z  : OUT STD_LOGIC;
		   div_zero : OUT STD_LOGIC);
END COMPONENT;

COMPONENT regfile IS
	PORT (clk    : IN  STD_LOGIC;
         wrd    : IN  STD_LOGIC;
         d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
         addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
         addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
         addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
         a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
         b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
 	      pcint2 : in STD_LOGIC_VECTOR(15 DOWNTO 0);			 
			boot	 : IN  STD_LOGIC;
			RSlect : IN STD_LOGIC;
			RSescr : IN STD_LOGIC;
			EIntrr : IN STD_LOGIC_VECTOR(1 DOWNTO 0);	
			RETI	  : IN STD_LOGIC;
			INTER   : OUT STD_LOGIC;
			c_interr : IN STD_LOGIC;
			codigoEx	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			addressEx	 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			systemMode : OUT STD_LOGIC);
END COMPONENT;

COMPONENT TLB IS
    PORT (clk : IN STD_LOGIC;
        boot	 : IN STD_LOGIC;
			 irTLB : IN STD_LOGIC_VECTOR(3 downto 0);
	       A			 : IN STD_LOGIC_VECTOR(3 downto 0);
			 B			 : IN STD_LOGIC_VECTOR(5 downto 0);
          TAG_DATA : IN STD_LOGIC_VECTOR(3 downto 0);
			 TAG_INSTR: IN STD_LOGIC_VECTOR(3 downto 0);
			 systemMode : IN STD_LOGIC;
			 wr_m		 : IN STD_LOGIC;
			 MissTLBInstr : OUT STD_LOGIC;
			 MissTLBData : OUT STD_LOGIC;
			 InvTLBInstr : OUT STD_LOGIC;
			 InvTLBData : OUT STD_LOGIC;
			 ProtTBLInstr : OUT STD_LOGIC;
			 ProtTBLData : OUT STD_LOGIC;
			 RoTLBData : OUT STD_LOGIC;
			 TAG_ADDRESSIr : OUT STD_LOGIC_VECTOR(3 downto 0);
			 TAG_ADDRESSData: OUT STD_LOGIC_VECTOR(3 downto 0);
			 ld_st : IN STD_LOGIC);
END COMPONENT;

SIGNAL dAux: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
SIGNAL aAux: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
SIGNAL bAux: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
SIGNAL bAux2: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
SIGNAL immedAux: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
SIGNAL data: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
SIGNAL resPCAux: STD_LOGIC_VECTOR (15 downto 0);
SIGNAL addr_mAux: STD_LOGIC_VECTOR (15 downto 0);
SIGNAL systemModeAux: STD_LOGIC;
SIGNAL TAG_ADDRESSIrAux : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL TAG_ADDRESSDataAux : STD_LOGIC_VECTOR(3 downto 0);

BEGIN

	with in_d select
	data <= dAux 	  when "00",   --Alu
			  datard_m when "01",	--Mem
		     rd_io	  when "11", 	--IN/GETIID
           newPCJAL when others;	--Jal
			
	with immed_x2 select
	immedAux <= std_logic_vector(SHIFT_LEFT(UNSIGNED(immed), 1)) when '1',    --MemW
				   immed 	 			 when others; --MemB
				
	with rb_n select
	bAux <= bAux2 when '1', 	    --RegB
			  immedAux when others;	 --Immed
 
	with ins_dad select
	addr_mAux <= TAG_ADDRESSDataAux&dAux(11 downto 0) when '1',	 --Alu
				 TAG_ADDRESSIrAux&pc(11 downto 0)   when others;    --PC
				 
	addr_m <= addr_mAux;
 
	wr_io <= bAux2;
	
	data_wr <= bAux2;

   newPCj <= aAux;
	
	systemMode <= systemModeAux;
	
	TAG_ADDRESSIr <= TAG_ADDRESSIrAux;
	
	alu0: alu	
			Port Map(x => aAux, y => bAux, op => op, w => dAux,
         			z => z,  div_zero => div_zero);
			
	reg0: regfile
			Port Map(clk => clk,  boot => boot, wrd => wrd, d => data, addr_a => addr_a, addr_b => addr_b,
					addr_d => addr_d, a => aAux, b => bAux2, RSlect => RSlect, RSescr => RSescr,
					pcint2 => pcint2,
					EIntrr => EIntrr, RETI => RETI, INTER => INTER, c_interr => c_interr,
					codigoEx => codigoEx, addressEx => addr_mAux, systemMode => systemModeAux);
					
	tlb0: TLB
			Port Map(clk => clk, boot => boot, irTLB => irTLB, A => aAux(3 downto 0), B => bAux2(5 downto 0), 
						TAG_DATA => dAux(15 downto 12), TAG_INSTR => pc(15 downto 12), 
						systemMode => systemModeAux, wr_m => wr_m, MissTLBInstr => MissTLBInstr,
						MissTLBData => MissTLBData, InvTLBInstr => InvTLBInstr, InvTLBData => InvTLBData,
						ProtTBLInstr => ProtTBLInstr, ProtTBLData => ProtTBLData, RoTLBData => RoTLBData,
					    TAG_ADDRESSData => TAG_ADDRESSDataAux, TAG_ADDRESSIr=> TAG_ADDRESSIrAux,
						ld_st=>ld_st);  
							
END Structure;