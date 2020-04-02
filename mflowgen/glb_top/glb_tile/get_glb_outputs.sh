#!/bin/bash
mflowgen run --design $GARNET_HOME/mflowgen/glb_tile/
make synopsys-ptpx-genlibdb
make mentor-calibre-gdsmerge
make mentor-calibre-lvs
mkdir -p outputs
cp -L *synopsys-ptpx-genlibdb/outputs/design.lib outputs/glb_tile_tt.lib
cp -L *synopsys-ptpx-genlibdb/outputs/design.db outputs/glb_tile.db
cp -L *cadence-innovus-signoff/outputs/design.lef outputs/glb_tile.lef
cp -L *cadence-innovus-signoff/outputs/design.lvs.v outputs/glb_tile.lvs.v
cp -L *mentor-calibre-gdsmerge/outputs/design_merged.gds outputs/glb_tile.gds

