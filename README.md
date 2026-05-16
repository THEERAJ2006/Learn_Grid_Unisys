# LearnGrid

Offline-first federated AI learning platform built with Flutter for Android, macOS, Linux, and Windows.

## Current Build

This workspace includes:
- Drift/SQLite local data layer with repository abstractions for future Supabase or MongoDB swaps
- Riverpod state management and `go_router` navigation
- Offline AI service layer for embeddings, transcription, image analysis, engagement tracking, recommendations, and cloud fallback routing
- Dashboard, content viewer, search, assistant, progress, leaderboard, onboarding, settings, P2P, and federated-learning screens
- Python scripts for model download/conversion, dataset manifesting, and Flower-based federated sync

## Run Commands

```bash
# Download all models (run once)
python3 scripts/download_models.py

# Download all datasets (run once)
python3 scripts/download_datasets.py

# Generate Drift database code
flutter pub run build_runner build --delete-conflicting-outputs

# Run by platform
flutter run -d android --release
flutter run -d macos
flutter run -d linux
flutter run -d windows

# Build release artifacts
flutter build apk --split-per-abi --release
flutter build appbundle --release
flutter build macos --release
flutter build linux --release
flutter build windows --release

# Test
flutter test
```
## Project Notes

- `.env` is loaded via `flutter_dotenv` and already ignored by git.
- Downloaded `.onnx`, `.tflite`, textbook, video, and dataset artifacts are git-ignored.
- The model manifest at `assets/models/model_manifest.json` is used by Settings to surface model status and versions.
- Repository interfaces live in `lib/data/repositories/` so feature code stays backend-agnostic.

## Constraints

- The app should remain usable offline from first launch.
- Cloud AI follows Gemini -> Groq -> Hugging Face -> offline fallback.
- Inference work is intended to stay off the main UI thread.

## Verification

I could not run `flutter analyze` or `flutter test` inside this environment because the local policy blocked the Flutter executable, so final verification needs to happen on your machine with the commands above.
