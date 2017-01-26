-- @description Solo track with active midi editor
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

tr = r.GetMediaItemTake_Track(take)

r.Undo_BeginBlock()

r.Main_OnCommand(40340,0) -- Track: Unsolo all tracks
r.SetMediaTrackInfo_Value(tr, 'I_SOLO', 2)

r.Undo_EndBlock('Solo tr with active media editor', -1)
