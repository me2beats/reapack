local r = reaper
r.Undo_BeginBlock()
r.SetEditCurPos2(0, 0, 0, 0)
r.Undo_EndBlock('Move cursor to start of project', 2)
