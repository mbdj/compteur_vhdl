--
-- Compteur + affichage sur LCD DISPLAY 5611AH à cathode commune
--
-- Mehdi Ben Djedidia 10/09/2022
--
--			A
--		   _
--		F | |B
--			G
--			_
--		 E| | C
--			_
--			D
--
-- rappel du codage binaire BCD

--	0	0000
--	1	0001
--	2	0010
--	3	0011
--	4	0100
--	5	0101
--	6	0110
--	7	0111
--	8	1000
--	9	1001
--
-- pin out du 5611AH (cathode commune):
--
--   10(G) 9(F) 8(GROUND) 7(A) 6(B)
--
--				A
--			   _
--			F | |B
--				G
--				_
--		 	 E| | C
--				_ .DP
--				D
-- 
--   1(E) 2(D) 3(GROUND) 4(C) 5(DP)
--



library ieee;
use ieee.std_logic_1164.all;

-- Afficher le chiffre en allument les 8 leds (A à G) du 5611AH en fonction du nombre bcd en entrée (N)
entity LED_DISPLAY is port
(
	N : in std_logic_vector(3 downto 0);	-- nombre codé binaire 0 (0000) à 9 (1000)
	A, B, C, D, E, F, G : out std_logic	-- segments led de l'afficheur
);
end;


architecture LED_DISPLAY_ARCHITECTURE of LED_DISPLAY is
begin

-- on allume les segments A à G en fonction du nombre N
A <= '1' when (N="0000" or N="0010" or N="0011" or N="0101" or N="0110" or N="0111" or N="1000" or N="1001") else '0';
B <= '1' when (N="0000" or N="0001" or N="0010" or N="0011" or N="0100" or N="0111" or N="1000" or N="1001") else '0';
C <= '1' when (N="0000" or N="0001" or N="0011" or N="0100" or N="0101" or N="0110" or N="0111" or N="1000" or N="1001") else '0';
D <= '1' when (N="0000" or N="0010" or N="0011" or N="0101" or N="0110" or N="1000" or N="1001") else '0';
E <= '1' when (N="0000" or N="0010" or N="0110" or N="1000") else '0';
F <= '1' when (N="0000" or N="0100" or N="0101" or N="0110" or N="1000" or N="1001") else '0';
G <= '1' when (N="0010" or N="0011" or N="0100" or N="0101" or N="0110" or N="1000" or N="1001") else '0';


end LED_DISPLAY_ARCHITECTURE;


--
-- Division de l'horloge de la carte (pin 12 sur la carte "perso MAX2")
--
library ieee;
use ieee.std_logic_1164.all;
entity CLOCK is port
(
	CLK_IN  : in std_logic;
	CLK_OUT : inout std_logic
);
end;


-- Voir https://www.youtube.com/watch?v=9HvN6tlGteo
architecture CLOCK_ARCHITECTURE of CLOCK is
signal Compteur : integer := 1;
begin

	process(CLK_IN)
	
	begin
			-- pour obtenir 1 Hz à partir de l'horloge 50MHz
			if rising_edge(CLK_IN) then
				if Compteur > 25_000_000 / 2 then
					CLK_OUT <= not CLK_OUT;
					Compteur <= 1;
				else
					Compteur<= Compteur+1;
				end if;
			end if;
		
	end process;
	
end CLOCK_ARCHITECTURE;




--
-- Compteur
-- incrémente la sortie à chaque coup d'horloge
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_Logic_Arith.all;
entity COMPTEUR is port
(
	CLOCK : in std_logic; -- horloge en entrée
	CPT : out std_logic_vector(3 downto 0) -- nombre incrémenté en sortie
);
end;

architecture COMPTEUR_ARCHITECTURE of COMPTEUR is
signal compteur : integer range 0 to 9 := 0;
begin
	process
	begin
		if(compteur < 9) then
			compteur <= compteur + 1;
		else
			compteur <= 0;
		end if;
		
		CPT <= conv_std_logic_vector(compteur, CPT'length);	-- CPT <= compteur;
		wait until rising_edge(CLOCK);
	end process;
end COMPTEUR_ARCHITECTURE;




--
-- Compteur
-- compte de 0 à 9 à une fréquence de 1 incrément par seconde (1 Hz)
--
library ieee;
use ieee.std_logic_1164.all;
entity COMPTEUR_DISPLAY is port
(
	CLOCK_IN : in std_logic; -- clock 50 MHz en entrée
	A, B, C, D, E, F, G : out std_logic	-- segments led de l'afficheur
);
end;

architecture COMPTEUR_DISPLAY_ARCHITECTURE of COMPTEUR_DISPLAY is

	component LED_DISPLAY
	port (
		N : in std_logic_vector(3 downto 0);	-- nombre codé binaire 0 (0000) à 9 (1000)
		A, B, C, D, E, F, G : out std_logic		-- segments led de l'afficheur
	);
	end component LED_DISPLAY;
	
	component CLOCK
	port (
		CLK_IN  : in std_logic;
		CLK_OUT : out std_logic
	);
	end component CLOCK;
	
	component COMPTEUR
	port (
		CLOCK : in std_logic; -- horloge en entrée
		CPT : out std_logic_vector(3 downto 0) -- nombre incrémenté en sortie
	);
	end component COMPTEUR;

	signal CLK : std_logic; -- clk en sortie de CLOCK : donne le top pour l'incrément du compteur
	signal CPT : std_logic_vector(3 downto 0);
	
begin

	TheClock : CLOCK port map (CLK_IN => CLOCK_IN, CLK_OUT => CLK);
	TheCompteur : COMPTEUR port map (CLOCK => CLK, CPT => CPT);
	TheDisplay : LED_DISPLAY port map (	N => CPT,
												A => A,
												B => B,
												C => C,
												D => D,
												E => E,
												F => F,
												G => G);
	
end COMPTEUR_DISPLAY_ARCHITECTURE;

