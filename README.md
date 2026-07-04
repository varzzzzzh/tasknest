# 📚 TaskNest — Real-Time Classroom Task Management App

<div align="center">

*A Flutter application that replaces noisy WhatsApp group chats with a dedicated system for assigning classroom tasks, notifying students individually, and tracking who's actually done — in real time.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20FCM-orange?logo=firebase)](https://firebase.google.com)

**Platforms:** Android · iOS · Web · Windows · Linux · macOS

</div>

---

## 🚀 Overview

In most classrooms, teachers share tasks and assignments through a WhatsApp group. Every student replies **"Done"**, **"Yes Ma'am"**, or **"Completed"**, which floods everyone's phone with notifications — and the teacher still has to scroll through the mess to figure out who has actually submitted anything.

**TaskNest** fixes this with a dedicated teacher–student workflow:

- Teachers assign a task once, to the whole class.
- Each student gets it as a **private, individual notification** — no group spam.
- Students respond directly in the app.
- Teachers see live, real-time completion status without asking twice.

---

## ❌ The Old Way vs ✅ The TaskNest Way

**Group chat today:**

```
Teacher → WhatsApp Group
Student 1 → Done
Student 2 → Yes Ma'am
Student 3 → Completed
...
100+ notifications, no clear tally
```

**With TaskNest:**

```
Teacher creates a task
        │
        ▼
  Cloud Firestore
        │
        ▼
Individual push notification (FCM)
        │
        ▼
   Each student
        │
        ▼
  Private response
        │
        ▼
Teacher's live dashboard (real-time)
```

---

## ✨ Key Features

**Teacher side**
- Secure login
- Create and assign classroom tasks
- Real-time view of who has responded and who hasn't
- No more manually counting group chat replies

**Student side**
- Secure login
- Instant, individual task notifications
- View assigned tasks and mark them complete
- Track your own completed vs pending tasks

**Under the hood**
- Firebase Cloud Messaging for individual (not group) push notifications
- Cloud Firestore for real-time sync — updates appear instantly, no manual refresh
- Firebase Authentication for secure teacher/student accounts

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| App framework | Flutter (Dart) |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Notifications | Firebase Cloud Messaging (FCM) |
| Supported targets | Android, iOS, Web, Windows, Linux, macOS |

---

## 🎥 Demo

A demo recording of the app in action is included in this repo:
- [`tasknestDemo.mp4`](./tasknestDemo.mp4)

*(GitHub doesn't preview video inline in the README — click through to watch, or embed a GIF/screenshot version here for a nicer preview.)*

---

## 📦 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed
- A [Firebase](https://firebase.google.com/) project

### Installation

```bash
git clone https://github.com/varzzzzzh/tasknest.git
cd tasknest
flutter pub get
flutter run
```

### Firebase Setup

This project uses `firebase.json` for configuration. To connect it to your own Firebase project:

1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication**, **Cloud Firestore**, and **Cloud Messaging**.
3. Add your platform config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
4. Run `flutterfire configure` if you want to regenerate `firebase_options.dart` for your own project.

---

## 📈 Possible Future Enhancements

- Task deadlines with reminders
- File/photo submission per task
- Teacher-side analytics on completion trends
- Dark mode
- Parent/guardian portal

---

## 👩‍💻 Author

**Varsha Ravi**
📧 varshar112006@gmail.com
🔗 [LinkedIn](https://linkedin.com/in/varzzzzzh) · 💻 [GitHub](https://github.com/varzzzzzh) · 🧩 [LeetCode](https://leetcode.com/u/Varshar111)

---

## ⭐ Support

If this project is useful to you, consider starring ⭐ the repo — it helps others find it too.

---

> **TaskNest — a smarter way for teachers and students to communicate, without the noise of group chats.**
