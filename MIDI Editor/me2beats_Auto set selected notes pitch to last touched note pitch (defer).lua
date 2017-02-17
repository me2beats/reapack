-- @description Auto set selected notes pitch to last touched note pitch (defer)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function Val()
--[[
  if track and found and found ~= -1 then
    val = r.TrackFX_GetParam(track, found, 2)
    if val then return val end
  end
--]]
  local tracks = r.CountTracks()
  
  for i = 0, tracks-1 do
    track = r.GetTrack(0,i)
    found = r.TrackFX_AddByName(track, 'midi_examine', 0, 0)
    if found ~= -1 then break end
  end  
  
  if found == -1 then
    r.InsertTrackAtIndex(0,0)
    track = r.GetTrack(0,0)
    if not track then r.MB('Something went wrong','Oops',0) return end
    r.TrackList_AdjustWindows(0)
    found = r.TrackFX_AddByName(track, 'midi_examine', 0, -1)
    r.GetSetMediaTrackInfo_String(track, 'P_NAME', 'MIDI Examiner', 1)
  
    r.SetMediaTrackInfo_Value(track, 'B_SHOWINMIXER',0)
    r.SetMediaTrackInfo_Value(track, 'B_SHOWINTCP',0)
  
    r.SetMediaTrackInfo_Value(track, 'I_RECARM',1)
    r.SetMediaTrackInfo_Value(track, 'I_RECMON',1)
    r.SetMediaTrackInfo_Value(track, 'I_RECMODE',2)
  end
  
  
  if found == -1 then r.MB('Something went wrong','Oops',0) return end
  
  val = r.TrackFX_GetParam(track, found, 2)
  return val

end

function are_notes_in_area(pitch_,x_ppq,y_ppq)
  x = nil
  for k = 0, notes-1 do
    local _, _, _, startppq, endppq,_,pitch = r.MIDI_GetNote(take, k)
    if pitch_ == pitch then
      if startppq > x_ppq and startppq < y_ppq or endppq > x_ppq and endppq < y_ppq or startppq < x_ppq and endppq > y_ppq then
        x = 1 break
      end
    end
  end
  if x then return 1 end
end

--[[
function correct_overlaps(pitch_,x_ppq,y_ppq)
  for k = 0, notes-1 do
    local _, _, _, startppq, endppq,_,pitch = r.MIDI_GetNote(take, k)
    if pitch_ == pitch then
      if startppq >= x_ppq and startppq <= y_ppq or endppq >= x_ppq and endppq <= y_ppq or startppq <= x_ppq and endppq >= y_ppq then
        x = 1 break
      end
    end
  end
end
--]]
function set_pitch(val_)

  if not val_ then val = Val() end
  
  if not val then bla() return end

  take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
  if not take then
    if not take then bla() return end
  end
  
  r.Undo_BeginBlock()


  _, notes = r.MIDI_CountEvts(take)

  if notes == 0 then return end


  for k = 0, notes-1 do
    _, sel, muted, startppq, endppq, chan, pitch, vel = r.MIDI_GetNote(take, k)
    if sel == true and val ~= pitch then
      if not are_notes_in_area(val,startppq,endppq) then
        r.MIDI_SetNote(take, k, 1, muted, startppq, endppq, chan, val, vel, 0)
      end
    end
  end

  item = r.GetMediaItemTake_Item(take)
  r.UpdateItemInProject(item)

  r.Undo_EndBlock('Set sel notes pitch to last note pitch', -1)

end




function main()

  val = Val()

  if not last_val or val ~= last_val then

    set_pitch(val)

    last_val = val
  end
  
  ::cnt1::
  
  r.defer(main)
end

-----------------------------------------------

function SetButtonON()
  r.SetToggleCommandState( sec, cmd, 1 ) -- Set ON
  r.RefreshToolbar2( sec, cmd )
  main()
end

-----------------------------------------------

function SetButtonOFF()
  r.SetToggleCommandState( sec, cmd, 0 ) -- Set OFF
  r.RefreshToolbar2( sec, cmd ) 
end

-----------------------------------------------
val = Val()
_, _, sec, cmd = r.get_action_context()
SetButtonON()
r.atexit(SetButtonOFF)

