# AGFS006 Screencast v2 Transcript

Source: `AGFS006-screencast-v2.cleanshotvideo/files/video.mov` (8:26)

| Time | Speaker | Transcript |
| :--- | :--- | :--- |
| 0:05 | Peter | Welcome back to Getting Started with Firebase the Agentic Way. So, the app that we've been working on allows you to translate idioms from one language to another. For example, if your friend tells you *"Du bist auf dem Holzweg"*, you can just use the app to find out that they are trying to tell you that you're barking up the wrong tree. |
| 0:27 | Peter | That's great, but if you actually want to learn those idioms by heart, it would be nice to save them right inside the app. I've already added the initial UI for that, so here's the Save button, and when I tap it, it shows up in the Favorites tab. |
| 0:46 | Peter | Right now, though, it only lives in memory and isn't persisted to a database, so every time I restart the app, I lose everything. Let's fix that using Antigravity, and actually, let's use Voice Mode. |
| 1:01 | Peter | Hey, I just added a Favorites tab to save idioms, and right now they only live in memory. How can we persist them in Firebase so they sync across devices? |
| 1:13 | Agent | To sync your saved idioms across devices, I'll look into the best Firebase implementation for your app. |
| 1:29 | Agent | Cloud Firestore is the best fit here. Since your app uses Firebase Auth, you can scope each user's favorites under a `users` collection. This enables real-time sync across devices using snapshot listeners, provides offline support by caching data locally, and ensures security with rules that limit access to each user's subcollection. To wire this up, we would add the Firebase package to Xcode, create a favorites service following your existing protocol pattern, hook it into your view model, and add rules to lock down access. Would you like me to go ahead and implement that? |
| 2:05 | Peter | Yes, that sounds great, and I think it's amazing that Marina already implemented Firebase Authentication so that we have an authenticated user when using the application. Yep, please go ahead and implement this for me. |
| 2:20 | Agent | Since Marina set up authentication, I'll wire up the Firebase FavoritesService and security rules. |
| 2:34 | Peter | Notice how Antigravity knows the exact Firebase patterns right away. This is because I installed this customization here, the Firebase plugin. So if we go here, you can see all the installed plugins. I've got the Firebase plugin installed. Here are all the commands that it brings, and it has a bunch of skills. And the skill that we're currently using is the Firestore skill, and you can see all the things that it brings: it understands the different Firestore editions, it knows how to set up, and it has a bunch of specialized guides for security rules, for example, for the individual SDKs that we've got. |
| 3:30 | Agent | I've created `FavoritesService`, hooked it into the view model and views, and added security rules. I'm verifying everything with a build now. |
| 3:39 | Peter | All right, so it seems like my agent is almost ready, so let's go back. |
| 3:56 | Peter | Oh, one more thing: do I need to add extra code to enable offline persistence, and can you also please double-check that unauthenticated writes are blocked and deploy the security rules? |
| 4:09 | Agent | Firebase caches data locally by default, so no extra code is needed for offline persistence. I'll verify the security rules to ensure unauthenticated writes are blocked and deploy them now. |
| 4:21 | Agent | I fixed a Swift 6 actor isolation error, and the build succeeded. Your `FavoritesService` is now wired up to sync user favorites in real time, the `ViewModel` handles the data flow based on auth state, and the security rules successfully passed a dry run to ensure unauthenticated writes are blocked. Everything compiles cleanly, so would you like me to deploy the security rules to your project or test the app in the simulator? |
| 4:45 | Agent | I've... *(overlapping start, trim in edit)* |
| 4:46 | Peter | Well, why not both? Please deploy the rules and then run on the simulator. |
| 4:52 | Agent | I'll deploy the security rules and launch the app in the simulator now. |
| 5:13 | Agent | I'm launching the app on the iPhone 18 Pro simulator now, with the security rules already deployed. I'll let you know as soon as it's up and running. |
| 5:22 | Agent | `IdiomBridge` is now running on the iPhone 18 Pro simulator, and your Firestore security rules are live. Any favorites you save or delete will sync in real time and stay cached offline automatically. |
| *(5:35)* | *(Studio VO Cue)* | *(Good spot for studio voiceover: "You're spot on, how could I forget this is turned on by default on iOS and Android.")* |
| 5:36 | Peter | All right, so I'm going to translate *"It's raining cats and dogs"* to German. |
| 5:44 | Agent | The German equivalent is *"Es regnet in Strömen"*. |
| 5:53 | Peter | Or *"Es gießt wie aus Eimern"*. |
| 5:57 | Agent | Das ist eine hervorragende Übersetzung for strong downpours! Let me know if you'd like to translate any other phrases. |
| 6:05 | Peter | No, but why don't we look at the database? |
| 6:08 | Agent | I'll check the Cloud Firestore database to verify your saved idioms. |
| 6:19 | Peter | All right, so while it's doing that, we can do that as well, and I'll go here to refresh the database. |
| 6:46 | Agent | I queried the database, and there are currently zero documents stored in the favorites collection. Make sure you're signed in and tap the star button on a translated idiom in the app to save it, and I can check again to see it appear. |
| 7:02 | Peter | All right. All right, so let me actually save it, and then, yeah, it shows up in the Favorites tab. Let's look at the database. |
| 7:14 | Agent | I'll check the database again to verify that your newly saved idiom is now persisting. |
| 7:26 | Agent | It's right there in Firestore. The path shows your source phrase and German translation are now successfully persisting, protected by your security rules, and ready to sync across devices. |
| 7:51 | Peter | That's fantastic. Thanks for your help. |
| 7:54 | Agent | You're very welcome. Enjoy syncing your favorites across your devices. |
| 7:59 | Peter | Awesome, so without typing a single line of code, I was able to add an entirely new feature to my app, complete with offline persistence and locked-down security rules. If you'd like to give this a try and see what *"Türlich, türlich"* means, check out the code from our repository in the description below. Thanks for watching, and I will see you in the next one! |
