-- @description Restore saved track selection, slot 3 (persist)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local slot = 3

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local notes = r.GetSetProjectNotes(0, 0, 0)
local data = notes:match'||me2beats_save_restore_tracks\r\n(.-\r\n)end||'
if not data then bla() return end
local sel_tracks_str = data:match('slot'..slot..' (.-)\r\n')
if not sel_tracks_str then bla() return end

local t = {}

for guid in sel_tracks_str:gmatch'{.-}' do
  local tr = r.BR_GetMediaTrackByGUID(0, guid)
  if tr then t[#t+1] = tr end
end

if #t == 0 then bla() return end


r.Undo_BeginBlock() r.PreventUIRefresh(1)

local first = r.GetTrack(0, 0)
r.SetOnlyTrackSelected(first)
r.SetTrackSelected(first, 0)

for i = 1, #t do r.SetTrackSelected(t[i],1) end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Restore saved track selection', 2)
