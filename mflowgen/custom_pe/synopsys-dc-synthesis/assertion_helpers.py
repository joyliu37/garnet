#=========================================================================
# assertion_helpers.py
#=========================================================================
# Helper functions for assertions
#
# Author : Christopher Torng
# Date   : March 14, 2020
#

from glob import glob

import re

# percent_clock_gated
#
# Reads the clock-gating report and returns a float representing the
# percentage of registers that are clock gated.
#

def percent_clock_gated():

  # Read the clock-gating report

  with open( glob('reports/*clock_gating.rpt')[0] ) as fd:
    lines = fd.readlines()

  # Get the line with the clock-gating percentage, which looks like this:
  #
  #     |    Number of Gated registers          |    32 (94.12%)   |
  #

  gate_line = [ l for l in lines if 'Number of Gated registers' in l ][0]

  # Extract the percentage between parentheses

  percentage = float( re.search( r'\((.*?)%\)', gate_line ).group(1) )/100

  return percentage



