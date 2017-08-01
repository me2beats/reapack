-- @description Restore cursor position (defer)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function main()
    local ext_sec, ext_key = 'me2beats_save_restore', 'cursor2'
    local str = r.GetExtState(ext_sec, ext_key)
    if str and str ~= '' then
      r.DeleteExtState(ext_sec, ext_key, 0)
      local ext_key = 'cursor_defer'
      local str = r.GetExtState(ext_sec, ext_key)
      r.SetEditCurPos2(0, str, 0, 0)
    else
      local cur = tostring(r.GetCursorPosition())
      local ext_key = 'cursor_defer'
      local str = r.GetExtState(ext_sec, ext_key)
      if str ~= cur then r.SetExtState(ext_sec, ext_key, cur, 0) end
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


_, _, sec, cmd = r.get_action_context()
SetButtonON()
r.atexit(SetButtonOFF)
