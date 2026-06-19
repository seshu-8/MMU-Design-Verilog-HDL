\# Git \& GitHub Upload Guide

\## MMU Design using Verilog HDL



Step-by-step commands to push this project to GitHub — from first init to final push, with a structured multi-commit history (looks better than one giant commit on your profile).



\---



\## 0. Prerequisites



\- Git installed → check with: `git --version`

\- GitHub account created

\- (Recommended) GitHub CLI `gh` installed, or just use the website to create the repo



\---



\## 1. Create the Repository on GitHub



\*\*Repository name:\*\* `MMU-Design-Verilog-HDL`



\*\*Description:\*\*

```

Memory Management Unit (MMU) design in Verilog HDL — virtual-to-physical address translation, page table, page fault \& protection fault detection. Simulation-verified (Icarus Verilog) and synthesized + implemented on Xilinx Vivado 2024.2 (Artix-7).

```



\*\*Topics/Tags:\*\*

```

verilog vlsi rtl-design fpga vivado digital-design computer-architecture

memory-management-unit mmu hdl hardware-design verification testbench

```



1\. Go to \[github.com/new](https://github.com/new)

2\. Repository name: `MMU-Design-Verilog-HDL`

3\. Paste the description above

4\. Set to \*\*Public\*\* (so it's visible on your profile as proof of work)

5\. \*\*Do NOT\*\* initialize with README, .gitignore, or license — you already have these locally

6\. Click \*\*Create repository\*\*

7\. Copy the repository URL shown (e.g., `https://github.com/YOUR\_USERNAME/MMU-Design-Verilog-HDL.git`)



\---



\## 2. One-Time Git Setup (skip if already configured)



```bash

git config --global user.name "Your Name"

git config --global user.email "your.email@example.com"

```



\---



\## 3. Initialize the Local Repository



Open a terminal/PowerShell \*\*inside the project folder\*\* (`MMU-Design-Verilog-HDL/`):



```bash

cd MMU-Design-Verilog-HDL

git init

git branch -M main

```



\---



\## 4. Connect to GitHub Remote



```bash

git remote add origin https://github.com/YOUR\_USERNAME/MMU-Design-Verilog-HDL.git

```



Replace `YOUR\_USERNAME` with your actual GitHub username.



\---



\## 5. Structured Commit Plan (7 commits)



Instead of one big commit, push in logical stages — this shows a clean development history when someone (e.g., an interviewer) checks your commit log.



\### Commit 1 — Project scaffolding



```bash

git add .gitignore README.md

git commit -m "Initial commit: project structure and README"

```



\### Commit 2 — RTL design



```bash

git add rtl/mmu.v

git commit -m "Add MMU RTL design: address translation, page table, fault detection"

```



\### Commit 3 — Testbench



```bash

git add tb/mmu\_tb.v

git commit -m "Add testbench: 8 test cases covering valid/invalid translation and faults"

```



\### Commit 4 — Simulation scripts and waveform



```bash

git add simulation/ waveforms/

git commit -m "Add simulation script and waveform results (Icarus Verilog + Vivado)"

```



\### Commit 5 — FPGA constraints



```bash

git add constraints/

git commit -m "Add Vivado XDC constraints for Nexys A7 (Artix-7) implementation"

```



\### Commit 6 — Synthesis/implementation reports



```bash

git add reports/ images/

git commit -m "Add synthesis utilization report, timing summary, and design schematics"

```



\### Commit 7 — Documentation



```bash

git add docs/

git commit -m "Add project report, interview prep, and Vivado simulation guide"

```



\---



\## 6. Push Everything to GitHub



```bash

git push -u origin main

```



Enter your GitHub username and a \*\*Personal Access Token\*\* (not your password) when prompted, if using HTTPS. To create a token: GitHub → Settings → Developer settings → Personal access tokens → Generate new token (classic) → check `repo` scope.



\---



\## 7. Verify



1\. Refresh your GitHub repository page

2\. Confirm all folders (`rtl/`, `tb/`, `constraints/`, `simulation/`, `waveforms/`, `reports/`, `images/`, `docs/`) appear

3\. Confirm the README renders with images visible (waveform, utilization report, timing summary, schematics)

4\. Check \*\*Commits\*\* tab — you should see all 7 commits in order



\---



\## 8. Optional: Add a License



Most portfolio repos include an MIT license.



```bash

\# On GitHub: Add file → Create new file → name it LICENSE

\# Choose "Choose a license template" → MIT License → Commit directly to main

```



Then locally:

```bash

git pull origin main

```



\---



\## Quick Reference — All Commands in Order



```bash

cd MMU-Design-Verilog-HDL

git init

git branch -M main

git remote add origin https://github.com/YOUR\_USERNAME/MMU-Design-Verilog-HDL.git



git add .gitignore README.md

git commit -m "Initial commit: project structure and README"



git add rtl/mmu.v

git commit -m "Add MMU RTL design: address translation, page table, fault detection"



git add tb/mmu\_tb.v

git commit -m "Add testbench: 8 test cases covering valid/invalid translation and faults"



git add simulation/ waveforms/

git commit -m "Add simulation script and waveform results (Icarus Verilog + Vivado)"



git add constraints/

git commit -m "Add Vivado XDC constraints for Nexys A7 (Artix-7) implementation"



git add reports/ images/

git commit -m "Add synthesis utilization report, timing summary, and design schematics"



git add docs/

git commit -m "Add project report, interview prep, and Vivado simulation guide"



git push -u origin main

```



\---



\## Troubleshooting



| Problem | Fix |

|---|---|

| `git: command not found` | Install Git from \[git-scm.com](https://git-scm.com/downloads) |

| `remote origin already exists` | Run `git remote remove origin` then redo Step 4 |

| Push asks for password and fails | GitHub no longer accepts account passwords for HTTPS push — use a Personal Access Token instead (see Step 6) |

| `nothing to commit` on a step | You may have already staged those files in an earlier `git add .` — check with `git status` |

| Large file warning on `.bit` file | Don't commit Vivado-generated `.bit`, `.xpr`, or build folders — they're already excluded in `.gitignore` |

| Images not rendering on GitHub README | Confirm paths in README use relative paths like `images/device\_view.png`, not absolute local paths |

