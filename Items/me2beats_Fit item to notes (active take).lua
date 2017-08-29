-- @description Fit item to notes (active take)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper


local items = r.CountSelectedMediaItems()
if items == 0 then return end

r.Undo_BeginBlock(); r.PreventUIRefresh(1)


for i = 0, items-1 do
  local it = r.GetSelectedMediaItem(0,i)
  local take = r.GetActiveTake(it)
  if take then
    local min,max = math.huge, 0
    local _, notes = r.MIDI_CountEvts(take)
    local it_start = r.GetMediaItemInfo_Value(it, 'D_POSITION')
    local it_len = r.GetMediaItemInfo_Value(it, 'D_LENGTH')
    local it_end = it_start+it_len
    
    for i = 0, notes - 1 do
      local _, _, _, start_note, end_note = r.MIDI_GetNote(take, i)
      min, max = math.min(start_note,min), math.max(end_note,max)
    end
    
    local start_time = r.MIDI_GetProjTimeFromPPQPos(take, min)
    local end_time = r.MIDI_GetProjTimeFromPPQPos(take, max)
    
    r.BR_SetItemEdges(it, start_time, end_time)
    r.UpdateItemInProject(it)
    
  end
  
end

r.PreventUIRefresh(-1); r.Undo_EndBlock('Fit item to notes (active take)', -1)
