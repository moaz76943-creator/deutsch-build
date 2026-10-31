import unicodedata
from typing import List

def get_script(char: str) -> str:
    """Returns a simplified script categorization for a character."""
    if not char:
        return 'UNKNOWN'

    # Extract the base character's codepoint, ignoring combiners
    # For surrogate pairs in Python strings, taking the first character might give a surrogate code point.
    # Python 3 handles chars outside BMP natively (len(char) is 1 for non-surrogates).
    # If the grapheme cluster has length > 1 (like a base + combiner), check the base character.
    # If the character itself is a surrogate (e.g. from manual chr(0xD834) + chr(0xDD1E) creation),
    # we can try to resolve it, but typical CJK characters don't fall into this edge case for get_script.
    if len(char) > 1 and 0xD800 <= ord(char[0]) <= 0xDBFF and 0xDC00 <= ord(char[1]) <= 0xDFFF:
        # surrogate pair
        code = (ord(char[0]) - 0xD800) * 0x400 + (ord(char[1]) - 0xDC00) + 0x10000
    else:
        code = ord(char[0])

    # Hiragana: U+3040 - U+309F
    if 0x3040 <= code <= 0x309F:
        return 'HIRAGANA'

    # Katakana: U+30A0 - U+30FF
    if 0x30A0 <= code <= 0x30FF:
        return 'KATAKANA'

    # CJK Unified Ideographs (Kanji)
    if (0x4E00 <= code <= 0x9FFF or
        0x3400 <= code <= 0x4DBF or
        0x20000 <= code <= 0x2A6DF):
        return 'KANJI'

    # Latin (approximate)
    if 0x0000 <= code <= 0x024F:
        return 'LATIN'

    return 'OTHER'


def get_cluster_boundaries(text: str) -> List[int]:
    """
    Returns the start indices of each valid Unicode grapheme cluster in the text.
    Ensures surrogate pairs and combining characters are not split.
    """
    boundaries = []
    i = 0

    while i < len(text):
        boundaries.append(i)

        # Check for surrogate pairs (in Python strings, chars outside BMP are 1 char,
        # but just in case we are dealing with UTF-16 surrogate codepoints directly)
        if 0xD800 <= ord(text[i]) <= 0xDBFF and i + 1 < len(text) and 0xDC00 <= ord(text[i+1]) <= 0xDFFF:
            i += 2
        else:
            i += 1

        # Skip combining marks
        while i < len(text):
            category = unicodedata.category(text[i])
            if category.startswith('M') or category == 'Cf':  # Marks or formatting characters
                i += 1
            else:
                break

    # Add the end of the string as the final boundary
    boundaries.append(len(text))
    return boundaries
