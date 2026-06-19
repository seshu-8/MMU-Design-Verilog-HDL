# MMU Design – Interview Preparation
## 10 Questions + Strong Answers

---

### Q1. Explain your project.

**Answer:**

"I designed and verified a Memory Management Unit in Verilog HDL as a VLSI course project. The MMU translates 16-bit virtual addresses to 12-bit physical addresses using a 16-entry page table stored in registers. Each page table entry holds a valid bit, read/write permission bits, and an 8-bit frame number. The address is split into a 12-bit virtual page number and a 4-bit page offset. On every translation request, the design checks the valid bit first — if the page is not in memory, it raises a page_fault. If the page is present but the access type violates permissions, it raises a prot_fault. Otherwise it concatenates the frame number with the original offset to produce the physical address and asserts trans_valid. I wrote a testbench with 8 test cases covering valid reads, valid writes, page faults, protection faults, boundary addresses, enable=0 behaviour, and mid-run reset. All tests passed in Icarus Verilog simulation. The design is parameterised so VA width, PA width, page size, and table entries can all be changed without modifying the RTL."

---

### Q2. What is the difference between a virtual address and a physical address?

**Answer:**

A **virtual address** is what the CPU core generates — it's the address from the program's point of view. Every process has its own virtual address space starting from zero. A **physical address** is the actual location on the memory chips. The MMU maintains a page table that maps virtual pages to physical frames. This separation lets multiple processes coexist without knowing about each other's physical locations, enables memory protection, and allows the OS to swap pages to disk (making physical memory appear larger than it is — the basis of virtual memory).

---

### Q3. What is a page table and what does each entry contain?

**Answer:**

A **page table** is a data structure (implemented as a register array in hardware or a RAM region in software) that maps virtual page numbers to physical frame numbers. Each **Page Table Entry (PTE)** in my design contains:
- **Valid bit** — indicates the page is currently in physical memory
- **Read permission bit** — allows read access
- **Write permission bit** — allows write access
- **Frame number** — the physical frame to map to

More advanced MMUs also include dirty bits, accessed bits, user/kernel privilege bits, execute-disable bits, and caching attributes.

---

### Q4. What is a page fault and how is it handled?

**Answer:**

A **page fault** occurs when the CPU tries to access a virtual page whose valid bit is 0 — meaning the page is not currently in physical memory. In hardware (like my RTL), the MMU raises the `page_fault` output. In a real system, this triggers a CPU exception that invokes the OS page fault handler, which:
1. Finds the requested page on disk (swap space)
2. Loads it into a free physical frame
3. Updates the page table entry (sets valid=1, fills frame number)
4. Clears the fault and re-executes the faulting instruction

In my design, the fault is just a flag — the OS-level handler is not modelled, which is appropriate for an RTL-only implementation.

---

### Q5. What is a protection fault and give an example from your project?

**Answer:**

A **protection fault** (also called a segmentation fault at the OS level) occurs when a valid page is accessed with a permission it doesn't have. In my design, page table entry for VPN 1 is marked read-only (read=1, write=0). If a WRITE access is attempted to this page, the `prot_fault` output is asserted. Similarly, VPN 3 is write-only; a READ attempt raises prot_fault. This is directly modelled in testbench TC4 and TC5. In real processors, protection faults enforce user/kernel separation — a user process cannot write to kernel memory pages.

---

### Q6. Why is the page offset passed directly to the physical address?

**Answer:**

The page offset specifies the byte position *within* a page. Since pages and frames are the same size (16 bytes in my design), the position within the frame is identical to the position within the page. Translating the page number maps you to the right frame, and the offset then locates the exact byte within that frame. Changing the offset would mean changing which byte within the page is accessed — that's the CPU's job, not the MMU's. So the offset bits are concatenated unchanged: `PA = {frame_number, page_offset}`.

---

### Q7. What is the difference between combinational and sequential logic, and which did you use?

**Answer:**

**Combinational logic** produces outputs that depend only on current inputs — no memory, no clock. **Sequential logic** uses flip-flops clocked by a clock signal, so outputs depend on both current inputs and stored state. I used **sequential (synchronous) logic** — the page table is stored in registers, and all outputs (physical_addr, page_fault, prot_fault, trans_valid) are registered on the rising clock edge. This makes the design synthesisable and timing-closure-friendly. A pure combinational MMU is also possible for small tables, but registered outputs avoid glitches and are standard in ASIC/FPGA flows.

---

### Q8. How would you extend this design to support a TLB?

**Answer:**

A **Translation Lookaside Buffer (TLB)** is a small fully-associative cache of recently used page table entries. The extension would add:
1. A TLB array of N entries (typically 16–64), each holding {VPN, frame, valid, permissions}
2. A parallel comparator tree to check if the incoming VPN matches any TLB entry (TLB hit in 1 cycle)
3. On a TLB miss, fall back to the full page table walk (multi-cycle)
4. A replacement policy (LRU or random) to evict old entries

This reduces average translation latency from N cycles (page table walk) to 1 cycle for the common case. Modern CPUs have separate instruction and data TLBs with multi-level hierarchies (L1 ITLB, L1 DTLB, L2 unified TLB).

---

### Q9. How are MMUs used in SoC design?

**Answer:**

In an SoC, the MMU is part of the processor subsystem and sits between the CPU pipeline and the bus fabric (AXI/AHB). It serves several roles: (1) **Process isolation** — each process/thread has its own page table, preventing one from corrupting another's memory. (2) **Secure computing** — TrustZone-style architectures use the MMU to create secure vs. non-secure memory regions. (3) **IOMMU** — peripheral devices (DMA controllers, GPUs) get their own address translation unit so they cannot access arbitrary physical memory. (4) **Hypervisors** — two-stage translation (VTTBR in ARM) maps guest virtual → guest physical → host physical for virtualisation. (5) **Memory-mapped I/O** — virtual addresses can be mapped to device registers, making hardware access look like normal memory reads/writes.

---

### Q10. What tools did you use and how would you simulate this project?

**Answer:**

I used **Icarus Verilog** (open-source) for simulation and **GTKWave** for waveform viewing — both are free and work on Linux, macOS, and Windows (WSL). The workflow is:
```
iverilog -o simulation/mmu_sim.out rtl/mmu.v tb/mmu_tb.v
vvp simulation/mmu_sim.out
gtkwave simulation/mmu_wave.vcd
```
The testbench generates a VCD file that shows all signals over time. In GTKWave, I add `virtual_addr`, `physical_addr`, `page_fault`, `prot_fault`, and `trans_valid` to the waveform view. For synthesis, the design targets Xilinx Artix-7 via Vivado — I can check LUT/FF usage in the utilisation report and verify timing closure at 100 MHz. For FPGA deployment on a Nexys A7, switches represent the virtual address and LEDs display the physical address and fault flags per the XDC constraints file included in the project.
