#!/bin/sh
# Glenn Neidermeier 2-May-2024
# Generate ROMS for Ms. Pac-Man (bootleg)
# Runs on pacman VHDL driver using LIZWIZ hardware configuration (enables upper ROM banks at $8000) 

# ROM info from MAME (by David Widel)
#  It turns out the bootleg is the decrypted version with the checksum check
#  removed and interrupt mode changed to 1.
#
#ROM_START( mspacmab )
#	ROM_REGION( 0x10000, REGION_CPU1, 0 )	/* 64k for code */
#	ROM_LOAD( "boot1",        0x0000, 0x1000, CRC(d16b31b7) SHA1(bc2247ec946b639dd1f00bfc603fa157d0baaa97) )
#	ROM_LOAD( "boot2",        0x1000, 0x1000, CRC(0d32de5e) SHA1(13ea0c343de072508908be885e6a2a217bbb3047) )
#	ROM_LOAD( "boot3",        0x2000, 0x1000, CRC(1821ee0b) SHA1(5ea4d907dbb2690698db72c4e0b5be4d3e9a7786) )
#	ROM_LOAD( "boot4",        0x3000, 0x1000, CRC(165a9dd8) SHA1(3022a408118fa7420060e32a760aeef15b8a96cf) )
#	ROM_LOAD( "boot5",        0x8000, 0x1000, CRC(8c3e6de6) SHA1(fed6e9a2b210b07e7189a18574f6b8c4ec5bb49b) )
#	ROM_LOAD( "boot6",        0x9000, 0x1000, CRC(368cb165) SHA1(387010a0c76319a1eab61b54c9bcb5c66c4b67a1) )
#
#	ROM_REGION( 0x1000, REGION_GFX1, ROMREGION_DISPOSE )
#	ROM_LOAD( "5e",           0x0000, 0x1000, CRC(5c281d01) SHA1(5e8b472b615f12efca3fe792410c23619f067845) )
#
#	ROM_REGION( 0x1000, REGION_GFX2, ROMREGION_DISPOSE )
#	ROM_LOAD( "5f",           0x0000, 0x1000, CRC(615af909) SHA1(fd6a1dde780b39aea76bf1c4befa5882573c2ef4) )
#
#	ROM_REGION( 0x0120, REGION_PROMS, 0 )
#	ROM_LOAD( "82s123.7f",    0x0000, 0x0020, CRC(2fc650bd) SHA1(8d0268dee78e47c712202b0ec4f1f51109b1f2a5) )
#	ROM_LOAD( "82s126.4a",    0x0020, 0x0100, CRC(3eb3a8e4) SHA1(19097b5f60d1030f8b82d9f1d3a241f93e5c75d6) )
#
#	ROM_REGION( 0x0200, REGION_SOUND1, 0 )	/* sound PROMs */
#	ROM_LOAD( "82s126.1m",    0x0000, 0x0100, CRC(a9cc86bf) SHA1(bbcec0570aeceb582ff8238a4bc8546a23430081) )
#	ROM_LOAD( "82s126.3m",    0x0100, 0x0100, CRC(77245b66) SHA1(0c4d0bee858b97632411c440bea6948a74759746) )	/* timing - not used */
#ROM_END

#
#set rom_path_src=..\roms\lizwiz
#set rom_path=..\build
#set romgen_path=..\romgen_source
#
#REM concatenate consecutive ROM regions
#copy /b/y %rom_path_src%\wiza + %rom_path_src%\wizb %rom_path%\wiz.bin > NUL
#copy /b/y %rom_path_src%\5e.cpu + %rom_path_src%\5f.cpu %rom_path%\gfx1.bin > NUL
#copy /b/y %rom_path_src%\6e.cpu + %rom_path_src%\6f.cpu + %rom_path_src%\6h.cpu + %rom_path_src%\6j.cpu %rom_path%\main.bin > NUL
#
#REM generate RTL code for small PROMS
#%romgen_path%\romgen %rom_path_src%\82s126.1m     PROM1_DST  8 a r e > %rom_path%\prom1_dst.vhd
#%romgen_path%\romgen %rom_path_src%\82s126.3m     PROM3_DST  7 a     > %rom_path%\prom3_dst.vhd
#%romgen_path%\romgen %rom_path_src%\4a.cpu        PROM4_DST 10 a     > %rom_path%\prom4_dst.vhd
#%romgen_path%\romgen %rom_path_src%\7f.cpu        PROM7_DST  5 a r e > %rom_path%\prom7_dst.vhd
#
#REM generate RAMB structures for larger ROMS
#%romgen_path%\romgen %rom_path%\gfx1.bin          GFX1      14 l r e > %rom_path%\gfx1.vhd
#%romgen_path%\romgen %rom_path%\main.bin          ROM_PGM_0 14 l r e > %rom_path%\rom0.vhd
#
#REM this ROM area is used and required for synthesis
#%romgen_path%\romgen %rom_path%\wiz.bin           ROM_PGM_1 14 l r e > %rom_path%\rom1.vhd
#
#echo done
#pause


rom_path_src=../roms/mspacmab
rom_path=../build
rom_path=../proj/xilinx/basys3/pengopac.srcs/sources_1/imports/build/
romgen_path=../romgen_source

#REM concatenate consecutive ROM regions
cat $rom_path_src/boot5 $rom_path_src/boot6 > $rom_path/wiz.bin
cat $rom_path_src/5e $rom_path_src/5f       > $rom_path/gfx1.bin
cat $rom_path_src/boot1 $rom_path_src/boot2 $rom_path_src/boot3 $rom_path_src/boot4 > $rom_path/main.bin

#REM generate RTL code for small PROMS (note: original .bat omitted 3m, does it matter?)
$romgen_path/romgen $rom_path_src/82s126.1m     PROM1_DST  8 a r e > $rom_path/prom1_dst.vhd
$romgen_path/romgen $rom_path_src/82s126.3m     PROM3_DST  7 a     > $rom_path/prom3_dst.vhd
$romgen_path/romgen $rom_path_src/82s126.4a     PROM4_DST 10 a     > $rom_path/prom4_dst.vhd
$romgen_path/romgen $rom_path_src/82s123.7f     PROM7_DST  5 a r e > $rom_path/prom7_dst.vhd

#REM generate RAMB structures for larger ROMS (note: original .bat used 13 bits for GFX1 address, does it matter?)
$romgen_path/romgen $rom_path/gfx1.bin          GFX1      14 l r e > $rom_path/gfx1.vhd
$romgen_path/romgen $rom_path/main.bin          ROM_PGM_0 14 l r e > $rom_path/rom0.vhd

#REM this is ROM area IS used AND required (note: original .bat used 13 address bits, does it matter?)
$romgen_path/romgen $rom_path/wiz.bin           ROM_PGM_1 14 l r e > $rom_path/rom1.vhd

echo done

