# pengo-papilioplus-fpga

Readme from https://code.google.com/archive/p/pengo-papilioplus-fpga/:

-----------------------------------------------------------------------

FPGA implementation of Pengo arcade game on Pacman hardware

Since the Pengo hardware is very similar to the Pacman hardware, I based this project on MikeJ's Pacman implementation from FPGAArcade and added the necessary changes to make Pengo work.

Specifically, additional program and graphics ROMs were added to fit the Pengo game, a ROM descrambler was implemented (based on MAME source code) and all the required address remapping for the game components.

Simply by changing ROM files and flipping the state of the PACMAN constant in the top level module, this implementation will run either Pengo or all the Pacman based games such as Pacman, Gorkans, Liz Wiz, Paint Roller, etc.

Added memmory mapper and descramble logic for Ms Pacman so this game will also play now in this implementation.

-----------------------------------------------------------------------


## Creating a clock source in Vivado Clocking Wizard 5/11/2024 (Glenn Neidermeier)

The Vivado Clocking Wizard is used to generate a reference clock as close as possible to the VGA pixel frequency 25.175 Mhz.
The Clocking Wizard will allow the MMCM instance to set for an output frequency of 25.17301 Mhz from the Basys3 100 Mhz oscillator.

- Create standalone project in Vivado, add the Basys 3 constraints and board file definition.

- Search for clock wiz in the IP Catalog.

- Under Clocking Options make sure Input Frequency is 100 Mhz.

- In Output Clock Output Frequency, attempting to set output clock 25.175 will get a warning to set the requested clock frquency to the nearest obtained frequency of 25.17301 Mhz


Import the files for synthesis:
```
project_1.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_clk_wiz.v
project_1.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.v
```
(Copy sources into project)

_COMPONENT Declaration_ and _INSTANTIATION Template_ for the MMCM instance are found in `project_1.gen/sources_1/ip/clk_wiz_0/clk_wiz_0.vho`

The component instantiation template is used in _proj/xilinx/basys3/pengopac.srcs/sources_1/new/pacman_clocks_xilinx_wiz.vhd_ to wire the new clock into the system. 

