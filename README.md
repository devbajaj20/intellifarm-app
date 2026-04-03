# 🌾 IntelliFarm
### AI-Powered Smart Agriculture System (ML + DL + Flutter + Flask)

---

## 📌 Overview

IntelliFarm is a **full-stack AI-based agricultural assistance system** that integrates:

- Machine Learning (Crop + Fertilizer Prediction)
- Deep Learning (Plant Disease Detection)
- Flask Backend APIs
- Flutter Mobile Application
- Firebase Cloud Services

It provides farmers with **real-time, data-driven recommendations** through a unified platform.

---

## 🚀 Features

### 🌱 Crop Recommendation
Predict best crop using:
- N, P, K values
- pH
- Temperature, Humidity, Rainfall

### 🧪 Fertilizer Recommendation
- Detect nutrient deficiencies
- Suggest optimal fertilizer

### 🌿 Disease Detection
- Upload leaf image
- CNN predicts disease

### 🤖 AI Chatbot
- Agriculture guidance
- Query-based assistance

### 🛒 Marketplace
- Farmers sell products directly

---

## 🏗️ Complete Tech Stack

### 📱 Frontend (Mobile)
- Flutter
- Dart

### 🔥 Cloud
- Firebase Authentication
- Firebase Firestore

### 💻 Backend
- Flask (REST API)
- Python

### 🧠 ML Models
- Random Forest (primary)
- Decision Tree
- SVM
- KNN

### 🧠 Deep Learning
- CNN (TensorFlow/Keras)

### 📊 Libraries
- Pandas
- NumPy
- Scikit-learn
- Matplotlib

---
## 📂 Project Structure

```bash
IntelliFarm/
│
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── routes.py            # All API routes
│   │   ├── predict.py           # Prediction logic
│   │   ├── utils.py             # Helper functions
│   │
│   ├── models/
│   │   ├── crop_model.pkl
│   │   ├── fertilizer_model.pkl
│   │   ├── yield_model.pkl
│   │   ├── disease_model.h5
│   │
│   ├── encoders/
│   │   ├── soil_encoder.pkl
│   │   ├── crop_encoder.pkl
│   │   ├── fertilizer_encoder.pkl
│   │
│   ├── data/
│   │   ├── crop_dataset.csv
│   │   ├── fertilizer_dataset.csv
│   │
│   ├── training/
│   │   ├── train_crop_model.py
│   │   ├── train_fertilizer_model.py
│   │   ├── train_disease_model.py
│   │
│   ├── requirements.txt
│   ├── run.py                   # Entry point
│
├── mobile_app/
│   ├── lib/
│   │   ├── main.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── crop_screen.dart
│   │   │   ├── fertilizer_screen.dart
│   │   │   ├── disease_screen.dart
│   │   │   ├── chatbot_screen.dart
│   │   │
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   ├── firebase_service.dart
│   │   │
│   │   ├── models/
│   │   │   ├── prediction_model.dart
│   │   │
│   │   ├── widgets/
│   │       ├── custom_card.dart
│
│   ├── pubspec.yaml
│
└── README.md
```
---

## 🔗 Backend Repository

The backend API for this project is hosted separately:

👉 https://github.com/devbajaj20/intellifarm-backend


## ⚙️ Backend Setup

```bash
cd backend

python -m venv venv
venv\Scripts\activate

pip install -r requirements.txt
python run.py


