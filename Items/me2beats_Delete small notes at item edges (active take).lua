-- @description Delete small notes at item edges (active take)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

-------------you can set minimal note length here (seconds)
local min = .2
-----------------------------------------------------------

local r = reaper

local items = r.CountSelectedMediaItems()
if items == 0 then return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 0, items-1 do
  local item = r.GetSelectedMediaItem(0,i)
  
  local it_start = r.GetMediaItemInfo_Value(item, 'D_POSITION')
  local it_len = r.GetMediaItemInfo_Value(item, 'D_LENGTH')
  local it_end = it_start+it_len
  
  local take = r.GetActiveTake(item)

  if take then
    
    local _, notes = r.MIDI_CountEvts(take)
    
    local t = {}
    
    for i = 0, notes - 1 do
      local start_note_ppq, end_note_ppq = ({r.MIDI_GetNote(take, i)})[4], ({r.MIDI_GetNote(take, i)})[5]
      local start_note = r.MIDI_GetProjTimeFromPPQPos(take, start_note_ppq)
      local end_note = r.MIDI_GetProjTimeFromPPQPos(take, end_note_ppq)
      local note_len = end_note - start_note
      if note_len <min and (start_note - it_start < .00001 or it_end-end_note < .00001) then t[#t+1] = i end
    end
    
    if #t ~= 0 then
    
      for i = #t,1,-1 do r.MIDI_DeleteNote(take, t[i]) end
      r.UpdateItemInProject(item)
  
    end
  end
  
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('Delete small notes at item edges', -1)
