-- @description Set note ends to start of next note (legato)
-- @version 1.1
-- @author me2beats
-- @changelog
--  hello vax

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end


r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.MIDIEditor_LastFocused_OnCommand(40405, 0) -- Set note ends to start of next note (legato)

local _, notes = r.MIDI_CountEvts(take)

local max_sel = 0


for i = 0, notes - 1 do
  local _, sel, _, start_note, end_note = r.MIDI_GetNote(take, i)
  if sel then max_sel = math.max(max_sel,start_note) end
end

d = math.huge

for i = 0, notes - 1 do
  local _, _, _, start_note = r.MIDI_GetNote(take, i)
  if d > start_note-max_sel and start_note-max_sel >0 then
    max_next = start_note
    d = start_note-max_sel
  end
end


t = {}

local item = r.GetMediaItemTake_Item(take)

local item_end = r.GetMediaItemInfo_Value(item, 'D_POSITION')+r.GetMediaItemInfo_Value(item, 'D_LENGTH')
local item_end_ppq = math.floor(r.MIDI_GetPPQPosFromProjTime(take, item_end)+0.5)

for i = 0, notes - 1 do
  local _, sel, _, start_note, end_note = r.MIDI_GetNote(take, i)
  if sel and start_note == max_sel and end_note ~= item_end_ppq then t[#t+1] = i end
end

if not max_next or max_next <= max_sel then

  for i = 1, #t do
    r.MIDI_SetNote(take,t[i],nil,nil,nil,item_end_ppq,nil,nil,nil)
  end

elseif max_next > max_sel then

  for i = 1, #t do
    r.MIDI_SetNote(take,t[i],nil,nil,nil,max_next,nil,nil,nil)
  end

end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Legato', -1)
