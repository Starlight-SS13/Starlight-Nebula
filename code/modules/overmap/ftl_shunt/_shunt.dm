#define CHARGE_TIME_PER_TON 0.1 //In deciseconds.
#define JOULES_PER_TON 200

#define FTL_START_FAILURE_FUEL 1 //Not enough fuel.
#define FTL_START_FAILURE_POWER 2 //Not enough power.
#define FTL_START_FAILURE_BROKEN 3 //ftl machine broken
#define FTL_START_FAILURE_COOLDOWN 4 //Cooling down.
#define FTL_START_FAILURE_OTHER 5 //Unspecific failure.

#define FTL_START_CONFIRMED 6 //All good.

#define SHUNT_SEVERITY_MINOR 1
#define SHUNT_SEVERITY_MAJOR 2
#define SHUNT_SEVERITY_CRITICAL 3
#define SHUNT_SEVERITY_CATASTROPHIC 4

#define FTL_STATUS_COOLDOWN 1
#define FTL_STATUS_OFFLINE 2
#define FTL_STATUS_GOOD 3
