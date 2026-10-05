-- Index terms. In text, mark a term as [unit root]{.term}, or give the
-- entry's key when the words differ: [unit roots]{.term key="unit-root"}.
-- Each becomes a link to its entry in glossary.qmd (#term-<key>) with class
-- tp-term; assets/two-page.html opens it in the pane, showing the entry
-- only. The entries and their "Used in" lists are written by hand.

local function slug(s)
  s = s:lower():gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
  return s
end

-- glossary.qmd sits at the project root; files in subfolders need ../
local function prefix()
  local input = quarto.doc.input_file
  local root = quarto.project and quarto.project.directory
  if not input or not root then return "" end
  local rel = pandoc.path.make_relative(input, root)
  local depth = #pandoc.path.split(rel) - 1
  return string.rep("../", depth)
end

local up = nil

function Span(span)
  if not span.classes:includes("term") then return nil end
  up = up or prefix()
  local key = span.attributes.key or pandoc.utils.stringify(span.content)
  local href = up .. "glossary.qmd#term-" .. slug(key)
  return pandoc.Link(span.content, href, "", pandoc.Attr("", { "tp-term" }))
end
