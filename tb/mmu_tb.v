// ============================================================
//  Testbench: mmu_tb.v
//  Project  : MMU Design using Verilog HDL
//  Tests:
//    TC1 - Valid translation, READ  (VP 0, offset 5)
//    TC2 - Valid translation, WRITE (VP 2, offset 8)
//    TC3 - Page fault (VP 9, not in table)
//    TC4 - Protection fault: WRITE to READ-only page (VP 1)
//    TC5 - Protection fault: READ  from WRITE-only page (VP 3)
//    TC6 - Boundary: last valid VP with max offset (VP 4, offset F)
//    TC7 - enable = 0, outputs must stay zero
//    TC8 - Reset during operation
// ============================================================

`timescale 1ns/1ps

module mmu_tb;

    // ----------------------------------------------------------
    //  DUT signals
    // ----------------------------------------------------------
    reg         clk;
    reg         rst_n;
    reg  [15:0] virtual_addr;
    reg         access_type;   // 0=READ, 1=WRITE
    reg         enable;

    wire [11:0] physical_addr;
    wire        page_fault;
    wire        prot_fault;
    wire        trans_valid;

    // ----------------------------------------------------------
    //  Instantiate DUT
    // ----------------------------------------------------------
    mmu #(
        .VA_WIDTH   (16),
        .PA_WIDTH   (12),
        .PAGE_BITS  (4),
        .PT_ENTRIES (16)
    ) dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .virtual_addr (virtual_addr),
        .access_type  (access_type),
        .enable       (enable),
        .physical_addr(physical_addr),
        .page_fault   (page_fault),
        .prot_fault   (prot_fault),
        .trans_valid  (trans_valid)
    );

    // ----------------------------------------------------------
    //  Clock generation: 10 ns period
    // ----------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // ----------------------------------------------------------
    //  Task: apply stimulus and display result
    // ----------------------------------------------------------
    task apply_and_check;
        input [15:0] va;
        input        acc;
        input        en;
        input [127:0] test_name;  // string label
    begin
        @(negedge clk);            // Drive inputs before rising edge
        virtual_addr = va;
        access_type  = acc;
        enable       = en;
        @(posedge clk);            // Wait for DUT to respond
        #1;                        // Small delay to settle
        $display("------------------------------------------------------------");
        $display("[%0s]", test_name);
        $display("  VA=0x%04h  VPN=%0d  OFFSET=0x%01h  ACC=%0s  EN=%0b",
                  va, va[15:4], va[3:0], (acc ? "WRITE" : "READ"), en);
        $display("  PA=0x%03h  trans_valid=%0b  page_fault=%0b  prot_fault=%0b",
                  physical_addr, trans_valid, page_fault, prot_fault);
        @(negedge clk);
    end
    endtask

    // ----------------------------------------------------------
    //  Main test sequence
    // ----------------------------------------------------------
    initial begin
        $display("============================================================");
        $display("  MMU DESIGN TESTBENCH  -  Seshu");
        $display("  Virtual Addr Width : 16-bit");
        $display("  Physical Addr Width: 12-bit");
        $display("  Page Size          : 16 Bytes");
        $display("============================================================");

        // ----- Initialise -----
        rst_n        = 0;
        virtual_addr = 16'h0000;
        access_type  = 0;
        enable       = 0;

        // Assert reset for 2 cycles
        @(posedge clk); @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        // ==================================================
        //  TC1: Valid READ translation
        //  VP 0 → Frame 0x10,  Offset 0x5
        //  Expected PA = {0x10, 0x5} = 0x105
        // ==================================================
        apply_and_check(16'h0005, 1'b0, 1'b1, "TC1: Valid READ  VP0 offset=5 => PA=0x105");

        // ==================================================
        //  TC2: Valid WRITE translation
        //  VP 2 → Frame 0x30, Offset 0x8
        //  Expected PA = {0x30, 0x8} = 0x308
        // ==================================================
        apply_and_check(16'h0028, 1'b1, 1'b1, "TC2: Valid WRITE VP2 offset=8 => PA=0x308");

        // ==================================================
        //  TC3: Page fault – VP 9 is invalid
        //  Expected: page_fault=1, trans_valid=0
        // ==================================================
        apply_and_check(16'h0090, 1'b0, 1'b1, "TC3: Page Fault  VP9 (INVALID ENTRY)");

        // ==================================================
        //  TC4: Protection fault – VP 1 is READ-only, but WRITE requested
        //  Expected: prot_fault=1, trans_valid=0
        // ==================================================
        apply_and_check(16'h0013, 1'b1, 1'b1, "TC4: ProtFault   VP1 READ-only, WRITE attempted");

        // ==================================================
        //  TC5: Protection fault – VP 3 is WRITE-only, but READ requested
        //  Expected: prot_fault=1, trans_valid=0
        // ==================================================
        apply_and_check(16'h003A, 1'b0, 1'b1, "TC5: ProtFault   VP3 WRITE-only, READ attempted");

        // ==================================================
        //  TC6: Boundary – VP 4 (last valid), offset = 0xF (max)
        //  Expected PA = {0x50, 0xF} = 0x50F
        // ==================================================
        apply_and_check(16'h004F, 1'b0, 1'b1, "TC6: Boundary    VP4 offset=F => PA=0x50F");

        // ==================================================
        //  TC7: enable = 0, no translation should occur
        //  All outputs must be 0
        // ==================================================
        apply_and_check(16'h0005, 1'b0, 1'b0, "TC7: Enable=0    no translation, all outputs=0");

        // ==================================================
        //  TC8: Mid-run reset
        // ==================================================
        @(negedge clk);
        virtual_addr = 16'h0005;
        access_type  = 1;
        enable       = 1;
        @(posedge clk);
        #1;
        $display("------------------------------------------------------------");
        $display("[TC8: MID-RUN RESET]");
        $display("  Asserting rst_n=0 mid-operation");
        rst_n = 0;
        @(posedge clk);
        #1;
        $display("  After reset: PA=0x%03h  tv=%0b  pf=%0b  pf2=%0b",
                  physical_addr, trans_valid, page_fault, prot_fault);
        rst_n = 1;
        @(posedge clk);

        $display("============================================================");
        $display("  ALL TEST CASES COMPLETE");
        $display("============================================================");
        $finish;
    end

    // ----------------------------------------------------------
    //  VCD dump for waveform viewing (GTKWave / Vivado / ModelSim)
    // ----------------------------------------------------------
    initial begin
        $dumpfile("simulation/mmu_wave.vcd");
        $dumpvars(0, mmu_tb);
    end

endmodule
