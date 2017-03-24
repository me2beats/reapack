-- @description Auto select track with focused FX 1.2 (defer)
-- @version 1.2
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function main()
  time = os.time()-init
  if time - last_update >= 1 then 

    retval, trnum = r.GetFocusedFX()
    if retval ~= 1 then goto continue end
    
    if not last_trnum or last_trnum ~= trnum then
      local tr = r.GetTrack(0,trnum-1)
      if not tr then goto continue end
      sel =  r.GetMediaTrackInfo_Value(tr, 'I_SELECTED')
      if sel == 0 then
        r.SetOnlyTrackSelected(tr)
        r.Main_OnCommand(40914,0) -- set first selected track as last touched
        r.SetMixerScroll(tr)
      end
    
    last_trnum = trnum  
    
    end
    
    ::continue::

    last_update = time
  end
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

init = os.time()
last_update = os.time()-init
_, _, sec, cmd = r.get_action_context()
SetButtonON()
r.atexit(SetButtonOFF)

