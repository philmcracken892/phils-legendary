Config = {}

Config.HuntTimer = 1800  -- Hunt duration in seconds (30 minutes)

Config.Rewards = {
    Cash = 100,          -- Cash reward amount for killing a legendary animal
    Trophy = true,       -- Whether to give a trophy for killing a legendary animal
    TrophyItem = 'legendary_trophy'  -- Item code for the trophy
}

Config.SpawnLocations = {
    -- Major Towns
    ["Valentine"] = {x = -284.49, y = 804.42, z = 119.38},
    ["Saint Denis"] = {x = 2631.9, y = -1242.4, z = 53.9},
    ["Rhodes"] = {x = 1346.35, y = -1307.9, z = 77.0},
    ["Blackwater"] = {x = -732.51, y = -1252.44, z = 44.73},
    ["Strawberry"] = {x = -1770.73, y = -391.03, z = 156.69},
    ["Tumbleweed"] = {x = -5517.17, y = -2937.8, z = -1.95},
    ["Armadillo"] = {x = -3666.15, y = -2626.54, z = -13.75},
    ["Van Horn"] = {x = 2930.56, y = 1330.22, z = 43.98},
    ["Annesburg"] = {x = 2923.16, y = 1351.93, z = 44.86},
    ["Caliga Hall"] = {x = 1917.10, y = -1337.77, z = 42.76},
    -- Smaller Settlements
    ["Butcher Creek"] = {x = 2517.75, y = 811.94, z = 74.95},
    ["Emerald Ranch"] = {x = 1417.90, y = 267.01, z = 89.63},
    ["Lagras"] = {x = 2034.56, y = -642.36, z = 42.09},
    ["Manzanita Post"] = {x = -1990.20, y = -1530.51, z = 114.33},
    ["Wapiti"] = {x = 446.36, y = 2150.68, z = 221.89},
    ["Colter"] = {x = -1354.39, y = 2421.61, z = 307.47},
    ["Braithwaite Manor"] = {x = 1011.27, y = -1707.46, z = 46.80},
    ["Thieves Landing"] = {x = -1389.46, y = -2378.92, z = 43.11},
    ["Fort Mercer"] = {x = -4214.88, y = -3442.10, z = 37.08},
    ["MacFarlane's Ranch"] = {x = -2386.59, y = -2378.02, z = 61.19},
    -- Ranches & Farms
    ["Beecher's Hope"] = {x = -1643.93, y = -1358.64, z = 83.30},
    ["Painted Sky"] = {x = -1337.41, y = 499.19, z = 93.43},
    ["Hanging Dog Ranch"] = {x = -1801.48, y = 410.93, z = 113.75},
    ["Downes Ranch"] = {x = -813.39, y = 347.36, z = 97.69},
    ["Carmody Dell"] = {x = 1077.10, y = 495.70, z = 96.42},
    ["Larned Sod"] = {x = 1787.36, y = 862.34, z = 113.44},
    ["Guthrie Farm"] = {x = 1185.15, y = 427.12, z = 92.83},
    ["Aberdeen Pig Farm"] = {x = 2010.00, y = -762.00, z = 42.00},
    ["Hill Haven Ranch"] = {x = -1508.00, y = -333.00, z = 155.00},
    ["Watson's Cabin"] = {x = -2071.78, y = 552.54, z = 119.87},
    -- Landmarks & Regions
    ["Ambarino"] = {x = -304.94, y = 1774.36, z = 195.20},
    ["New Hanover"] = {x = 879.09, y = 284.30, z = 118.21},
    ["Lemoyne"] = {x = 1889.42, y = -922.59, z = 42.66},
    ["West Elizabeth"] = {x = -1347.55, y = -665.33, z = 100.80},
    ["New Austin"] = {x = -3404.04, y = -2536.42, z = 0.67},
    ["Grizzlies East"] = {x = 776.74, y = 1927.16, z = 258.37},
    ["Grizzlies West"] = {x = -1823.33, y = 1268.12, z = 214.99},
    ["Bayou Nwa"] = {x = 2262.89, y = -780.19, z = 41.66},
    ["Bluewater Marsh"] = {x = 2359.50, y = 186.66, z = 45.23},
    ["Big Valley"] = {x = -1585.85, y = -174.48, z = 132.43},
    -- Camps & Hideouts
    ["Clemens Point"] = {x = 1898.21, y = -1868.95, z = 43.13},
    ["Horseshoe Overlook"] = {x = -131.22, y = 593.88, z = 114.22},
    ["Whiskey Tree"] = {x = 591.90, y = 1691.84, z = 187.65},
    ["Twin Rocks"] = {x = -3949.35, y = -2140.81, z = -5.22},
    ["Six Point Cabin"] = {x = -2369.38, y = 124.16, z = 216.15},
    ["Dodd's Bluff"] = {x = 2166.25, y = -618.00, z = 42.12},
    ["Fort Brennand"] = {x = 2386.07, y = 1686.28, z = 96.39},
    ["The Loft"] = {x = -1546.35, y = 2097.94, z = 314.31},
    ["Ewing Basin"] = {x = -1339.35, y = 2419.42, z = 306.45},
    ["Nekoti Rock"] = {x = -1672.65, y = 1596.49, z = 194.44}
}

Config.LegendaryAnimals = {
    { hash = 0xAA89BB8D, model = 'mp_a_c_cougar_01', outfit = 4, names = {'Legendary Cougar', 'Golden Cougar'}, clueModel = 'p_horsepoop03x'},
    { hash = 0xE8CBC01C, model = 'mp_a_c_boar_01', outfit = 5, names = {'Legendary Boar', 'Feral Boar'}, clueModel = 'p_horsepoop03x'},
    { hash = 0x9770DD23, model = 'mp_a_c_buck_01', outfit = 6, names = {'Legendary Buck', 'Majestic Buck'}, clueModel = 'p_horsepoop03x'},
    { hash = 0xDECA9205, model = 'mp_a_c_fox_01', outfit = 4, names = {'Legendary Fox', 'Silver Fox'}, clueModel = 'p_horsepoop03x'},
    { hash = 0x2830CF33, model = 'a_c_alligator_02', outfit = 4, names = {'Legendary Alligator', 'Swamp King'}, clueModel = 'p_horsepoop03x'},
    { hash = 0xBB746741, model = 'mp_a_c_beaver_01', outfit = 3, names = {'Legendary Beaver', 'River Builder'}, clueModel = 'p_horsepoop03x'},
    { hash = 0xAD02460F, model = 'mp_a_c_wolf_01', outfit = 5, names = {'Legendary Wolf', 'Midnight Wolf'}, clueModel = 'p_horsepoop03x'},
    { hash = 0xD1641E60, model = 'mp_a_c_elk_01', outfit = 4, names = {'Legendary Elk', 'Great Elk'}, clueModel = 'p_horsepoop03x'},
    { hash = 0xB20D360D, model = 'mp_a_c_coyote_01', outfit = 4, names = {'Legendary Coyote', 'Desert Stalker'}, clueModel = 'p_horsepoop03x'},
    { hash = 0xB91BAB89, model = 'mp_a_c_panther_01', outfit = 4, names = {'Legendary Panther', 'Shadow Panther'}, clueModel = 'p_horsepoop03x'},
    { hash = 0xE1884260, model = 'mp_a_c_bighornram_01', outfit = 5, names = {'Legendary Ram', 'Mountain Lord'}, clueModel = 'p_horsepoop03x'},
    { hash = 0xF3D63D2D, model = 'mp_a_c_bear_01', outfit = 4, names = {'Legendary Bear', 'Bharati Grizzly'}, clueModel = 'p_horsepoop03x'},
    { hash = 0xA0E9B6A8, model = 'a_c_buffalo_tatanka_01', outfit = 5, names = {'Legendary White Bison', 'Snow Bison'}, clueModel = 'p_horsepoop03x'},
    { hash = 0xC87D6F8E, model = 'mp_a_c_pronghorn_01', outfit = 4, names = {'Legendary Pronghorn', 'Sun Pronghorn'}, clueModel = 'p_horsepoop03x'},
    { hash = 0x7E7C6F2A, model = 'mp_a_c_moose_01', outfit = 5, names = {'Legendary Moose', 'Snow Moose'}, clueModel = 'p_horsepoop03x'}
}