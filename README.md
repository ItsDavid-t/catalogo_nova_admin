---
<p align="right">Developed with ❤️ by <b>ItsDavid-t</b> 🐢</p>

---

# 📦 Catalogo Admin

> **Enterprise-grade inventory management solution built with architectural excellence for Cuban MiPyMEs.**

<p align="left">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Clean_Architecture-black?style=for-the-badge" alt="Clean Architecture" />
</p>

---

### 💎 Value Proposition
**Catalogo Admin** is a production-ready mobile ecosystem engineered for **scalability**, data security, and real-time inventory control tailored for local hardware and spare parts businesses.

* **Modern UI:** Full **Material 3** implementation with a highly responsive design and native dark/light mode synchronization.
* **Secure Media Management:** Integrated with **Supabase Storage** buckets for optimized image delivery, enforcing secure asset paths.
* **Robust Data Architecture:** Strict data integrity barriers driven by PostgreSQL backend engines.
* **Smart Retention System:** Advanced **"Reserved"** lifecycle state for products. Instead of performing hard deletes, items undergo a soft-deletion state to prevent accidental data loss and facilitate seamless inventory auditing.

---

### 🛠️ Technical Specifications
* **Architecture:** Domain-Driven **Clean Architecture** strict separation of Data, Domain, and Presentation layers.
* **State Management:** Reactive and predictable workflow utilizing `Cubit` structures to guarantee immutable state flows.
* **Backend & Cloud Services:** `Supabase` backend implementation leveraging real-time subscriptions and managed secure authentication.
* **Dependency Injection:** Modular service management via `GetIt` service locators.
* **Error Handling:** Robust functional-oriented programming paradigm applying decoupled recovery layers for precision tracing.

---

### 📱 App Screenshots

| 🛒 Inventory Dashboard & Querying | ⚙️ Product Mutation & LifeCycle |
| :---: | :---: |
| <img src="assets/images/dashboard_full.jpeg" width="270" /><br><sub>*Main view showcasing real-time hardware data*</sub> | <img src="assets/images/add_product.jpeg" width="270" /><br><sub>*Optimized form implementation with reactive validation fields*</sub> |
| <img src="assets/images/dashboard_filtered.jpeg" width="270" /><br><sub>*Category filtering workflow handling isolated state re-renders*</sub> | <img src="assets/images/product_detail.jpeg" width="270" /><br><sub>*Material 3 Bottom Sheet displaying model relationships*</sub> |

---

### 🏗️ Project Structure
The repository strictly respects professional engineering guidelines to ensure maintenance and modular scale:

```text
├── lib
│   ├── config          # Themes, declarative routing, and global injection parameters
│   ├── data            # Remote Data Sources, Supabase models, and Repository implementations
│   ├── domain          # Pure business logic: Abstract interfaces, Use Cases, and Core Entities
│   └── presentation    # UI presentation layer: State Controllers (Cubits), screens, and design tokens
