import tempfile
from bit_vector import BitVector
from io_core.io1bit_magma import IO1bit
from fault.tester import Tester
import pytest


def test_regression():
    io1bit = IO1bit()
    io1bit_circuit = io1bit.circuit()
    tester = Tester(io1bit_circuit)

    for _glb2io in [BitVector(x, 1) for x in range(2**1)]:
        for _f2io in [BitVector(x, 1) for x in range(2**1)]:
            tester.poke(io1bit_circuit.glb2io, _glb2io)
            tester.poke(io1bit_circuit.f2io_1, _f2io)
            tester.eval()
            tester.expect(io1bit_circuit.io2glb, _f2io)
            tester.expect(io1bit_circuit.io2f_1, _glb2io)

    with tempfile.TemporaryDirectory() as tempdir:
        tester.compile_and_run(target="verilator",
                               magma_output="coreir-verilog",
                               directory=tempdir,
                               flags=["-Wno-fatal"])