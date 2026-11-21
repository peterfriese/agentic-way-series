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
| **0:00 - Cold Open: Live App Demo & Voice Mode** | |
| *(0:00)* Welcome back to Getting Started with Firebase the Agentic Way. So, the app that we've been working on allows you to translate idioms from one language to another. For example, if your friend tells you *"Du bist auf dem Holzweg"*, you can just use the app to find out *(translates live while talking)* that they are trying to tell you that you're barking up the wrong tree. That's great, but sometimes you might want to really learn those idioms by heart, so it would be good to be able to store them in the app in some sort of database. Let's ask Antigravity in Voice Mode. | Split screen: Speaker + iPhone 18 Pro Simulator translating *"Du bist auf dem Holzweg"* to *"You're barking up the wrong tree"* while Peter speaks |
| *(0:18)* **Peter (Voice Mode):** "Hey, so the app we're looking at allows users to translate idioms from their language to another language, and I was thinking it might be a good idea to store a history of all the words and idioms they translated in a database. Can you suggest how we could do that?" | Antigravity Voice Mode waveform + live transcript |
| *(0:32)* **Agent (Voice):** "Yes, you can do that using Cloud Firestore. Since the app already uses Firebase Authentication, we can store each user's translated idioms under their own UID so they sync across devices." | Antigravity Voice Mode waveform |
| *(0:44)* **Peter (Voice Mode):** "That's a great idea. That actually builds nicely on the Sign in with Google support Marina added earlier, since we can already tell users apart. Let's also build a UI for that history list." | Antigravity Voice Mode waveform |
| **0:52 - Agentic Build, Firebase Plugin & Security Rules** | |
| *(0:52)* **Agent (Voice):** "I'll add the `FirebaseFirestore` package, create a Swift 6 repository scoped to each user's UID, build a Saved Idioms history view in SwiftUI, and hand off `firestore.rules` to the security rules specialist." | Antigravity tool stream: `firebase-firestore` and `firestore-rules-author` skills loading |
| *(1:05)* Notice how Antigravity knows the exact Firebase patterns right away? That's because I've enabled the **Firebase plugin**, which gives the agent specialized skills for Cloud Firestore and Firestore Security Rules, so it even delegates `firestore.rules` to a dedicated security rules author. | Screencast: Antigravity Plugins / Firebase plugin skills + `FirestoreIdiomRepository.swift`, `IdiomBridgeViewModel.swift`, and `firestore.rules` |
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
| **4:35 - Post-Credits "Cut!" Outro** | |
| *(4:35)* **Producer (off-camera):** "And, cut! Hey, quick question: how did you actually build the iOS version of Marina's Android app?" | Fake fade-out, then camera stays rolling; Peter relaxes on set |
| *(4:43)* **Peter (smiling):** "Oh, I used Antigravity to convert the whole app using its new Swarm mode and Voice Mode. We actually recorded a full behind-the-scenes video on that, so let's drop a link in the description below." | Quick flash of the Swarm Overview UI + "Link in the description" end card |
