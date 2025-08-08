`timescale 1ns / 1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

//////Transaction Class: describe the data sent to DUT
class transaction extends uvm_sequence_item; //it extends uvm_sequence_item to enable interaction with the sequencer and driver
    rand bit [3:0] a; //bit is 2-state 
    rand bit [3:0] b; //rand used to generate random value
    bit [4:0] y;

    function new(input string path = "transaction");
        super.new(path); // Call the base class constructor with the provided name.
    endfunction

    `uvm_object_utils_begin(transaction)
    `uvm_field_int(a, UVM_DEFAULT) // Register the fields for print, compare, copy, and packing.
    `uvm_field_int(b, UVM_DEFAULT)
    `uvm_field_int(y, UVM_DEFAULT)
    `uvm_object_utils_end

endclass

//////Sequence Class: Generate the sequence of transactions and send to driver
class generator extends uvm_sequence #(transaction); //It extends uvm_sequence with the parameter transaction, meaning it will generate and send transaction type items.
    `uvm_object_utils(generator) //Registers the generator class with the UVM factory.

    transaction t;
    integer i;

    function new(input string path = "generator");
        super.new(path);
    endfunction

virtual task body(); //This is where the actual stimulus generation happens in UVM.
    t = transaction::type_id::create("t");
    repeat(10)
        begin
            start_item(t); //Notifies the sequencer/driver that a new item is ready.
            t.randomize();
            `uvm_info("GEN", $sformatf("Data send to Driver a :%0d, b: %0d", t.a, t.b), UVM_NONE);
            finish_item(t); //Finalizes the transaction and sends it to the driver.
        end
endtask
endclass

///////Driver Class
class driver extends uvm_driver #(transaction); //Driver used to stimulate transaction
    `uvm_object_utils(driver)

        function new(input string path = "driver", uvm_component parent = null)
            super.new(path, parent);
        endfunction

    transaction tc; //transaction object used to save stimulus from sequencer
    virtual add_if aif;

        virtual function void build_phase(uvm_phase phase)
            super.build_phase(phase);
            tc = transaction::type_id::create("tc");

            if(!uvm_config_db #(virtual aif_if)::get(this,"","aif",aif)) //Find aif in this class and save value in key into it
                `uvm_error("DRV","Unable to access uvm_config_db", UVM_NONE);
        endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tc);//sepcial port used to communicate with sequencer
            aif.a <= tc.a;
            aif.b <= tc.b;
            `uvm_info("DRV", sformatf("Trigger DUT a: %0d, b: %0d", tc.a, tc.b), UVM_NONE);
            seq_item_port.item_done();
            #10
        end
    endtask
endclass

///////Monitor Class: Receives the response from DUT, wraps them into a transaction object, and publishes them via analysis port to scoreboard
class monitor extends uvm_monitor
    `uvm_component_utils(monitor)

    uvm_analysis_port #(transaction) send; //send transaction to scoreboard

    function new(input string inst = "monitor", uvm_component parent = null);
        super.new(inst,parent);
        send = new("send",this); //set parent to current class
    endfunction

    transaction t;
    virtual add_if aif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        t = transaction::type_id::create("t");

        if(!uvm_config_db #(virtual add_if)::get(this,"","aif",aif))
            `uvm_error("MON", "Unable to access uvm_config_db");
    endfunction

    virtual task run_phase(uvm_phase phase);
    forever begin
        #10;
        t.a = aif.a;
        t.b = aif.b;
        t.y = aif.y;
        `uvm_info("MON", $sformatf("Data send to Scoreboard a: %0d, b: %0d, and y: %0d", t.a, t.b, t.y),UVM_NONE);
        send.write(t);
    end
    endtask
endclass

class scoreboard extends uvm_scoreboard
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp#(transaction, scoreboard) recv;
    transaction tr;

    function new(input string inst = "scoreboard", uvm_component parent = "null");
        super.new(inst, parent);
        recv = new("recv", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = transaction::type_id::create("tr");
    endfunction

    virtual function void write(input transaction t);
        tr = t;
        `uvm_info("SCO",$sformatf("Data rcvd from Monitor a: %0d , b : %0d and y : %0d",tr.a,tr.b,tr.y), UVM_NONE);

        if(tr.y = tr.a+tr.b)
            `uvm_info("SCO","Test passed",UVM_NONE);
        else
            `uvm_info("SCO","Test failed",UVM_NONE);
    endfunction
endclass

class agent extends uvm_agent;
    `uvm_component_utils(agent);

    function new(input string inst = "agent", uvm_component c);
        super.new(inst, c);
    endfunction

    monitor m;
    driver d;
    uvm_sequence #(transaction) seqr;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m = monitor::type_id::create("m", this);
        d = driver::type_id::create("d", this);
        seqr = uvm_sequence #(transaction)::type_id::create("seqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass

class env extends uvm_env;
    `uvm_component_utils(env);
    function new(input string inst = "ENV", uvm_component c);
        super.new(inst,c);
    endfunction

    scoreboard s;
    agent a;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a = agent::type_id::create("a", this);
        s = scoreboard::type_id::create("s", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a.m.send.connect(s.recv);
    endfunction
endclass

class test extends uvm_test;
    `uvm_component_utils(test);
    function new(input string inst = "test", uvm_component c);
        super.new(inst,c);
    endfunction

    generator gen;
    env e;

    virtual function void build_phase(uvm_phase phase)
        super.build_phase(phase);
        e = env::type_id::create("e",this);
        gen = generator::type_id::create("gen",this);
    endfunction

    virtual task run_phase(uvm_phase phase)
        phase.raise_objection(this);
        gen.start(e.a.seqr);
        #50
        phase.drop_objection(this);
    endtask
endclass

module uvm_add_tb();
    add_if aif(();
    add dut(.a(aif.a),.b(aif.b),.y(aif.y)));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end

    initial begin
        uvm_config_db #(virtual add_if)::set(null, "uvm_test_top.e.a*", "aif", aif); //Send aif to driver & monitor
        run_test("test");
    end
endmodule