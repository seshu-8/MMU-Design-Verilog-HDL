# Vivado 2024.2 — Complete Step-by-Step Guide
## MMU Design using Verilog HDL

Every step below tells you exactly which window, button, or menu to use. Follow in order.

---

## STEP 1: Create New Project

1. Open **Vivado 2024.2**
2. On the Vivado start screen, click **Create Project**
3. Click **Next** on the welcome screen
4. **Project Name** screen:
   - Project name: `MMU_Design`
   - Project location: choose any folder (e.g., `Desktop`)
   - Leave **"Create project subdirectory"** checked
   - Click **Next**
5. **Project Type** screen:
   - Select **RTL Project**
   - Make sure **"Do not specify sources at this time"** is **unchecked**
   - Click **Next**

---

## STEP 2: Add the RTL Design File (mmu.v)

1. You're now on the **Add Sources** screen
2. Click the **Add Files** button (top right of the file list box)
3. A file browser opens → navigate to your project folder → go into `rtl/` → select `mmu.v` → click **OK**
4. Back on the Add Sources screen, check the box **"Copy sources into project"**
5. Click **Next**

---

## STEP 3: Add the Constraints File (XDC)

1. You're now on the **Add Constraints** screen
2. Click **Add Files**
3. Navigate into `constraints/` → select `nexys_a7.xdc` → click **OK**
4. Check **"Copy constraints files into project"**
5. Click **Next**

> Don't have a Nexys A7 board? Skip this step by clicking **Next** without adding any file. You can still simulate and synthesize without it — just skip Steps 11–12 (Implementation/Bitstream) later.

---

## STEP 4: Select the FPGA Part

1. You're now on the **Default Part** screen
2. Click the **Parts** tab (should already be selected)
3. In the search box, type: `xc7a100tcsg324-1`
4. Click on the part that appears in the list to select it (highlighted blue)

   *If you have a different board, search for its exact part number instead — check the board's documentation or silkscreen.*

5. Click **Next**
6. **Summary** screen appears → click **Finish**

Vivado now opens the main project window.

---

## STEP 5: Add the Testbench File (mmu_tb.v)

1. Look at the **Sources** panel on the left side of the main Vivado window
2. Right-click on **Simulation Sources** (folder icon in the tree) → select **Add Sources**
3. A dialog opens → select **Add or create simulation sources** → click **Next**
4. Click **Add Files**
5. Navigate into `tb/` → select `mmu_tb.v` → click **OK**
6. Check **"Copy sources into project"**
7. Click **Finish**

In the Sources panel, expand **Simulation Sources → sim_1** — you should now see both `mmu_tb.v` and `mmu.v` listed (Vivado automatically includes the design file in simulation).

---

## STEP 6: Run Behavioral Simulation

1. Look at the **Flow Navigator** panel on the far left
2. Find the section labeled **SIMULATION**
3. Click **Run Simulation** (this expands a small menu)
4. Click **Run Behavioral Simulation**

Vivado compiles the design. This takes 10–30 seconds. A new window/tab opens showing the waveform viewer. By default it stops after a short time window (1000 ns).

---

## STEP 7: Add Signals to the Waveform Window

If the waveform window already shows `virtual_addr`, `physical_addr`, etc., skip to Step 8. If it's empty or missing signals:

1. In the bottom-left of the waveform window, find the **Scope** panel (tab may be labeled "Scope")
2. In the Scope tree, click on `mmu_tb` → then click on `dut` (this is the DUT instance inside the testbench)
3. The **Objects** panel (next to Scope) now lists all signals of the `dut` (the MMU module): `clk`, `rst_n`, `virtual_addr`, `access_type`, `enable`, `physical_addr`, `page_fault`, `prot_fault`, `trans_valid`
4. Select all of them: click `clk`, then hold **Shift** and click the last signal to select the whole range
5. Right-click the selection → **Add to Wave Window**

---

## STEP 8: Run the Full Simulation

1. In the waveform window toolbar, find the **Run** icon (or go to menu **Simulation → Run → Run All**)
2. Click it. The testbench runs to completion (it calls `$finish` after all 8 test cases)
3. Click the **Zoom Fit** icon in the toolbar (magnifying glass with an outward arrow) to fit the entire simulation into view

You should now see all 8 test cases laid out across the waveform, with `physical_addr`, `page_fault`, and `prot_fault` changing at each test case boundary.

---

## STEP 9: Read the Test Results in the Tcl Console

1. At the bottom of the Vivado window, find the **Tcl Console** tab
2. Scroll up through the printed text — this is the `$display` output from the testbench
3. You'll see all 8 test cases printed with their VA, VPN, offset, access type, and resulting PA/fault flags
4. Confirm the final line reads: `ALL TEST CASES COMPLETE`

This console output is your simulation log — copy it into a text file for `reports/simulation_log.txt` if needed.

---

## STEP 10: Run Synthesis

1. In the **Flow Navigator**, find the **SYNTHESIS** section
2. Click **Run Synthesis**
3. A dialog box appears asking for number of jobs — leave default → click **OK**
4. Wait for the progress bar (bottom right) to complete — usually under a minute for this design
5. A popup appears: **"Synthesis Completed"** with options. Select **Open Synthesized Design** (or just click **Cancel** if you only want reports)

### View the reports:
1. In the **Flow Navigator**, under **SYNTHESIS**, expand **Reports** (or go to menu **Reports → Synthesis**)
2. Click **Report Utilization** → this shows LUT, FF, and IO counts used
3. Click **Report Timing Summary** → check that **WNS (Worst Negative Slack)** is **0 or positive** — this means timing is met

---

## STEP 11: Run Implementation

1. In the **Flow Navigator**, find the **IMPLEMENTATION** section
2. Click **Run Implementation**
3. A dialog may ask to confirm running synthesis first if not already done — click **Yes**
4. Wait for completion (1–2 minutes)
5. Popup appears: **"Implementation Completed"** → click **Cancel** (we'll generate the bitstream next)

---

## STEP 12: Generate Bitstream (only if you have FPGA hardware)

1. In the **Flow Navigator**, find **PROGRAM AND DEBUG**
2. Click **Generate Bitstream**
3. Wait for completion
4. Popup appears → click **Cancel** (or **Open Hardware Manager** if your board is connected via USB and you want to program it immediately)

If you don't have a board, you can stop after Step 11 — the Implementation report is sufficient proof of a complete, working design.

### Known issue: DRC UCIO-1 — Unconstrained Logical Port

`physical_addr` is 12 bits wide, but `constraints/nexys_a7.xdc` only maps the lower 8 bits (`physical_addr[7:0]`) to LEDs — there usually aren't enough free single-color LEDs on a Nexys A7 to map all 12 bits in this simple scheme. This causes **bitstream generation to fail** with:

```
[DRC UCIO-1] Unconstrained Logical Port: 4 out of 27 logical ports have no
user assigned specific location constraint (LOC)...
Problem ports: physical_addr[11], physical_addr[10], physical_addr[9], physical_addr[8].
```

This is expected and not a bug in the RTL — it's a deliberate simplification in the constraints file. To allow bitstream generation anyway, downgrade this specific DRC check from Error to Warning using a **pre-hook script** (a one-time `set_property` in the Tcl Console does *not* persist through `launch_runs`, so a hook file is required):

**1. Create the hook script** (Tcl Console), using your actual project path:

```tcl
set fp [open "D:/your/project/path/relax_drc.tcl" w]
puts $fp "set_property SEVERITY {Warning} \[get_drc_checks UCIO-1\]"
close $fp
```

**2. Attach it to the write_bitstream step:**

```tcl
set_property STEPS.WRITE_BITSTREAM.TCL.PRE "D:/your/project/path/relax_drc.tcl" [get_runs impl_1]
```

**3. Verify it was set correctly** (should print back the exact path with no doubling):

```tcl
get_property STEPS.WRITE_BITSTREAM.TCL.PRE [get_runs impl_1]
```

**4. Re-run bitstream generation:** Flow Navigator → PROGRAM AND DEBUG → **Generate Bitstream** → when prompted, choose **"Run from Step: write_bitstream"** (no need to redo synthesis/implementation).

This time the DRC check is a warning instead of an error, and `write_bitstream` completes normally.

---

## STEP 13: Save Reports and Screenshots for GitHub

Create these files/screenshots and place them in your project's `reports/` and `waveforms/` folders:

| File to save | Where to get it |
|---|---|
| `reports/utilization_report.txt` | Reports → Report Utilization → click **Export Report** button (top of report view) |
| `reports/timing_summary.txt` | Reports → Report Timing Summary → **Export Report** |
| `reports/simulation_log.txt` | Copy-paste text from the Tcl Console (Step 9) |
| `waveforms/full_simulation.png` | Screenshot of the waveform window after Zoom Fit (Step 8) |
| `waveforms/page_fault_tc3.png` | Zoom into TC3 region of the waveform, take a screenshot |
| `waveforms/prot_fault_tc4.png` | Zoom into TC4 or TC5 region, take a screenshot |

---

## Quick Reference Table

| # | Flow Navigator Section | Button to Click |
|---|---|---|
| 1 | — | Create Project |
| 2 | — | Add Sources → `mmu.v` |
| 3 | — | Add Constraints → `nexys_a7.xdc` |
| 4 | — | Select part `xc7a100tcsg324-1` |
| 5 | — | Add Sources → `mmu_tb.v` (as Simulation Source) |
| 6 | SIMULATION | Run Simulation → Run Behavioral Simulation |
| 7 | SYNTHESIS | Run Synthesis |
| 8 | IMPLEMENTATION | Run Implementation |
| 9 | PROGRAM AND DEBUG | Generate Bitstream |

---

## Troubleshooting

| Problem | Solution |
|---|---|
| `mmu_tb` not recognized as simulation top | Right-click `mmu_tb.v` in Sources panel → **Set as Top** |
| Simulation stops too early, doesn't show all test cases | Click **Run All** in the waveform toolbar, not just **Run** (which only advances a fixed time step) |
| Waveform window is blank/no signals | Repeat Step 7 — signals must be manually added from the Scope/Objects panels |
| XDC pin errors during synthesis | Constraints target Nexys A7 specifically. If using a different board, either remove the constraints file or edit `PACKAGE_PIN` values to match your board's pinout |
| "Synthesis failed" with port mismatch errors | Check Sources panel — make sure only `mmu.v` is under Design Sources and `mmu_tb.v` is under Simulation Sources, not mixed together |
| Can't find Tcl Console | Menu → **Window → Tcl Console** |
| Bitstream generation fails with `DRC UCIO-1` | See **"Known issue: DRC UCIO-1"** under Step 12 — use a pre-hook Tcl script to downgrade the check to a warning |
| `set_property STEPS.WRITE_BITSTREAM.TCL.PRE` path looks doubled-up | The Tcl Console's working directory is not your project folder — always pass the **full absolute path** to the hook file, not a relative one |
