# RTL Design & Verification Collection

This repository contains my self-driven **RTL design** and **verification** projects, covering common digital interfaces, arithmetic circuits, and UVM-based verification environments.  
It demonstrates my skills in **Verilog, SystemVerilog, and UVM**, including design, testbench development, and waveform analysis.

## 📂 Project List

### 1. Common Interfaces (SystemVerilog Testbenches)

- **UART**
  - [RTL Design](01_uart_sv_tb/uart_design.v)  
  - [SystemVerilog Testbench](01_uart_sv_tb/uart_tb.sv)  
  - [Waveform Screenshot](01_uart_sv_tb/uart_transmitter.png)  
  - [Simulation Result](01_uart_sv_tb/uart_result)

- **FIFO** 
  - [RTL Design](02_fifo_sv_tb/fifo_design.v)  
  - [SystemVerilog Testbench](02_fifo_sv_tb/fifo_tb.sv) 
  - [Simulation Result](02_fifo_sv_tb/fifo_result)

- **APB**
  - [RTL Design](03_apb_sv_tb/APB_design.v)  
  - [SystemVerilog Testbench](03_apb_sv_tb/APB_tb.sv)  

- **SPI**
  - [RTL Design](04_spi_sv_tb/spi_rtl.v)  
  - [SystemVerilog Testbench](04_spi_sv_tb/spi_tb.sv)  
  - [Waveform Screenshot](04_spi_sv_tb/spi_wave1_sv_tb.png)  
  - [Simulation Result](04_spi_sv_tb/spi_result)

- **I2C**  
  - [RTL Design](05_i2c_sv_tb/i2c_rtl.v)  
  - [SystemVerilog Testbench](05_i2c_sv_tb/i2c_tb.sv)  

- **FIFO (Alt Implementation)**
  - [RTL Design](06_fifo_sv_tb/dff_rtl.v)  
  - [SystemVerilog Testbench](06_fifo_sv_tb/dff_tb1.sv)  
  - [Waveform Screenshot](06_fifo_sv_tb/dff_wave1.png)  
  - [Simulation Result](04_spi_sv_tb/spi_result)



### 2. Arithmetic Circuits (UVM Testbenches)

- [**Combinational Adder**](07_comb_adder_uvm_tb) (UVM Testbench)
  - [RTL Design](07_comb_adder_uvm_tb/comb_adder_rtl.v)  
  - [UVM Testbench](07_comb_adder_uvm_tb/uvm_add_tb.sv)

- [**Sequential Adder**](08_seq_adder_uvm_tb) (UVM Testbench) 
  - [RTL Design](08_seq_adder_uvm_tb/seq_adder_rtl.v)  
  - [UVM Testbench](08_seq_adder_uvm_tb/uvm_add_tb.sv)



## 💡 Skills Demonstrated

- **HDL Languages**: Verilog, SystemVerilog
- **Verification Methodology**: UVM
- **Digital Design Concepts**:
  - UART, SPI, I2C protocols
  - FIFO design and verification
  - APB bus interface
  - Combinational & sequential arithmetic circuits
- **Verification Artifacts**:
  - Self-written SystemVerilog & UVM testbenches
  - Captured simulation results and waveforms



## 📄 Documentation

Additional design notes and diagrams are in the [docs/](docs) folder.