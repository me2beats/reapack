-- @description Remove tracks with no items
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

function nothing() end

tracks = reaper.CountTracks(0)
if tracks ~= 0 then
  reaper.Undo_BeginBlock(); reaper.PreventUIRefresh(111)
  t = {};  max_dep = 0
  for i = 1, tracks do
    tr = reaper.GetTrack(0, i-1); tr_dep = reaper.GetTrackDepth(tr)
    if tr_dep > max_dep then max_dep = tr_dep end
    track_items = reaper.CountTrackMediaItems(tr)
    if track_items == 0 then t[#t+1] = {tr_dep, ''} else t[#t+1] = {tr_dep} end
  end
  
  reaper.Main_OnCommand(40297, 0) -- unselect all tracks

  for wanted_dep = max_dep, 0, -1 do
    for cur_tr_number = 1, #t do
      tr = reaper.GetTrack(0, cur_tr_number-1)
      cur_tr_dep = t[cur_tr_number][1]
      if t[cur_tr_number][2] == '' then -- is this track empty?
        if cur_tr_dep == wanted_dep then
          if t[cur_tr_number+1] ~= nil then
            if t[cur_tr_number+1][1] > cur_tr_dep then -- if cur track is folder
              sel = 1
              for next_tr_number = cur_tr_number+1, #t do
                if next_tr_number <= #t then -- does next track exist?
                  next_tr_dep = t[next_tr_number][1]
                  if next_tr_dep > wanted_dep then -- is next track a child of current track?
                    if next_tr_dep == wanted_dep+1 then -- we need only tracks with depth = wanted_dep+1 cause we have already checked 'deeper' tracks)
                      next_tr = reaper.GetTrack(0, next_tr_number-1)
                      next_track_selected = reaper.GetMediaTrackInfo_Value(next_tr, "I_SELECTED")
                      if next_track_selected == 1 then else sel = 0 break end
                    end
                  else break end
                else break end
              end
              if sel == 1 then reaper.SetTrackSelected(tr, true) end  -- all tracks in folder are empty so we can select them
            else reaper.SetTrackSelected(tr, true) end
          elseif cur_tr_number == #t then reaper.SetTrackSelected(tr, true) end          
        end
      end
    end
  end
  reaper.Main_OnCommand(40005, 0) -- remove selected tracks
  reaper.PreventUIRefresh(-111); reaper.Undo_EndBlock('select tracks with no items', 1)
  
else reaper.defer(nothing) end
