library ieee;
USE ieee.std_logic_1164.all;

entity multi is
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
			except : IN STD_LOGIC;
		c_except : OUT STD_LOGIC;
		excep_protec : IN STD_LOGIC;
		excep_protec2 : OUT STD_LOGIC;
		EIntrr	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		EIntrr2  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
end entity;

architecture Structure of multi is

    type state_type is (F, DEMW, SYSTEM);
	
	signal estado_actual: state_type;
	
begin

	process (clk, boot)
	begin
		if boot = '1' then
			estado_actual <= F;
		elsif (rising_edge(clk)) then
			case estado_actual is
				when F =>
					estado_actual <= DEMW;
				when DEMW =>
					IF ((intr = '1' and INTER = '1') or except = '1') THEN
						c_interr <= '1';
						c_except <= '1';
						estado_actual <= SYSTEM;
					ELSE
						estado_actual <= F;
					END IF;
				when SYSTEM =>
					c_interr <= '0';
					c_except <= '0';
					estado_actual <= F;
			end case;
		end if;
	end process;
				
	wr_m <= wr_m_l when estado_actual=DEMW else '0';
	ldpc <= ldpc_l when estado_actual=DEMW or estado_actual=SYSTEM else '0';
	wrd <= wrd_l when estado_actual=DEMW else '0';
	word_byte <= w_b when estado_actual=DEMW else '0';
	ins_dad <= '1' when estado_actual=DEMW else '0';
	ldir <= '0' when estado_actual=DEMW else '1';
	excep_protec2 <= excep_protec when estado_actual=DEMW else '0';
	EIntrr2 <= EIntrr when estado_actual=DEMW else "00";

end Structure;
