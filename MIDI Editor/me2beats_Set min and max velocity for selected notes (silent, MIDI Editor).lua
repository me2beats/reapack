-- @description Set min and max velocity for selected notes (silent, MIDI Editor)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

-----------------change default values here
local min = 30
local max = 70
-------------------------------------------

if not (min and max) then return end
if min > 127 then min = 127 elseif min < 0 then min = 0 end
if max > 127 then max = 127 elseif max < 0 then max = 0 end

local name
local function GetMidiEditorTakeOrActiveTake()
  local take
  take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
  if not take then
    local item = r.GetSelectedMediaItem(0,0)
    if not item then return end
    take = r.GetActiveTake(item)
  end
  return take
end

local take = GetMidiEditorTakeOrActiveTake(); if not take then return end
local _, notes = r.MIDI_CountEvts(take); if notes == 0 then  return end

local iter, t = 0, {}

for i = 0, notes - 1 do
  local _, sel, _, _, _, _, _, vel = r.MIDI_GetNote(take, i)
  if sel then
    if vel < min then t[i] = min; iter = iter+1
    elseif vel > max then t[i] = max; iter = iter+1 end
  end
end

if iter == 0 then return end

r.Undo_BeginBlock(); r.PreventUIRefresh(1)
for i,vel in pairs(t) do r.MIDI_SetNote(take, i, nil, nil,nil,nil,nil,nil,vel) end
r.PreventUIRefresh(-1); r.Undo_EndBlock('Set min and max velocity', -1)
