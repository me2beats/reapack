-- @description Move notes up or down (mousewheel)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function action(id) r.MIDIEditor_LastFocused_OnCommand(id,0) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

local _, notes = r.MIDI_CountEvts(take)

local f
for i = 0, notes - 1 do
  local _, sel = r.MIDI_GetNote(take, i)
  if sel then f=1 break end
end

if not f then bla() return end

local _,_,_,_,_,_,val = r.get_action_context()

r.Undo_BeginBlock() r.PreventUIRefresh(1)

if val > 0 then action(40177) -- Edit: Move notes up one semitone
elseif val < 0 then action(40178) -- Edit: Move notes down one semitone
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Move notes up or down', -1)
