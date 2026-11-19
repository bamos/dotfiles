-- Keep document structure and links, but discard inline text styling.
local function unstyle(element)
  return element.content
end

return {
  Strong = unstyle,
  Emph = unstyle,
  Underline = unstyle,
  Strikeout = unstyle,
  SmallCaps = unstyle,
  Subscript = unstyle,
  Superscript = unstyle,
  Code = function(element)
    return pandoc.Str(element.text)
  end,
  LineBreak = function()
    -- Keep the clipboard's line breaks without Org's visible \\ markers.
    -- Handle the parsed break, not text, so literal backslashes stay intact.
    return pandoc.RawInline('org', '\n')
  end,
  Link = function(element)
    return pandoc.Link(element.content, element.target)
  end,
}
