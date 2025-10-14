-- split_columns.lua
-- Pandoc Lua filter: split a single-spread Markdown document into two columns.
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
    return 'right'
  end
end

function Pandoc(doc)
  local blocks = doc.blocks

  -- Optionally skip a top-level H1 that duplicates the YAML title
  local skip_first_h1 = false
  if #blocks > 0 and blocks[1].t == 'Header' and blocks[1].level == 1 then
    local h1 = stringify(blocks[1].content)
    if doc.meta and doc.meta.title and stringify(doc.meta.title) == h1 then
      skip_first_h1 = true
    end
  end

  -- Build ordered sections
  local section_list = {}
  local current = { name = '__preamble__', blocks = {} }
  table.insert(section_list, current)

  for i, blk in ipairs(blocks) do
    if i == 1 and skip_first_h1 then
      -- omit duplicate H1
    else
      if blk.t == 'Header' and blk.level == 2 then
        local name = stringify(blk.content)
        current = { name = name, blocks = { blk } }
        table.insert(section_list, current)
      else
        table.insert(current.blocks, blk)
      end
    end
  end

  local left_blocks = {}
  local right_blocks = {}

  -- Distribute: H2 -> bold unnumbered paragraph, rest as-is
  for _, sec in ipairs(section_list) do
    if sec.name == '__preamble__' then
      for _, b in ipairs(sec.blocks) do table.insert(left_blocks, b) end
    else
      local classification = classifyHeader(sec.name)
      local target = (classification == 'left') and left_blocks or right_blocks
      for _, b in ipairs(sec.blocks) do
        if b.t == 'Header' and b.level == 2 then
          table.insert(target, pandoc.Para{ pandoc.Strong(b.content) })
        else
          table.insert(target, b)
        end
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
