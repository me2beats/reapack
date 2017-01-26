-- @description Increase selected items volume linearly
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local log10 = function(x) return math.log(x, 10) end

items = r.CountSelectedMediaItems()
if items > 2 then
  first = r.GetSelectedMediaItem(0,0)
  last = r.GetSelectedMediaItem(0,items-1)

  a1 = 20*log10(r.GetMediaItemInfo_Value(first, 'D_VOL'))
  az = 20*log10(r.GetMediaItemInfo_Value(last, 'D_VOL'))
  d = (az - a1)/(items-1)
  
  r.Undo_BeginBlock()
  
  for i = 1, items-2 do
    local it = r.GetSelectedMediaItem(0,i)
    local it_vol = r.GetMediaItemInfo_Value(it, 'D_VOL')
    local it_db = 20*log10(it_vol)
    local delta_db = math.floor(a1+d*i+0.5) - it_db
    r.SetMediaItemInfo_Value(it, 'D_VOL', it_vol*10^(0.05*delta_db))
    r.UpdateItemInProject(it)
  end

  r.Undo_EndBlock('increase sel items volume linearly', -1)

else bla() end
