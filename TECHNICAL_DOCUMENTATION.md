# LearnGrid: Complete Technical Documentation

**Version:** 1.0.0  
**Last Updated:** 2026-05-16  
**Status:** Active Development  
**Repository:** THEERAJ2006/Learn_Grid_Unisys

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Project Overview](#project-overview)
3. [Architecture](#architecture)
4. [Technology Stack](#technology-stack)
5. [Database Design](#database-design)
6. [Features & Implementation](#features--implementation)
7. [Code Structure](#code-structure)
8. [Setup & Deployment](#setup--deployment)
9. [Troubleshooting](#troubleshooting)
10. [Security Considerations](#security-considerations)

---

## Executive Summary

**LearnGrid** is an offline-first federated AI learning platform built with Flutter that enables AI-powered education in low-bandwidth regions. The app combines:

- 🌐 **Local AI Inference** - Run ML models entirely on-device
- 📱 **Cross-Platform** - Android, iOS, Windows, macOS, Linux, Web
- 🔄 **Peer-to-Peer Sync** - Share content between nearby devices
- 🤝 **Federated Learning** - Collaborative model improvement
- ☁️ **Smart Cloud Fallback** - Gemini → Groq → HuggingFace → Offline
- 📊 **Gamification** - Streaks, points, leaderboards, progress tracking
- 🗄️ **Local Database** - SQLite with Drift ORM for offline-first data

---

## Project Overview

### What LearnGrid Does

LearnGrid is a **learning management system** designed for communities with unreliable internet access. It allows users to:

1. **Learn Offline** - Access educational content without internet
2. **Get AI Help** - Chat with an AI assistant (online or offline)
3. **Search Intelligently** - Semantic search using AI embeddings
4. **Track Progress** - Monitor learning with gamified achievements
5. **Share Locally** - P2P sync content with nearby devices
6. **Collaborate** - Improve AI models through federated learning

### Target Users

- 🎓 Students in low-bandwidth regions
- 🏫 Schools and educational institutions
- 🌍 NGOs and humanitarian organizations
- 👨‍💻 Researchers studying federated learning

### Key Statistics

| Metric | Value |
|--------|-------|
| **Primary Language** | Dart (46.4%) |
| **Framework** | Flutter |
| **Database** | SQLite (via Drift ORM) |
| **State Management** | Riverpod |
| **Routing** | GoRouter |
| **AI Models** | ONNX, TFLite |
| **Supported Platforms** | Android, iOS, Windows, macOS, Linux, Web |

---

## Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│            UI Layer (features/)                 │
│  Dashboard, Content, Chat, Files, Settings     │
├─────────────────────────────────────────────────┤
│       State Management (Riverpod Providers)     │
├─────────────────────────────────────────────────┤
│        Repository Layer (Backend Agnostic)      │
│  Content, User, Progress, Chat, Leaderboard   │
├─────────────────────────────────────────────────┤
│          Data Layer (Drift + SQLite)            │
│  All user data stored locally & encrypted      │
├─────────────────────────────────────────────────┤
│            AI/ML Inference (lib/ai/)            │
│  ONNX, TFLite, Search, Speech, Vision         │
├─────────────────────────────────────────────────┤
│         Services (Connectivity, P2P, Sync)     │
└─────────────────────────────────────────────────┘
```

### Folder Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # App configuration
├── core/
│   ├── router/                  # GoRouter config (app_router.dart)
│   └── theme/                   # Material theme (app_theme.dart)
├── data/
│   ├── database/                # Drift ORM & SQLite
│   │   ├── app_database.dart    # Database class
│   │   ├── tables.dart          # Drift table definitions
│   │   └── app_database.g.dart  # Generated code
│   ├── models/
│   │   └── entities.dart        # Data entities (backend-agnostic)
│   ├── providers/               # Riverpod providers
│   │   ├── data_providers.dart
│   │   └── current_user_provider.dart
│   └── repositories/            # Repository interfaces & implementations
├── services/
│   ├── connectivity/            # Online/offline detection
│   ├── p2p/                     # Peer-to-peer sync (Android)
│   └── sync/                    # Content synchronization
├── ai/                          # AI/ML inference layer
│   ├── router/                  # Cloud vs offline routing
│   ├── nlp/                     # Text embeddings, search
│   ├── speech/                  # Speech-to-text
│   ├── vision/                  # Image analysis
│   ├── chat/                    # Chat AI
│   ├── engagement/              # Engagement tracking
│   ├── recommendation/          # Content recommendation
│   ├── federated_learning/      # Flower integration
│   ├── isolates/                # Background inference
│   ├── runtime/                 # Model runtime selection
│   └── stubs/                   # Mock implementations
└── features/                    # Feature modules (screens)
    ├── shell/                   # App shell (navigation)
    ├── dashboard/               # Home screen
    ├── content/                 # Content management
    ├── search/                  # Semantic search
    ├── chat/                    # Chat sessions
    ├── ai_assistant/            # AI chat screen
    ├── files/                   # File manager
    ├── gamification/            # Progress & leaderboard
    ├── settings/                # Settings
    ├── onboarding/              # First-run setup
    ├── p2p/                     # P2P sharing
    └── federated/               # Federated learning UI
```

### Data Flow Architecture

**User Action → Provider → Repository → Database → UI Update**

```
Example: User searches for "photosynthesis"
│
├─ SearchScreen.onChanged("photosynthesis")
│
├─ Calls searchProvider.search(query)
│
├─ Riverpod provider calls SemanticSearchRepository
│
├─ Repository encodes query to embedding
│
├─ Queries embeddings table, computes similarity
│
├─ Returns top 10 results
│
├─ Provider emits AsyncValue.data(results)
│
└─ SearchScreen rebuilds with results
```

### State Management with Riverpod

**Provider Hierarchy:**

```
appDatabaseProvider (singleton)
├─ contentRepositoryProvider
│  └─ contentNotifierProvider
├─ progressRepositoryProvider
│  └─ userProgressNotifierProvider
├─ chatRepositoryProvider
│  └─ chatSessionsProvider
├─ leaderboardRepositoryProvider
│  └─ leaderboardEntryProvider
└─ embeddingRepositoryProvider
   ├─ embeddingIndexProvider (FutureProvider)
   └─ searchProvider (FutureProvider.family)

connectivityServiceProvider
├─ aiRouterProvider (Cloud vs offline)
└─ syncServiceProvider
```

---

## Technology Stack

### Core Framework

| Component | Version | Purpose |
|-----------|---------|---------|
| Dart | ^3.11.5 | Language |
| Flutter | Latest | UI Framework |

### UI & Navigation

| Package | Version | Purpose |
|---------|---------|---------|
| go_router | ^12.0.0 | Routing & navigation |
| google_fonts | ^6.1.0 | Typography |
| flutter_animate | ^4.2.0 | Animations |
| shimmer | ^3.0.0 | Loading placeholders |
| fl_chart | ^0.65.0 | Charts & graphs |

### State Management & Data

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.4.0 | Reactive state, DI |
| freezed | ^2.4.0 | Immutable models |
| drift | ^2.14.0 | SQLite ORM |
| sqlite3_flutter_libs | ^0.5.0 | SQLite driver |

### AI/ML Inference

| Package | Version | Purpose |
|---------|---------|---------|
| tflite_flutter | ^0.12.1 | TensorFlow Lite |
| flutter_onnxruntime | ^1.7.0 | ONNX Runtime |
| ml_linalg | ^13.0.0 | Vector math |
| google_mlkit_text_recognition | ^0.13.0 | OCR |

### Content Processing

| Package | Version | Purpose |
|---------|---------|---------|
| syncfusion_flutter_pdfviewer | ^23.0.0 | PDF rendering |
| video_player | ^2.8.0 | Video playback |
| just_audio | ^0.9.36 | Audio processing |
| docx_to_text | ^1.0.1 | DOCX parsing |

### Networking & Services

| Package | Version | Purpose |
|---------|---------|---------|
| connectivity_plus | ^5.0.0 | Online/offline status |
| http | ^1.1.0 | HTTP requests |
| dio | ^5.4.0 | Advanced HTTP client |
| nearby_connections | ^4.3.0 | Android P2P |

### Security & Storage

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_secure_storage | ^9.2.2 | Encrypted storage |
| shared_preferences | ^2.3.2 | Key-value storage |
| crypto | ^3.0.3 | Hash functions |
| encrypt | ^5.0.3 | AES encryption |

---

## Database Design

### Entity-Relationship Diagram

```
┌─────────────┐
│    USERS    │
└─────────────┘
       │
       ├──→ ENGAGEMENT_SESSIONS
       ├──→ USER_PROGRESS
       └──→ LEADERBOARD_ENTRIES

┌──────────────────┐
│  CONTENT_ITEMS   │◄─── Multiple types: pdf, video, image, docx, text
└──────────────────┘
       │
       ├──→ EMBEDDINGS (768-dim vectors)
       ├──→ TRANSCRIPTS (video chunks)
       ├──→ IMAGE_INSIGHTS (analysis results)
       └──→ AI_RESPONSE_CACHE

┌──────────────────┐
│  CHAT_SESSIONS   │
└──────────────────┘
       │
       └──→ CHAT_MESSAGES

┌────────────────┐
│  MANAGED_FILES │ ◄─── User-uploaded files
└────────────────┘

┌──────────────────┐
│   PEER_DEVICES   │ ◄─── P2P discovery
└──────────────────┘
```

### Key Tables

#### Users Table
```dart
- id (PK): Device UUID
- device_id: Unique device identifier
- created_at: Registration timestamp
- prefs: JSON preferences blob
- consent_online: Cloud AI consent flag
```

#### ContentItems Table
```dart
- id (PK): Content UUID
- title: Display name
- type: 'text'|'video'|'pdf'|'image'|'docx'
- file_path: Local storage path
- difficulty_level: 1-5
- topic_tags: JSON array
- subject: e.g., "Biology", "Mathematics"
- language: "en", "es", etc.
- file_size: Bytes
- added_at: Timestamp
Index: (type), (subject)
```

#### Embeddings Table
```dart
- id (PK): UUID
- content_id (FK): References ContentItems
- chunk_index: For long documents
- chunk_text: Original text snippet
- embedding: BLOB (768-dim Float32 vector)
- model: 'minilm-l6-v2'
Index: (content_id)
```

#### AIResponseCache Table
```dart
- id (PK): UUID
- cache_key (UNIQUE): Hash of prompt
- response_json: API response
- source: 'offline'|'cloud'
- model: 'gemini'|'groq'|'huggingface'
- created_at: Timestamp
- expires_at: 24-hour TTL
Indexes: (cache_key), (expires_at DESC)
```

#### UserProgress Table
```dart
- id (PK): UUID
- user_id (FK): References Users
- content_id (FK): References ContentItems
- completion_pct: 0.0-1.0
- last_accessed_at: Timestamp
- difficulty_rating: 1-5 user rating
- time_spent_seconds: Total time
Index: (user_id), (content_id)
```

#### ChatSessions Table
```dart
- id (PK): Auto-increment
- name: Session title
- created_at: Timestamp
- updated_at: Last message time
- linked_file_ids: JSON array of file IDs
Index: (updated_at DESC)
```

---

## Features & Implementation

### 1. Content Management

**What it does:** Upload, organize, view PDFs, videos, images, text

**Files involved:**
- `lib/features/content/screens/content_list_screen.dart`
- `lib/features/content/screens/content_viewer_screen.dart`
- `lib/data/repositories/content_repository.dart`

**User flow:**
```
ContentListScreen (browse all)
    ↓ select item
ContentViewerScreen (PDF/Video/Image viewer)
    ↓ track engagement & update progress
UserProgress saved to database
```

**Content types supported:**
- **PDF**: SyncfusionPdfViewer with page navigation
- **Video**: VideoPlayer with transcription
- **Image**: Full-screen viewer with analysis
- **Text**: Scrollable formatted text
- **DOCX**: Extracted text display

### 2. Semantic Search

**What it does:** AI-powered search using embeddings

**Algorithm:**
```
1. User enters query: "photosynthesis process"
2. Query encoded to 768-dim embedding
3. Compute cosine similarity vs all content embeddings
4. Sort results by similarity score
5. Return top 10 matches
```

**Example:**
```
Query: "How do plants make food?"
Results:
├─ "Photosynthesis Guide" (98% match)
├─ "Plant Biology 101" (94% match)
└─ "Energy in Plants" (91% match)
```

**Files:**
- `lib/ai/nlp/embedding_service.dart`
- `lib/ai/nlp/semantic_search.dart`

### 3. AI Assistant

**What it does:** Chat with offline/cloud AI

**Cloud fallback chain:**
```
Check online status
    ↓
Try cache
    ├─ Cache hit → Return cached response
    ├─ Cache miss + online → Try cloud APIs
    │   ├─ Gemini API
    │   ├─ Groq API
    │   └─ HuggingFace API
    └─ Cache miss + offline → Local inference
        └─ Run offline LLM model
```

**Response flow:**
```
User: "How do mitochondria produce energy?"
    ↓
AIRouter.route()
    ├─ Check cache: miss
    ├─ Check online: yes
    └─ Try Gemini → Success!
        ├─ Cache result (24h TTL)
        └─ Return to user
    ↓
AI: "Mitochondria produce ATP through cellular respiration..."
```

### 4. Transcription

**What it does:** Auto-transcribe video content

**Process:**
```
1. Extract audio from video file
2. Split into 30-second chunks
3. Feed to TFLite speech-to-text model
4. Generate timestamps for each chunk
5. Store in Transcripts table
6. Make video fully searchable
```

### 5. Image Analysis

**What it does:** Extract concepts, OCR, classify images

**Pipeline:**
```
Image uploaded
    ├─ Classification (diagram/photo/chart)
    ├─ OCR (extract visible text)
    ├─ Concept extraction (identify objects)
    ├─ Caption generation
    └─ Store in ImageInsights table
```

### 6. Engagement Tracking

**What it does:** Monitor user focus while learning

**Metrics tracked:**
- Tap/click events per minute
- Scroll events per minute
- Time without interaction (idle)
- Engagement state classification

**States:**
- 🔥 **Focused**: High interaction, low idle
- 👁️ **Passive**: Medium interaction
- 😴 **Fatigued**: Decreasing engagement
- ❌ **Absent**: Long idle periods

### 7. Gamification

**Leaderboard:**
```
Criteria for points:
├─ Content completion: 50 points
├─ Daily streak: 10 points/day
├─ Quiz pass: 25 points
└─ Community contribution: Variable

Leaderboard types:
├─ Global (all-time)
├─ Weekly (resets Monday)
└─ Subject-specific
```

**Progress:**
- Per-content completion percentage
- Time investment tracking
- Difficulty ratings from users

### 8. Chat Sessions

**What it does:** Manage multiple independent conversations

**Features:**
- Create named sessions
- Persistent history
- Link files to session
- AI can reference linked documents

### 9. File Management

**What it does:** Upload and manage user files

**Features:**
- Upload PDFs, images, documents
- Extract text for search
- Generate embeddings
- Link to chat sessions
- Delete files

### 10. P2P Sync

**What it does:** Share content between nearby devices

**Technology:** NearbyConnections (Android only)

**Workflow:**
```
Device A: Starts P2P discovery
Device B: Discovers Device A
User selects content to sync
    ↓
Content transferred via Bluetooth/WiFi Direct
    ↓
Device B: Content added to local database
```

**Use cases:**
- Teacher → Students
- School offline network
- Emergency information distribution

### 11. Federated Learning

**What it does:** Improve models collaboratively

**Privacy-preserving approach:**
```
Device 1: Train on local data for N epochs
    ↓ Send only model weights (NOT raw data)
Coordinator: Average weights from all devices
    ↓ Send updated model back
Device 2,3,4: Receive new model
    ↓ Repeat
```

---

## Code Structure

### Main Entry Point

```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  runApp(const ProviderScope(child: LearnGridApp()));
}

// lib/app.dart
class LearnGridApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LearnGrid',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
```

### Routing Configuration

```dart
// lib/core/router/app_router.dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    // Check onboarding on every route
    final hasShown = await SettingsPrefs.getHasShownOnboarding();
    if (!hasShown) return '/onboarding';
    return null;
  },
  routes: [
    GoRoute(path: '/onboarding', builder: ...),
    ShellRoute(
      builder: (context, state, child) => AppShellScreen(child: child),
      routes: [
        GoRoute(path: '/', name: 'dashboard', builder: ...),
        GoRoute(path: '/chat', name: 'chat-sessions', builder: ...),
        GoRoute(path: '/files', name: 'files', builder: ...),
        GoRoute(path: '/settings', name: 'settings', builder: ...),
      ],
    ),
    GoRoute(path: '/content', name: 'content-list', builder: ...),
    GoRoute(path: '/content/:id', name: 'content-viewer', builder: ...),
    // ... more routes
  ],
);
```

### Database Initialization

```dart
// lib/data/database/app_database.dart
@DriftDatabase(tables: [
  Users, ContentItems, Transcripts, ImageInsights,
  Embeddings, EngagementSessions, UserProgress,
  AIResponseCache, LeaderboardEntries, PeerDevices,
  ChatSessions, ChatMessages, ManagedFiles,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Create custom tables
      // Create performance indexes
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle migrations
    },
  );

  // Query methods (all user data access goes through here)
  Future<List<ContentItem>> getAllContent() async {
    return select(contentItems).get();
  }

  Future<List<Embedding>> getEmbeddingsByContent(String contentId) async {
    return (select(embeddings)
      ..where((tbl) => tbl.contentId.equals(contentId)))
      .get();
  }

  Future<UserProgressData?> getUserProgress(String userId, String contentId) async {
    return (select(userProgress)
      ..where((tbl) =>
        tbl.userId.equals(userId) & tbl.contentId.equals(contentId)))
      .getSingleOrNull();
  }

  // ... more query methods
}
```

### Repository Pattern

```dart
// lib/data/repositories/repository_interfaces.dart
abstract class ContentRepository {
  Future<List<ContentItemEntity>> getAll();
  Future<ContentItemEntity?> getById(String id);
  Future<void> insert(ContentItemEntity item);
  Future<void> update(ContentItemEntity item);
  Future<void> delete(String id);
}

// lib/data/repositories/drift/drift_repositories.dart
class DriftContentRepository implements ContentRepository {
  final AppDatabase _db;

  DriftContentRepository(this._db);

  @override
  Future<List<ContentItemEntity>> getAll() async {
    final rows = await _db.getAllContent();
    return rows.map((r) => _rowToEntity(r)).toList();
  }

  // ... implement other methods
}
```

### Riverpod Providers

```dart
// lib/data/providers/data_providers.dart
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return DriftContentRepository(ref.watch(appDatabaseProvider));
});

final contentNotifierProvider = StateNotifierProvider<
  ContentNotifier,
  AsyncValue<List<ContentItemEntity>>
>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return ContentNotifier(repo);
});
```

### Dashboard Screen Example

```dart
// lib/features/dashboard/screens/dashboard_screen.dart
class DashboardScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadAiMode();
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentNotifierProvider);
    final userId = ref.watch(currentUserIdProvider);
    final progress = ref.watch(userProgressNotifierProvider(userId));
    final leaderEntry = ref.watch(_myLeaderboardEntryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: content.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: '$e'),
        data: (items) {
          // Build dashboard UI
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 190,
                backgroundColor: AppTheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: _HeaderBanner(
                    greeting: _greeting(),
                    streakDays: leaderEntry.valueOrNull?.streakDays ?? 0,
                    totalPoints: leaderEntry.valueOrNull?.totalPoints ?? 0,
                  ),
                ),
              ),
              // ... more slivers
            ],
          );
        },
      ),
    );
  }
}
```

---

## Setup & Deployment

### Prerequisites

- Flutter SDK (3.11.5+)
- Python 3.8+ (for model scripts)
- Git
- For Android: Android SDK (API 21+)
- For iOS: Xcode 12+
- For Desktop: Visual Studio or CMake (Windows/Linux)

### Initial Setup

```bash
# Clone repository
git clone https://github.com/THEERAJ2006/Learn_Grid_Unisys.git
cd Learn_Grid_Unisys

# Install dependencies
flutter pub get

# Download & convert AI models
python3 scripts/download_models.py
python3 scripts/download_datasets.py

# Generate Drift database code
flutter pub run build_runner build --delete-conflicting-outputs

# Setup environment
cp .env.example .env
# Edit .env with your API keys:
# GEMINI_API_KEY=your_key_here
# GROQ_API_KEY=your_key_here
# HF_API_KEY=your_key_here
```

### Running the App

```bash
# List connected devices
flutter devices

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Run on desktop
flutter run -d windows
flutter run -d macos
flutter run -d linux

# Run on web
flutter run -d chrome

# Release build
flutter build apk --split-per-abi --release
flutter build appbundle --release
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

### Environment Variables

**.env file:**
```env
# Cloud API Keys (optional, app works offline without)
GEMINI_API_KEY=sk-xxx
GROQ_API_KEY=gsk_xxx
HF_API_KEY=hf_xxx

# Optional: Custom model paths
CUSTOM_EMBEDDING_MODEL=/path/to/model.onnx
CUSTOM_SPEECH_MODEL=/path/to/speech.tflite

# Optional: Federated learning
FL_SERVER_URL=http://localhost:8080
```

### Model Download

```bash
# Download required models
python3 scripts/download_models.py

# Downloads:
# - minilm-l6-v2.onnx (384MB) - text embeddings
# - speech_model.tflite (50MB) - speech-to-text
# - vision_model.onnx (200MB) - image analysis
# - llm_model.onnx (4GB) - optional local LLM

# Models are cached in assets/models/
```

### Build Runner for Code Generation

```bash
# Watch for file changes and regenerate
flutter pub run build_runner watch

# Build once
flutter pub run build_runner build

# Clean and rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Troubleshooting

### Issue: Build fails with "Drift code generation failed"

**Solution:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter clean
flutter pub get
flutter pub run build_runner build
```

### Issue: Models not found at runtime

**Solution:**
```bash
# Download models
python3 scripts/download_models.py

# Verify models are in assets/models/
ls -la assets/models/

# Rebuild app
flutter clean
flutter run
```

### Issue: Permissions denied on Android

**Solution:**
```bash
# Request permissions at runtime
adb shell pm grant com.learngrid android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.learngrid android.permission.WRITE_EXTERNAL_STORAGE

# Or add to AndroidManifest.xml
```

### Issue: Database locked (SQLite error)

**Solution:**
```dart
// Ensure database connection is awaited
final db = await AppDatabase().init();

// Don't share across isolates without care
```

### Issue: Offline inference is slow

**Solution:**
```dart
// Use GPU acceleration if available
final hasGPU = await inferenceService.hasGPU();
if (hasGPU) {
  await tfliteModel.loadWithGPU();
}
```

### Issue: Hot reload doesn't work after Drift changes

**Solution:**
```bash
# Hot reload can't regenerate Drift code
# Must do full rebuild

flutter pub run build_runner build
flutter run  # Full restart, not hot reload
```

---

## Security Considerations

### ✅ Secure Practices

1. **No Hardcoded Secrets**
   - API keys loaded from `.env` (not committed)
   - Accessed via `dotenv.env['KEY_NAME']`

2. **Encrypted Storage**
   - Using `flutter_secure_storage`
   - API keys encrypted at rest

3. **Local-First Design**
   - All user data stored locally in SQLite
   - No raw data sent to cloud
   - Only model parameters for federated learning

4. **HTTPS Enforcement**
   - All cloud API calls use HTTPS
   - No mixed-content

### ⚠️ Recommendations for Production

1. **Add SQLite Encryption**
   ```dart
   // Use SQLCipher for encrypted database
   // Currently: plain database (low security risk for educational use)
   ```

2. **Add Certificate Pinning**
   ```dart
   // Pin API certificates to prevent MITM attacks
   // Currently: standard certificate validation
   ```

3. **Implement Authentication**
   ```dart
   // Optional: Biometric/passcode for app access
   // Currently: Device-scoped, no auth
   ```

4. **Rate Limiting**
   ```dart
   // Add rate limiting for cloud API calls
   // Prevents abuse of API keys
   ```

5. **Data Minimization**
   - Don't log sensitive data
   - Clear cache regularly
   - Allow users to delete all data

### Security Checklist

- [ ] No API keys in code
- [ ] `.env` in `.gitignore`
- [ ] HTTPS only for cloud calls
- [ ] Permissions request at runtime
- [ ] SQLite encryption (optional)
- [ ] Certificate pinning (optional)
- [ ] Audit logs for data access

---

## Performance Tips

### Optimize Semantic Search

```dart
// Use indexes
CREATE INDEX idx_embeddings_content_id ON embeddings(content_id);

// Limit search scope
final embeddings = await db.getEmbeddingsBySubject('math');  // SQL filter

// Use vector similarity approximation (if needed)
// Exact cosine similarity: O(n) for n embeddings
// Approximate (Annoy/FAISS): O(log n) but requires library
```

### Optimize AI Inference

```dart
// Use background isolates
await Isolate.spawn(_computeEmbeddings, [chunks, port.sendPort]);

// Cache results aggressively
// TTL: 24 hours for responses

// Use lower precision
// Float32 → Float16 or Int8 for faster inference
```

### Optimize Database

```dart
// Use batch operations
await batch((batch) {
  batch.insertAll(embeddings, items);
});

// Eager load when needed
// SELECT DISTINCT to avoid duplicates
```

### Memory Optimization

```dart
// Stream large datasets instead of loading all
final stream = db.getAllEmbeddingsStream();

// Clear caches periodically
await database.clearExpiredCache();

// Limit list items with pagination
const pageSize = 50;
```

---

## Contributing Guidelines

### Code Style

- Follow Dart conventions
- Use `flutter analyze` to check code
- Format with `dart format`
- Max line length: 80 characters

### Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Git Workflow

1. Create feature branch: `git checkout -b feature/my-feature`
2. Commit changes: `git commit -m "Add my feature"`
3. Push to GitHub: `git push origin feature/my-feature`
4. Create Pull Request with description
5. Pass all CI checks before merging

---

## Resources

- **Flutter Docs:** https://flutter.dev/docs
- **Riverpod Docs:** https://riverpod.dev
- **Drift Docs:** https://drift.simonbinder.eu
- **GoRouter Docs:** https://pub.dev/packages/go_router
- **ONNX Runtime:** https://onnxruntime.ai
- **TensorFlow Lite:** https://www.tensorflow.org/lite

---

## License

This project is licensed under the MIT License - see LICENSE file for details.

---

## Contact & Support

**Repository:** https://github.com/THEERAJ2006/Learn_Grid_Unisys  
**Maintainer:** THEERAJ2006  
**Last Updated:** 2026-05-16

For issues, questions, or contributions, please open an issue or pull request on GitHub.

---

**Document Version:** 1.0  
**Generated:** 2026-05-16  
**Status:** Complete
