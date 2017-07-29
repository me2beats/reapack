-- @description Auto open folder with media item active take source media
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function auto_browse_sel_item(it)
  local tk = r.GetActiveTake(it)
  if not tk then return end
  if r.TakeIsMIDI(tk) then return end
  local src = r.GetMediaItemTake_Source(tk)
  if not src then return end
  local src_fn = r.GetMediaSourceFileName(src, '')

  r.OpenMediaExplorer(src_fn, 0)
end

function main()
  local ch_count = r.GetProjectStateChangeCount(0)

  if not last_ch_count or last_ch_count ~= ch_count then
    
    local it = r.GetSelectedMediaItem(0,0)
    if it then
      local guid,proj_str = r.BR_GetMediaItemGUID(it), tostring(r.EnumProjects(-1, ''))

      local ext_sec, ext_key,ext_key1 = 'me2beats_auto_browse', 'last_sel', 'last_proj'
      local old_guid = r.GetExtState(ext_sec, ext_key)
      local old_proj = r.GetExtState(ext_sec, ext_key1)
      if old_guid ~= guid or old_proj ~= proj_str then
--      if old_guid ~= guid then
        auto_browse_sel_item(it)
        r.SetExtState(ext_sec, ext_key, guid, 0)
        r.SetExtState(ext_sec, ext_key1, proj_str, 0)
      end
    end

  end

  last_ch_count = ch_count
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

