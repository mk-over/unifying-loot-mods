require "Items/Distributions"
require "Vehicles/VehicleDistributions"
require "Items/ItemPicker"

	
	-- local GloveBox =  {
	-- rolls = 1,
	-- items = {
		-- "Cigarettes", 7,
        -- "WhiskeyFull", 0.5,
        -- "Torch", 5,
        -- "Battery", 7,
        -- "MintCandy", 10,
        -- "Lollipop", 10,
        -- "Candycane", 10,
        -- "BeefJerky", 7,
		-- "Pills", 5,
		-- "PillsBeta", 5,
		-- "PillsAntiDep", 5,
		-- "Bandaid", 10,
        -- "Bandaid", 7,
        -- "AlcoholWipes", 7,
        -- "Bandage", 5,
        -- "Twine", 5,
        -- "Scotchtape", 7,
		-- "Radio.WalkieTalkie4", 10,
		-- "Radio.WalkieTalkie5", 1,
        -- "CDplayer", 5,
        -- "Headphones", 5,
			-- "Pistol", 1,
			-- "Pistol2", 1,
			-- "Pistol3", 0.5,
			-- "Bullets9mmBox", 4,
			-- "GunPowder", 3,
			-- "ShotgunShellsBox", 4,
			-- "223Box", 3,
			-- "308Box", 3,
			-- "Bullets9mmBox", 2,
			-- "ShotgunShellsBox", 2,
			-- "223Box", 2,
			-- "308Box", 2,
			-- "HolsterSimple", 3,
			-- "HolsterDouble", 0.8,
			-- "Nightstick", 4,
        -- "HuntingKnife", 0.25,
		-- "Glasses_Sun", 0.25,
        -- "Glasses_Aviators", 0.1,
        -- "Gloves_LeatherGlovesBlack", 0.1,
        -- "Gloves_LeatherGloves", 0.25,
        -- "Base.MuldraughMap", 5,
        -- "Base.WestpointMap", 5,
        -- "Base.MarchRidgeMap", 5,
        -- "Base.RosewoodMap", 5,
        -- "Base.RiversideMap", 5,
		-- "Key_250",1,
		-- "Key_264",1,
		-- "Key_265",0.25,
		-- "Key_266",1,
		-- "Key_268",1,
		-- "Key_1250",1,
		-- "Key_1264",1,
		-- "Key_1265",0.25,
		-- "Key_1266",1,
		-- "Key_1268",1,
		
		-- "Key_250",100,
		-- "Key_264",100,
		-- "Key_265",100,
		-- "Key_266",100,
		-- "Key_268",100,
		
		-- "Key_1250",100,
		-- "Key_1264",100,
		-- "Key_1265",100,
		-- "Key_1266",100,
		-- "Key_1268",100,
	-- },
	-- junk = {
		-- rolls = 1,
		-- items = {
            -- "Notebook", 10,
            -- "Magazine", 7,
            -- "Newspaper", 7,
			-- "Pen", 5,
            -- "BluePen", 5,
            -- "RedPen", 5,
            -- "Pencil", 5,
            -- "Eraser", 5,
            -- "RubberBand", 5,
			-- "Tissue", 5,
            -- "Tissue", 3,
			-- "Lighter", 5,
			-- "Matches", 7,
			-- "Paperclip", 5,
			-- "Lipstick", 3,
            -- "Cologne", 3,
            -- "Perfume", 3,
            -- "MakeupEyeshadow", 3,
            -- "MakeupFoundation", 3,
			-- "Comb", 5,
            -- "CreditCard", 5,
			-- "Wallet", 5,
			-- "Wallet2", 5,
			-- "Wallet3", 5,
			-- "Wallet4", 5,
			-- "ToiletPaper", 3,
			-- "Mirror", 3,
            -- "Razor", 3,
			-- "Disc", 5,
            -- "Cockroach", 1,
		-- }
	-- }
	-- }	
	
	-- SeatRearLeft = VehicleDistributions.Seat;
	-- SeatRearRight = VehicleDistributions.Seat;
-- }
	-- VehicleDistributions.Police.Glovebox = Glovebox

-- local distributionTable = {
	-- PickUpVanLightsPolice = { Normal = VehicleDistributions.Police; },
	-- CarLightsPolice = { Normal = VehicleDistributions.Police; },
-- }



-- table.insert(VehicleDistributions, 1, distributionTable)
if VehicleDistributions.Police.GloveBox then 
	table.insert(VehicleDistributions.Police.GloveBox.items, "Key_250")
	table.insert(VehicleDistributions.Police.GloveBox.items, 0.1)	
	table.insert(VehicleDistributions.Police.GloveBox.items, "Key_264")
	table.insert(VehicleDistributions.Police.GloveBox.items, 0.1)
	table.insert(VehicleDistributions.Police.GloveBox.items, "Key_265")
	table.insert(VehicleDistributions.Police.GloveBox.items, 0.1)
	table.insert(VehicleDistributions.Police.GloveBox.items, "Key_266")
	table.insert(VehicleDistributions.Police.GloveBox.items, 0.1)
	table.insert(VehicleDistributions.Police.GloveBox.items, "Key_268")
	table.insert(VehicleDistributions.Police.GloveBox.items, 0.1)
end
	
SuburbsDistributions.all.Outfit_Police = SuburbsDistributions.all.Outfit_Police or {rolls = 1,items = {},junk= {rolls =1, items={}}}
        
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, "Key_250")
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, 1)       
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, "Key_264")
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, 1)       
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, "Key_265")
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, 1)       
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, "Key_268")
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, 1)       
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, "Key_1250")
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, 1)       
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, "Key_1264")
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, 1)       
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, "Key_1265")
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, 1)       
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, "Key_1266")
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, 1)       
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, "Key_1268")
table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, 1) 

