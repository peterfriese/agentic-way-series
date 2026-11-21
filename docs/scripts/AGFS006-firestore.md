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

1. **Record the live Voice Mode session first (at your desk):** Run Antigravity Voice Mode with a screen recorder capturing the Antigravity + Simulator + Firebase Console windows, plus a clean separate audio track for your mic and Antigravity's spoken replies.
2. **Keep prompts crisp and conversational:** Speak naturally to Antigravity in 1-2 sentence turns so the back-and-forth feels genuine on camera and edits cleanly.
3. **In the studio:** Play back the screencast on a reference monitor and cue the agent's pre-recorded voice replies so you can react naturally on camera without waiting on live model latency.

# Script

| Script | Visuals |
| :--- | :--- |
| **0:00 - Cold Open: Live App Demo & Voice Mode** | |
| *(0:00)* Welcome back to Getting Started with Firebase the Agentic Way. So, the app that we've been working on allows you to translate idioms from one language to another. For example, if your friend tells you *"Du bist auf dem Holzweg"*, you can just use the app to find out *(translates live while talking)* that they are trying to tell you that you're barking up the wrong tree. That's great, but if you actually want to learn those idioms by heart, it would be nice to save them right inside the app. I've already added the initial UI for that: here's the **Favorites** tab and the **Save** button. Right now, though, even though I can tap **Save** and see it in **Favorites**, it only lives in memory and isn't persisted to a database, so every time I restart the app, I lose everything. Let's fix that using Antigravity, and actually, let's do it using Voice Mode. | Split screen: Speaker + iPhone 18 Pro Simulator translating *"Du bist auf dem Holzweg"* to *"You're barking up the wrong tree"*, tapping **Save**, showing it in **Favorites**, then noting it's in-memory only |
| *(0:43)* **Peter (Voice Mode):** "Hey, I really like how this app allows me to translate idioms, but I'd like to learn them by heart. Can you suggest how we could do that and store them in a database?" | Antigravity Voice Mode waveform + live transcript |
| *(0:55)* **Agent (Voice):** "Yes, you can do that using Cloud Firestore. Since the app already uses Firebase Authentication, we can store each user's translated idioms under their own UID so they sync across devices." | Antigravity Voice Mode waveform |
| *(1:09)* **Peter (Voice Mode):** "Oh! Good thing Marina implemented Sign in with Google in the previous episode! Let's hook up our Favorites tab and Save button to Firestore. And since we've decided on Firestore, let's add a rule in `AGENTS.md` so you always read the `firebase-firestore` skill and its iOS setup guide before writing any Firestore code." | Antigravity Voice Mode waveform + `AGENTS.md` updating with the mandatory Firebase skills rule |
| **1:30 - Agentic Build, Firebase Plugin & Security Rules** | |
| *(1:30)* **Agent (Voice):** "I'll update `AGENTS.md`, add the `FirebaseFirestore` package, create a Swift 6 repository using `@DocumentID` and `Codable` scoped to each user's UID, wire it into the prepped Favorites UI, and hand off `firestore.rules` to the security rules specialist." | Antigravity tool stream: `AGENTS.md` edit + `firebase-firestore` (`ios_setup.md`) and `firestore-rules-author` skills loading |
| *(1:48)* Notice how Antigravity knows the exact Firebase patterns right away? That's because I've enabled the **Firebase plugin** and locked that rule into `AGENTS.md`, so it uses `@DocumentID` and Firestore's native `Codable` APIs out of the box and delegates `firestore.rules` to a dedicated security rules author. *(sips coffee while the agent works)* | Screencast: Antigravity Plugins / Firebase plugin skills + fast-forward of `SavedIdiomRepository.swift` and `firestore.rules` while Peter drinks coffee |
| *(2:13)* **Peter (Voice Mode):** "Oh, and please make sure offline persistence is enabled and double-check that unauthenticated writes are blocked." | Voice Mode waveform |
| *(2:22)* **Agent (Voice):** "Offline persistence is on by default on iOS, and `firestore.rules` restricts read and write access to `request.auth != null && request.auth.uid == userId`. Deploying rules and running the tests now." | Screencast: `firebase deploy --only firestore:rules` + `flowdeck test` passing |
| *(2:40)* **Peter (smiling):** "You're spot on, how could I forget this is turned on by default on iOS and Android." | Speaker in full screen |
| *(2:47)* **Interstitial (French accent):** "A few moments later..." | Title card: *"A few moments later..."* |
| **2:52 - Live Demo: Simulator to Firebase Console** | |
| *(2:52)* Let's see it running in the iOS Simulator. I'll sign in, translate *"It's raining cats and dogs"* to German, and tap Save. | iPhone 18 Pro Simulator: sign in, translate, tap Save |
| *(3:03)* **Agent (Voice, interrupting playfully):** "Oh, that is a really funny idiom! *Es regnet wie aus Eimern*, literally raining out of buckets." | Antigravity Voice Mode waveform pulses spontaneously |
| *(3:11)* **Peter (smiling):** "Wait, you're still listening? Good, keep watching." So here's the Favorites tab right inside the app, showing both the original phrase and the German translation, and it stays cached even if we go offline. Now let's switch over to the Firebase Console and open Firestore Database. If we drill into the `users` collection, pick my user ID, and open `idioms`, there's our new document sitting right there with the source text, translated idiom, language pair, and server timestamp, all synced in real time. | Screencast: Favorites tab -> Firebase Console -> Firestore Database drilling into `users/{uid}/idioms` and highlighting document fields |
| **3:47 - Checking Security Rules** | |
| *(3:47)* And if we check the Rules tab in the console, those rules are already live: only the signed-in owner can read or write their own collection. | Screencast: Firebase Console -> Firestore -> Rules tab |
| **3:58 - Wrapping Up** | |
| *(3:58)* Awesome, so without typing a single line of code, I was able to add an entirely new feature to my app, complete with offline persistence and locked-down security rules. If you'd like to give this app a go and see what *"Türlich, türlich"* means, check out the code from our repository in the description below. Thanks for watching, and I will see you in the next one! | Speaker in full screen + repo link & subscribe card |
| **4:25 - Post-Credits "Cut!" Outro** | |
| *(4:25)* **Producer (off-camera):** "And, cut! Hey, quick question: how did you actually build the iOS version of Marina's Android app?" | Fake fade-out, then camera stays rolling; Peter relaxes on set |
| *(4:36)* **Peter (smiling):** "Oh, I used Antigravity to convert the whole app using its new Swarm mode and Voice Mode. We actually recorded a full behind-the-scenes video on that, so let's drop a link in the description below." | Quick flash of the Swarm Overview UI + "Link in the description" end card |
