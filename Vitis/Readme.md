# CORDIC Calculation Vitis Embedded Software & Hardware Platform

This repository contains the exported **AMD/Xilinx Vitis Workspace Archive** containing both the **Hardware Platform (`.xsa` / platform project)** and the **Application Project** used to run CORDIC algorithm calculations and stream output results back to the host computer.

---

## 📁 Workspace Contents

```
Vitis/
├── Readme.md
└── vitis_cordic_workspace.zip   # Full exported Vitis workspace archive (Platform + App)
```

The archived zip file (`vitis_cordic_workspace.zip`) includes:
1. **Hardware Platform Project:** Contains board support packages (BSP), processor initialization, and hardware platform definition exported from Vivado.
2. **Application Project (`CORDIC_App`):** Contains the application C/C++ source code, drivers, standard libraries, and linker script (`lscript.ld`) targeting the processing system.

---

## 🚀 How to Import and Recreate the Workspace

### Method 1: Using Vitis Unified IDE (2023.1+)

1. **Launch Vitis Unified IDE.**
2. In the top menu, select **File** $\rightarrow$ **Import...**
3. Choose **Vitis Component / Workspace Archive** and browse to select `vitis_cordic_workspace.zip`.
4. Choose or create a target workspace folder and click **Next**.
5. Review the imported Platform and Application components, then click **Finish**.
6. Right-click the Application component in the Vitis Explorer and select **Build**.

---

### Method 2: Using Vitis Classic (Eclipse-based, 2020.1 – 2022.2)

1. Launch **Vitis Classic IDE** with a new, clean workspace folder.
2. Select **File** $\rightarrow$ **Import...**
3. Expand the **General** folder, select **Existing Projects into Workspace**, and click **Next**.
4. Check the radio button for **Select archive file** and point it to `vitis_cordic_workspace.zip`.
5. Ensure both the **Platform Project** and **Application Project** checkboxes are selected.
6. Click **Finish**.
7. Right-click the application project and click **Build Project**.

---

## 🖥️ How to Run & View Results on Computer

To view the CORDIC calculation results directly on your computer:

### 1. Hardware Connections
1. Connect your target FPGA board to your computer using a USB-UART / Micro-USB cable.
2. Ensure the board is powered on and connected via JTAG/USB.

### 2. Configure Serial Terminal
Open a serial terminal application on your PC (such as **Tera Term**, **PuTTY**, or the built-in **Vitis Serial Terminal**) with these settings:
* **Baud Rate:** `115200`
* **Data Bits:** `8`
* **Parity:** `None`
* **Stop Bits:** `1`
* **Flow Control:** `None`

### 3. Launch Application
1. In Vitis, right-click the application project.
2. Select **Run As** $\rightarrow$ **1 Launch Hardware (Single Application Debug)**.
3. The executable (`.elf`) will download to the board and begin execution.
4. CORDIC sine/cosine calculations, angle inputs, and execution logs will stream directly to your terminal window.

---

## ⚙️ Requirements

* **Software:** AMD/Xilinx Vitis Unified Software Platform
* **Target Hardware:** Supported FPGA board with UART serial interface configured
* **Drivers:** FTDI / USB-to-UART bridge drivers installed on the host machine
