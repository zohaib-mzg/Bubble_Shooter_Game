# 🎮 80s Bubble Blaster — x86 Assembly Game

A retro-style Bubble Shooter game built entirely in **x86 Assembly (NASM)**, running in **16-bit DOS real mode** with direct video memory manipulation for rendering.

---

## 🕹️ Gameplay

- Move your shooter **left/right** using arrow keys
- Press **Up arrow** to fire bullets at falling bubbles
- Shoot all 10 bubbles to **win**
- You have **5 lives** — don't let bubbles reach your row!
- Press **ESC** to quit

---

## 🛠️ Tech Stack

| Component       | Detail                        |
|----------------|-------------------------------|
| Language        | x86 Assembly (NASM)           |
| Mode            | 16-bit DOS Real Mode           |
| Video Output    | Direct VGA Text Memory (0xB800)|
| Input Handling  | Custom Keyboard ISR (IRQ1)    |
| Timer           | Custom Timer ISR (IRQ0)       |
| Assembler       | NASM                          |
| Emulator        | DOSBox                        |

---

## ✨ Features

- Custom **keyboard interrupt handler** for real-time input
- Custom **timer interrupt** for game loop timing
- Direct **VGA text buffer** rendering (no BIOS calls for display)
- Live **score** and **lives** HUD
- Win/Lose screen with **final score display**
- Bubble collision detection with player and bullets
- Bubbles **reset to original position** after passing the bottom

---

## 🚀 How to Run

### Requirements
- [NASM Assembler](https://www.nasm.us/)
- [DOSBox](https://www.dosbox.com/)

### Steps

```bash
# Assemble
nasm bubbleShooter.asm -o bubbleShooter.com

# Run in DOSBox
b11.com
```

---

## 🎮 Controls

| Key         | Action         |
|-------------|----------------|
| ← Left Arrow | Move Left      |
| → Right Arrow | Move Right    |
| ↑ Up Arrow   | Shoot Bullet   |
| ESC          | Quit Game      |

---

## 👨‍💻 Author

**Muhammad Zohaib**
