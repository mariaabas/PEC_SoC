LIBRARY ieee;
USE ieee.std_logic_1164.all; 
 
ENTITY driver7Segmentos IS
	PORT( codigoCaracter : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
			bitsCaracter   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END driver7Segmentos; 
 
ARCHITECTURE Structure OF driver7Segmentos IS

BEGIN
	with codigoCaracter select
	bitsCaracter <= "1000000" WHEN "00000",
						 "1111001" WHEN "00001",
						 "0100100" WHEN "00010",
						 "0110000" WHEN "00011",
						 "0011001" WHEN "00100",
						 "0010010" WHEN "00101",
						 "0000010" WHEN "00110",
						 "1111000" WHEN "00111",
						 "0000000" WHEN "01000",
						 "0011000" WHEN "01001",
						 "0001000" WHEN "01010",
						 "0000011" WHEN "01011",
						 "1000110" WHEN "01100",
						 "0100001" WHEN "01101",
						 "0000110" WHEN "01110",
						 "0001110" WHEN "01111",
						 "1111111" WHEN OTHERS;
END Structure;