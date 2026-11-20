# [AGFS005] Get started with Cloud Firestore - the Agentic way!

## *Series: Agentic Firebase Video Series*

**Author(s):** [Peter Friese](mailto:peterfriese@google.com)

**Last Updated:** Nov 20, 2026

# Metadata

| About this video | |
| :--- | :--- |
| Title | Get started with Cloud Firestore - the Agentic way! |
| Series | Agentic Firebase Video Series |
| Target Time | 5 minutes |

| Who are the people working on this? | |
| :--- | :--- |
| Speaker(s) | [Peter Friese](mailto:peterfriese@google.com) |

# Studio Recording Strategy (Voice Mode + Screencast)

1. **Record the live Voice Mode session first (at your desk):** Run Antigravity Voice Mode with a screen recorder capturing the Antigravity + Simulator + Firebase Console windows, plus a clean separate audio track for your mic and Antigravity's spoken replies.
2. **Keep prompts crisp and conversational:** Speak naturally to Antigravity in 1-2 sentence turns so the back-and-forth feels genuine on camera and edits cleanly.
3. **In the studio:** Play back the screencast on a reference monitor and cue the agent's pre-recorded voice replies so you can react naturally on camera without waiting on live model latency.

# Script

| Script | Visuals |
| :--- | :--- |
| **0:00 - Cold Open: Straight Into Voice Mode** | |
| *(0:00)* Last time, Marina added Sign in with Google to Idiom Bridge. Today, I'm adding Cloud Firestore and production security rules to the iOS app without typing a single line of code, just by talking to Antigravity in Voice Mode. Watch this. | Split screen: Speaker + Antigravity Voice Mode active over Xcode / iOS Simulator |
| *(0:15)* **Peter (Voice Mode):** "Hey, Idiom Bridge already signs users in with Firebase Auth. Add Cloud Firestore so each user's translated idioms sync under their own UID, show a saved history list in SwiftUI, and write strict security rules so nobody else can read their data." | Antigravity Voice Mode waveform + live transcript |
| **0:30 - Agentic Build & Security Rules** | |
| *(0:30)* **Agent (Voice):** "I'll add the FirebaseFirestore package, create a Swift 6 repository scoped to each user's UID, wire up the history list, and hand off `firestore.rules` to the security rules specialist." | Antigravity tool stream: `firebase-firestore` and `firestore-rules-author` skills loading |
| *(0:55)* Notice what's happening here: because the Firebase Agent Plugin is installed, Antigravity pulls in the `firebase-firestore` skill for the Swift 6 data layer and delegates `firestore.rules` to a dedicated security rules author. | Fast-forward screencast of `FirestoreIdiomRepository.swift`, `IdiomBridgeViewModel.swift`, and `firestore.rules` |
| *(1:35)* **Peter (Voice Mode):** "Make sure offline persistence is enabled and double-check that unauthenticated writes are blocked." | Voice Mode waveform |
| *(1:45)* **Agent (Voice):** "Offline persistence is on by default on iOS, and `firestore.rules` restricts read and write access to `request.auth != null && request.auth.uid == userId`. Deploying rules and running the tests now." | Screencast: `firebase deploy --only firestore:rules` + `flowdeck test` passing |
| **2:30 - Live Demo: Simulator to Firebase Console** | |
| *(2:30)* Let's see it running in the iOS Simulator. I'll sign in, translate *"It's raining cats and dogs"* to German, and tap Save. | iPhone 18 Pro Simulator: sign in, translate, tap Save |
| *(2:48)* **Agent (Voice, interrupting playfully):** "Oh, that is a really funny idiom! *Es regnet wie aus Eimern*, literally raining out of buckets." | Antigravity Voice Mode waveform pulses spontaneously |
| *(2:56)* **Peter (smiling):** "Wait, you're still listening? Good, keep watching." There it is in the Saved Idioms list, and if I switch over to the Firebase Console under Firestore Database, the document is already there under `users/{uid}/idioms` with the source idiom, target language, and timestamp. | Screencast: Saved Idioms list -> Firebase Console -> Firestore Database showing the live document |
| **3:45 - Checking Security Rules** | |
| *(3:45)* And if we check the Rules tab in the console, those rules are already live: only the signed-in owner can read or write their own collection. | Screencast: Firebase Console -> Firestore -> Rules tab |
| **4:15 - Wrapping Up** | |
| *(4:15)* Zero boilerplate, zero hand-written rules, and full cross-device sync in just a few minutes of conversation. Grab the code from the `agentic-way-series` repo linked below, and subscribe to the Firebase YouTube channel for the next episode. | Speaker in full screen + repo link & subscribe card |
