-- @description Match selected items tempo to project tempo
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

items = r.CountSelectedMediaItems()
if items == 0 then bla() return end

cur = r.GetCursorPosition()

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

for i = 0, items-1 do
  it = r.GetSelectedMediaItem(0,i)
  
  local tk = r.GetActiveTake(it)
  if not tk then goto cnt end
  local src = r.GetMediaItemTake_Source(tk)
  if not src then goto cnt end
  local src_fn = r.GetMediaSourceFileName(src, '')
  
  pos = r.GetMediaItemInfo_Value(it, 'D_POSITION')
  _, rate, len = r.GetTempoMatchPlayRate(src, 1, pos, 1)
  r.SetMediaItemTakeInfo_Value(tk, 'D_PLAYRATE', rate)
  r.SetMediaItemInfo_Value(it, 'D_LENGTH',len)
  ::cnt::
  
end

r.PreventUIRefresh(-1); r.Undo_EndBlock('Match items tempo', -1)
