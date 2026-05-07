---
<p align="right">Developed with ❤️ by <b>ItsDavid-t</b> 🐢</p>

---





# 📦 Echo Stock

> **Enterprise-grade inventory management solution built with architectural excellence.**

<p align="left">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi" />
  <img src="https://img.shields.io/badge/Clean_Architecture-black?style=for-the-badge" />
</p>

---

### 📱 Preview
<<<<<<< HEAD
| Main Dashboard | Stock Management | Analytics / Dark Mode |
| :---: | :---: | :---: |
| ![Dashboard](./assets/dashboard.png) | ![Management](./assets/management.png) | ![Dark Mode](./assets/dark_mode.png) |
=======
| Main Dashboard | Navigation Drawer | Add Product Form |
| :---: | :---: | :---: |
| ![Dashboard](./assets/cap1.png) | ![Drawer](./assets/cap2.png) | ![Form](./assets/cap3.png) |
>>>>>>> 1ae6d97a12713c65dbde10e240c922e16ff95f3c

---

### 💎 Value Proposition
Echo Stock is more than a simple CRUD; it is an ecosystem engineered for **scalability**.
*   **Modern UI:** Full **Material 3** implementation with native multi-theme support.
*   **Performance:** Reactive logic designed to minimize resource consumption on mobile devices.
*   **Maintainability:** Modular codebase allowing new features without breaking existing core logic.
*   **Smart Retention:** Built-in "Reserved" status for products to prevent accidental data loss.

---

### 🛠️ Technical Specifications
*   **State Management:** `Cubit` & `BLoC` for a predictable data flow.
*   **Backend:** `FastAPI` powered by a `PostgreSQL` relational database.
*   **Dependency Injection:** `GetIt` for total decoupling of services.
*   **Error Handling:** Functional programming approach using the `Either` pattern.

---

### 🏗️ Project Structure
Following strict **Clean Architecture** principles:
```text
── lib
│   ├── config          # Themes and Global Configuration
│   ├── data            # Repositories Impl & Data Sources
│   ├── domain          # Entities, Use Cases & Repository Interfaces
│   └── presentation    # UI Logic (Cubits), Screens & Widgets
