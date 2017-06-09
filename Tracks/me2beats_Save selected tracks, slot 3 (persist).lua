-- @description Save selected tracks, slot 3 (persist)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local slot = 3

local function esc_lite(str) str = str:gsub('%-', '%%-') return str end

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tracks = r.CountSelectedTracks()
if tracks == 0 then bla() return end

local sel_str = ''
for i = 0, tracks-1 do sel_str = sel_str..r.GetTrackGUID(r.GetSelectedTrack(0,i)) end

local notes = r.GetSetProjectNotes(0, 0, 0)

local a = '||me2beats_save_restore_tracks\r\n'

local data = notes:match(a..'(.-\r\n)end||')

if data then
  local new_data
  local slot_data = data:match('slot'..slot..' (.-)\r\n')
  if slot_data then
    new_data = data:gsub('slot'..slot..' '..esc_lite(slot_data),'slot'..slot..' '..sel_str,1)
  else new_data = data..'slot'..slot..' '..sel_str..'\r\n' end
  notes = notes:gsub(esc_lite(data),new_data)
elseif notes=='' then notes = notes..a..'slot'..slot..' '..sel_str..'\r\nend||\r\n'
else notes = notes..'\r\n'..a..'slot'..slot..' '..sel_str..'\r\nend||\r\n' end

r.Undo_BeginBlock()
r.GetSetProjectNotes(0, 1, notes)
r.Undo_EndBlock('Save selected tracks', 2)
