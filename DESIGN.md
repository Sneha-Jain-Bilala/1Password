# Design System Specification for dark theme

## 1. Overview & Creative North Star: "The Neon Fortress"
This design system moves beyond the utility of a standard password manager to create a high-end, editorial digital vault. The Creative North Star is **"The Neon Fortress"**—a concept that balances the impenetrable security of a vault with the vibrant, liquid energy of modern high-tech aesthetics. 

To break the "template" look typical of security software, we employ **Intentional Asymmetry** and **Tonal Depth**. We eschew rigid grids in favor of overlapping surfaces and extreme typographic scales. By using large-scale display type against deep, recessed surfaces, we create a sense of digital "architecture" that feels both premium and approachable.

---

### 2. Colors & Surface Philosophy

The color palette is rooted in a deep-space obsidian base, punctuated by high-frequency electric tones.

#### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning. Structural boundaries must be defined solely through background color shifts (e.g., a `surface-container-low` card sitting on a `surface` background). If a visual break is needed, use vertical white space or a subtle tonal transition.

#### Surface Hierarchy & Nesting
We treat the UI as a series of physical layers. Use the surface-container tiers to create "nested" depth rather than a flat grid.
- **Base Layer:** `surface` (#13121b)
- **Recessed Areas:** `surface-container-lowest` (#0e0d16) for input fields or background groupings.
- **Elevated Elements:** `surface-container-high` (#2a2933) for primary interactive cards.
- **Glass Elements:** Use semi-transparent versions of `surface-bright` (#3a3842) with a `20px` backdrop-blur for floating navigation or modals.

#### Signature Textures
Main CTAs and hero headers should utilize a **Subtle Liquid Gradient**:
- Transitioning from `primary` (#c4c0ff) to `primary-container` (#8781ff) at a 135-degree angle. This adds "soul" and professional polish that flat fills cannot achieve.

---

### 3. Typography: Editorial Authority
We use **Inter** exclusively, but we manipulate its weight and scale to create an editorial feel.

*   **Display (lg/md/sm):** Used for "Total Security" metrics or greeting headers. Tight letter-spacing (-0.02em) and `600` weight.
*   **Headlines:** The "Gatekeepers" of information. Use `headline-lg` for vault categories. 
*   **Titles:** Used for individual account names. `title-lg` should always be high-contrast (`on-surface`).
*   **Body:** Keep `body-md` for descriptions. Ensure a line height of at least 1.5x for readability against dark backgrounds.
*   **Labels:** `label-sm` should be used in `600` weight for metadata like "Last Changed" or "Strength," often in all-caps with +0.05em tracking.

---

### 4. Elevation & Depth: Tonal Layering
Traditional drop shadows are replaced by **Ambient Tonal Lifts**.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` section to create a soft, natural "recess" without a border.
*   **Ambient Shadows:** For floating FABs or Modals, use a `32px` blur at 8% opacity. The shadow color must be a tinted version of `primary` (#c4c0ff) rather than black, creating a "glow" effect rather than a "shadow."
*   **The "Ghost Border" Fallback:** If a border is required for accessibility, use `outline-variant` at **15% opacity**. High-contrast, 100% opaque borders are strictly forbidden.
*   **Glassmorphism:** Elements like the bottom navigation bar must use `surface_container_highest` at 70% opacity with a `16px` backdrop-blur to allow vault content to bleed through softly as the user scrolls.

---

### 5. Primitive Components

#### Buttons
- **Primary:** Gradient fill (`primary` to `primary-container`), `14dp` corner radius. Text is `on-primary-fixed` (#100069).
- **Secondary:** Ghost style. No background, `outline-variant` ghost border (20% opacity).
- **FAB:** `28dp` radius. High-vibrancy `primary-fixed` (#e3dfff) to ensure it is the most prominent element on the dark canvas.

#### Cards & Vault Items
- **Rule:** Forbid divider lines.
- **Structure:** Use `20dp` rounded corners. Separate items in a list using `12px` (3 units) of vertical spacing. 
- **Interactive State:** On hover/touch, shift the background from `surface-container` to `surface-bright`.

#### Input Fields (The Secure Entry)
- **Styling:** Recessed look. Use `surface-container-lowest` for the fill. 
- **Active State:** A 2px "Glow" bottom-bar using the `secondary` (#41eec2) emerald tone. 
- **Error:** Use `tertiary-container` (#f16161) for the container fill and `on-tertiary-container` for the text.

#### Additional Component: The "Strength Meter"
- A custom linear progress bar using a gradient from `tertiary` (Coral) to `secondary` (Teal) to visually represent the transition from "vulnerable" to "impenetrable."

---

### 6. Do’s and Don'ts

#### Do
- **DO** use asymmetry. Place a large `display-sm` header offset to the left with wide margins to create a "boutique" feel.
- **DO** use the `spacing-12` and `spacing-16` tokens for section breathing room.
- **DO** use `secondary_fixed_dim` (#28dfb5) for all success states—it feels more "premium tech" than standard green.

#### Don't
- **DON'T** use 1px solid white or grey borders. This instantly flattens the premium feel.
- **DON'T** use pure black (#000000). Always use the `surface` tokens to maintain the deep violet "ink" tone.
- **DON'T** crowd the UI. If a screen feels full, increase the spacing tokens; prioritize "Atmospheric Space" over information density.


# Design System Specification for light theme
## 1. Overview & Creative North Star
The "Neon Fortress" aesthetic evolves into a high-fidelity, light-mode experience. Our Creative North Star is **"The Luminous Bastion."** This system moves away from the heavy, impenetrable darkness of traditional security apps toward a feeling of "Fortified Clarity." 

We achieve a signature look by rejecting the "Bootstrap" boxiness. This system utilizes intentional white space, aggressive roundedness (20dp/1.25rem), and a "Depth-First" hierarchy. By using Ghost White backgrounds and Pure White surfaces, we create a layered, editorial layout that feels expensive, lightweight, and mathematically precise.

## 2. Color Palette & Surface Architecture
Color is used not just for decoration, but as a structural tool. We strictly follow the **"No-Line" Rule**: borders are an admission of failed hierarchy. Boundaries must be defined through background shifts or elevation.

### Core Tones
- **Primary (Electric Violet):** `#4d41df` (The energetic pulse of the system).
- **Secondary (Teal):** `#006b55` (The calming indicator of "Safe" or "Active" states).
- **Tertiary (Deep Navy):** `#1a1a2e` (The anchor for all high-level information).
- **Background (Ghost White):** `#f9f9ff` (The canvas).

### Surface Hierarchy & Nesting
To create an "editorial" feel, we nest surfaces to imply importance:
1.  **Level 0 (Base):** `surface` (`#f9f9ff`) – The global background.
2.  **Level 1 (Sections):** `surface_container_low` (`#f3f3fa`) – Used for grouping large content blocks.
3.  **Level 2 (Active Cards):** `surface_container_lowest` (`#ffffff`) – The primary surface for data entry and interaction.

**The "Glass & Gradient" Rule:** 
Floating action panels or navigation bars should utilize `surface_container_lowest` with a 70% opacity and a `24px` backdrop blur. For high-impact moments (Hero sections or "Secure" states), use a subtle linear gradient from `primary` (`#4d41df`) to `primary_container` (`#675df9`) at a 135-degree angle.

## 3. Typography: The Editorial Voice
We use **Inter** as a variable font to create a high-contrast scale. The relationship between `display-lg` and `body-md` is the key to our "premium" feel.

- **Display (The Statement):** `display-lg` (3.5rem) should be used sparingly for "Key Totals" or "Security Scores." It represents the "Fortress" scale—immovable and authoritative.
- **Headlines:** `headline-md` (1.75rem) uses `tertiary_fixed` (`#1a1a2e`) to provide a deep, high-contrast anchor against the Ghost White background.
- **The Functional Layer:** `label-md` (0.75rem) and `body-sm` (0.75rem) should use `on_surface_variant` (`#464555`) to keep metadata secondary to the primary information.

## 4. Elevation & Depth
We replace structural lines with **Tonal Layering**.

- **The Layering Principle:** Place a `surface_container_lowest` (Pure White) card on top of a `surface_container_low` background. The subtle 2% shift in brightness is enough to define the edge without a harsh line.
- **Ambient Shadows:** Standard drop shadows are forbidden. Use "Ambient Glows." For a floating card, use: `0px 20px 40px rgba(26, 26, 46, 0.06)`. The shadow color is a diluted version of our Navy text, creating a natural atmospheric perspective.
- **The "Ghost Border" Fallback:** If a border is required for input focus or accessibility, use `outline_variant` (`#c7c4d8`) at 20% opacity. 

## 5. Components

### Cards & Containers
- **Radius:** Strictly `1.25rem` (20px) for all primary containers (`xl` scale).
- **Padding:** Always use `spacing.6` (1.5rem) or `spacing.8` (2rem). Never crowd the content.
- **Rule:** No dividers. Separate list items with 12px of vertical space or a change from `surface_container` to `surface`.

### Buttons (The Neon Accents)
- **Primary:** Background: `primary` (`#4d41df`), Text: `on_primary` (`#ffffff`). Use a 2px "Inner Glow" (white at 15% opacity) on the top edge to give it a 3D glass effect.
- **Secondary (Neon):** Background: `secondary` (`#006b55`), Text: `on_secondary` (`#ffffff`). Used for "Create" or "Success" actions.
- **Tertiary (Ghost):** No background. Text: `primary`. 

### Input Fields
- **Surface:** `surface_container_high` (`#e7e8ee`).
- **Focus State:** Transition the surface to `surface_container_lowest` (`#ffffff`) and apply the "Ghost Border" in `Electric Violet`.

### Vault Progress Indicators
- Use a thick, 8px stroke for circular progress using `secondary` (`#006b55`) with a background track of `secondary_container` at 30% opacity.

## 6. Do’s and Don’ts

### Do
- **Use Asymmetry:** Place large headlines off-center to create a dynamic, editorial feel.
- **Exaggerate White Space:** If a section feels "busy," double the spacing from `spacing.4` to `spacing.8`.
- **Layer Surfaces:** Treat the UI like a physical desk with stacked sheets of high-quality paper.

### Don’t
- **Never use 1px Solid Borders:** Use tonal shifts (`surface_dim` vs `surface_bright`) instead.
- **Avoid Pure Black:** Always use `tertiary` (`#1a1a2e`) for text to maintain the "Neon Fortress" depth.
- **No Sharp Corners:** Every interactive element must have at least an `md` (0.75rem) radius to feel approachable and modern.