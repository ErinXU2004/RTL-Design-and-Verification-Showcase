`timescale 1ns / 1ps

// UART Coverage Testbench
// This file implements comprehensive functional coverage for UART module

class uart_coverage;
    
    // Virtual interface for coverage collection
    virtual uart_if vif;
    
    // Coverage groups
    covergroup uart_tx_cg @(posedge vif.uclktx);
        // Data value coverage
        data_cp: coverpoint vif.dintx {
            bins zero = {0};
            bins low = {[1:85]};
            bins mid = {[86:170]};
            bins high = {[171:254]};
            bins max = {255};
        }
        
        // Operation type coverage
        oper_cp: coverpoint vif.newd {
            bins idle = {0};
            bins start_transmission = {1};
        }
        
        // Done signal coverage
        done_cp: coverpoint vif.donetx {
            bins not_done = {0};
            bins done = {1};
        }
        
        // Cross coverage
        data_oper_cross: cross data_cp, oper_cp;
        oper_done_cross: cross oper_cp, done_cp;
    endgroup
    
    covergroup uart_rx_cg @(posedge vif.uclkrx);
        // Received data coverage
        rx_data_cp: coverpoint vif.doutrx {
            bins zero = {0};
            bins low = {[1:85]};
            bins mid = {[86:170]};
            bins high = {[171:254]};
            bins max = {255};
        }
        
        // RX done signal coverage
        rx_done_cp: coverpoint vif.donerx {
            bins not_done = {0};
            bins done = {1};
        }
        
        // RX signal coverage
        rx_signal_cp: coverpoint vif.rx {
            bins idle = {1};
            bins start = {0};
        }
        
        // Cross coverage
        rx_data_done_cross: cross rx_data_cp, rx_done_cp;
        rx_signal_done_cross: cross rx_signal_cp, rx_done_cp;
    endgroup
    
    covergroup uart_state_cg @(posedge vif.clk);
        // State machine coverage for TX
        tx_state_cp: coverpoint vif.donetx {
            bins idle = {0};
            bins transmitting = {1};
        }
        
        // State machine coverage for RX
        rx_state_cp: coverpoint vif.donerx {
            bins idle = {0};
            bins receiving = {1};
        }
        
        // Reset coverage
        reset_cp: coverpoint vif.rst {
            bins active = {1};
            bins inactive = {0};
        }
        
        // Cross coverage
        reset_tx_cross: cross reset_cp, tx_state_cp;
        reset_rx_cross: cross reset_cp, rx_state_cp;
    endgroup
    
    // Constructor
    function new(virtual uart_if vif);
        this.vif = vif;
        uart_tx_cg = new();
        uart_rx_cg = new();
        uart_state_cg = new();
    endfunction
    
    // Method to start coverage collection
    task start_coverage();
        fork
            uart_tx_cg.start();
            uart_rx_cg.start();
            uart_state_cg.start();
        join_none
    endtask
    
    // Method to stop coverage collection
    task stop_coverage();
        uart_tx_cg.stop();
        uart_rx_cg.stop();
        uart_state_cg.stop();
    endtask
    
    // Method to get coverage report
    function void get_coverage_report();
        $display("=== UART Coverage Report ===");
        $display("TX Data Coverage: %0.2f%%", uart_tx_cg.data_cp.get_inst_coverage());
        $display("TX Operation Coverage: %0.2f%%", uart_tx_cg.oper_cp.get_inst_coverage());
        $display("TX Done Coverage: %0.2f%%", uart_tx_cg.done_cp.get_inst_coverage());
        $display("RX Data Coverage: %0.2f%%", uart_rx_cg.rx_data_cp.get_inst_coverage());
        $display("RX Done Coverage: %0.2f%%", uart_rx_cg.rx_done_cp.get_inst_coverage());
        $display("Overall TX Coverage: %0.2f%%", uart_tx_cg.get_inst_coverage());
        $display("Overall RX Coverage: %0.2f%%", uart_rx_cg.get_inst_coverage());
        $display("Overall State Coverage: %0.2f%%", uart_state_cg.get_inst_coverage());
        $display("=============================");
    endfunction
    
endclass

// Enhanced UART Testbench with Coverage
module uart_coverage_tb;
    
    uart_if vif();
    uart_top #(1000000, 9600) dut (vif.clk,vif.rst,vif.rx,vif.dintx,vif.newd,vif.tx,vif.doutrx,vif.donetx, vif.donerx);
    
    // Coverage instance
    uart_coverage cov;
    
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
        vif.rst <= 1'b1;
        vif.rx <= 1'b1;
        vif.newd <= 1'b0;
        vif.dintx <= 8'h00;
        repeat(10) @(posedge vif.clk);
        vif.rst <= 1'b0;
        
        // Test different data patterns
        test_data_patterns();
        
        // Test edge cases
        test_edge_cases();
        
        // Test concurrent TX/RX
        test_concurrent_operations();
        
        // Wait for completion
        #1000;
        
        // Generate coverage report
        cov.get_coverage_report();
        $finish();
    end
    
    // Test different data patterns
    task test_data_patterns();
        $display("=== Testing Data Patterns ===");
        
        // Test all data ranges
        test_single_data(8'h00);  // Zero
        test_single_data(8'h55);  // Low range
        test_single_data(8'hAA);  // Mid range
        test_single_data(8'hFF);  // Max value
        
        // Test random data
        repeat(20) begin
            test_single_data($urandom_range(0, 255));
        end
    endtask
    
    // Test single data transmission
    task test_single_data(input [7:0] data);
        @(posedge vif.clk);
        vif.dintx <= data;
        vif.newd <= 1'b1;
        @(posedge vif.clk);
        vif.newd <= 1'b0;
        wait(vif.donetx == 1'b1);
        @(posedge vif.clk);
        $display("Transmitted data: 0x%02h", data);
    endtask
    
    // Test edge cases
    task test_edge_cases();
        $display("=== Testing Edge Cases ===");
        
        // Test reset during transmission
        test_single_data(8'h55);
        vif.rst <= 1'b1;
        repeat(5) @(posedge vif.clk);
        vif.rst <= 1'b0;
        
        // Test rapid successive transmissions
        repeat(5) begin
            test_single_data($urandom_range(0, 255));
        end
    endtask
    
    // Test concurrent operations
    task test_concurrent_operations();
        $display("=== Testing Concurrent Operations ===");
        
        fork
            // TX operations
            begin
                repeat(10) begin
                    test_single_data($urandom_range(0, 255));
                end
            end
            // RX operations (simulate external RX)
            begin
                repeat(10) begin
                    @(posedge vif.clk);
                    vif.rx <= 1'b0;  // Start bit
                    repeat(8) begin
                        @(posedge vif.uclkrx);
                        vif.rx <= $random;
                    end
                    @(posedge vif.uclkrx);
                    vif.rx <= 1'b1;  // Stop bit
                    wait(vif.donerx == 1'b1);
                end
            end
        join
    endtask
    
    // Waveform dump
    initial begin
        $dumpfile("uart_coverage.vcd");
        $dumpvars(0, uart_coverage_tb);
    end
    
    // Assign internal signals
    assign vif.uclktx = dut.utx.uclk;
    assign vif.uclkrx = dut.rtx.uclk;
    
endmodule
