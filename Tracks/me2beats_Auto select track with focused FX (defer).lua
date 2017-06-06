-- @description Auto select track with focused FX 1.2 (defer)
-- @version 1.3
-- @author me2beats
-- @changelog
--  + Added prevent UI refresh; Fast responsiveness but may eat more CPU (if so - pls downgrade to 1.2)

local r = reaper
local last_trnum

function main()

  local retval, trnum = r.GetFocusedFX()
  if retval ~= 1 then goto continue end

  if not last_trnum or last_trnum ~= trnum then
    local tr = r.GetTrack(0,trnum-1)
    if not tr then goto continue end
    local sel =  r.GetMediaTrackInfo_Value(tr, 'I_SELECTED')
    if sel == 0 then
      r.PreventUIRefresh(1)
      r.SetOnlyTrackSelected(tr)
      r.Main_OnCommand(40914,0) -- set first selected track as last touched
      r.SetMixerScroll(tr)
      r.PreventUIRefresh(-1)
    end

  last_trnum = trnum  

  end

  ::continue::

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

_, _, sec, cmd = r.get_action_context()
SetButtonON()
r.atexit(SetButtonOFF)

