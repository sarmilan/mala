# mala

An Apple Watch app that turns the Digital Crown into a japa mala — a tactile counter for mantra meditation.

Hold the watch in your hand like a physical mala. Turn the crown to count. That's it.

---

## what it does

- **crown scroll** — 2 detents = 1 count. one-directional, intentional.
- **tap to count** — the whole screen is a tap target. same feel, faster rhythm.
- **distraction free mode** — screen goes dark. you count by haptic alone.
- **persistent count** — close the app, reopen it, your count is where you left it.
- **lifetime total** — tracks every mantra you've ever counted. never resets.
- **rounds of 108** — quietly tracks full rounds below the counter.
- **reset** — long press to release the count back to zero. the session is archived before it clears.

---

## gestures

| input                    | action                       |
| ------------------------ | ---------------------------- |
| crown scroll (2 detents) | count +1                     |
| tap anywhere             | count +1                     |
| long press (1s)          | reset to 0                   |
| crown press              | toggle distraction free mode |

---

## stack

- watchOS 7.0+
- SwiftUI
- UserDefaults for persistence
- WKInterfaceDevice haptics

no dependencies. no companion iOS app.

---

## project structure

```
Mala/
├── MalaApp.swift          # app entry point
├── ContentView.swift      # single screen UI
├── MalaViewModel.swift    # state, persistence, crown input
└── Assets.xcassets        # app icon
```

---

## data

| key                   | type | description                              |
| --------------------- | ---- | ---------------------------------------- |
| `mala_current_count`  | Int  | current count — persists across sessions |
| `mala_lifetime_total` | Int  | all-time total — never decrements        |

---

## running the app

**simulator**

1. open `Mala.xcodeproj` in Xcode
2. select an Apple Watch simulator target
3. build and run (`⌘R`)
4. scroll trackpad over the crown to simulate rotation

**physical watch** _(requires Apple Developer Program)_

1. connect iPhone with watch paired
2. select your watch as the run target in Xcode
3. trust the device if prompted
4. build and run

---

## status

| release                         | status                                      |
| ------------------------------- | ------------------------------------------- |
| P0 — core counter               | ✅ in simulator, pending physical device QA |
| P1 — timer, multi-mantra, music | 🔜 planned                                  |

---

## p1 and beyond

- meditation timer with gentle completion buzz
- track multiple mantras separately
- ambient music via connected headphones
- breathing sync — taptic + audio cues for inhale/exhale
- gesture counting via CoreMotion (no crown, just wrist motion)
- session history and statistics
- settings: crown sensitivity, tap toggle, round size

---

_mala is designed to be held, not worn._
