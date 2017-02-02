-- @description Normalize items (active takes) with track volume compensation
-- @version 1.2
-- @author me2beats
-- @changelog
--  + init
--  + fix something

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

function DB(vol) return 20*math.log(vol, 10) end

function VOL(db) return 10^(0.05*db) end


r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.Main_OnCommand(40108,0) -- Item properties: Normalize items

t = {}

for i = 0,items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local take = r.GetActiveTake(item)
  if not take then goto cnt end
  local tr = r.GetMediaItem_Track(item)
  vol = r.GetMediaItemTakeInfo_Value(take, 'D_VOL')
  vol_db = DB(vol)
  tr_str = tostring(tr)
  if not t[tr_str] then t[tr_str] = {} end
  if t[tr_str][3] then
    if vol_db > t[tr_str][3] then t[tr_str] = {tr,item,vol_db} end
  else t[tr_str] = {tr,item,vol_db} end
  ::cnt::
end

for _,v in pairs(t) do
  local tr = v[1]
  local item = v[2]
  vol_db = v[3]
  tr_vol = r.GetMediaTrackInfo_Value(tr, 'D_VOL')
  tr_vol_db = DB(tr_vol)
  r.SetMediaTrackInfo_Value(tr, 'D_VOL',VOL(tr_vol_db-vol_db))
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('normalize items + compensation', -1)
