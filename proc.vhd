LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY proc IS
    PORT (clk       : IN  STD_LOGIC;
          boot      : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rd_io	 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_io	 : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
			 addr_io : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 rd_in	: OUT STD_LOGIC;
			 wr_out	: OUT STD_LOGIC;
			 intr		: IN STD_LOGIC;
			 inta		: OUT STD_LOGIC;
			 div_zero : OUT STD_LOGIC;
			 ilegal_ir: OUT STD_LOGIC;
			 except : IN STD_LOGIC;
			 codigoEx :IN STD_LOGIC_VECTOR(3 downto 0);
			 excep_protec : OUT STD_LOGIC;
			 calls : OUT STD_LOGIC;
			 systemMode : OUT STD_LOGIC;
			 MissTLBInstr : OUT STD_LOGIC;
			 MissTLBData : OUT STD_LOGIC;
			 InvTLBInstr : OUT STD_LOGIC;
			 InvTLBData : OUT STD_LOGIC;
			 ProtTBLInstr : OUT STD_LOGIC;
			 ProtTBLData : OUT STD_LOGIC;
			 RoTLBData : OUT STD_LOGIC;
			 ld_st: OUT STD_LOGIC;
			 INTER : OUT STD_LOGIC;
			 c_interr : OUT STD_LOGIC);
END proc;


ARCHITECTURE Structure OF proc IS

COMPONENT unidad_control IS
    PORT (boot      : IN  STD_LOGIC;
          clk       : IN  STD_LOGIC;
		    newPCj	  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          pc        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          ins_dad   : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 rb_n		  : OUT STD_LOGIC;
          immed_x2  : OUT STD_LOGIC;
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
          z 		  : IN STD_LOGIC;
		    newPCJAL  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		    pcint2  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);			 
		    addr_io : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 rd_in	: OUT STD_LOGIC;
			 wr_out	: OUT STD_LOGIC;
			 RSlect	: OUT STD_LOGIC;
			 RSescr	: OUT STD_LOGIC;
			 EIntrr	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 RETI		: OUT STD_LOGIC;
			 intr		: IN STD_LOGIC;
			 inta		: OUT STD_LOGIC;
			 INTER	: IN STD_LOGIC;
			 c_interr: OUT STD_LOGIC;
			 ilegal_ir: OUT STD_LOGIC;
			 except : IN STD_LOGIC;
			 systemMode : IN STD_LOGIC;
			 excep_protec : OUT STD_LOGIC;
			 calls : OUT STD_LOGIC;
			 irTLB : OUT STD_LOGIC_VECTOR(3 downto 0);
			 ld_st : OUT STD_LOGIC);
END COMPONENT;

COMPONENT datapath IS
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
		    rb_n	    : IN  STD_LOGIC;
		    newPCJAL : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		    pcint2  : in STD_LOGIC_VECTOR(15 DOWNTO 0);			 
	       rd_io	 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
	 		 wr_io	 : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          data_wr  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		    newPCj   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		    z		   : OUT STD_LOGIC;
			 RSlect	: IN STD_LOGIC;
			 RSescr	: IN STD_LOGIC;
			 EIntrr	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			 RETI		: IN STD_LOGIC;
			 INTER 	: OUT STD_LOGIC;
			 c_interr: IN STD_LOGIC;
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

END COMPONENT;

SIGNAL opAux: STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL wrdAux: STD_LOGIC;
SIGNAL addr_aAux: STD_LOGIC_VECTOR(2 downto 0);
SIGNAL addr_bAux: STD_LOGIC_VECTOR(2 downto 0);
SIGNAL addr_dAux: STD_LOGIC_VECTOR(2 downto 0);
SIGNAL immedAux: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL newPCjAux: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL bus_pcint2: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL newPCJALAux: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL pcAux: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL ins_dadAux: STD_LOGIC;
SIGNAL in_dAux: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL rb_nAux: STD_LOGIC;
SIGNAL immed_x2Aux: STD_LOGIC;
SIGNAL zAux: STD_LOGIC;
SIGNAL RSlectAux: STD_LOGIC;
SIGNAL RSescrAux: STD_LOGIC;
SIGNAL EIntrrAux: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL RETIAux : STD_LOGIC;
SIGNAL INTERAux : STD_LOGIC;
SIGNAL c_interrAux : STD_LOGIC;
SIGNAL systemModeAux : STD_LOGIC;
SIGNAL irTLBAux : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL wr_mAux : STD_LOGIC;
SIGNAL ld_stAux : STD_LOGIC;

    
BEGIN

	systemMode <= systemModeAux;
	
	INTER <= INTERAux;
	c_interr <= c_interrAux;
 	
	wr_m <= wr_mAux;
	
	ld_st <= ld_stAux;

	c0: unidad_control
			Port Map(boot => boot, clk => clk, newPCj => newPCjAux, datard_m => datard_m,
					op => opAux, wrd => wrdAux, addr_a => addr_aAux,
					addr_b => addr_bAux, addr_d => addr_dAux, immed => immedAux,
					pc => pcAux, ins_dad => ins_dadAux, in_d => in_dAux, rb_n => rb_nAux,
					immed_x2 => immed_x2Aux, wr_m => wr_mAux, word_byte => word_byte, z => zAux,
					pcint2 => bus_pcint2,
					newPCJAL => newPCJALAux, addr_io => addr_io, rd_in => rd_in, wr_out => wr_out,
					RSlect => RSlectAux, RSescr => RSescrAux, EIntrr => EIntrrAux, RETI => RETIAux,
					intr => intr, inta => inta, INTER => INTERAux, c_interr => c_interrAux,
					ilegal_ir=> ilegal_ir, except => except, systemMode => systemModeAux, 
					excep_protec => excep_protec, calls => calls, irTLB=> irTLBAux, ld_st=>ld_stAux);

	e0: datapath
			Port Map(clk => clk, boot => boot, op => opAux, wrd => wrdAux,
					addr_a => addr_aAux, addr_b => addr_bAux, addr_d => addr_dAux,
					immed => immedAux, immed_x2 => immed_x2Aux, datard_m => datard_m,
					ins_dad => ins_dadAux, pc => pcAux, in_d => in_dAux, 
					pcint2 => bus_pcint2,
					rb_n => rb_nAux, newPCJAL => newPCJALAux, rd_io => rd_io, wr_io => wr_io,
					addr_m => addr_m, data_wr => data_wr, newPCj => newPCjAux, z => zAux,
					RSlect => RSlectAux, RSescr => RSescrAux, EIntrr => EIntrrAux, RETI => RETIAux,
					INTER => INTERAux, c_interr => c_interrAux, div_zero=> div_zero,
					codigoEx => codigoEx, systemMode => systemModeAux, irTLB=> irTLBAux, wr_m => wr_mAux,
					MissTLBInstr => MissTLBInstr, MissTLBData=> MissTLBData, InvTLBInstr => InvTLBInstr,
					InvTLBData => InvTLBData, ProtTBLInstr => ProtTBLInstr, ProtTBLData => ProtTBLData,
					RoTLBData => RoTLBData, ld_st=>ld_stAux);	

END Structure;