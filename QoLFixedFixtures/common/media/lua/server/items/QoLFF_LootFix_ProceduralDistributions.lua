--[[
    QoL Fixed Fixtures - Loot distribution fix (Paper-towel Dispenser / Air Blower)
    --------------------------------------------------------------------------------
    Verified directly against the user's own Distributions.lua + ProceduralDistributions.lua
    (Build 42.20). Not guessed. Basis:

    1. Paper-towel Dispenser's internal name is "Air Blower", sprites
       fixtures_bathroom_01_14 / _15 / _16 / _17.
    2. Every medical-flavoured room def (medical, medicaloffice, medicalstorage,
       dentist, hospitalroom, hospitalhallway) defines a generic "counter"
       container-type that pulls from a drug/tool-heavy list
       (MedicalClinicDrugs, MedicalOfficeCounter, HospitalRoomCounter, etc.)
       -- confirmed containing AlcoholWipes, Disinfectant, Gloves_Surgical,
       Bandage, Book_Medical, CarKey, and similar.
    3. Vanilla ALREADY carves out an exception for a specific wall-fixture
       sprite inside one of these same "counter" blocks -- hospitalroom's
       counter has:
         {name="HospitalRoomCleaning", min=0, max=99,
          forceForTiles="fixtures_sinks_01_16;fixtures_sinks_01_17;
                         fixtures_sinks_01_18;fixtures_sinks_01_19"}
       This is the real, working, in-file precedent for "one wall-fixture
       sprite gets its own list even though it shares a container-type with
       everything else in the room." We're doing the same thing for the
       Air Blower sprites, in every room def that has this pattern.

    forceForTiles is additive and sprite-keyed: it can only ever match those
    4 exact sprite IDs, so this cannot break any other container in these
    rooms even if the underlying "is the dispenser really tagged as
    counter-type here" assumption turns out to be wrong in some room -- worst
    case it silently does nothing for that room, same as before.

    NOT YET CONFIRMED: exact paper-towel-roll item ID. Searched
    ProceduralDistributions.lua for "papertowel", "paper_towel", "kitchenroll",
    "towelroll", "napkin" -- zero hits anywhere in the loot tables. "Tissue" IS
    confirmed present and used elsewhere in the file, so that's real. Check
    media/scripts/normal.txt (or in-game admin spawn menu) for the actual
    paper-towel item ID and swap it in below -- do not trust the placeholder.
--]]

local DISPENSER_TILES = "fixtures_bathroom_01_14;fixtures_bathroom_01_15;fixtures_bathroom_01_16;fixtures_bathroom_01_17"

local function preDistributionMerge()
    ProceduralDistributions.list.QoLFF_CleanDispenser = {
        rolls = 2,
        items = {
            "Tissue", 20,
            -- "PLACEHOLDER_PaperTowelRoll", 20,  -- swap in the real item ID, see note above
        },
    }
end
Events.OnPreDistributionMerge.Add(preDistributionMerge)

local dispenserOverride = {
    name = "QoLFF_CleanDispenser",
    min = 1, max = 3,
    forceForTiles = DISPENSER_TILES,
}

local overrideTable = {
    medical = {
        counter = { procedural = true, procList = { dispenserOverride } },
    },
    medicaloffice = {
        counter = { procedural = true, procList = { dispenserOverride } },
    },
    medicalstorage = {
        counter = { procedural = true, procList = { dispenserOverride } },
    },
    dentist = {
        counter = { procedural = true, procList = { dispenserOverride } },
    },
    hospitalroom = {
        counter = { procedural = true, procList = { dispenserOverride } },
    },
    hospitalhallway = {
        counter = { procedural = true, procList = { dispenserOverride } },
    },
}
-- Inserted near the front so it merges in before the base game's own room
-- definitions (Distributions is a list of tables merged in order).
table.insert(Distributions, 2, overrideTable)

--[[
    Diagnosis beds ("medical equipment stored in weird diagnosis beds"):
    not yet located. Neither Distributions.lua nor ProceduralDistributions.lua
    contain "bed" as a container-type key in any of the 6 room defs above --
    checked directly, not assumed. Either it's a different container-type
    name than "bed" (need the exact sprite name + which room def, same way
    we found Air Blower above), or it's mod-added storage-bed behavior, not
    vanilla. Next step: same lookup method -- find the bed's internal
    sprite/object name, grep both files for it.

    Whiteboard / scrapyard fridge-oven-grill: confirmed zero matches in
    BOTH files for "whiteboard", "corkboard", "scrapyard", "junkyard" --
    not vanilla, not in these files at all. Real cause is external to what's
    been searched so far (see project research notes for current theory).
--]]
