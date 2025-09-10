`timescale 1ns / 1ps

// FIFO Coverage Testbench
// This file implements comprehensive functional coverage for FIFO module

class fifo_coverage;
    
    // Virtual interface for coverage collection
    virtual fifo_if fif;
    
    // Coverage groups
    covergroup fifo_operation_cg @(posedge fif.clock);
        // Operation type coverage
        oper_cp: coverpoint {fif.wr, fif.rd} {
            bins idle = {2'b00};
            bins write_only = {2'b10};
            bins read_only = {2'b01};
            bins read_write = {2'b11};
        }
        
        // Data input coverage
        data_in_cp: coverpoint fif.data_in {
            bins zero = {0};
            bins low = {[1:85]};
            bins mid = {[86:170]};
            bins high = {[171:254]};
            bins max = {255};
        }
        
        // Data output coverage
        data_out_cp: coverpoint fif.data_out {
            bins zero = {0};
            bins low = {[1:85]};
            bins mid = {[86:170]};
            bins high = {[171:254]};
            bins max = {255};
        }
        
        // FIFO status coverage
        status_cp: coverpoint {fif.full, fif.empty} {
            bins empty = {2'b01};
            bins normal = {2'b00};
            bins full = {2'b10};
            bins invalid = {2'b11};  // Should never happen
        }
        
        // Reset coverage
        reset_cp: coverpoint fif.rst {
            bins active = {1};
            bins inactive = {0};
        }
        
        // Cross coverage
        oper_status_cross: cross oper_cp, status_cp;
        data_status_cross: cross data_in_cp, status_cp;
        reset_oper_cross: cross reset_cp, oper_cp;
    endgroup
    
    covergroup fifo_depth_cg @(posedge fif.clock);
        // FIFO depth coverage (simulated)
        depth_cp: coverpoint fif.data_in {
            bins depth_0 = {0};
            bins depth_1_4 = {[1:4]};
            bins depth_5_8 = {[5:8]};
            bins depth_9_12 = {[9:12]};
            bins depth_13_15 = {[13:15]};
            bins depth_16 = {16};
        }
        
        // Write operation when full
        write_full_cp: coverpoint {fif.wr, fif.full} {
            bins write_when_not_full = {2'b10};
            bins write_when_full = {2'b11};
            bins no_write = {2'b00, 2'b01};
        }
        
        // Read operation when empty
        read_empty_cp: coverpoint {fif.rd, fif.empty} {
            bins read_when_not_empty = {2'b01};
            bins read_when_empty = {2'b11};
            bins no_read = {2'b00, 2'b10};
        }
        
        // Cross coverage
        depth_write_cross: cross depth_cp, write_full_cp;
        depth_read_cross: cross depth_cp, read_empty_cp;
    endgroup
    
    covergroup fifo_transition_cg @(posedge fif.clock);
        // State transition coverage
        state_transition_cp: coverpoint {fif.full, fif.empty} {
            bins empty_to_normal = {2'b01, 2'b00};
            bins normal_to_full = {2'b00, 2'b10};
            bins full_to_normal = {2'b10, 2'b00};
            bins normal_to_empty = {2'b00, 2'b01};
        }
        
        // Operation sequence coverage
        oper_sequence_cp: coverpoint {fif.wr, fif.rd} {
            bins idle_to_write = {2'b00, 2'b10};
            bins idle_to_read = {2'b00, 2'b01};
            bins write_to_read = {2'b10, 2'b01};
            bins read_to_write = {2'b01, 2'b10};
        }
        
        // Cross coverage
        state_oper_cross: cross state_transition_cp, oper_sequence_cp;
    endgroup
    
    // Constructor
    function new(virtual fifo_if fif);
        this.fif = fif;
        fifo_operation_cg = new();
        fifo_depth_cg = new();
        fifo_transition_cg = new();
    endfunction
    
    // Method to start coverage collection
    task start_coverage();
        fork
            fifo_operation_cg.start();
            fifo_depth_cg.start();
            fifo_transition_cg.start();
        join_none
    endtask
    
    // Method to stop coverage collection
    task stop_coverage();
        fifo_operation_cg.stop();
        fifo_depth_cg.stop();
        fifo_transition_cg.stop();
    endtask
    
    // Method to get coverage report
    function void get_coverage_report();
        $display("=== FIFO Coverage Report ===");
        $display("Operation Coverage: %0.2f%%", fifo_operation_cg.oper_cp.get_inst_coverage());
        $display("Data Input Coverage: %0.2f%%", fifo_operation_cg.data_in_cp.get_inst_coverage());
        $display("Data Output Coverage: %0.2f%%", fifo_operation_cg.data_out_cp.get_inst_coverage());
        $display("Status Coverage: %0.2f%%", fifo_operation_cg.status_cp.get_inst_coverage());
        $display("Depth Coverage: %0.2f%%", fifo_depth_cg.depth_cp.get_inst_coverage());
        $display("State Transition Coverage: %0.2f%%", fifo_transition_cg.state_transition_cp.get_inst_coverage());
        $display("Overall Operation Coverage: %0.2f%%", fifo_operation_cg.get_inst_coverage());
        $display("Overall Depth Coverage: %0.2f%%", fifo_depth_cg.get_inst_coverage());
        $display("Overall Transition Coverage: %0.2f%%", fifo_transition_cg.get_inst_coverage());
        $display("=============================");
    endfunction
    
endclass

// Enhanced FIFO Testbench with Coverage
module fifo_coverage_tb;
    
    fifo_if fif();
    FIFO dut (fif.clock, fif.rst, fif.wr, fif.rd, fif.data_in, fif.data_out, fif.empty, fif.full);
    
    // Coverage instance
    fifo_coverage cov;
    
    // Clock generation
    initial begin
        fif.clock <= 0;
    end
    
    always #10 fif.clock <= ~fif.clock;
    
    // Coverage test
    initial begin
        // Initialize coverage
        cov = new(fif);
        cov.start_coverage();
        
        // Reset sequence
        reset_fifo();
        
        // Test different scenarios
        test_basic_operations();
        test_full_fifo();
        test_empty_fifo();
        test_concurrent_operations();
        test_edge_cases();
        
        // Wait for completion
        #1000;
        
        // Generate coverage report
        cov.get_coverage_report();
        $finish();
    end
    
    // Reset FIFO
    task reset_fifo();
        $display("=== Resetting FIFO ===");
        fif.rst <= 1'b1;
        fif.wr <= 1'b0;
        fif.rd <= 1'b0;
        fif.data_in <= 0;
        repeat(5) @(posedge fif.clock);
        fif.rst <= 1'b0;
        $display("FIFO Reset Complete");
    endtask
    
    // Test basic operations
    task test_basic_operations();
        $display("=== Testing Basic Operations ===");
        
        // Test write operations
        repeat(5) begin
            write_data($urandom_range(1, 255));
        end
        
        // Test read operations
        repeat(5) begin
            read_data();
        end
        
        // Test mixed operations
        repeat(10) begin
            if ($random % 2) begin
                write_data($urandom_range(1, 255));
            end else begin
                read_data();
            end
        end
    endtask
    
    // Test full FIFO
    task test_full_fifo();
        $display("=== Testing Full FIFO ===");
        
        // Fill FIFO to full
        repeat(16) begin
            write_data($urandom_range(1, 255));
        end
        
        // Try to write when full
        write_data(8'hFF);
        
        // Read some data
        repeat(8) begin
            read_data();
        end
        
        // Write more data
        repeat(8) begin
            write_data($urandom_range(1, 255));
        end
    endtask
    
    // Test empty FIFO
    task test_empty_fifo();
        $display("=== Testing Empty FIFO ===");
        
        // Empty FIFO
        repeat(16) begin
            read_data();
        end
        
        // Try to read when empty
        read_data();
        
        // Write some data
        repeat(5) begin
            write_data($urandom_range(1, 255));
        end
    endtask
    
    // Test concurrent operations
    task test_concurrent_operations();
        $display("=== Testing Concurrent Operations ===");
        
        fork
            // Write operations
            begin
                repeat(20) begin
                    write_data($urandom_range(1, 255));
                end
            end
            // Read operations
            begin
                repeat(20) begin
                    read_data();
                end
            end
        join
    endtask
    
    // Test edge cases
    task test_edge_cases();
        $display("=== Testing Edge Cases ===");
        
        // Test reset during operations
        write_data(8'h55);
        fif.rst <= 1'b1;
        repeat(3) @(posedge fif.clock);
        fif.rst <= 1'b0;
        
        // Test rapid operations
        repeat(5) begin
            fif.wr <= 1'b1;
            fif.data_in <= $urandom_range(1, 255);
            @(posedge fif.clock);
            fif.wr <= 1'b0;
            @(posedge fif.clock);
        end
        
        // Test simultaneous read/write
        fif.wr <= 1'b1;
        fif.rd <= 1'b1;
        fif.data_in <= 8'hAA;
        @(posedge fif.clock);
        fif.wr <= 1'b0;
        fif.rd <= 1'b0;
        @(posedge fif.clock);
    endtask
    
    // Write data to FIFO
    task write_data(input [7:0] data);
        @(posedge fif.clock);
        fif.wr <= 1'b1;
        fif.rd <= 1'b0;
        fif.data_in <= data;
        @(posedge fif.clock);
        fif.wr <= 1'b0;
        $display("Write data: 0x%02h, Full: %b, Empty: %b", data, fif.full, fif.empty);
    endtask
    
    // Read data from FIFO
    task read_data();
        @(posedge fif.clock);
        fif.wr <= 1'b0;
        fif.rd <= 1'b1;
        @(posedge fif.clock);
        fif.rd <= 1'b0;
        $display("Read data: 0x%02h, Full: %b, Empty: %b", fif.data_out, fif.full, fif.empty);
    endtask
    
    // Waveform dump
    initial begin
        $dumpfile("fifo_coverage.vcd");
        $dumpvars(0, fifo_coverage_tb);
    end
    
endmodule
