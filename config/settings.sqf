call compileFinal preprocessFileLineNumbers "config\defined_sectors.sqf";

missionNamespace setVariable ['DO_RESTART', false];
missionNamespace setVariable ["ADMINS", [
	"76561199191114264", // Grom
	"76561198118636599", // Toph
	"76561199182684233", // Nar
	"76561199126160178", // Tilly
	"76561199154831308", // Gallo
    "76561198047333011", // Tetlys
	"76561198002572104", // Patches
	"76561199215271181", // Johnnyt
    "76561198069002476", // Irish
    "76561199151440104", // Dropbear
    "76561198890328821", // jimbob
    "76561198178112458", // Leo B.
    "76561198414366102", // Doc
    "76561198009964108", // angry
    "76561199041918350", // T_urb
    "76561198011818172", // crashton
    "76561198174392371", // Salami
    "76561198369871957", // Unfortunate Son 
    "76561198038169434", // LazyTitan
    "76561198044173784"  // Thunder
]];
missionNamespace setVariable ['TIME_MULTIPLIER',   8];
missionNamespace setVariable ['RESTART_INTERVAL_SECONDS',   18000, true];
missionNamespace setVariable ['MAX_ACTIVE_SECTORS',     	2];
missionNamespace setVariable ['ISRC_CAPTURING_ACCOUNTING_DELAY', 50]; // seconds in delay from spawn to monitoring current spawned units, enabling capture.
missionNamespace setVariable ['SECTOR_CAPTURE_COEFFICIENT', 0.06]; // < 6% of the total enemy population is a CAPTURE
missionNamespace setVariable ['RESPAWN_LOCATION',       	[2376.08,5035.81,0], true];
missionNamespace setVariable ['FOB_BRAVO_LOCATION',       	[0,0,0], true]; // [0, 0, 0] for none
missionNamespace setVariable ['FOB_CHARLIE_LOCATION',       [0,0,0], true]; // [0, 0, 0] for none
missionNamespace setVariable ['CLEANUP_INTERVAL',       	500]; //  Interval in seconds to run cleanup
missionNamespace setVariable ['MAX_CIV_POP_PEDS',       	3, true]; //  Max number of pedestrians that can be spawned in a sector
missionNamespace setVariable ['MAX_CIV_POP_TRAFFIC',    	3, true]; //  Max number of motorists that can be spawned in a sector
missionNamespace setVariable ['BLUFOR_ACTIVATION_COUNT',    4]; // Number of Blufor players units needed in any sector to activate it, also min players online to activate BG's.
missionNamespace setVariable ['ISRC_MARKER_UPDATE_INTERVAL',30];  // Interval in seconds to update the asset markers and server FPS counter 
missionNamespace setVariable ["LOCATION_TYPES", 			["NameLocal", "NameVillage", "NameCity", "NameCityCapital", "Strategic", "NameMarine"], true];
missionNamespace setVariable ["DEBUG", 						false]; // kind've deprecated: systemChat can be used for debugging, DS will just ignore it as server.
missionNamespace setVariable ["SECTOR_RECAP_RANGE", 		100]; // Meters from the center of the sector for a BG to begin recapturing the point.
missionNamespace setVariable ["SECTOR_RECAP_TIME", 			900]; // 15 min: Time in seconds for a battlegroup to recapture a point once they have reached the location
missionNamespace setVariable ["SECTOR_STRAGGLER_CUTOFF",    120]; // Per the first unit showing up at the sector, Time in seconds stragglers have to show up inside the sector's recap range before being deleted.
missionNamespace setVariable ["SECTOR_RECAP_SIZE",          300]; // Area of inclusivity in regards to recapturing a sector.
missionNamespace setVariable ["LOGI_POINT_CLASSNAME",       "USMC_WarfareBVehicleServicePoint", true]; // className for our logi point
missionNamespace setVariable ["STARTING_CIV_REP", 100]; // Starting civ rep | 0-100
missionNamespace setVariable ["STARTING_FUNDING", 100000000]; // Starting funding: 100mil
missionNamespace setVariable ["RESUPPLY_INTERVAL_SECONDS", 1600, true]; // Interval until any role leader can grab a new crate.
missionNamespace setVariable ["VEHICLE_YARD_CENTER", [2344.19,4774.02,0], true]; // CENTER OF THE RESPAWN YARD
missionNamespace setVariable ["VEHICLE_YARD_RADIUS", 80, true]; // RADIUS OF THE RESPAWN YARD
missionNamespace setVariable ["ENEMY_SIDE", east, true]; // Side Of General Enemy
missionNamespace setVariable ["FRIENDLY_SIDE", west, true]; // Side Of friendlies
missionNamespace setVariable ["RESISTANCE_IS_FRIENDLY", false, true]; // Restance is friendly
missionNamespace setVariable ["ZEUS_LOGISTICS_SUPPLIES_CLASSES", [
    "CargoNet_01_box_F",
    "CargoNet_01_barrels_F"
], true];
missionNamespace setVariable ["SAM_COUNT", 0]

/////// SPAWNS ///////////////////////////////////

missionNamespace setVariable ["ISRC_ENEMY_BATTLEGROUP", createHashMapFromArray [
	[
		"infantry",
		[
			"rhs_vdv_flora_efreitor", 
			"rhs_vdv_flora_sergeant", 
			"rhs_vdv_flora_grenadier_rpg", 
			"rhs_vdv_flora_rifleman", 
			"rhs_vdv_flora_rifleman", 
			"rhs_vdv_flora_rifleman", 
			"rhs_vdv_flora_rifleman",         
			"rhs_vdv_flora_medic", 
			"rhs_vdv_flora_machinegunner", 
			"rhs_vdv_flora_machinegunner", 
			"rhs_vdv_flora_at", 
			"rhs_vdv_flora_at", 
			"rhs_vdv_flora_aa"
		]
	],
	[
		"vehicle",
		[
			"min_rf_gaz_2330_HMG", 
			"rhs_tigr_sts_msv"
		]
	],
	[
		"armor",
		[
			"rhs_btr80a_msv", 
			"rhs_btr80_vdv", 
			"rhs_bmp3mera_msv", 
			"rhs_bmp2k_msv", 
			"rhs_bmp1p_vv", 
			"rhs_t72be_tv", 
			"rhs_t90sm_tv", 
			"rhs_t80uk",
			"RHS_Ural_Zu23_MSV_01", 
			"rhs_zsu234_aa"
		]
	]
], true];

missionNamespace setVariable ["ISRC_ENEMY_BATTLEGROUP_WEIGHTS",
	createHashMapFromArray [
		["infantry", [20, 35, 50]], // min, mid, max
		["vehicle",     [3, 6, 8]],    // min, mid, max
		["armor",    [2, 3, 4]]     // min, mid, max
	]
, true];

missionNamespace setVariable ["ISRC_ENEMY_AIR", [
    "min_rf_ka_52", 
    "min_rf_heli_light_black", 
    "RHS_Mi24P_vdv", 
    "RHS_Mi24V_vdv", 
    "rhs_mig29sm_vvsc", 
    "RHS_Su25SM_vvsc",
    "O_Taliban_MD_500_01",
    "O_Taliban_UH_1H_Armed_01",
    "O_Taliban_UH_60M_Armed_01",
    "RHS_Mi8AMT_vdv"
], true];

missionNamespace setVariable ["ISRC_ENEMY_CAR", [
    "O_Taliban_M113_M240_01",
    "O_Taliban_DShKM_Minitripod_01",
    "O_Taliban_M240_Low_01",
    "O_Taliban_Offroad_M2_01",
    "O_Taliban_PickUp_DShKM_01",
    "O_OTaliban_Navistar_MaxxPro_M2_01",
    "O_Taliban_ABP_M1151_GPK_M2_01",
    "O_Taliban_Hilux_DShKM_01",
    "O_Taliban_SPG_9_01",
	"min_rf_gaz_2330_HMG", 
    "rhs_tigr_sts_msv",
	"rhs_tigr_sts_msv",  
	"RHS_ZU23_VDV", 
	"rhs_KORD_high_VDV", 
	"RHS_AGS30_TriPod_VDV", 
	"rhs_Kornet_9M133_2_vdv",
	"min_rf_Mortar"
], true];

missionNamespace setVariable ["ISRC_ENEMY_ARMOR", [
    "rhs_btr80a_msv", 
    "rhs_btr80a_msv", 
    "rhs_btr80a_msv", 
    "rhs_btr80_vdv", 
    "rhs_bmp3mera_msv", 
	"rhs_bmp2k_vdv",
    "rhs_bmp2k_vdv",
    "rhs_bmp2k_vdv",
    "rhs_t72be_tv", 
    "rhs_t90sm_tv", 
    "rhs_t80uk",
    "rhs_t80uk",
    "RHS_Ural_Zu23_MSV_01", 
    "rhs_zsu234_aa",
    "rhs_zsu234_aa",
    "O_Taliban_URAL_4320_ZU23_01",
    "O_Taliban_URAL_4320_ZU23_01",
    "O_Taliban_BMP_1_01",
    "O_OTaliban_M1117_Guardian_01",
    "O_Taliban_T55A_01",
    "O_Taliban_M1A1_01",
    "UK3CB_O_2S6M_Tunguska_VPV"
], true];

missionNamespace setVariable ["ISRC_ENEMY_INFANTRY", [
	["fire_team", [
        "rhs_vdv_flora_efreitor", 
        "rhs_vdv_flora_sergeant", 
        "rhs_vdv_flora_grenadier_rpg", 
        "rhs_vdv_flora_rifleman", 
        "rhs_vdv_flora_rifleman", 
        "rhs_vdv_flora_rifleman", 
        "rhs_vdv_flora_rifleman",         
        "rhs_vdv_flora_medic", 
        "rhs_vdv_flora_machinegunner", 
        "rhs_vdv_flora_machinegunner", 
        "rhs_vdv_flora_at", 
        "rhs_vdv_flora_at", 
        "rhs_vdv_flora_aa"
	]],
	["weapons_team", [
        "rhs_vdv_flora_sergeant",
        "rhs_vdv_flora_at", 
        "rhs_vdv_flora_aa", 
        "rhs_vdv_flora_arifleman_rpk", 
        "rhs_vdv_flora_RShG2", 
        "rhs_vdv_flora_LAT",
        "rhs_vdv_flora_medic"
	]],
	["recon_team", [
        "rhs_vdv_recon_efreitor", 
        "rhs_vdv_recon_arifleman", 
        "rhs_vdv_recon_marksman_asval", 
        "rhs_vdv_recon_medic", 
        "rhs_vdv_recon_rifleman_ak103", 
        "rhs_vdv_recon_rifleman_l", 
        "rhs_vdv_recon_arifleman_rpk_scout"
	]],
    ["taliban_fire_team", [
        "O_Taliban_Team_Leader_01",
        "O_Taliban_Automatic_Rifleman_01", 
        "O_Taliban_IED_Maker_01", 
        "O_Taliban_Machine_Gunner_M240_01", 
        "O_Taliban_Machine_Gunner_PKM_01", 
        "O_Taliban_Marksman_01", 
        "O_Taliban_Medic_01", 
        "O_Taliban_Rifleman_AKM_01", 
        "O_Taliban_Rifleman_AKMS_01", 
        "O_Taliban_Rifleman_LAT_01", 
        "O_Taliban_Section_Leader_01"
    ]],
    ["taliban_weapons_team", [
        "O_Taliban_Team_Leader_01",
        "O_Taliban_AA_Specialist_01", 
        "O_Taliban_AT_Specialist_01",        
        "O_Taliban_Automatic_Rifleman_01", 
        "O_Taliban_Automatic_Rifleman_01", 
        "O_Taliban_Machine_Gunner_M240_01", 
        "O_Taliban_Machine_Gunner_PKM_01", 
        "O_Taliban_Rifleman_M16_01", 
        "O_Taliban_Rifleman_M4_01"
    ]],
    ["taliban_sf_team", [
        "O_Taliban_SF_Team_Leader_01", 
        "O_Taliban_SF_Automatic_Rifleman_01", 
        "O_Taliban_SF_Marksman_01", 
        "O_Taliban_SF_Paramedic_01", 
        "O_Taliban_SF_Rifleman_01", 
        "O_Taliban_SF_Rifleman_LAT_01", 
        "O_Taliban_SF_Section_Leader_01", 
        "O_Taliban_Sniper_01"        
    ]]
], true];

missionNamespace setVariable ["ISRC_ENEMY_MARINE", [
    //"rhs_bmk_t",
    "UK3CB_AAF_O_RHIB_Gunboat",
    "UK3CB_AAF_O_RHIB_Gunboat",
    "UK3CB_AAF_O_RHIB_Gunboat",
    "UK3CB_AAF_O_RHIB_Gunboat",
    "UK3CB_CHD_W_O_Fishing_Boat_Zu23_front",
    "UK3CB_CHD_W_O_Fishing_Boat_Zu23_front",
    "UK3CB_CHD_W_O_Fishing_Boat_SPG9",
    "UK3CB_CHD_W_O_Fishing_Boat_SPG9"
]];

missionNamespace setVariable ["ISRC_civilians", [
	"ZEPHIK_Female_Civ_15",
	"ZEPHIK_Female_Civ_14", 
    "ZEPHIK_Female_Civ_12",
    "ZEPHIK_Female_Civ_12",
	"ZEPHIK_Female_Civ_2", 
	"ZEPHIK_Female_Civ_3", 
	"ZEPHIK_Female_Civ_1", 
    "UK3CB_ADC_C_CIV_ISL",
    "UK3CB_ADC_C_WORKER",
    "UK3CB_ADC_C_SPOT_ISL",
    "UK3CB_ADC_C_LABOURER_ISL",
    "UK3CB_ADC_C_FUNC",
    "UK3CB_TKC_C_CIV",
    "UK3CB_TKC_C_DOC",
    "UK3CB_TKC_C_SPOT",
    "UK3CB_TKC_C_WORKER",
    "RDS_Citizen_Random",
    "RDS_Citizen2",
    "RDS_Citizen3"
], true];

missionNamespace setVariable ["ISRC_civilian_vehicles", [
	"RDS_PL_Van_01_box_f", //     Box Van
	"RDS_PL_Golf4_Civ_01", //     Golf
	"RDS_PL_Hatchback_01_F", //   Hatchback
	"RDS_PL_JAWA353_Civ_01", //   Motorbike
	"RDS_PL_TT650_Civ_01", //     Dirtbike
	"RDS_PL_Zetor6945_BaPL_se",// Tractor
	"RDS_PL_Octavia_Civ_01", //   Volvo
	"RDS_PL_Gaz24_Civ_03",   //   Old
	"RDS_PL_Lada_Civ_01",   //    Old
	"RDS_PL_Lada_Civ_05",   //    Police Car
	"RDS_PL_MMT_Civ_01",     //    Mountain Bike
    "UK3CB_TKC_C_Golf", // 3CB - start
    "UK3CB_TKC_C_Ural_Empty",
    "UK3CB_TKC_C_SUV",
    "UK3CB_TKC_C_S1203_Amb",
    "UK3CB_TKC_C_Hilux_Civ_Open",
    "UK3CB_TKC_C_Datsun_Civ_Closed",
    "UK3CB_TKC_C_Ikarus" // 3CB - end
], true];

/////// END SPAWNS ///////////////////////////////

// For BG's, technically deprecated.
missionNamespace setVariable ["ISRC_transport_truck", "min_rf_truck_covered", true];

// For paradrops
missionNamespace setVariable ["ISRC_transport_rotary", "RHS_Mi8AMT_vdv", true]; 
missionNamespace setVariable ["ISRC_paras", [
    "rhssaf_army_o_m10_para_sq_lead",
    "rhssaf_army_o_m10_para_ft_lead",
    "rhssaf_army_o_m10_para_rifleman_m21",
    "rhssaf_army_o_m10_para_mgun_m84",
    "rhssaf_army_o_m10_para_gl_ag36",
    "rhssaf_army_o_m10_para_ft_lead",
    "rhssaf_army_o_m10_para_mgun_minimi",
    "rhssaf_army_o_m10_para_gl_ag36",
    "rhssaf_army_o_m10_para_rifleman_at"
], true];

// For BG's, technically deprecated.
missionNamespace setVariable ["ISRC_transport_troops", [
    "rhs_vdv_flora_efreitor", 
    "rhs_vdv_flora_sergeant", 
    "rhs_vdv_flora_grenadier_rpg", 
    "rhs_vdv_flora_rifleman", 
    "rhs_vdv_flora_rifleman", 
    "rhs_vdv_flora_rifleman", 
    "rhs_vdv_flora_rifleman",         
    "rhs_vdv_flora_medic", 
    "rhs_vdv_flora_machinegunner", 
    "rhs_vdv_flora_machinegunner", 
    "rhs_vdv_flora_at", 
    "rhs_vdv_flora_at", 
    "rhs_vdv_flora_aa"
], true];

// currency symbol to use for funding
missionNamespace setVariable ["CURRENCY_SYMBOL", "$", true];

/// FLP - Beginning of campaign
missionNamespace setVariable ["STARTING_COP_LOCATION", [0,0,0], true]; // set to false for none, players will then have to purchase the initial FLP
missionNamespace setVariable ["COP_DEPLOY_MOVE_PRICE", 100000, true];

// Deprecated!
missionNamespace setVariable ["SIDE_OP_HUMANITARIAN_ELAPSED_TIME", 1800, true];

// classNames of IEDs
missionNamespace setVariable ["IED_TYPES", ["IEDLandBig_F","IEDLandSmall_F","IEDUrbanBig_F","IEDUrbanSmall_F"], true];

// Classnames of our "sam sites" - it's also battery/arty-capable. See "// Create SAM sites" for more info.
missionNamespace setVariable ["ISRC_SAM_SITE", ["min_rf_sa_22", "sam_site"], true];

// Areas in which to remove all terrain object (Deprecated).
missionNamespace setVariable ["ISRC_TERRAIN_REMOVAL_POINTS", []];

// Patrols (Actually attack groups lol)
missionNamespace setVariable ["ISRC_ENEMY_PATROLS", [
    [ // choice
        [ // team
            "O_Taliban_ANP_Offroad_M2_01", 
            [] 
        ],
        [
            "min_rf_truck_covered",
            [
                "rhs_vdv_flora_efreitor", 
                "rhs_vdv_flora_sergeant", 
                "rhs_vdv_flora_grenadier_rpg", 
                "rhs_vdv_flora_rifleman", 
                "rhs_vdv_flora_rifleman", 
                "rhs_vdv_flora_rifleman", 
                "rhs_vdv_flora_rifleman",         
                "rhs_vdv_flora_medic", 
                "rhs_vdv_flora_machinegunner", 
                "rhs_vdv_flora_machinegunner", 
                "rhs_vdv_flora_at", 
                "rhs_vdv_flora_at"
            ]
        ]
    ],
    [ // choice
        [ // team
            "O_Taliban_ANP_Offroad_M2_01",
            [] 
        ],
        [
            "O_Taliban_ANP_Offroad_M2_01",
            []
        ]
    ]
], true];

/// Max-distance from $RESPAWN_LOCATION friendlies can be at which scripted arty will ignore them (QOL feature). 
missionNamespace setVariable ["ARTY_CONTROLLER_FOB_BLACKLIST_RANGE", 800, true];

/// Blacklists a rectangular area from being affected by the cleanup script.
missionNamespace setVariable ["CLEANUP_WHITELIST_AREAS", [
    //[RESPAWN_LOCATION, 500, 500, 0, false]
]];

/// Names of locations that should become pre-captured sectors
missionNamespace setVariable ["ALREADY_CAPTURED", [
    "Coastal Zone - Alpha",
    "Coastal Zone - Bravo",
    "Coastal Zone - Charlie",
    "Coastal Zone - Delta",
    "Radio Tower 031197",
    "Radio Tower 047194",
    "Chabahar Estuary",
    "POI 013177",
    "Mantiq",
    "Chabahar River Mouth",
    "Imam Ali Int. Port",
    "Chaman",
    "Qorghan",
    "POI 058187",
    "POI 070186",
    "Raqol",
    "Kushkak",
    "POI 089186",
    "Tarchi",
    "Jamak",
    "Radio Tower 015163",
    "Radio Tower 008159",
    "Radio Tower 012155",
    "Radio Tower 009145",
    "Sya Dara Iron Mine",   
    "Radio Tower 024172",
    "Radio Tower 036171",
    "Sarqul",
    "Al Hamza Air Base",
    "Rasman",
    "The Villa",
    "POI 103181",
    "Aynak Copper Mine",
    "Chahe Shrin",
    "Zari",
    "Lalezar",
    "POI 018109",
    "Bastam",
    "Radio Tower 010102",
    "Radio Tower 013088",     
    "Radio Tower 036088",
    "Imarat",
    "Garmarund",     
    "Radio Tower 044115",
    "Hajigak Iron Mine"
], true];

/// Names of locations that should never become sectors
LOCATIONS_BLACKLIST = [];

/*
Notice: moved `LOGISTICS_SUPPLIES_CLASSES` to "initPlayerLocal.sqf"!
Notice: removed `LOGISTICS_SUPPLIES_CLASSES` and all related features for now (ie: logistics)
*/

call compileFinal preprocessFileLineNumbers "config\spawnopts.sqf";
