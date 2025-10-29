#!/usr/bin/env python3
import os
import re
import argparse
from datetime import date

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'src', 'manuscript'))
TOC_PATH = os.path.join(ROOT, '00_05_TOC.md')

# Regex helpers
PREFIX_FILE_RE = re.compile(r'^(\d+)_([^/]+)\.md$')
CHAPTER_DIR_RE = re.compile(r'^CHAPTER_(\d+)$')
SPREAD_FILE_RE = re.compile(r'^SPREAD_(\d+)\.md$')


def list_root_pages():
	pages = []
	for name in os.listdir(ROOT):
		full = os.path.join(ROOT, name)
		if os.path.isfile(full) and PREFIX_FILE_RE.match(name):
			if name == os.path.basename(TOC_PATH):
				# We'll regenerate this file; don't list it in its own TOC
				continue
			# Skip 00_* production pages from TOC list
			if name.startswith('00_'):
				continue
			pages.append(name)
	def sort_key(n):
		m = PREFIX_FILE_RE.match(n)
		return int(m.group(1)) if m else 0
	pages.sort(key=sort_key)
	return pages


def list_chapters():
	chapters = []
	for name in os.listdir(ROOT):
		full = os.path.join(ROOT, name)
		if os.path.isdir(full):
			m = CHAPTER_DIR_RE.match(name)
			if m:
				chapters.append((int(m.group(1)), name))
	chapters.sort(key=lambda x: x[0])
	return chapters


def list_spreads(chapter_dir):
	entries = []
	for name in os.listdir(chapter_dir):
		m = SPREAD_FILE_RE.match(name)
		if m:
			entries.append((int(m.group(1)), name))
	entries.sort(key=lambda x: x[0])
	return [name for _, name in entries]


def read_front_matter_title(path: str) -> str | None:
	"""Extract a 'title' from simple YAML front matter without external deps.
	Expects a leading '---' block. Returns None if not found.
	"""
	try:
		with open(path, 'r', encoding='utf-8') as f:
			lines = f.readlines()
	except FileNotFoundError:
		return None
	if not lines or not lines[0].strip().startswith('---'):
		return None
	# find the closing '---'
	end = None
	for i in range(1, min(len(lines), 200)):
		if lines[i].strip().startswith('---'):
			end = i
			break
	if end is None:
		return None
	# scan for title: ... inside [1:end)
	title_re = re.compile(r'^title:\s*["\']?(.*?)["\']?\s*$')
	for i in range(1, end):
		m = title_re.match(lines[i].strip())
		if m:
			return m.group(1)
	return None


def parse_aux_for_pages(aux_path: str) -> dict:
	pages = {}
	if not aux_path or not os.path.exists(aux_path):
		return pages
	# Matches lines like: \newlabel{frag:CHAPTER_02_SPREAD_01}{{}{17}...}
	# or: \newlabel{frag:...}{{some}{17}...}
	newlabel_re = re.compile(r"\\newlabel\{([^}]+)\}\{\{[^}]*\}\{(\d+)\}")
	try:
		with open(aux_path, 'r', encoding='utf-8') as f:
			for line in f:
				m = newlabel_re.search(line)
				if m:
					pages[m.group(1)] = int(m.group(2))
	except Exception:
		pass
	return pages


def write_toc(aux_pages: dict | None = None):
	today = date.today().isoformat()

	lines = []
	# YAML front matter — keep stable fields, update date
	lines.append('---')
	lines.append('slug: toc')
	lines.append('number: 00.5')
	lines.append('title: Table of Contents')
	lines.append('status: draft')
	lines.append(f'updated: {today}')
	lines.append('public_only_check: ok')
	lines.append('---')
	lines.append('')
	# Spacing hint for LaTeX layout
	lines.append(r'\vspace*{1in}')
	lines.append('')

	# Root pages (exclude 00_* pages and TOC itself)
	root_pages = list_root_pages()
	# Friendly names for known root pages
	FRIENDLY = {
		'01_FOREWORD.md': 'Foreword',
		'02_EATING_THE_FRUIT.md': 'Eating the Fruit',
		'03_WHATS_AT_STAKE.md': "What’s at Stake",
	}
	def pretty(s: str) -> str:
		base = re.sub(r'^\d+_', '', os.path.splitext(s)[0])
		base = base.replace('_', ' ').replace('-', ' ')
		return base.title()
	use_hyperref = aux_pages is not None
	for name in root_pages:
		# Link text: friendly mapping or prettified
		link_text = FRIENDLY.get(name, pretty(name))
		# Page number for root page if available
		label = f"frag:{os.path.splitext(name)[0]}"
		rp_page = aux_pages.get(label) if aux_pages else None
		if use_hyperref:
			page_suffix = f" \\dotfill (p.~{rp_page})" if rp_page else ""
			lines.append(f'- \\hyperref[{label}]{{{link_text}}}{page_suffix}')
		else:
			page_suffix = f" \\dotfill (p. {rp_page})" if rp_page else ""
			lines.append(f'- [{link_text}](./{name}){page_suffix}')

	# Chapters and spreads
	for num, chname in list_chapters():
		# Insert a Markdown hard line break (two trailing spaces) on the last
		# emitted non-empty line to create extra spacing BEFORE each chapter only.
		# This keeps chapters separated without adding space between a chapter and its spreads.
		if lines:
			idx = len(lines) - 1
			while idx >= 0 and lines[idx] == '':
				idx -= 1
			if idx >= 0 and not lines[idx].endswith('  '):
				lines[idx] = lines[idx] + '  '
		# Derive chapter display name from intro title if available
		chdir = os.path.join(ROOT, chname)
		intro_path = os.path.join(chdir, '01_INTRO.md')
		intro_title = read_front_matter_title(intro_path) or 'Introduction'
		# Page for chapter intro if available
		intro_label = f'frag:{chname}_01_INTRO'
		ch_page = aux_pages.get(intro_label) if aux_pages else None
		suffix = f' \\dotfill (p.~{ch_page})' if (use_hyperref and ch_page) else (f' \\dotfill (p. {ch_page})' if ch_page else '')
		# Chapter line links directly to the Intro; no separate "Intro" entry
		if os.path.exists(intro_path):
			if use_hyperref:
				lines.append(f'- \\hyperref[{intro_label}]{{Chapter {num} - {intro_title}}}{suffix}')
			else:
				lines.append(f'- [Chapter {num} - {intro_title}](./{chname}/01_INTRO.md){suffix}')
		else:
			lines.append(f'- Chapter {num} - {intro_title}{suffix}')
		# Spreads as nested list items (no raw \hspace)
		for sp in list_spreads(chdir):
			sp_title = read_front_matter_title(os.path.join(chdir, sp)) or os.path.splitext(sp)[0]
			# Omit the word 'Spread' before the spreads — show just the title
			label = f'frag:{chname}_{os.path.splitext(sp)[0]}'
			sp_page = aux_pages.get(label) if aux_pages else None
			if use_hyperref:
				page_suffix = f' \\dotfill (p.~{sp_page})' if sp_page else ''
				lines.append(f'  - \\hyperref[{label}]{{{sp_title}}}{page_suffix}')
			else:
				page_suffix = f' \\dotfill (p. {sp_page})' if sp_page else ''
				lines.append(f'  - [{sp_title}](./{chname}/{sp}){page_suffix}')


	lines.append('')
	lines.append('---')
	lines.append('')

	content = '\n'.join(lines)

	# Only write if changed to avoid touching timestamps unnecessarily
	prev = None
	if os.path.exists(TOC_PATH):
		with open(TOC_PATH, 'r', encoding='utf-8') as f:
			prev = f.read()
	if prev != content:
		with open(TOC_PATH, 'w', encoding='utf-8') as f:
			f.write(content)
		print(f"Updated {TOC_PATH}")
	else:
		print(f"No changes needed for {TOC_PATH}")


if __name__ == '__main__':
	if not os.path.isdir(ROOT):
		raise SystemExit(f"Manuscript root not found: {ROOT}")
	parser = argparse.ArgumentParser(description='Generate manuscript TOC')
	parser.add_argument('--aux', help='Path to LaTeX AUX file for page numbers', default=None)
	args = parser.parse_args()
	pages = parse_aux_for_pages(args.aux) if args.aux else None
	write_toc(pages)

