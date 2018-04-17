LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY controladores_IO IS
	PORT (boot 		: IN STD_LOGIC;
			CLOCK_50 : IN std_logic;
			addr_io 	: IN std_logic_vector(7 downto 0);
			wr_io 	: in std_logic_vector(15 downto 0);
			rd_io 	: out std_logic_vector(15 downto 0);
			wr_out 	: in std_logic;
			rd_in 	: in std_logic;
			led_verdes : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			led_rojos  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			pulsadores : IN STD_LOGIC_VECTOR(3 downto 0);
			interruptores : IN STD_LOGIC_VECTOR(7 downto 0);
			visor0		  : OUT STD_LOGIC_VECTOR(4 downto 0);
			visor1		  : OUT STD_LOGIC_VECTOR(4 downto 0);
			visor2		  : OUT STD_LOGIC_VECTOR(4 downto 0);
			visor3		  : OUT STD_LOGIC_VECTOR(4 downto 0);
			ps2_clk  : inout std_logic;
			ps2_data : inout std_logic;
			vga_cursor : out std_logic_vector(15 downto 0);
			vga_cursor_enable : out std_logic;
			intr 		: OUT	STD_LOGIC;
			inta 		: IN 	STD_LOGIC);
END controladores_IO;

ARCHITECTURE Structure OF controladores_IO IS

	type PORTS is array (255 downto 0) of std_logic_vector(15 downto 0);
   signal por          : PORTS;
	SIGNAL read_charAux : STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL data_readyAux: STD_LOGIC:='0';
	SIGNAL clear_charAux: STD_LOGIC:='0';
	SIGNAL iidAux: STD_LOGIC_VECTOR(7 downto 0);
	signal contador_ciclos : STD_LOGIC_VECTOR(15 downto 0):=x"0000";
	signal contador_milisegundos : STD_LOGIC_VECTOR(15 downto 0):=x"0000";
	
	signal ps2_intrAux : std_logic:='0';
	signal ps2_intaAux : std_logic:='0';
	
	signal key_intrAux : std_logic:='0';
	signal key_intaAux : std_logic:='0';
	
	signal switch_intrAux : std_logic:='0';
	signal switch_intaAux : std_logic:='0';
	
	signal timer_intrAux : std_logic:='0';
	signal timer_intaAux : std_logic:='0';
	
	COMPONENT keyboard_controller_inter is
		Port(clk 		 : in 	STD_LOGIC;
			  inta 		 : in    STD_LOGIC;
		     reset      : in    STD_LOGIC;
			  ps2_clk    : inout STD_LOGIC;
			  ps2_data   : inout STD_LOGIC;
			  read_char  : out   STD_LOGIC_VECTOR (7 downto 0);
           clear_char : in    STD_LOGIC;
           data_ready : out   STD_LOGIC;
			  intr 		 : out   STD_LOGIC);
	END COMPONENT;
	
	COMPONENT key_controller is
	 Port(clk : in STD_LOGIC;
	      boot : in STD_LOGIC;
			inta : in STD_LOGIC;
		   keys : in STD_LOGIC_VECTOR(3 DOWNTO 0);
			intr : out STD_LOGIC);
	END COMPONENT;
	
	COMPONENT switch_controller is
	 Port(clk : in STD_LOGIC;
	      boot : in STD_LOGIC;
			inta : in STD_LOGIC;
		   switches : in STD_LOGIC_VECTOR(7 DOWNTO 0);
			intr : out STD_LOGIC);
	END COMPONENT;
	
	COMPONENT timer_controller is 
		Port (clk 	:	in STD_LOGIC;
				boot 	:  in STD_LOGIC;
				inta  :  in STD_LOGIC;
				intr  :  out STD_LOGIC);
	END COMPONENT;
				
	COMPONENT interrupt_controller IS
	PORT (boot 			: IN STD_LOGIC;
			clk 			: IN std_logic;
			inta 			: IN std_logic;
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
	END COMPONENT;
	
BEGIN

	PROCESS (CLOCK_50) BEGIN
		IF(rising_edge(CLOCK_50)) THEN
		
			if contador_ciclos=0 then
				contador_ciclos<=x"C350"; -- tiempo de ciclo=20ns(50Mhz) 1ms=50000ciclos
					if contador_milisegundos>0 then
						contador_milisegundos <= contador_milisegundos-1;
					end if;
			else
				contador_ciclos <= contador_ciclos-1;
			end if;
				
			clear_charAux <= '0';
			por(7)(3 downto 0) <= pulsadores;
			por(8)(7 downto 0) <= interruptores;
			por(21) <= contador_milisegundos;
			por(20) <= contador_ciclos;
			IF(wr_out = '1') THEN
				IF (addr_io = "0010000") THEN				--PORT 16
					clear_charAux <= '1';
					por(conv_integer(addr_io)) <= (others => '0');
				END IF;
				IF (conv_integer(addr_io) /= 20) THEN
					por(conv_integer(addr_io)) <= wr_io;
					IF (conv_integer(addr_io) = 21) THEN
						contador_milisegundos <=wr_io;
					end if;		
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	rd_io <=    "00000000" & iidAux when inta = '1' else												 -- GETIID
				"00000000" & read_charAux when (rd_in = '1' and addr_io = "0001111") else 			 -- PORT15 -> KEYBOARD
				"000000000000000" & data_readyAux when (rd_in = '1' and addr_io = "0010000") else    -- PORT16 -> READY
				por(conv_integer(addr_io))		when rd_in = '1';									 -- OTHER PORTS
				
	visor0 <= not(por(9)(0)) & por(10)(3 downto 0);
	visor1 <= not(por(9)(1)) & por(10)(7 downto 4);
	visor2 <= not(por(9)(2)) & por(10)(11 downto 8);
	visor3 <= not(por(9)(3)) & por(10)(15 downto 12);
	led_verdes <= por(5)(7 downto 0);
	led_rojos  <= por(6)(7 downto 0);
	
	k_c: keyboard_controller_inter
		Port Map(clk => CLOCK_50, inta => ps2_intaAux, reset => boot, ps2_clk => ps2_clk, ps2_data => ps2_data,
				read_char => read_charAux, clear_char => clear_charAux, data_ready => data_readyAux, intr => ps2_intrAux);
	
	key0: key_controller
		Port Map(clk => CLOCK_50, boot => boot, inta => key_intaAux,
				keys => pulsadores, intr => key_intrAux);
				
	switch0: switch_controller
		Port Map(clk => CLOCK_50, boot => boot, inta => switch_intaAux,
					switches => interruptores, intr => switch_intrAux);
		
	timer0: timer_controller
		Port Map(clk => CLOCK_50, boot => boot, inta => timer_intaAux, intr => timer_intrAux);
	 
	i_c0: interrupt_controller
		Port Map(boot => boot, clk => CLOCK_50, inta => inta, key_intr => key_intrAux,
					ps2_intr => ps2_intrAux, switch_intr => switch_intrAux, timer_intr => timer_intrAux,
					intr => intr, key_inta => key_intaAux, ps2_inta => ps2_intaAux, switch_inta => switch_intaAux,
					timer_inta => timer_intaAux, iid => iidAux);
			
END Structure; 