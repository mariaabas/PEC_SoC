LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY TLB IS
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
END TLB;

ARCHITECTURE Structure OF TLB IS

	type VIRTUAL  is array (7 downto 0) of std_logic_vector(3 downto 0);
	type PHYSICAL is array (7 downto 0) of std_logic_vector(5 downto 0); -- bit 5: validez; bit 4: ReadOnly
	
	SIGNAL VTLB_DATA	  : VIRTUAL;
	SIGNAL PTLB_DATA	  : PHYSICAL;
	
	SIGNAL VTLB_INSTR   : VIRTUAL;
	SIGNAL PTLB_INSTR   : PHYSICAL;

BEGIN

-- TLB
process(clk) begin
		if (rising_edge(clk)) then
		
			--Inicializaciones
			if (boot = '1') then 
				--Instr
				VTLB_INSTR(0) <= "0000"; PTLB_INSTR(0) <= "100000"; --USER 0
				VTLB_INSTR(1) <= "0001"; PTLB_INSTR(1) <= "100001"; --USER 1
				VTLB_INSTR(2) <= "0010"; PTLB_INSTR(2) <= "100010"; --USER 2
				VTLB_INSTR(3) <= "1000"; PTLB_INSTR(3) <= "101000"; --SYSTEM 8
				VTLB_INSTR(4) <= "1100"; PTLB_INSTR(4) <= "101100"; --ROM C
				VTLB_INSTR(5) <= "1101"; PTLB_INSTR(5) <= "101101"; --ROM D 
				VTLB_INSTR(6) <= "1110"; PTLB_INSTR(6) <= "111110"; --ROM E 
				VTLB_INSTR(7) <= "1111"; PTLB_INSTR(7) <= "111111"; --ROM F

				--Data
				VTLB_DATA(0) <= "0000"; PTLB_DATA(0) <= "100000"; --USER 0
				VTLB_DATA(1) <= "0001"; PTLB_DATA(1) <= "100001"; --USER 1
				VTLB_DATA(2) <= "0010"; PTLB_DATA(2) <= "100010"; --USER 2
				VTLB_DATA(3) <= "1000"; PTLB_DATA(3) <= "101000"; --SYSTEM 8
				VTLB_DATA(4) <= "1100"; PTLB_DATA(4) <= "101100"; --ROM C
				VTLB_DATA(5) <= "1101"; PTLB_DATA(5) <= "101101"; --ROM D
				VTLB_DATA(6) <= "1110"; PTLB_DATA(6) <= "111110"; --ROM E
				VTLB_DATA(7) <= "1111"; PTLB_DATA(7) <= "111111"; --ROM F
				
--				--Data SNAKE
--				--VTLB_DATA(0) <= "0100"; PTLB_DATA(0) <= "100100"; --USER 0
--				VTLB_DATA(0) <= "0000"; PTLB_DATA(0) <= "100000"; --USER 0
--				VTLB_DATA(1) <= "0001"; PTLB_DATA(1) <= "100001"; --USER 1
--				--VTLB_DATA(1) <= "1111"; PTLB_DATA(1) <= "101111"; -- F
--				VTLB_DATA(2) <= "0010"; PTLB_DATA(2) <= "100010"; --USER 2
--				--VTLB_DATA(2) <= "1110"; PTLB_DATA(2) <= "101110"; --ROM E
--				VTLB_DATA(3) <= "1000"; PTLB_DATA(3) <= "101000"; --SYSTEM 8
--				VTLB_DATA(4) <= "1100"; PTLB_DATA(4) <= "101100"; --ROM C
--				VTLB_DATA(5) <= "1101"; PTLB_DATA(5) <= "101101"; --ROM D
--				--VTLB_DATA(6) <= "1110"; PTLB_DATA(6) <= "111110"; --ROM E
--				VTLB_DATA(6) <= "1011"; PTLB_DATA(6) <= "101011"; --ROM B 	
--				--VTLB_DATA(7) <= "1111"; PTLB_DATA(7) <= "111111"; --ROM F
--				VTLB_DATA(7) <= "1010"; PTLB_DATA(7) <= "101010"; --ROM A
			end if;
			--Actualizaciones
			if (irTLB(0) = '1') then
				PTLB_INSTR(conv_integer(A)) <= B; -- WRPI
			end if;
			if (irTLB(1) = '1') then
				VTLB_INSTR(conv_integer(A)) <= B(3 downto 0); -- WRVI
			end if;
			if (irTLB(2) = '1') then 
				PTLB_DATA(conv_integer(A)) <=  B; -- WRPD
			end if;
			if (irTLB(3) = '1') then 
				VTLB_DATA(conv_integer(A)) <= B(3 downto 0); -- WRVD
			end if;
	end if;
end process;

	 
	 MissTLBInstr <= '1' when irTLB /= "0001" and irTLB /= "0010" and
									 (VTLB_INSTR(0) /= TAG_INSTR and
									  VTLB_INSTR(1) /= TAG_INSTR and
									  VTLB_INSTR(2) /= TAG_INSTR and
									  VTLB_INSTR(3) /= TAG_INSTR and
									  VTLB_INSTR(4) /= TAG_INSTR and
									  VTLB_INSTR(5) /= TAG_INSTR and
									  VTLB_INSTR(6) /= TAG_INSTR and
									  VTLB_INSTR(7) /= TAG_INSTR)
									  else '0'; 						--MISS TLB INSTR; except 6	
									  
	 MissTLBData <= '1' when ld_st = '1' and irTLB /= "0100" and irTLB /= "1000" and 
									 (VTLB_DATA(0) /= TAG_DATA and
									  VTLB_DATA(1) /= TAG_DATA and
									  VTLB_DATA(2) /= TAG_DATA and
									  VTLB_DATA(3) /= TAG_DATA and
									  VTLB_DATA(4) /= TAG_DATA and
									  VTLB_DATA(5) /= TAG_DATA and
									  VTLB_DATA(6) /= TAG_DATA and
									  VTLB_DATA(7) /= TAG_DATA)
									  else '0'; 						--MISS TLB DATA; except 7
									  
	 InvTLBInstr <= '1' when  irTLB /= "0001" and irTLB /= "0010" and 
									 ((VTLB_INSTR(0) = TAG_INSTR and PTLB_INSTR(0)(5) = '0') or
									  (VTLB_INSTR(1) = TAG_INSTR and PTLB_INSTR(1)(5) = '0') or
									  (VTLB_INSTR(2) = TAG_INSTR and PTLB_INSTR(2)(5) = '0') or
									  (VTLB_INSTR(3) = TAG_INSTR and PTLB_INSTR(3)(5) = '0') or
									  (VTLB_INSTR(4) = TAG_INSTR and PTLB_INSTR(4)(5) = '0') or
									  (VTLB_INSTR(5) = TAG_INSTR and PTLB_INSTR(5)(5) = '0') or
									  (VTLB_INSTR(6) = TAG_INSTR and PTLB_INSTR(6)(5) = '0') or
									  (VTLB_INSTR(7) = TAG_INSTR and PTLB_INSTR(7)(5) = '0'))
									  else '0'; 						--INV TLB INSTR; except 8
									 
									 
	 InvTLBData  <= '1' when ld_st = '1' and irTLB /= "0100" and irTLB /= "1000" and
									 ((VTLB_DATA(0) = TAG_DATA and PTLB_DATA(0)(5) = '0') or
									  (VTLB_DATA(1) = TAG_DATA and PTLB_DATA(1)(5) = '0') or
									  (VTLB_DATA(2) = TAG_DATA and PTLB_DATA(2)(5) = '0') or
									  (VTLB_DATA(3) = TAG_DATA and PTLB_DATA(3)(5) = '0') or
									  (VTLB_DATA(4) = TAG_DATA and PTLB_DATA(4)(5) = '0') or
									  (VTLB_DATA(5) = TAG_DATA and PTLB_DATA(5)(5) = '0') or
									  (VTLB_DATA(6) = TAG_DATA and PTLB_DATA(6)(5) = '0') or
									  (VTLB_DATA(7) = TAG_DATA and PTLB_DATA(7)(5) = '0'))
									  else '0';
									  
	 
	  ProtTBLInstr <= '0';
	  ProtTBLData  <= '0';
	  
	  RoTLBData  <= '1' when  wr_m = '1' and irTLB /= "0100" and irTLB /= "1000" and
									  ((VTLB_DATA(0) = TAG_DATA and PTLB_DATA(0)(5) = '1' and PTLB_DATA(0)(4) = '1') or				 
									  (VTLB_DATA(1) = TAG_DATA and PTLB_DATA(1)(5) = '1' and PTLB_DATA(1)(4) = '1') or		
									  (VTLB_DATA(2) = TAG_DATA and PTLB_DATA(2)(5) = '1' and PTLB_DATA(2)(4) = '1') or		
									  (VTLB_DATA(3) = TAG_DATA and PTLB_DATA(3)(5) = '1' and PTLB_DATA(3)(4) = '1') or		
									  (VTLB_DATA(4) = TAG_DATA and PTLB_DATA(4)(5) = '1' and PTLB_DATA(4)(4) = '1') or		
									  (VTLB_DATA(5) = TAG_DATA and PTLB_DATA(5)(5) = '1' and PTLB_DATA(5)(4) = '1') or		
									  (VTLB_DATA(6) = TAG_DATA and PTLB_DATA(6)(5) = '1' and PTLB_DATA(6)(4) = '1') or		
									  (VTLB_DATA(7) = TAG_DATA and PTLB_DATA(7)(5) = '1' and PTLB_DATA(7)(4) = '1'))
									  else '0'; 						--Ro TLB DATA; except 12
	 
	  TAG_ADDRESSIr <= PTLB_INSTR(0)(3 downto 0) when (VTLB_INSTR(0) = TAG_INSTR and PTLB_DATA(0)(5) = '1') else
					 PTLB_INSTR(1)(3 downto 0) when (VTLB_INSTR(1) = TAG_INSTR and PTLB_DATA(1)(5) = '1') else
					 PTLB_INSTR(2)(3 downto 0) when (VTLB_INSTR(2) = TAG_INSTR and PTLB_DATA(2)(5) = '1') else
					 PTLB_INSTR(3)(3 downto 0) when (VTLB_INSTR(3) = TAG_INSTR and PTLB_DATA(3)(5) = '1') else
					 PTLB_INSTR(4)(3 downto 0) when (VTLB_INSTR(4) = TAG_INSTR and PTLB_DATA(4)(5) = '1') else
					 PTLB_INSTR(5)(3 downto 0) when (VTLB_INSTR(5) = TAG_INSTR and PTLB_DATA(5)(5) = '1') else
					 PTLB_INSTR(6)(3 downto 0)when (VTLB_INSTR(6) = TAG_INSTR and PTLB_DATA(6)(5) = '1') else
					 PTLB_INSTR(7)(3 downto 0) when (VTLB_INSTR(7) = TAG_INSTR and PTLB_DATA(7)(5) = '1');
					 

TAG_ADDRESSData <= PTLB_DATA(0)(3 downto 0) when (VTLB_DATA(0) = TAG_DATA and PTLB_DATA(0)(5) = '1') else
					 PTLB_DATA(1)(3 downto 0) when (VTLB_DATA(1) = TAG_DATA and PTLB_DATA(1)(5) = '1') else
					 PTLB_DATA(2)(3 downto 0) when (VTLB_DATA(2) = TAG_DATA and PTLB_DATA(2)(5) = '1') else
					 PTLB_DATA(3)(3 downto 0) when (VTLB_DATA(3) = TAG_DATA and PTLB_DATA(3)(5) = '1') else
					 PTLB_DATA(4)(3 downto 0) when (VTLB_DATA(4) = TAG_DATA and PTLB_DATA(4)(5) = '1') else
					 PTLB_DATA(5)(3 downto 0) when (VTLB_DATA(5) = TAG_DATA and PTLB_DATA(5)(5) = '1') else
					 PTLB_DATA(6)(3 downto 0) when (VTLB_DATA(6) = TAG_DATA and PTLB_DATA(6)(5) = '1') else
					 PTLB_DATA(7)(3 downto 0) when (VTLB_DATA(7) = TAG_DATA and PTLB_DATA(7)(5) = '1');
					 
					 

END Structure;