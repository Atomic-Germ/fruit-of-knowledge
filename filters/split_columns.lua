-- split_columns.lua
-- Pandoc Lua filter: split a single-spread Markdown document into two columns using the paracol LaTeX package.
-- Default column mapping:
--   Left  column: "Received Teaching", "Tension", "Practice"
--   Right column: "Jesus' Public Words", "Reflection", "Notes"
-- The filter removes an initial H1 that duplicates the YAML title (to avoid title duplication),
-- then groups H2 sections and places them in the appropriate column.

local stringify = pandoc.utils.stringify

local function contains(hay, needle)
  return tostring(hay):lower():find(needle, 1, true) ~= nil
end

local function classifyHeader(name)
  local n = tostring(name):lower()
  if contains(n, 'received') or contains(n, 'tension') or contains(n, 'practice') then
    return 'left'
  elseif contains(n, 'jesus') or contains(n, 'public words') or contains(n, 'reflection') or contains(n, 'notes') then
    return 'right'
  else
    -- Default: place unknown sections in the right column
    return 'right'
  end
end

function Pandoc(doc)
  local blocks = doc.blocks
  local sections = {}
  local current = '__preamble__'
  sections[current] = {}

  -- Optionally skip a top-level H1 if it exactly matches the YAML title
  local skip_first_h1 = false
  if #blocks > 0 and blocks[1].t == 'Header' and blocks[1].level == 1 then
    local h1 = stringify(blocks[1].content)
    if doc.meta and doc.meta.title and stringify(doc.meta.title) == h1 then
      skip_first_h1 = true
    end
  end

  for i, blk in ipairs(blocks) do
    if i == 1 and skip_first_h1 then
      -- omit duplicate H1 from the flow
    else
      if blk.t == 'Header' and blk.level == 2 then
        current = stringify(blk.content)
        sections[current] = {blk}
      else
        sections[current] = sections[current] or {}
        table.insert(sections[current], blk)
      end
    end
  end

  local left_blocks = {}
  local right_blocks = {}

  -- put any preamble content (before the first H2) into the left column
  if sections['__preamble__'] then
    for _, b in ipairs(sections['__preamble__']) do
      table.insert(left_blocks, b)
    end
  end

  for name, blks in pairs(sections) do
    if name ~= '__preamble__' then
      local classification = classifyHeader(name)
      if classification == 'left' then
        for _, b in ipairs(blks) do table.insert(left_blocks, b) end
      else
        for _, b in ipairs(blks) do table.insert(right_blocks, b) end
      end
    end
  end

  local out = {}
  table.insert(out, pandoc.RawBlock('latex', '\\begin{paracol}{2}'))
  for _, b in ipairs(left_blocks) do table.insert(out, b) end
  table.insert(out, pandoc.RawBlock('latex', '\\switchcolumn'))
  for _, b in ipairs(right_blocks) do table.insert(out, b) end
  table.insert(out, pandoc.RawBlock('latex', '\\end{paracol}'))

  return pandoc.Pandoc(out, doc.meta)
end
