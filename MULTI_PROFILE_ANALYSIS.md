# Multi-Profile Support - Analysis & Implementation Plan

## 📋 Requirement Analysis

**User Request**: Support multiple user profiles where users can:
- Add multiple accounts (username/password combinations)
- Switch between profiles seamlessly
- Each profile maintains separate data/sessions

## 🔍 Current Architecture Analysis

### **Authentication Flow**
```
Login Screen → Credentials → Backend API → User Object → SharedPreferences
                                                              ↓
                                              Single Key: "USER" (kUserPrefs)
```

**Key Components**:
1. **lib/model/user.dart** - User model with session management
2. **lib/controller/login.dart** - Login screen with biometric support
3. **lib/utils/network.dart** - Login API call
4. **SharedPreferences** - Stores single user JSON under key `"USER"`
5. **lib/data/local/offline_database.dart** - SQLite for offline data (NOT user-specific)

### **Current Limitations**
❌ **Single User Storage**: Only one user can be stored at a time
```dart
final String kUserPrefs = "USER";  // Hardcoded single key
saveUser() async {
  prefs.setString(kUserPrefs, responseJSON);  // Overwrites previous user
}
```

❌ **Shared SQLite Database**: All offline data in one database
- No user_id column in most tables
- No data isolation between users
- Switching users would show previous user's cached data

❌ **No Profile Management UI**: No way to:
- View saved profiles
- Add new profiles
- Switch between profiles
- Delete profiles

## ✅ Feasibility Assessment

**Yes, it's possible!** But requires significant architectural changes.

### **Complexity Level**: ⭐⭐⭐⭐ (Medium-High)

**Reasons**:
1. ✅ **Authentication is flexible** - Backend supports multiple logins
2. ⚠️ **Data isolation needed** - Offline database must be partitioned
3. ⚠️ **Session management** - Each profile needs separate token
4. ⚠️ **Biometric per profile** - Credentials storage per user
5. ⚠️ **UI/UX changes** - Profile switcher, account manager

## 🏗️ Implementation Plan

### **Phase 1: Profile Storage Layer** (3-4 hours)

#### 1.1 Create Profile Manager
**New File**: `lib/utils/profile_manager.dart`

```dart
class UserProfile {
  final String id;            // Unique ID (username or user_id)
  final String username;
  final String displayName;
  final String userType;
  final DateTime lastLogin;
  final String sessionData;   // Full User JSON
  final bool isPinned;
  
  // Biometric credentials (if enabled)
  final bool hasBiometric;
}

class ProfileManager {
  static const String _kProfilesKey = "USER_PROFILES";
  static const String _kActiveProfileKey = "ACTIVE_PROFILE_ID";
  
  // Get all saved profiles
  Future<List<UserProfile>> getAllProfiles();
  
  // Get active profile
  Future<UserProfile?> getActiveProfile();
  
  // Switch to different profile
  Future<void> switchProfile(String profileId);
  
  // Add new profile after login
  Future<void> addProfile(User user);
  
  // Remove profile
  Future<void> removeProfile(String profileId);
  
  // Update profile data
  Future<void> updateProfile(String profileId, User user);
}
```

**Storage Strategy**:
```
SharedPreferences:
  "USER_PROFILES" → JSON array of UserProfile objects
  "ACTIVE_PROFILE_ID" → Current profile ID
  "PROFILE_{userId}_SESSION" → User session JSON
  "PROFILE_{userId}_BIOMETRIC_ENABLED" → bool
```

#### 1.2 Update User Model
**File**: `lib/model/user.dart`

**Changes**:
```dart
// OLD (single user)
static const String kUserPrefs = "USER";

// NEW (multi-profile aware)
static String _getProfileKey(String userId) => "PROFILE_${userId}_SESSION";
static const String _kLegacyKey = "USER";  // Migration support

saveUser(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(_getProfileKey(userId), responseJSON);
  
  // Also save to ProfileManager
  await ProfileManager.instance.addProfile(this);
}

removeUser(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(_getProfileKey(userId));
  
  // Remove from ProfileManager
  await ProfileManager.instance.removeProfile(userId);
}
```

### **Phase 2: Database Isolation** (4-5 hours)

#### 2.1 User-Specific Databases

**Option A: Separate Database per User** (Recommended)
```dart
class OfflineDatabase {
  static OfflineDatabase? _instance;
  static String? _currentUserId;
  
  static OfflineDatabase getInstance(String userId) {
    if (_instance == null || _currentUserId != userId) {
      _currentUserId = userId;
      _instance = OfflineDatabase._internal(userId);
    }
    return _instance!;
  }
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    // Separate DB file per user
    final dbPath = join(path, 'offline_${_currentUserId}.db');
    return await openDatabase(dbPath, version: _dbVersion, onCreate: _onCreate);
  }
}
```

**Benefits**:
- ✅ Complete data isolation
- ✅ Easy to clear user data (delete file)
- ✅ Simple implementation
- ⚠️ Multiple DB files to manage

**Option B: Single Database with user_id Column**
```sql
ALTER TABLE work_orders ADD COLUMN user_id TEXT;
ALTER TABLE ppm_sections ADD COLUMN user_id TEXT;
-- ... for all tables
```

**Benefits**:
- ✅ Single database file
- ⚠️ Complex queries (always filter by user_id)
- ⚠️ Migration nightmare (add user_id to 20+ tables)
- ⚠️ Risk of data leakage if filter missed

**Recommendation**: **Option A** (Separate databases)

#### 2.2 Update Repository Pattern

**All repositories need user context**:

```dart
// OLD
class PPMRepository {
  final OfflineDatabase _database = OfflineDatabase.instance;
}

// NEW
class PPMRepository {
  final String _userId;
  late final OfflineDatabase _database;
  
  PPMRepository(this._userId) {
    _database = OfflineDatabase.getInstance(_userId);
  }
}
```

### **Phase 3: UI/UX Changes** (3-4 hours)

#### 3.1 Login Screen Enhancement

**Add "Account Switcher"**:
```dart
// Show saved profiles above login form
ListView.builder(
  itemCount: profiles.length,
  itemBuilder: (context, index) {
    final profile = profiles[index];
    return ProfileTile(
      profile: profile,
      onTap: () => _quickLogin(profile),  // Biometric login if enabled
      onRemove: () => _removeProfile(profile),
    );
  },
)

// Add "Login as different user" button
```

#### 3.2 Profile Management Screen

**New File**: `lib/controller/profile_manager_screen.dart`

**Features**:
- List all saved profiles
- Set primary/default profile
- Enable/disable biometric per profile
- Remove profiles
- View last login time
- Storage usage per profile

#### 3.3 Quick Profile Switcher

**Add to Drawer** (`lib/view/drawer.dart`):
```dart
// At top of drawer
ProfileSwitcher(
  currentProfile: currentUser,
  onSwitch: (profile) async {
    await _switchToProfile(profile);
    Navigator.of(context).pushReplacementNamed("/homepage");
  },
)
```

### **Phase 4: Biometric Integration** (2-3 hours)

#### 4.1 Per-Profile Credentials

**Update**: `lib/utils/auth_secure_storage.dart`

```dart
// OLD
Future<void> saveBiometricCredentials(String username, String password);

// NEW
Future<void> saveBiometricCredentials(String userId, String username, String password);
Future<Map<String, String>?> getBiometricCredentials(String userId);
```

**Storage Keys**:
```
"biometric_user_{userId}" → username
"biometric_pass_{userId}" → password
```

#### 4.2 Biometric Login Flow

```dart
// Quick switch with biometric
Future<void> _quickLoginWithBiometric(UserProfile profile) async {
  final authenticated = await _localAuth.authenticate(...);
  if (!authenticated) return;
  
  final credentials = await AuthSecureStorage.getBiometricCredentials(profile.id);
  final user = await login(credentials['username']!, credentials['password']!);
  
  await ProfileManager.instance.switchProfile(profile.id);
  Navigator.pushReplacementNamed("/homepage");
}
```

### **Phase 5: Migration & Testing** (2-3 hours)

#### 5.1 Migrate Existing Users

```dart
Future<void> migrateLegacyUser() async {
  final prefs = await SharedPreferences.getInstance();
  final legacyData = prefs.getString("USER");
  
  if (legacyData != null) {
    final user = User.fromMap(legacyData);
    
    // Move to new profile system
    await ProfileManager.instance.addProfile(user);
    await ProfileManager.instance.switchProfile(user.id);
    
    // Keep legacy key for now (backwards compatibility)
    // prefs.remove("USER");  // Remove after testing
  }
}
```

#### 5.2 Testing Checklist

- [ ] Login with profile A
- [ ] Download offline data for profile A
- [ ] Switch to profile B
- [ ] Verify profile A's data not visible
- [ ] Download offline data for profile B
- [ ] Switch back to profile A
- [ ] Verify profile A's data restored
- [ ] Remove profile B
- [ ] Verify profile B's database deleted
- [ ] Test biometric login per profile
- [ ] Test logout removes only active profile

## 📊 Effort Estimation

| Phase | Tasks | Time | Priority |
|-------|-------|------|----------|
| 1. Profile Storage | ProfileManager, User model update | 3-4h | HIGH |
| 2. Database Isolation | Separate DBs, Repository updates | 4-5h | HIGH |
| 3. UI/UX | Login screen, Profile manager, Switcher | 3-4h | MEDIUM |
| 4. Biometric | Per-profile credentials | 2-3h | MEDIUM |
| 5. Migration | Legacy migration, Testing | 2-3h | HIGH |
| **TOTAL** | | **14-19 hours** | |

## 🚨 Risks & Challenges

### **1. Data Isolation**
**Risk**: User A sees User B's offline data
**Mitigation**: Separate database files per user + thorough testing

### **2. Storage Space**
**Risk**: Multiple profiles = multiple offline databases
**Solution**: Add storage management UI, limit profiles (e.g., max 5)

### **3. Migration Complexity**
**Risk**: Existing users lose data
**Mitigation**: Keep legacy "USER" key, gradual migration

### **4. Session Conflicts**
**Risk**: Switching profiles while tasks are syncing
**Mitigation**: Cancel pending operations before switch

### **5. Biometric Security**
**Risk**: Someone switches profiles and accesses without re-auth
**Mitigation**: Require biometric/password confirmation before switch

## 🎯 Recommended Approach

### **Minimal Viable Product (MVP)** - ~8 hours

**Scope**:
1. ✅ Store multiple profiles in SharedPreferences
2. ✅ Profile switcher in login screen
3. ✅ Separate offline databases per user
4. ✅ Update User model for multi-profile
5. ✅ Basic migration for existing users
6. ❌ Skip biometric per profile (use current implementation)
7. ❌ Skip profile management screen (basic switcher only)

**What Users Get**:
- Can add multiple accounts
- Quick switch from login screen
- Each profile's data is isolated
- Last used profile auto-loads

### **Full Implementation** - ~16 hours

**Additional Features**:
- Profile management screen
- Biometric per profile
- Profile avatars/colors
- Storage usage dashboard
- Pin favorite profiles

## 💡 Alternative: Simpler Approach

### **"Remember Me" Feature** (2-3 hours)

Instead of full multi-profile:
- Save last N usernames (not passwords)
- Show username dropdown on login
- Auto-fill username when selected
- Still single session at a time

**Pros**:
- Much simpler (no DB changes)
- Quick to implement
- Solves "I have multiple accounts" problem

**Cons**:
- Still need to type password
- No data isolation
- No quick switching

## 🎬 Next Steps

1. **Clarify Requirements**:
   - How many profiles expected? (3? 5? 10?)
   - Need biometric per profile?
   - Need profile management UI?
   - Is "Remember Me" sufficient?

2. **Choose Approach**:
   - MVP (basic multi-profile)
   - Full Implementation
   - Simple "Remember Me"

3. **Start Implementation**:
   - Create ProfileManager
   - Update database isolation
   - Build profile switcher UI

## 📝 Questions for User

1. **How many profiles** do you expect users to have? (impacts storage strategy)
2. **Is biometric per profile** necessary? (adds complexity)
3. **Do you want a profile management screen** or just a quick switcher?
4. **Should profiles sync across devices** or stay local?
5. **What happens to offline data when profile is deleted?** (keep/delete)
6. **Is there a "default/primary" profile** concept?

---

**Summary**: Multi-profile support is **definitely possible** but requires careful planning around data isolation. The recommended approach is **separate databases per user** with a **profile switcher UI**. Estimated effort: **14-19 hours for full implementation**, or **8 hours for MVP**.
