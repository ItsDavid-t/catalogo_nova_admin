---
<p align="right">Developed with ❤️ by <b>ItsDavid-t</b> 🐢</p>

---

# 📦 Catalogo Admin

> **Enterprise-grade inventory management solution built with architectural excellence.**

<p align="left">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" />
  <img src="https://img.shields.io/badge/Clean_Architecture-black?style=for-the-badge" />
</p>

---

### 💎 Value Proposition
**Catalogo Admin** is an ecosystem engineered for **scalability**, security, and real-time inventory control.

*   **Modern UI:** Full **Material 3** implementation with native light/dark theme support.
*   **Secure Media Management:** Integrated with **Supabase Storage** for optimized image handling via Row Level Security (RLS).
*   **Robust Data Architecture:** Critical information protection using **RLS** at the database level to ensure data integrity.
*   **Smart Retention:** Built-in **"Reserved"** status for products, preventing accidental data loss and allowing for seamless item recovery.

---

### 🛠️ Technical Specifications
*   **Architecture:** Strict **Clean Architecture** (Decoupling of Data, Domain, and Presentation layers).
*   **State Management:** `Cubit` & `BLoC` for a predictable and reactive data flow.
*   **Backend & Cloud:** `Supabase` (PostgreSQL) providing secure authentication and cloud storage.
*   **Dependency Injection:** `GetIt` for efficient and modular service management.
*   **Error Handling:** Functional programming approach using the `Either` pattern for precise debugging.

---

### 🏗️ Project Structure
The project follows professional engineering standards to guarantee long-term maintainability:

```text
── lib
│   ├── config          # Themes, routes, and global configurations
│   ├── data            # Repository implementations and Data Sources (Supabase)
│   ├── domain          # Business entities, Use Cases, and Repository interfaces
│   └── presentation    # UI Logic (Cubits), Screens, and Atomic Components
