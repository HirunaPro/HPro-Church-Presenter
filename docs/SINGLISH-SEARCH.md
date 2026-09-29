# Singlish Search

Operators can search Sinhala and Tamil songs by typing romanized text ("Singlish"), or in native script. Titles and lyrics are searched, results update as you type, and no configuration is needed. If `js/transliteration.js` fails to load, search falls back to plain matching.

## Examples

| Song | Working searches |
|------|------------------|
| ඔබ දිව්‍ය පාමුලේ… | `oba`, `divya`, `dhivya`, `pamule`, `paamule` |
| මාව ගලවාගත් දෙවිඳා ඔබයි | `mawa`, `galava`, `devinda` |
| අඳුර මැදින් එළිය ගලනවා… | `andura`, `medin`, `eliya` |
| ජීවමාන යේසුස් | `jesus`, `yesus`, `jivamaana` |
| என் இயேசுவே நீரே எனக்கு | `en`, `yesuve`, `neere`, `enakku` |

## Tips

- Use distinctive words or partial words; case does not matter.
- Multiple keywords narrow results (`yesu premaya`).
- If nothing matches, shorten the query, drop doubled letters (`paamule` -> `pamule`), or try `v`/`w`, `s`/`sh`, `j`/`y`.
- Newly imported Sinhala/Tamil songs are searchable automatically.

## Common keywords

| Singlish | Sinhala | Tamil | Meaning |
|----------|---------|-------|---------|
| yesu | යේසු | இயேசு | Jesus |
| dewiya / dhevan | දෙවියා | தேவன் | God |
| prabhu / andavar | ප්‍රභු | ஆண்டவர் | Lord |
| mahima / mahimai | මහිමය | மகிமை | Glory |
| stuthi / sthothiram | ස්තුති | ஸ்தோத்திரம் | Praise |
| prarthana | ප්‍රාර්ථනා | ப்ரார்த்தனை | Prayer |
| premaya / anbu | ප්‍රේමය | அன்பு | Love |
| oba / neer | ඔබ | நீர் | You |
| mama / nan | මම | நான் | I/Me |

## How it works

`js/transliteration.js` provides `toSinglish()` (Sinhala and Tamil to Latin) and a fuzzy matcher, used by `js/operator.js`.

Transliteration handles consonant + virama (්) + vowel-sign combinations (the inherent "a" is dropped when a vowel sign or virama follows), the zero-width joiner (U+200D), and characters such as `ඳ` (`nda`).

Fuzzy matching tries an exact match first, then compares phonetically normalized forms of query and target:

- Aspirates: `dh`/`d`, `th`/`t`, `bh`/`b`, `gh`/`g`, `kh`/`k`, `ph`/`p`
- Repeated vowels collapse: `aa`->`a`, `ee`->`e`, `ii`->`i`, `oo`->`o`, `uu`->`u`; also `ae`->`e`, `ai`->`i`, `mae`->`me`
- Equivalents: `w`/`v`, `y`/`j`, `ll`->`l`, `nda`->`nd`, `sh`->`s`
- Trailing `na` -> `n`

Client-side only, no dependencies.

## Testing

Start the server (`python3 src/server/server.py`), open `http://localhost:8000/operator.html`, and search for the examples above.
