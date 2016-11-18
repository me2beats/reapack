-- @description Copy focused FX (with automation) to selected tracks
-- @version 0.7
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function esc_lite (str) str = str:gsub('%-', '%%-') return str end


function Elem_in_tb(elem,tb)
-- element shouldn't be tb
  _found = nil
  for eit = 1, #tb do if tb[eit] == elem then _found = 1 break end end
  if not _found then return false else _found = nil return true end
end


function Gen_Guid(guid)
  new_guid = r.genGuid()
  if Elem_in_tb(new_guid,guids_tb) == false then
    gsub_tb[guid] = new_guid
    guids_tb[#guids_tb+1] = new_guid
    return
  else Gen_Guid() end
end


function New_guids(str)

  guids_tb = {}

  for i = 0, r.CountTracks()-1 do
    tr = r.GetTrack(0,i)
    _, chunk = r.GetTrackStateChunk(tr, '', 0)
    for guid in chunk:gmatch'{........%-....%-....%-....%-............}' do
      if Elem_in_tb(guid,guids_tb) == false then
        table.insert(guids_tb, guid)
      end
    end
  end

  gsub_tb = {}
  for guid in str:gmatch'{........%-....%-....%-....%-............}' do
    Gen_Guid(guid)
  end

  for k,v in pairs(gsub_tb) do str = str:gsub(esc_lite(k),v) end
  
  return str

end


function esc (str)
str = str:gsub('%(', '%%(')
str = str:gsub('%)', '%%)')
str = str:gsub('%.', '%%.')
str = str:gsub('%+', '%%+')
str = str:gsub('%-', '%%-')
str = str:gsub('%$', '%%$')
str = str:gsub('%[', '%%[')
str = str:gsub('%]', '%%]')
str = str:gsub('%*', '%%*')
str = str:gsub('%?', '%%?')
str = str:gsub('%^', '%%^')
str = str:gsub('/', '%%/')
return str end

r.Undo_BeginBlock()

tracks = r.CountSelectedTracks()
if tracks == 0 then bla() return end

retval, trnum, _, fxnum = r.GetFocusedFX()
if retval == 0 then bla() return end

tr_from = r.GetTrack(0,trnum-1)
_, chunk_from = r.GetTrackStateChunk(tr_from, '', 0)

fx_guid = r.TrackFX_GetFXGUID(tr_from, fxnum)

fx_chain_from = chunk_from:match'<.-<(.*)>.->'

fx_data_from = fx_chain_from:match('.*\n(BYPASS.-'..esc_lite(fx_guid)..'.-WAK.-\n)')
fx_data_from = New_guids(fx_data_from)



r.PreventUIRefresh(1)
for i = 0, tracks-1 do

  tr_to = r.GetSelectedTrack(0,i)

  if tr_to == tr_from then chunk_to = chunk_from
  else _, chunk_to = r.GetTrackStateChunk(tr_to, '', 0) end

  is_fx_chain = chunk_to:match('\n<FXCHAIN')
  if is_fx_chain then

    tr_chunk_no_64 = chunk_to
    for x in chunk_to:gmatch('\nBYPASS %d+ %d+ %d+\n<.-\n(.-)>') do
      tr_chunk_no_64 = tr_chunk_no_64:gsub(esc(x), '')
    end

    fx = r.TrackFX_GetCount(tr_to)
    if fx ~= 0 then
      before, after = tr_chunk_no_64:match('(.*\nWAK.-\n)(.*)')
    else before, after = tr_chunk_no_64:match('(.*\nDOCKED.-\n)(.*)') end
  else
    fx_chain_start = chunk_from:match'\n(<FXCHAIN\nSHOW .-DOCKED .-\n)'
    before, after = chunk_to:match('(.*\nMAINSEND.-\n)(.*)')
    before = before..fx_chain_start
    after = after..'>\n'
  end

  new_chunk_to = before..fx_data_from..after

  r.SetTrackStateChunk(tr_to, new_chunk_to, 0)
end
r.PreventUIRefresh(1)

r.Undo_EndBlock('Copy focused FX to selected tracks', -1)

