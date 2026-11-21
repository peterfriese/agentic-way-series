# [AGFS006] Get started with Cloud Firestore - the Agentic way!

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
| Producer | [Clarissa de los Reyes](mailto:dclarissa@google.com) |

# Studio Recording Strategy (Voice Mode + Screencast)

1. **Pre-flight check:** Make sure the simulator starts on **German -> British English**, pre-warm `DerivedData` / SwiftPM cache so `FirebaseFirestore` links quickly, and have the Firebase Console open to `users/{uid}` in the background.
2. **Record the live Voice Mode session first (at your desk):** Run Antigravity Voice Mode with a screen recorder capturing the Antigravity + Simulator + Firebase Console windows, plus a clean separate audio track for your mic and Antigravity's spoken replies.
3. **Keep prompts crisp and conversational:** Speak naturally to Antigravity in 1-2 sentence turns so the back-and-forth feels genuine on camera and edits cleanly. Mute or end Voice Mode right before **Wrapping Up** (`4:18`) so the agent does not respond to your outro.
4. **In the studio:** Play back the screencast on a reference monitor and cue the agent's pre-recorded voice replies so you can react naturally on camera without waiting on live model latency.

# Script

| Script | Visuals |
| :--- | :--- |
| **0:00 - Cold Open: Live App Demo & Voice Mode** | |
| *(0:00)* Welcome back to Getting Started with Firebase the Agentic Way. So, the app that we've been working on allows you to translate idioms from one language to another. For example, if your friend tells you *"Du bist auf dem Holzweg"*, you can just use the app to find out *(translates live while talking)* that they are trying to tell you that you're barking up the wrong tree. That's great, but if you actually want to learn those idioms by heart, it would be nice to save them right inside the app. I've already added the initial UI for that: here's the **Save** button, and when I tap it, it shows up in the **Favorites** tab. Right now, though, it only lives in memory and isn't persisted to a database, so every time I restart the app, I lose everything. Let's fix that using Antigravity, and actually, let's do it using Voice Mode. | Split screen: Speaker + iPhone 18 Pro Simulator translating *"Du bist auf dem Holzweg"* to *"You're barking up the wrong tree"*, tapping **Save**, then switching to **Favorites** and noting it's in-memory only |
| *(1:03)* **Peter (Voice Mode):** "Hey, I just added a Favorites tab to save idioms, and right now they only live in memory. How can we persist them in Firebase so they sync across devices?" | Antigravity Voice Mode waveform + live transcript |
| *(1:15)* **Agent (Voice):** "Yes, you can do that using Cloud Firestore. Since the app already uses Firebase Authentication, we can store each user's translated idioms under their own UID so they sync across devices." | Antigravity Voice Mode waveform |
| *(1:29)* **Peter (Voice Mode):** "Oh! Good thing Marina implemented Sign in with Google in the previous episode! Let's hook up our Favorites tab and Save button to Firestore. Oh hey, and since we decided on Firestore, can you please add a rule to `AGENTS.md` to make sure that you are referring to the Firestore skill when writing any Firestore code? Thank you." | Antigravity Voice Mode waveform + `AGENTS.md` updating with the mandatory Firebase skills rule |
| **1:50 - Agentic Build, Firebase Plugin & Security Rules** | |
| *(1:50)* **Agent (Voice):** "I'll update `AGENTS.md`, add the `FirebaseFirestore` package, create a Swift 6 repository using `@DocumentID` and `Codable` scoped to each user's UID, wire it into the prepped Favorites UI, and hand off `firestore.rules` to the security rules specialist." | Antigravity tool stream: `AGENTS.md` edit + `firebase-firestore` (`ios_setup.md`) and `firestore-rules-author` skills loading |
| *(2:08)* Notice how Antigravity knows the exact Firebase patterns right away? This works because I've installed the **Firebase plugin** and locked that rule into `AGENTS.md`, so it uses `@DocumentID` and Firestore's native `Codable` APIs out of the box and delegates `firestore.rules` to a dedicated security rules author. *(sips coffee while the agent works)* | Screencast: Antigravity Plugins / Firebase plugin skills + fast-forward of `SavedIdiomRepository.swift` and `firestore.rules` while Peter drinks coffee |
| *(2:33)* **Peter (Voice Mode):** "Oh, and do I need to add extra code to enable offline persistence? Also, please double-check that unauthenticated writes are blocked, **and deploy the security rules**." | Voice Mode waveform **(cue: explicitly ask to deploy the rules so the agent runs `firebase deploy --only firestore:rules` instead of `--dry-run`)** |
| *(2:42)* **Agent (Voice):** "Actually, offline persistence is already enabled by default on iOS, no extra code needed! And `firestore.rules` restricts read and write access to `request.auth != null && request.auth.uid == userId`. Deploying rules and running the unit tests now." | Screencast: `firebase deploy --only firestore:rules` + `flowdeck test --only IdiomBridgeTests` running; B-roll cutaway to Firebase Console showing empty `users/{uid}/favorites` state |
| *(3:00)* **Peter (smiling):** "You're spot on, how could I forget this is turned on by default on iOS and Android." | Speaker in full screen |
| *(3:07)* **Interstitial (French accent):** "A few moments later..." | Title card: *"A few moments later..."* |
| **3:12 - Live Demo: Simulator to Firebase Console** | |
| *(3:12)* Let's see it running in the iOS Simulator. I'll translate *"It's raining cats and dogs"* to German (hey Antigravity, what's the funny literal one?) and tap Save. | iPhone 18 Pro Simulator: translate, tap Save |
| *(3:23)* **Agent (Voice, interrupting playfully):** "Oh, that is a really funny idiom! *Es regnet wie aus Eimern*, literally raining out of buckets." | Antigravity Voice Mode waveform pulses spontaneously |
| *(3:31)* **Peter (smiling):** "Wait, you're still listening? Good, keep watching." So here's the Favorites tab right inside the app, showing both the original phrase and the German translation, and it stays cached even if we go offline. Now let's switch over to the Firebase Console and open Firestore Database. If we drill into the `users` collection, pick my user ID, and open `favorites`, there's our new document sitting right there with the source text, translated idiom, language pair, and timestamp, all synced in real time. | Screencast: Favorites tab -> Firebase Console -> Firestore Database drilling into `users/{uid}/favorites` and highlighting document fields (mute/end Voice Mode after this beat) |
| **4:07 - Checking Security Rules** | |
| *(4:07)* And if we check the Rules tab in the console, those rules are already live: only the signed-in owner can read or write their own collection. | Screencast: Firebase Console -> Firestore -> Rules tab |
| **4:18 - Wrapping Up** | |
| *(4:18)* Awesome, so without typing a single line of code, I was able to add an entirely new feature to my app, complete with offline persistence and locked-down security rules. If you'd like to give this app a go and see what *"Türlich, türlich"* means, check out the code from our repository in the description below. Thanks for watching, and I will see you in the next one! | Speaker in full screen + repo link & subscribe card |
| **4:45 - Post-Credits "Cut!" Outro** | |
| *(4:45)* **Producer (off-camera):** "And, cut! Hey, quick question: how did you actually build the iOS version of Marina's Android app?" | Fake fade-out, then camera stays rolling; Peter relaxes on set |
| *(4:56)* **Peter (smiling):** "Oh, I used Antigravity to convert the whole app using its new Swarm mode and Voice Mode. We actually recorded a full behind-the-scenes video on that, so let's drop a link in the description below." | Quick flash of the Swarm Overview UI + "Link in the description" end card |
