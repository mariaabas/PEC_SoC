LIBRARY ieee;
USE ieee.std_logic_1164.all; 
 
ENTITY key_controller IS
	 Port(clk : in STD_LOGIC;
	      boot : in STD_LOGIC;
			inta : in STD_LOGIC;
		   keys : in STD_LOGIC_VECTOR(3 DOWNTO 0);
			intr : out STD_LOGIC);
END key_controller; 
 
ARCHITECTURE Structure OF key_controller IS

SIGNAL estado_actual: STD_LOGIC_VECTOR(3 downto 0);

BEGIN

	process (clk) begin
		if (RISING_EDGE(clk)) then
			if (boot = '1') then
				estado_actual <= keys;
				intr <= '0'; 
			elsif (inta = '0') then 
				if (estado_actual /= keys) then
					estado_actual <= keys;
					intr <= '1';
				end if;
			else
				intr <= '0';
			end if;
   	end if;
	end process;

END Structure;
