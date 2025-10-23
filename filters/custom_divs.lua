-- custom_divs.lua
-- Pandoc Lua filter: handle custom fenced divs for special formatting
-- Supports: warning, note, info, tip, caution, example boxes
-- Footnotes within divs are moved outside to appear at page bottom

local pandoc = pandoc

-- Helper to wrap content in a LaTeX environment
local function latex_env(env_name, content)
  local open = pandoc.RawBlock('latex', '\\begin{' .. env_name .. '}')
  local close = pandoc.RawBlock('latex', '\\end{' .. env_name .. '}')
  local result = {open}
  for _, block in ipairs(content) do
    table.insert(result, block)
  end
  table.insert(result, close)
  return result
end

-- Map of div classes to LaTeX environment names
local div_map = {
  warning = 'warningbox',
  note = 'notebox',
  info = 'infobox',
  tip = 'tipbox',
  caution = 'cautionbox',
  example = 'examplebox',
  aside = 'asidebox'
}

function Div(div)
  -- Check if this div has a class we recognize
  for class, env in pairs(div_map) do
    if div.classes:includes(class) then
      -- Use savenotes environment to defer footnotes to page bottom
      local result = {
        pandoc.RawBlock('latex', '\\begin{savenotes}'),
        pandoc.RawBlock('latex', '\\begin{' .. env .. '}')
      }
      for _, block in ipairs(div.content) do
        table.insert(result, block)
      end
      table.insert(result, pandoc.RawBlock('latex', '\\end{' .. env .. '}'))
      table.insert(result, pandoc.RawBlock('latex', '\\end{savenotes}'))
      return result
    end
  end
  -- If no special handling, return unchanged
  return nil
end

-- Handle inline spans with custom classes
function Span(span)
  -- Example: [text]{.highlight} -> \hl{text}
  if span.classes:includes('highlight') then
    return {
      pandoc.RawInline('latex', '\\hl{'),
      pandoc.Span(span.content),
      pandoc.RawInline('latex', '}')
    }
  end
  -- Add more inline span handlers as needed
  return nil
end
