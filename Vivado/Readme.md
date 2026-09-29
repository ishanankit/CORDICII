# CORDIC Shift Vivado FPGA Design

This repository contains the Verilog RTL source files and a fully archived Vivado project for the **CORDIC Shift** design.

---

## 📁 Repository Structure

```text
Vivado/
├── .gitignore
├── Readme.md
├── cordic1.v            # CORDIC 1st stage
├── cordic2.v            # CORDIC 2nd stage
├── cordicshiftfinal.xpr.zip # Complete Vivado archived project zip
├── friend.v             # friend rotation stage
├── nano.v               # nanorotation stage
├── top.v                # Top-level module integrating sub-components
├── trivial.v            # trivial stage
└── usr.v                # USR stage
```

---

## 🚀 How to Recreate & Run the Project in Vivado

You can recreate the complete project setup either by unzipping the archived project or by importing the raw HDL source files into a new Vivado project.

### Method 1: Using the Archived Project (Recommended)

1. **Extract the Archive:**
   Unzip `cordicshiftfinal.xpr.zip` to your preferred workspace directory.
   
2. **Open in Vivado:**
   - Launch **AMD/Xilinx Vivado**.
   - Select **File** $\rightarrow$ **Project** $\rightarrow$ **Open...**
   - Navigate to the unzipped directory and select the `.xpr` project file.

3. **Run Synthesis & Implementation:**
   - In the **Flow Navigator** panel, click **Run Synthesis**.
   - Once synthesis completes, click **Run Implementation**.
   - Click **Generate Bitstream** to produce the final hardware binary file.

---

### Method 2: Rebuilding from Raw Verilog Sources

If you prefer to create a clean project from scratch:

1. Launch Vivado and click **Create Project**.
2. Set your project name and directory, then choose **RTL Project**.
3. In the **Add Sources** step:
   - Click **Add Files** and select all `.v` files (`top.v`, `cordic1.v`, `cordic2.v`, `friend.v`, `nano.v`, `trivial.v`, `usr.v`).
   - Set `top.v` as the **Top-level module**.
4. Select your target FPGA board or specific target part number.
5. Click **Finish** to build the project workspace.

---

## ⚙️ Prerequisites

* **Software:** AMD/Xilinx Vivado Design Suite (2025).
* **Language:** Verilog HDL (IEEE 1364 standard).
