--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:40:21 12/11/2019
-- Design Name:   
-- Module Name:   /home/zennaro/Documents/BE_VHDL/transmitter_test.vhd
-- Project Name:  BE
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: transmitter
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY transmitter_test IS
END transmitter_test;
 
ARCHITECTURE behavior OF transmitter_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT transmitter
    PORT(
         TABORTP : IN  std_logic;
         TAVAILP : IN  std_logic;
         TDATAI : IN  std_logic_vector(7 downto 0);
         TDATAO : OUT  std_logic_vector(7 downto 0);
         TDONEP : OUT  std_logic;
         TFINISHP : IN  std_logic;
         TLASTP : IN  std_logic;
         TREADP : OUT  std_logic;
         TSTARTP : OUT  std_logic;
         TRNSMTP : OUT  std_logic;
         CLK : IN  std_logic;
         RSTN : IN  std_logic;
         NOADDRI : IN  std_logic_vector(47 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal TABORTP : std_logic := '0';
   signal TAVAILP : std_logic := '0';
   signal TDATAI : std_logic_vector(7 downto 0) := (others => '0');
   signal TFINISHP : std_logic := '0';
   signal TLASTP : std_logic := '0';
   signal CLK : std_logic := '0';
   signal RSTN : std_logic := '0';
   signal NOADDRI : std_logic_vector(47 downto 0) := (others => '0');

 	--Outputs
   signal TDATAO : std_logic_vector(7 downto 0);
   signal TDONEP : std_logic;
   signal TREADP : std_logic;
   signal TSTARTP : std_logic;
   signal TRNSMTP : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: transmitter PORT MAP (
          TABORTP => TABORTP,
          TAVAILP => TAVAILP,
          TDATAI => TDATAI,
          TDATAO => TDATAO,
          TDONEP => TDONEP,
          TFINISHP => TFINISHP,
          TLASTP => TLASTP,
          TREADP => TREADP,
          TSTARTP => TSTARTP,
          TRNSMTP => TRNSMTP,
          CLK => CLK,
          RSTN => RSTN,
          NOADDRI => NOADDRI
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
	
	-- Action toutes les 80 ns
	
	-- Valeurs des sorties qui changent régulièrement en fonction de chaque test
	RSTN <= '1', '0' after 20 ns, '1' after 40 ns;
	TABORTP <='0', '1' after 2000 ns, '0' after 2010 ns;
	TAVAILP <='0','1' after 80 ns, '0' after 90 ns, '1' after 1760 ns, '0' after 1770 ns, '1' after 2080 ns, '0' after 2090 ns, '1' after 3420 ns, '0' after 3430 ns;
	
	NOADDRI <= X"0123456789CA";
	
	TLASTP<='0', '1' after 1360 ns, '0' after 1370 ns;
	
	TFINISHP<='0', '1' after 1520 ns, '0' after 1530 ns, '1' after 4400 ns, '0' after 4410 ns;
	
	---------------- Test 1 : envoi complet et valide (adresse destinataire et data) -------------------
	
	--attente pour envoi du SFD (fait en interne)
	
	--envoi de l'adresse destinataire
	TDATAI <= X"FF",X"00" after 160 ns, X"11" after 240 ns, X"22" after 320 ns, X"33" after 400 ns, X"44" after 480 ns, X"55" after 560 ns,
	
	--attente pour envoi de l'adresse source (fait en interne)
	
	--envoi de data
	X"AA" after 1120 ns,X"BB" after 1200 ns,X"CC" after 1280 ns,X"DD" after 1360 ns,
	
	
	---------------- Test 2 : envoi stoppé par la levée de TABORTP (adresse destinataire et data) -------------------
	
	--attente pour envoi du SFD (fait en interne)
	
	--envoi de l'adresse destinataire
	 --X"FF" after 1600 ns ,X"00" after 1680 ns, X"11" after 1760 ns,
	 X"22" after 1840 ns, X"33" after 1920 ns, X"44" after 2000 ns, X"55" after 2080 ns,
	 --suite à TABORTP du padding est généré
	 
	 --on tente de recommencer une trame avant la fin du padding :
	 X"22" after 2160 ns,X"33" after 2240 ns,
	 --cette tentative échoue car TAVAILP ne peut être pris en compte lors du padding
	 
	 ---------------- Test 3 : envoi complet avec TFINISHP qui se lève trop tôt(adresse destinataire et data) -------------------
	
	--attente pour envoi du SFD (fait en interne)
	
	--envoi de l'adresse destinataire
	 --X"FF" after 1600 ns ,X"00" after 1680 ns, X"11" after 1760 ns,
	 X"22" after 3500 ns, X"33" after 3580 ns, X"44" after 3660 ns, X"55" after 3740 ns,X"66" after 3820 ns,X"77" after 3900 ns,
	 
	 
	 --attente pour envoi de l'adresse source (fait en interne)
	
	--envoi de data
	 X"CC" after 4380 ns,X"DD" after 4460 ns, X"EE" after 4540 ns;
	
      wait;
		
   end process;

END;
