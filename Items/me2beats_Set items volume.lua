-- @description Set items volume
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local log10 = function(x) return math.log(x, 10) end

local items = r.CountSelectedMediaItems()
if items > 0 then
  local retval, new_db = r.GetUserInputs("Set items volume", 1, "New volume, dB:", "")
  if retval == true and new_db and tonumber(new_db) then
    r.Undo_BeginBlock()
    for i = 0, items-1 do
      local it = r.GetSelectedMediaItem(0,i)
      local it_vol = r.GetMediaItemInfo_Value(it, 'D_VOL')
      local it_db = 20*log10(it_vol)
      local delta_db = new_db - it_db
      r.SetMediaItemInfo_Value(it, 'D_VOL', it_vol*10^(0.05*delta_db))
      r.UpdateItemInProject(it)
    end
    r.Undo_EndBlock('set items volume', -1)
  else bla() end
else bla() end
