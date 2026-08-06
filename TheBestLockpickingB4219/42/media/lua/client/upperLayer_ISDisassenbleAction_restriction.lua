--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "Moveables/ISMoveablesAction"
require "TimedActions/ISBaseTimedAction"
-----------------------------------------------------------------------------------------------------------------------------------------------------------
local upperLayer = {}
upperLayer.ISMoveablesAction = {}
local text_double_FIX
-----------------------------------------------------------------------------------------------------------------------------------------------------------
upperLayer.ISMoveablesAction.isValidObject = ISMoveablesAction.isValidObject
function ISMoveablesAction:isValidObject()
    upperLayer.ISMoveablesAction.isValidObject(self)

    if (not self.square) then return false end
    if (not self.moveProps) then return false end
    -----------------------------------------------------------------------------------------------------------------
    local objects = self.square:getObjects()

    for i = 0, objects:size() - 1 do 

        local object = objects:get(i)
        if object and self.moveProps.object == object then 

            if((instanceof(object, 'IsoDoor') or (instanceof(object, 'IsoThumpable') and object:isDoor())) or 
            (instanceof(object, "IsoWindow") or object:getType() == "Window") )	and
            object:isLocked()	then 

                if text_double_FIX == nil then self.character:Say(getText("UI_zRe_isLocked")) ; text_double_FIX = true
                elseif text_double_FIX == true then text_double_FIX = nil
                end
                
            	return false 
        	end
        end
    end
    ------------------------------------------------------------------------------------------------------------------
    local objects = self.square:getObjects()

    if objects then
        for i = 0, objects:size() - 1 do

            local object = objects:get(i)
            if  object and self.moveProps.object == object then
                return true
            end
        end
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------


