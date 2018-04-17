LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY exception_controller IS
	PORT (boot : IN STD_LOGIC;
			intr 			: IN STD_LOGIC;
			div_zero		: IN std_logic;
			ilegal_ir 	: in std_logic;
			invalid_access: IN STD_LOGIC;
			except 		: OUT STD_LOGIC;
			codigoEx		: OUT STD_LOGIC_VECTOR(3 downto 0);
			excep_protec : IN STD_LOGIC;
			calls : IN STD_LOGIC;
			mem_protec : IN STD_LOGIC;
			INTER : IN STD_LOGIC;
			c_interr: IN STD_LOGIC;
			MissTLBInstr : IN STD_LOGIC; --6
			MissTLBData : IN STD_LOGIC; --7
			InvTLBInstr : IN STD_LOGIC; --8
			InvTLBData : IN STD_LOGIC;  --9
			ProtTBLInstr : IN STD_LOGIC; --10
			ProtTBLData : IN STD_LOGIC; --11
			RoTLBData : IN STD_LOGIC);  --12
END exception_controller;

ARCHITECTURE Structure OF exception_controller IS

-- Necesario un vector de excepciones?

BEGIN
	
		except <= '1' when boot = '0' and (div_zero = '1' or
													ilegal_ir = '1' or
													  invalid_access = '1' or
												     excep_protec = '1' or
													  calls = '1' or
													  mem_protec = '1' or
													  MissTLBInstr = '1' or 
													  MissTLBData = '1' or 
													  InvTLBInstr = '1' or 
													  InvTLBData = '1' or
													  ProtTBLInstr = '1' or
													  ProtTBLData = '1' or
													  RoTLBData = '1')  --12
					 else '0';
	   
		codigoEx <= "0000" when ilegal_ir = '1' and c_interr = '0' else -- Instruccion ilegal --ex 0
					   "0001" when invalid_access = '1' and c_interr = '0' else -- Acceso invalido --ex 1
						"0100" when div_zero = '1' and c_interr = '0' else -- Divisio per zero -- ex 4
						"0110" when MissTLBInstr = '1' and c_interr = '0' else -- Miss de TLB instrucciones --ex 6
						"0111" when MissTLBData = '1' and c_interr = '0' else -- Miss de TLB datos --ex 7
						"1000" when InvTLBInstr = '1' and c_interr = '0' else -- Pagina invalida TLB instrucciones --ex 8
						"1001" when InvTLBData = '1' and c_interr = '0' else -- Pagina invalida TLB datos --ex 9
						"1010" when ProtTBLInstr = '1' and c_interr = '0' else -- Pagina protegida TLB de instrucciones --ex 10
						"1011" when ProtTBLData = '1' and c_interr = '0' else -- Pagina protegida TLB de datos --ex 11
						"1011" when mem_protec = '1' and c_interr = '0' else -- Proteccio memoria sistema -- ex 11
						"1100" when RoTLBData = '1' and c_interr = '0' else -- Pagina solo lectura --ex 12
						"1101" when excep_protec = '1' and c_interr = '0' else -- Mode usuari realitzant instruccions mode sistema -ex 13
						"1110" when calls = '1' and c_interr = '0' else -- System Call --ex 14
						"1111" when intr = '1' and INTER = '1' and c_interr = '0';	-- Interrupt --ex 15
						
		
END Structure; 
