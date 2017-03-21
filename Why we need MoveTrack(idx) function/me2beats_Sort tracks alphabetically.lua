-- @description Sort tracks alphabetically
-- @version 0.1
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function move_sel_tr (idx)
--needs tracks
  tr = nil
  tracks = r.CountSelectedTracks(0)
  tr_num = r.GetMediaTrackInfo_Value(r.GetSelectedTrack(0,0), 'IP_TRACKNUMBER')
  if tr_num > idx then tr = r.GetTrack(0,idx-2)
  elseif tr_num < idx then tr = r.GetTrack(0,idx+tracks-2) end
  if tr then
    tr_tb = {}
    for i = 0, tracks-1 do tr_tb[#tr_tb+1] = r.GetSelectedTrack(0,i) end
    r.Main_OnCommand(r.NamedCommandLookup('_S&M_COPYSNDRCV1'), 0) -- copy tr with routing
    r.SetOnlyTrackSelected(tr)
    r.Main_OnCommand(40914, 0) -- set first selected track as last touched track
    r.Main_OnCommand(r.NamedCommandLookup('_S&M_PASTSNDRCV1'), 0) -- paste tr with routing
    tr_tb_2 = {}
    for k = 0, tracks-1 do tr_tb_2[#tr_tb_2+1] = r.GetSelectedTrack(0,k) end
    r.Main_OnCommand(40297, 0) -- unselect all tracks
    for j = 1, #tr_tb do r.DeleteTrack(tr_tb[j]) end
    for l = 1, #tr_tb_2 do r.SetTrackSelected(tr_tb_2[l], 1) end
  end
end


alltracks = r.CountTracks(0)
tracks_tb = {}
for n = 0, alltracks-1 do
  tr_ = r.GetTrack(0,n)
  
  guid = r.BR_GetMediaTrackGUID(tr_)
  _, tr_name = r.GetSetMediaTrackInfo_String(tr_, 'P_NAME', '', 0)
  if r.GetTrackDepth(tr_) == 0 then tracks_tb[#tracks_tb+1] = tr_name..guid end
end

function alphanumsort(o)
   local function conv(s)
      local res, dot = "", ""
      for n, m, c in tostring(s):gmatch"(0*(%d*))(.?)" do
         if n == "" then
            dot, c = "", dot..c
         else
            res = res..(dot == "" and ("%03d%s"):format(#m, m)
                                  or "."..n)
            dot, c = c:match"(%.?)(.*)"
         end
         res = res..c:gsub(".", "\0%0")
      end
      return res
   end
   table.sort(o,
      function (a, b)
         local ca, cb = conv(a), conv(b)
         return ca < cb or ca == cb and a < b
      end)
   return o
end


alphanumsort(tracks_tb)

r.Undo_BeginBlock(); r.PreventUIRefresh(111)


for m = #tracks_tb,1, -1 do
  guid_ = tracks_tb[m]:sub(-38)
  r.SetOnlyTrackSelected(r.BR_GetMediaTrackByGUID(0, guid_))
  move_sel_tr (m)
end


r.PreventUIRefresh(-111); r.Undo_EndBlock('Sort tracks', -1)
