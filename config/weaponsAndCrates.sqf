missionNamespace setVariable ["ISRC_supply_crates", [
	[
		"general_resupply",
		"Box_NATO_Equip_F",
		[],
		[
            ["rhs_mag_30Rnd_556x45_M855A1_PMAG_Tracer_Red", 25],
            ["rhs_mag_30Rnd_556x45_Mk262_PMAG_Tan", 25],
            ["rhs_mag_20Rnd_SCAR_762x51_m61_ap", 5],
            ["rhs_mag_20Rnd_SCAR_762x51_m62_tracer", 10],
            ["ACE_40mm_Flare_white", 10],
            ["ACE_HuntIR_M203", 2],
            ["rhs_mag_M397_HET", 10],
            ["rhs_mag_M433_HEDP", 10],
            ["rhs_mag_M441_HE", 10],
            ["1Rnd_SmokeGreen_Grenade_shell", 5]      
		],
		[
			// Crate Items
            ["ACE_elasticBandage", 25],
            ["ACE_packingBandage", 25],
            ["ACE_fieldDressing", 25],
            ["ACE_bloodIV", 5],
            ["ACE_EntrenchingTool", 2],
            ["ACE_epinephrine", 5],
            ["ACE_morphine", 5],
            ["rhs_mag_an_m8hc", 5]                 
		]
	],
	[
		"empty_resupply",
		"Box_NATO_Equip_F",
		[],
		[],
		[]
	],
	[
		"medical_resupply",
		"ACE_medicalSupplyCrate_advanced",
		[],
		[],
		[
            ["kat_IO_FAST", 5],
            ["kat_IV_16", 30],
            ["ACE_adenosine", 5],
            ["ACE_fieldDressing", 20],
            ["ACE_elasticBandage", 50],
            ["ACE_packingBandage", 50],
            ["ACE_quikclot", 10],
            ["ACE_bloodIV", 20],
            ["ACE_bloodIV_250", 20],
            ["ACE_bloodIV_500", 20],
            ["ACE_epinephrine", 10],
            ["ACE_morphine", 10],
            ["ACE_personalAidKit", 10],
            ["ACE_plasmaIV_500", 5],
            ["ACE_salineIV_500", 10],
            ["ACE_salineIV_250", 15],
            ["ACE_salineIV", 10],
            ["ACE_splint", 10],
            ["ACE_tourniquet", 15]         
        ]
	],
	[
		"at_resupply",
		"Box_NATO_Equip_F",
		[
			// Crate Weapons
            ["rhs_weap_fgm148", 1], // Javelin
            ["launch_MRAWS_olive_F", 1] // MAAWS
		],
		[
			// Crate Magazines
            ["rhs_fgm148_magazine_AT", 2],
            ["rhs_fim92_mag", 2],
            ["MRAWS_HEAT_F", 1],
            ["MRAWS_HE_F", 1] 
		],
		[
			// Crate Items
		]
	]
], true];

missionNamespace setVariable ["ISRC_static_weapons", [
	"RHS_TOW_TriPod_USMC_D",
	"RHS_Stinger_AA_pod_USMC_D",
    "RHS_MK19_TriPod_USMC_D",
    "B_T_Mortar_01_F",
    "RHS_M2StaticMG_D",
    "RHS_M2StaticMG_MiniTripod_D"
], true];
