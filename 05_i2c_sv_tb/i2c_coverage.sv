`timescale 1ns / 1ps

// I2C Coverage Testbench
// This file implements comprehensive functional coverage for I2C module

class i2c_coverage;
    
    // Virtual interface for coverage collection
    virtual i2c_if vif;
    
    // Coverage groups
    covergroup i2c_operation_cg @(posedge vif.clk);
        // Operation type coverage
        oper_cp: coverpoint vif.op {
            bins write = {0};
            bins read = {1};
        }
        
        // Address coverage
        addr_cp: coverpoint vif.addr {
            bins addr_0 = {0};
            bins addr_low = {[1:31]};
            bins addr_mid = {[32:63]};
            bins addr_high = {[64:95]};
            bins addr_max = {127};
        }
        
        // Data input coverage
        data_in_cp: coverpoint vif.din {
            bins zero = {0};
            bins low = {[1:85]};
            bins mid = {[86:170]};
            bins high = {[171:254]};
            bins max = {255};
        }
        
        // Data output coverage
        data_out_cp: coverpoint vif.dout {
            bins zero = {0};
            bins low = {[1:85]};
            bins mid = {[86:170]};
            bins high = {[171:254]};
            bins max = {255};
        }
        
        // Busy signal coverage
        busy_cp: coverpoint vif.busy {
            bins idle = {0};
            bins busy = {1};
        }
        
        // Done signal coverage
        done_cp: coverpoint vif.done {
            bins not_done = {0};
            bins done = {1};
        }
        
        // ACK error coverage
        ack_err_cp: coverpoint vif.ack_err {
            bins no_error = {0};
            bins error = {1};
        }
        
        // Cross coverage
        oper_addr_cross: cross oper_cp, addr_cp;
        oper_data_cross: cross oper_cp, data_in_cp;
        busy_done_cross: cross busy_cp, done_cp;
        ack_oper_cross: cross ack_err_cp, oper_cp;
    endgroup
    
    covergroup i2c_protocol_cg @(posedge vif.clk);
        // Protocol state coverage
        protocol_state_cp: coverpoint {vif.newd, vif.busy, vif.done, vif.ack_err} {
            bins idle = {4'b0000};
            bins start = {4'b1000};
            bins busy_no_error = {4'b1100};
            bins busy_with_error = {4'b1101};
            bins complete_no_error = {4'b1110};
            bins complete_with_error = {4'b1111};
            bins error_states = {4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1001, 4'b1010, 4'b1011};
        }
        
        // New data signal coverage
        newd_cp: coverpoint vif.newd {
            bins idle = {0};
            bins start = {1};
        }
        
        // Reset coverage
        reset_cp: coverpoint vif.rst {
            bins active = {1};
            bins inactive = {0};
        }
        
        // Cross coverage
        state_reset_cross: cross protocol_state_cp, reset_cp;
        newd_state_cross: cross newd_cp, protocol_state_cp;
    endgroup
    
    covergroup i2c_address_cg @(posedge vif.clk);
        // Address range coverage
        addr_range_cp: coverpoint vif.addr {
            bins addr_0_15 = {[0:15]};
            bins addr_16_31 = {[16:31]};
            bins addr_32_47 = {[32:47]};
            bins addr_48_63 = {[48:63]};
            bins addr_64_79 = {[64:79]};
            bins addr_80_95 = {[80:95]};
            bins addr_96_111 = {[96:111]};
            bins addr_112_127 = {[112:127]};
        }
        
        // Operation with address coverage
        oper_addr_range_cross: cross vif.op, addr_range_cp {
            bins write_addr_0_15 = binsof(vif.op) intersect {0} && binsof(addr_range_cp) intersect {addr_0_15};
            bins read_addr_0_15 = binsof(vif.op) intersect {1} && binsof(addr_range_cp) intersect {addr_0_15};
            bins write_addr_16_31 = binsof(vif.op) intersect {0} && binsof(addr_range_cp) intersect {addr_16_31};
            bins read_addr_16_31 = binsof(vif.op) intersect {1} && binsof(addr_range_cp) intersect {addr_16_31};
        }
        
        // ACK error with address coverage
        ack_addr_cross: cross vif.ack_err, addr_range_cp;
    endgroup
    
    covergroup i2c_data_integrity_cg @(posedge vif.clk);
        // Data integrity coverage
        data_integrity_cp: coverpoint vif.din {
            bins all_zeros = {0};
            bins all_ones = {255};
            bins alternating = {0xAA, 0x55};
            bins random = {[1:254]};
        }
        
        // Data output integrity coverage
        data_out_integrity_cp: coverpoint vif.dout {
            bins all_zeros = {0};
            bins all_ones = {255};
            bins alternating = {0xAA, 0x55};
            bins random = {[1:254]};
        }
        
        // Operation with data coverage
        oper_data_cross: cross vif.op, data_integrity_cp;
        
        // Data input/output correlation
        data_correlation_cp: cross data_integrity_cp, data_out_integrity_cp;
    endgroup
    
    // Constructor
    function new(virtual i2c_if vif);
        this.vif = vif;
        i2c_operation_cg = new();
        i2c_protocol_cg = new();
        i2c_address_cg = new();
        i2c_data_integrity_cg = new();
    endfunction
    
    // Method to start coverage collection
    task start_coverage();
        fork
            i2c_operation_cg.start();
            i2c_protocol_cg.start();
            i2c_address_cg.start();
            i2c_data_integrity_cg.start();
        join_none
    endtask
    
    // Method to stop coverage collection
    task stop_coverage();
        i2c_operation_cg.stop();
        i2c_protocol_cg.stop();
        i2c_address_cg.stop();
        i2c_data_integrity_cg.stop();
    endtask
    
    // Method to get coverage report
    function void get_coverage_report();
        $display("=== I2C Coverage Report ===");
        $display("Operation Coverage: %0.2f%%", i2c_operation_cg.oper_cp.get_inst_coverage());
        $display("Address Coverage: %0.2f%%", i2c_operation_cg.addr_cp.get_inst_coverage());
        $display("Data Input Coverage: %0.2f%%", i2c_operation_cg.data_in_cp.get_inst_coverage());
        $display("Data Output Coverage: %0.2f%%", i2c_operation_cg.data_out_cp.get_inst_coverage());
        $display("Busy Signal Coverage: %0.2f%%", i2c_operation_cg.busy_cp.get_inst_coverage());
        $display("Done Signal Coverage: %0.2f%%", i2c_operation_cg.done_cp.get_inst_coverage());
        $display("ACK Error Coverage: %0.2f%%", i2c_operation_cg.ack_err_cp.get_inst_coverage());
        $display("Protocol State Coverage: %0.2f%%", i2c_protocol_cg.protocol_state_cp.get_inst_coverage());
        $display("Address Range Coverage: %0.2f%%", i2c_address_cg.addr_range_cp.get_inst_coverage());
        $display("Data Integrity Coverage: %0.2f%%", i2c_data_integrity_cg.data_integrity_cp.get_inst_coverage());
        $display("Overall Operation Coverage: %0.2f%%", i2c_operation_cg.get_inst_coverage());
        $display("Overall Protocol Coverage: %0.2f%%", i2c_protocol_cg.get_inst_coverage());
        $display("Overall Address Coverage: %0.2f%%", i2c_address_cg.get_inst_coverage());
        $display("Overall Data Integrity Coverage: %0.2f%%", i2c_data_integrity_cg.get_inst_coverage());
        $display("=============================");
    endfunction
    
endclass

// Enhanced I2C Testbench with Coverage
module i2c_coverage_tb;
    
    i2c_if vif();
    i2c_top dut (vif.clk, vif.rst, vif.newd, vif.op, vif.addr, vif.din, vif.dout, vif.busy, vif.ack_err, vif.done);
    
    // Coverage instance
    i2c_coverage cov;
    
    // Clock generation
    initial begin
        vif.clk <= 0;
    end
    
    always #5 vif.clk <= ~vif.clk;
    
    // Coverage test
    initial begin
        // Initialize coverage
        cov = new(vif);
        cov.start_coverage();
        
        // Reset sequence
        reset_i2c();
        
        // Test different scenarios
        test_basic_operations();
        test_address_range();
        test_data_patterns();
        test_edge_cases();
        test_error_conditions();
        test_concurrent_operations();
        
        // Wait for completion
        #1000;
        
        // Generate coverage report
        cov.get_coverage_report();
        $finish();
    end
    
    // Reset I2C
    task reset_i2c();
        $display("=== Resetting I2C ===");
        vif.rst <= 1'b1;
        vif.newd <= 1'b0;
        vif.op <= 1'b0;
        vif.din <= 0;
        vif.addr <= 0;
        repeat(10) @(posedge vif.clk);
        vif.rst <= 1'b0;
        $display("I2C Reset Complete");
    endtask
    
    // Test basic operations
    task test_basic_operations();
        $display("=== Testing Basic Operations ===");
        
        // Test write operations
        repeat(5) begin
            write_data($urandom_range(1, 127), $urandom_range(1, 255));
        end
        
        // Test read operations
        repeat(5) begin
            read_data($urandom_range(1, 127));
        end
        
        // Test mixed operations
        repeat(10) begin
            if ($random % 2) begin
                write_data($urandom_range(1, 127), $urandom_range(1, 255));
            end else begin
                read_data($urandom_range(1, 127));
            end
        end
    endtask
    
    // Test address range
    task test_address_range();
        $display("=== Testing Address Range ===");
        
        // Test all address ranges
        write_data(0, 8'h00);
        write_data(1, 8'h01);
        write_data(15, 8'h0F);
        write_data(16, 8'h10);
        write_data(31, 8'h1F);
        write_data(32, 8'h20);
        write_data(63, 8'h3F);
        write_data(64, 8'h40);
        write_data(95, 8'h5F);
        write_data(96, 8'h60);
        write_data(127, 8'h7F);
        
        // Test read from different addresses
        read_data(0);
        read_data(63);
        read_data(127);
    endtask
    
    // Test data patterns
    task test_data_patterns();
        $display("=== Testing Data Patterns ===");
        
        // Test all zeros
        write_data(10, 8'h00);
        
        // Test all ones
        write_data(11, 8'hFF);
        
        // Test alternating patterns
        write_data(12, 8'hAA);
        write_data(13, 8'h55);
        
        // Test specific bit patterns
        write_data(14, 8'h01);  // LSB only
        write_data(15, 8'h80);  // MSB only
        write_data(16, 8'h0F);  // Lower nibble
        write_data(17, 8'hF0);  // Upper nibble
        
        // Test random data
        repeat(20) begin
            write_data($urandom_range(1, 127), $urandom_range(1, 255));
        end
    endtask
    
    // Test edge cases
    task test_edge_cases();
        $display("=== Testing Edge Cases ===");
        
        // Test reset during operation
        vif.newd <= 1'b1;
        vif.op <= 1'b0;
        vif.addr <= 7'h12;
        vif.din <= 8'h55;
        @(posedge vif.clk);
        vif.rst <= 1'b1;
        repeat(5) @(posedge vif.clk);
        vif.rst <= 1'b0;
        
        // Test rapid successive operations
        repeat(5) begin
            write_data($urandom_range(1, 127), $urandom_range(1, 255));
        end
        
        // Test operation without newd
        vif.addr <= 7'h20;
        vif.din <= 8'h33;
        @(posedge vif.clk);
        @(posedge vif.clk);
    endtask
    
    // Test error conditions
    task test_error_conditions();
        $display("=== Testing Error Conditions ===");
        
        // Test invalid address (if supported)
        write_data(128, 8'h55);  // Address out of range
        
        // Test operation during busy
        vif.newd <= 1'b1;
        vif.op <= 1'b0;
        vif.addr <= 7'h30;
        vif.din <= 8'h66;
        @(posedge vif.clk);
        vif.newd <= 1'b0;
        
        // Start another operation while busy
        vif.newd <= 1'b1;
        vif.op <= 1'b1;
        vif.addr <= 7'h31;
        @(posedge vif.clk);
        vif.newd <= 1'b0;
    endtask
    
    // Test concurrent operations
    task test_concurrent_operations();
        $display("=== Testing Concurrent Operations ===");
        
        fork
            // Write operations
            begin
                repeat(10) begin
                    write_data($urandom_range(1, 127), $urandom_range(1, 255));
                end
            end
            // Read operations
            begin
                repeat(10) begin
                    read_data($urandom_range(1, 127));
                end
            end
        join
    endtask
    
    // Write data
    task write_data(input [6:0] addr, input [7:0] data);
        @(posedge vif.clk);
        vif.newd <= 1'b1;
        vif.op <= 1'b0;
        vif.addr <= addr;
        vif.din <= data;
        @(posedge vif.clk);
        vif.newd <= 1'b0;
        wait(vif.done == 1'b1);
        @(posedge vif.clk);
        $display("Write: Addr=0x%02h, Data=0x%02h, ACK_ERR=%b", addr, data, vif.ack_err);
    endtask
    
    // Read data
    task read_data(input [6:0] addr);
        @(posedge vif.clk);
        vif.newd <= 1'b1;
        vif.op <= 1'b1;
        vif.addr <= addr;
        vif.din <= 0;
        @(posedge vif.clk);
        vif.newd <= 1'b0;
        wait(vif.done == 1'b1);
        @(posedge vif.clk);
        $display("Read: Addr=0x%02h, Data=0x%02h, ACK_ERR=%b", addr, vif.dout, vif.ack_err);
    endtask
    
    // Waveform dump
    initial begin
        $dumpfile("i2c_coverage.vcd");
        $dumpvars(0, i2c_coverage_tb);
    end
    
endmodule
