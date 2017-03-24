-- @description Select tracks from selected track to track at mouse
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function min_max(x,y) return math.min(x,y),math.max(x,y) end

local mouse_tr = r.BR_TrackAtMouseCursor()
if not mouse_tr then return end

sel_tr = r.GetSelectedTrack(0, 0)
if not sel_tr then return end

mouse_tr_num = r.GetMediaTrackInfo_Value(mouse_tr, 'IP_TRACKNUMBER')
sel_tr_num = r.GetMediaTrackInfo_Value(sel_tr, 'IP_TRACKNUMBER')

min,max = min_max(mouse_tr_num,sel_tr_num)

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

r.SetOnlyTrackSelected(mouse_tr,1)
r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track


for i = min,max do
  local tr = r.GetTrack(0,i-1)
  if r.GetMediaTrackInfo_Value(tr, 'B_SHOWINMIXER') == 1 or r.GetMediaTrackInfo_Value(tr, 'B_SHOWINTCP') == 1 then
    r.SetTrackSelected(tr,1)
  end
end

--[[
window = r.BR_GetMouseCursorContext()
if window == 'tcp' then r.SetMixerScroll(mouse_tr) end
--]]

r.PreventUIRefresh(-1)

r.Undo_EndBlock('Select tracks from selected track to track at mouse', -1)
