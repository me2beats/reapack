-- @description Go to previous soloed track
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

sel_tr = reaper.GetSelectedTrack(0, 0)
if sel_tr ~= nil then
  if reaper.AnyTrackSolo(0) == true then
    sel_tr_num = reaper.GetMediaTrackInfo_Value(sel_tr, "IP_TRACKNUMBER")
    status = 0 
    t = sel_tr_num - 1
    while (status == 0 and t ~= 0) do 
      got_tr = reaper.GetTrack(0, t-1)
      if (reaper.GetMediaTrackInfo_Value(got_tr, "I_SOLO") == 2 or reaper.GetMediaTrackInfo_Value(got_tr, "I_SOLO") == 1) then
        status = 1
      end
      if (t == 1 and status ~= 1) then 
        status = 2
      end
      if t > 0 then
        t = t-1
      end
    end
  end
  if status == 1 then
    tr = reaper.GetTrack(0, t)
    reaper.SetOnlyTrackSelected(tr)
    reaper.Main_OnCommand(40913, 0) -- scroll sel track into view
  end
end
