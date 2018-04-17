LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY control_l IS
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
          newPCb 	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 addr_io : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 rd_in	: OUT STD_LOGIC;
			 wr_out	: OUT STD_LOGIC;
			 RSlect	: OUT STD_LOGIC;
			 RSescr	: OUT STD_LOGIC;
			 EIntrr	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 RETI		: OUT STD_LOGIC;
			 inta    : OUT STD_LOGIC:= '0';
			 ilegal_ir : OUT STD_LOGIC;
			 systemMode : IN STD_LOGIC;
			 excep_protec : OUT STD_LOGIC;
			 calls : OUT STD_LOGIC;
			 irTLB : OUT STD_LOGIC_VECTOR(3 downto 0);
			 ld_st : OUT STD_LOGIC);
END control_l;


ARCHITECTURE Structure OF control_l IS

SIGNAL op_aux: STD_LOGIC_VECTOR (6 downto 0);
SIGNAL immedAux: STD_LOGIC_VECTOR (15 downto 0);
SIGNAL immedPC: STD_LOGIC_VECTOR (7 downto 0);
SIGNAL op_aux2: STD_LOGIC_VECTOR(8 downto 0);
SIGNAL op_auxTLB: STD_LOGIC_VECTOR(9 downto 0);


SIGNAL c_op: STD_LOGIC_VECTOR (3 downto 0);

BEGIN
	
	c_op <= ir(15 downto 12);
	
	op_aux <= ir(15 downto 12) & ir(5 downto 3);
	
	op_aux2 <= ir(15 downto 12) & ir(4 downto 0);
	
	op_auxTLB <= systemMode&op_aux2;

	
	ilegal_ir <= '1' when op_aux = "0001010" or -- Comp
								 op_aux = "0001110" or
								 op_aux = "0001111" or
								 op_aux = "1000011" or -- Ext AriT
								 op_aux = "1000110" or
								 op_aux = "1000111" or
								 c_op = "1001" or		  -- Float
								 c_op = "1011" or		  -- LD Float
								 c_op = "1100" or 		  -- ST Float
								 op_aux2 = "101000010" or -- Jumps
								 op_aux2 = "101000101" or
								 op_aux2 = "101000110" or
								 op_aux2 = "111100010" or -- SpeCIALS
								 op_aux2 = "111100011" or
								 op_aux2 = "111100101" or
								 op_aux2 = "111100110" or
								 op_aux2 = "111100111" or
								 op_aux2 = "111101001" or
								 op_aux2 = "111101010" or
								 op_aux2 = "111101011" or
								 op_aux2 = "111101101" or
								 op_aux2 = "111101110" or
								 op_aux2 = "111101111" or
								 op_aux2 = "111110001" or
								 op_aux2 = "111110010" or
								 op_aux2 = "111110011" or
								 op_aux2 = "111111000" or --FLUSH
								 op_aux2 = "111111001" or
								 op_aux2 = "111111010" or
								 op_aux2 = "111111011" or
								 op_aux2 = "111111100" or
								 op_aux2 = "111111101" or
								 op_aux2 = "111111110" or
								 (op_aux2 = "101000111" and systemMode = '1') or --CALLS EN SYSTEM MODE
								 (c_op = "1010" and ir(5 downto 3) /= "000") or -- Resv. Fut. Ampl.
								 (c_op = "1111" and ir(5) = '0') -- Resv. Fut. Ampl.
								 else '0';  	

	op <= op_aux(6 downto 3) & "000" when c_op& ir(8) =  "01010" ELSE --MOVI
		  op_aux(6 downto 3) & "001" when c_op& ir(8) =  "01011" ELSE --MOVHI
	      "0000100" when c_op = "0010" OR 	--ADDI
						 c_op = "0011" OR 	--LD
						 c_op = "0100" OR 	--ST
						 c_op = "1101" OR 	--LDB
						 c_op = "1110" ELSE --STB
		  op_aux;
		  
	rb_n <= '1' when (c_op = "0000" or --ARIT
					  c_op = "0001" or --CMP
					  c_op = "1000" or --EXT.ARIT
					  c_op = "0110" or --BZ/BNZ
					  c_op = "1010" or --JAL
					  (c_op = "0111" and ir(8) = '1'))   --OUT
					   else '0';
	
	ldpc <= '0' when ir = "1111111111111111" else '1';
			
	wrd <=  '0' when c_op = "0100" ELSE --ST
			'0' when c_op = "1110" ELSE --STB
			'0' when c_op = "0110" ELSE --BZ/BNZ
			'0' when c_op = "1010" and (ir(2 downto 0) = "000" or ir(2 downto 0) = "001" or ir(2 downto 0) = "011" or ir(2 downto 0) = "111") ELSE --JZ/JNZ/JMP/CALL
			'0' when c_op = "0111" and ir(8) = '1' ELSE --OUT
			'0' when c_op = "1111" and ir(4 downto 0) /= "01000" ELSE -- SPECIALS EXCEPTO GETIID
			'1'; --RESTA
			
	with c_op select
	addr_a <= ir(11 downto 9) when "0101", --MOV/MOVHI
		      ir(8 downto 6) when others;
	   
	addr_d <= ir(11 downto 9);
										  
	addr_b <= ir(2 downto 0) when (c_op = "0000" or c_op = "0001" or c_op = "1000") else --ARIT, CMP, EXTARIT
			    ir(11 downto 9); 
	 
	with c_op select
	immedAux(7 downto 0) <= ir(7 downto 0) when "0101", --MOVI/MOVHI
							ir(7 downto 0) when "0110", --BZ/BNZ
					     	ir(5)&ir(5)&ir(5 downto 0) when others; --LD/ST

	immed(7  downto 0) <= immedAux(7 downto 0);
	immed(15 downto 8) <= (others => immedAux(7));

	with c_op select
	wr_m <= '1' when "0100", --ST
			'1' when "1110", --STB
			'0' when others; --OTHERS
			
	with c_op select 
	in_d <= "01" when "0011", --LD
			"01" when "0100", --ST
			"01" when "1101", --LDB
			"01" when "1110", --STB
			"10" when "1010", --JAL
			"11" when "0111", --IN
			"11" when "1111", --GETIID
			"00" when others; --ALU

	addr_io <= ir(7 downto 0);
			
	rd_in <=  '1' when  ir(8) = '0' and c_op = "0111" else '0';
	wr_out <= '1' when  ir(8) = '1' and c_op = "0111" else '0';
	
	with c_op select
	immed_x2 <= '0' when "0101", --MOV
				'0' when "0010", --ADDI
				not(ir(15)) when others; --MEM
	word_byte <= ir(15);

	immedPC <= immedAux(7 downto 0);

	newPCb(7 downto 0) <= immedPC(6 downto 0)&'0' when (ir(8) = '0' and z = '1') or (ir(8) = '1' and z = '0');	  --BNZ

	newPCb(15 DOWNTO 8) <= (others => immedPC(7));
	tknbr <= "01" when c_op = "0110" and ((ir(8) = '0' and z = '1') or (ir(8) = '1' and z = '0')) else --BZ/BNZ
			 "10" when c_op = "1010" and ((ir(2 downto 0) = "000" and z = '1') or	--JZ
										  (ir(2 downto 0) = "001" and z = '0') or  			--JNZ
										  (ir(2 downto 0) = "011") or 							--JMP
										  (ir(2 downto 0) = "100")) else 						--JAL
			 "10" when c_op = "1111" and ir(4 downto 0) = "00100" else					--RETI
			 "00";
			 
	--INTERRUPTS
	RSlect <= '1' when c_op = "1111" and ir(4 downto 0) = "01100" and systemMode = '1' else '0'; --RDS
	RSescr <= '1' when c_op = "1111" and ir(4 downto 0) = "10000" and systemMode = '1' else '0'; --WRS
	EIntrr <= "11" when c_op = "1111" and ir(4 downto 0) = "00000" and systemMode = '1' else 		--EI
				 "10" when c_op = "1111" and ir(4 downto 0) = "00001" and systemMode = '1' else		--DI
				 "00";
	RETI <= '1' when c_op = "1111" and ir(4 downto 0) = "00100" and systemMode = '1' else '0'; --RETI
	
	inta <= '1' when c_op = "1111" and ir(4 downto 0) = "01000" and systemMode = '1' else '0'; --GETIID
	
	excep_protec <= '1' when systemMode = '0' and c_op = "1111" and -- except proteccion: codigo Except : 13
									(ir(4 downto 0) = "01100" or --RDS
									ir(4 downto 0) = "10000" or  --WRS
									ir(4 downto 0) = "00000" or  --EI
									ir(4 downto 0) = "00001" or  --DI
									ir(4 downto 0) = "00100" or  --RETI
									ir(4 downto 0) = "01000" or  --GETIID
									ir(4 downto 0) = "10100" or  --WRPI
									ir(4 downto 0) = "10101" or  --WRVI
									ir(4 downto 0) = "10110" or  --WRPD 
									ir(4 downto 0) = "10111")    --WRVD
									else '0';
	calls <= '1' when c_op = "1010" and  ir(5 downto 0) = "000111" and systemMode = '0' else '0'; --CALL codigo Except: 14
	
	
	--TLB
	with op_auxTLB select
	irTLB <= "0001" when "1111110100", -- WRPI
				"0010" when "1111110101", -- WRVI
				"0100" when "1111110110", -- WRPD
				"1000" when "1111110111", -- WRVD
				"0000" when others;
	
	with c_op select
	ld_st <= '1' when "0011", --LD
			'1' when "0100", --ST
			'1' when "1101", --LDB
			'1' when "1110", --STB
			'0' when others;		
	
END Structure;