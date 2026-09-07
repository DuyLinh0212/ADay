# ADay Brand Visual Assets & Deterministic Renderers

This directory documents the visual brand foundation, color specifications, and deterministic vector renderers for **ADay** ("Plan Today · A Better Tomorrow").

---

## 1. Brand Identity & Visual North Star

- **Creative North Star:** "Bình minh có kế hoạch" (Sunrise with a plan).
- **Inspiration:** The clear, calm feeling of opening a window on a fresh morning: clear tasks, tangible progress, and an encouraging next step without pressure or punitive gamification.
- **Reference Assets:**
  - `Logoapp.png`: App squircle icon with sunrise, rolling green hills, white humanist 'A', and embedded teal checkmark.
  - `TrangChu.png`: Production home screen mockup showcasing hero progress banner, section surfaces, mountain+sun illustration, task list, and bottom navigation.

---

## 2. Palette Tokens

| Token | Hex | Role | Contrast / Rule |
| :--- | :--- | :--- | :--- |
| **Brand Navy** | `#0A3768` | Main headings, high-contrast labels, neutral icons | Primary dark anchor |
| **Action Blue** | `#168AF2` | Primary buttons, active tabs, links, focus halo | 180ms hover/active shift |
| **Sky Cyan** | `#27BCEB` | Hero gradient transition, secondary charts | Morning sky tone |
| **Progress Teal** | `#0EB8AC` | Progress ring sweep, completed items | Visual positive reinforcement |
| **Success Mint** | `#20C99A` | Secondary success indicators, check badges | High legibility |
| **Sunrise Gold** | `#FFB52E` | Reminders, postponed indicators, tomorrow prep | Encouraging warm hue |
| **Cancel Coral** | `#F0525E` | Cancelled status, overdue markers, alerts | Non-punitive, functional only |
| **Morning Canvas**| `#F7FCFF` | App background | Cool-light clean atmosphere |
| **Clear Surface** | `#FFFFFF` | Primary cards, sheets, surfaces | Radius strictly $\le$ 16px |
| **Cool Surface**  | `#EEF7FD` | Secondary controls, inactive buttons, chips | Subtle depth |
| **Muted Ink**    | `#6683A5` | Secondary text, timestamps, captions | WCAG AA $\ge$ 4.5:1 |
| **Divider Mist** | `#DCE9F3` | 1px hairline dividers | Clean separation without shadows |

---

## 3. Deterministic Vector Renderers

Rather than relying on raster PNG assets that degrade when scaled and require asset bundle file I/O, the visual foundation implements zero-dependency, pixel-perfect **CustomPainter** vector renderers in Flutter SDK:

### A. `ADayAppIconPainter` (`lib/presentation/widgets/aday_logo_header.dart`)
- **Visual:** Precision squircle matching `Logoapp.png`.
- **Layers:**
  1. Background: Sky Cyan (`#32B3F0`) to Progress Teal (`#0CB6AA`) vertical gradient.
  2. Sun & Rays: Sunrise Gold (`#FFB52E`) disk with 4 radiating beam lines.
  3. Rolling Hills: Layered curved ridges with mint-to-teal gradient.
  4. Humanist 'A': Bold rounded white letterform with crossbar cutout.
  5. Checkmark: Teal (`#0EB8AC`) rounded checkmark embedded into the crossbar.
- **Usage:**
  ```dart
  // Standalone app icon widget:
  ADayAppIcon(size: 40.0)

  // Full header logo with typography:
  ADayLogo(compact: false)
  ```

### B. `MountainSunPainter` (`lib/presentation/widgets/mountain_sun_visual.dart`)
- **Visual:** Contoured morning mountains with warm rising sun and optional summit flag.
- **Layers:**
  1. Rising Sun: `#FFB52E` disk with 6 soft radiating beams.
  2. Far Ridge: Atmospheric sky-cyan contour (`#27BCEB`).
  3. Mid Ridge: Teal peak (`#20C99A`) reaching summit.
  4. Foreground Ridge: Progress teal rolling contour (`#0EB8AC`).
  5. Optional Summit Flag: Action Blue (`#168AF2`) triangular milestone flag.
- **Usage:**
  ```dart
  MountainSunVisual(height: 100.0, showFlag: true)
  MountainSunHeader(greeting: 'Xin chào, Minh!', subtext: '...')
  MountainSunGoalCard(title: 'Mục tiêu dài hạn', ...)
  ```

### C. `ProgressRingPainter` (`lib/presentation/widgets/progress_ring.dart`)
- **Visual:** Circular completion indicator with animated sweep and percentage text.
- **Specs:**
  - Background track: `Colors.white.withOpacity(0.22)`
  - Active sweep: `ADayColors.surface` with rounded stroke caps
  - Animation: 240ms cubic ease-out, respects reduced-motion settings.
- **Usage:**
  ```dart
  ProgressRing(progress: 0.67, size: 80.0)
  ```

---

## 4. Standalone Vector Specifications (SVG)

### ADay Brand Icon (Square / Squircle):
```xml
<svg width="512" height="512" viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="512" height="512" rx="122" fill="url(#sky_gradient)"/>
  <!-- Sun -->
  <circle cx="332" cy="184" r="92" fill="#FFB52E"/>
  <path d="M375 75L390 40" stroke="#FFC043" stroke-width="28" stroke-linecap="round"/>
  <path d="M425 125L455 100" stroke="#FFC043" stroke-width="28" stroke-linecap="round"/>
  <!-- Hills -->
  <path d="M0 307C153 256 307 317 512 296V512H0V307Z" fill="url(#hill_gradient)"/>
  <!-- Letter A -->
  <path d="M140 399L256 122L372 399" stroke="white" stroke-width="82" stroke-linecap="round" stroke-linejoin="round"/>
  <!-- Checkmark -->
  <path d="M210 281L245 317L322 240" stroke="#0EB8AC" stroke-width="51" stroke-linecap="round" stroke-linejoin="round"/>
  <defs>
    <linearGradient id="sky_gradient" x1="256" y1="0" x2="256" y2="512" gradientUnits="userSpaceOnUse">
      <stop stop-color="#32B3F0"/>
      <stop offset="1" stop-color="#0CB6AA"/>
    </linearGradient>
    <linearGradient id="hill_gradient" x1="256" y1="256" x2="256" y2="512" gradientUnits="userSpaceOnUse">
      <stop stop-color="#1CB496"/>
      <stop offset="1" stop-color="#0A988D"/>
    </linearGradient>
  </defs>
</svg>
```

---

## 5. Accessibility & Implementation Rules

1. **Target Dimensions:** Every interactive control guarantees at least **44x44 pt** touch target (`ADaySpacing.minTouchTargetConstraints`).
2. **Text Scaling:** No static overflow-prone container heights; flexible wrapping with Vietnamese tone mark breathing room.
3. **Corner Radii:** Strictly $\le 16$px for surfaces and cards (`ADaySpacing.surfaceRadius`); 12px for controls (`ADaySpacing.controlRadius`); 999px only for pills (`ADaySpacing.pillRadius`).
4. **The More-Than-Color Rule:** Colors never carry status alone; icons or explicit textual tags accompany all states (Completed, Postponed, Cancelled, Overdue).
5. **State Motion:** Subtle 150–250ms curves without perpetual autoplay animations.
