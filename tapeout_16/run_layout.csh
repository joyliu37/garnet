#! /bin/tcsh
# Takes in top level design name as argument and
# # runs basic synthesis script
set echo

setenv DESIGN $1
setenv PWR_AWARE $2

cd synth/$1; pwd
if ("${1}" =~ Tile* ) then
    # innovus -no_gui -replay ../../scripts/layout_Tile.tcl || exit 13

    # Oops github script does not seem to work, use alex script instead
    # set s=../../scripts/layout_Tile.tcl
    set s=/sim/ajcars/garnet/tapeout_16/scripts/layout_Tile.tcl
    echo "source -verbose $s" > /tmp/tmp$$
    echo "exit" >> /tmp/tmp$$
    innovus -no_gui -abort_on_error -replay /tmp/tmp$$ || exit 13
else
    # innovus -replay ../../scripts/layout_${1}.tcl || exit 13
    set s=../../scripts/layout_${1}.tcl
    echo "source -verbose $s" > /tmp/tmp$$
    echo "exit" >> /tmp/tmp$$
    innovus -no_gui --abort_on_error replay /tmp/tmp$$ || exit 13
endif
cd ../..
