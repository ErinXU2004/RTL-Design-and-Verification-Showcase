# HDL + SystemVerilog/UVM Verification Projects

This repository contains RTL design modules and their corresponding verification environments written in SystemVerilog and UVM.

## 📚 About This Repository

Each folder in this repo contains a self-contained **design module** (e.g., flip-flop, FIFO, etc.) along with its:

- 💻 **Verilog design**
- ✅ **SystemVerilog testbench**
- 📈 **Simulation waveforms or output logs**
- 🔍 Optional **monitor / scoreboard** logic if applicable

This structure helps me build and verify reusable components while exploring different testbench methodologies.

Also, I drew a diagram based on my understanding of testbench module:

![TestbenchModule](docs/Testbench%20Module%20Components.jpeg)


## 📁 Modules Included So Far

- **D Flip-Flop (DFF)**
  - [RTL design](D-Flipflop/dff_design.v) using procedural always blocks
  - Class-based [testbench](D-Flipflop/dff_tb1.sv) with stimulus generation and output checking
  - Result [Waveform](D-Flipflop/dff_wave1.png) with Value from Random Generator & Driver

- **FIFO (First-In First-Out Buffer)**
  - Behavioral and structural [FIFO implementation](FIFO/fifo_design.v)
  - Randomized read/write stimulus with scoreboard-based verification [testbench](FIFO/fifo_tb.sv)



## 🛠 Tools Used

- **Platform:** [EDA Playground](https://edaplayground.com/)
- **Simulators:** 
  - Synopsys VCS
  - Cadence Xcelium

These simulators support SystemVerilog OOP features such as classes, mailboxes, interfaces, and assertions.


## 💡 Goals

- Build hands-on experience with **RTL design** and **testbench construction**
- Apply **SystemVerilog OOP verification concepts** (e.g., transactions, drivers, monitors)
- Practice **simulation debugging and waveform analysis**
- Prepare for interviews and real-world SoC/ASIC verification tasks



## 📬 Contact

If you're a hiring manager or mentor in digital design or verification, feel free to explore this repo or connect with me!

