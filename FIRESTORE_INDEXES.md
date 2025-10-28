# Firestore Index Setup Instructions

## 🔥 Required Firestore Indexes

To optimize query performance, you need to create the following composite indexes in your Firebase Console.

### 📍 How to Create Indexes:

1. Go to [Firebase Console](https://console.firebase.google.com/project/kinkeeper-2f63b)
2. Navigate to **Firestore Database** → **Indexes**
3. Click **"Create Index"**
4. Create the following indexes:

### 📋 Index 1: Tasks by Family and Status
- **Collection ID**: `tasks`
- **Fields**:
  - `familyId` (Ascending)
  - `status` (Ascending)
  - `createdAt` (Descending)

### 📋 Index 2: Tasks by Family and Created Date
- **Collection ID**: `tasks`
- **Fields**:
  - `familyId` (Ascending)
  - `createdAt` (Descending)

### 📋 Index 3: Tasks by User and Created Date
- **Collection ID**: `tasks`
- **Fields**:
  - `assignedTo` (Ascending)
  - `createdAt` (Descending)

## ⚡ Quick Fix (Temporary)

The app has been updated to work without these indexes by sorting data in the application code instead of using Firestore's `orderBy()`. This means:

- ✅ **Tasks will load immediately** without waiting for indexes
- ✅ **No more "index required" errors**
- ⚠️ **Slightly slower performance** for large datasets (but fine for family use)

## 🚀 Performance Optimization

Once you create the indexes above, you can update the queries back to use Firestore's native ordering for better performance:

```dart
// After indexes are created, you can use:
.orderBy('createdAt', descending: true)
```

## 📊 Current Status

- ✅ **App works without indexes** (temporary solution)
- ⏳ **Indexes recommended** for production use
- 🔄 **Automatic sorting** in app code (works for small-medium datasets)

---

**Note**: The app will work perfectly fine without these indexes for typical family use (10-100 tasks). The indexes are only needed for very large datasets or if you want optimal performance.
