LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY regfile IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
  		    pcint2  : in STD_LOGIC_VECTOR(15 DOWNTO 0);			 

          b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 boot	  : IN  STD_LOGIC;
			 RSlect : IN STD_LOGIC;
			 RSescr : IN STD_LOGIC;
			 EIntrr : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			 RETI	  : IN STD_LOGIC;
			 INTER  : OUT STD_LOGIC;
			 c_interr: IN  STD_LOGIC;
			 codigoEx: IN STD_LOGIC_VECTOR(3 downto 0);
			 addressEx: IN STD_LOGIC_VECTOR(15 downto 0);
			 systemMode : OUT STD_LOGIC);
END regfile;

ARCHITECTURE Structure OF regfile IS

	type REGISTRES is array (7 downto 0) of std_logic_vector(15 downto 0);
   signal reg          : REGISTRES;
	
	
	type SPECIALS is array (7 downto 0) of std_logic_vector(15 downto 0);
   signal spe          : SPECIALS;
	
BEGIN

	PROCESS (clk) BEGIN
		IF(rising_edge(clk)) THEN
			IF (boot = '1') THEN
				spe(7) <= (others => '0');
				spe(7)(0) <= '1';
			END IF;
			IF(WRD = '1') THEN
				reg(conv_integer(addr_d)) <= d;
			END IF;
			IF (RSescr = '1') THEN
				spe(conv_integer(addr_d)) <= reg(conv_integer(addr_a)); -- SPE <- REG
			END IF;
			IF (RSlect = '1') THEN
				reg(conv_integer(addr_d)) <= spe(conv_integer(addr_a)); -- REG <- SPE
			END IF;
			IF (EIntrr(1) = '1') THEN
				spe(7)(1) <= EIntrr(0);
			END IF;
			IF (RETI = '1') THEN
				spe(7) <= spe(0);
			END IF;
			IF (c_interr = '1') THEN
				spe(0) <= spe(7);
				spe(1) <= pcint2; 
				spe(2) <= "000000000000" & codigoEx;-- 15 si Inter, codigoEx si Excep
				spe(7)(1) <= '0';
				spe(7)(0) <= '1';
			END IF;
			IF (codigoEx = "0001") THEN	-- Mem mal alineada Except: 1
				spe(3) <= addressEx;
			END IF;
			IF (codigoEx >= "0110" and codigoEx <= "1100") THEN -- FALLO TLB
				spe(3) <= addressEx;
			END IF;
			IF (codigoEx = "1110") THEN
				spe(7)(0) <= '1';
				spe(3) <= reg(conv_integer(addr_a));
			END IF;
		END IF;
	END PROCESS;
	a <= spe(1) when RETI = '1' else		-- RETI
		  spe(5) when c_interr = '1' else	-- RSI
		  reg(conv_integer(addr_a));
		  
	b <= reg(conv_integer(addr_b));
	
	INTER <= spe(7)(1);
	
	systemMode <= spe(7)(0);	 
	
	
	
END Structure;