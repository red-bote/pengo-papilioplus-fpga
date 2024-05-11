----------------------------------------------------------------------------------
-- Company: 
--   Red-Bote 
-- Engineer: 
--   Red~Bote
-- Create Date: 05/08/2024 05:01:20 PM
-- Design Name: 
-- Module Name: rtl_top - RTL
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--   top-level for PACMAN
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rtl_top is
    Port ( clk : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           JA : in STD_LOGIC_VECTOR (4 downto 0);
           btnC : in STD_LOGIC;
           btnU : in STD_LOGIC;
           btnL : in STD_LOGIC;
           btnR : in STD_LOGIC;
           btnD : in STD_LOGIC;
           vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue : out STD_LOGIC_VECTOR (3 downto 0);
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC;
           O_PMODAMP2_AIN : out STD_LOGIC;
           O_PMODAMP2_GAIN : out STD_LOGIC;
           O_PMODAMP2_SHUTD : out STD_LOGIC;

           PS2DAT1 : inout STD_LOGIC;
           PS2CLK1 : inout STD_LOGIC;

           led : out STD_LOGIC_VECTOR (15 downto 0));
end rtl_top;

architecture RTL of rtl_top is
    signal buttons : std_logic_vector(3 downto 0);
    signal reset : std_logic;
begin
    --
    -- TODO: document switches
    --
    --  I_SW(0) 1P Start
    --  I_SW(1) Coin
    --  I_SW(2) Coin
    --  I_SW(3) 2P Start
    --
    -- active-low shutdown pin
    O_PMODAMP2_SHUTD <= sw(14);
    -- gain pin is driven high there is a 6 dB gain, low is a 12 dB gain 
    O_PMODAMP2_GAIN <= sw(15);

    buttons <= btnL & btnR & btnU & btnD;
    reset <= btnC;

    u_top : entity work.papilio_top 
	port map (
        O_VIDEO_R => vgaRed,
        O_VIDEO_G => vgaGreen,
        O_VIDEO_B => vgaBlue,
        O_HSYNC => Hsync,
        O_VSYNC => Vsync,
		--
        O_AUDIO_L => O_PMODAMP2_AIN,
        O_AUDIO_R => open,
        --
        PS2DAT1 => PS2DAT1,
        PS2CLK1 => PS2CLK1,

--        I_JOYSTICK_A => JA, -- sw(8 downto 4), -- sw(6) Right
--        I_JOYSTICK_B => sw(13 downto 9), -- sw[13] low causes test mode
        --
--        I_SW => sw(3 downto 0),
--        O_LED => led(2 downto 0),
        --
        I_RESET => reset,
        CLK_IN => clk
	);

end RTL;
