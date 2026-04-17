# Where Is Lola? - Game Boy Retro Adventure (SM83 Assembly)

This is a retro videogame developed for the original **Nintendo Game Boy**, written entirely in **SM83 Assembly**. This project was created as part of an academic challenge focused on low-level hardware optimization and direct memory management.

## 🛠️ Technical Stack
* **Language:** SM83 Assembly (Game Boy CPU).
* **Toolchain:** RGBDS (Rednex Game Boy Development System).
* **Audio Engine:** GBT Player (interrupt-based sound management).
* **Graphics Tools:** GBTD (Game Boy Tile Designer) and GBMB (Game Boy Map Builder).

## 🚀 Technical Highlights
* **Collision System:** Implementation of an optimized tile-based collision detection for 8-bit processors.
* **VRAM/OAM Management:** Direct hardware register manipulation for sprite rendering and background updates during V-Blank intervals.
* **Scene Architecture:** Developed a state-machine flow to manage game states (Main Menu, Gameplay, and Game Over screens).
* **Performance:** Careful use of CPU cycles and memory mapping to ensure smooth gameplay on original hardware.

## ✍️ My Contributions
As part of a development team, I was specifically responsible for:
* Designing and implementing the **Main Game Loop** and the state machine logic.
* Developing the **Physics and Collision systems** from scratch (`physics.asm`, `collision.asm`).
* Integrating audio resources and synchronizing sound effects with in-game events.

## ⚠️ Compilation Note
This repository contains the source code and assets. Due to the specific path dependencies of the academic environment and the RGBDS toolchain, it is intended as a **code showcase** rather than a "plug-and-play" build. 

---
*This project is archived and was developed for educational purposes.*
