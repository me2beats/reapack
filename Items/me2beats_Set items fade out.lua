-- @description Set items fade out
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

val_1 = ''
val_2 = ''
val_3 = -1
val_4 = ''

-- val_1 = len, val_2 = curve, val_3 = auto, val_4 = shape

items = r.CountSelectedMediaItems(0)
if items > 0 then
  retval, retvals_csv = r.GetUserInputs
  ("Items fade out", 4,
  [[Length,Curve [-1; 1],Autofade length (or -1),Shape]],
  val_1..','..val_2..','..val_3..','..val_4)
  if retval == true then

    r.Undo_BeginBlock()

    len, curve, auto, shape = retvals_csv:match('(.*),(.*),(.*),(.*)')
    len, curve, auto, shape = tonumber(len), tonumber(curve), tonumber(auto), tonumber(shape)

    for i = 0, items-1 do
      item = r.GetSelectedMediaItem(0,i)
      if len and len >= 0 then r.SetMediaItemInfo_Value(item, 'D_FADEOUTLEN', len) end
      if curve and curve >= -1 and curve <= 1 then r.SetMediaItemInfo_Value(item, 'D_FADEOUTDIR', curve) end
      if auto then r.SetMediaItemInfo_Value(item, 'D_FADEOUTLEN_AUTO', auto) end
      if shape then r.SetMediaItemInfo_Value(item, 'C_FADEOUTSHAPE', shape) end
    end
    r.UpdateArrange()
    r.Undo_EndBlock('Set items fade out', -1)
  else bla() end
else bla() end
