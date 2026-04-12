# Translate Module: User Flow & Implementation Deep-Dive

This document details the user journey and technical architecture for the `translate` module, derived from the `sidebar.pen` specification.

## 1. Interaction Flows

### 1.1 Text Translation Flow
1.  **Entry**: User selects the "TEXT" tab in the segmented navigation (`KDwYx`).
2.  **Configuration**: User interacts with the **Language Switcher Pill** (`QC3wT`). 
    *   Clicking "English" or "Spanish" triggers a dropdown (implied by `P:cTN8T` component).
    *   Clicking the **Swap Button** (`kBihi`) flips the source/target languages.
3.  **Input**: User types into the **Source Text Card** (`NCB85`). 
    *   As the user types, the "Typing" indicator (`hQjTM`) becomes visible.
    *   Character count (`xL0h0`) updates dynamically.
4.  **Execution**: User clicks "Translate now" (`xTemf`). 
    *   The **Live Badge** (`ybKRI`) in the output card pulses/lights up.
5.  **Result**: The **Translated Output Card** (`eybPf`) displays the result with "Updated just now" status.

### 1.2 Audio Translation Flow
1.  **Entry**: User selects "AUDIO" tab (`eg0r5`).
2.  **Activation**: User presses the **Central Mic Button** (`4ecbu`).
    *   The button's glow effect (`#d0bcff4d`) intensifies.
    *   The **Waveform Visualization** (`D922N`) begins animating its bars.
3.  **Transcription**: Speech appears in real-time in the **Transcript Card** (`3P6Ie`).
    *   Source text appears in the top section (`JSAzt`).
    *   Translation appears in the bottom section (`rU1Y6`) marked with a green icon (`5zXyi`).
4.  **Control**: User can use **Quick-Translate Chips** (`g4NTW`) to "Repeat last" or "Slow playback" without re-recording.

### 1.3 Image/OCR Flow
1.  **Entry**: User selects "IMAGE" tab (`pweRV`).
2.  **Sourcing**: User clicks "Upload image" (`PbCOl`) or "Take screenshot" (`ZvbGz`).
3.  **Processing**: The **Pending Preview Card** (`HweQw`) appears.
    *   A thumbnail shows the image.
    *   User clicks "Run OCR" (`9eRuP`).
4.  **Verification**: Extracted text is shown for review before final translation.

---

## 2. Technical Implementation Details

### 2.1 Visual Architecture
- **Theme Axis**: Uses `P:Mode: Dark` and `P:Accent: Violet`.
- **Layering**: All tabs use a background shadow rectangle (`#00000040`, blur 43.75) to create depth against the desktop background.
- **Hierarchy Mapping**:
    - `Root Frame` (400px, `#1c1b1f`)
    - `Header` (56px, `space_between`)
    - `Navigation` (64px, `gap: 4`)
    - `Content Area` (Vertical Scroll, `gap: 24/20`)
    - `Footer` (40px, `#141318`)

### 2.2 Key Property Specifications
| Feature | ID | Key Property | Value |
| :--- | :--- | :--- | :--- |
| **Accent Color** | - | `fill` | `#d0bcffff` |
| **Waveform Bar** | `hlNJJ` | `cornerRadius` | `99` (Pill shape) |
| **Glow Effect** | `4ecbu` | `shadow.blur` | `26.25` |
| **Card Border** | `NCB85` | `stroke.fill` | `#ffffff08` (Subtle) |
| **Divider** | `bxDSZ` | `fill` | `#ffffff01` (1% Opacity) |

### 2.3 Component Mapping for Quickshell
- **Icons**: Map to `Material Symbols Rounded` via `IconFont` components.
- **Animations**: `css-transform` targets indicate that `scale` and `opacity` should be animated on hover/press.
- **Status Dot**: Node `B50Rj` (`#93f073ff`) should be tied to a `Timer` or `IPC` status check in the final shell.
