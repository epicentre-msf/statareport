-- Force the physical size of the report figures in the Word output.
--
-- The shift plots are emitted by create_dyntex as `![caption](.../output_figures/x.png)`
-- with no size attribute, so Word falls back to the PNG's intrinsic size and scales
-- it to the full text width -- the graphs come out too wide. Pandoc has no default
-- for image size, so we set it here (a Lua filter is the in-repo lever; the
-- create_dyntex ado is not edited).
--
-- 11.5 cm x 10 cm matches the xsize()/ysize() used for the graphs in
-- do_files/06-safety.do. Only figures under output_figures/ are touched, so a
-- cover logo or any other image is left alone. Change the two values below to
-- resize every figure.
local FIG_WIDTH  = "11.5cm"
local FIG_HEIGHT = "10cm"

function Image(img)
  if img.src:match("output_figures") then
    img.attributes.width  = FIG_WIDTH
    img.attributes.height = FIG_HEIGHT
  end
  return img
end
