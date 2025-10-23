-- preserve_footnote_numbers.lua
-- Preserves footnote numbers starting from 0 instead of 1

-- Track if we've injected the counter reset
local counter_reset_done = false

function Pandoc(doc)
  -- Inject the counter reset at the start of the document
  if not counter_reset_done then
    local reset = pandoc.RawBlock('latex', '\\setcounter{footnote}{-1}')
    table.insert(doc.blocks, 1, reset)
    counter_reset_done = true
  end
  return doc
end

