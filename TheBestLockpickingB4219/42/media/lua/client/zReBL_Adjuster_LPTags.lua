local function zReBLAdjust(Name, Property, Value)
	local Item = ScriptManager.instance:getItem(Name)
	if Item then
		Item:DoParam(Property.." = "..Value)
	end
end
-- vanila crowbar
	zReBLAdjust("Base.Crowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
-- vanila screwdriver
-- zReBLAdjust("Base.Screwdriver","Tags","Screwdriver;zReBLScrew");

-- id: ToolsOfTheTrade (UtilityBar - one handed, animation not compatibility)
if getActivatedMods():contains("ToolsOfTheTrade") then
	zReBLAdjust("ToolsOfTheTrade.HalliganBar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
end

-- id: PaintableCrowbars PaintableCrowbars_SND_HL1 PaintableCrowbars_SND_HL2
if getActivatedMods():contains("PaintableCrowbars") or getActivatedMods():contains("PaintableCrowbars_SND_HL1") or getActivatedMods():contains("PaintableCrowbars_SND_HL2") then
	zReBLAdjust("Base.Crowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.BlackCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.BrownCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.CyanCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.GreenCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.GreyCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.LightBlueCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.LightBrownCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.OrangeCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.PinkCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.PurpleCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.RedCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.TurquoiseCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.WhiteCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.YellowCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.RainbowCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("Base.StrippedCrowbar","Tags","Crowbar;RemoveBarricade;zReBLCrow");
end

-- id: MonmouthCounty_new MonmouthCountyTributeLegacy
if getActivatedMods():contains("MonmouthCounty_new") then
	zReBLAdjust("MonmouthWeapons.CrowbarScorpion","Tags","Crowbar;RemoveBarricade;zReBLCrow");
	zReBLAdjust("MonmouthWeapons.Crowbarski","Tags","Crowbar;RemoveBarricade;zReBLCrow");
end
if getActivatedMods():contains("MonmouthCountyTributeLegacy") then
	zReBLAdjust("MonmouthWeapons.CrowbarScorpion","Tags","Crowbar;RemoveBarricade;zReBLCrow");
end

-- id: BasedCrowaxe
if getActivatedMods():contains("BasedCrowaxe") then
	zReBLAdjust("Base.BasedCrowaxe","Tags","ChopTree;Crowbar;CutPlant;RemoveBarricade;zReBLCrow");
end