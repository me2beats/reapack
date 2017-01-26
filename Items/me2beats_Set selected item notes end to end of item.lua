-- @description Set selected item notes end to end of item
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local item = r.GetSelectedMediaItem(0,0)
if not item then bla() return end

local take = r.GetActiveTake(item)
if not take then bla() return end

if r.TakeIsMIDI(take) == false then bla() return end

notes = r.MIDI_CountEvts(take)

if notes == 0 then bla() return end

it_end = r.GetMediaItemInfo_Value(item, 'D_POSITION')+r.GetMediaItemInfo_Value(item, 'D_LENGTH')
it_end_ppq = r.MIDI_GetPPQPosFromProjTime(take, it_end)

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

for i = 0, notes - 1 do
  _, sel, muted, start_note, end_note, chan, pitch, vel = r.MIDI_GetNote(take, i)
  r.MIDI_SetNote(take, i, sel, muted, start_note, it_end_ppq, chan, pitch, vel)
end

r.PreventUIRefresh(-1)
r.UpdateItemInProject(item)
r.Undo_EndBlock('set selected item notes end to end of item', -1)
