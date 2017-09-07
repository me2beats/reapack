-- @description Close all midi editors
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

for i = 1,100 do
  ed = r.MIDIEditor_GetActive()
  if not ed then return end
  r.MIDIEditor_OnCommand(ed, 2)
end

r.PreventUIRefresh(-1); r.Undo_EndBlock('Close all MIDI editors', -1)
