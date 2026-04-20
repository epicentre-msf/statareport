-- Extension ofTarleb's answer on Stackoverflow (https://stackoverflow.com/a/52131435/3888000) to include docx section ends with portrait/landscape orientation changes. 
-- Also uses officer package syntax to create sections breaks

local function newpage(format)
  if format == 'docx' then
    local pagebreak = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
    return pandoc.RawBlock('openxml', pagebreak)
  else
    return pandoc.Para{pandoc.Str '\f'}
  end
end

local function endPortrait(format)
  if format == 'docx' then 
    local pagebreak = '<w:p xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\"><w:pPr><w:sectPr><w:pPr><w:sectPr>  <w:pgSz w:orient=\"landscape\" w:w=\"16838\" w:h=\"11906\" w:code=\"9\"/><w:pgMar w:top=\"1417\" w:right=\"1417\" w:bottom=\"1417\" w:left=\"1417\" w:header=\"720\" w:footer=\"720\" w:gutter=\"0\"/><w:cols w:space=\"720\"/><w:docGrid w:linePitch=\"326\"/></w:sectPr></w:pPr></w:sectPr></w:pPr></w:p>'
    return pandoc.RawBlock('openxml', pagebreak)
  else
    return pandoc.Para{pandoc.Str '\f'}
  end
end

local function endLandscape(format)
  if format == 'docx' then
    local pagebreak = '<w:p xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\"><w:pPr><w:sectPr><w:pPr><w:sectPr><w:pgSz w:orient=\"portrait\" w:h=\"16838\" w:w=\"11906\" w:code=\"9\"/><w:pgMar w:top=\"1417\" w:right=\"1417\" w:bottom=\"1417\" w:left=\"1417\" w:header=\"720\" w:footer=\"720\" w:gutter=\"0\"/><w:cols w:space=\"720\"/><w:docGrid w:linePitch=\"326\"/></w:sectPr></w:pPr></w:sectPr></w:pPr></w:p>'
    return pandoc.RawBlock('openxml', pagebreak)
  else
    return pandoc.Para{pandoc.Str '\f'}
  end
end

local function endContinuous(format)
  if format == 'docx' then
    local pagebreak = '<w:p xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\"><w:pPr><w:sectPr><w:type w:val=\"continuous\"/></w:sectPr></w:pPr></w:p>'
    return pandoc.RawBlock('openxml', pagebreak)
  else
    return pandoc.Para{pandoc.Str '\f'}
  end
end

local function listoftables(format)
  if format == 'docx' then
    local pagebreak = '<w:sdt><w:sdtPr><w:docPartObj><w:docPartGallery w:val=\"Table of Contents\" /><w:docPartUnique /></w:docPartObj></w:sdtPr><w:sdtContent><w:p><w:pPr><w:pStyle w:val=\"TOCHeading\" /></w:pPr><w:r><w:t>List Of Tables</w:t></w:r></w:p><w:p><w:r><w:fldChar w:fldCharType=\"begin\" w:dirty=\"true\" /><w:instrText xml:space="preserve"> TOC \\h \\z \\c "Table" </w:instrText><w:fldChar w:fldCharType=\"separate\" /><w:fldChar w:fldCharType=\"end\" /></w:r></w:p></w:sdtContent></w:sdt>'
    return pandoc.RawBlock('openxml', pagebreak)
  else
    return pandoc.Para{pandoc.Str '\f'}
  end
end

local function listoffigures(format)
  if format == 'docx' then
    local pagebreak = '<w:sdt><w:sdtPr><w:docPartObj><w:docPartGallery w:val=\"Table of Contents\" /><w:docPartUnique /></w:docPartObj></w:sdtPr><w:sdtContent><w:p><w:pPr><w:pStyle w:val=\"TOCHeading\" /></w:pPr><w:r><w:t>List Of Figures</w:t></w:r></w:p><w:p><w:r><w:fldChar w:fldCharType=\"begin\" w:dirty=\"true\" /><w:instrText xml:space="preserve"> TOC \\h \\z \\c "Figure" </w:instrText><w:fldChar w:fldCharType=\"separate\" /><w:fldChar w:fldCharType=\"end\" /></w:r></w:p></w:sdtContent></w:sdt>'
    return pandoc.RawBlock('openxml', pagebreak)
  else
    return pandoc.Para{pandoc.Str '\f'}
  end
end

-- Filter function called on each RawBlock element.
function RawBlock (el)
  if el.text:match '\\newpage' then
    return newpage(FORMAT)
  elseif el.text:match '\\BeginLandscape' then
    return endLandscape(FORMAT)
  elseif el.text:match '\\BeginContinuous' then
    return endContinuous(FORMAT)
  elseif el.text:match '\\BeginPortrait' then
    return endPortrait(FORMAT)
  elseif el.text:match '\\listoftables' then
    return listoftables(FORMAT)
  elseif el.text:match '\\listoffigures' then
    return listoffigures(FORMAT)
  end
  -- otherwise, leave the block unchanged
  return nil
end
