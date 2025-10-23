-- footnotes_to_footer.lua
-- Extracts footnotes and places them in front matter for footer rendering

local footnotes = {}
local footnote_counter = -1

-- Capture footnote content
function Note(note)
  footnote_counter = footnote_counter + 1
  local note_num = footnote_counter
  
  -- Store the footnote content
  footnotes[note_num] = note.content
  
  -- Return just the superscript mark in the text
  return pandoc.RawInline('latex', '\\textsuperscript{' .. note_num .. '}')
end

-- At the end, inject footnotes into metadata
function Pandoc(doc)
  if footnote_counter < 0 then
    return doc
  end
  
  -- Build the footer content
  local footer_parts = {}
  
  for i = 0, footnote_counter do
    if footnotes[i] then
      -- Convert to LaTeX
      local fn_latex = pandoc.write(pandoc.Pandoc(footnotes[i]), 'latex')
      fn_latex = fn_latex:gsub('\n+', ' '):gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')
      
      table.insert(footer_parts, '\\textbf{' .. i .. '.} ' .. fn_latex)
    end
  end
  
  -- Join with line breaks
  local footer_content = table.concat(footer_parts, '\\par\n')
  
  -- Set as metadata
  doc.meta['footer_notes'] = pandoc.MetaBlocks({pandoc.RawBlock('latex', footer_content)})
  
  return doc
end
