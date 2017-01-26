-- @description Move items to selected track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local items = r.CountSelectedMediaItems() if items == 0 then bla() return end

tr = r.GetSelectedTrack(0,0)  if not tr then bla() return end

t = {}
for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  t[#t+1] = item
end

r.Undo_BeginBlock()
for i = 1,#t do r.MoveMediaItemToTrack(t[i], tr) end
r.UpdateArrange()
r.Undo_EndBlock('Move items to sel track', -1)
