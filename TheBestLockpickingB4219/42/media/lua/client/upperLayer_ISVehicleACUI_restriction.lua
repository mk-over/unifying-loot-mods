--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "Vehicles/ISUI/ISVehicleACUI"
-----------------------------------------------------------------------------------------------------------------------------------------------------------
local upperLayer = {}
upperLayer.ISVehicleACUI = {}
local text_double_FIX
-----------------------------------------------------------------------------------------------------------------------------------------------------------
upperLayer.ISVehicleACUI.updateButtons = ISVehicleACUI.updateButtons
function ISVehicleACUI:updateButtons()
    upperLayer.ISVehicleACUI.updateButtons(self)
	self.ok:setEnable(true);
	self.ok:setTooltip(nil);
	if self.heater:getModData().active then
		self.ok:setTitle(getText("ContextMenu_Turn_Off"))
	else
		self.ok:setTitle(getText("ContextMenu_Turn_On"))
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------


