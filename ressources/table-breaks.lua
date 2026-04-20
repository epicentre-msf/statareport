-- Convert line returns inside table cells to hard line breaks (DOCX-friendly)
-- Usage: pandoc -t docx --lua-filter=table-linebreaks.lua -o out.docx in.md

local function replace_inlines(inlines)
  local out = {}
  for _, inline in ipairs(inlines) do
    if inline.t == "SoftBreak" then
      table.insert(out, pandoc.LineBreak())
    elseif inline.t == "Str" and (inline.text == "\\n" or inline.text == "<br>") then
      -- Replace literal "\n" or "<br>" markers with a real line break
      table.insert(out, pandoc.LineBreak())
    else
      table.insert(out, inline)
    end
  end
  return out
end

local inline_handlers = {
  Inlines = replace_inlines
}

local function walk_blocks(blocks)
  for i, blk in ipairs(blocks) do
    blocks[i] = pandoc.walk_block(blk, inline_handlers)
  end
end

local function cell_blocks(cell)
  local ct = type(cell)
  if ct ~= "table" and ct ~= "userdata" then
    return nil
  end
  if cell.contents ~= nil then
    return cell.contents
  end
  if cell.content ~= nil then
    return cell.content
  end
  return nil
end

local function fix_cell(cell)
  local blocks = cell_blocks(cell)
  if blocks == nil then
    return
  end
  walk_blocks(blocks)
end

local function fix_rows(rows)
  if rows == nil then
    return
  end
  for _, row in ipairs(rows) do
    if row.cells ~= nil then
      for _, cell in ipairs(row.cells) do
        fix_cell(cell)
      end
    end
  end
end

-- Newer Pandoc: run on every Cell (covers header & body cells)
function Cell(c)
  if FORMAT ~= "docx" then return nil end
  fix_cell(c)
  return c
end

-- Fallback for very old Pandoc versions without Cell:
-- We walk entire tables as a backup.
function Table(tbl)
  if FORMAT ~= "docx" then return nil end

  -- Try to cover both the modern and legacy table structures defensively.
  -- Modern API:
  if tbl.head and tbl.head.rows then
    fix_rows(tbl.head.rows)
  end
  if tbl.bodies then
    for _, body in ipairs(tbl.bodies) do
      if body.head ~= nil then
        fix_rows(body.head)
      elseif body.head and body.head.rows then
        fix_rows(body.head.rows)
      end

      if body.body ~= nil then
        if body.body.rows ~= nil then
          fix_rows(body.body.rows)
        else
          fix_rows(body.body)
        end
      end

      if body.rows ~= nil then
        fix_rows(body.rows)
      end
    end
  end
  if tbl.foot and tbl.foot.rows then
    fix_rows(tbl.foot.rows)
  end

  -- Legacy API (best-effort; harmless if structure differs)
  if tbl.headers and tbl.rows then
    local function fix_cells(cells)
      for _, cell in ipairs(cells) do
        local ct = type(cell)
        if ct == "table" or ct == "userdata" then
          walk_blocks(cell)
        end
      end
    end
    fix_cells(tbl.headers)
    for _, row in ipairs(tbl.rows) do fix_cells(row) end
  end

  return tbl
end
