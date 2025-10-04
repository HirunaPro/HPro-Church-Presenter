# Singlish Search Guide

## Overview
The Church Presentation App now supports **Singlish (romanized) search** for both **Sinhala** and **Tamil** songs. This means you can search for songs by typing in English letters, making it much easier to find songs without needing to type in native scripts.

## How to Use

### Search Examples

#### For Sinhala Songs
If you have a Sinhala song titled **"ඔබ දිව්‍ය පාමුලේ…"**, you can search for it using:
- `oba` → will find "**O**ba divya paamule"
- `divya` → will find "Oba **divya** paamule"
- `paamule` → will find "Oba divya **paamule**"
- `oba divya` → will find "**Oba divya** paamule"

#### For Tamil Songs
If you have a Tamil song titled **"என் இயேசுவே நீரே எனக்கு"**, you can search for it using:
- `en` → will find "**En** Yesuve"
- `yesuve` → will find "En **Yesuve** neere"
- `neere` → will find "En Yesuve **neere**"
- `yesuve neere` → will find "En **Yesuve neere**"

### Search Features

1. **Multi-script Search**: You can search in:
   - Singlish (romanized English)
   - Native Sinhala script
   - Native Tamil script

2. **Fuzzy Matching**: The search is smart and handles common variations:
   - `aa` vs `a` (e.g., both `paamule` and `pamule` will work)
   - `ee` vs `e` or `i`
   - `oo` vs `o` or `u`
   - `v` vs `w`
   - `sh` vs `s`
   - `th` vs `t`

3. **Search in Phrases**: The search also looks inside song lyrics, not just titles.

## Transliteration Reference

### Sinhala to Singlish

| Sinhala | Singlish | Example |
|---------|----------|---------|
| ක | ka | ඔබ = oba |
| ප | pa | පාමුලේ = paamule |
| ම | ma | මම = mama |
| ය | ya | යේසු = yesu |
| ව | va | දිව්‍ය = divya |
| ස | sa | සිටිමි = sitimi |
| හ | ha | හඬින් = hadin |

### Tamil to Singlish

| Tamil | Singlish | Example |
|-------|----------|---------|
| என் | en | என் = en |
| இயேசு | yesu | இயேசு = yesu |
| நீர் | neer | நீர் = neer |
| என்றும் | endrum | என்றும் = endrum |
| தேவை | dhevai | தேவை = dhevai |

### Vowels

| Sinhala | Tamil | Singlish |
|---------|-------|----------|
| අ | அ | a |
| ආ | ஆ | aa |
| ඉ | இ | i |
| ඊ | ஈ | ii |
| උ | உ | u |
| ඌ | ஊ | uu |
| එ | எ | e |
| ඒ | ஏ | ee |
| ඔ | ஒ | o |
| ඕ | ஓ | oo |

## Tips for Best Results

1. **Start with key words**: Search for distinctive words from the song title
2. **Use partial words**: Even typing a few letters will show matching songs
3. **Try variations**: If you're not sure about the exact spelling, try common variations (e.g., `w` or `v`)
4. **Search is case-insensitive**: `YESU`, `Yesu`, and `yesu` all work the same

## Technical Details

The transliteration system:
- Automatically converts Sinhala/Tamil text to romanized Singlish
- Performs phonetic matching for better results
- Supports both exact and fuzzy matching
- Works in real-time as you type
- No need to configure anything - it works automatically!

## Adding Songs

When you add new Sinhala or Tamil songs through the bulk import feature, they will automatically be searchable in Singlish. No special configuration is needed.

## Troubleshooting

**Q: Search is not working?**
- Make sure you've reloaded the page after the update
- Check the browser console (F12) for any errors

**Q: Can't find a song even with Singlish search?**
- Try searching for just a small part of the title
- Use the fuzzy search by trying different spelling variations
- Make sure the song file exists in the `/songs` directory

**Q: Want to disable Singlish search?**
- The system falls back to regular search if transliteration.js is not loaded
- Simply remove the script tag from operator.html

## Examples in Action

### Example 1: Searching for Sinhala Song
**Song Title**: "ඔබ දිව්‍ය පාමුලේ…"

You can search with:
- `oba` ✓
- `diwya` ✓
- `pamule` ✓
- `yesu` ✓ (if "යේසු" appears in lyrics)

### Example 2: Searching for Tamil Song
**Song Title**: "என் இயேசுவே நீரே எனக்கு"

You can search with:
- `en` ✓
- `yesu` ✓
- `neere` ✓
- `enakku` ✓

---

**Enjoy easier song searching with Singlish support!** 🎵
