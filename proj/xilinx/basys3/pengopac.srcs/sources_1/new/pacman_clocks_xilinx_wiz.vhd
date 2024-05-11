----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/08/2024 05:23:16 PM
-- Design Name: 
-- Module Name: pacman_clocks_xilinx_wiz - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

--
-- A simulation model of Pacman hardware
-- Copyright (c) MikeJ - January 2006
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
-- The latest version of this file can be found at: www.fpgaarcade.com
--
-- Email pacman@fpgaarcade.com
--
-- Revision list
--
-- version 004 spartan3e release
-- version 001 Jan 2006 release - initial release of this module

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;

library UNISIM;
	use UNISIM.Vcomponents.all;

entity PACMAN_CLOCKS_WIZ is
	port (
		I_CLK_REF         : in    std_logic;
		I_RESET           : in    std_logic;
		--
		O_CLK_REF         : out   std_logic;
		--
		O_ENA_12          : out   std_logic;
		O_ENA_6           : out   std_logic;
		O_CLK             : out   std_logic;
		O_RESET           : out   std_logic
	);
end;

architecture RTL of PACMAN_CLOCKS_WIZ is
--	-- Input clock buffering / unused connectors
--	signal clkin1            : std_logic;
--	-- Output clock buffering
--	signal clkfb             : std_logic;
--	signal clk0              : std_logic;
--	signal clkfx             : std_logic;
--	signal locked_internal   : std_logic;
--	signal status_internal   : std_logic_vector(7 downto 0);

	signal clk               : std_logic;
--	signal reset             : std_logic;
	signal delay_count       : std_logic_vector(7 downto 0) := (others => '0');
	signal div_cnt           : std_logic_vector(1 downto 0);

	-- The original uses a 6.144 MHz clock
	--
	-- Here we are taking in 32MHz clock, and using the CLKFX 32*(10/13) to get 24.615MHz
	-- We are then clock enabling the whole design at /4 and /2
	--
	-- This runs the game at 6.15 MHz which is 0.16% fast.
	--
	-- (The scan converter requires a x4 freq clock)


------------------------------------------------------------------------------
--  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
--   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
------------------------------------------------------------------------------
-- clk_out1__25.00000______0.000______50.0______175.402_____98.575
-- clk_out2__25.00000______0.000______50.0______175.402_____98.575
--
------------------------------------------------------------------------------
-- Input Clock   Freq (MHz)    Input Jitter (UI)
------------------------------------------------------------------------------
-- __primary_________100.000____________0.010


-- The following code must appear in the VHDL architecture header:
------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
component clk_wiz_0_clk_wiz
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;

begin

--	O_CLK_REF <= clk0;
--	O_CLK     <= clk;

--	-- Input buffering
--	--------------------------------------
--	clkin1_buf : IBUFG
--	port map (I => I_CLK_REF, O => clkin1);

--	-- Output buffering
--	-------------------------------------
--	clkf_buf : BUFG
--	port map (I => clk0, O => clkfb);

--	clkout1_buf : BUFG
--	port map (I => clkfx, O => clk);
	 
--	dcm_sp_inst: DCM_SP
--	generic map(
--		CLKFX_DIVIDE          => 13,
--		CLKFX_MULTIPLY        => 10,
--		CLKIN_PERIOD          => 31.25
--	)
--	port map (
--		-- Input clock
--		CLKIN                 => clkin1,
--		CLKFB                 => clkfb,
--		-- Output clocks
--		CLK0                  => clk0,
--		CLKFX                 => clkfx,
--		-- Other control and status signals
--		LOCKED                => locked_internal,
--		STATUS                => status_internal,
--		RST                   => I_RESET
--	);

  p_delay : process(I_RESET, clk)
  begin
    if (I_RESET = '1') then
      delay_count <= x"00"; -- longer delay for cpu
      O_RESET <= '1';
    elsif rising_edge(clk) then
      if (delay_count(7 downto 0) = (x"FF")) then
        delay_count <= (x"FF");
        O_RESET <= '0';
      else
        delay_count <= delay_count + "1";
        O_RESET <= '1';
      end if;
    end if;
  end process;

  p_clk_div : process(I_RESET, clk)
  begin
    if (I_RESET = '1') then
      div_cnt <= (others => '0');
    elsif rising_edge(clk) then
      div_cnt <= div_cnt + "1";
    end if;
  end process;

  p_assign_ena : process(div_cnt)
  begin
    O_ENA_12 <= div_cnt(0);
    O_ENA_6  <= div_cnt(0) and not div_cnt(1);
  end process;



-- COMP_TAG_END ------ End COMPONENT Declaration ------------
-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.
------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
--your_instance_name : clk_wiz_0
--   port map ( 
--  -- Clock out ports  
--   clk_out1 => clk_out1,
--   clk_out2 => clk_out2,
--  -- Status and control signals                
--   reset => reset,
--   locked => locked,
--   -- Clock in ports
--   clk_in1 => clk_in1
-- );
-- INST_TAG_END ------ End INSTANTIATION Template ------------
  u_clk_wiz_0 : clk_wiz_0_clk_wiz
  port map ( 
    -- Clock out ports
    clk_out1 => clk, -- clk_out1
    clk_out2 => open, -- clk_out2,
    -- Status and control signals
    reset => I_RESET,
    locked => open, -- locked,
    -- Clock in ports
    clk_in1 => I_CLK_REF -- clk_in1
 );

  O_CLK     <= clk;

end RTL;
