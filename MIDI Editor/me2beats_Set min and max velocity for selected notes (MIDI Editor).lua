-- @description Set min and max velocity for selected notes (MIDI Editor)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

-----------------change default values here
local default_min = 30
local default_max = 70
-------------------------------------------

if not (default_min and default_max) then return end

local name
local function GetMidiEditorTakeOrActiveTake()
  local take
  take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
  if not take then
    local item = r.GetSelectedMediaItem(0,0)
    if not item then return end
    take = r.GetActiveTake(item)
    name = 'Min max velocity for active take notes'
  else
    name = 'Min max velocity for MIDI editor notes'
  end
  return take
end

local take = GetMidiEditorTakeOrActiveTake(); if not take then return end
local _, notes = r.MIDI_CountEvts(take); if notes == 0 then return end

local retval, retvals_csv = r.GetUserInputs
(name, 2,'Min,Max',default_min..','..default_max)

if not retval then return end

local min,max=retvals_csv:match'(.*),(.*)'; min,max = tonumber(min),tonumber(max)

min = min or default_min; max = max or default_max

if min > 127 then min = 127 elseif min < 0 then min = 0 end
if max > 127 then max = 127 elseif max < 0 then max = 0 end

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
