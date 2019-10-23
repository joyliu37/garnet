#!/bin/bash

VERBOSE=false
if [ "$1" == "-v" ]; then VERBOSE=true;  shift; fi
if [ "$1" == "-q" ]; then VERBOSE=false; shift; fi

TILE=$1

########################################################################
echo "--- GET REQUIRED COLLATERAL FROM CACHE"

# Need mem_synth.txt and/or mem_cfg.txt in top-level dir
pwd; ls -l mem_cfg.txt mem_synth.txt >& /dev/null || echo 'no mems (yet)'
cp $CACHEDIR/mem_cfg.txt .
cp $CACHEDIR/mem_synth.txt .
pwd; ls -l mem_cfg.txt mem_synth.txt || echo 'oops where are the mems'

cd tapeout_16

# Symlink to pre-existing verilog files in the cache
ls -ld genesis_verif || echo "no gv (yet)"
ls -ld $CACHEDIR/genesis_verif \
  || echo "ERROR no cached gv, that's gonna be a problem"
test -d genesis_verif || ln -s $CACHEDIR/genesis_verif
ls -ld genesis_verif || echo "no gv (yet)"


########################################################################
echo "--- MODULE LOAD REQUIREMENTS"
echo ""
set +x; source test/module_loads.sh


########################################################################
echo "--- BLOCK-LEVEL SYNTHESIS - ${TILE}"
set -x
PWR_AWARE=1
nobuf='stdbuf -oL -eL'
if [ "$VERBOSE" == true ];
  then filter=($nobuf cat)                         # VERBOSE
  else filter=($nobuf ./test/run_synthesis.filter) # QUIET
fi
# pwd; ls -l genesis_verif

$nobuf ./run_synthesis.csh Tile_${TILE} ${PWR_AWARE} \
  | ${filter[*]} \
  || exit 13
pwd

# Check results and copy to cache dir
ls synth/Tile_${TILE}/results_syn/final_area.rpt
# /sim/buildkite-agent/builds/r7arm-aha-2/tapeout-aha/mem/tapeout_16
mkdir $CACHEDIR/synth || echo cachedir synth dir already exists maybe
cp -rp \
    synth/{append.csh,PE/,run_all.csh,Tile_MemCore/,Tile_PE/} \
    $CACHEDIR

set +x
echo "+++ SYNTHESIS SUMMARY"
echo ""
echo "Generated synth/Tile_${TILE} and copied it to cache dir"
echo "Includes results_syn/final_area.rpt"
date
ls -ld $CACHEDIR/
ls -ld $CACHEDIR/synth
ls -ld $CACHEDIR/synth/Tile_${TILE}/results_syn/final_area.rpt
echo ""

s=synth/Tile_${TILE}/genus.log
sed -n '/QoS Summary/,/Total Instances/p' $s