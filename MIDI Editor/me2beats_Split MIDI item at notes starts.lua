-- @description Split MIDI item at notes starts
-- @version 1.0
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function Elem_in_tb(elem,tb)
  local found
  for eit = 1, #tb do if tb[eit] == elem then found = 1 break end end
  return found
end


local items = r.CountSelectedMediaItems()
if items == 0 then return end


r.Undo_BeginBlock(); r.PreventUIRefresh(1)

for i = items-1,0,-1 do
  local item = r.GetSelectedMediaItem(0,i)
  
  local t = {}
  
  if item then
  
    local take = r.GetActiveTake(item)
    if take then
    
      if r.TakeIsMIDI(take) then
      
        local _, notes = r.MIDI_CountEvts(take)
        
        for i = 0, notes - 1 do
          local start_note = ({r.MIDI_GetNote(take, i)})[4]
--          local _, _, _, start_note = r.MIDI_GetNote(take, i) -- alternatively
          local start_note = r.MIDI_GetProjTimeFromPPQPos(take, start_note)
          if not Elem_in_tb(start_note,t) then
            t[#t+1] = start_note
          end
        end
    
      
        for i = 2, #t do item = r.SplitMediaItem(item, t[i]) end
      end
    end
  end
  
  
end

r.UpdateArrange()


r.PreventUIRefresh(-1); r.Undo_EndBlock('Split MIDI item at notes starts', -1)

