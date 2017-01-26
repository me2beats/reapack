-- @description Zoom horizontally if ruler is at mouse (otherwise scroll vertically)
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function act(id) r.Main_OnCommand(id, 0) end

_,_,_,_,_,_,val = r.get_action_context()

r.Undo_BeginBlock()

local window, segment, details = r.BR_GetMouseCursorContext()
--if window ~= 'ruler' then bla() return end
if window == 'ruler' then
  if val > 0 then act(1012) else act(1011) end
elseif window == 'arrange' then
  if val > 0 then act(40138) else act(40139) end
else bla() end
r.Undo_EndBlock('zoom horizontally', 2)
