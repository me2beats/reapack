-- @description Move items to time selection start
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function move_items(pos)
  local cur = r.GetCursorPosition()
  r.SetEditCurPos2(0, pos, 0, 0)
  r.Main_OnCommand(41205,0) -- Item edit: Move position of item to edit cursor
  r.SetEditCurPos2(0, cur, 0, 0)
end

local items = r.CountSelectedMediaItems()
if not items then bla() return end

local x = r.GetSet_LoopTimeRange(0, 0, 0, 0, 0)

r.Undo_BeginBlock() r.PreventUIRefresh(1)

move_items(x)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Move items to time selection start', -1)
