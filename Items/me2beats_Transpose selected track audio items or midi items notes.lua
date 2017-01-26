-- @description Transpose selected track audio items or midi items notes
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local tr = r.GetSelectedTrack(0,0)
if not tr then bla() return end

local items = r.CountTrackMediaItems(tr)
if items == 0 then bla() return end

local retval, transpose = r.GetUserInputs("Transpose", 1, "Transpose, semitones:", "")
if retval ~= true then bla() return end

r.Undo_BeginBlock(); r.PreventUIRefresh(1)

for i = 0, items-1 do
  local it =  r.GetTrackMediaItem(tr, i)
  local takes = r.CountTakes(it)
  for t = 0, takes-1 do
    local take = r.GetTake(it, t)
    if not take then break end
    if r.TakeIsMIDI(take) == true then
      local _, notes = r.MIDI_CountEvts(take)
      for n = 0, notes-1 do
        local retval, sel, muted, startppq, endppq, chan, pitch, vel = r.MIDI_GetNote(take, n)
        r.MIDI_SetNote(take, n, sel, muted, startppq, endppq, chan, pitch + transpose, vel)
      end
    else
      local t_pitch = r.GetMediaItemTakeInfo_Value(take, 'D_PITCH')
      r.SetMediaItemTakeInfo_Value(take, 'D_PITCH', t_pitch + transpose)
    end
  end
  r.UpdateItemInProject(it)
end

r.PreventUIRefresh(-1) r.Undo_EndBlock('transpose selected track audio items or midi items notes', -1)

