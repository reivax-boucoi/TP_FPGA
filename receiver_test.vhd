--------------------------------------------------------------------------------
-- Company: INSA
-- Engineer: Bourlot Xavier - Zennaro Thomas
--
-- Create Date:   17:09:52 11/20/2019
-- Design Name:   
-- Module Name:   /home/bourlot/FPGA/TP/BE/receiver_test.vhd
-- Project Name:  BE
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: receiver
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
USE ieee.numeric_std.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;

 
ENTITY receiver_test IS
END receiver_test;
 
ARCHITECTURE behavior OF receiver_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT receiver
    PORT(
         RBYTEP : OUT  std_logic;
         RCLEANP : OUT  std_logic;
         RCVNGP : OUT  std_logic;
         RDATAO : OUT  std_logic_vector(7 downto 0);
         RDATAI : IN  std_logic_vector(7 downto 0);
         RDONEP : OUT  std_logic;
         RENABP : IN  std_logic;
         RSMATIP : OUT  std_logic;
         RSTARTP : OUT  std_logic;
         CLK : IN  std_logic;
         RSTN : IN  std_logic;
         NOADDRI : IN  std_logic_vector(47 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal RDATAI : std_logic_vector(7 downto 0) := (others => '0');
   signal RENABP : std_logic := '0';
   signal CLK : std_logic := '0';
   signal RSTN : std_logic := '0';
   signal NOADDRI : std_logic_vector(47 downto 0) := (others => '0');

 	--Outputs
   signal RBYTEP : std_logic;
   signal RCLEANP : std_logic;
   signal RCVNGP : std_logic;
   signal RDATAO : std_logic_vector(7 downto 0);
   signal RDONEP : std_logic;
   signal RSMATIP : std_logic;
   signal RSTARTP : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: receiver PORT MAP (
          RBYTEP => RBYTEP,
          RCLEANP => RCLEANP,
          RCVNGP => RCVNGP,
          RDATAO => RDATAO,
          RDATAI => RDATAI,
          RDONEP => RDONEP,
          RENABP => RENABP,
          RSMATIP => RSMATIP,
          RSTARTP => RSTARTP,
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
	
	-- CLK a 10ns donc faire tous les 80ns 	
		
		NOADDRI <= X"0123456789AB";
		RSTN <= '1', '0' after 20 ns, '1' after 40 ns, '0' after 5600 ns, '1' after 5620 ns;
		RENABP <= '0', '1' after 35 ns, '0' after 5000 ns, '1' after 5020 ns;
		
		------------------------- TEST 1 : envoi d'une adresse de destination erronée ---------------------------
		
		-- Fausse adresse (octet AC non conforme):
		RDATAI <= "00000000", "10101011" after 80 ns,  X"01" after 160 ns, X"23" after 240 ns, X"45" after 320 ns, X"AC" after 400 ns, 
		
		
		------------------------- TEST 2 : 1er envoi d'une trame complète ---------------------------
		-- SFD et Adresse de destination correcte:
		X"AB" after 480 ns, X"01" after 560 ns,X"23" after 640 ns,X"45" after 720 ns,X"67" after 800 ns,X"89" after 880 ns,X"AB" after 960 ns, 
		
		--Adresse source:
		X"98" after 1040 ns,X"76" after 1120ns,X"54" after 1200 ns,X"32" after 1280 ns,X"10" after 1360 ns,X"FE" after 1440 ns,
		
		-- Envoi de données  avec le EFD:
		X"CA" after 1520 ns,X"FE" after 1600 ns,X"BE" after 1680 ns,X"DF" after 1760 ns,X"BA" after 1840 ns,X"CC" after 1920 ns,"10101001" after 2000 ns,

		
		------------------------- TEST 3 : 2eme envoi consécutif d'une trame complète avec EFD dans l'adresse source---------------------------
		-- SFD et Adresse correcte:
		X"AB" after 3080 ns, X"01" after 3160 ns,X"23" after 3240 ns,X"45" after 3320 ns,X"67" after 3400 ns,X"89" after 3480 ns,X"AB" after 3560 ns, 
		
		--Adresse source (contient un EFD):
		X"01" after 3640 ns,X"11" after 3720 ns,"10101001" after 3800 ns,X"33" after 3880 ns,X"44" after 3960 ns,X"55" after 4040 ns,
		
		-- Envoi de données:
		X"FF" after 4120 ns,X"EE" after 4200 ns,X"DD" after 4280 ns, X"CC" after 4360 ns,X"BB" after 4440 ns,X"AA" after 4520 ns,"10101001" after 4600 ns,
		
		------------------------- TEST 4 : RENAPB passe à 0 après 5000 ns ---------------------------
		-- Adresse correcte:
		X"AB" after 4680 ns, X"01" after 4760 ns,X"23" after 4840 ns,X"45" after 4920 ns,X"67" after 5000 ns,X"89" after 5080 ns,
		
		X"00" after 5240 ns,
		
		------------------------- TEST 5 : RSTN passe à 0 après 5600 ns ---------------------------
		-- Adresse correcte:
		X"AB" after 5300 ns, X"01" after 5380 ns,X"23" after 5460 ns,X"45" after 5540 ns,X"67" after 5620 ns,X"89" after 5700 ns;
		
		
		
      wait;
   end process;

END;
