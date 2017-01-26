-- @description Increase selected notes volume linearly 0.9
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
    
    a1 = t[1][6]
    az = t[#t][6]
    d = (az - a1)/(#t-1)
    
    r.Undo_BeginBlock()
    
    for i = 2, #t-1 do
      r.MIDI_SetNote(take, t[i][7], 1, t[i][1], t[i][2], t[i][3], t[i][4], t[i][5], math.floor(a1+d*(i-1)+0.5))
    end
    
    r.Undo_EndBlock('increase sel notes volume', -1)
    
  else bla() end
else bla() end
