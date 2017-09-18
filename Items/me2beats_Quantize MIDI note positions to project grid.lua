-- @description Quantize MIDI note positions to project grid
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function GetAndDelNotes(take)

  local t = {}

  for i = 0, 1000 do
    local ret, sel, mute, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, 0)
    if not ret then  break end
    t[#t+1] = {sel, mute, start_note, end_note, chan, pitch, vel}
    r.MIDI_DeleteNote(take, 0)
  end
  return t
end

local items = r.CountSelectedMediaItems()
if items == 0 then return end

for i = 0, items-1 do
  local it = r.GetSelectedMediaItem(0,i)

  local take = r.GetActiveTake(it)
  if take and r.TakeIsMIDI(take) then

    local _, notes = r.MIDI_CountEvts(take)
    if notes > 0 then

      r.Undo_BeginBlock()
      r.PreventUIRefresh(1)

      local t_all = GetAndDelNotes(take)

      for i = 1,#t_all do
        local sel, mute, start_note_ppq, end_note_ppq, chan, pitch, vel = table.unpack(t_all[i])
        local start_note = r.MIDI_GetProjTimeFromPPQPos(take, start_note_ppq)
        local closest_gr = r.SnapToGrid(0, start_note)
        local closest_gr_ppq = r.MIDI_GetPPQPosFromProjTime(take, closest_gr)
        if closest_gr_ppq ~= start_note_ppq then
          r.MIDI_InsertNote(take, sel, mute, closest_gr_ppq, closest_gr_ppq+end_note_ppq-start_note_ppq, chan, pitch, vel, 0)
        else
          r.MIDI_InsertNote(take, sel, mute, start_note_ppq, end_note_ppq, chan, pitch, vel, 0)
        end
      end

      r.UpdateItemInProject(it)

      r.PreventUIRefresh(-1)
      r.Undo_EndBlock('Quantize notes to project grid', -1)
    end
  end
end
