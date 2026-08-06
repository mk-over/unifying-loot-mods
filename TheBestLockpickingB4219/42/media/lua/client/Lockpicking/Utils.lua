if BetLock == nil then BetLock = {} end
BetLock.Utils = {}

local LevelTable = {}
LevelTable[0] = {"UI_BetLock_VeryEasy", 0, 8}
LevelTable[1] = {"UI_BetLock_Easy", 2, 16}
LevelTable[2] = {"UI_BetLock_Average", 4, 32}
LevelTable[3] = {"UI_BetLock_Hard", 6, 64}
LevelTable[4] = {"UI_BetLock_VeryHard", 8, 128}


local roomLevel = {}
roomLevel["conveniencestore"] = {0, 2}
roomLevel["warehouse"] = {1, 2}
roomLevel["burgerkitchen"] = {0, 2}
roomLevel["medclinic"] = {1, 2}
roomLevel["medicalstorage"] = {2, 2}
roomLevel["zippeestore"] = {1, 2}
roomLevel["grocerystorage"] = {0, 3}
roomLevel["grocery"] = {0, 2}
roomLevel["gigamartkitchen"] = {1, 2}
roomLevel["gigamart"] = {0, 3}
roomLevel["fossoil"] = {2, 2}
roomLevel["bedroom"] = {0, 2}
roomLevel["loggingfactory"] = {1, 3}
roomLevel["all"] = {0, 2}
roomLevel["shed"] = {0, 2}
roomLevel["kitchen"] = {1, 2}
roomLevel["spiffosstorage"] = {2, 2}
roomLevel["spiffoskitchen"] = {1, 3}
roomLevel["kitchen_crepe"] = {1, 2}
roomLevel["plazastore1"] = {2, 2}
roomLevel["garagestorage"] = {3, 2}
roomLevel["garage"] = {2, 3}
roomLevel["bathroom"] = {0, 2}
roomLevel["pizzawhirled"] = {1, 3}
roomLevel["motelbedroom"] = {1, 2}
roomLevel["lobby"] = {1, 3}
roomLevel["bookstore"] = {2, 2}
roomLevel["grocers"] = {0, 3}
roomLevel["library"] = {0, 3}
roomLevel["toolstore"] = {0, 3}
roomLevel["bar"] = {1, 2}
roomLevel["barkitchen"] = {1, 3}
roomLevel["policestorage"] = {3, 2}
roomLevel["armystorage"] = {4, 1}
roomLevel["pharmacy"] = {1, 2}
roomLevel["pharmacystorage"] = {2, 3}
roomLevel["gunstore"] = {3, 2}
roomLevel["gunstorestorage"] = {4, 1}
roomLevel["mechanic"] = {2, 2}
roomLevel["bakery"] = {1, 3}
roomLevel["aesthetic"] = {2, 3}
roomLevel["clothesstore"] = {1, 3}
roomLevel["motelroom"] = {2, 2}
roomLevel["motelroomoccupied"] = {1, 3}
roomLevel["empty"] = {0, 2}
roomLevel["cafe"] = {1, 3}
roomLevel["cafekitchen"] = {2, 2}
roomLevel["pizzakitchen"] = {2, 2}
roomLevel["dining"] = {1, 3}
roomLevel["restaurant"] = {0, 3}
roomLevel["post"] = {2, 3}
roomLevel["poststorage"] = {2, 3}
roomLevel["dinnerkitchen"] = {2, 2}
roomLevel["restaurantkitchen"] = {1, 2}
roomLevel["jayschicken"] = {1, 2}
roomLevel["generalstorestorage"] = {2, 2}
roomLevel["generalstore"] = {0, 3}
roomLevel["freezer"] = {2, 2}
roomLevel["fridge"] = {2, 2}
roomLevel["laundry"] = {1, 3}
roomLevel["furniturestore"] = {2, 2}
roomLevel["furniturestorage"] = {2, 3}
roomLevel["storageunit"] = {3, 2}
roomLevel["fishingstorage"] = {2, 3}
roomLevel["theatre"] = {2, 3}
roomLevel["theatrekitchen"] = {2, 2}
roomLevel["theatrestorage"] = {3, 2}
roomLevel["cornerstore"] = {0, 3}
roomLevel["housewarestore"] = {1, 2}
roomLevel["shoestore"] = {2, 3}
roomLevel["sportstore"] = {1, 3}
roomLevel["sportstorage"] = {2, 2}
roomLevel["giftstorage"] = {2, 3}
roomLevel["giftstore"] = {1, 3}
roomLevel["candystore"] = {1, 3}
roomLevel["toystore"] = {1, 3}
roomLevel["electronicsstore"] = {2, 3}
roomLevel["sewingstore"] = {1, 3}
roomLevel["medical"] = {2, 3}
roomLevel["medicaloffice"] = {2, 3}
roomLevel["jewelrystore"] = {3, 2}
roomLevel["musicstore"] = {2, 3}
roomLevel["departmentstore"] = {1, 3}
roomLevel["hall"] = {2, 2}
roomLevel["icecreamkitchen"] = {0, 3}
roomLevel["gasstore"] = {2, 3}
roomLevel["gasstorage"] = {3, 2}
roomLevel["gardenstore"] = {1, 3}
roomLevel["farmstorage"] = {2, 2}
roomLevel["security"] = {3, 2}
roomLevel["armysurplus"] = {4, 1}
roomLevel["armyhanger"] = {4, 1}
roomLevel["knoxbutcher"] = {2, 3}
roomLevel["changeroom"] = {0, 4}
roomLevel["hunting"] = {3, 2}
roomLevel["camping"] = {1, 2}
roomLevel["campingstorage"] = {2, 3}
roomLevel["butcher"] = {1, 3}
roomLevel["optometrist"] = {2, 2}
roomLevel["clothingstore"] = {0, 3}
roomLevel["office"] = {0, 3}
roomLevel["bank"] = {3, 2}
roomLevel["livingroom"] = {0, 2}

-- Добавленные недостающие комнаты
roomLevel["BandPractice"] = {1, 2} -- Специализированная, музыкальная
roomLevel["Carpenter"] = {2, 2} -- Рабочая мастерская
roomLevel["Chef"] = {1, 3} -- Кухня, как у ресторанов
roomLevel["Farmer"] = {1, 2} -- Фермерская, простая
roomLevel["Nurse"] = {2, 2} -- Медицинская
roomLevel["SafehouseLoot"] = {1, 3} -- Убежище, средняя сложность
roomLevel["SafehouseLoot_Late"] = {2, 2} -- Убежище позже, выше сложность
roomLevel["SafehouseLoot_Mid"] = {1, 3} -- Убежище, средняя
roomLevel["SurvivorCache1"] = {2, 2} -- Тайник выживших
roomLevel["SurvivorCache2"] = {2, 2} -- Тайник выживших
roomLevel["SurvivorCacheBigBuilding"] = {3, 2} -- Большой тайник
roomLevel["aestheticstorage"] = {2, 2} -- Хранилище эстетики
roomLevel["arenakitchen"] = {1, 2} -- Кухня арены
roomLevel["arenakitchenstorage"] = {2, 2} -- Хранилище кухни арены
roomLevel["armytent"] = {3, 2} -- Военная палатка
roomLevel["artstore"] = {1, 3} -- Магазин искусства
roomLevel["backstage"] = {1, 2} -- Закулисье
roomLevel["bakerykitchen"] = {1, 3} -- Кухня пекарни
roomLevel["bandkitchen"] = {1, 2} -- Кухня группы
roomLevel["bandlivingroom"] = {0, 2} -- Гостиная группы
roomLevel["bandmerch"] = {1, 3} -- Магазин мерча группы
roomLevel["barbecuestore"] = {1, 3} -- Магазин барбекю
roomLevel["barcounter"] = {1, 2} -- Стойка бара
roomLevel["barcountertwiggy"] = {1, 2} -- Стойка бара (Twiggy)
roomLevel["barn"] = {1, 2} -- Сарай
roomLevel["barstorage"] = {2, 2} -- Хранилище бара
roomLevel["baseballgiftstorage"] = {2, 2} -- Хранилище бейсбольных подарков
roomLevel["baseballstorage"] = {2, 2} -- Хранилище бейсбола
roomLevel["baseballstore"] = {1, 3} -- Магазин бейсбола
roomLevel["batfactory"] = {2, 2} -- Фабрика бит
roomLevel["batstorage"] = {2, 2} -- Хранилище бит
roomLevel["batteryfactory"] = {2, 2} -- Фабрика батарей
roomLevel["batterystorage"] = {2, 2} -- Хранилище батарей
roomLevel["beergarden"] = {1, 2} -- Пивной сад
roomLevel["bowlingalley"] = {1, 3} -- Боулинг
roomLevel["boxing"] = {2, 2} -- Боксёрский зал
roomLevel["breakroom"] = {1, 2} -- Комната отдыха
roomLevel["brewery"] = {2, 2} -- Пивоварня
roomLevel["brewerystorage"] = {2, 2} -- Хранилище пивоварни
roomLevel["burgerkitchenstorage"] = {2, 2} -- Хранилище бургерной кухни
roomLevel["cabinetfactory"] = {2, 2} -- Фабрика шкафов
roomLevel["cabinetshipping"] = {2, 2} -- Склад шкафов
roomLevel["cafeteria"] = {1, 2} -- Кафетерий
roomLevel["cafeteriakitchen"] = {2, 2} -- Кухня кафетерия
roomLevel["camerastore"] = {2, 3} -- Магазин камер
roomLevel["candystorage"] = {2, 2} -- Хранилище конфет
roomLevel["captainoffice"] = {2, 2} -- Офис капитана
roomLevel["cardealershipoffice"] = {1, 2} -- Офис автодилера
roomLevel["carsupply"] = {2, 2} -- Автомагазин
roomLevel["catfish_dining"] = {1, 2} -- Столовая Catfish
roomLevel["catfish_kitchen"] = {1, 2} -- Кухня Catfish
roomLevel["catwalk"] = {1, 2} -- Коридор
roomLevel["changeroomjockey"] = {0, 4} -- Раздевалка жокеев
roomLevel["chinesekitchen"] = {1, 3} -- Китайская кухня
roomLevel["chineserestaurant"] = {1, 3} -- Китайский ресторан
roomLevel["classroom"] = {0, 2} -- Классная комната
roomLevel["closet"] = {0, 2} -- Чулан
roomLevel["clothingstorage"] = {2, 2} -- Хранилище одежды
roomLevel["comicstorage"] = {2, 2} -- Хранилище комиксов
roomLevel["comicstore"] = {1, 3} -- Магазин комиксов
roomLevel["construction"] = {2, 2} -- Строительная зона
roomLevel["controlroom"] = {2, 2} -- Комната управления
roomLevel["cornerstorecounter"] = {0, 2} -- Стойка углового магазина
roomLevel["cornerstorestorage"] = {2, 2} -- Хранилище углового магазина
roomLevel["coroneroffice"] = {2, 2} -- Офис коронера
roomLevel["cortmanmedroom"] = {2, 2} -- Медкомната Cortman
roomLevel["cortmanoffice"] = {1, 2} -- Офис Cortman
roomLevel["cybercafe"] = {1, 3} -- Киберкафе
roomLevel["dartgame"] = {1, 2} -- Дартс
roomLevel["daycare"] = {0, 2} -- Детский сад
roomLevel["deepfry_kitchen"] = {1, 3} -- Кухня фритюра
roomLevel["dentist"] = {2, 2} -- Дантист
roomLevel["dentiststorage"] = {2, 2} -- Хранилище дантиста
roomLevel["departmentstorage"] = {2, 2} -- Хранилище универмага
roomLevel["derelict"] = {0, 2} -- Заброшенное
roomLevel["detectiveoffice"] = {2, 2} -- Офис детектива
roomLevel["dinerbackroom"] = {1, 2} -- Задняя комната закусочной
roomLevel["dinercounter"] = {1, 2} -- Стойка закусочной
roomLevel["dogfoodfactory"] = {2, 2} -- Фабрика собачьего корма
roomLevel["dogfoodshipping"] = {2, 2} -- Склад собачьего корма
roomLevel["dogfoodstorage"] = {2, 2} -- Хранилище собачьего корма
roomLevel["donut_dining"] = {1, 2} -- Столовая пончиков
roomLevel["donut_kitchen"] = {1, 3} -- Кухня пончиков
roomLevel["donut_kitchenstorage"] = {2, 2} -- Хранилище кухни пончиков
roomLevel["druglab"] = {3, 2} -- Нарколаборатория
roomLevel["drugshack"] = {2, 2} -- Нарколачуга
roomLevel["duckshootgame"] = {1, 2} -- Игра "стрельба по уткам"
roomLevel["eggstorage"] = {2, 2} -- Хранилище яиц
roomLevel["electronicsstorage"] = {2, 2} -- Хранилище электроники
roomLevel["elementaryclassroom"] = {0, 2} -- Начальная школа, класс
roomLevel["elementaryschool"] = {0, 2} -- Начальная школа
roomLevel["evidenceroom"] = {3, 2} -- Комната улик
roomLevel["factory"] = {2, 2} -- Фабрика
roomLevel["factorystorage"] = {2, 2} -- Хранилище фабрики
roomLevel["firegarage"] = {2, 2} -- Пожарный гараж
roomLevel["firestorage"] = {2, 2} -- Пожарное хранилище
roomLevel["fishchipskitchen"] = {1, 3} -- Кухня рыбы с картошкой
roomLevel["fryshipping"] = {2, 2} -- Склад фритюра
roomLevel["glassesstore"] = {2, 2} -- Магазин очков
roomLevel["golffactory"] = {2, 2} -- Фабрика гольфа
roomLevel["golfshipping"] = {2, 2} -- Склад гольфа
roomLevel["golfstore"] = {1, 3} -- Магазин гольфа
roomLevel["gym"] = {1, 2} -- Спортзал
roomLevel["gymstorage"] = {2, 2} -- Хранилище спортзала
roomLevel["homecinema"] = {1, 2} -- Домашний кинотеатр
roomLevel["hoopgame"] = {1, 2} -- Игра с кольцами
roomLevel["hospitalhallway"] = {1, 2} -- Коридор больницы
roomLevel["hospitalroom"] = {2, 2} -- Комната больницы
roomLevel["hospitalstorage"] = {2, 2} -- Хранилище больницы
roomLevel["hotdogstand"] = {1, 2} -- Ларёк с хот-догами
roomLevel["interrogationroom"] = {2, 2} -- Комната допросов
roomLevel["italiankitchen"] = {1, 3} -- Итальянская кухня
roomLevel["italianrestaurant"] = {1, 3} -- Итальянский ресторан
roomLevel["jackiejayeoffice"] = {1, 2} -- Офис Jackie Jaye
roomLevel["jackiejayestudio"] = {1, 2} -- Студия Jackie Jaye
roomLevel["janitor"] = {1, 2} -- Комната уборщика
roomLevel["jayschicken_dining"] = {1, 2} -- Столовая Jays Chicken
roomLevel["jayschicken_kitchen"] = {1, 3} -- Кухня Jays Chicken
roomLevel["jerkycoldroom"] = {2, 2} -- Холодильник для вяленого мяса
roomLevel["jerkyfactory"] = {2, 2} -- Фабрика вяленого мяса
roomLevel["jerkyshipping"] = {2, 2} -- Склад вяленого мяса
roomLevel["joanstudio"] = {1, 2} -- Студия Joan
roomLevel["judgematthassset"] = {2, 2} -- Судебный зал
roomLevel["kennels"] = {1, 2} -- Питомник
roomLevel["kidsbedroom"] = {0, 2} -- Детская спальня
roomLevel["kitchenwares"] = {1, 2} -- Магазин кухонной утвари
roomLevel["knifefactory"] = {2, 2} -- Фабрика ножей
roomLevel["knifeshipping"] = {2, 2} -- Склад ножей
roomLevel["knifestore"] = {1, 3} -- Магазин ножей
roomLevel["laboratory"] = {3, 2} -- Лаборатория
roomLevel["leatherclothesstore"] = {1, 3} -- Магазин кожаной одежды
roomLevel["lingeriestore"] = {1, 3} -- Магазин белья
roomLevel["liquorstore"] = {2, 2} -- Магазин спиртного
roomLevel["loggingtruck"] = {1, 2} -- Лесовоз
roomLevel["loggingwarehouse"] = {2, 2} -- Склад лесозаготовок
roomLevel["mannequinfactory"] = {2, 2} -- Фабрика манекенов
roomLevel["mapfactory"] = {2, 2} -- Фабрика карт
roomLevel["mayorwestpointoffice"] = {2, 2} -- Офис мэра
roomLevel["metalshipping"] = {2, 2} -- Склад металла
roomLevel["metalshop"] = {2, 2} -- Металлическая мастерская
roomLevel["mexicankitchen"] = {1, 3} -- Мексиканская кухня
roomLevel["morgue"] = {2, 2} -- Морг
roomLevel["movierental"] = {1, 3} -- Прокат фильмов
roomLevel["newspaperprint"] = {2, 2} -- Типография газет
roomLevel["newspapershipping"] = {2, 2} -- Склад газет
roomLevel["newspaperstorage"] = {2, 2} -- Хранилище газет
roomLevel["nolansoffice"] = {1, 2} -- Офис Nolans
roomLevel["officechurch"] = {0, 3} -- Офис церкви
roomLevel["officestorage"] = {2, 2} -- Хранилище офиса
roomLevel["oldarmy"] = {3, 2} -- Старая армия
roomLevel["oldmedical"] = {2, 2} -- Старая медицина
roomLevel["paintershop"] = {2, 2} -- Малярная мастерская
roomLevel["pawnshop"] = {2, 3} -- Ломбард
roomLevel["pawnshopoffice"] = {2, 2} -- Офис ломбарда
roomLevel["pawnshopstorage"] = {2, 2} -- Хранилище ломбарда
roomLevel["photoroom"] = {1, 2} -- Фотостудия
roomLevel["picnic"] = {0, 2} -- Пикник
roomLevel["pileocrepe"] = {1, 2} -- Pile o' Crepe
roomLevel["pizzawhirledcounter"] = {1, 2} -- Стойка Pizza Whirled
roomLevel["policearchive"] = {3, 2} -- Архив полиции
roomLevel["policegarage"] = {2, 2} -- Гараж полиции
roomLevel["policegunstorage"] = {4, 1} -- Хранилище оружия полиции
roomLevel["policelocker"] = {2, 2} -- Раздевалка полиции
roomLevel["policeoffice"] = {2, 2} -- Офис полиции
roomLevel["pool"] = {1, 2} -- Бассейн
roomLevel["potatostorage"] = {2, 2} -- Хранилище картофеля
roomLevel["prisoncells"] = {3, 2} -- Тюремные камеры
roomLevel["prisonstorage"] = {3, 2} -- Хранилище тюрьмы
roomLevel["producestorage"] = {2, 2} -- Хранилище продуктов
roomLevel["radiofactory"] = {2, 2} -- Фабрика радио
roomLevel["radioshipping"] = {2, 2} -- Склад радио
roomLevel["radiostorage"] = {2, 2} -- Хранилище радио
roomLevel["railroadrepair"] = {2, 2} -- Ремонт железной дороги
roomLevel["railroadstorage"] = {2, 2} -- Хранилище железной дороги
roomLevel["recreation"] = {1, 2} -- Зона отдыха
roomLevel["restaurantdining"] = {1, 2} -- Столовая ресторана
roomLevel["ringtossgame"] = {1, 2} -- Игра с кольцами
roomLevel["schoolgymstorage"] = {2, 2} -- Хранилище школьного спортзала
roomLevel["schoolstorage"] = {2, 2} -- Хранилище школы
roomLevel["seafoodkitchen"] = {1, 3} -- Кухня морепродуктов
roomLevel["secondaryclassroom"] = {0, 2} -- Средняя школа, класс
roomLevel["secondaryhall"] = {1, 2} -- Коридор средней школы
roomLevel["smokingroom"] = {1, 2} -- Курительная комната
roomLevel["sodatruck"] = {1, 2} -- Грузовик с газировкой
roomLevel["spiffo_dining"] = {1, 2} -- Столовая Spiffo
roomLevel["storage"] = {2, 2} -- Общее хранилище
roomLevel["stripclub"] = {2, 2} -- Стрип-клуб
roomLevel["studio"] = {1, 2} -- Студия
roomLevel["sushidining"] = {1, 2} -- Столовая суши
roomLevel["sushikitchen"] = {1, 3} -- Кухня суши
roomLevel["teacherroom"] = {1, 2} -- Комната учителя
roomLevel["technical"] = {2, 2} -- Техническая комната
roomLevel["throwgame"] = {1, 2} -- Игра с метанием
roomLevel["thundergas"] = {2, 2} -- Thunder Gas
roomLevel["tobaccostorage"] = {2, 2} -- Хранилище табака
roomLevel["tobaccostore"] = {2, 2} -- Магазин табака
roomLevel["toolstorestorage"] = {2, 2} -- Хранилище магазина инструментов
roomLevel["toystorestorage"] = {2, 2} -- Хранилище магазина игрушек
roomLevel["universitylibrary"] = {0, 3} -- Университетская библиотека
roomLevel["universitystorage"] = {2, 2} -- Хранилище университета
roomLevel["viplounge"] = {2, 2} -- VIP-зал
roomLevel["waitingroom"] = {1, 2} -- Комната ожидания
roomLevel["walletshop"] = {2, 2} -- Магазин кошельков
roomLevel["weddingstoredress"] = {1, 3} -- Свадебный магазин платьев
roomLevel["weddingstorestorage"] = {2, 2} -- Хранилище свадебного магазина
roomLevel["weddingstoresuit"] = {1, 3} -- Свадебный магазин костюмов
roomLevel["weldingstorage"] = {2, 2} -- Хранилище сварки
roomLevel["weldingworkshop"] = {2, 2} -- Сварочная мастерская
roomLevel["westernkitchen"] = {1, 3} -- Западная кухня
roomLevel["whiskeybottling"] = {2, 2} -- Розлив ви ски
roomLevel["wirefactory"] = {2, 2} -- Фабрика проволоки
roomLevel["woodcraftset"] = {2, 2} -- Деревообрабатывающий цех
roomLevel["ww_aesthetic"] = {2, 2} -- WW эстетика
roomLevel["ww_bar"] = {1, 2} -- WW бар
roomLevel["ww_bedroom"] = {0, 2} -- WW спальня
roomLevel["ww_blacksmith"] = {2, 2} -- WW кузница
roomLevel["ww_generalstore"] = {1, 3} -- WW универсальный магазин
roomLevel["ww_hall"] = {1, 2} -- WW коридор
roomLevel["ww_kitchen"] = {1, 2} -- WW кухня
roomLevel["ww_livingroom"] = {0, 2} -- WW гостиная
roomLevel["ww_sheriff"] = {2, 2} -- WW шериф
roomLevel["ww_toolstore"] = {1, 3} -- WW магазин инструментов
roomLevel["zippeestorage"] = {2, 2} -- Хранилище Zippee




function BetLock.Utils.getLockpickLevelBuildingObj(obj)
    local sq1 = obj:getSquare()
    local sq2 = obj:getOppositeSquare()
    local name = nil

    if sq1 and sq1:getRoom() then
        name = sq1:getRoom():getName()
    elseif sq2 and sq2:getRoom() then
        name = sq2:getRoom():getName()
    end

    local level
    if name == nil or roomLevel[name] == nil then
        level = ZombRand(2)
    else
        level = roomLevel[name][1] + ZombRand(roomLevel[name][2])
    end

    local tmp = {}
    tmp.name = LevelTable[level][1] 
    tmp.num = LevelTable[level][2]
    tmp.xp = LevelTable[level][3]

    return tmp
end

function BetLock.Utils.getLockpickingLevelVehicle(vehicle)
    local mechType = vehicle:getScript():getMechanicType()
    local level = 1

    if mechType == 1 then
        level = 1 + ZombRand(2)
    elseif mechType == 2 then
        level = 2 + ZombRand(2)
    elseif mechType == 3 then
        level = 3 + ZombRand(2)
    end

    local name = vehicle:getScript():getName():lower()

    if name:contains("police") or name:contains("fire") or name:contains("ranger") or name:contains("sheriff") then
        level = 2 + ZombRand(2)
    end

    local tmp = {}
    tmp.name = LevelTable[level][1] 
    tmp.num = LevelTable[level][2]
    tmp.xp = LevelTable[level][3]

    return tmp
end

function BetLock.Utils.getHotwireLevelVehicle(vehicle)
    local mechType = vehicle:getScript():getMechanicType()
    local level = 0

    if mechType == 1 then
        level = 1 
    elseif mechType == 2 then
        level = 2
    elseif mechType == 3 then
        level = 3
    end

    local name = vehicle:getScript():getName():lower()

    if name:contains("police") or name:contains("fire") or name:contains("ranger") or name:contains("sheriff") or name:contains("swat") or name:contains("lights") then
        level = 3 + ZombRand(2)
    end

    local tmp = {}
    tmp.name = LevelTable[level][1] 
    tmp.num = LevelTable[level][2]
    tmp.xp = LevelTable[level][3]

    return tmp
end


local chanceBreakByLevel = {}
chanceBreakByLevel[0] = 0.005
chanceBreakByLevel[1] = 0.02
chanceBreakByLevel[2] = 0.04
chanceBreakByLevel[3] = 0.05
chanceBreakByLevel[4] = 0.1
chanceBreakByLevel[5] = 0.25
chanceBreakByLevel[6] = 0.4
chanceBreakByLevel[7] = 0.55
chanceBreakByLevel[8] = 0.70
chanceBreakByLevel[9] = 0.85
chanceBreakByLevel[10] = 1.0
chanceBreakByLevel[11] = 1.2
chanceBreakByLevel[12] = 1.4
chanceBreakByLevel[13] = 1.6
chanceBreakByLevel[14] = 1.8
chanceBreakByLevel[15] = 2.0
chanceBreakByLevel[16] = 2.2
chanceBreakByLevel[17] = 2.4
chanceBreakByLevel[18] = 2.6

function BetLock.Utils.getChanceBreakLock(playerLevel, lockLevel)
    return chanceBreakByLevel[playerLevel - lockLevel + 8]
end


local diffByLevel = {}
diffByLevel[0] = 0.005
diffByLevel[1] = 0.02
diffByLevel[2] = 0.04
diffByLevel[3] = 0.05
diffByLevel[4] = 0.1
diffByLevel[5] = 0.25
diffByLevel[6] = 0.4
diffByLevel[7] = 0.55
diffByLevel[8] = 0.70
diffByLevel[9] = 0.85
diffByLevel[10] = 1.0
diffByLevel[11] = 1.2
diffByLevel[12] = 1.4
diffByLevel[13] = 1.6
diffByLevel[14] = 1.8
diffByLevel[15] = 2.0
diffByLevel[16] = 2.2
diffByLevel[17] = 2.4
diffByLevel[18] = 2.6


function BetLock.Utils.getDiffAngleBobbyPin(skill, level)
    return diffByLevel[skill - level + 8]
end



local crowbarSizeByLevel = {}
crowbarSizeByLevel[0] = {1, 2}
crowbarSizeByLevel[1] = {2, 4}
crowbarSizeByLevel[2] = {2, 4}
crowbarSizeByLevel[3] = {3, 6}
crowbarSizeByLevel[4] = {3, 6}
crowbarSizeByLevel[5] = {4, 8}
crowbarSizeByLevel[6] = {6, 12}
crowbarSizeByLevel[7] = {8, 16}
crowbarSizeByLevel[8] = {10, 20}
crowbarSizeByLevel[9] = {12, 24}
crowbarSizeByLevel[10] = {14, 28}
crowbarSizeByLevel[11] = {16, 32}
crowbarSizeByLevel[12] = {18, 36}
crowbarSizeByLevel[13] = {20, 40}
crowbarSizeByLevel[14] = {22, 44}
crowbarSizeByLevel[15] = {25, 50}
crowbarSizeByLevel[16] = {30, 60}
crowbarSizeByLevel[17] = {35, 70}
crowbarSizeByLevel[18] = {40, 80}

function BetLock.Utils.getGreenYellowSize(skill, level)
    return crowbarSizeByLevel[skill - level + 8]
end

