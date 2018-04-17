LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY unidad_control IS
    PORT (boot      : IN  STD_LOGIC;
          clk       : IN  STD_LOGIC;
          newPCj    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
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
          z         : IN STD_LOGIC;
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
			  ilegal_ir : OUT STD_LOGIC;
			 except     : IN STD_LOGIC;
			 systemMode : IN STD_LOGIC;
			 excep_protec : OUT STD_LOGIC;
			 calls : OUT STD_LOGIC;
			 irTLB : OUT STD_LOGIC_VECTOR(3 downto 0);
			 ld_st : OUT STD_LOGIC);

END unidad_control;

ARCHITECTURE Structure OF unidad_control IS

COMPONENT control_l IS
    PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          z         : IN  STD_LOGIC;
          tknbr     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          op        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
          ldpc      : OUT STD_LOGIC;
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		    rb_n		  : OUT STD_LOGIC;
          immed_x2  : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
          newPCb 	  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 addr_io   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 rd_in	  : OUT STD_LOGIC;
			 wr_out	  : OUT STD_LOGIC;
			 RSlect	  : OUT STD_LOGIC;
			 RSescr	  : OUT STD_LOGIC;
			 EIntrr	  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 RETI		  : OUT STD_LOGIC;
			 inta      : OUT STD_LOGIC;
			 ilegal_ir : OUT STD_LOGIC;
			 systemMode : IN STD_LOGIC;
			 excep_protec : OUT STD_LOGIC;
			 calls : OUT STD_LOGIC;
			 irTLB : OUT STD_LOGIC_VECTOR(3 downto 0);
			 ld_st : OUT STD_LOGIC);
END COMPONENT;

COMPONENT multi IS
    port(clk       : IN  STD_LOGIC;
         boot      : IN  STD_LOGIC;
         ldpc_l    : IN  STD_LOGIC;
         wrd_l     : IN  STD_LOGIC;
         wr_m_l    : IN  STD_LOGIC;
         w_b       : IN  STD_LOGIC;
			intr 		 : IN  STD_LOGIC;
			INTER		 : IN  STD_LOGIC;
         ldpc      : OUT STD_LOGIC;
         wrd       : OUT STD_LOGIC;
         wr_m      : OUT STD_LOGIC;
         ldir      : OUT STD_LOGIC;
         ins_dad   : OUT STD_LOGIC;
         word_byte : OUT STD_LOGIC;
			c_interr  : OUT STD_LOGIC;
			except	 : IN STD_LOGIC;
			c_except  : OUT STD_LOGIC;
			excep_protec : IN STD_LOGIC;
			excep_protec2 : OUT STD_LOGIC;
			EIntrr	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			EIntrr2  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
END COMPONENT;

SIGNAL irAux: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL ldpcAux: STD_LOGIC;
SIGNAL ldpcAux2: STD_LOGIC;
SIGNAL tknbrAux: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL tknbrAux2: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL newPC: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL newPCbAux: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL newPCjAux: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL pcIntr: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL wrdAux: STD_LOGIC;
SIGNAL wr_mAux: STD_LOGIC;
SIGNAL word_byteAux: STD_LOGIC;
SIGNAL ldirAux: STD_LOGIC;
SIGNAL zAux: STD_LOGIC;
SIGNAL c_interrAux: STD_LOGIC;
SIGNAL ilegal_irAux: STD_LOGIC;
SIGNAL excep_protecAux: STD_LOGIC;
SIGNAL in_dAux: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL EIntrrAux: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL c_exceptAux: STD_LOGIC;

BEGIN

PCcounter: PROCESS (clk) BEGIN
	IF (rising_edge(clk)) then 
		if(boot = '1') then
			newPC <= x"C000";
		elsif (ldpcAux2 = '1') then
			case tknbrAux is
				when "00" => newPC <= newPC + 2;      		 --SECUENCIAMIENTO HABITUAL
				when "01" => newPC <= newPC + 2 + newPCbAux; --BZ/BNZ
				when "10" => newPC <= newPCj;	      		 --JXX/RSI/RETI
				when others => newPC <= newPC;				 --FUTURA IMPLEMENTACIO TLB
			end case;
			pcIntr <= newPC;--+2;
		end if;
	END IF;
END PROCESS PCcounter;

irSel: PROCESS (clk) BEGIN
	IF (rising_edge(clk)) then 
		IF (ldirAux = '1') then 
			irAux <= datard_m;
		END IF;
	end if;
END PROCESS irSel;

	pc <= newPC;

pcint2 <= newPC;

	newPCJAL <= newPC+2 when c_interrAux = '0' else pcIntr;
	
	tknbrAux <= "10" when c_interrAux = '1' else tknbrAux2;	--Haz que el pc valga el de la RSI
	in_d <= "10" when c_interrAux = '1' else in_dAux;		--Guarda el pc de antes de la RSI
	
	ilegal_ir <= ilegal_irAux when c_exceptAux = '0' else '0';
	--excep_protec <= excep_protecAux when c_exceptAux = '0' else '0';
	
	c_interr <= c_interrAux;
	
	c0: control_l
		 Port Map(ir => irAux, z => z, tknbr => tknbrAux2, op => op, ldpc => ldpcAux, wrd => wrdAux,
				  addr_a => addr_a, addr_b => addr_b, addr_d => addr_d,
				  immed => immed, wr_m => wr_mAux, in_d => in_dAux, rb_n => rb_n,
				  immed_x2 => immed_x2, word_byte => word_byteAux, newPCb => newPCbAux,
				  addr_io => addr_io, rd_in => rd_in, wr_out => wr_out, RSlect	=> RSlect,
				  RSescr => RSescr, EIntrr => EIntrrAux, RETI => RETI, inta => inta, ilegal_ir=> ilegal_irAux,
				  systemMode => systemMode, excep_protec => excep_protecAux, calls => calls, irTLB => irTLB,
				  ld_st=>ld_st);
	
	m0: multi
		 Port Map(clk => clk, boot => boot, ldpc_l => ldpcAux, wrd_l => wrdAux,
				  wr_m_l => wr_mAux, w_b => word_byteAux, intr => intr, INTER => INTER, ldpc => ldpcAux2,
				  wrd => wrd, wr_m => wr_m, ldir => ldirAux, ins_dad => ins_dad,
				  word_byte => word_byte, c_interr => c_interrAux, except => except,
				  c_except => c_exceptAux, excep_protec => excep_protecAux,
				  excep_protec2 => excep_protec, EIntrr => EIntrrAux, EIntrr2 => EIntrr);
	
END Structure;