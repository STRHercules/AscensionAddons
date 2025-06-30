local ADDON_NAME = "AAC_MapMarker"
local MARKER_SIZE = 16
local CONTROL_BUTTON_SIZE = 24
local ICON_BAG = "Interface\\Icons\\INV_Misc_Bag_08"
local ICON_STAR = "Interface\\Icons\\Spell_ChargePositive"
local ICON_SKULL = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"
local ICON_CROSS = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7"
local ICON_SQUARE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6"
local ICON_MOON = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5"
local ICON_TRIANGLE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4"
local ICON_DIAMOND = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3"
local ICON_CIRCLE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2"
local ICON_VENDOR = "Interface\\Icons\\INV_Misc_Coin_01"
local ICON_RARE = "Interface\\Icons\\Ability_Hunter_SniperShot"
local ICON_CHEST = "Interface\\Icons\\INV_Box_01"
local ICON_QUEST = "Interface\\Icons\\INV_Misc_Note_01"
local ICON_CAVE = "Interface\\Icons\\Spell_Nature_EarthBindTotem"
local FONT_PATH = "Fonts\\FRIZQT__.TTF"
local FONT_SIZE = 9

local AAC_MapMarker = CreateFrame("Frame")

local DefaultMapMarkerDB = {
	["markers"] = {
		["813730181"] = {
			["mapID"] = 474,
			["posY"] = 0.002129020868240481,
			["posX"] = 0.03618315437852337,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["957457567"] = {
			["mapID"] = 41,
			["posY"] = -0.2852956997698075,
			["posX"] = 0.2654135100829202,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["796910540"] = {
			["mapID"] = 480,
			["posY"] = 0.1128410380684222,
			["posX"] = -0.0539476172617951,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["957438847"] = {
			["mapID"] = 24,
			["posY"] = 0.05748505567661442,
			["posX"] = -0.04756048417250389,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["622276828"] = {
			["mapID"] = 16,
			["posY"] = -0.3393214455356759,
			["posX"] = -0.30535605034618,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810497891"] = {
			["mapID"] = 474,
			["posY"] = -0.2118433172324494,
			["posX"] = 0.08728091798037711,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["621916484"] = {
			["mapID"] = 82,
			["posY"] = -0.1328008823595087,
			["posX"] = 0.09420032380856802,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810806903"] = {
			["mapID"] = 480,
			["posY"] = 0.3896208451943285,
			["posX"] = -0.03762467978720841,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["621782546"] = {
			["mapID"] = 282,
			["posY"] = 0.1120425593164209,
			["posX"] = 0.1112329815646051,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["622024125"] = {
			["mapID"] = 183,
			["posY"] = -0.3254825023542901,
			["posX"] = 0.01684395812433688,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["622262984"] = {
			["mapID"] = 17,
			["posY"] = 0.1812376159310298,
			["posX"] = -0.1655468158894036,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["621940828"] = {
			["mapID"] = 262,
			["posY"] = -0.3936127819473991,
			["posX"] = -0.07825464581987689,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["621993671"] = {
			["mapID"] = 25,
			["posY"] = 0.03539601606840317,
			["posX"] = 0.2645264121476716,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["809735895"] = {
			["mapID"] = 468,
			["posY"] = -0.1096472098753545,
			["posX"] = 0.09934565061151954,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["622079812"] = {
			["mapID"] = 142,
			["posY"] = 0.3292082718792774,
			["posX"] = 0.2702039647330173,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810863776"] = {
			["mapID"] = 466,
			["posY"] = 0.1650034535309842,
			["posX"] = -0.1036260331217476,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["622160046"] = {
			["mapID"] = 20,
			["posY"] = 0.3539586406036124,
			["posX"] = 0.00956979698854955,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810841915"] = {
			["mapID"] = 480,
			["posY"] = 0.2107784042554807,
			["posX"] = -0.12917496187918,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["621850937"] = {
			["mapID"] = 62,
			["posY"] = -0.2719897716409395,
			["posX"] = 0.2977044899469922,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["622150609"] = {
			["mapID"] = 30,
			["posY"] = 0.2057218657488036,
			["posX"] = 0.4355620809907205,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810602079"] = {
			["mapID"] = 479,
			["posY"] = 0.3214904214556624,
			["posX"] = 0.007795461340547305,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["622223375"] = {
			["mapID"] = 44,
			["posY"] = -0.1642051148294958,
			["posX"] = 0.1875247318822844,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810482656"] = {
			["mapID"] = 474,
			["posY"] = 0.1394545012215156,
			["posX"] = 0.1298624575373412,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810671986"] = {
			["mapID"] = 478,
			["posY"] = -0.1990690331352897,
			["posX"] = -0.1753049980102672,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["621808484"] = {
			["mapID"] = 23,
			["posY"] = 0.3435793218323699,
			["posX"] = -0.05235086893384847,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["809996929"] = {
			["mapID"] = 466,
			["posY"] = -0.2480372968962894,
			["posX"] = -0.05536705782469581,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["621954750"] = {
			["mapID"] = 29,
			["posY"] = -0.009314685895299648,
			["posX"] = -0.1109005207690503,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["622005015"] = {
			["mapID"] = 122,
			["posY"] = -0.2903526314007311,
			["posX"] = -0.1556110813928605,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["622071265"] = {
			["mapID"] = 142,
			["posY"] = -0.2381898924296746,
			["posX"] = -0.09244842245011235,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["796119494"] = {
			["mapID"] = 468,
			["posY"] = 0.08383196339143148,
			["posX"] = 0.001585705905054468,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["797410077"] = {
			["mapID"] = 468,
			["posY"] = -0.1831005883274703,
			["posX"] = -0.06175419091398703,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["958009529"] = {
			["mapID"] = 82,
			["posY"] = 0.3811045160187122,
			["posX"] = -0.1667886691322487,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["957353680"] = {
			["mapID"] = 182,
			["posY"] = 0.1511643621089973,
			["posX"] = 0.3988357512279105,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["810665925"] = {
			["mapID"] = 478,
			["posY"] = 0.265069858604478,
			["posX"] = 0.1845087526576946,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["957851856"] = {
			["mapID"] = 202,
			["posY"] = -0.277844291761248,
			["posX"] = 0.005666440273701086,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["621903906"] = {
			["mapID"] = 39,
			["posY"] = -0.2051894182694168,
			["posX"] = -0.3663895135002007,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810750760"] = {
			["mapID"] = 476,
			["posY"] = 0.2714571316944734,
			["posX"] = 0.2277999426073564,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["957844308"] = {
			["mapID"] = 202,
			["posY"] = -0.09048638652012614,
			["posX"] = 0.1930251164800893,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["957839780"] = {
			["mapID"] = 202,
			["posY"] = -0.0340656140026769,
			["posX"] = -0.1213683882269881,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["621882984"] = {
			["mapID"] = 12,
			["posY"] = 0.1280107420414092,
			["posX"] = 0.11549109358705,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["621822953"] = {
			["mapID"] = 23,
			["posY"] = -0.1410513809196781,
			["posX"] = -0.1011421289819292,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["621815421"] = {
			["mapID"] = 23,
			["posY"] = 0.02581526368310869,
			["posX"] = 0.1878796968561383,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["622204656"] = {
			["mapID"] = 182,
			["posY"] = -0.1155024196011121,
			["posX"] = -0.0003660073967460438,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["957464486"] = {
			["mapID"] = 41,
			["posY"] = 0.3598137454962376,
			["posX"] = -0.1682079699176445,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["957451243"] = {
			["mapID"] = 41,
			["posY"] = 0.07132407748284943,
			["posX"] = 0.2760591046384187,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["810896762"] = {
			["mapID"] = 466,
			["posY"] = -0.1053893073703774,
			["posX"] = -0.3598247581464776,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["957431666"] = {
			["mapID"] = 24,
			["posY"] = -0.2278121813727983,
			["posX"] = 0.3292858194183663,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["957425098"] = {
			["mapID"] = 24,
			["posY"] = 0.4013307060818102,
			["posX"] = 0.1518628777085211,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["957412362"] = {
			["mapID"] = 82,
			["posY"] = 0.1192283111584176,
			["posX"] = 0.03689287465997367,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["622014781"] = {
			["mapID"] = 183,
			["posY"] = 0.4175648856810416,
			["posX"] = 0.133233401735785,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810658016"] = {
			["mapID"] = 478,
			["posY"] = 0.1256158987478101,
			["posX"] = 0.1830893120947937,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810308437"] = {
			["mapID"] = 479,
			["posY"] = -0.03725909329797603,
			["posX"] = 0.173863437657206,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["622114703"] = {
			["mapID"] = 35,
			["posY"] = 0.2994011721811863,
			["posX"] = 0.3063981615344327,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["622201234"] = {
			["mapID"] = 182,
			["posY"] = -0.411710125591141,
			["posX"] = -0.04347981969260972,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["957383176"] = {
			["mapID"] = 33,
			["posY"] = -0.2821020632248098,
			["posX"] = -0.06175426080273947,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["957358243"] = {
			["mapID"] = 182,
			["posY"] = -0.4109117909846966,
			["posX"] = 0.04115098668241866,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["957830505"] = {
			["mapID"] = 202,
			["posY"] = 0.3257485336269044,
			["posX"] = -0.1355621648572236,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["809707933"] = {
			["mapID"] = 478,
			["posY"] = -0.05748502127824306,
			["posX"] = 0.2356065162595483,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810694016"] = {
			["mapID"] = 468,
			["posY"] = 0.09048589675283558,
			["posX"] = -0.3470503871347666,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["622249062"] = {
			["mapID"] = 17,
			["posY"] = -0.3095141623796032,
			["posX"] = -0.1783212218454908,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["621878421"] = {
			["mapID"] = 12,
			["posY"] = 0.00452438832750161,
			["posX"] = 0.009037314583392402,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["621835609"] = {
			["mapID"] = 202,
			["posY"] = -0.239254944638147,
			["posX"] = 0.2098801170273183,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["621867203"] = {
			["mapID"] = 27,
			["posY"] = -0.01357258840027683,
			["posX"] = -0.2194833557839303,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810596231"] = {
			["mapID"] = 479,
			["posY"] = 0.076646717696902,
			["posX"] = -0.1923374810444231,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810618418"] = {
			["mapID"] = 478,
			["posY"] = 0.2118430371314236,
			["posX"] = -0.2327900344789171,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["622035593"] = {
			["mapID"] = 24,
			["posY"] = -0.1527611107657443,
			["posX"] = -0.1366268501125279,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["957394129"] = {
			["mapID"] = 33,
			["posY"] = -0.05854986382045069,
			["posX"] = 0.07024840000184501,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["621776750"] = {
			["mapID"] = 282,
			["posY"] = 0.4015969126223179,
			["posX"] = -0.01083394474343633,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810488155"] = {
			["mapID"] = 474,
			["posY"] = -0.1884235954574861,
			["posX"] = -0.03478607821641667,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["797028780"] = {
			["mapID"] = 476,
			["posY"] = 0.1234863709130933,
			["posX"] = 0.02979602128923215,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810493038"] = {
			["mapID"] = 474,
			["posY"] = -0.1245511266403634,
			["posX"] = 0.2015413405249791,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810591594"] = {
			["mapID"] = 479,
			["posY"] = -0.1479705863324957,
			["posX"] = -0.1022067792928572,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810727104"] = {
			["mapID"] = 468,
			["posY"] = -0.4098486388767487,
			["posX"] = 0.2505100830599867,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["630714180"] = {
			["mapID"] = 38,
			["posY"] = -0.2626751381622061,
			["posX"] = -0.2265801742102956,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810703458"] = {
			["mapID"] = 468,
			["posY"] = 0.1618097473702345,
			["posX"] = -0.2022732155409662,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810761880"] = {
			["mapID"] = 476,
			["posY"] = -0.205456044142454,
			["posX"] = -0.1341428640718278,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810744598"] = {
			["mapID"] = 476,
			["posY"] = 0.2671989146900989,
			["posX"] = 0.1568308497899213,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810689673"] = {
			["mapID"] = 468,
			["posY"] = 0.4364603935773876,
			["posX"] = -0.3115658057816729,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810823694"] = {
			["mapID"] = 480,
			["posY"] = -0.2746512055901954,
			["posX"] = 0.06457084741649932,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["621795984"] = {
			["mapID"] = 41,
			["posY"] = -0.2509643861930991,
			["posX"] = 0.2531714467544851,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["622127718"] = {
			["mapID"] = 102,
			["posY"] = -0.1147042987559767,
			["posX"] = 0.05445773526615801,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["621893000"] = {
			["mapID"] = 162,
			["posY"] = 0.2376579691159496,
			["posX"] = 0.1694276684259529,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810264270"] = {
			["mapID"] = 474,
			["posY"] = 0.1234863709130933,
			["posX"] = -0.08446433136661727,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["957697151"] = {
			["mapID"] = 202,
			["posY"] = 0.2948768534694367,
			["posX"] = 0.205799452547424,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		},
		["810698195"] = {
			["mapID"] = 468,
			["posY"] = -0.1256152615589275,
			["posX"] = -0.346340573486311,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["621932562"] = {
			["mapID"] = 262,
			["posY"] = 0.1237524202039025,
			["posX"] = -0.005156392158090623,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["622139203"] = {
			["mapID"] = 33,
			["posY"] = -0.2520291239021744,
			["posX"] = -0.02218898002537517,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["622176140"] = {
			["mapID"] = 18,
			["posY"] = -0.06147687449241112,
			["posX"] = 0.09420046358607292,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810755736"] = {
			["mapID"] = 476,
			["posY"] = -0.2192949873238398,
			["posX"] = 0.2654136498604252,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["621841781"] = {
			["mapID"] = 202,
			["posY"] = 0.4260813196897902,
			["posX"] = -0.04986695278190082,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["622049765"] = {
			["mapID"] = 24,
			["posY"] = -0.0412509465121441,
			["posX"] = 0.2467841738876891,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810586523"] = {
			["mapID"] = 479,
			["posY"] = -0.2980703769912137,
			["posX"] = 0.1660567941162615,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["797103760"] = {
			["mapID"] = 479,
			["posY"] = -0.1415834442839159,
			["posX"] = -0.3058880899405694,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810477472"] = {
			["mapID"] = 474,
			["posY"] = 0.2235528980189053,
			["posX"] = -0.04472160304670237,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["622192781"] = {
			["mapID"] = 182,
			["posY"] = -0.2978045897832355,
			["posX"] = -0.07541583458282782,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["621969140"] = {
			["mapID"] = 242,
			["posY"] = 0.05562215371493495,
			["posX"] = 0.02677969262087991,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810709084"] = {
			["mapID"] = 468,
			["posY"] = -0.004258094972056289,
			["posX"] = 0.2036704314805778,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810512010"] = {
			["mapID"] = 474,
			["posY"] = -0.3619432520367244,
			["posX"] = 0.1767021790055026,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["630710842"] = {
			["mapID"] = 38,
			["posY"] = 0.4090485565054252,
			["posX"] = -0.1492238085260644,
			["text"] = "Shady Dealer",
			["icon"] = "Interface\\Icons\\INV_Misc_Coin_01",
		},
		["810723266"] = {
			["mapID"] = 468,
			["posY"] = 0.1522288901518077,
			["posX"] = 0.3065756789657359,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810520879"] = {
			["mapID"] = 474,
			["posY"] = 0.06067874463817832,
			["posX"] = 0.2249612012590599,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810816755"] = {
			["mapID"] = 480,
			["posY"] = -0.02022596319764755,
			["posX"] = -0.04472174282420738,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810890770"] = {
			["mapID"] = 466,
			["posY"] = -0.01277442414767265,
			["posX"] = 0.2533488942970358,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810829180"] = {
			["mapID"] = 480,
			["posY"] = -0.2735862582148553,
			["posX"] = -0.191627795707349,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810812034"] = {
			["mapID"] = 480,
			["posY"] = 0.1341317561743307,
			["posX"] = 0.2327678448000042,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["810853220"] = {
			["mapID"] = 466,
			["posY"] = 0.1799069337642778,
			["posX"] = 0.1497338566416748,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
		["813895760"] = {
			["mapID"] = 478,
			["posY"] = -0.06706614057950089,
			["posX"] = -1.1112311644616e-005,
			["text"] = "",
			["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		},
	},
}


local iconPaths = {
    Bag = ICON_BAG,
    Star = ICON_STAR,
    Skull = ICON_SKULL,
    Cross = ICON_CROSS,
    Square = ICON_SQUARE,
    Moon = ICON_MOON,
    Triangle = ICON_TRIANGLE,
    Diamond = ICON_DIAMOND,
    Circle = ICON_CIRCLE,
    Vendor = ICON_VENDOR,
    Rare = ICON_RARE,
    Chest = ICON_CHEST,
    Quest = ICON_QUEST,
    Cave = ICON_CAVE
}

local currentMarkerFrames = {}

local function CreateMarkerFrame(markerId, data, parentFrame)
    if _G["AAC_MapMarker"..markerId] then
        return _G["AAC_MapMarker"..markerId]
    end

    local marker = CreateFrame("Button", "AAC_MapMarker"..markerId, parentFrame, "BackdropTemplate")
    marker.markerId = markerId
    marker.iconPath = data.icon

    marker:SetWidth(MARKER_SIZE)
    marker:SetHeight(MARKER_SIZE)
    marker:SetFrameStrata("MEDIUM")
    marker:SetFrameLevel(parentFrame:GetFrameLevel() + 5)
    marker:EnableMouse(true)
    marker:RegisterForDrag("LeftButton")
    marker:SetMovable(true)

    marker:SetNormalTexture(data.icon)
    marker:GetNormalTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92)
    marker:SetPushedTexture(data.icon)
    marker:GetPushedTexture():SetAlpha(0.7)
    marker:GetPushedTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92)
    marker:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    marker:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    currentMarkerFrames[markerId] = marker

    marker:SetScript("OnDragStart", function(self)
        if IsMouseButtonDown("LeftButton") then
            self:StartMoving()
            self:SetAlpha(0.7)
        end
    end)

    marker:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self:SetAlpha(1.0)

        local parent = self:GetParent()
        local pWidth = parent:GetWidth()
        local pHeight = parent:GetHeight()

        -- Mittelpunkt des Markers relativ zur oberen linken Ecke des Parents berechnen
        local markerCenterX = self:GetLeft() + (self:GetWidth() / 2)
        local markerCenterY = self:GetTop() - (self:GetHeight() / 2) -- Y-Koordinate nimmt nach unten zu

        -- Mittelpunkt des Parents berechnen (relativ zu sich selbst ist der Ursprung 0,0, aber explizit ist klarer)
        local parentCenterX = parent:GetLeft() + (pWidth / 2)
        local parentCenterY = parent:GetTop() - (pHeight / 2)

        -- Offset des Marker-Mittelpunkts vom Parent-Mittelpunkt berechnen
        local offsetX = markerCenterX - parentCenterX
        local offsetY = markerCenterY - parentCenterY

        -- Relative Position berechnen (normalisiert durch Parent-Dimensionen)
        local relX = offsetX / pWidth
        local relY = offsetY / pHeight

        local currentMapID = GetCurrentMapAreaID()

        if MapMarkerDB and MapMarkerDB.markers and MapMarkerDB.markers[self.markerId] then
            MapMarkerDB.markers[self.markerId].posX = relX
            MapMarkerDB.markers[self.markerId].posY = relY
            MapMarkerDB.markers[self.markerId].mapID = currentMapID
        end
    end)

    local label = marker:CreateFontString("AAC_MapMarkerLabelText"..markerId, "OVERLAY")
    label:SetFont(FONT_PATH, FONT_SIZE, "OUTLINE")
    label:SetPoint("TOP", marker, "BOTTOM", 0, -2)
    label:SetText(data.text or "Optional Label")

    local labelFrame = CreateFrame("Button", "AAC_MapMarkerLabelFrame"..markerId, marker)
    labelFrame:SetFrameLevel(marker:GetFrameLevel() + 1)
    labelFrame:EnableMouse(true)
    labelFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    labelFrame:SetPoint("CENTER", label, "CENTER", 0, 0)

    local function UpdateLabelFrameSize()
        local width = label:GetStringWidth() + 10
        local height = label:GetStringHeight() + 6
        labelFrame:SetSize(math.max(40, width), math.max(15, height))
    end

    local function CreateEditBox(parent, currentText, markerIdToEdit)
        local editBox = CreateFrame("EditBox", "AAC_MapMarkerEditBox"..markerIdToEdit, parent)
        editBox:SetPoint("CENTER", label, "CENTER", 0, 0)
        editBox:SetFrameStrata("TOOLTIP")
        editBox:SetFrameLevel(labelFrame:GetFrameLevel() + 10)
        editBox:SetSize(100, 30)
        editBox:SetFontObject(GameFontNormal)
        editBox:SetAutoFocus(true)
        editBox:EnableKeyboard(true)
        editBox:SetMultiLine(false)
        editBox:SetMaxLetters(100)
        editBox:SetText(currentText)
        editBox:HighlightText()

        local bg = CreateFrame("Frame", nil, editBox)
        bg:SetFrameLevel(editBox:GetFrameLevel() - 1)
        bg:SetAllPoints(editBox)
        bg:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        bg:SetBackdropColor(0, 0, 0, 0.8)
        bg:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)

        local function SaveLabel()
            local text = editBox:GetText()
            if MapMarkerDB and MapMarkerDB.markers and MapMarkerDB.markers[markerIdToEdit] then
                MapMarkerDB.markers[markerIdToEdit].text = text
            else
            end
            label:SetText(text)
            UpdateLabelFrameSize()
            editBox:Hide()
            editBox:ClearFocus()
        end

        editBox:SetScript("OnEnterPressed", SaveLabel)
        editBox:SetScript("OnEscapePressed", function(self)
            self:Hide()
            self:ClearFocus()
        end)
        editBox:SetScript("OnEditFocusLost", function(self)
            self:Hide()
        end)

        editBox:SetScript("OnHide", function(self)
            _G[self:GetName()] = nil
        end)

        editBox:Show()
        return editBox
    end

    labelFrame:SetScript("OnMouseDown", function(self, button)
    end)

    labelFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            local currentText = label:GetText() or ""
            CreateEditBox(self, currentText, marker.markerId)
        end
    end)

    marker:SetScript("OnMouseDown", function(self, button)
    end)

    marker:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            local idToDelete = self.markerId
            if MapMarkerDB and MapMarkerDB.markers then
                MapMarkerDB.markers[idToDelete] = nil
            end
            local labelFrameToDelete = _G["AAC_MapMarkerLabelFrame"..idToDelete]
            if labelFrameToDelete then labelFrameToDelete:Hide(); _G["AAC_MapMarkerLabelFrame"..idToDelete] = nil end
            local labelTextToDelete = _G["AAC_MapMarkerLabelText"..idToDelete]
            if labelTextToDelete then _G["AAC_MapMarkerLabelText"..idToDelete] = nil end

            self:Hide()
            _G[self:GetName()] = nil
            currentMarkerFrames[idToDelete] = nil
        end
    end)

    UpdateLabelFrameSize()

    marker:ClearAllPoints()
    local pWidth = parentFrame:GetWidth()
    local pHeight = parentFrame:GetHeight()
    local absX = (data.posX or 0) * pWidth
    local absY = (data.posY or 0) * pHeight
    marker:SetPoint("CENTER", parentFrame, "CENTER", absX, absY)

    marker:Show()
    return marker
end

local function AddNewMarker(iconPath, parentFrame)
    if not parentFrame or not parentFrame:IsShown() then return end

    local markerId = tostring(math.floor(GetTime() * 1000))
    local currentMapID = GetCurrentMapAreaID()

    local newData = {
        icon = iconPath,
        text = "Optional ",
        posX = 0.55,
        posY = 0,
        mapID = currentMapID
    }

    MapMarkerDB = MapMarkerDB or {}
    MapMarkerDB.markers = MapMarkerDB.markers or {}

    MapMarkerDB.markers[markerId] = newData

    CreateMarkerFrame(markerId, newData, parentFrame)
end

AAC_MapMarker:RegisterEvent("ADDON_LOADED")
AAC_MapMarker:RegisterEvent("WORLD_MAP_UPDATE")
AAC_MapMarker:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        -- Initialize database with default values if it doesn't exist
        if not MapMarkerDB then
            MapMarkerDB = CopyTable(DefaultMapMarkerDB)
            print("|cFF00FF00AAC MapMarker:|r Initial database loaded with pre-defined markers.")
        end
        
        MapMarkerDB = MapMarkerDB or {}
        MapMarkerDB.markers = MapMarkerDB.markers or {}

        local mapFrame = WorldMapButton

        local controlPanel = CreateFrame("Frame", "AAC_MapMarkerControlPanel", mapFrame)
        controlPanel:SetWidth(CONTROL_BUTTON_SIZE + 10)
        local buttonTypes = {
            "Bag", "Star", "Skull", "Cross", "Square", "Moon",
            "Triangle", "Diamond", "Circle", "Vendor", "Rare", "Chest", "Quest", "Cave"
        }
        -- Adjusted height calculation for the new button
        controlPanel:SetHeight((CONTROL_BUTTON_SIZE + 5) * #buttonTypes + 10 + (CONTROL_BUTTON_SIZE * 1.5 + 5)) -- Added space for the remove button
        controlPanel:SetPoint("RIGHT", mapFrame, "RIGHT", -10, 0)

        local prevButton = nil

        for i, buttonType in ipairs(buttonTypes) do
            local controlButton = CreateFrame("Button", "AAC_MapMarkerControl"..buttonType, controlPanel)
            controlButton:SetWidth(CONTROL_BUTTON_SIZE)
            controlButton:SetHeight(CONTROL_BUTTON_SIZE)

            if i == 1 then
                controlButton:SetPoint("TOP", controlPanel, "TOP", 0, -5)
            else
                controlButton:SetPoint("TOP", prevButton, "BOTTOM", 0, -5)
            end

            local iconPath = iconPaths[buttonType]
            controlButton:SetNormalTexture(iconPath)

            if buttonType == "Skull" or buttonType == "Cross" or buttonType == "Square" or
               buttonType == "Moon" or buttonType == "Triangle" or buttonType == "Diamond" or buttonType == "Circle" then
            else
                controlButton:GetNormalTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end

            controlButton:SetPushedTexture(iconPath)
            controlButton:GetPushedTexture():SetAlpha(0.7)
            if buttonType ~= "Skull" and buttonType ~= "Cross" and buttonType ~= "Square" and
               buttonType ~= "Moon" and buttonType ~= "Triangle" and buttonType ~= "Diamond" and buttonType ~= "Circle" then
                controlButton:GetPushedTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end

            controlButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

            controlButton:SetScript("OnClick", function()
                local detailFrame = WorldMapDetailFrame
                if detailFrame and detailFrame:IsShown() then
                    AddNewMarker(iconPath, detailFrame)
                end
            end)

            prevButton = controlButton
        end

        -- Create the "Remove Markers" button
        local removeButton = CreateFrame("Button", "AAC_MapMarkerRemoveAllButton", controlPanel)
        removeButton:SetWidth(CONTROL_BUTTON_SIZE + 10) -- Keep width
        removeButton:SetHeight(CONTROL_BUTTON_SIZE) -- Adjust height to match other buttons
        removeButton:SetPoint("TOP", prevButton, "BOTTOM", 0, -5) -- Adjust spacing to match other buttons

        -- Set background texture
        removeButton:SetBackdrop({
            bgFile = "Interface\\Buttons\\UI-Button-Background",
            edgeFile = "Interface\\Buttons\\UI-Button-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        removeButton:SetBackdropColor(0.4, 0.4, 0.4, 1) -- Grey background
        removeButton:SetBackdropBorderColor(0.8, 0.8, 0.8, 1) -- Lighter grey border

        -- Add text
        local removeText = removeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        removeText:SetPoint("CENTER")
        removeText:SetText("Clear Map") -- Shorter text
        removeText:SetTextColor(1, 1, 1, 1) -- White text

        -- Add highlight texture
        local highlightTexture = removeButton:CreateTexture(nil, "HIGHLIGHT")
        highlightTexture:SetTexture("Interface\\Buttons\\UI-Button-Highlight")
        highlightTexture:SetAllPoints(removeButton)
        highlightTexture:SetBlendMode("ADD")

        -- Add pushed texture
        local pushedTexture = removeButton:CreateTexture(nil, "PUSHED")
        pushedTexture:SetTexture("Interface\\Buttons\\UI-Button-Background")
        pushedTexture:SetAllPoints(removeButton)
        pushedTexture:SetVertexColor(0.3, 0.3, 0.3, 1) -- Darker grey when pushed


        removeButton:SetScript("OnClick", function()
            local currentMapID = GetCurrentMapAreaID()
            local detailFrame = WorldMapDetailFrame
            if not detailFrame or not detailFrame:IsShown() then return end

            local markersToRemove = {}
            -- Find markers for the current map
            if MapMarkerDB and MapMarkerDB.markers then
                for markerId, data in pairs(MapMarkerDB.markers) do
                    if data.mapID == currentMapID then
                        table.insert(markersToRemove, markerId)
                    end
                end
            end

            -- Remove the found markers
            for _, markerId in ipairs(markersToRemove) do
                -- Remove from database
                if MapMarkerDB and MapMarkerDB.markers then
                    MapMarkerDB.markers[markerId] = nil
                end

                -- Hide and remove frame if it exists
                local frame = currentMarkerFrames[markerId]
                if frame then
                    frame:Hide()
                    currentMarkerFrames[markerId] = nil
                end

                -- Clean up global references for the marker and its label components
                local markerFrameName = "AAC_MapMarker"..markerId
                local labelFrameName = "AAC_MapMarkerLabelFrame"..markerId
                local labelTextName = "AAC_MapMarkerLabelText"..markerId
                if _G[markerFrameName] then _G[markerFrameName] = nil end
                if _G[labelFrameName] then _G[labelFrameName]:Hide(); _G[labelFrameName] = nil end
                if _G[labelTextName] then _G[labelTextName] = nil end

                -- Also attempt cleanup for edit box if it happens to be open
                local editBoxName = "AAC_MapMarkerEditBox"..markerId
                if _G[editBoxName] then _G[editBoxName]:Hide(); _G[editBoxName] = nil end
            end
        end)

        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "WORLD_MAP_UPDATE" then
        local detailFrame = WorldMapDetailFrame
        if detailFrame and detailFrame:IsShown() then
            for id, frame in pairs(currentMarkerFrames) do
                if frame and frame.Hide then
                    frame:Hide()
                    if _G["AAC_MapMarker"..id] then _G["AAC_MapMarker"..id] = nil end
                    if _G["AAC_MapMarkerLabelFrame"..id] then _G["AAC_MapMarkerLabelFrame"..id] = nil end
                    if _G["AAC_MapMarkerLabelText"..id] then _G["AAC_MapMarkerLabelText"..id] = nil end
                end
            end
            currentMarkerFrames = {}

            local currentMapID = GetCurrentMapAreaID()
            if MapMarkerDB and MapMarkerDB.markers then
                for markerId, data in pairs(MapMarkerDB.markers) do
                    if data.mapID == currentMapID then
                        CreateMarkerFrame(markerId, data, detailFrame)
                    end
                end
            end

            if _G["AAC_MapMarkerControlPanel"] then
                _G["AAC_MapMarkerControlPanel"]:Show()
            end
        else
            if _G["AAC_MapMarkerControlPanel"] then
                _G["AAC_MapMarkerControlPanel"]:Hide()
            end
            for id, frame in pairs(currentMarkerFrames) do
                if frame and frame.Hide then frame:Hide() end
                if _G["AAC_MapMarker"..id] then _G["AAC_MapMarker"..id] = nil end
                if _G["AAC_MapMarkerLabelFrame"..id] then _G["AAC_MapMarkerLabelFrame"..id] = nil end
                if _G["AAC_MapMarkerLabelText"..id] then _G["AAC_MapMarkerLabelText"..id] = nil end
            end
            currentMarkerFrames = {}
        end
    end
end)

