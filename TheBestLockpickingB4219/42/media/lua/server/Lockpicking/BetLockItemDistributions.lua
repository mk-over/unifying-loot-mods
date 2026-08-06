-- B42.19: ProceduralDistributions.list no longer available at load time.
-- Applying distributions on OnGameBoot when the table is populated.

local books = {
    BookstoreBooks        = {{1,10},{2,8},{3,6},{4,4},{5,2}},
    BookstoreBlueCollar   = {{1,10},{2,8},{3,6},{4,4},{5,2}},
    BookstoreCrimeFiction = {{1,10},{2,8},{3,6},{4,4},{5,2}},
    CrateBooks            = {{1,6},{2,4},{3,2},{4,1},{5,0.5}},
    LibraryBooks          = {{1,8},{2,6},{3,4},{4,2},{5,1}},
    UniversityLibraryBooks  = {{3,8},{4,4},{5,2}},
    UniversityLibraryCinema = {{3,8},{4,4},{5,2}},
    LivingRoomShelf         = {{1,0.1},{2,0.05},{3,0.025}},
    LivingRoomShelfClassy   = {{1,0.1},{2,0.05},{3,0.025}},
    LivingRoomShelfRedneck  = {{1,0.1},{2,0.05},{3,0.025}},
    RecRoomShelf            = {{1,0.1},{2,0.05},{3,0.025}},
    PostOfficeBooks         = {{1,6},{2,4},{3,2},{4,1},{5,0.5}},
    SafehouseBookShelf      = {{1,1},{2,1},{3,1},{4,1},{5,0.5}},
    SurvivalGear            = {{1,2},{2,1},{3,0.5},{4,0.1},{5,0.01}},
}

local magLists = {
    BookstoreBooks=1.0, BookstoreBlueCollar=1.0, BookstoreCrimeFiction=1.0,
    CrateBooks=0.7, LibraryBooks=0.8, UniversityLibraryBooks=0.6,
    UniversityLibraryCinema=0.6, LivingRoomShelf=0.05, LivingRoomShelfClassy=0.05,
    LivingRoomShelfRedneck=0.05, RecRoomShelf=0.05, postbox=0.5,
    PostOfficeBooks=0.7, SafehouseBookShelf=0.4, SurvivalGear=0.5,
    ["Postal.TruckBed"]=0.7, ["MobileLibrary.TruckBed"]=1.2, ["Survivalist.TruckBed"]=0.1,
}

local magazines = {
    {item="BetLock.AlarmMag",       baseWeight=1.5},
    {item="BetLock.LockpickingMag", baseWeight=2.0},
}

local directItems = {
    {list="CrateMagazines",      item="BetLock.AlarmMag",       w=1},
    {list="CrateMagazines",      item="BetLock.LockpickingMag", w=1},
    {list="MechanicShelfBooks",  item="BetLock.AlarmMag",       w=2},
    {list="MechanicShelfBooks",  item="BetLock.LockpickingMag", w=2},
    {list="PostOfficeMagazines", item="BetLock.AlarmMag",       w=1},
    {list="PostOfficeMagazines", item="BetLock.LockpickingMag", w=1},
    {list="StoreShelfMechanics", item="BetLock.AlarmMag",       w=1},
    {list="StoreShelfMechanics", item="BetLock.LockpickingMag", w=1},
    {list="BathroomCabinet",     item="BetLock.BobbyPin",       w=4},
    {list="BathroomCounter",     item="BetLock.BobbyPin",       w=4},
    {list="SalonCounter",        item="BetLock.BobbyPin",       w=4},
}

local function applyDistributions()
    local pd = ProceduralDistributions
    if not pd or not pd.list then return end

    for listName, entries in pairs(books) do
        local list = pd.list[listName]
        if list and list.items then
            for _, e in ipairs(entries) do
                table.insert(list.items, "BetLock.BookLockpicking" .. e[1])
                table.insert(list.items, e[2])
            end
        end
    end

    for listName, scale in pairs(magLists) do
        local list = pd.list[listName]
        if list and list.items then
            for _, mag in ipairs(magazines) do
                local w = mag.baseWeight * scale
                if w >= 0.1 then
                    table.insert(list.items, mag.item)
                    table.insert(list.items, w)
                end
            end
        end
    end

    for _, d in ipairs(directItems) do
        local list = pd.list[d.list]
        if list and list.items then
            table.insert(list.items, d.item)
            table.insert(list.items, d.w)
        end
    end
end

Events.OnGameBoot.Add(applyDistributions)
