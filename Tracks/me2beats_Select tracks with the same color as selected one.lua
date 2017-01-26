-- @description Select tracks with the same color as selected one
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing()
end

tracks = reaper.CountTracks(0)
if tracks > 1 then
  sel_tr = reaper.GetSelectedTrack(0,0)
  if sel_tr ~= nil then
    
    script_title = 'Select tracks with the same color as selected one'
    reaper.Undo_BeginBlock()
    
    sel_tr_col = reaper.GetMediaTrackInfo_Value(sel_tr, 'I_CUSTOMCOLOR')
    for t = 0, tracks-1 do
      tr = reaper.GetTrack(0,t)
      tr_col = reaper.GetMediaTrackInfo_Value(tr, 'I_CUSTOMCOLOR')
      if tr_col == sel_tr_col then
        reaper.SetTrackSelected(tr, true)
      end
    end
    
    reaper.Undo_EndBlock(script_title, -1)
  
  else
    reaper.defer(nothing)
  end
else
  reaper.defer(nothing)
end
