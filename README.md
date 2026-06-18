[//]: # (# traffic_quiz)

[//]: # (# Cambodia Traffic Law Quiz &#40;Assignment 2&#41;)

[//]: # ()
[//]: # (A Flutter-based quiz application designed to help users learn and test their knowledge of Cambodian traffic laws.)

[//]: # ()
[//]: # (## 🚀 How to Run the Assignment)

[//]: # ()
[//]: # (Because this assignment is part of a larger Flutter project, follow these steps to run it:)

[//]: # ()
[//]: # (### 1. Prerequisites)

[//]: # (* Ensure you have the [Flutter SDK]&#40;https://docs.flutter.dev/get-started/install&#41; installed.)

[//]: # (* Ensure you have an Android Emulator, iOS Simulator, or a physical device connected.)

[//]: # ()
[//]: # (### 2. Setup)

[//]: # (Clone the repository and navigate to the project folder: git clone <REPOSITORY_URL> cd to your project)

[//]: # ()
[//]: # ()
[//]: # ()
[//]: # (### 3. Install Dependencies)

[//]: # (Run this command to download the required packages: flutter pub get)

[//]: # ()
[//]: # ()
[//]: # (### 4. Running the Specific Assignment)

[//]: # (Since the assignment is located in `lib/assignment2/main.dart`, you must point Flutter to that specific file to run it as a standalone app: flutter run lib/assignment2/main.dart)

# 🌿 Herbalife App

A full-stack mobile application for managing Herbalife memberships, products, and payments.

Built with **Flutter** (frontend) and **Node.js/Express** (backend).

---

## 📱 Features

- Member registration & login (JWT authentication)
- Product listing & shopping cart
- KHQR payment integration
- Member points & position tracking
- Profile photo upload (Cloudinary)
- Khmer & English language support

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter (Dart) |
| Backend | Node.js + Express |
| Database | MySQL 8.0 |
| Auth | JWT |
| Media | Cloudinary |
| Payment | KHQR |

---

## ⚙️ Prerequisites

Make sure you have these installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Node.js](https://nodejs.org/) (v18+)
- [MySQL 8.0](https://dev.mysql.com/downloads/)
- A [Cloudinary](https://cloudinary.com) account

---

## 🚀 Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/Phanuth25/herbalife.git
cd herbalife
```

### 2. Set up the database
- Create a MySQL database named `herbalife`
- Import the schema:
```bash
mysql -u root -p herbalife < schema.sql
```

### 3. Configure the backend
```bash
cd lib/herbalife/private
cp .env.example .env
```
Fill in your values in `.env`:
<<<<<<< HEAD
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=herbalife
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
JWT_SECRET=any_long_random_string
```
=======

>>>>>>> ver2
### 4. Start the backend
```bash
cd lib/herbalife
npm install
node server.js
```
Server runs on `http://localhost:3000`

### 5. Configure Flutter
Open `lib/herbalife/public/provider/auth_provider.dart` and change line 13:
```dart
final String _accounturl = "http://10.0.2.2:3000/api";
```
Replace `10.0.2.2` with your machine's IP address.
To find your IP run `ipconfig` in terminal and look for **IPv4 Address**.

### 6. Run the Flutter app
```bash
flutter pub get
flutter run
```

---

<<<<<<< HEAD
## 📁 Project Structure
```
lib/herbalife/
├── main.dart                 # Flutter app entry point
├── server.js                 # Node.js backend entry point
├── package.json              # Node.js dependencies
├── package-lock.json
├── schema.sql                # Database schema
├── l10n/                     # Localization (English & Khmer)
├── private/                  # Backend logic
│   ├── controller/           # API route handlers
│   ├── model/                # Database connection
│   └── .env.example          # Environment variable template
└── public/                   # Flutter frontend
    ├── constants/            # API URLs and app constants
    ├── page/                 # Screens
    ├── provider/             # State management
    ├── model/                # Data models
    └── widget/               # Reusable widgets
```
=======
## 📁 Project Structure
>>>>>>> ver2