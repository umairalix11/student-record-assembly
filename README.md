# Student Record Management System (x86 Assembly)

A low-level Student Record Management System developed in **x86 Assembly Language** using the **NASM compiler** and executed inside the **DOSBox emulator**.

This project demonstrates low-level memory management, custom array manipulations, and direct hardware interaction without relying on high-level language wrappers.

## 🧠 Key Technical Features

*   **Parallel Array Matrix Architecture:** Managed data storage efficiently by maintaining multiple synchronized arrays in memory to handle structured student records dynamically.
*   **Shift-Left Deletion Logic:** Implemented custom low-level deletion mechanics. When a record is deleted, the system manually shifts all subsequent memory blocks to the left to maintain data integrity and optimize space.
*   **Direct Text-Mode Graphics & Menu:** Built an interactive Command Line Interface (CLI) menu using BIOS interrupts for data input, validation, and structured output display.

## 🛠️ System Requirements & Tools

*   **Processor Architecture:** x86 (16-bit Real Mode)
*   **Compiler:** NASM (Netwide Assembler)
*   **Emulator:** DOSBox

## 🚀 How to Run the Project

1. Open **DOSBox** and mount your project directory.
2. Compile the assembly file using NASM:
```bash
   nasm -f bin project.asm -o project.com
