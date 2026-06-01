import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 5)

    dut.rst_n.value = 1

    # Apply test pattern
    dut.ui_in.value = 0xA5

    await ClockCycles(dut.clk, 1)

    # Check output
    assert int(dut.uo_out.value) == 0xA5

    dut._log.info("I2C Master Controller test passed")
