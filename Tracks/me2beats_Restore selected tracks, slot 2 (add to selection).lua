-- @description Restore selected tracks, slot 2 (add to selection)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local sel_tracks_str = r.GetExtState('me2beats_save-restore', 'sel_tracks_2')
if not sel_tracks_str or sel_tracks_str == '' then bla() return end


r.Undo_BeginBlock() r.PreventUIRefresh(1)

for guid in sel_tracks_str:gmatch'{.-}' do
  local tr = r.BR_GetMediaTrackByGUID(0, guid)
  if tr then r.SetTrackSelected(tr,1) end
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Restore selected tracks', -1)
