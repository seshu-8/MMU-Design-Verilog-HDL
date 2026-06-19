// ============================================================
//  Memory Management Unit (MMU) - RTL Design
//  Project : MMU Design using Verilog HDL
//  Author  : Seshu
//  Description:
//    Translates 16-bit virtual addresses to 12-bit physical
//    addresses using a 16-entry page table with valid bit,
//    read/write permission bits, and page-fault detection.
//
//  Virtual Address  [15:0]  = PAGE_NUMBER[15:4] | OFFSET[3:0]
//  Physical Address [11:0]  = FRAME_NUMBER[11:4] | OFFSET[3:0]
//  Page Size        = 16 bytes  (4-bit offset)
//  Page Table Entries = 16
// ============================================================

module mmu #(
    parameter VA_WIDTH     = 16,   // Virtual  address width
    parameter PA_WIDTH     = 12,   // Physical address width
    parameter PAGE_BITS    = 4,    // Offset bits  (page size = 2^4 = 16 B)
    parameter PT_ENTRIES   = 16    // Number of page-table entries
)(
    input  wire                 clk,
    input  wire                 rst_n,          // Active-low synchronous reset

    // Translation request
    input  wire [VA_WIDTH-1:0]  virtual_addr,   // 16-bit virtual address
    input  wire                 access_type,    // 0 = READ,  1 = WRITE
    input  wire                 enable,         // High to trigger translation

    // Translation result
    output reg  [PA_WIDTH-1:0]  physical_addr,  // 12-bit physical address
    output reg                  page_fault,     // Page not present
    output reg                  prot_fault,     // Permission violation
    output reg                  trans_valid     // Translation succeeded
);

    // ----------------------------------------------------------
    //  Internal parameters
    // ----------------------------------------------------------
    localparam VPN_BITS   = VA_WIDTH - PAGE_BITS;  // Virtual page number bits = 12
    localparam FPN_BITS   = PA_WIDTH - PAGE_BITS;  // Frame number bits        = 8

    // ----------------------------------------------------------
    //  Page Table Entry format  (10 bits per entry)
    //  [9]      = valid bit
    //  [8]      = read  permission
    //  [7]      = write permission
    //  [FPN_BITS-1:0] = frame number (8 bits)
    // ----------------------------------------------------------
    localparam PTE_WIDTH  = 1 + 1 + 1 + FPN_BITS;  // = 11 bits

    reg [PTE_WIDTH-1:0] page_table [0:PT_ENTRIES-1];

    // ----------------------------------------------------------
    //  Address decomposition wires
    // ----------------------------------------------------------
    wire [VPN_BITS-1:0]  vpn    = virtual_addr[VA_WIDTH-1 : PAGE_BITS];
    wire [PAGE_BITS-1:0] offset = virtual_addr[PAGE_BITS-1 : 0];

    // ----------------------------------------------------------
    //  Page table fields from looked-up entry
    // ----------------------------------------------------------
    wire                  pte_valid = page_table[vpn][PTE_WIDTH-1];
    wire                  pte_read  = page_table[vpn][PTE_WIDTH-2];
    wire                  pte_write = page_table[vpn][PTE_WIDTH-3];
    wire [FPN_BITS-1:0]   pte_frame = page_table[vpn][FPN_BITS-1:0];

    // ----------------------------------------------------------
    //  Page table initialisation
    //  Format: {valid, read, write, frame_number}
    //
    //  Entry 0  : VP 0  → Frame 0x10, R+W
    //  Entry 1  : VP 1  → Frame 0x20, R only
    //  Entry 2  : VP 2  → Frame 0x30, R+W
    //  Entry 3  : VP 3  → Frame 0x40, W only  (unusual, for testing)
    //  Entry 4  : VP 4  → Frame 0x50, R+W
    //  Entries 5-15 : INVALID
    // ----------------------------------------------------------
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset outputs
            physical_addr <= {PA_WIDTH{1'b0}};
            page_fault    <= 1'b0;
            prot_fault    <= 1'b0;
            trans_valid   <= 1'b0;

            // Load page table on reset
            page_table[0]  <= {1'b1, 1'b1, 1'b1, 8'h10};  // valid,R,W, frame=0x10
            page_table[1]  <= {1'b1, 1'b1, 1'b0, 8'h20};  // valid,R,  , frame=0x20
            page_table[2]  <= {1'b1, 1'b1, 1'b1, 8'h30};  // valid,R,W, frame=0x30
            page_table[3]  <= {1'b1, 1'b0, 1'b1, 8'h40};  // valid, ,W, frame=0x40
            page_table[4]  <= {1'b1, 1'b1, 1'b1, 8'h50};  // valid,R,W, frame=0x50
            page_table[5]  <= {1'b0, 1'b0, 1'b0, 8'h00};  // INVALID
            page_table[6]  <= {1'b0, 1'b0, 1'b0, 8'h00};
            page_table[7]  <= {1'b0, 1'b0, 1'b0, 8'h00};
            page_table[8]  <= {1'b0, 1'b0, 1'b0, 8'h00};
            page_table[9]  <= {1'b0, 1'b0, 1'b0, 8'h00};
            page_table[10] <= {1'b0, 1'b0, 1'b0, 8'h00};
            page_table[11] <= {1'b0, 1'b0, 1'b0, 8'h00};
            page_table[12] <= {1'b0, 1'b0, 1'b0, 8'h00};
            page_table[13] <= {1'b0, 1'b0, 1'b0, 8'h00};
            page_table[14] <= {1'b0, 1'b0, 1'b0, 8'h00};
            page_table[15] <= {1'b0, 1'b0, 1'b0, 8'h00};
        end
        else if (enable) begin
            // Default: clear outputs
            physical_addr <= {PA_WIDTH{1'b0}};
            page_fault    <= 1'b0;
            prot_fault    <= 1'b0;
            trans_valid   <= 1'b0;

            // Step 1: Valid bit check
            if (!pte_valid) begin
                page_fault  <= 1'b1;   // Page not loaded in memory
            end
            // Step 2: Permission check
            else if (access_type == 1'b0 && !pte_read) begin
                prot_fault  <= 1'b1;   // Read not permitted
            end
            else if (access_type == 1'b1 && !pte_write) begin
                prot_fault  <= 1'b1;   // Write not permitted
            end
            // Step 3: Successful translation
            else begin
                physical_addr <= {pte_frame, offset};
                trans_valid   <= 1'b1;
            end
        end
        else begin
            // enable = 0: hold outputs at 0
            physical_addr <= {PA_WIDTH{1'b0}};
            page_fault    <= 1'b0;
            prot_fault    <= 1'b0;
            trans_valid   <= 1'b0;
        end
    end

endmodule
