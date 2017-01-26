-- @description Select only even notes
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function bool_to_num(bool)
  if bool == true then return 1 elseif bool == false then return 0 end
end

take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if take then
  _, notes = r.MIDI_CountEvts(take)
  if notes > 1 then
    t = {}
    t_pos = {}
    for k = 0, notes-1 do
      _, sel, _, start_ppq = r.MIDI_GetNote(take, k)
      if sel == true then t_pos[#t_pos+1] = start_ppq end
    end

    table.sort(t_pos)
    tabu = {}
    for k = 0, notes-1 do
      _, sel, muted, start_ppq, end_ppq, chan, pitch, vel = r.MIDI_GetNote(take, k)
      if sel == true then
        for j = 1, #t_pos do
          if t_pos[j] == start_ppq then
            for i = 1, #tabu do
              if j == tabu[i] then
                found = 1
              break
              end
            end
            if not found then
              t[j] = {bool_to_num(muted), start_ppq, end_ppq, chan, pitch, vel, k}
              tabu[#tabu+1] = j
              break
            else found = nil end
          end
        end
      end
    end

    last = -1
    
    r.Undo_BeginBlock(); r.PreventUIRefresh(1)

    
    r.MIDIEditor_LastFocused_OnCommand(40214, 0) -- unselect all notes
    
    pass = 1
    for i = 1, #t do

      muted, start_ppq, end_ppq, chan, pitch, vel, k = table.unpack(t[i])
      if start_ppq > last then
      
        if pass then
          pass = nil
        else
          pass = 1
          r.MIDI_SetNote(take, k, 1, muted, start_ppq, end_ppq, chan, pitch, vel)
        end
        last = start_ppq
      elseif start_ppq == last then
        if pass then
          r.MIDI_SetNote(take, k, 1, muted, start_ppq, end_ppq, chan, pitch, vel)
        end
      end
    end
    
    r.PreventUIRefresh(-1); r.Undo_EndBlock('select only odd notes', -1)
  else bla() end
else bla() end
