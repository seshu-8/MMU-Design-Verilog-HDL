#!/bin/bash
# ============================================================
#  Simulation script using Icarus Verilog (free & open-source)
#  Works on Linux, macOS, Windows (with WSL or MinGW)
#  Install: sudo apt install iverilog gtkwave
# ============================================================

set -e

echo "============================================================"
echo "  MMU Design - Simulation Script"
echo "  Using Icarus Verilog + GTKWave"
echo "============================================================"

# Create simulation output folder
mkdir -p simulation

# --- Compile ---
echo "[1/3] Compiling RTL + Testbench..."
iverilog -o simulation/mmu_sim.out \
    -I rtl \
    rtl/mmu.v \
    tb/mmu_tb.v

echo "      Compilation OK"

# --- Simulate ---
echo "[2/3] Running simulation..."
vvp simulation/mmu_sim.out | tee simulation/mmu_sim.log

echo "      Simulation log saved → simulation/mmu_sim.log"

# --- Waveform ---
echo "[3/3] Opening GTKWave..."
echo "      VCD file → simulation/mmu_wave.vcd"
if command -v gtkwave &> /dev/null; then
    gtkwave simulation/mmu_wave.vcd &
else
    echo "      GTKWave not found. Open simulation/mmu_wave.vcd manually."
fi

echo "============================================================"
echo "  Done. Check simulation/ folder for outputs."
echo "============================================================"
