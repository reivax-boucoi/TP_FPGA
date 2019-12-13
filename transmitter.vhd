----------------------------------------------------------------------------------
-- Company: INSA
-- Engineer: Bourlot Xavier - Zennaro Thomas
-- 
-- Create Date:    24:25:39 11/27/-3019 
-- Design Name: 
-- Module Name:    transmitter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;



-- Définition des bits et bus d'entrées/sorties
entity transmitter is
    Port ( TABORTP : in  STD_LOGIC;
           TAVAILP : in  STD_LOGIC;
           TDATAI : in  STD_LOGIC_VECTOR (7 downto 0);
           TDATAO : out  STD_LOGIC_VECTOR (7 downto 0);
           TDONEP : out  STD_LOGIC;
           TFINISHP : in  STD_LOGIC;
           TLASTP : in  STD_LOGIC;
           TREADP : out  STD_LOGIC;
           TSTARTP : out  STD_LOGIC;
           TRNSMTP : out  STD_LOGIC;
			  CLK : in  STD_LOGIC;
           RSTN : in  STD_LOGIC;
			  NOADDRI : in STD_LOGIC_VECTOR (47 downto 0));
end transmitter;




architecture Behavioral of transmitter is


--Nombre d'octets d'une adresse (ici 6 octets) 
constant ADDR_length : integer := 6;

--Sous-type qui joue le rôle de compteur de bytes d'une adresse destinataire/source
Subtype addr_counter is INTEGER range 0 to ADDR_length-1;

--Nombre de bits de padding (ici 32 bits) 
constant PAD_length : integer := 32;

--Sous-type qui joue le rôle de compteur de bits de padding
Subtype pad_counter is INTEGER range 0 to PAD_length;

--Nombre total de trames intermédiaires
constant frame_step_nb : integer := 5;

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

--Compteur padding
signal current_pad_count : pad_counter;


begin

process


begin

	wait until CLK'EVENT and CLK='1';
		
		--Initialisation à 0 pour avoir des pulses
		TDONEP <= '0';
		TREADP <= '0';
		TSTARTP <='0';
		
		-- Initialisation à 0 des steps et des compteurs
		if RSTN = '0' or TFINISHP = '1' then
			TDATAO <= "00000000"; 
			TRNSMTP <= '0';
			current_addr_byte <= 0;
			current_frame_step <=0;
			clk_counter <= "000";
			current_pad_count<=0;
		
		
		elsif TABORTP ='0' and  TFINISHP = '0' and current_pad_count = 0 then
			clk_counter<=clk_counter+1;
			
			if(current_frame_step=0 and TAVAILP = '1')then						--On émet le SFD
					TDATAO <= SFD ;
					TSTARTP<='1';
					TRNSMTP<='1';
					clk_counter<="000";
					current_frame_step<=current_frame_step+1;
					current_pad_count<=0;
			end if;
			
			if(clk_counter="111")then							--On attend 8 tops d'horloge pour passer à la sous-trame suivante
			
				if((current_frame_step>0 )and (current_frame_step<3))then -- pulse treadp
					TREADP<='1';
				end if;
				
				if(current_frame_step=1)then -- on retransmet l'addresse destinataire
				
					current_addr_byte<=current_addr_byte+1;
								
					if (current_addr_byte<ADDR_length) then
						TDATAO<=TDATAI;
					else
						current_frame_step<=current_frame_step+1;
						current_addr_byte<=0;
						TDATAO<=NOADDRI(47 downto 40);
					end if;			
					
				elsif(current_frame_step=2)then -- on emet notre adresse
				
								
					if (current_addr_byte<ADDR_length-1) then
						TDATAO<=NOADDRI(39-(current_addr_byte)*8 downto 32-(current_addr_byte*8));
						current_addr_byte<=current_addr_byte+1;
					else
						current_frame_step<=current_frame_step+1;
						current_addr_byte<=0;
						TDATAO<=TDATAI;
					end if;
							
				elsif(current_frame_step=3)then -- on retransmet les donnees
						if(TLASTP='1')then
							current_frame_step<=current_frame_step+1;
							current_addr_byte<=0;
						end if;
						TDATAO<=TDATAI; --envoi octet par octet
						
						
				elsif(current_frame_step=4)then -- EFD
					
					current_addr_byte<=current_addr_byte+1;
					TDATAO<=EFD;
					TDONEP<='1';
					if(current_addr_byte=2)then
						TDATAO<="00000000";
						current_addr_byte<=0;
						current_frame_step<=0;
						TRNSMTP<='0';
					end if;
				end if;		
			end if;
		elsif TABORTP = '1' then -- commencer l'envoi de padding
			current_pad_count<=1;
			TDATAO <= "00000000"; 
			TRNSMTP <= '0';
			current_addr_byte <= 0;
			current_frame_step <=0;
			clk_counter <= "000";
		end if;
		
		if current_pad_count >0 and current_pad_count<PAD_length then -- envoi de padding
			TDATAO<="00000000";
			current_pad_count<=current_pad_count+1;
		elsif current_pad_count=PAD_length then -- arrêt de l'envoi de padding et retour à la transmission
			current_pad_count<=0;
		end if;
		
end process;


end Behavioral;

