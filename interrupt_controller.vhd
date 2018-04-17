LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY interrupt_controller IS
	PORT (boot 			: IN STD_LOGIC;
			clk 			: IN std_logic;
			inta 			: IN std_logic:= '0';
			key_intr 	: in std_logic;
			ps2_intr 	: in std_logic;
			switch_intr : in std_logic;
			timer_intr 	: in std_logic;
			
			intr 			: OUT STD_LOGIC;
			key_inta  	: OUT STD_LOGIC;
			ps2_inta 	: OUT STD_LOGIC;
			switch_inta : OUT STD_LOGIC;
			timer_inta	: OUT STD_LOGIC;
			iid		  	: OUT STD_LOGIC_VECTOR(7 downto 0));
END interrupt_controller;

ARCHITECTURE Structure OF interrupt_controller IS

	SIGNAL vect_intr : STD_LOGIC_VECTOR(3 downto 0):= "0000";				
	
BEGIN

	process(clk, boot) begin 
		if (rising_edge(clk)) then
			iid <= "10101010";
			if (boot = '1') then 
				iid <= "01010101";
				intr <= '0'; 
			--INTA
			elsif (inta = '1') then
				intr <= '0';
				if (vect_intr(0) = '1') then	  --TIMER
					iid <= "00000000";
					timer_inta <= '1';
				elsif (vect_intr(1) = '1') then --KEYS
					iid <= "00000001";
					key_inta <= '1';
				elsif (vect_intr(2) = '1') then --SWITCHES
					iid <= "00000010";
					switch_inta <= '1';
				elsif (vect_intr(3) = '1') then --KEYBOARD
					iid <= "00000011";
					ps2_inta <= '1';
				else
					iid <= "00000100";				
				end if;
			--INTR
			elsif (timer_intr = '1' or key_intr = '1' or switch_intr = '1' or ps2_intr = '1') then
				vect_intr(0) <= timer_intr;				
				vect_intr(1) <= key_intr;
				vect_intr(2) <= switch_intr;
				vect_intr(3) <= ps2_intr;
				intr <= '1';
			else
				timer_inta <= '0';
				key_inta <= '0';
				switch_inta <= '0';
				ps2_inta <= '0';
			end if;
			
			
		end if;
	end process;

END Structure; 
