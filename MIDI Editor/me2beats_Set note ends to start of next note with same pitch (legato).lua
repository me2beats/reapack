-- @description Set note ends to start of next note with same pitch (legato)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

local _, notes = r.MIDI_CountEvts(take)

local t = {}

for i = 0, notes - 1 do
  local _,sel,_,start_note,_,_,pitch = r.MIDI_GetNote(take, i)
  if sel then
    if not t[pitch] then t[pitch]={} end
    t[pitch][start_note] = i
  end
end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for pitch,i_start_tb in pairs(t) do
  start_tb = {}
  for start in pairs(i_start_tb) do start_tb[#start_tb+1] = start end
  table.sort(start_tb)
  
  for j = 1, #start_tb-1 do
    r.MIDI_SetNote(take,i_start_tb[start_tb[j]],nil,nil,nil,start_tb[j+1],nil,nil,nil)
  end
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Legato', -1)

