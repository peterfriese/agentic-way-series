# AGFS006 Screencast v1 Transcript

Source: `AGFS006-screencast-v1.cleanshotvideo/files/video.mov` (9:00)

| Time | Speaker | Transcript |
| :--- | :--- | :--- |
| 0:06 | Peter | Welcome back to Getting Started with Firebase the Agentic Way. So, the app that we've been working on allows you to translate idioms from one language to the other. For example, if your friend tells you *"Du bist auf dem Holzweg"*, you can just use the app to find out that they are trying to tell you that you're barking up the wrong tree. |
| 0:30 | Peter | That's great, but if you actually want to learn those idioms by heart, it would be nice to save them right inside the app. I've already added the initial UI for that: so here is the Save button, and when I tap it, the idiom shows up in the Favorites tab. |
| 0:50 | Peter | Right now, though, this only lives in memory and isn't persisted to a database, so every time I restart the app, I lose everything. Let's fix that using Antigravity, and actually, let's do it using Voice Mode. |
| 1:09 | Peter | Hey, so I've just added a Favorites tab to save idioms, and right now they only live in memory. How can we persist them in Firebase so they sync across devices? |
| 1:24 | Agent | I'll check your codebase to see how the idiom state is currently managed. |
| 1:40 | Agent | Right now, `IdiomBridgeViewModel` keeps favorites in an in-memory array, but since you already have Firebase Auth wired up, the cleanest way to persist and sync them across devices is with Cloud Firestore. You can save each saved item under a user-scoped subcollection, leverage Firestore's `Codable` support for direct serialization, replace the array updates with a Firestore service that writes on save or delete, and attach a snapshot listener for real-time syncing. To keep it secure, you would add a `firestore.rules` file to restrict read and write access to the authenticated user. Would you like me to set up the Firestore service, update the view model, and create those security rules for you? |
| 2:22 | Peter | Yeah, that sounds fantastic, and I think it's a good thing that Marina implemented the authentication feature in the previous episode of this video series. So yeah, why don't you go ahead and implement this for me? Thank you. |
| 2:38 | Agent | To ensure your favorites sync across all your devices, I'll update the view model and set up the Firestore service now. |
| 2:48 | Peter | All right, so the reason why Antigravity understands all of this is that I've installed the Firebase plugin. So if we come here into Customizations, you can see that there are a bunch of customizations, and I've installed the Firebase plugin here. And when we go into the plugin, we can see that it's got a bunch of commands that we can use, and it has a number of skills. And the skill that we are currently using is the Firestore skill, and it has all the knowledge that Antigravity needs to understand how Firestore works, how to best access it, and how to write code for the individual languages that you might want to use. And in our particular case, because this is an iOS application, this is going to be Swift, and it understands all the special features of the Swift SDK for Firestore. Same obviously for Kotlin, but this application is a Swift application. Cool, so let's go back to our coding agent. |
| 4:18 | Agent | Building the app now to verify the Firestore integration. |
| 4:25 | Agent | The build succeeded, and Firestore persistence for your favorites is all wired up. I added `FirebaseFirestore` to the project file, created `FavoritesService.swift` to read, save, delete, and stream items, and updated `IdiomBridgeViewModel.swift` and `ContentView.swift` to sync favorites in real time. I also added owner-only security rules in `firestore.rules` and wired them into `firebase.json`, verified with a dry-run deploy. Would you like me to deploy the Firestore rules to your Firebase project or launch the app on the simulator? |
| 5:12 | Peter | Yeah, so can you please deploy the security rules, and do I need to add extra code to enable offline persistence? |
| 5:22 | Agent | I'll deploy the security rules and check the offline persistence settings for your Firebase project. |
| 5:38 | Agent | Offline persistence is already enabled by default on iOS, so no extra code is needed. I also deployed your Firestore rules to the `idiom-bridge-agentic` project, and they are now live. |
| 5:51 | Peter | You're spot on. How could I forget this is turned on by default on iOS and Android? |
| 6:05 | Peter | So, can you please run the application on my simulator? |
| 6:09 | Agent | I'll launch the application on your simulator now. |
| 6:26 | Agent | I'm launching the app on your iPhone 18 Pro simulator now. |
| 6:35 | Agent | `IdiomBridge` is now running on your iPhone 18 Pro simulator. You can try signing in, translating an idiom, and saving it to favorites to see it persisted in Firestore. |
| 6:47 | Peter | All right, so I'll translate *"It's raining cats and dogs"*. |
| 7:09 | Peter | And then let's save it to Favorites, and here we are. |
| 7:17 | Peter | So let's take a quick look at the database. And here we can see that the data has been persisted into the database. And we can also look at the security rules to see that the agent has deployed our security rules. |
| 8:03 | Peter | Awesome, so without typing a single line of code, I was able to add an entirely new feature to my app, complete with offline persistence and locked-down security rules. If you'd like to give this a go and see what *"Türlich, türlich"* means, check out the code from our repository in the description below. Thanks for watching, and I will see you in the next one! |
| 8:26 | Peter | Cut! |
| 8:27 | Producer / Peter (off-camera) | Hey, quick question: how did you actually build the iOS version of Marina's Android app? |
| 8:32 | Peter | Well, I used Antigravity with this new Swarm feature and Voice Mode, which was actually a lot of fun. So yeah, I recorded a video how I did that, and yeah, I think I'll drop a link to that in the description below. Cheers. |
