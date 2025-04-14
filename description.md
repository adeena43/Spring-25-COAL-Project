# Matrix Calculator - Assembly Language Project

![Assembly Language](https://img.shields.io/badge/Language-Assembly-%237E4DD2) 
![MASM32](https://img.shields.io/badge/Framework-MASM32-%2300599C)

## 📖 Introduction
A console-based matrix calculator implemented in Assembly Language (MASM32) to perform fundamental and advanced matrix operations efficiently. Designed for educational purposes to demonstrate low-level programming concepts and numerical computations.

---

## 🛠️ Technology Stack
- **Programming Language**: MASM32 Assembly
- **Development Environment**: MASM32 SDK
- **Interface**: Console-based application

---

## ✨ Key Features

### Basic Operations
- ➕ Matrix Addition 
- ➖ Matrix Subtraction 
- ✖️ Matrix Multiplication 
- ➗ Matrix Division (via inverse multiplication)

### Advanced Operations (2×2 & 3×3 Only)
- 🔄 Matrix Transpose
- 🧮 Determinant Calculation
- 📐 Adjoint Matrix
- ⚙️ Matrix Inverse (non-singular matrices only)

### General Features
- 🖥️ Dynamic input handling for user-defined matrix sizes
- ❌ Robust error handling for invalid inputs
- 🧠 Optimized memory management for large matrices

---

## 🏗️ Design Approach
- **Modular Structure**:  
  Each operation (addition, subtraction, etc.) is implemented as an independent subroutine.
- **Memory Management**:  
  Matrix elements stored in MASM32 arrays with heap allocation.
- **I/O Handling**:  
  Console-based input with structured output formatting.

---

## 🚧 Challenges & Solutions
| Challenge | Solution |
|-----------|----------|
| Matrix Division | Implemented via multiplication with the inverse matrix |
| 3×3 Determinant | Cofactor expansion method |
| Large Matrices | Optimized memory allocation using MASM32 heap functions |

---

## 🔮 Future Enhancements
- 🖼️ GUI implementation for better UX
- 🔢 Support for 4×4 and larger matrices
- 🔍 Eigenvalue/eigenvector computations
- 📁 File I/O for matrix storage

---

## 👥 Group Members
- Adina Faraz (23K-0008)
- Syed Muneeb Ur Rehman (23K-0038)

---

## 📜 Conclusion
This project demonstrates efficient numerical computation in low-level assembly language while providing essential matrix operations. It serves as an educational tool for understanding both assembly programming and linear algebra concepts.

*Instructor: Mr. Ubaidullah | Section: BS-Al 4A*
