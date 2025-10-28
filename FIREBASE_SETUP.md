# Firebase Setup Guide for KinKeeper App

## 🚀 Quick Setup

### 1. Firebase Project Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing project
3. Add Android app with package name: `com.example.kinkeeper`
4. Download `google-services.json` and place it in `android/app/`

### 2. Enable Firebase Services

#### Authentication
1. Go to Authentication → Sign-in method
2. Enable **Email/Password** provider
3. Optionally enable **Google** sign-in for easier access

#### Firestore Database
1. Go to Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a location (choose closest to your users)

#### Storage (Optional)
1. Go to Storage
2. Click "Get started"
3. Choose "Start in test mode" for development

### 3. Update Firebase Configuration

✅ **Firebase Configuration Complete!**

Your Firebase project is already configured with:
- **Project ID**: `kinkeeper-2f63b`
- **API Key**: `AIzaSyDGR5cMlD271uFVhE5ph_E-jg6qnZw0h3E`
- **App ID**: `1:507189889883:android:318ea989d5a209ec53687e`
- **Package Name**: `com.example.kinkeeper.kinkeeperapp`

The `firebase_options.dart` and `google-services.json` files are already configured with your project details.

## 📊 Database Schema

### Collections Structure

```
📁 Firestore Database
├── 📁 users (Collection)
│   └── 📄 {userId} (Document)
│       ├── name: string
│       ├── email: string
│       ├── familyId: string
│       ├── profilePic: string (optional)
│       ├── joinedAt: timestamp
│       └── role: string ("parent" | "child")
│
├── 📁 families (Collection)
│   └── 📄 {familyId} (Document)
│       ├── familyName: string
│       ├── createdBy: string (userId)
│       ├── members: array<string> (userIds)
│       ├── createdAt: timestamp
│       └── description: string (optional)
│
└── 📁 tasks (Collection)
    └── 📄 {taskId} (Document)
        ├── title: string
        ├── description: string
        ├── priority: string ("High" | "Medium" | "Low")
        ├── assignedTo: string (userId)
        ├── assignedBy: string (userId)
        ├── familyId: string
        ├── status: string ("Pending" | "In Progress" | "Completed")
        ├── createdAt: timestamp
        ├── updatedAt: timestamp
        └── notes: string (optional)
```

### Security Rules

Add these Firestore security rules in Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Family members can read family data
    match /families/{familyId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.members;
      allow write: if request.auth != null && 
        request.auth.uid in resource.data.members;
    }
    
    // Family members can read/write tasks for their family
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/families/$(resource.data.familyId)).data.members;
    }
  }
}
```

## 🔧 Installation Commands

Run these commands in your project directory:

```bash
# Install dependencies
flutter pub get

# For Android
flutter build apk

# For iOS (if needed)
flutter build ios
```

## 📱 App Features

### ✅ Implemented Features

1. **Authentication**
   - Email/Password sign up and login
   - User role management (Parent/Child)
   - Secure authentication flow

2. **Family Management**
   - Create family with unique Family ID
   - Join existing family using Family ID
   - View all family members
   - Role-based access control

3. **Task Management**
   - Create tasks with title, description, priority
   - Assign tasks to family members
   - Track task status (Pending → In Progress → Completed)
   - Real-time task updates
   - Task filtering by status

4. **Profile & History**
   - User profile with statistics
   - Task history and completion tracking
   - Personal task management

5. **UI/UX**
   - Modern Material Design 3
   - Responsive layout
   - Intuitive navigation
   - Real-time updates

### 🚀 Future Enhancements

- Push notifications for task assignments
- Task due dates and reminders
- Photo attachments for completed tasks
- Family chat functionality
- Task categories and tags
- Advanced analytics and reporting
- Offline support
- Multi-language support

## 🐛 Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `google-services.json` is in `android/app/`
   - Check Firebase configuration in `firebase_options.dart`

2. **Authentication errors**
   - Verify Email/Password is enabled in Firebase Console
   - Check security rules

3. **Database permission errors**
   - Update Firestore security rules
   - Ensure user is authenticated

4. **Build errors**
   - Run `flutter clean && flutter pub get`
   - Check Android SDK version compatibility

### Debug Mode

Enable debug logging by adding this to your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enable debug logging
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const KinKeeperApp());
}
```

## 📞 Support

For issues or questions:
1. Check Firebase Console for error logs
2. Review Flutter debug console
3. Verify network connectivity
4. Check device permissions

---

**Happy Task Managing! 🏠✨**

