LIBRARY ieee;
USE ieee.std_logic_1164.all; 
 USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY timer_controller IS
	 	Port (clk 	:	in STD_LOGIC;
				boot 	:  in STD_LOGIC;
				inta  :  in STD_LOGIC;
				intr  :  out STD_LOGIC);
END timer_controller; 
 
ARCHITECTURE Structure OF timer_controller IS

signal contador_ciclos : STD_LOGIC_VECTOR(23 downto 0);

BEGIN

	process (clk) begin
		if rising_edge(clk) then
			if boot = '1' then
				contador_ciclos<=x"2625A0";
				intr <= '0';
			elsif contador_ciclos = 0 then
				contador_ciclos<=x"2625A0"; -- tiempo de ciclo=20ns(50Mhz) 1ms=50000ciclos; 50ms * 50000 = 2625A0
				intr <= '1';
			else
				contador_ciclos <= contador_ciclos-1;
			end if;
			if (inta = '1')  then 
				intr <= '0';
			end if;
		end if;
	end process;

END Structure;
