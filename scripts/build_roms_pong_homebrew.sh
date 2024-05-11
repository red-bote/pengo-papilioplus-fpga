#!/bin/sh

# set PATHs
rom_path_src=../roms/pong_homebrew
rom_path=../build
romgen_path=../romgen_source

[ ! -d $rom_path ] && mkdir $rom_path

# REM concatenate consecutive ROM regions
cat $rom_path_src/pacman.5e $rom_path_src/pacman.5f > $rom_path/gfx1.bin
cat $rom_path_src/pacman.6e $rom_path_src/pacman.6f $rom_path_src/pacman.6h $rom_path_src/pacman.6j > $rom_path/main.bin

# REM generate RTL code for small PROMS
# block ram16 registered output clock enable
$romgen_path/romgen $rom_path_src/pacman.1m     PROM1_DST  8 l r e   > $rom_path/prom1_dst.vhd  # 82s126.1m

# 4A is 256 byte image, only 128 bytes used but still requires 8 address bits
#$romgen_path/romgen $rom_path_src/pacman.4a     PROM4_DST  10 l r e  > $rom_path/prom4_dst.vhd  # 82s126.4a
# Using " a  - rtl model rom array" because the clocked memory causes artifacting on pengo sprites
$romgen_path/romgen $rom_path_src/pacman.4a     PROM4_DST  10 a      > $rom_path/prom4_dst.vhd  # 82s126.4a

# 7f is 32 bytes image, only 16 bytes used
$romgen_path/romgen $rom_path_src/pacman.7f     PROM7_DST  5 l r e   > $rom_path/prom7_dst.vhd  # 82s123.7f

# dummy image for prom3
$romgen_path/romgen $rom_path_src/dummy.3m     PROM3_DST  7 a     > $rom_path/prom3_dst.vhd

# REM generate RAMB structures for larger ROMS
$romgen_path/romgen $rom_path/gfx1.bin          GFX1      14 l r e   > $rom_path/gfx1.vhd
$romgen_path/romgen $rom_path/main.bin          ROM_PGM_0 14 l r e   > $rom_path/rom0.vhd

# REM this is ROM area not used but required
$romgen_path/romgen $rom_path/gfx1.bin          ROM_PGM_1 14 l r e   > $rom_path/rom1.vhd

echo done

