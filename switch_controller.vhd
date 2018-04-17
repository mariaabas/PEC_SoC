LIBRARY ieee;
USE ieee.std_logic_1164.all; 
 
ENTITY switch_controller IS
	 Port(clk : in STD_LOGIC;
	      boot : in STD_LOGIC;
			inta : in STD_LOGIC;
		   switches : in STD_LOGIC_VECTOR(7 DOWNTO 0);
			intr : out STD_LOGIC);
END switch_controller; 
 
ARCHITECTURE Structure OF switch_controller IS

SIGNAL estado_actual: STD_LOGIC_VECTOR(7 downto 0);

BEGIN

	process (clk) begin
		if (RISING_EDGE(clk)) then
			if (boot = '1') then
				estado_actual <= switches;
				intr <= '0';
			elsif (inta = '0') then 
				if (estado_actual /= switches) then
					estado_actual <= switches;
					intr <= '1';
				end if;
			else
				intr <= '0';
			end if;
   	end if;
	end process;

END Structure;