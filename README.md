<div align="center">

# 📚 TaskNext
### Real-Time Classroom Task Management System

*A Flutter application that streamlines classroom communication by allowing teachers to assign tasks directly to students, track responses in real time, and eliminate unnecessary group message clutter.*

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

</div>

---

# 🚀 Overview

In many classrooms, teachers share assignments through WhatsApp groups. Every student replies with messages like **"Yes Ma'am"**, **"Completed"**, or **"Done"**, resulting in hundreds of unnecessary notifications and making it difficult for teachers to know who has actually completed the task.

**TaskNext** solves this problem by providing a dedicated classroom task management platform where:

- Teachers assign tasks to an entire class.
- Students receive **private notifications**.
- Students submit responses individually.
- Teachers can instantly monitor completion status.
- No unnecessary group chat messages.

The application creates a clean, organized, and distraction-free communication channel between teachers and students.

---

# ✨ Problem Statement

### Existing Workflow

```
Teacher → WhatsApp Group

Student 1 → Done
Student 2 → Yes Ma'am
Student 3 → Completed
Student 4 → Done

...
100+ Messages
```

Problems:

❌ Group notification spam

❌ Difficult to track submissions

❌ Teachers manually count responses

❌ Students get distracted by unrelated chats

---

### TaskNext Workflow

```
Teacher
      │
      ▼
Creates Task
      │
      ▼
Firebase Firestore
      │
      ▼
Push Notification
      │
      ▼
Individual Student
      │
      ▼
Student Response
      │
      ▼
Teacher Dashboard
```

Benefits:

✅ Private notifications

✅ Organized submissions

✅ Real-time updates

✅ Better classroom management

---

# 🎯 Key Features

## 👨‍🏫 Teacher Module

- Secure Login
- Create classroom tasks
- Assign deadlines
- View all assigned tasks
- Track student responses
- Monitor completion status
- View pending students
- Real-time updates

---

## 👨‍🎓 Student Module

- Secure Login
- Receive instant task notifications
- View assigned tasks
- Mark task as Completed
- Submit responses individually
- Track completed and pending tasks

---

## 🔔 Notifications

- Firebase Cloud Messaging (FCM)
- Instant push notifications
- Individual delivery
- No unnecessary group messages

---

## ⚡ Real-Time Sync

Using Firebase Firestore,

- New tasks appear instantly
- Responses update in real time
- No manual refresh required

---

# 🛠 Tech Stack

## Frontend

- Flutter
- Dart

## Backend

- Firebase

## Database

- Cloud Firestore

## Authentication

- Firebase Authentication

## Notifications

- Firebase Cloud Messaging (FCM)

---

# 📱 Screenshots

> Add your application screenshots here.

| Login | Teacher Dashboard |
|--------|-------------------|
| Image | Image |

| Student Dashboard | Task Details |
|-------------------|--------------|
| Image | Image |

---

# 📂 Project Structure

```
lib/

├── authentication/
├── models/
├── screens/
│   ├── teacher/
│   ├── student/
├── services/
├── widgets/
├── firebase/
└── main.dart
```

---

# 🔥 Architecture

```
Flutter App
      │
      ▼
Firebase Authentication
      │
      ▼
Cloud Firestore
      │
      ▼
Firebase Cloud Messaging
      │
      ▼
Real-Time Notification Delivery
```

---

# 💡 Real-World Impact

TaskNext significantly improves classroom communication by:

- Reducing unnecessary WhatsApp notifications
- Improving teacher productivity
- Making task tracking effortless
- Providing a distraction-free experience
- Encouraging organized communication

---

# 📈 Future Enhancements

- Attendance Tracking
- Assignment File Upload
- PDF Notes Sharing
- Quiz Module
- Parent Portal
- Teacher Analytics Dashboard
- Dark Mode
- Calendar Integration

---

# 📦 Installation

```bash
git clone https://github.com/varzzzzzh/tasknest.git
```

```bash
cd tasknest
```

```bash
flutter pub get
```

```bash
flutter run
```

---

# 👨‍💻 Developed By

**Varsha Ravi**

📧 Email: varshar112006@gmail.com

🔗 LinkedIn:
https://linkedin.com/in/varzzzzzh

💻 GitHub:
https://github.com/varzzzzzh

---

# ⭐ Support

If you found this project useful,

⭐ Star the repository

🍴 Fork the project

🤝 Contribute to improve it

---

> **TaskNext isn't just a classroom application—it's a smarter way for teachers and students to communicate without the noise of group chats.**
