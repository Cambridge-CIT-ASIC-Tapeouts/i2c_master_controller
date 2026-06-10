import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_i2c_master(dut):

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 5)

    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 5)

    # Start transfer
    dut.ui_in.value = 0x01

    await ClockCycles(dut.clk, 20)

    busy = int(dut.uo_out.value) & 1
    done = (int(dut.uo_out.value) >> 1) & 1
    ack  = (int(dut.uo_out.value) >> 2) & 1

    cocotb.log.info(f"BUSY={busy}")
    cocotb.log.info(f"DONE={done}")
    cocotb.log.info(f"ACK={ack}")

    assert done == 1
    assert ack == 1
    assert busy == 0
