-- split_columns.lua
-- Pandoc Lua filter: split a single-spread Markdown document into two columns.
-- Default column mapping:
--   Left  column: "Received Teaching", "Tension", "Practice"
--   Right column: "Jesus' Public Words", "Reflection", "Notes" (until first ---)
--   Full width: Content after first HorizontalRule in "Notes" section
-- The filter removes an initial H1 that duplicates the YAML title (to avoid title duplication),
-- then groups H2 sections and places them in the appropriate column.
-- 
-- Column override: Wrap a section in a div with class "left" or "right" to force placement:
--   ::: {.left}
--   ## Section Name
--   Content here
--   :::

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

-- Check if a div has a specific class
local function hasClass(div, className)
  if div.classes then
    for _, cls in ipairs(div.classes) do
      if cls == className then
        return true
      end
    end
  end
  return false
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

  -- Build ordered sections, splitting at the HR in Notes
  local section_list = {}
  local current = { name = '__preamble__', blocks = {} }
  table.insert(section_list, current)
  local in_notes = false
  local after_hr = false

  for i, blk in ipairs(blocks) do
    if i == 1 and skip_first_h1 then
      -- omit duplicate H1
    elseif after_hr then
      -- Everything after the HR goes into after section
      table.insert(current.blocks, blk)
    else
      -- Check if this is a Div with explicit column placement
      if blk.t == 'Div' and (hasClass(blk, 'left') or hasClass(blk, 'right')) then
        local override_column = hasClass(blk, 'left') and 'left' or 'right'
        current = { name = '__div__', blocks = { blk }, is_after = false, override_column = override_column }
        table.insert(section_list, current)
      elseif blk.t == 'Header' and blk.level == 2 then
        local name = stringify(blk.content)
        if contains(name:lower(), 'notes') then
          in_notes = true
        end
        current = { name = name, blocks = { blk }, is_after = false }
        table.insert(section_list, current)
      elseif in_notes and blk.t == 'HorizontalRule' then
        -- First HR in Notes section: end two-column, start after section
        table.insert(current.blocks, blk)
        after_hr = true
        current = { name = '__after_hr__', blocks = {}, is_after = true }
        table.insert(section_list, current)
      else
        table.insert(current.blocks, blk)
      end
    end
  end

  local left_blocks = {}
  local right_blocks = {}
  local after_blocks = {}

  -- Distribute sections to appropriate areas
  for _, sec in ipairs(section_list) do
    if sec.name == '__preamble__' then
      for _, b in ipairs(sec.blocks) do table.insert(left_blocks, b) end
    elseif sec.is_after then
      for _, b in ipairs(sec.blocks) do table.insert(after_blocks, b) end
    else
      -- Use override column if specified, otherwise classify by section name
      local classification = sec.override_column or classifyHeader(sec.name)
      local target = (classification == 'left') and left_blocks or right_blocks
      
      for _, b in ipairs(sec.blocks) do
        if b.t == 'Header' and b.level == 2 then
          table.insert(target, pandoc.Para{ pandoc.Strong(b.content) })
        elseif b.t == 'Div' and sec.override_column then
          -- If this is an overridden div, unwrap it and add its contents
          for _, inner in ipairs(b.content) do
            if inner.t == 'Header' and inner.level == 2 then
              -- Convert H2 headers to bold paragraphs
              table.insert(target, pandoc.Para{ pandoc.Strong(inner.content) })
            else
              table.insert(target, inner)
            end
          end
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
  
  -- Add full-width content after two-column layout
  for _, b in ipairs(after_blocks) do table.insert(out, b) end

  return pandoc.Pandoc(out, doc.meta)
end
