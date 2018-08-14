from common.model import Model
from bit_vector import BitVector
from enum import Enum
import magma as m
import fault


class GC_reg_addr(Enum):
    TST_addr = 0
    stall_addr = 1
    clk_sel_addr = 2
    rw_delay_sel_addr = 3
    clk_switch_delay_sel_addr = 4


def gen_global_controller(config_data_width: int,
                          config_addr_width: int,
                          config_op_width: int):

    class GlobalController(Model()):
        def __init__(self):
            super().__init__()
            self.NUM_STALL_DOMAINS = 4
            self.reset()

        def reset(self):
            self.GC_regs = {GC_reg_addr.TST_addr:
                            [BitVector(0, config_data_width)],
                            GC_reg_addr.stall_addr:
                            [BitVector(0, self.NUM_STALL_DOMAINS)],
                            GC_reg_addr.clk_sel_addr:
                            [BitVector(0, 1)],
                            [GC_reg_addr.rw_delay_sel_addr]:
                            [BitVector(0, config_data_width)],
                            GC_reg_addr.clk_switch_delay_sel_addr:
                            [BitVector(0, 1)]}
            self.reset_out = [0]
            self.config_addr_out = [BitVector(0, config_addr_width)]
            self.config_data_out = [BitVector(0, config_data_width)]
            self.config_data_in = fault.UnknownValue
            self.read = [0]
            self.write = [0]
            self.config_data_to_jtag = [0]

        def config_read(self, addr):
            duration = BitVector.as_uint(self.GC_regs
                                         [GC_reg_addr.rw_delay_sel_addr])
            self.read = [1] * duration + [0]
            self.write = [0] * (duration + 1)
            self.config_addr_out = [BitVector(addr, config_addr_width)] \
                * (duration + 1)
            self.config_data_to_jtag = [self.config_data_to_jtag[-1]] \
                + [self.config_data_in] * duration

        def config_write(self, addr, data):
            duration = BitVector.as_uint(
                       self.GC_regs[GC_reg_addr.rw_delay_sel_addr])
            self.read = [0] * (duration + 1)
            self.write = [1] * duration + [0]
            self.config_addr_out = [BitVector(addr, config_addr_width)] \
                * (duration + 1)
            self.config_data_out = [BitVector(data, config_data_width)] \
                * (duration + 1)

        def read_GC_reg(self, addr):
            self.config_data_to_jtag = [BitVector(self.GC_regs[addr][-1],
                                                  config_data_width)]

        def write_GC_reg(self, addr, data):
            reg_width = self.GC_regs[addr].num_bits
            self.GC_regs[addr] = [BitVector(data, reg_width)]

        def global_reset(self, data):
            if (data > 0):
                self.reset_out = [1] * BitVector.as_uint(data) + [0]
            else:
                self.reset_out = [1] * 20 + [0]

        def advance_clk(self, addr: BitVector, data: BitVector):
            save_stall_reg = self.GC_regs[GC_reg_addr.stall_addr][-1]
            temp_stall_reg = BitVector(0, self.NUM_STALL_DOMAINS)
            for i in range(self.NUM_STALL_DOMAINS):
                if (addr[i] == 1 and save_stall_reg[i] == 1):
                    temp_stall_reg[i] = 0
                else:
                    temp_stall_reg[i] = save_stall_reg[i]
            self.GC_regs[GC_reg_addr.stall_addr] = [temp_stall_reg] \
                * BitVector.as_uint(data) + [save_stall_reg]

        def set_config_data_in(self, data):
            self.config_data_in = BitVector(data, config_data_width)

        def __cleanup(self):
            # Remove sequences from outputs/regs in preparation for the next
            # op.
            self.GC_regs[GC_reg_addr.stall_addr] \
                = [self.GC_regs[GC_reg_addr.stall_addr][-1]]
            self.config_addr_out = [self.config_addr_out[-1]]
            self.config_data_out = [self.config_data_out[-1]]
            self.read = [self.read[-1]]
            self.write = [self.write[-1]]
            self.config_data_to_jtag = self.config_data_to_jtag[-1]

        def __call__(self, *args, **kwargs):
            output_obj = self
            self._cleanup()
            return output_obj
