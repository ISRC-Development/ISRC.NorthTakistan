// Coefficient to calculate maximum distance from the nearest building in which infantry can be garrisoned. 
// Essentially, if unit's distance from the center of the nearest building is less than or equal to (_infantryRadius * SPAWNOPTS_INFANTRY_GARRISON_COEF), they can be garrisoned.
missionNamespace setVariable ["SPAWNOPTS_INFANTRY_GARRISON_COEF", 0.25, true];