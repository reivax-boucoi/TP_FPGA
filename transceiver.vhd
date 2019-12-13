----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:27:36 11/27/2019 
-- Design Name: 
-- Module Name:    tranceiver - Behavioral 
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
library work;
use work.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity transceiver is
	

end transceiver;

architecture Behavioral of tranceiver is
component transmitter 
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
end component;

component receiver 
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
			  NOADDRI : in STD_LOGIC_VECTOR (47 downto 0));
end component;

for all: receiver use entity work.receiver(behavioral);
for all: transmitter use entity work.transmitter(behavioral);

begin


end Behavioral;

