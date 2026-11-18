# MAD Lab Kit

Starter projects for the labs of the **Mobile Application Development** course handbook (GCUF, BS level).
Everything here is free and needs no paid account.

## For students

| You want to... | Do this |
| --- | --- |
| Build on your own laptop (Lab 0, Part C or D) | Download **MAD-LiteKit.zip** from [Releases](../../releases/latest), extract it, and copy the `starter` folder for each lab |
| Save about 1 GB of downloads | Also download **gradle-home.zip** from [Releases](../../releases/latest) and copy its `gradle-home` folder to `C:\Users\<you>\.gradle` (Lab 0, Part D4) |
| Build in the browser (Lab 0, Part G) | **Fork** this repository, then **Code > Codespaces > Create codespace on main**, then `cd starter` and `./gradlew assembleDebug` |

| Folder | What it is |
| --- | --- |
| `starter/` | The Java starter project used by every lab |
| `kotlin-starter/` | The same in Kotlin, with a Jetpack Compose screen, for bonus work |
| `kit/README.txt` | The short Lite Kit instructions included in the zip |
| `.devcontainer/` | Sets up GitHub Codespaces: installs the Android SDK automatically |

## How the labs are checked

Every push runs [the verify workflow](.github/workflows/verify.yml) on GitHub's free machines:

- **Lab 0 on Windows**, step by step as the Lab Manual describes it (command-line tools, `android sdk install`, `gradlew.bat`), with a 1.5 GB memory limit for older laptops; also Lab 12 (Node.js and PowerShell) and Lab 13 (keystore, signed APK and App Bundle).
- **Every lab's guided code on Android emulators** (Android 11, 15 and 16), built from the handbook's own code blocks, with automatic UI tests and screenshots (`ci/labs/`).
- **The Codespaces container** builds the starter.

The results (logs and screenshots) are on the [`ci-results`](../../tree/ci-results) branch.
