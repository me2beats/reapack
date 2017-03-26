-- @description Auto solo for selected tracks (defer)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function solo_sel_tracks_unsolo_others()
  r.PreventUIRefresh(1)
  for i = 0, r.CountTracks()-1 do
    local tr = r.GetTrack(0,i)
    local sel = r.IsTrackSelected(tr)
    local soloed = r.GetMediaTrackInfo_Value(tr, 'I_SOLO')
    if sel == true then if soloed == 0 then r.SetMediaTrackInfo_Value(tr, 'I_SOLO', 2) end
    elseif soloed ~= 0 then r.SetMediaTrackInfo_Value(tr, 'I_SOLO', 0) end
  end
  r.PreventUIRefresh(-1)
end


function main()
  local ch_count = r.GetProjectStateChangeCount()

  if not last_ch_count or last_ch_count ~= ch_count then

    solo_sel_tracks_unsolo_others()

  end

  last_ch_count = ch_count
  r.defer(main)
end

----------------------------------------------------------------------------------------------------
function SetButtonON()
  r.SetToggleCommandState( sec, cmd, 1 ) -- Set ON
  r.RefreshToolbar2( sec, cmd )
  main()
end

----------------------------------------------------------------------------------------------------
function SetButtonOFF()
  r.SetToggleCommandState( sec, cmd, 0 ) -- Set OFF
  r.RefreshToolbar2( sec, cmd ) 
end
----------------------------------------------------------------------------------------------------

_, _, sec, cmd = r.get_action_context()
SetButtonON()
r.atexit(
function()
r.SoloAllTracks(0) -- unsolo all
SetButtonOFF()
end
)
