-- blockquote_box.lua
-- Pandoc Lua filter: wrap BlockQuote nodes with LaTeX environment markers
-- The filter replaces BlockQuote blocks with RawBlock markers that the LaTeX
-- template defines as an environment producing a light-gray box.

local pandoc = pandoc

function BlockQuote(blk)
  -- Wrap the blockquote content in raw LaTeX begin/end markers.
  -- We emit a custom environment `grayquote` that must be defined in the
  -- LaTeX template preamble.
  local open = pandoc.RawBlock('latex', '\\begin{grayquote}')
  local close = pandoc.RawBlock('latex', '\\end{grayquote}')

  -- The BlockQuote contains a list of blocks; return open, then the contents, then close
  local out = {open}
  for _, b in ipairs(blk.content) do table.insert(out, b) end
  table.insert(out, close)
  return out
end
