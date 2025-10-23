#!/usr/bin/env python3
"""
expand_scripture.py - Expand Bible references to full ASV text

Usage: python scripts/expand_scripture.py <input_file> [output_file]

Replaces [[Book Chapter:Verse-Verse]] with actual scripture text from ASV.
Example: [[Luke 10:30-37]] -> full text of those verses

If output_file is not specified, prints to stdout.
"""

import sys
import re
import requests
from pathlib import Path

# Bible API endpoint (using bible-api.com which supports ASV)
BIBLE_API_URL = "https://bible-api.com/{reference}?translation=asv"

def parse_reference(ref_text):
    """
    Parse a reference like "Luke 10:30-37" into components.
    Returns: (book, chapter, start_verse, end_verse)
    """
    # Match patterns like "Luke 10:30-37" or "John 3:16"
    match = re.match(r'^([A-Za-z\s]+)\s+(\d+):(\d+)(?:-(\d+))?$', ref_text.strip())
    if not match:
        return None
    
    book = match.group(1).strip()
    chapter = int(match.group(2))
    start_verse = int(match.group(3))
    end_verse = int(match.group(4)) if match.group(4) else start_verse
    
    return (book, chapter, start_verse, end_verse)

def fetch_scripture(book, chapter, start_verse, end_verse):
    """
    Fetch scripture text from Bible API.
    Returns the scripture text or None if error.
    """
    if start_verse == end_verse:
        reference = f"{book} {chapter}:{start_verse}"
    else:
        reference = f"{book} {chapter}:{start_verse}-{end_verse}"
    
    try:
        url = BIBLE_API_URL.format(reference=reference.replace(' ', '%20'))
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        
        data = response.json()
        
        # Get verses individually to preserve structure
        verses = data.get('verses', [])
        if verses:
            # Format each verse on its own line
            verse_texts = []
            for verse in verses:
                text = verse.get('text', '').strip()
                # Clean up verse numbers in brackets
                text = re.sub(r'^\[\d+\]\s*', '', text)
                verse_texts.append(text)
            text = ' '.join(verse_texts)
        else:
            # Fallback to combined text
            text = data.get('text', '').strip()
            text = re.sub(r'\[\d+\]\s*', '', text)
        
        # Remove extra whitespace
        text = re.sub(r'\s+', ' ', text)
        
        return text
    except Exception as e:
        print(f"Error fetching {reference}: {e}", file=sys.stderr)
        return None

def expand_references(content):
    """
    Find all [[Reference]] patterns and replace with scripture text.
    """
    def replace_reference(match):
        ref_text = match.group(1)
        parsed = parse_reference(ref_text)
        
        if not parsed:
            print(f"Warning: Could not parse reference: {ref_text}", file=sys.stderr)
            return match.group(0)  # Return unchanged
        
        book, chapter, start_verse, end_verse = parsed
        scripture = fetch_scripture(book, chapter, start_verse, end_verse)
        
        if scripture is None:
            print(f"Warning: Could not fetch scripture for: {ref_text}", file=sys.stderr)
            return match.group(0)  # Return unchanged
        
        # Format the output with aside block and citation
        citation = f"{book} {chapter}:{start_verse}"
        if start_verse != end_verse:
            citation += f"-{end_verse}"
        citation += " (ASV)"
        
        return f'::: aside\n"{scripture}"\n:::\n'
    
    # Find all [[...]] patterns
    pattern = r'\[\[([^\]]+)\]\]'
    return re.sub(pattern, replace_reference, content)

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    input_file = Path(sys.argv[1])
    output_file = Path(sys.argv[2]) if len(sys.argv) > 2 else None
    
    if not input_file.exists():
        print(f"Error: Input file not found: {input_file}", file=sys.stderr)
        sys.exit(1)
    
    # Read input file
    content = input_file.read_text(encoding='utf-8')
    
    # Expand scripture references
    expanded_content = expand_references(content)
    
    # Write output
    if output_file:
        output_file.write_text(expanded_content, encoding='utf-8')
        print(f"Expanded scripture references written to: {output_file}")
    else:
        print(expanded_content)

if __name__ == '__main__':
    main()
