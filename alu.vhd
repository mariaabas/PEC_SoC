LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
--USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_signed.all;

ENTITY alu IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		  z	 : OUT STD_LOGIC;
		  div_zero : OUT STD_LOGIC);
		  
END alu;


ARCHITECTURE Structure OF alu IS

SIGNAL wAux: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL SHA: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL SHL: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL DIV: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL CMPLT: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL CMPLE: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL CMPEQ: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL CMPLTU: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL CMPLEU: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL mulAuxS: STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
SIGNAL mulAuxU: STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
SIGNAL one: STD_LOGIC_VECTOR(15 downto 0):= "0000000000000001";
SIGNAL zeros: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

BEGIN


	div_zero <= '1' when (op = "1000100" or op = "1000101") and y = zeros else '0'; -- Div/0 Except: 4


	SHA <= To_StdLogicVector(To_bitvector(x) sll to_integer(signed(y(4 downto 0)))) when signed(y(4 downto 0)) > 0 else
		  To_StdLogicVector(To_bitvector(x) sra to_integer(signed(not(y(4 downto 0))+1)));
		
		   
	SHL <= To_StdLogicVector(To_bitvector(x) sll to_integer(signed(y(4 downto 0)))) when signed(y(4 downto 0)) > 0 else
		   To_StdLogicVector(To_bitvector(x) srl to_integer(signed(not(y(4 downto 0))+1)));

	mulAuxS <= x * y;	   
	mulAuxU <= STD_LOGIC_VECTOR(UNSIGNED(x) * UNSIGNED(y));
	
	CMPLT  <= one when SIGNED(x) < SIGNED(y)  else zeros;
	CMPLE  <= one when SIGNED(x) <= SIGNED(y) else zeros;
	CMPEQ  <= one when SIGNED(x) = SIGNED(y)  else zeros;
	CMPLTU <= one when UNSIGNED(x) < UNSIGNED(y)  else zeros;
	CMPLEU <= one when UNSIGNED(x) <= UNSIGNED(y) else zeros;
	
	DIV <= STD_LOGIC_VECTOR(SIGNED(x) / SIGNED(y));
	
	with op select
		wAux <= y when "0101000", 						   --MOVI
			 y(7 downto 0) & x(7 downto 0) when "0101001", --MOVHI
			 x + y when "0000100", 	 					   --ADD/ADDI/LD/ST/LDB/STB
			 x and y when "0000000",					   --AND
			 x or y when "0000001",						   --OR
			 x xor y when "0000010",					   --XOR
			 not(x) when "0000011",						   --NOT
			 x - y when "0000101",						   --SUB
			 SHA when "0000110",						   --SHA
			 SHL when "0000111", 						   --SHL
			 mulAuxS(15 downto 0)  when "1000000",		   --MUL
			 mulAuxS(31 downto 16) when "1000001",	 	   --MULH
			 mulAuxU(31 downto 16) when "1000010",		   --MULHU
			 (x(15) xor y(15))&DIV(14 downto 0)	 		 when "1000100", --DIV
			 STD_LOGIC_VECTOR(UNSIGNED(x) / UNSIGNED(y)) when "1000101", --DIVU
			 CMPLT  when "0001000",	 					   --CMPLT
			 CMPLE  when "0001001",						   --CMPLE
			 CMPEQ  when "0001011",						   --CMPEQ
			 CMPLTU when "0001100",						   --CMPLTU
			 CMPLEU when others;						   --CMPLEU (0001101)
			 
	z <= '1' when y = zeros else '0';
	w <= wAux;
   
END Structure;