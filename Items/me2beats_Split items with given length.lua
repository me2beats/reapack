-- @description Split items with given length
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end;

local items = r.CountSelectedMediaItems(0)
if items > 0 then
  local retval, wanted_len = r.GetUserInputs("Split items", 1, "Length, seconds:", "")
  if retval == true then
    local wanted_len = tonumber(wanted_len)
    if wanted_len then
      r.Undo_BeginBlock()
      for i = items-1, 0, -1 do
        local item = r.GetSelectedMediaItem(0,i)
        local pos = r.GetMediaItemInfo_Value(item, 'D_POSITION')
        local len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
        if wanted_len < len then
          for i = math.floor(len/wanted_len), 1, -1 do
            r.SplitMediaItem(item, wanted_len*i+pos)
          end
        end
      end
      r.UpdateArrange()
      r.Undo_EndBlock('Split items with given length', -1)
    else bla() end
  else bla() end
else bla() end
