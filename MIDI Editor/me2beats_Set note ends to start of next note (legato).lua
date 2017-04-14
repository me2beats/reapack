-- @description Set note ends to start of next note (legato)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end


r.Undo_BeginBlock() r.PreventUIRefresh(1)

r.MIDIEditor_LastFocused_OnCommand(40405, 0) -- Set note ends to start of next note (legato)

local notes = r.MIDI_CountEvts(take)

local max_sel,max = 0,0


for i = 0, notes - 1 do
  local _, sel, _, start_note, end_note = r.MIDI_GetNote(take, i)
  if sel then max_sel = math.max(max_sel,end_note) end
  max = math.max(max,start_note)
end

t = {}

for i = 0, notes - 1 do
  local _, sel, _, _, end_note = r.MIDI_GetNote(take, i)
  if sel and end_note == max_sel then t[#t+1] = i end
end

if max < max_sel then

  local item = r.GetMediaItemTake_Item(take)

  local item_end = r.GetMediaItemInfo_Value(item, 'D_POSITION')+r.GetMediaItemInfo_Value(item, 'D_LENGTH')
  local item_end_ppq = math.floor(r.MIDI_GetPPQPosFromProjTime(take, item_end)+0.5)

  for i = 1, #t do
    r.MIDI_SetNote(take,t[i],nil,nil,nil,item_end_ppq,nil,nil,nil)
  end

elseif max > max_sel then

  for i = 1, #t do
    r.MIDI_SetNote(take,t[i],nil,nil,nil,max,nil,nil,nil)
  end

end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Legato', -1)
