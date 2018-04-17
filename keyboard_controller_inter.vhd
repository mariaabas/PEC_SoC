LIBRARY ieee;
USE ieee.std_logic_1164.all; 
 
ENTITY keyboard_controller_inter IS
	 Port(clk 		 : in 	STD_LOGIC;
			  inta 		 : in    STD_LOGIC;
		     reset      : in    STD_LOGIC;
			  ps2_clk    : inout STD_LOGIC;
			  ps2_data   : inout STD_LOGIC;
			  read_char  : out   STD_LOGIC_VECTOR (7 downto 0);
           clear_char : in    STD_LOGIC;
           data_ready : out   STD_LOGIC;
			  intr 		 : out   STD_LOGIC);
END keyboard_controller_inter; 
 
ARCHITECTURE Structure OF keyboard_controller_inter IS

	COMPONENT keyboard_controller is
    Port (clk        : in    STD_LOGIC;
          reset      : in    STD_LOGIC;
          ps2_clk    : inout STD_LOGIC;
          ps2_data   : inout STD_LOGIC;
          read_char  : out   STD_LOGIC_VECTOR (7 downto 0);
          clear_char : in    STD_LOGIC;
          data_ready : out   STD_LOGIC);
	END COMPONENT;

SIGNAL clear_charAux : STD_LOGIC:='0';
SIGNAL data_readyAux : STD_LOGIC:='0';
	
BEGIN
	
	intr <= data_readyAux when reset = '0' else '0';
	data_ready <= data_readyAux;

	clear_charAux <= inta when inta = '1' else clear_char;
	
	k_c: keyboard_controller
		Port Map(clk => clk, reset => reset, ps2_clk => ps2_clk, ps2_data => ps2_data,
					read_char => read_char, clear_char => clear_charAux, data_ready => data_readyAux);
	
END Structure;