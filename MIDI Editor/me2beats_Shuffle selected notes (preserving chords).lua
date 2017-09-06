-- @description Shuffle selected notes (preserving chords)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then return end

local _, notes = r.MIDI_CountEvts(take)
if notes <= 1 then return end

local t,t_out = {},{}

function GetNotes(take)

  local t = {}

  for i = 0, 1000 do
    local ret, sel, mute, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, 0)
    if not ret then  break end
    t[#t+1] = {i, sel, mute, start_note, end_note, chan, pitch, vel}
    r.MIDI_DeleteNote(take, 0)
  end

  for i = 1, #t do
    local _, sel, mute, start_note, end_note, chan, pitch, vel = table.unpack(t[i])
    r.MIDI_InsertNote(take, sel, mute, start_note, end_note, chan, pitch, vel, 0)
  end

  return t
end

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

local state = r.GetToggleCommandStateEx(32060, 40681) -- check overlaps auto corection
if state == 1 then r.MIDIEditor_LastFocused_OnCommand(40681, 0) end

r.UpdateItemInProject(r.GetMediaItemTake_Item(take))

local t_all = GetNotes(take)

for i = 1,#t_all do
  local i_note, sel, mute, start_note, end_note, chan, pitch, vel = table.unpack(t_all[i])
  if sel then
    local f
    for j = 1, #t do
      if t[j][1][3] == start_note then
        table.insert(t[j],{i_note, mute, start_note, end_note-start_note, chan, pitch, vel})
        f = true
        break
      end
    end
    if not f then t[#t+1] = {} t[#t][1] = {i_note, mute, start_note, end_note-start_note, chan, pitch, vel} end
  end
end

if #t <= 1 then goto cnt end

--------------------------- shuffle notes

for i = 1, #t*10 do

  local e1,e2 = math.random(1, #t),math.random(1, #t)
  if e1~=e2 then

    local buf = t[e1][1][3]
    for j = 1, #t[e1] do t[e1][j][3] = t[e2][1][3] end
    for j = 1, #t[e2] do t[e2][j][3] = buf end

    t_out[#t_out+1] = {table.unpack(t[e1])}
    t_out[#t_out+1] = {table.unpack(t[e2])}

    table.remove(t,math.max(e1,e2))
    table.remove(t,math.min(e1,e2))

    if #t == 1 then
      local e2 = math.random(1, #t_out)
      
      local buf = t[1][1][3]
      
      for j = 1, #t[1] do t[1][j][3] = t_out[e2][1][3] end
      for j = 1, #t_out[e2] do t_out[e2][j][3] = buf end

      t_out[#t_out+1] = {table.unpack(t[1])}

      break
    elseif #t==0 then  break end
  end
end

for i = #t_all,1,-1 do r.MIDI_DeleteNote(take, t_all[i][1]) end -- -- delete all notes

--------------------------insert unselected notes
for i = 1, #t_all do
  local _, sel, mute, start_note, end_note, chan, pitch, vel = table.unpack(t_all[i])
  if not sel then
    r.MIDI_InsertNote(take, sel, mute, start_note, end_note, chan, pitch, vel, 0)
  end
end

--------------------------insert selected (shuffled) notes

for i = 1,#t_out do
  for j = 1, #t_out[i] do
    local _, mute, start_note, len, chan, pitch, vel = table.unpack(t_out[i][j])
    local end_note = start_note+len
    r.MIDI_InsertNote(take, true, mute, start_note, end_note, chan, pitch, vel, 0)
  end
end
----------------------------------------------------------
r.UpdateItemInProject(r.GetMediaItemTake_Item(take))


::cnt::

r.PreventUIRefresh(-1)
r.Undo_EndBlock('Shuffle selected notes (preserving chords)', -1)

