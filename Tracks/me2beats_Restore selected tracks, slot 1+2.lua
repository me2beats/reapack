-- @description Restore selected tracks, slot 1+2
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local sel_tracks_str_1 = r.GetExtState('me2beats_save-restore', 'sel_tracks_1')
local sel_tracks_str_2 = r.GetExtState('me2beats_save-restore', 'sel_tracks_2')

if not (sel_tracks_str_1 or sel_tracks_str_2) or (sel_tracks_str_1 == '' and sel_tracks_str_1 == '') then bla() return end


r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.Main_OnCommand(40297,0) -- unselect all tracks

for guid in sel_tracks_str_1:gmatch'{.-}' do
  local tr = r.BR_GetMediaTrackByGUID(0, guid)
  if tr then r.SetTrackSelected(tr,1) end
end

for guid in sel_tracks_str_2:gmatch'{.-}' do
  local tr = r.BR_GetMediaTrackByGUID(0, guid)
  if tr then r.SetTrackSelected(tr,1) end
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Restore selected tracks', -1)
