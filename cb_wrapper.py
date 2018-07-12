import sys
import magma as m
from genesis_wrapper import run_genesis


def define_cb(width,
              num_tracks,
              feedthrough_outputs,
              has_constant,
              default_value,
              filename="cb.vp"):
    parameters = {
        "width": width,
        "num_tracks": num_tracks,
        "feedthrough_outputs": feedthrough_outputs,
        "has_constant": has_constant,
        "default_value": default_value,
    }
    outfile = run_genesis("cb", filename, parameters)
    outfile = "genesis_verif/" + outfile
    cb_wrapper = m.DefineFromVerilogFile(outfile)
    return cb_wrapper
