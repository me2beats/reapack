-- @description normalize items (active takes) with track volume compensation
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

function DB(vol) return 20*math.log(vol, 10) end

function VOL(db) return 10^(0.05*db) end


r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.Main_OnCommand(40108,0) -- Item properties: Normalize items

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  local take = r.GetActiveTake(item)
  vol = r.GetMediaItemTakeInfo_Value(take, 'D_VOL')
  vol_db = DB(vol)
  tr = r.GetMediaItem_Track(item)
  tr_vol = r.GetMediaTrackInfo_Value(tr, 'D_VOL')
  tr_vol_db = DB(tr_vol)
  if tr_vol_db ~= -vol_db then
    r.SetMediaTrackInfo_Value(tr, 'D_VOL',VOL(-vol_db))
  end
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('normalize items + compensation', -1)
