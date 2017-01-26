-- @description Set selected items fades
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

--------------- fade in settings (change it!)
local in_len = 0.1
local in_curve = ''
local in_shape = ''
--------------- fade out settings (change it!)
local out_len = 0.1
local out_curve = ''
local out_shape = ''
--------------------------------
in_len, in_curve, in_shape = tonumber(in_len), tonumber(in_curve), tonumber(in_shape)
out_len, out_curve, out_shape = tonumber(out_len), tonumber(out_curve), tonumber(out_shape)

local r = reaper local function nothing() end

local items = r.CountSelectedMediaItems(0)

if items > 0 then

  r.Undo_BeginBlock()

  for i = 0, items-1 do
    local item = r.GetSelectedMediaItem(0,i)
--    r.SetMediaItemInfo_Value(item, 'D_FADEINLEN_AUTO', -1)
--    r.SetMediaItemInfo_Value(item, 'D_FADEOUTLEN_AUTO', -1)
    if in_len and in_len > 0 then r.SetMediaItemInfo_Value(item, 'D_FADEINLEN', in_len) end
    if in_curve and in_curve >= -1 and in_curve <= 1 then r.SetMediaItemInfo_Value(item, 'D_FADEINDIR', in_curve) end
    if in_shape then r.SetMediaItemInfo_Value(item, 'C_FADEINSHAPE', in_shape) end
    if out_len and out_len > 0 then r.SetMediaItemInfo_Value(item, 'D_FADEOUTLEN', out_len) end
    if out_curve and out_curve >= -1 and out_curve <= 1 then r.SetMediaItemInfo_Value(item, 'D_FADEOUTDIR', out_curve) end
    if out_shape then r.SetMediaItemInfo_Value(item, 'C_FADEOUTSHAPE', out_shape); end
  end
  r.UpdateArrange()

  r.Undo_EndBlock('Set sel items fades', -1)

else r.defer(nothing) end
