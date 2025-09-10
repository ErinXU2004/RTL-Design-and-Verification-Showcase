`timescale 1ns / 1ps

// SPI Coverage Testbench
// This file implements comprehensive functional coverage for SPI module

class spi_coverage;
    
    // Virtual interface for coverage collection
    virtual spi_if vif;
    
    // Coverage groups
    covergroup spi_master_cg @(posedge vif.sclk);
        // Data input coverage
        data_in_cp: coverpoint vif.din {
            bins zero = {0};
            bins low = {[1:1023]};
            bins mid = {[1024:2047]};
            bins high = {[2048:3071]};
            bins max = {4095};
        }
        
        // New data signal coverage
        newd_cp: coverpoint vif.newd {
            bins idle = {0};
            bins start_transmission = {1};
        }
        
        // CS signal coverage
        cs_cp: coverpoint vif.cs {
            bins active = {0};
            bins inactive = {1};
        }
        
        // MOSI signal coverage
        mosi_cp: coverpoint vif.mosi {
            bins low = {0};
            bins high = {1};
        }
        
        // Done signal coverage
        done_cp: coverpoint vif.done {
            bins not_done = {0};
            bins done = {1};
        }
        
        // Cross coverage
        data_newd_cross: cross data_in_cp, newd_cp;
        cs_mosi_cross: cross cs_cp, mosi_cp;
        newd_done_cross: cross newd_cp, done_cp;
    endgroup
    
    covergroup spi_slave_cg @(posedge vif.sclk);
        // Data output coverage
        data_out_cp: coverpoint vif.dout {
            bins zero = {0};
            bins low = {[1:1023]};
            bins mid = {[1024:2047]};
            bins high = {[2048:3071]};
            bins max = {4095};
        }
        
        // CS detection coverage
        cs_detect_cp: coverpoint vif.cs {
            bins cs_high = {1};
            bins cs_low = {0};
        }
        
        // MOSI data coverage
        mosi_data_cp: coverpoint vif.mosi {
            bins mosi_0 = {0};
            bins mosi_1 = {1};
        }
        
        // Done signal coverage
        slave_done_cp: coverpoint vif.done {
            bins not_done = {0};
            bins done = {1};
        }
        
        // Cross coverage
        cs_mosi_data_cross: cross cs_detect_cp, mosi_data_cp;
        cs_done_cross: cross cs_detect_cp, slave_done_cp;
    endgroup
    
    covergroup spi_protocol_cg @(posedge vif.clk);
        // Protocol state coverage
        protocol_state_cp: coverpoint {vif.newd, vif.cs, vif.done} {
            bins idle = {3'b000};
            bins start = {3'b100};
            bins transmitting = {3'b110};
            bins complete = {3'b111};
            bins error = {3'b001, 3'b010, 3'b011, 3'b101};
        }
        
        // Clock frequency coverage
        sclk_freq_cp: coverpoint vif.sclk {
            bins sclk_low = {0};
            bins sclk_high = {1};
        }
        
        // Reset coverage
        reset_cp: coverpoint vif.rst {
            bins active = {1};
            bins inactive = {0};
        }
        
        // Cross coverage
        state_reset_cross: cross protocol_state_cp, reset_cp;
        sclk_state_cross: cross sclk_freq_cp, protocol_state_cp;
    endgroup
    
    covergroup spi_data_integrity_cg @(posedge vif.sclk);
        // Data integrity coverage
        data_integrity_cp: coverpoint vif.din {
            bins all_zeros = {0};
            bins all_ones = {4095};
            bins alternating = {0xAAA, 0x555};
            bins random = {[1:4094]};
        }
        
        // Bit position coverage
        bit_position_cp: coverpoint vif.mosi {
            bins bit_0 = {0};
            bins bit_1 = {1};
        }
        
        // Transmission length coverage
        transmission_length_cp: coverpoint vif.din {
            bins short = {[0:15]};
            bins medium = {[16:255]};
            bins long = {[256:4095]};
        }
        
        // Cross coverage
        data_bit_cross: cross data_integrity_cp, bit_position_cp;
        length_bit_cross: cross transmission_length_cp, bit_position_cp;
    endgroup
    
    // Constructor
    function new(virtual spi_if vif);
        this.vif = vif;
        spi_master_cg = new();
        spi_slave_cg = new();
        spi_protocol_cg = new();
        spi_data_integrity_cg = new();
    endfunction
    
    // Method to start coverage collection
    task start_coverage();
        fork
            spi_master_cg.start();
            spi_slave_cg.start();
            spi_protocol_cg.start();
            spi_data_integrity_cg.start();
        join_none
    endtask
    
    // Method to stop coverage collection
    task stop_coverage();
        spi_master_cg.stop();
        spi_slave_cg.stop();
        spi_protocol_cg.stop();
        spi_data_integrity_cg.stop();
    endtask
    
    // Method to get coverage report
    function void get_coverage_report();
        $display("=== SPI Coverage Report ===");
        $display("Master Data Coverage: %0.2f%%", spi_master_cg.data_in_cp.get_inst_coverage());
        $display("Master CS Coverage: %0.2f%%", spi_master_cg.cs_cp.get_inst_coverage());
        $display("Master MOSI Coverage: %0.2f%%", spi_master_cg.mosi_cp.get_inst_coverage());
        $display("Slave Data Coverage: %0.2f%%", spi_slave_cg.data_out_cp.get_inst_coverage());
        $display("Slave CS Detection: %0.2f%%", spi_slave_cg.cs_detect_cp.get_inst_coverage());
        $display("Protocol State Coverage: %0.2f%%", spi_protocol_cg.protocol_state_cp.get_inst_coverage());
        $display("Data Integrity Coverage: %0.2f%%", spi_data_integrity_cg.data_integrity_cp.get_inst_coverage());
        $display("Overall Master Coverage: %0.2f%%", spi_master_cg.get_inst_coverage());
        $display("Overall Slave Coverage: %0.2f%%", spi_slave_cg.get_inst_coverage());
        $display("Overall Protocol Coverage: %0.2f%%", spi_protocol_cg.get_inst_coverage());
        $display("Overall Data Integrity Coverage: %0.2f%%", spi_data_integrity_cg.get_inst_coverage());
        $display("=============================");
    endfunction
    
endclass

// Enhanced SPI Testbench with Coverage
module spi_coverage_tb;
    
    spi_if vif();
    top dut (vif.clk, vif.rst, vif.newd, vif.din, vif.dout, vif.done);
    
    // Coverage instance
    spi_coverage cov;
    
    // Clock generation
    initial begin
        vif.clk <= 0;
    end
    
    always #10 vif.clk <= ~vif.clk;
    
    // Coverage test
    initial begin
        // Initialize coverage
        cov = new(vif);
        cov.start_coverage();
        
        // Reset sequence
        reset_spi();
        
        // Test different scenarios
        test_basic_transmission();
        test_data_patterns();
        test_edge_cases();
        test_rapid_transmissions();
        test_protocol_violations();
        
        // Wait for completion
        #1000;
        
        // Generate coverage report
        cov.get_coverage_report();
        $finish();
    end
    
    // Reset SPI
    task reset_spi();
        $display("=== Resetting SPI ===");
        vif.rst <= 1'b1;
        vif.newd <= 1'b0;
        vif.din <= 0;
        repeat(10) @(posedge vif.clk);
        vif.rst <= 1'b0;
        $display("SPI Reset Complete");
    endtask
    
    // Test basic transmission
    task test_basic_transmission();
        $display("=== Testing Basic Transmission ===");
        
        // Test single transmission
        transmit_data(12'h555);
        transmit_data(12'hAAA);
        transmit_data(12'hFFF);
        transmit_data(12'h000);
    endtask
    
    // Test data patterns
    task test_data_patterns();
        $display("=== Testing Data Patterns ===");
        
        // Test all zeros
        transmit_data(12'h000);
        
        // Test all ones
        transmit_data(12'hFFF);
        
        // Test alternating patterns
        transmit_data(12'hAAA);
        transmit_data(12'h555);
        
        // Test random data
        repeat(20) begin
            transmit_data($urandom_range(0, 4095));
        end
        
        // Test specific bit patterns
        transmit_data(12'h001);  // LSB only
        transmit_data(12'h800);  // MSB only
        transmit_data(12'h00F);  // Lower nibble
        transmit_data(12'hF00);  // Upper nibble
    endtask
    
    // Test edge cases
    task test_edge_cases();
        $display("=== Testing Edge Cases ===");
        
        // Test reset during transmission
        vif.newd <= 1'b1;
        vif.din <= 12'h555;
        @(posedge vif.clk);
        vif.rst <= 1'b1;
        repeat(5) @(posedge vif.clk);
        vif.rst <= 1'b0;
        
        // Test rapid successive transmissions
        repeat(5) begin
            transmit_data($urandom_range(0, 4095));
        end
        
        // Test transmission without newd
        vif.din <= 12'h123;
        @(posedge vif.clk);
        @(posedge vif.clk);
    endtask
    
    // Test rapid transmissions
    task test_rapid_transmissions();
        $display("=== Testing Rapid Transmissions ===");
        
        fork
            // Rapid transmission
            begin
                repeat(10) begin
                    transmit_data($urandom_range(0, 4095));
                end
            end
            // Monitor for completion
            begin
                repeat(10) begin
                    wait(vif.done == 1'b1);
                    @(posedge vif.clk);
                end
            end
        join
    endtask
    
    // Test protocol violations
    task test_protocol_violations();
        $display("=== Testing Protocol Violations ===");
        
        // Test newd assertion without data change
        vif.din <= 12'h111;
        vif.newd <= 1'b1;
        @(posedge vif.clk);
        vif.newd <= 1'b0;
        wait(vif.done == 1'b1);
        
        // Test data change without newd
        vif.din <= 12'h222;
        @(posedge vif.clk);
        @(posedge vif.clk);
        
        // Test multiple newd assertions
        vif.din <= 12'h333;
        vif.newd <= 1'b1;
        @(posedge vif.clk);
        vif.newd <= 1'b0;
        vif.newd <= 1'b1;
        @(posedge vif.clk);
        vif.newd <= 1'b0;
    endtask
    
    // Transmit data
    task transmit_data(input [11:0] data);
        @(posedge vif.clk);
        vif.newd <= 1'b1;
        vif.din <= data;
        @(posedge vif.clk);
        vif.newd <= 1'b0;
        wait(vif.done == 1'b1);
        @(posedge vif.clk);
        $display("Transmitted data: 0x%03h", data);
    endtask
    
    // Waveform dump
    initial begin
        $dumpfile("spi_coverage.vcd");
        $dumpvars(0, spi_coverage_tb);
    end
    
    // Assign internal signals
    assign vif.sclk = dut.m1.sclk;
    
endmodule
