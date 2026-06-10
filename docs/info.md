# I2C Master Controller

## How it works

This project implements a simple I2C Master Controller in Verilog for Tiny Tapeout.

The controller generates I2C communication signals on the SDA and SCL lines. When a START command is received, the controller initiates a transmission sequence consisting of:

* START condition generation
* Transmission of a fixed 7-bit slave address (0x50) with a write bit
* Transmission of one 8-bit data byte
* STOP condition generation

The design is implemented as a finite state machine (FSM) and operates from the Tiny Tapeout system clock.

Three status outputs are provided:

* **BUSY**: Indicates that a transmission is in progress.
* **DONE**: Indicates that the transmission has completed.
* **ACK**: Indicates successful completion of the transfer sequence.

The SDA and SCL signals are available on the bidirectional I/O pins and can be monitored using external test equipment.

## How to test

1. Apply reset by driving `rst_n` low.
2. Release reset by driving `rst_n` high.
3. Place the desired data value on the input pins.
4. Assert the START input.
5. Observe the SDA and SCL outputs.
6. Monitor the BUSY signal during transmission.
7. Verify that DONE and ACK are asserted when the transfer completes.

Expected behavior:

* BUSY goes high when transmission starts.
* SDA outputs the serial data stream.
* SCL toggles during transmission.
* DONE goes high after the STOP condition is generated.
* ACK is asserted when the transaction finishes.

## External hardware

The design may be connected to:

* An I2C slave device
* A logic analyzer
* An oscilloscope

These tools can be used to observe the SDA and SCL waveforms and verify correct operation of the controller.
