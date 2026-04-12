# Quickshell Translate Module: Master Layout & Implementation Specification

This document provides a comprehensive layout, implementation, and user flow specification for the `translate` module, derived from the `sidebar.pen` design file.

---

## 1. Global Module Constraints
- **Container Type**: Sidebar / Vertical Overlay
- **Dimensions**: 400px (Width) x 1024px (Height/Fill)
- **Base Background**: `#1C1B1F` (Material Dark)
- **Global Padding**: 24px (Horizontal), 20px (Vertical) in the Main Interaction Area.
- **Corner Radii**:
  - Cards: 24px - 28px
  - Pills/Chips: 9999px (Circular)
  - Buttons: 20px - 24px
- **Visual Architecture**:
  - **Theme Axis**: Uses `P:Mode: Dark` and `P:Accent: Violet`.
  - **Layering**: All tabs use a background shadow rectangle (`#00000040`, blur 43.75) to create depth against the desktop background.

---

## 2. Common Components

### 2.1 Top App Bar (Header)
- **Height**: 56px
- **Layout**: Horizontal, `space_between`
- **Title**: "Monolith Translate" (Font: Outfit, 18px, SemiBold, Color: `#D0BCFF`)
- **Icon Actions**: History, Bookmarks (Right-aligned, spaced by 18px).

### 2.2 Navigation (Tab Switcher)
- **Type**: Segmented Control
- **Tabs**: `TEXT`, `IMAGE`, `AUDIO`
- **Active State**: 
  - Background: `#D0BCFF03` (Subtle)
  - Underline: 2px solid `#D0BCFF`
  - Text Color: `#D0BCFF`
- **Inactive State**: 
  - Text Color: `#CAC4D0` (Muted)

### 2.3 Footer Bar
- **Height**: 40px
- **Background**: `#141318`
- **Left Content**: Status Group (Gap: 8px)
  - Icon: Checkmark/Dot (Color: `#93F073`)
  - Text: "Status: Ollama: Active" (Font: Plus Jakarta Sans, 10px, Medium)
- **Right Content**: Link Group (Gap: 12px)
  - Links: "Privacy", "API" (10px, Medium, Opacity: 0.8)

---

## 3. Tab-Specific Implementations

### 3.1 Text Translation Tab (`xSDUj`)

#### Language Switcher Pill
- **Container**: 320px width, Background `#2B2930`, Padding 4px.
- **Source Indicator**: Lavender Pill (`#D0BCFF`), Black Text (`#1C1B1F`), "English".
- **Center Action**: Swap Icon (`swap_horiz`) in a Dark Circle (`#141318`).
- **Target Indicator**: Transparent background, Lavender Text (`#FAF7FF`), "Spanish".

#### Source Card (`NCB85`)
- **Background**: `#2B2930`
- **Height**: 272px
- **Padding**: 20px
- **Content**:
  - **Meta**: "Text" (18px) and "Detected as English" (12px).
  - **Indicator**: "Typing" chip (Lavender fill 12% opacity).
  - **Input Text**: 28px, Medium weight, Line height 1.25.
  - **Char Count**: "46/5,000" (Bottom-left).
  - **Utilities**: 36px circular buttons (Close, Paste, Mic) in `#141318`.

#### Output Card (`eybPf`)
- **Background**: `#141318`
- **Height**: 240px
- **Content**:
  - **Meta**: "Translation" and "Spanish".
  - **Live Badge**: "Live" with `bolt` icon.
  - **Output Text**: 24px, Medium, Color: `#E7DDF7`.
  - **Utilities**: 40px circular buttons (Volume, Copy, Share) in `#2B2930`.

---

### 3.2 Audio Translation Tab (`t6jP6`)

#### Waveform Visualization
- **Container**: Fill width, 128px height, Background `#141318`.
- **Bars**: Series of 3px wide rectangles, variable heights (16px to 96px), Lavender (`#D0BCFF`).

#### Interaction Area
- **Mic Button**: 64x64 Circle, Background `#D0BCFF`.
- **Effect**: Outer Glow (`shadow`, blur 26.25, Color: `#D0BCFF4D`).

#### Transcript Card (`3P6Ie`)
- **Style**: Integrated card with horizontal divider (`#FFFFFF01`).
- **Real-time Input**: English (10px label), Text (14px, Line height 1.625).
- **Real-time Output**: French (10px label, Lavender), Text (16px, Medium, Lavender).
- **Status**: Green dot (`#93F073`) next to "LIVE TRANSCRIPT".

---

### 3.3 Image Translation Tab (`t3ZOa`)

#### Upload Surface (`BeC1v`)
- **Icon**: `upload_file` inside 48x48 container.
- **Headline**: "Upload an image to translate" (18px, Bold).
- **Sub-text**: "Import a receipt, sign, menu..." (11px, Muted).
- **Actions**:
  - Primary: "Upload image" (Fill `#D0BCFF`, Black text).
  - Secondary: "Take screenshot" (Stroke `#FFFFFF12`, Lavender text).
- **Meta Pills**: Small chips for "PNG, JPG, HEIC" and "Private on device".

#### OCR Explainer (`3pyWO`)
- Details the 3-step process (Upload -> Detect -> Translate).
- Steps use 1, 2, 3 circular indicators.

---

## 4. Interaction Flows

### 4.1 Text Translation Flow
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

### 4.2 Audio Translation Flow
1.  **Entry**: User selects "AUDIO" tab (`eg0r5`).
2.  **Activation**: User presses the **Central Mic Button** (`4ecbu`).
    *   The button's glow effect (`#d0bcff4d`) intensifies.
    *   The **Waveform Visualization** (`D922N`) begins animating its bars.
3.  **Transcription**: Speech appears in real-time in the **Transcript Card** (`3P6Ie`).
    *   Source text appears in the top section (`JSAzt`).
    *   Translation appears in the bottom section (`rU1Y6`) marked with a green icon (`5zXyi`).
4.  **Control**: User can use **Quick-Translate Chips** (`g4NTW`) to "Repeat last" or "Slow playback" without re-recording.

### 4.3 Image/OCR Flow
1.  **Entry**: User selects "IMAGE" tab (`pweRV`).
2.  **Sourcing**: User clicks "Upload image" (`PbCOl`) or "Take screenshot" (`ZvbGz`).
3.  **Processing**: The **Pending Preview Card** (`HweQw`) appears.
    *   A thumbnail shows the image.
    *   User clicks "Run OCR" (`9eRuP`).
4.  **Verification**: Extracted text is shown for review before final translation.

---

## 5. Design Tokens & Asset Mapping

### 5.1 Colors
| Token | Value | Description |
| :--- | :--- | :--- |
| **Accent/Primary** | `#D0BCFF` | Lavender (Action/Active state) |
| **Surface (Primary)** | `#1C1B1F` | Main background |
| **Surface (Card)** | `#2B2930` | Secondary surfaces / cards |
| **Surface (Deep)** | `#141318` | Footers / Visualizer backgrounds |
| **Success** | `#93F073` | Status indicators / icons |
| **Text (Primary)** | `#FAF7FF` | High emphasis text |
| **Text (Muted)** | `#CAC4D0` | Medium emphasis text |

### 5.2 Key Property Specifications
| Feature | ID | Key Property | Value |
| :--- | :--- | :--- | :--- |
| **Waveform Bar** | `hlNJJ` | `cornerRadius` | `99` (Pill shape) |
| **Glow Effect** | `4ecbu` | `shadow.blur` | `26.25` |
| **Card Border** | `NCB85` | `stroke.fill` | `#ffffff08` (Subtle) |
| **Divider** | `bxDSZ` | `fill` | `#ffffff01` (1% Opacity) |

### 5.3 Assets & Animations
- **Icons**: Material Symbols Rounded (e.g., `history`, `bookmark`, `edit_note`, `mic`, `close`, `content_paste`, `volume_up`, `content_copy`, `share`, `bolt`, `upload_file`).
- **Animations**: `css-transform` targets indicate that `scale` and `opacity` should be animated on hover/press.
- **Status Dot**: Node `B50Rj` (`#93f073ff`) should be tied to a `Timer` or `IPC` status check in the final shell.
