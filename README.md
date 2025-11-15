<img src="https://github.com/FarhanAbelRantisi/NutriSight-App/issues/1#issue-3628372968" width="300" />

# 🥗 NutriSight — Smart Nutrition Scanner with Nutri-Grade System

NutriSight is a Flutter mobile application that analyzes nutrition labels using OCR + NER, then assigns a Nutri-Grade score (A–D) to packaged food products.  
With NutriSight, users can scan ingredients instantly and make more informed, healthier decisions — powered by a custom AI backend.

---

## 📱 Download APK

Pre-built APKs for testing:

- **[APK (x86_64)](https://github.com/FarhanAbelRantisi/NutriSight-App/releases/download/v0.1-release-x86_64/app-x86_64-release.apk)**
- **[APK (ARM64)](https://github.com/FarhanAbelRantisi/NutriSight-App/releases/download/v0.1-release-arm64/app-arm64-v8a-release.apk)**
- **[APK (ARM32)](https://github.com/FarhanAbelRantisi/NutriSight-App/releases/download/v0.1-release-arm32/app-armeabi-v7a-release.apk)**

---

## ⭐ Key Features

### ✔ Nutrition Label Scanning  
Automatically extract sugar, sodium, fat, and other nutrients using OCR (Google Vision) and LayoutLM.

### ✔ Nutri-Grade System (A–D)  
Grades are determined based on nutrient thresholds inspired by global health standards.

### ✔ Scan History  
All scan results are saved to Firestore and displayed in a clean, searchable UI.

### ✔ Education Module  
Built-in educational content about healthy eating and how to read labels.

### ✔ Firebase Authentication  
- Email & Password Login  
- Google Sign-In  
- Profile photo upload  
- Change email & password  
- Logout  

---

## 🧠 How the Nutri-Grade System Works

NutriSight assigns a grade using three core nutrients per 100g:

| Nutrient        | A (Low) | B (Medium) | C/D (High) |
|-----------------|---------|------------|------------|
| **Sugar**       | ≤ 5 g   | 6–12 g     | > 12 g     |
| **Sat. Fat**    | ≤ 1.5 g | 1.6–5 g    | > 5 g      |
| **Sodium**      | ≤ 120 mg| 121–400 mg | > 400 mg   |

Process used by the API:  
1. OCR extracts text  
2. LayoutLM extracts structured nutrient fields  
3. Custom grading engine assigns A–D  

---

## 🧩 Category-Specific Grading Examples

Different food categories require different classification thresholds.  
NutriSight automatically applies the correct logic depending on the **category_code** provided by the API request.

Below are simplified examples for several common product categories.

---

### 🥤 1. **Beverages (Minuman)**

| Nutrient (per 100 ml) | Grade A | Grade B | Grade C/D |
|------------------------|---------|---------|-----------|
| **Sugar**              | ≤ 2.5 g | 2.6–6 g | > 6 g     |
| **Sodium**             | ≤ 40 mg | 41–120 mg | > 120 mg |

> Beverages use stricter sugar limits because liquid sugars absorb faster into the body.

### 🍦 2. **Dairy Products (Milk, Yogurt, etc.)**

| Nutrient (per 100 g)  | Grade A | Grade B | Grade C/D |
|------------------------|---------|---------|-----------|
| **Sugar**              | ≤ 5 g   | 6–10 g  | > 10 g    |
| **Sat. Fat**           | ≤ 1.5 g | 1.6–4 g | > 4 g     |

> Dairy contains natural lactose, so sugar limits are slightly adjusted.

### 🍪 3. **Snacks & Desserts**

| Nutrient (per 100 g) | Grade A | Grade B | Grade C/D |
|-----------------------|---------|---------|-----------|
| **Sugar**             | ≤ 10 g  | 11–20 g | > 20 g    |
| **Sat. Fat**          | ≤ 2 g   | 2.1–7 g | > 7 g     |
| **Sodium**            | ≤ 150 mg| 151–400 mg | > 400 mg |

> These products focus heavily on saturated fat and sodium due to their higher density.

### 🍜 4. **Processed Foods (Instant, Frozen, Ready-to-Eat)**

| Nutrient (per 100 g) | Grade A | Grade B | Grade C/D |
|-----------------------|---------|---------|-----------|
| **Sodium**            | ≤ 200 mg| 201–600 mg | > 600 mg |
| **Sat. Fat**          | ≤ 1.5 g | 1.6–5 g | > 5 g     |

> Sodium plays a major role due to preservatives commonly used in processed foods.

### 📌 Notes

- These tables provide **simplified** versions of the rules used in NutriSight.  
- The real grading system applies **category-specific weighting** so products are judged fairly across different food types.  
- Thresholds were derived from public health guidelines, local regulations, and nutritional standards commonly used globally.

---

## 🧰 Tech Stack

### 📱 Mobile
- Flutter (Dart)
- Provider (State Management)
- Firebase Auth
- Firestore Database
- Firebase Storage

### 🤖 AI Backend (Hosted, Ready-to-Use)
- FastAPI (Python)
- Google Cloud Vision OCR  
- LayoutLM Model (HuggingFace Transformers)
- Custom grading logic  
- Deployed on Google Cloud (public API)

> **You can use the API directly—no backend setup needed for contributors.**

---

## 🌐 Public API (Ready to Use)

Developers can directly call the NutriSight backend:

### **POST https://nutrition-api-464605127931.asia-southeast2.run.app/classify-image-graded**

#### Parameters  
- `file` → Image file  
- `category_code` → Product category (01.0 - 15.0)

#### Example (cURL)
```bash
curl -X POST "https://nutrition-api-464605127931.asia-southeast2.run.app/classify-image-graded" \
-F "file=@nutrition.jpg" \
-F "category_code=01.0"
`````
#### Response contains:
- grade (A–D)
- nutrients
- extracted fields
- debugging NER results

---

### 🚀 Setup & Installation

We welcome contributions and suggestions! Follow the steps below to contribute:

1. Clone the repository

```bash
git clone https://github.com/FarhanAbelRantisi/NutriSight-App.git
cd NutriSight-App
`````

2. Install dependencies

```bash
flutter pub get
`````
3. Add Firebase Configuration

```bash
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
`````

4. Run the app

```bash
flutter run
`````

---

### 🤝 Contributing

Contributions are welcome!
You can:
- Fork the repo
- Create a feature branch
- Submit a pull request








