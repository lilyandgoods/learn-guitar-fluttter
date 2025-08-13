# Guitar Learning App (FlutterFlow assets)

This repository contains implementation assets to turn a blank FlutterFlow iOS app into a guitar learning app, including:
- Custom Widgets (Advanced mic tuner, Interactive Fretboard)
- Custom Functions (frequency/note helpers, tap-tempo, streaks, chord transpose)
- Firestore security rules
- Seed content (lessons, chords, scales, songs, achievements)
- iOS Info.plist additions
- Pubspec dependency lines for Custom Code

## Integrate in FlutterFlow

1) Dependencies (Custom Code > Pubspec)
Add these dependencies under `dependencies:`
```
flutter_audio_capture: ^1.0.0
pitch_detector_dart: ^0.4.0
```

2) iOS permission (Settings > iOS > Info.plist entries)
Add this entry:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app uses the microphone for guitar tuning.</string>
```

3) Custom Widgets (Custom Code > Widgets)
- Create `AdvancedGuitarTuner` using `custom_code/widgets/AdvancedGuitarTuner.dart`
- Create `InteractiveFretboard` using `custom_code/widgets/InteractiveFretboard.dart`

4) Custom Functions (Custom Code > Functions)
- Add from `custom_code/functions/*.dart`

5) Firestore rules
Use `firebase/firestore.rules` in Firebase console.

6) Seed content
Import JSONs from `content_seed/` into Firestore (manually or via script), or copy values to create docs.

7) Pages & wiring
- Practice > Tuner: show Basic and Advanced. Advanced navigates to page containing `AdvancedGuitarTuner`.
- Bind `autoDetect` and `targetNote` props from page state.

## Local repository development
This repo is asset-oriented for FlutterFlow. If you want a full Flutter app, run `flutter create` separately and integrate these files.

## Push to GitHub
After the initial commit is created (done by scripts), set the remote and push:
```
# Replace with your repo URL
git remote add origin https://github.com/<your-username>/<your-repo>.git
git branch -M main
git push -u origin main
```

If you need me to push for you, share a GitHub repo URL I can add as a remote.
