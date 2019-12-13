----------------------------------------------------------------------------------
-- Company: INSA
-- Engineers: Bourlot Xavier - Zennaro Thomas
-- 
-- Create Date:    16:33:30 11/20/1819 
-- Design Name: 
-- Module Name:    receiver - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- IT WORKS !!!!
-- Dependencies: 
--
-- Revision: 
-- Revision 12.3.4.568
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


-- Définition des bits et bus d'entrées/sorties
entity receiver is
    Port ( RBYTEP : out  STD_LOGIC;
           RCLEANP : out  STD_LOGIC;
           RCVNGP : out  STD_LOGIC;
           RDATAO : out  STD_LOGIC_VECTOR (7 downto 0);
           RDATAI : in  STD_LOGIC_VECTOR (7 downto 0);
           RDONEP : out  STD_LOGIC;
           RENABP : in  STD_LOGIC;
           RSMATIP : out  STD_LOGIC;
           RSTARTP : out  STD_LOGIC;
           CLK : in  STD_LOGIC;
           RSTN : in  STD_LOGIC;
			  NOADDRI : in STD_LOGIC_VECTOR (47 downto 0)
			  );
end receiver;




architecture Behavioral of receiver is

--Nombre d'octets d'une adresse (ici 6 octets) 
constant ADDR_length : integer := 6;

--Sous-type qui joue le rôle de compteur de bytes d'une adresse destinataire/source
Subtype addr_counter is INTEGER range 0 to ADDR_length-1;

--Nombre total de trames intermédiaires
constant frame_step_nb : integer := 4;

--Sous-type qui joue le rôle de compteur de trames intermédiaires 
Subtype frame_step_counter is INTEGER range 0 to frame_step_nb-1;

--Définition du Start Frame Delimitor
constant SFD : STD_LOGIC_VECTOR(7 downto 0) := "10101011"; --"AB"

--Définition du End Frame Delimitor
constant EFD : STD_LOGIC_VECTOR(7 downto 0) := "10101001"; --"A9"

--Compteur de fronts montants de l'horloge
signal clk_counter : STD_LOGIC_VECTOR(2 downto 0);

--Compteur de trames intermédiaires
signal current_frame_step : frame_step_counter;

--Compteur de bytes d'une adresse
signal current_addr_byte : addr_counter;


begin

	process

	begin

		wait until CLK'EVENT and CLK='1';
		
		--Initialisation à 0 des bits générant des impulsions (pulses)
		RBYTEP <= '0';		--Nous avons choisi de l'activer lors de l'envoi des octets de l'adresse source et des octets de data
		RCLEANP <= '0';
		RDONEP <= '0';
		RSMATIP <= '0';
		RSTARTP <= '0';
		
		-- Initialisation à 0 (ou reset) des signaux steps et des signaux compteurs
		if RSTN = '0' or RENABP = '0' then
			RDATAO <= "00000000"; 
			RCVNGP <= '0';
			current_addr_byte <= 0;
			current_frame_step <=0;
			clk_counter <= "000";
			
		elsif RENABP ='1' then
		
			if current_frame_step=0 and (RDATAI = SFD) then -- On check la validité du SFD
			
				current_frame_step <= current_frame_step +1;
				RSTARTP <= '1';
				RCVNGP <= '1';
			
			end if;
			
		-- Traitement des adresses et données après récupération du SFD
			if current_frame_step > 0 then
				
					clk_counter<=clk_counter+'1';		-- compteur de fronts montants
					
					if(clk_counter="111") then			--attendre 8 tops d'horloges
						


		-- Reception de l'adresse de destination : (6 octets) --
						if (current_frame_step = 1) then
						
							current_addr_byte<=current_addr_byte+1;
							
							if (current_addr_byte<ADDR_length) then
--								
								if ( NOADDRI((47-current_addr_byte*8) downto (40-current_addr_byte*8)) /= RDATAI) then -- si adresse invalide
									RCLEANP <='1'; 
									current_frame_step<=0;
									current_addr_byte<=0;
									clk_counter <= "000";
									RCVNGP <= '0';
								end if;
							else		
									current_addr_byte <= 0;
									current_frame_step <= current_frame_step +1;
									RDATAO<=RDATAI;
									RBYTEP <= '1';
								-- On vérifie que l'adresse de destination est complétement valide
									RSMATIP <='1';
							end if;	
					
							
		-- Reception de l'adresse source : (6 octets) -- 
						elsif(current_frame_step = 2) then
							RBYTEP <= '1';
							current_addr_byte<=current_addr_byte+1;
							
							if (current_addr_byte<ADDR_length) then
								RDATAO<=RDATAI; --envoi octet par octet
							else
								current_addr_byte <= 0;
								current_frame_step <= current_frame_step +1;
								RDATAO<=RDATAI;
							end if;
						
		-- Reception de length, Data et EFD --
						elsif(current_frame_step = 3) then
						
							if(RDATAI=EFD)then
								RDONEP<='1';
								current_frame_step<=0;
								current_addr_byte<=0;
								RCVNGP <= '0';
								RDATAO <= "00000000"; 
							else
							RBYTEP <= '1';
								RDATAO<=RDATAI; --envoi octet par octet des donnees et du champ length à la couche supérieure
							end if;
						end if;
											
						clk_counter <= "000";
					end if;
			end if;
		end if;

	end process;
end Behavioral;

