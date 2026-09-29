# Operator UI Quick Reference

## 📐 Layout Overview

```
┌─────────────────────────────────────────────────────────┐
│  ☰                    OPERATOR INTERFACE                │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  QUICK CONTROLS (Always Visible)                        │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Font: [S] [M] [L] [XL]  [🎉 Welcome]  Now: ...   │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  TABS                                                    │
│  ┌──────────────────┬──────────────────┐                │
│  │  📺 Screens      │  🎵 Songs ✓      │                │
│  └──────────────────┴──────────────────┘                │
│                                                          │
│  TAB CONTENT (Scrollable)                                │
│  ┌────────────────────────────────────────────────────┐ │
│  │                                                     │ │
│  │  [Songs Tab - Selected: දෙවිදුනි ඔබගේ...]    ✕   │ │
│  │                                                     │ │
│  │  ┌───────────────────────────────────────────────┐ │ │
│  │  │ Phrase 1: දෙවිදුනි ඔබගේ ප්‍රේමය           │ │ │
│  │  │ කෙයි කරම් විශ්වදූ                          │ │ │
│  │  └───────────────────────────────────────────────┘ │ │
│  │  ┌───────────────────────────────────────────────┐ │ │
│  │  │ Phrase 2: මත සතුරලන් විසා                  │ │ │
│  │  │ මත පොලලින් විසා                            │ │ │
│  │  └───────────────────────────────────────────────┘ │ │
│  │  ┌───────────────────────────────────────────────┐ │ │
│  │  │ Phrase 3: ...                                  │ │ │
│  │  └───────────────────────────────────────────────┘ │ │
│  │                                                     │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Features

### 1. Quick Controls Bar
**Location:** Top (always visible)
**Contains:**
- Font size buttons (S, M, L, XL)
- Welcome screen quick button
- Current display indicator

### 2. Tab System
**Tabs:**
- 📺 **Screens** - Quick slides & custom text
- 🎵 **Songs** - Selected song phrases

### 3. Screens Tab
**Grid of Quick Buttons:**
- 👋 Welcome
- 📖 Sermon
- 🙏 Prayer
- 📢 Announcements
- ⬛ Blank Screen

**Custom Text Area:**
- Textarea for Bible verses
- "Show Custom Text" button

### 4. Songs Tab
**When Song Selected:**
- Green header with song title
- ✕ Clear button
- Scrollable phrase list

**Empty State:**
- 🎵 Icon + helpful message

---

## 📱 Mobile Layout

```
┌─────────────────────────┐
│  ☰ (Menu)               │
├─────────────────────────┤
│ Font: [S][M][L][XL]     │
│ [🎉 Welcome]            │
│ Now: Welcome...         │
├─────────────┬───────────┤
│ 📺 Screens  │ 🎵 Songs ✓│
├─────────────┴───────────┤
│                         │
│  [Selected Song]    ✕   │
│                         │
│  ┌─────────────────────┐│
│  │ Phrase 1            ││
│  │ Multi-line          ││
│  └─────────────────────┘│
│  ┌─────────────────────┐│
│  │ Phrase 2            ││
│  └─────────────────────┘│
│                         │
│  ▼ Scroll for more      │
│                         │
└─────────────────────────┘
```

---

## 🎨 Color Guide

| Element | Color | When |
|---------|-------|------|
| Font button | Gray (#e0e0e0) | Inactive |
| Font button | Green (#4CAF50) | Active |
| Welcome button | Gold gradient | Always |
| Now indicator | Orange tint | Always |
| Tab | Gray (#f5f5f5) | Inactive |
| Tab | White + blue line | Active |
| Screen card | White/Light blue | Default |
| Phrase | White | Default |
| Phrase | Light blue | Hover |
| Phrase | Green | Active/Playing |
| Song header | Green | When selected |

---

## ⚡ Quick Actions

### Change Font Size
1. Tap S, M, L, or XL at top
2. Font changes immediately

### Show Welcome Screen
1. Tap 🎉 button at top
2. Appears instantly

### Display Quick Screen
1. Tap "📺 Screens" tab
2. Tap any screen button

### Show Custom Text
1. Tap "📺 Screens" tab
2. Type in textarea
3. Tap "Show Custom Text"

### Select & Display Song
1. Tap ☰ to open menu
2. Search (optional)
3. Tap song name
4. Menu closes, switches to Songs tab
5. Tap any phrase to display

### Clear Song
1. In Songs tab
2. Tap ✕ button in green header

---

## 📊 Space Efficiency

### Before (Old Design)
```
Control Panel:     ~400px
Phrases Section:   Remaining space
Scrolling:         Everything together
```

### After (New Design)
```
Quick Controls:    ~60px (fixed)
Tabs:              ~50px (fixed)
Content Area:      Remaining (full height)
Scrolling:         Per tab
```

**Result:** More vertical space for phrases! 🎉

---

## 🔄 Automatic Behaviors

1. **Song Selection** → Switches to Songs tab
2. **Song Selection** → Closes mobile menu
3. **Tab Switch** → Smooth fade transition
4. **Phrase Click** → Highlights in green
5. **Mobile Menu** → Overlay + slide-in

---

## ✅ Best Practices

### For Operators
1. Keep Songs tab open during service
2. Use Welcome button for quick transitions
3. Tap phrases instead of scrolling
4. Clear selection between songs for cleaner view

### For Mobile Users
1. Use hamburger menu to access songs
2. Menu auto-closes after selection
3. Full-screen the browser for more space
4. Use landscape mode for wider phrases

---

## 🆘 Troubleshooting

**Can't see phrases?**
- Make sure you're on Songs tab
- Check if song is selected (green header)
- Try tapping ✕ and selecting again

**Controls too small?**
- Zoom browser (pinch gesture)
- Try landscape orientation
- Consider using tablet instead

**Tab won't switch?**
- Check JavaScript errors in console
- Refresh the page
- Clear browser cache

