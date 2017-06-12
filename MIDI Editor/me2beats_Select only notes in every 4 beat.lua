-- @description Select only notes in every 4 beat
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local beat = 3

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

local item = r.GetMediaItemTake_Item(take)
local it_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')

local it_len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
local it_end = it_start+it_len

local _, msr = r.TimeMap2_timeToBeats(0, it_start)
local msr_start = r.TimeMap_GetMeasureInfo(0, msr)

local _, notes = r.MIDI_CountEvts(take)
if notes == 0 then bla() return end

local t,t_notes = {},{}

for i = 0, notes - 1 do
  local _, _, _, start_note, end_note = r.MIDI_GetNote(take, i)
  t_notes[i+1] = {r.MIDI_GetProjTimeFromPPQPos(take, start_note),r.MIDI_GetProjTimeFromPPQPos(take, end_note)}
end

local x,y

x = r.TimeMap2_beatsToTime(0, msr+beat, 0)
y = r.TimeMap2_beatsToTime(0, msr+1+beat, 0)

local x_i=beat
local y_i=1+beat

for i = 1,1000 do
  t[i]={x,y}
  x_i,y_i=x_i+4,y_i+4
  x = r.TimeMap2_beatsToTime(0, x_i, 0)
  if x >= it_end then break end
  y = r.TimeMap2_beatsToTime(0, y_i, 0)
end

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

for j = 1, #t_notes do
  local n_x,n_y = t_notes[j][1],t_notes[j][2]
  r.MIDI_SetNote(take, j-1, 0, nil,nil,nil,nil,nil,nil)
end

for i = 1, #t do
  x,y = t[i][1],t[i][2]
  for j = 1, #t_notes do
    local n_x,n_y = t_notes[j][1],t_notes[j][2]

    if n_x <= x and n_y >= x+0.00001 or
       n_x <= y-0.00001 and n_y >= y or
       n_x >= x and n_y <= y then
      r.MIDI_SetNote(take, j-1, 1, nil,nil,nil,nil,nil,nil)
    end
  end
end

r.PreventUIRefresh(-1); r.Undo_EndBlock('Sel notes in every '..(beat+1)..' beat', -1)

