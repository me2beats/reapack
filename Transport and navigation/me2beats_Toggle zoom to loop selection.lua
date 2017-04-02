-- @description Toggle zoom to loop selection
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function SetButtonON()
  r.SetToggleCommandState( sec, cmd, 1 ) -- Set ON
  r.RefreshToolbar2( sec, cmd )
end

-----------------------------------------------

function SetButtonOFF()
  r.SetToggleCommandState( sec, cmd, 0 ) -- Set OFF
  r.RefreshToolbar2( sec, cmd ) 
end

-----------------------------------------------

_, _, sec, cmd = r.get_action_context()

local ext_sec, ext_key = 'me2beats_save_restore','zoom_to_loop'

local str = r.GetExtState(ext_sec, ext_key)
if not str or str == '' then

  x_l, y_l = r.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
  if x_l == y_l then bla() return end


  x_a, y_a = r.BR_GetArrangeView(0)

  str = x_a..','..y_a
  r.SetExtState(ext_sec, ext_key, str, 0)

  r.Undo_BeginBlock()

  r.BR_SetArrangeView(0, x_l-(y_l-x_l)/50, y_l+(y_l-x_l)/50)


  SetButtonON()


  r.Undo_EndBlock('Zoom to loop selection', 2)

else

  x_a,y_a = str:match'(.*),(.*)'
  x_a,y_a = tonumber(x_a),tonumber(y_a)

  r.Undo_BeginBlock()

  r.BR_SetArrangeView(0, x_a, y_a)

  SetButtonOFF()

  r.Undo_EndBlock('Zoom to loop selection', 2)

  r.DeleteExtState(ext_sec, ext_key, 0)
end

