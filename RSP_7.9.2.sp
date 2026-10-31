#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdktools_trace>
#include <sdktools_tempents_stocks>
#include <entity_prop_stocks>
#include <sdkhooks>
#include <cstrike>
#include <usermessages>
#include <bitbuffer>

// Optional companion APIs: Leech transfers reserve magazines; active Entropy only removes them.
native bool CS2Mag_RemoveReserveMagazines(int client, int weapon, int amount);
native int CS2Mag_TransferReserveMagazines(int sourceClient, int sourceWeapon, int destinationClient, int destinationWeapon, int amount);

#define PLUGIN_VERSION "RSP 7.9.2 - Spectator and Grenade Fixes"

#define RSP_MAX_ENTITIES 2048
#define RSP_FLASH_RECORDS 64
#define RSP_GHOST_MAINTENANCE_INTERVAL 0.50
#define RSP_WALLHACK_REFRESH_INTERVAL 0.30
#define RSP_WALLHACK_BEAM_VMT "materials/sprites/rsp_wallhack_vividgreen_0313.vmt"
#define RSP_WALLHACK_BEAM_VTF "materials/sprites/rsp_wallhack_vividgreen_0313.vtf"
#define RSP_WALLHACK_BEAM_TEXTURE "sprites/rsp_wallhack_vividgreen_0313.vmt"
#define RSP_WALLHACK_BEAM_WIDTH 0.75
#define RSP_WALLHACK_HALF_WIDTH 18.0
#define RSP_WALLHACK_BOTTOM_OFFSET 4.0
#define RSP_WALLHACK_TOP_OFFSET 76.0
#define RSP_AIMBOT_ACQUIRE_MAX_YAW 12.0
#define RSP_AIMBOT_ACQUIRE_MAX_PITCH 30.0
#define RSP_AIMBOT_HEAD_POINT_OFFSET 2.5
#define RSP_ASSIGN_DELAY 0.20
#define RSP_TARGET_SELECTION_BUILD_DELAY 0.10
#define RSP_POWER_ASSIGNMENT_NOTICE_DELAY 0.60
#define RSP_ROUND_TARGET_SELECTION_DELAY 0.10
#define RSP_ROUND_POWER_ROSTER_DELAY 0.20
#define RSP_OBSERVER_ROSTER_REFRESH_DELAY 0.35
#define RSP_BLIND_CHECK_DELAY 0.05
#define RSP_BLIND_RETRY_COUNT 12
#define RSP_FLASH_MAX_AGE 4.00
#define RSP_FLASH_MAX_DISTANCE 4096.0
#define RSP_REGENERATION_INTERVAL 3.0
#define RSP_REGENERATION_AMOUNT 15
#define RSP_BLACKOUT_FADE_DURATION 3.0
#define RSP_ENDER_GRENADE_MAX_FLIGHT_TIME 20.0
#define RSP_SCREEN_FADE_FRACBITS 9
#define RSP_HEALING_ANGEL_MAX_HEALTH 125
#define RSP_HEALING_ANGEL_ALLY_MAX_HEALTH 100
#define RSP_HEALING_ANGEL_HEAL_AMOUNT 50
#define RSP_HEALING_ANGEL_COOLDOWN 5.0
#define RSP_SCREEN_FADE_IN 0x0001
#define RSP_SCREEN_FADE_OUT 0x0002
#define RSP_SCREEN_FADE_STAYOUT 0x0008
#define RSP_SCREEN_FADE_PURGE 0x0010
#define RSP_ZOMBIE_RESPAWN_DELAY 1.25
#define RSP_ZOMBIE_RESPAWN_RETRIES 6
#define RSP_ZOMBIE_RETRY_DELAY 0.35
#define RSP_ZOMBIE_SPEED_MULTIPLIER 1.50
#define RSP_DEADLY_FLASH_THROW_GRACE 12.0
#define RSP_DEADLY_FLASH_MONEY_CAP 16000
#define RSP_DEADLY_FLASH_DISSOLVE_STYLE 1
#define RSP_INCENDIARY_AMMO_DISSOLVE_STYLE 1
#define RSP_EXECUTIONER_HE_GRACE 8.0
#define RSP_RAGDOLL_FORCE_MULTIPLIER_MAX 15.0
#define RSP_INVENTOR_TURRET_RAGDOLL_FORCE_MULTIPLIER 15.0
#define RSP_RAGDOLL_FORCE_TIMEOUT 0.75
#define RSP_EXECUTIONER_ARMOR_LETHAL_FACTOR 2.0
#define RSP_EXECUTIONER_LETHAL_MARGIN 10.0
#define RSP_RAGDOLL_FORCE_CAP 150000.0
#define RSP_RAGDOLL_VELOCITY_CAP 6000.0
#define RSP_RAGDOLL_FALLBACK_FORCE 12000.0
#define RSP_RAGDOLL_FALLBACK_VELOCITY 600.0
#define RSP_RETREAT_COOLDOWN 20.0
#define RSP_SWAPPER_COOLDOWN 30.0
#define RSP_GODMODE_COOLDOWN 25.0
#define RSP_DAMAGER_COOLDOWN 30.0
#define RSP_DAMAGER_DAMAGE 25.0
#define RSP_GODMODE_DURATION 3.5
#define RSP_RANDOM_WEAPON_COOLDOWN 15.0
#define RSP_STRIP_WEAPONS_COOLDOWN 30.0
#define RSP_RECLAIMER_CHANCE 50
#define RSP_CONCUSSION_CHANCE_MIN 15
#define RSP_CONCUSSION_CHANCE_MAX 30
#define RSP_CONCUSSION_FLASH_DURATION 3.0
#define RSP_SPECTATOR_DURATION 5.0
#define RSP_SPECTATOR_COOLDOWN 25.0
#define RSP_BLOODLUST_HEAL 100
#define RSP_DEMOLITION_DAMAGE_MULTIPLIER 1.50
#define RSP_DEMOLITION_RADIUS_MULTIPLIER 3.00
#define RSP_EXPLODING_BARREL_COOLDOWN 10.0
#define RSP_EXPLODING_BARRELS_PER_COOLDOWN 2
#define RSP_REPLICA_COOLDOWN 25.0
#define RSP_REPLICA_HEALTH 100
#define RSP_REPLICA_FORWARD_DISTANCE 40.0
#define RSP_REPLICA_MIN_FORWARD_DISTANCE 34.0
#define RSP_REPLICA_FORWARD_STEP 2.0
#define RSP_REPLICA_COLLISION_HEIGHT 72.0
#define RSP_REPLICA_FLOOR_TRACE_UP 64.0
#define RSP_REPLICA_FLOOR_TRACE_DOWN 96.0
#define RSP_REPLICA_FLOOR_SAMPLE_OFFSET 14.0
#define RSP_REPLICA_MAX_GROUND_VARIATION 24.0
#define RSP_BUILDABLE_MAX_GROUND_VARIATION 112.0
#define RSP_BUILDABLE_FLOOR_TRACE_UP 128.0
#define RSP_BUILDABLE_FLOOR_TRACE_DOWN 192.0
#define RSP_BUILDABLE_MAX_REFERENCE_DELTA 128.0
#define RSP_BUILDABLE_MIN_GROUND_SAMPLES 9
#define RSP_BUILDABLE_PLACEMENT_ATTEMPTS 8
#define RSP_BUILDABLE_PLACEMENT_STEP 5.0
#define RSP_BUILDABLE_CLEARANCE_XY_SCALE 0.82
#define RSP_BUILDABLE_CLEARANCE_HEIGHT_SCALE 1.0
// Tesla placement uses the full footprint and a small margin so walls/props cannot overlap its edges.
#define RSP_INVENTOR_TURRET_CLEARANCE_XY_SCALE 1.0
#define RSP_INVENTOR_TURRET_CLEARANCE_XY_MIN 36.0
#define RSP_INVENTOR_TURRET_CLEARANCE_PADDING 8.0
#define RSP_INVENTOR_TURRET_POSTSPAWN_PADDING 6.0
#define RSP_REPLICA_GROUND_CLEARANCE 1.0
#define RSP_BUILDER_COOLDOWN 5.0
#define RSP_INVENTOR_COOLDOWN 5.0
#define RSP_LEECH_CHANCE_MIN 20
#define RSP_LEECH_CHANCE_MAX 40
#define RSP_WEAPON_SWAP_COOLDOWN 20.0
#define RSP_ENTROPY_COOLDOWN 20.0
#define RSP_LEECH_RESERVE_TRANSFER_PERCENT 25
#define RSP_MINER_USES_PER_ROUND 5
#define RSP_MINER_COOLDOWN 5.0
#define RSP_MINER_TRIGGER_RADIUS 40.0
#define RSP_MINER_RADIUS 500.0
#define RSP_MINER_DAMAGE 100.0
#define RSP_MINER_ENEMY_VISIBILITY_RADIUS 60.0
#define RSP_MINER_MIN_SEPARATION 50.0
#define RSP_LOOTBOX_USE_RADIUS 90.0
#define RSP_LOOTBOX_USE_COOLDOWN 1.2
#define RSP_COLLISION_GROUP_INTERACTIVE_DEBRIS 3
#define RSP_COLLISION_GROUP_PLAYER 5
#define RSP_COLLISION_GROUP_PLAYER_MOVEMENT 8
#define RSP_LOOTBOX_MODEL "models/items/cs_gift.mdl"
#define RSP_BUILDABLE_NONE 0
#define RSP_BUILDABLE_FENCE 1
#define RSP_BUILDABLE_TURRET 2

#define RSP_BUILDER_FENCE_MODEL "models/props_wasteland/wood_fence01a.mdl"
#define RSP_INVENTOR_TURRET_MODEL "models/props_c17/substation_transformer01d.mdl"
#define RSP_BUILDER_FENCE_HEALTH 150.0
#define RSP_BUILDER_FENCE_GROUND_SINK 17.0
#define RSP_BUILDER_DEBRIS_LIFETIME 4.5
#define RSP_BUILDER_DEBRIS_COUNT 10
#define RSP_INVENTOR_USES_PER_ROUND 2
#define RSP_INVENTOR_MAX_TURRETS 2
#define RSP_INVENTOR_TURRET_HEALTH 350.0
#define RSP_INVENTOR_TURRET_EXPLOSION_MAGNITUDE 100
#define RSP_INVENTOR_TURRET_EXPLOSION_RADIUS 350
#define RSP_INVENTOR_TURRET_DAMAGE_MIN 15
#define RSP_INVENTOR_TURRET_DAMAGE_MAX 25
#define RSP_INVENTOR_TURRET_INTERVAL 1.2
#define RSP_INVENTOR_TURRET_BEAM_LIFE 0.12
#define RSP_INVENTOR_TURRET_BEAM_WIDTH 24.0
#define RSP_INVENTOR_TURRET_BEAM_END_WIDTH 8.5
#define RSP_INVENTOR_TURRET_IMPACT_SPRITE "sprites/blueglow1.vmt"
#define RSP_INVENTOR_TURRET_IMPACT_SPRITE_SIZE 1.00
#define RSP_INVENTOR_TURRET_IMPACT_SPRITE_BRIGHTNESS 255
#define RSP_INVENTOR_TURRET_MUZZLE_HEIGHT 100.0
// Fallback lifts are only used when a spawned model does not expose credible bounds.
#define RSP_BUILDER_FENCE_FALLBACK_LIFT 38.0
#define RSP_INVENTOR_TURRET_FALLBACK_LIFT 62.0
#define RSP_INVENTOR_TURRET_GROUND_SINK 4.0
#define RSP_INVENTOR_TURRET_ANTENNA_TOP_INSET 7.0
// Used only if the model collision cannot provide a valid antenna-top sample.
#define RSP_INVENTOR_TURRET_BEAM_RIGHT_OFFSET -10.0
#define RSP_INVENTOR_TURRET_BEAM_FORWARD_OFFSET 2.0
#define RSP_INVENTOR_TURRET_BEAM_SURFACE_GRID 24
#define RSP_INVENTOR_TURRET_BEAM_SURFACE_SCAN_DEPTH 20.0
#define RSP_INVENTOR_TURRET_LOOP_SOUND "ambient/energy/force_field_loop1.wav"
#define RSP_INVENTOR_TURRET_SHOT_SOUND "weapons/physcannon/energy_disintegrate4.wav"
#define RSP_INVENTOR_TURRET_SHOT_SOUND_LEVEL 85
#define RSP_INVENTOR_TURRET_EXPLOSION_SOUND "weapons/hegrenade/explode3.wav"
#define RSP_INVENTOR_TURRET_LOOP_RADIUS "750"
#define RSP_INVENTOR_TURRET_LOOP_VOLUME "10"
#define RSP_INVENTOR_TURRET_ARC_TEXTURE "sprites/physbeam.vmt"
#define RSP_INVENTOR_TURRET_ARC_COLOR "85 155 255"
#define RSP_INVENTOR_TURRET_ARC_RADIUS "70"
#define RSP_INVENTOR_TURRET_ARC_BEAMCOUNT_MIN "3"
#define RSP_INVENTOR_TURRET_ARC_BEAMCOUNT_MAX "5"
#define RSP_INVENTOR_TURRET_ARC_THICK_MIN "1"
#define RSP_INVENTOR_TURRET_ARC_THICK_MAX "4"
#define RSP_INVENTOR_TURRET_ARC_LIFETIME_MIN "0.25"
#define RSP_INVENTOR_TURRET_ARC_LIFETIME_MAX "0.4"
#define RSP_INVENTOR_TURRET_ARC_INTERVAL_MIN "0.45"
#define RSP_INVENTOR_TURRET_ARC_INTERVAL_MAX "0.9"
#define RSP_INVENTOR_TURRET_HEADSHOT_CHANCE 15
#define RSP_INVENTOR_TURRET_JUGGERNAUT_HEADSHOT_CHANCE 15
#define RSP_INVENTOR_TURRET_HEADSHOT_MULTIPLIER 4.0
#define RSP_INVENTOR_TURRET_ARC_HEIGHT_OFFSET 10.0
#define RSP_TESLA_LOOP_SOUND_SPAWNFLAGS "16"
#define RSP_EFL_DIRTY_SURR_COLLISION_BOUNDS (1 << 14)
#define RSP_HOOK_COOLDOWN 5.0
#define RSP_HOOK_PULL_SPEED 750.0
#define RSP_HOOK_BELT_HEIGHT 40.0
#define RSP_HOOK_STOP_DISTANCE 56.0
#define RSP_HOOK_TICK 0.05
#define RSP_VIPER_DAMAGE 3
#define RSP_VIPER_INTERVAL 2.5
#define RSP_ANOMALY_COOLDOWN 15.0
#define RSP_ANOMALY_LOOKBACK 7.0
#define RSP_ANOMALY_SAMPLE_INTERVAL 1.0
#define RSP_ANOMALY_HISTORY_SAMPLES 12
#define RSP_EXPLODING_BARREL_MODEL "models/props_c17/oildrum001_explosive.mdl"
#define RSP_GHOST_DEATH_REVEAL_DURATION 1.25
#define RSP_IMPOSTOR_DEATH_TRANSITION_DURATION 1.50
#define RSP_DWARF_DUCK_VIEW_HEIGHT_DELTA 18.0
#define RSP_INFINITE_GRENADE_REFILL_DELAY 0.50
#define RSP_INFINITE_GRENADE_FALLBACK_GUARD 5.0
#define RSP_GRENADE_TYPE_COUNT 3
#define RSP_GRENADE_HE 0
#define RSP_GRENADE_FLASH 1
#define RSP_GRENADE_SMOKE 2
#define RSP_INVENTORY_WEAPON_LIMIT 64
#define RSP_REVIVER_COOLDOWN 20.0
#define RSP_INCENDIARY_AMMO_DURATION 3.0
#define RSP_RAPID_FIRE_MIN 1.05
#define RSP_RAPID_FIRE_MAX 1.25
#define RSP_RAMBO_BONUS_MIN 50
#define RSP_RAMBO_BONUS_MAX 500
#define RSP_ASTRONAUT_GRAVITY_MIN 0.10
#define RSP_ASTRONAUT_GRAVITY_MAX 0.60
#define RSP_SPEED_DEMON_MIN 1.20
#define RSP_SPEED_DEMON_MAX 3.00
#define RSP_RICH_BOY_MIN 5000
#define RSP_RICH_BOY_MAX 15000
#define RSP_RICH_BOY_STEP 50
#define RSP_DWARF_SCALE_MIN 0.25
#define RSP_DWARF_SCALE_MAX 0.75
#define RSP_ARMOURED_REDUCTION_MIN 0.65
#define RSP_ARMOURED_REDUCTION_MAX 0.85
#define RSP_BLADEMASTER_DEFLECT_CHANCE 85
#define RSP_DASH_COOLDOWN 4.0
#define RSP_DASH_FORWARD_IMPULSE 700.0
#define RSP_DASH_VERTICAL_IMPULSE 180.0
#define RSP_DASH_GROUND_VERTICAL_IMPULSE 300.0
#define RSP_REVERSER_COOLDOWN 15.0
#define RSP_REVERSER_DURATION 10.0
#define RSP_GHOST_PISTOL_RESTORE_DELAY 0.50
#define RSP_PISTOL_RESTORE_MAX_ATTEMPTS 4
#define RSP_ZOMBIE_HEALTH 600
#define RSP_ZOMBIE_DROPPED_WEAPONS 16
#define RSP_ZOMBIE_DROP_CLEANUP_WINDOW 0.60
#define RSP_FLASH_ENEMY_KILL_REWARD 300
#define RSP_FLASH_TEAMKILL_PENALTY 3300
#define RSP_DRACULA_HEAL_MULTIPLIER 0.50
#define RSP_DRACULA_MAX_HEALTH 200
#define RSP_DOUBLE_JUMP_DELAY 0.50
#define RSP_DOUBLE_JUMP_VERTICAL_SPEED 265.0
#define RSP_FLASH_PRO_DURATION 7.0
#define RSP_LONG_FLASH_MAX_AGE 2.50
#define RSP_KNOCKBACK_IMPULSE 180.0
#define RSP_KNOCKBACK_VERTICAL_AIM_THRESHOLD 0.70
#define RSP_KNOCKBACK_GROUND_LAUNCH_MIN 300.0
#define RSP_KNOCKBACK_MAX_HORIZONTAL_SPEED 520.0
#define RSP_KNOCKBACK_MAX_VERTICAL_SPEED 650.0
#define RSP_DEATH_BOMB_MAGNITUDE 200
#define RSP_DEATH_BOMB_RADIUS 700 // 2x the stock CS:S HE radius; damage magnitude remains unchanged.
#define RSP_POWER_RESPAWN_DELAY 0.75
#define RSP_POWER_RESPAWN_RETRIES 6
#define RSP_POWER_RESPAWN_RETRY_DELAY 0.35
#define RSP_POWER_RESPAWN_REVIVER 1
#define RSP_POWER_RESPAWN_PHOENIX 2
#define RSP_POWER_RESPAWN_RESURRECTION 3
#define RSP_TOXIC_SMOKE_MAX_CLOUDS 32
#define RSP_TOXIC_SMOKE_DURATION 18.0
#define RSP_TOXIC_SMOKE_RADIUS 180.0
#define RSP_TOXIC_SMOKE_DAMAGE 15.0
#define RSP_TOXIC_SMOKE_TICK_INTERVAL 1.00
#define RSP_TOXIC_SMOKE_TIMER_INTERVAL 0.05
#define RSP_TOXIC_SMOKE_THROW_MAX_AGE 25.0
#define RSP_FREEZING_AMMO_DURATION 3.00
#define RSP_CRIPPLER_DURATION 4.0
#define RSP_CRIPPLER_SPEED_MULTIPLIER 0.50
#define RSP_CRIPPLER_DAMAGE_MULTIPLIER 0.25
#define RSP_DISORIENT_COOLDOWN 1.00
#define RSP_DISORIENT_VIEW_TIMEOUT 0.75
#define RSP_DISORIENT_ANGLE_ACK_TOLERANCE 8.0
#define RSP_THORNS_REFLECT_RATIO 0.50
#define RSP_FRIENDLY_FIRE_HEAL_RATIO 0.05
#define RSP_DISARM_CHANCE_MIN 20
#define RSP_DISARM_CHANCE_MAX 40
#define RSP_NOCLIP_DURATION 5.0
#define RSP_NOCLIP_COOLDOWN 20.0
#define RSP_NOCLIP_SAFE_CHECK_INTERVAL 0.20
#define RSP_NOCLIP_HIGH_RESCUE_MARGIN 768.0
#define RSP_NOCLIP_PLAYERCLIP_RESCUE_MARGIN 256.0
#define RSP_NOCLIP_PLAYERCLIP_TRACE_DEPTH 2048.0
#define RSP_NOCLIP_NODRAW_TRACE_DEPTH 64.0
#define RSP_NOCLIP_SKY_TRACE_DEPTH 64.0
#define RSP_NOCLIP_SKYCAMERA_RESCUE_RADIUS 2048.0
#define RSP_NOCLIP_SKYCAMERA_MIN_SPAWN_DISTANCE 1024.0
#define RSP_MEDIC_CHARGES 3
#define RSP_MEDIC_AMOUNT 50
#define RSP_MEDIC_MAX_HEALTH 100
#define RSP_HEALING_SMOKE_AMOUNT 15
#define RSP_SMOKE_CLOUD_TOXIC 1
#define RSP_SMOKE_CLOUD_HEALING 2
#define RSP_SMOKE_PROJECTILE_MAX_AGE 25.0
#define RSP_EXPLOSIVE_AMMO_CHANCE_MIN 15
#define RSP_EXPLOSIVE_AMMO_CHANCE_MAX 30
#define RSP_EXPLOSIVE_AMMO_DAMAGE 50.0
#define RSP_EXPLOSIVE_AMMO_SOUND_1 "weapons/hegrenade/explode3.wav"
#define RSP_EXPLOSIVE_AMMO_SOUND_2 "weapons/hegrenade/explode4.wav"
#define RSP_EXPLOSIVE_AMMO_SOUND_3 "weapons/hegrenade/explode5.wav"
#define RSP_EXPLOSIVE_AMMO_DECAL "decals/scorch1"
#define RSP_EXPLOSIVE_AMMO_RADIUS 175.0


#define RSP_KNOCKUP_CHANCE_MIN 20
#define RSP_KNOCKUP_CHANCE_MAX 40
#define RSP_KNOCKUP_VERTICAL_SPEED 416.0
#define RSP_BANKRUPT_NONE 0
#define RSP_EXTORTION_COST 50
#define RSP_BERSERKER_TRIGGER_HP 25
#define RSP_BERSERKER_DAMAGE_MULTIPLIER 1.50
#define RSP_BERSERKER_SPEED_MULTIPLIER 1.40
#define RSP_GIANT_SCALE_MIN 1.10
#define RSP_GIANT_SCALE_MAX 1.40
#define RSP_GIANT_HEALTH_MIN 120
#define RSP_GIANT_HEALTH_MAX 400
#define RSP_SAPPER_SPEED_MIN 20
#define RSP_SAPPER_SPEED_MAX 60
#define RSP_RADAR_HIDDEN_COORD -4095
// Source engine observer mode value: OBS_MODE_ROAMING (free spectator camera), not an RSP power.
#define RSP_OBSERVER_MODE_ROAMING 6


enum RSPPower
{
    RSP_None = 0,
    RSP_Executioner,
    RSP_Aimbot,
    RSP_Wallhack,
    RSP_Rambo,
    RSP_Astronaut,
    RSP_SpeedDemon,
    RSP_Ghost,
    RSP_DeadlyFlash,
    RSP_Armoured,
    RSP_Regeneration,
    RSP_SteelHead,
    RSP_Juggernaut,
    RSP_IncendiaryAmmo,
    RSP_Disarmament,
    RSP_RichBoy,
    RSP_Dwarf,
    RSP_Zombie,
    RSP_Retreat,
    RSP_EnemySpawn,
    RSP_Swapper,
    RSP_Bunny,
    RSP_RapidFire,
    RSP_InfiniteAmmo,
    RSP_Impostor,
    RSP_Dracula,
    RSP_FreezingAmmo,
    RSP_Disorient,
    RSP_ToxicSmoke,
    RSP_DoubleJump,
    RSP_FlashPro,
    RSP_Knockback,
    RSP_DeathBomb,
    RSP_Reviver,
    RSP_Phoenix,
    RSP_GodMode,
    RSP_RandomWeapon,
    RSP_StripWeapons,
    RSP_Grenadier,
    RSP_Sunshine,
    RSP_Smoker,
    RSP_HealingSmoke,
    RSP_Thorns,
    RSP_NoClip,
    RSP_Medic,
    RSP_FriendlyFire,
    RSP_Gambler,
    RSP_Curser,
    RSP_ExplodingBarrel,
    RSP_Soldier,
    RSP_Thief,
    RSP_ExplosiveAmmo,
    RSP_Bankrupt,
    RSP_Extortion,
    RSP_Duplicator,
    RSP_Berserker,
    RSP_Hacker,
    RSP_Chameleon,
    RSP_Scientist,
    RSP_Sapper,
    RSP_Machete,
    RSP_BlastProtection,
    RSP_Blademaster,
    RSP_Dash,
    RSP_Reverser,
    RSP_Knockup,
    RSP_Replica,
    RSP_Anomaly,
    RSP_Hook,
    RSP_Resurrection,
    RSP_Viper,
    RSP_RobinHood,
    RSP_Assassin,
    RSP_NoRecoil,
    RSP_Builder,
    RSP_Inventor,
    RSP_FeatherFalling,
    RSP_WeaponSwap,
    RSP_Lootbox,
    RSP_Grounder,
    RSP_Leech,
    RSP_Miner,
    RSP_Avenger,
    RSP_Crippler,
    RSP_Giant,
    RSP_Entropy,
    RSP_Damager,
    RSP_Blackout,
    RSP_HealingAngel,
    RSP_EnderGrenade,
    RSP_Reclaimer,
    RSP_Concussion,
    RSP_Bloodlust,
    RSP_Spectator,
    RSP_Demolition,
    RSP_PowerCount
};

enum RSPClientLanguage
{
    RSP_LANG_EN = 0,
    RSP_LANG_PL
};

// Explicit random pool of implemented powers only. Retreat/Enemy Spawn and Ender Grenade use hull-checked destinations; activated powers share the established bind dispatcher.
// Teleport destinations are hull-checked against world geometry, props and other players.
static const RSPPower g_RSPSelectablePowers[] =
{ // 94 active entries. Disabled/retired powers are excluded from the enum, pool, and language tables.
    RSP_Executioner, RSP_Aimbot, RSP_Wallhack, RSP_Rambo,
    RSP_Astronaut, RSP_SpeedDemon, RSP_Ghost, RSP_DeadlyFlash,
    RSP_Armoured, RSP_Regeneration, RSP_SteelHead, RSP_Juggernaut,
    RSP_IncendiaryAmmo, RSP_Disarmament, RSP_RichBoy, RSP_Dwarf, RSP_Zombie,
    RSP_Retreat, RSP_EnemySpawn, RSP_Swapper, RSP_Bunny, RSP_RapidFire, RSP_InfiniteAmmo,
    RSP_Impostor, RSP_Dracula, RSP_FreezingAmmo, RSP_Disorient, RSP_ToxicSmoke,
    RSP_DoubleJump, RSP_FlashPro, RSP_Knockback, RSP_DeathBomb,
    RSP_Reviver, RSP_Phoenix, RSP_GodMode, RSP_RandomWeapon, RSP_StripWeapons,
    RSP_Grenadier, RSP_Sunshine, RSP_Smoker, RSP_HealingSmoke, RSP_Thorns,
    RSP_NoClip, RSP_Medic, RSP_FriendlyFire, RSP_Gambler, RSP_Curser,
    RSP_ExplodingBarrel, RSP_Soldier, RSP_Thief,
    RSP_ExplosiveAmmo, RSP_Bankrupt, RSP_Extortion, RSP_Duplicator,
    RSP_Berserker, RSP_Hacker, RSP_Chameleon, RSP_Scientist, RSP_Sapper,
    RSP_Machete, RSP_BlastProtection, RSP_Blademaster,
    RSP_Dash, RSP_Reverser, RSP_Knockup, RSP_Replica,
    RSP_Anomaly, RSP_Hook, RSP_Resurrection, RSP_Viper,
    RSP_RobinHood, RSP_Assassin, RSP_NoRecoil, RSP_Builder, RSP_Inventor,
    RSP_FeatherFalling, RSP_WeaponSwap, RSP_Lootbox, RSP_Grounder,
    RSP_Leech, RSP_Miner, RSP_Avenger, RSP_Crippler, RSP_Giant, RSP_Entropy, RSP_Damager,
    RSP_Blackout, RSP_HealingAngel, RSP_EnderGrenade,
    RSP_Reclaimer, RSP_Concussion, RSP_Bloodlust, RSP_Spectator, RSP_Demolition
};

static const char g_sPowerNamesEn[RSP_PowerCount][32] =
{
    "None",
    "Executioner",
    "Aimbot",
    "Wallhack",
    "Rambo",
    "Astronaut",
    "Speed Demon",
    "Ghost",
    "Deadly Flash",
    "Armoured",
    "Regeneration",
    "Steel Head",
    "Juggernaut",
    "Incendiary Ammo",
    "Disarmament",
    "Rich Boy",
    "Dwarf",
    "Zombie",
    "Retreat",
    "Enemy Spawn",
    "Swapper",
    "Bunny",
    "Rapid Fire",
    "Infinite Ammo",
    "Impostor",
    "Dracula",
    "Freezing Ammo",
    "Disorient",
    "Toxic Smoke",
    "Double Jump",
    "Flash-Pro",
    "Knockback",
    "Death Bomb",
    "Reviver",
    "Phoenix",
    "God Mode",
    "Random Weapon",
    "Heist",
    "Grenadier",
    "Sunshine",
    "Smoker",
    "Healing Smoke",
    "Thorns",
    "NoClip",
    "Medic",
    "Friendly Fire",
    "Gambler",
    "Curser",
    "Exploding Barrel",
    "Soldier",
    "Thief",
    "Explosive Ammo",
    "Bankrupt",
    "Extortion",
    "Duplicator",
    "Berserker",
    "Hacker",
    "Chameleon",
    "Scientist",
    "Sapper",
    "Machete",
    "Blast Protection",
    "Blademaster",
    "Dash",
    "Reverser",
    "Knockup",
    "Replica",
    "Anomaly",
    "Hook",
    "Resurrection",
    "Viper",
    "Robin Hood",
    "Assassin",
    "No Recoil",
    "Builder",
    "Inventor",
    "Feather Falling",
    "Weapon Swap",
    "Lootbox",
    "Grounder",
    "Leech",
    "Miner",
    "Avenger",
    "Crippler",
    "Giant",
    "Entropy",
    "Damager",
    "Blackout",
    "Healing Angel",
    "Ender Grenade",
    "Reclaimer",
    "Concussion",
    "Bloodlust",
    "Spectator",
    "Demolition"
};

static const char g_sPowerDescriptionsEn[RSP_PowerCount][256] =
{
    "No active superpower.",
    "Any damage you deal to an enemy instantly kills them.",
    "Firearm hits count as headshots for damage and killfeed.",
    "Enemies are visible through walls when they are close enough.",
    "You receive bonus health.",
    "Your gravity is reduced.",
    "Your movement speed is increased.",
    "You are completely invisible. You can only use a knife and grenades.",
    "Your flashbangs instantly kill anyone they blind.",
    "Reduces incoming damage by 65–85%.",
    "You regenerate 15 HP every 3 seconds.",
    "You are immune to headshots.",
    "Bullets hitting your body deal no damage.",
    "Firearm hits ignite enemies for 3 seconds.",
    "A hit has a 20–40% chance to make the enemy drop their held weapon.",
    "You receive a cash bonus.",
    "Your player model is scaled down (range: x0.25–x0.75).",
    "After death, you respawn as a zombie with 600 HP and x1.50 movement speed. You can only use a knife.",
    "Activate to teleport back to your team's spawn.",
    "Activate to teleport to the enemy spawn. Cooldown: 20 seconds.",
    "Swap positions with a random living enemy. Cooldown: 30 seconds.",
    "Hold jump to automatically jump again when you land.",
    "Your rate of fire is increased.",
    "Your firearm magazine never runs out of ammunition.",
    "You change into a random model from the opposing team.",
    "You restore 50% of the damage you deal, up to 200 HP.",
    "A hit has a 20–40% chance to freeze the enemy's movement and block their attacks for 3 seconds.",
    "A hit has a 20–40% chance to turn the enemy 180°.",
    "Your smoke deals 15 damage to enemies every 1 second.",
    "You have an extra jump. Press jump in mid-air to bounce again every 0.5 seconds.",
    "You are immune to flashbang blindness. Your flashbangs blind enemies for 7 seconds.",
    "Firearm shots push you opposite to your aim direction.",
    "On death, you explode, dealing heavy damage to everyone within range.",
    "Every 20 seconds, you can try to revive a random dead teammate (50% chance).",
    "After death, you have a 50% chance to respawn with full team equipment.",
    "After activation, you are immune to all damage for 3.5 seconds. Cooldown: 25 seconds.",
    "Activate to receive a random weapon. Cooldown: 15 seconds.",
    "Steal a random enemy’s primary weapon and pistol, dropping both beside you. Cooldown: 30 seconds.",
    "Your HE grenades never run out.",
    "Your flashbangs never run out.",
    "Your smoke grenades never run out.",
    "Your smoke heals living teammates by 15 HP per second, up to 100 HP, for 18 seconds.",
    "Reflect 50% of the actual health damage an enemy deals to you back to that attacker.",
    "Fly freely, ignoring collisions, for 5 seconds. Cooldown: 20 seconds after it ends.",
    "You have three medkits per round. Each restores 50 HP, up to 100 HP.",
    "Shooting teammates heals them for 5% of the damage the shot would have dealt.",
    "Choose one of three superpowers by typing /1, /2, or /3 in chat.",
    "Choose an enemy who will lose 5 HP for each missed shot by typing /1, /2, etc. in chat.",
    "Place two explosive barrels where you are aiming. Cooldown: 10 seconds after the second barrel.",
    "You deal 15–30% more damage.",
    "Steal the selected enemy’s superpower by typing /1, /2, etc. in chat.",
    "A bullet impact has a 15–30% chance to trigger an explosion dealing up to 50 damage.",
    "Choose an enemy who will lose all their cash by typing /1, /2, etc. in chat.",
    "The selected enemy pays $50 for each shot. Choose an enemy by typing /1, /2, etc. in chat.",
    "Copy the selected enemy’s superpower by typing /1, /2, etc. in chat.",
    "At 25 HP or less, you deal 50% more damage and move 40% faster.",
    "Disable the selected enemy’s radar by typing /1, /2, etc. in chat.",
    "You copy the superpower of the first enemy you kill.",
    "You can enlarge a selected enemy by typing /1, /2, etc. in chat.",
    "Planting and defusing the bomb take 20–60% less time when your team can perform that objective.",
    "Knife hits instantly kill living enemies.",
    "You are immune to explosive damage.",
    "While holding a knife, you have an 85% chance to block a bullet hit.",
    "Activate to launch yourself strongly forward. Cooldown: 4 seconds.",
    "Activate to reverse a random enemy’s controls for 10 seconds. Cooldown: 15 seconds.",
    "A firearm hit has a 20–40% chance to launch the enemy straight upward.",
    "Activate to place a replica of your character in front of you. It reflects damage back to the attacker. Cooldown: 25 seconds.",
    "Activate to teleport to your position from 7 seconds ago. Cooldown: 15 seconds.",
    "Activate to fire a rope at the surface you aim at and pull yourself toward it. Cooldown: 5 seconds.",
    "You respawn once after your death.",
    "Hits poison enemies: 3 HP every 2.5 s. Further hits add 3 HP poison damage. Poison cannot kill.",
    "Steal $10 from an enemy for every point of damage you deal to them.",
    "Firearm and knife hits deal double damage when you attack an enemy from behind.",
    "No camera kick while firing.",
    "Activate to place a wooden wall in front of you. Cooldown: 5 seconds.",
    "Activate to place a laser turret that attacks nearby enemies. Tesla: 350 HP / 15–25 DMG. Cooldown: 5 seconds.",
    "You take no fall damage.",
    "Activate to swap the weapon you are currently holding with a random enemy. Cooldown: 20 seconds.",
    "A killed enemy drops a gift for your team. Aim at it and press “E” to open it.",
    "Choose an enemy to block jumping until round end by typing /1, /2, etc. in chat.",
    "A hit has a chance to steal the enemy's reserve ammo (range: 20–40%).",
    "You have five mines per round. They explode when an enemy enters their range. Cooldown: 5 seconds.",
    "You inherit the superpower of the first teammate who dies this round.",
    "Hit enemies move 50% slower and deal 75% less damage for 4 seconds.",
    "Your model is enlarged (range: x1.10–x1.40) and gains bonus HP based on size.",
    "Activate to remove all reserve ammo from the firearm currently held by a random enemy. Cooldown: 20 seconds.",
    "Activate to deal 25 damage to all enemies. Cooldown: 30 seconds.",
    "Choose the enemy who will receive the blackout effect by typing /1, /2, etc. in chat.",
    "Regenerate below 125 HP. Restore +50 HP to allies, up to 100 HP. Cooldown: 5 seconds.",
    "Teleport to the blast area of your HE grenade.",
    "You have a 50% chance to recover a used grenade.",
    "A hit has a 15–30% chance to blind the enemy. (range: 15-30%).",
    "You receive +100 HP for each enemy kill.",
    "Activate spectator mode for 5 seconds. Cooldown: 25 seconds after it ends.",
    "Your HE grenades deal 1.5x damage and have 3x the blast radius."
};

static const char g_sPowerDescriptions[RSP_PowerCount][256] =
{
    "Brak aktywnej super mocy.",
    "Dowolne obrażenia zadane przeciwnikowi natychmiast go zabijają.",
    "Trafienia z broni palnej zadają obrażenia jak strzał w głowę i liczą się jako headshot.",
    "Przeciwnicy są widoczni przez ściany, gdy są wystarczająco blisko.",
    "Otrzymujesz dodatkowe zdrowie.",
    "Grawitacja jest zmniejszona.",
    "Prędkość ruchu jest zwiększona.",
    "Jesteś całkowicie niewidzialny. Możesz używać tylko noża i granatów.",
    "Twoje flashbangi zabijają każdego, kogo oślepią.",
    "Redukcja otrzymywanych obrażeń o 65–85%.",
    "Odzyskujesz 15 HP co 3 sekundy.",
    "Jesteś odporny na strzały w głowę.",
    "Pociski trafiające w ciało nie zadają Ci obrażeń.",
    "Trafienia z broni palnej podpalają przeciwnika na 3 sekundy.",
    "Trafienie ma 20–40% szansy na wyrzucenie trzymanej broni przeciwnika.",
    "Otrzymujesz premię pieniężną.",
    "Twój model postaci jest zmniejszony (zakres: x0,25–x0,75).",
    "Po śmierci odradzasz się jako zombie z 600 HP i prędkością x1.50. Możesz używać tylko noża.",
    "Aktywuj, aby teleportować się z powrotem na swój spawn.",
    "Aktywuj, aby teleportować się na spawn przeciwników. Odnowienie: 20 sekund.",
    "Zamieniasz się pozycją z losowym żywym przeciwnikiem. Odnowienie: 30 sekund.",
    "Przytrzymaj skok, aby automatycznie skakać po lądowaniu.",
    "Szybkostrzelność jest zwiększona.",
    "Naboje w magazynku broni palnej nie kończą się.",
    "Zmieniasz się w losowy model przeciwnej drużyny.",
    "Odzyskujesz 50% zadanych obrażeń, maksymalnie do 200 HP.",
    "Trafienie ma 20–40% szansy na zamrożenie ruchu oraz ataku przeciwnika na 3 sekundy.",
    "Trafienie ma 20–40% szansy na obrócenie przeciwnika o 180°.",
    "Twój dym zadaje wrogom 15 obrażeń co 1 sekundę.",
    "Posiadasz dodatkowy skok. Naciskaj przycisk skoku w powietrzu, aby odbijać się ponownie co 0,5 s.",
    "Jesteś odporny na efekty oślepienia. Twoje flesze oślepiają przeciwników przez 7 sekund.",
    "Strzały z broni palnej odrzucają Cię w kierunku przeciwnym do celowania.",
    "Po śmierci eksplodujesz, zadając wysokie obrażenia wszystkim w zasięgu.",
    "Co 20 sekund możesz próbować wskrzesić losowego martwego sojusznika (50% szansy).",
    "Po śmierci masz 50% szansy na odrodzenie z pełnym wyposażeniem swojej drużyny.",
    "Po aktywacji jesteś odporny na wszystkie obrażenia przez 3,5 sekundy. Odnowienie: 25 sekund.",
    "Po aktywacji otrzymujesz losową broń. Odnowienie: 15 sekund.",
    "Kradniesz broń główną i pistolet losowego przeciwnika, upuszczając je obok siebie. Odnowienie: 30 sekund.",
    "Twoje granaty HE nigdy się nie kończą.",
    "Twoje granaty błyskowe nigdy się nie kończą.",
    "Twoje granaty dymne nigdy się nie kończą.",
    "Twój dym leczy żywych sojuszników o 15 HP co 1 s, maksymalnie do 100 HP, przez 18 s.",
    "Odbijasz na atakującego 50% otrzymanych obrażeń.",
    "Możesz swobodnie latać, ignorując kolizje, przez 5 sekund. Odnowienie: 20 sekund po zakończeniu.",
    "Masz trzy apteczki na rundę. Każda przywraca 50 HP, maksymalnie do 100 HP.",
    "Strzelanie do sojuszników leczy ich o 5% obrażeń, które zadałby strzał.",
    "Wybierz jedną z trzech supermocy, wpisując na czacie /1, /2 lub /3.",
    "Wybierz przeciwnika, który straci 5 HP za każdy niecelny strzał, wpisując na czacie /1, /2 itd.",
    "Postaw dwie wybuchowe beczki w miejscu celowania. Odnowienie: 10 sekund po postawieniu drugiej beczki.",
    "Zadajesz o 15–30% większe obrażenia.",
    "Możesz ukraść supermoc wybranemu przeciwnikowi, wpisując na czacie /1, /2 itd.",
    "Uderzenie pocisku ma 15–30% szansy na wybuch zadający do 50 obrażeń.",
    "Wybierz przeciwnika, który straci całą gotówkę, wpisując na czacie /1, /2 itd.",
    "Wybrany przeciwnik płaci $50 za każdy strzał. Wybierz przeciwnika, wpisując na czacie /1, /2 itd.",
    "Możesz skopiować supermoc wybranego przeciwnika, wpisując na czacie /1, /2 itd.",
    "Przy 25 HP lub mniej zadajesz o 50% większe obrażenia i poruszasz się o 40% szybciej.",
    "Możesz wyłączyć radar wybranemu przeciwnikowi, wpisując na czacie /1, /2 itd.",
    "Przejmujesz supermoc pierwszego zabitego przeciwnika.",
    "Możesz zwiększyć model wybranemu przeciwnikowi, wpisując na czacie /1, /2 itd.",
    "Czas podkładania i rozbrajania bomby jest krótszy o 20–60%, gdy Twoja drużyna może wykonać dany cel.",
    "Trafienie przeciwnika nożem natychmiast go zabija.",
    "Jesteś odporny na obrażenia od wybuchów.",
    "Trzymając nóż, masz 85% szans na zablokowanie trafienia pociskiem.",
    "Aktywuj, aby mocno wybić się do przodu. Odnowienie: 4 sekundy.",
    "Aktywuj, aby odwrócić sterowanie losowego przeciwnika na 10 sekund. Odnowienie: 15 sekund.",
    "Trafienie wroga ma 20–40% szans na podbicie go pionowo w górę.",
    "Aktywuj, aby postawić przed sobą replikę swojej postaci. Odbija obrażenia w atakującego. Odnowienie: 25 sekund.",
    "Teleportujesz się do pozycji sprzed 7 sekund. Odnowienie: 15 sekund.",
    "Aktywuj, aby wystrzelić linę w celowaną powierzchnię i przyciągnąć się do niej. Odnowienie: 5 sekund.",
    "Odradzasz się po swojej śmierci.",
    "Trafienie zatruwa wroga: 3 HP co 2,5 s. Kolejne trafienia zwiększają obrażenia trucizny o 3 HP. Trucizna nie zabija.",
    "Kradniesz przeciwnikowi $10 za każdy zadany mu punkt obrażeń.",
    "Trafienia z broni palnej i noża zadają podwójne obrażenia, gdy atakujesz przeciwnika od tyłu.",
    "Brak podrzutu kamery podczas strzelania.",
    "Aktywuj, aby postawić przed sobą drewnianą ścianę. Odnowienie: 5 sekund.",
    "Aktywuj, aby umieścić działko laserowe atakujące pobliskich wrogów. Tesla: 350 HP / 15–25 DMG. Odnowienie: 5 sekund.",
    "Nie otrzymujesz obrażeń od upadku.",
    "Aktywuj, aby zamienić się aktualnie trzymaną bronią z losowym przeciwnikiem. Odnowienie: 20 sekund.",
    "Zabity przeciwnik, upuszcza prezent dla Twojej drużyny. Naciśnij „E”, celując w prezent, aby go otworzyć.",
    "Wybierz przeciwnika, któremu zablokujesz możliwość skakania do końca rundy, wpisując na czacie /1, /2 itd.",
    "Trafienie przeciwnika ma 20–40% szansy na kradzież jego zapasowej amunicji.",
    "Masz pięć min na rundę które eksplodują, gdy przeciwnik wejdzie w ich zasięg. Odnowienie: 5 sekund.",
    "Przejmujesz supermoc pierwszego sojusznika, który zginie w tej rundzie.",
    "Trafieni wrogowie poruszają się o 50% wolniej i zadają 75% mniej obrażeń przez 4 sekundy.",
    "Twój model jest powiększony (zakres: x1,10–x1,40) i zyskujesz dodatkowe HP za rozmiar.",
    "Aktywuj, aby zabrać losowemu przeciwnikowi całej zapasowej amunicji w aktualnie trzymanej broni. Odnowienie: 20 sekund.",
    "Aktywuj, aby zadać 25 DMG wszystkim przeciwnikom. Odnowienie: 30 sekund.",
    "Wybierz przeciwnika który dostanie efekt przyciemniania, wpisując na czacie /1, /2 itd.",
    "Regeneracja poniżej 125 HP. Przywracasz +50 HP sojusznikom, maksymalnie do 100 HP. Odnowienie: 5 sekund.",
    "Teleportujesz się w obszar wybuchu Twojego granatu odłamkowego.",
    "Masz 50% szansy aby odzyskać użyty granat.",
    "Trafienie ma x szansy na oślepienie przeciwnika. (zakres: 15-30%).",
    "Otrzymujesz +100 HP za zabójstwo przeciwnika.",
    "Możesz włączyć tryb obserwatora na 5 sekund. Odnowienie: 25 sekund po zakończeniu.",
    "Twój granat odłamkowy zadaje 1.5x więcej obrażeń w trzykrotnie większym zasięgu."
};

int g_iCachedClientUserId[MAXPLAYERS + 1];
bool g_bObserverRosterRefreshQueued[MAXPLAYERS + 1];
// Bunny temporarily raises only the owner's per-player maxspeed for the jump command,
// bypassing CS:S's 1.1x bunny-jump clamp without touching global server ConVars.
bool g_bBunnyMaxSpeedOverride[MAXPLAYERS + 1];
float g_fBunnyOriginalMaxSpeed[MAXPLAYERS + 1];
RSPPower g_iPower[MAXPLAYERS + 1];
int g_iAssignedRound[MAXPLAYERS + 1];
int g_iRoundSerial;
// Ragdolls detached before RSP respawns. Indexed by current edict slot, values are serial-safe entity refs.
// A detached ragdoll is no longer reachable through the player's m_hRagdoll, so RSP owns its round-boundary cleanup.
int g_iPreservedRagdollRefByEntity[RSP_MAX_ENTITIES];

// Defensive follow-up for Steel Head: some weapon/damage paths or other hooks can
// reintroduce damage after TraceAttack. Correlate the immediate TakeDamage callback
// with the same victim/attacker and clear the transient state next frame.

bool g_bEnabled;
bool g_bSupportedMap;
int g_iExplodingBarrelModelIndex;
int g_iBuilderFenceModelIndex;
int g_iInventorTurretModelIndex;
int g_iTeslaMainBeamModelIndex = -1;
int g_iTeslaImpactSpriteModelIndex = -1;
bool g_bRoundReady;
// Temporary logical test-round state for the listen-server host when no real round exists.
bool g_bHostPowerGrantedOutsideRound[MAXPLAYERS + 1];
bool g_bRoundEnding;
bool g_bRoundFreezeEnded;
// A native team-elimination termination was held because that eliminated team had a respawn pending.
// Keep it armed through a successful respawn so a later death cannot leave the round stuck.
bool g_bDeferredEliminationWin[4];
int g_iDeferredEliminationRound[4];

// Stock CS:S player models. The player's actual team is never changed.
static const char g_sDisguiseCTModels[4][64] =
{
    "models/player/ct_urban.mdl",
    "models/player/ct_gsg9.mdl",
    "models/player/ct_sas.mdl",
    "models/player/ct_gign.mdl"
};
static const char g_sDisguiseTModels[4][64] =
{
    "models/player/t_arctic.mdl",
    "models/player/t_guerilla.mdl",
    "models/player/t_leet.mdl",
    "models/player/t_phoenix.mdl"
};

// Stock CS:S/Source wood pieces used for brief physical debris when a Builder fence breaks.
static const char g_sBuilderDebrisModels[5][PLATFORM_MAX_PATH] =
{
    "models/props_debris/wood_board01a.mdl",
    "models/props_debris/wood_board02a.mdl",
    "models/props_debris/wood_board04a.mdl",
    "models/props_debris/wood_chunk01a.mdl",
    "models/props_debris/wood_chunk02a.mdl"
};

bool g_bGravityStateSaved[MAXPLAYERS + 1];
float g_fOldGravity[MAXPLAYERS + 1];
bool g_bOldGravityValid[MAXPLAYERS + 1];
float g_fLowGravityMultiplier[MAXPLAYERS + 1];
bool g_bMoveSpeedStateSaved[MAXPLAYERS + 1];
float g_fOldMoveSpeed[MAXPLAYERS + 1];
bool g_bOldMoveSpeedValid[MAXPLAYERS + 1];
int g_iOldRamboHealth[MAXPLAYERS + 1];
int g_iRamboRolledBonus[MAXPLAYERS + 1];
float g_fOldModelScale[MAXPLAYERS + 1];
bool g_bModelScaleStateSaved[MAXPLAYERS + 1];
bool g_bOldModelScaleValid[MAXPLAYERS + 1];
float g_fOldViewOffset[MAXPLAYERS + 1][3];
bool g_bOldViewOffsetValid[MAXPLAYERS + 1];
bool g_bOldViewOffsetWasDucked[MAXPLAYERS + 1];
float g_fSelfModelScaleRatio[MAXPLAYERS + 1];
float g_fGiantSelfScale[MAXPLAYERS + 1];
int g_iGiantOldMaxHealth[MAXPLAYERS + 1];
bool g_bGiantHealthStateSaved[MAXPLAYERS + 1];
float g_fOldCollisionMins[MAXPLAYERS + 1][3];
float g_fOldCollisionMaxs[MAXPLAYERS + 1][3];
bool g_bOldCollisionBoundsValid[MAXPLAYERS + 1];
bool g_bDisguiseApplied[MAXPLAYERS + 1];
bool g_bDisguiseDeathTransition[MAXPLAYERS + 1];
float g_fDisguiseDeathTransitionUntil[MAXPLAYERS + 1];
char g_sDisguiseOriginalModel[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
bool g_bZombieUsedThisRound[MAXPLAYERS + 1];
bool g_bZombieRespawnPending[MAXPLAYERS + 1];
int g_iZombieRespawnRound[MAXPLAYERS + 1];
Handle g_hZombieRespawnTimer[MAXPLAYERS + 1];
float g_fNextSkillUseTime[MAXPLAYERS + 1];
float g_fReverseControlsUntil[MAXPLAYERS + 1];
int g_iReverseControlsRound[MAXPLAYERS + 1];
int g_iReverseControlsOwnerUserId[MAXPLAYERS + 1];
float g_fGhostDeathRevealUntil[MAXPLAYERS + 1];
bool g_bRagdollForcePending[MAXPLAYERS + 1];
bool g_bRagdollForceApplied[MAXPLAYERS + 1];
bool g_bRagdollForceHooked[MAXPLAYERS + 1];
bool g_bExecutionerSuicideFallbackPending[MAXPLAYERS + 1];
float g_fRagdollForceUntil[MAXPLAYERS + 1];
float g_fRagdollForceMultiplier[MAXPLAYERS + 1];
int g_iRagdollForceRound[MAXPLAYERS + 1];
float g_fRagdollForceDirection[MAXPLAYERS + 1][3];
Handle g_hInfiniteGrenadeRefillTimer[MAXPLAYERS + 1][RSP_GRENADE_TYPE_COUNT];
float g_fInfiniteGrenadeLastFireTime[MAXPLAYERS + 1][RSP_GRENADE_TYPE_COUNT];
float g_fGodModeUntil[MAXPLAYERS + 1];

int g_iZombieDroppedWeaponRefs[MAXPLAYERS + 1][RSP_ZOMBIE_DROPPED_WEAPONS];
int g_iZombieDroppedWeaponCount[MAXPLAYERS + 1];
Handle g_hZombieDroppedCleanupTimer[MAXPLAYERS + 1];
int g_iZombieDroppedCleanupAttempts[MAXPLAYERS + 1];

int g_iGhostEntityOwnerUserId[RSP_MAX_ENTITIES];
int g_iReplicaOwnerUserId[RSP_MAX_ENTITIES];
float g_fReplicaHealth[RSP_MAX_ENTITIES];
bool g_bReplicaPendingRemoval[RSP_MAX_ENTITIES];
int g_iBuildableOwnerUserId[RSP_MAX_ENTITIES];
int g_iBuildableType[RSP_MAX_ENTITIES];
float g_fBuildableHealth[RSP_MAX_ENTITIES];
int g_iBuildableLoopSoundRef[RSP_MAX_ENTITIES];
int g_iBuildableAntennaTeslaRef[RSP_MAX_ENTITIES];
float g_fBuildableYaw[RSP_MAX_ENTITIES];
float g_fBuildableBeamOffset[RSP_MAX_ENTITIES][3];
bool g_bBuildableBeamOffsetValid[RSP_MAX_ENTITIES];
int g_iInventorUsesThisRound[MAXPLAYERS + 1];
int g_iMinerUsesThisRound[MAXPLAYERS + 1];
int g_iExplodingBarrelsPlacedTowardCooldown[MAXPLAYERS + 1];
int g_iLeechChancePercent[MAXPLAYERS + 1];
int g_iGrounderRound[MAXPLAYERS + 1];
int g_iGrounderOwnerUserId[MAXPLAYERS + 1];
bool g_bGrounderUsedThisAssignment[MAXPLAYERS + 1];
bool g_bGiftUseWasDown[MAXPLAYERS + 1];
float g_fNextGiftUseTime[MAXPLAYERS + 1];
bool g_bAvengerConsumedThisRound[MAXPLAYERS + 1];
float g_fWeakeningUntil[MAXPLAYERS + 1];
int g_iWeakeningRound[MAXPLAYERS + 1];
int g_iWeakeningOwnerUserId[MAXPLAYERS + 1];
float g_fWeakeningBaseMovementValue[MAXPLAYERS + 1];
bool g_bWeakeningBaseMovementValid[MAXPLAYERS + 1];
bool g_bMagazineSystemDetected;
Handle g_hMinerCheckTimer;
int g_iGiftOwnerUserId[RSP_MAX_ENTITIES];
int g_iGiftTeam[RSP_MAX_ENTITIES];
int g_iMinerOwnerUserId[RSP_MAX_ENTITIES];
int g_iMinerTeam[RSP_MAX_ENTITIES];
int g_iMinerRound[RSP_MAX_ENTITIES];
bool g_bMinerDetonating[RSP_MAX_ENTITIES];
bool g_bMinerDiscoveredBy[RSP_MAX_ENTITIES][MAXPLAYERS + 1];
Handle g_hBuildableTurretTimer[RSP_MAX_ENTITIES];
float g_fArmouredDamageReduction[MAXPLAYERS + 1];
float g_fFrozenUntil[MAXPLAYERS + 1];
int g_iCryoOwnerUserId[MAXPLAYERS + 1];
float g_fNextDisorientTime[MAXPLAYERS + 1];
float g_fDisorientTargetYaw[MAXPLAYERS + 1];
float g_fDisorientViewUntil[MAXPLAYERS + 1];
int g_iDisorientOwnerUserId[MAXPLAYERS + 1];
int g_iCryoChancePercent[MAXPLAYERS + 1];
int g_iDisorientChancePercent[MAXPLAYERS + 1];
int g_iConcussionChancePercent[MAXPLAYERS + 1];
float g_fConcussionDspUntil[MAXPLAYERS + 1];
int g_iConcussionDspEffect[MAXPLAYERS + 1];
int g_iSpectatorSavedVoiceFlags[MAXPLAYERS + 1];
bool g_bSpectatorVoiceFlagsSaved[MAXPLAYERS + 1];
Handle g_hReclaimerRefillTimer[MAXPLAYERS + 1][RSP_GRENADE_TYPE_COUNT];
bool g_bSpectatorActive[MAXPLAYERS + 1];
Handle g_hSpectatorTimer[MAXPLAYERS + 1];
float g_fSpectatorOrigin[MAXPLAYERS + 1][3];
float g_fSpectatorAngles[MAXPLAYERS + 1][3];
int g_iSpectatorOldMoveType[MAXPLAYERS + 1];
int g_iSpectatorOldRenderMode[MAXPLAYERS + 1];
int g_iSpectatorOldRenderColor[MAXPLAYERS + 1][4];
bool g_bSpectatorOldDrawViewModelValid[MAXPLAYERS + 1];
int g_iSpectatorOldDrawViewModel[MAXPLAYERS + 1];
int g_iSpectatorWeaponRefs[MAXPLAYERS + 1][5];
int g_iSpectatorWeaponRenderMode[MAXPLAYERS + 1][5];
int g_iSpectatorWeaponRenderColor[MAXPLAYERS + 1][5][4];
int g_iVampirismDamageAttackerUserId[MAXPLAYERS + 1];
int g_iVampirismHealthBeforeDamage[MAXPLAYERS + 1];
int g_iVampirismDamageRound[MAXPLAYERS + 1];
float g_fVampirismHealRemainder[MAXPLAYERS + 1];
float g_fDoubleJumpReadyTime[MAXPLAYERS + 1];
bool g_bDoubleJumpWasDown[MAXPLAYERS + 1];

float g_fReviverNextUseTime[MAXPLAYERS + 1];
int g_iMedicCharges[MAXPLAYERS + 1];
Handle g_hReviverReadyTimer[MAXPLAYERS + 1];
Handle g_hSkillReadyTimer[MAXPLAYERS + 1];
int g_iReviverOwnerUserId[MAXPLAYERS + 1];
bool g_bPhoenixUsedThisRound[MAXPLAYERS + 1];
bool g_bResurrectionUsedThisRound[MAXPLAYERS + 1];

bool g_bHookActive[MAXPLAYERS + 1];
Handle g_hHookTimer[MAXPLAYERS + 1];
float g_fHookAnchor[MAXPLAYERS + 1][3];
float g_fHookLastDistance[MAXPLAYERS + 1];
float g_fHookLastProgressTime[MAXPLAYERS + 1];
int g_iHookBeamModel;
float g_fAnomalyHistoryTime[MAXPLAYERS + 1][RSP_ANOMALY_HISTORY_SAMPLES];
float g_fAnomalyHistoryOrigin[MAXPLAYERS + 1][RSP_ANOMALY_HISTORY_SAMPLES][3];
float g_fAnomalyHistoryAngles[MAXPLAYERS + 1][RSP_ANOMALY_HISTORY_SAMPLES][3];
int g_iAnomalyHistoryWriteIndex[MAXPLAYERS + 1];
float g_fAnomalyLastRecordTime[MAXPLAYERS + 1];

// Gambler: three distinct, pre-rolled offers. Variable values shown in chat are reused
// unchanged when the player selects that offer.
#define RSP_GAMBLER_OPTIONS 3
RSPPower g_eGamblerOffers[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
bool g_bGamblerPendingSelection[MAXPLAYERS + 1];
bool g_bGamblerChatIntercept[MAXPLAYERS + 1];
bool g_bGamblerApplyingChoice[MAXPLAYERS + 1];
int g_iGamblerSelectedOfferIndex[MAXPLAYERS + 1];
int g_iGamblerRamboBonus[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
int g_iGamblerRichBoyBonus[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
float g_fGamblerLowGravity[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
float g_fGamblerSpeedBonus[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
int g_iGamblerDisarmChance[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
int g_iGamblerLeechChance[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
float g_fGamblerModelScale[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
float g_fGamblerArmouredReduction[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
float g_fGamblerRapidFireMultiplier[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
int g_iGamblerCryoChance[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
int g_iGamblerDisorientChance[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];
int g_iGamblerKnockupChance[MAXPLAYERS + 1][RSP_GAMBLER_OPTIONS];

// Curser missed-shot team state and knife timing.
// Curser affects one selected enemy until that target dies or the round resets.
bool g_bCurserTargetCursed[MAXPLAYERS + 1];
int g_iCurserTargetCurseRound[MAXPLAYERS + 1];
int g_iCurserOwnerUserId[MAXPLAYERS + 1];

// Blackout is stored on the affected target and lasts until target death or round reset.
bool g_bBlackoutActive[MAXPLAYERS + 1];
bool g_bBlackoutUsedThisAssignment[MAXPLAYERS + 1];
int g_iBlackoutRound[MAXPLAYERS + 1];
Handle g_hBlackoutRefadeTimer[MAXPLAYERS + 1];

// Healing Angel's owner-health cap is temporary and restores the previous max-health state on reset.
float g_fHealingAngelNextUseTime[MAXPLAYERS + 1];
int g_iHealingAngelOldMaxHealth[MAXPLAYERS + 1];
bool g_bHealingAngelMaxHealthStateSaved[MAXPLAYERS + 1];

#define RSP_TARGET_SELECT_NONE 0
#define RSP_TARGET_SELECT_THIEF 1
#define RSP_TARGET_SELECT_CURSER 2
#define RSP_TARGET_SELECT_BANKRUPT 3
#define RSP_TARGET_SELECT_EXTORTION 4
#define RSP_TARGET_SELECT_DUPLICATOR 5
#define RSP_TARGET_SELECT_HACKER 6
#define RSP_TARGET_SELECT_SCIENTIST 7
#define RSP_TARGET_SELECT_GROUNDER 8
#define RSP_TARGET_SELECT_BLACKOUT 9
enum RSPTargetNotice
{
    RSP_NOTICE_BANKRUPT = 0,
    RSP_NOTICE_EXTORTION,
    RSP_NOTICE_HACKER,
    RSP_NOTICE_HACKER_PARTIAL,
    RSP_NOTICE_THIEF,
    RSP_NOTICE_DUPLICATOR,
    RSP_NOTICE_CURSER,
    RSP_NOTICE_SCIENTIST,
    RSP_NOTICE_BLACKOUT,
    RSP_NOTICE_GROUNDER,
    RSP_NOTICE_WEAPON_SWAP
};
int g_iExplosiveBulletsChancePercent[MAXPLAYERS + 1];
int g_iPowerNoticeGeneration[MAXPLAYERS + 1];
// Last server tick in which this client's Explosive Bullets impact was handled.
int g_iExplosiveBulletLastImpactTick[MAXPLAYERS + 1];
int g_iKnockupChancePercent[MAXPLAYERS + 1];
bool g_bExplosiveBulletDamageInProgress[MAXPLAYERS + 1];
bool g_bExplosiveBulletDeathPending[MAXPLAYERS + 1];
int g_iExplosiveBulletDeathOwnerUserId[MAXPLAYERS + 1];
int g_iExplosiveBulletDeathRound[MAXPLAYERS + 1];
int g_iExpensiveAmmoOwnerUserId[MAXPLAYERS + 1];
int g_iExpensiveAmmoRound[MAXPLAYERS + 1];
int g_iExpensiveAmmoPendingShots[MAXPLAYERS + 1];
bool g_bExpensiveAmmoFrameQueued[MAXPLAYERS + 1];
int g_iExpensiveAmmoShotTick[MAXPLAYERS + 1];
// Toxic Ammo is target-side and round-scoped. It deliberately stores no shooter handle,
// so a poison effect survives its source player's death or disconnect.
Handle g_hToxicAmmoTimer[MAXPLAYERS + 1];
bool g_bToxicAmmoActive[MAXPLAYERS + 1];
int g_iToxicAmmoRound[MAXPLAYERS + 1];
int g_iToxicAmmoStacks[MAXPLAYERS + 1];
int g_iLastFriendlyTraceTick[MAXPLAYERS + 1];
int g_iHackerOwnerUserId[MAXPLAYERS + 1];
int g_iHackerRound[MAXPLAYERS + 1];
// CS:S suppresses its radar panel while the player is in a flash state.
// Hacker uses a near-transparent server-side flash state and re-applies it after real flashes.
bool g_bHackerRadarFlashStateSaved[MAXPLAYERS + 1];
bool g_bHackerRadarFlashOverrideActive[MAXPLAYERS + 1];
float g_fHackerOriginalFlashDuration[MAXPLAYERS + 1];
float g_fHackerOriginalFlashMaxAlpha[MAXPLAYERS + 1];
float g_fHackerRealFlashUntil[MAXPLAYERS + 1];
Handle g_hHackerRadarReapplyTimer[MAXPLAYERS + 1];
int g_iHackerRadarPendingOwnerUserId[MAXPLAYERS + 1];
bool g_bGiantEffectActive[MAXPLAYERS + 1];
int g_iGiantOwnerUserId[MAXPLAYERS + 1];
float g_fGiantOldScale[MAXPLAYERS + 1];
int g_iSapperSpeedPercent[MAXPLAYERS + 1];
bool g_bSapperPlantAnimationActive[MAXPLAYERS + 1];
int g_iSapperViewModelRef[MAXPLAYERS + 1];
bool g_bSapperViewModelRateSaved[MAXPLAYERS + 1];
float g_fSapperViewModelOriginalRate[MAXPLAYERS + 1];
bool g_bSapperPlayerRateSaved[MAXPLAYERS + 1];
float g_fSapperPlayerOriginalRate[MAXPLAYERS + 1];
int g_iMachetePendingAttackerUserId[MAXPLAYERS + 1];
int g_iMachetePendingRound[MAXPLAYERS + 1];
int g_iExplosiveBulletSprite = -1;
int g_iExplosiveBulletDecal = -1;
int g_iTargetSelectionType[MAXPLAYERS + 1];
bool g_bTargetSelectionPending[MAXPLAYERS + 1];
bool g_bTargetSelectionForceDisplay[MAXPLAYERS + 1];
Handle g_hTargetSelectionBuildTimer[MAXPLAYERS + 1];
bool g_bTargetSelectionInitialized[MAXPLAYERS + 1];
int g_iTargetSelectionCount[MAXPLAYERS + 1];
RSPPower g_eTargetSelectionPowerSnapshot[MAXPLAYERS + 1][MAXPLAYERS + 1];
int g_iTargetSelectionTeamSnapshot[MAXPLAYERS + 1][MAXPLAYERS + 1];
int g_iTargetSelectionRound[MAXPLAYERS + 1];
int g_iTargetSelectionUserIds[MAXPLAYERS + 1][MAXPLAYERS + 1];

// During a theft, ApplyPower reads the target's current rolled parameters before the source loses its power.
bool g_bThiefApplyingStolenPower[MAXPLAYERS + 1];
int g_iThiefSourceUserId[MAXPLAYERS + 1];
RSPPower g_eThiefSourcePower[MAXPLAYERS + 1];
float g_fSoldierDamageMultiplier[MAXPLAYERS + 1];
int g_iCurserEnemyHitCounter[MAXPLAYERS + 1];
int g_iCurserResolvedEnemyHitCounter[MAXPLAYERS + 1];

bool g_bThornsDamagePending[MAXPLAYERS + 1];
int g_iThornsAttackerUserId[MAXPLAYERS + 1];
int g_iThornsHealthBeforeDamage[MAXPLAYERS + 1];
int g_iThornsDamageRound[MAXPLAYERS + 1];
int g_iThornsInflictorRef[MAXPLAYERS + 1];
float g_fThornsReflectRemainder[MAXPLAYERS + 1];
bool g_bThornsReflectedDeathPending[MAXPLAYERS + 1];
int g_iThornsReflectedOwnerUserId[MAXPLAYERS + 1];
int g_iThornsReflectedDeathRound[MAXPLAYERS + 1];
int g_iThornsReflectedOwnerCashBefore[MAXPLAYERS + 1];
bool g_bApplyingThornsDamage;

// Damager death attribution is victim-scoped; kill cash is batched per activation so
// multi-kills award exactly $300 per victim instead of inheriting held-weapon rewards.
bool g_bDamagerDeathPending[MAXPLAYERS + 1];
int g_iDamagerDeathOwnerUserId[MAXPLAYERS + 1];
int g_iDamagerDeathRound[MAXPLAYERS + 1];
int g_iDamagerCashOwnerUserId[MAXPLAYERS + 1];
int g_iDamagerCashBefore[MAXPLAYERS + 1];
int g_iDamagerCashRound[MAXPLAYERS + 1];
int g_iDamagerKillCount[MAXPLAYERS + 1];
bool g_bDamagerCashCorrectionQueued[MAXPLAYERS + 1];

bool g_bNoclipActive[MAXPLAYERS + 1];
bool g_bNoclipWindowOpen[MAXPLAYERS + 1];
bool g_bNoclipDamageRestoreQueued[MAXPLAYERS + 1];
float g_fNoclipExpiresAt[MAXPLAYERS + 1];
float g_fNoclipNextSafeCheckTime[MAXPLAYERS + 1];
int g_iNoclipOldMoveType[MAXPLAYERS + 1];
Handle g_hNoclipTimer[MAXPLAYERS + 1];
bool g_bNoclipLastSafeValid[MAXPLAYERS + 1];
float g_fNoclipLastSafeOrigin[MAXPLAYERS + 1][3];

bool g_bPowerRespawnPending[MAXPLAYERS + 1];
int g_iPowerRespawnRound[MAXPLAYERS + 1];
int g_iPowerRespawnAttempts[MAXPLAYERS + 1];
int g_iPowerRespawnKind[MAXPLAYERS + 1];
Handle g_hPowerRespawnTimer[MAXPLAYERS + 1];

bool g_bDeathExplosionPending[MAXPLAYERS + 1];
int g_iDeathExplosionOwnerTeam[MAXPLAYERS + 1];
int g_iRSPDeathExplosionTeam[RSP_MAX_ENTITIES];
int g_iDeathExplosionOwnerUserId[MAXPLAYERS + 1];
int g_iDeathExplosionRound[MAXPLAYERS + 1];
float g_fDeathExplosionOrigin[MAXPLAYERS + 1][3];
bool g_bLastSmokeWasToxic[MAXPLAYERS + 1];
bool g_bLastSmokeWasHealing[MAXPLAYERS + 1];
float g_fLastSmokeThrowTime[MAXPLAYERS + 1];
int g_iLastSmokeThrowRound[MAXPLAYERS + 1];
int g_iLastSmokeThrowTeam[MAXPLAYERS + 1];

bool g_bToxicSmokeCloudActive[RSP_TOXIC_SMOKE_MAX_CLOUDS];
int g_iToxicSmokeCloudType[RSP_TOXIC_SMOKE_MAX_CLOUDS];
int g_iToxicSmokeCloudOwnerUserId[RSP_TOXIC_SMOKE_MAX_CLOUDS];
int g_iToxicSmokeCloudTeam[RSP_TOXIC_SMOKE_MAX_CLOUDS];
int g_iToxicSmokeCloudRound[RSP_TOXIC_SMOKE_MAX_CLOUDS];
float g_fToxicSmokeCloudOrigin[RSP_TOXIC_SMOKE_MAX_CLOUDS][3];
float g_fToxicSmokeCloudExpires[RSP_TOXIC_SMOKE_MAX_CLOUDS];
float g_fToxicSmokeCloudNextDamage[RSP_TOXIC_SMOKE_MAX_CLOUDS];
Handle g_hToxicSmokeTimer;
bool g_bToxicSmokeDeathPending[MAXPLAYERS + 1];
int g_iToxicSmokeDeathOwnerUserId[MAXPLAYERS + 1];
int g_iToxicSmokeDeathRound[MAXPLAYERS + 1];

float g_fSpeedBonus[MAXPLAYERS + 1];
float g_fRapidFireMultiplier[MAXPLAYERS + 1];
// Per-weapon Rapid Fire snapshots; only restore values still owned by this plugin.
float g_fRapidFireOriginalNextAttack[RSP_MAX_ENTITIES][2];
float g_fRapidFireAppliedNextAttack[RSP_MAX_ENTITIES][2];
bool g_bRapidFireAttackTracked[RSP_MAX_ENTITIES][2];
int g_iRapidFireOwnerUserId[RSP_MAX_ENTITIES];
int g_iRapidFireWeaponEntRef[RSP_MAX_ENTITIES];
bool g_bZombieCleanupQueued[MAXPLAYERS + 1];
int g_iZombieCleanupRound[MAXPLAYERS + 1];
int g_iZombieLoadoutRound[MAXPLAYERS + 1];
bool g_bZombieLoadoutApplying[MAXPLAYERS + 1];
float g_fZombieDropCleanupUntil[MAXPLAYERS + 1];
bool g_bGhostNeedsDefaultPistol[MAXPLAYERS + 1];
int g_iPistolRestoreAttempts[MAXPLAYERS + 1];
Handle g_hPistolRestoreTimer[MAXPLAYERS + 1];
int g_iLastFiredWeaponRef[MAXPLAYERS + 1];
int g_iDisarmChancePercent[MAXPLAYERS + 1];
int g_iRichBoyRolledBonus[MAXPLAYERS + 1];
bool g_bDisarmPending[MAXPLAYERS + 1];
int g_iPendingDropWeaponRef[MAXPLAYERS + 1];
Handle g_hRegenTimer[MAXPLAYERS + 1];

int g_iFlashOwnerUserId[RSP_FLASH_RECORDS];
int g_iFlashRound[RSP_FLASH_RECORDS];
float g_fFlashTime[RSP_FLASH_RECORDS];
float g_fFlashProDuration[RSP_FLASH_RECORDS];
float g_fFlashOrigin[RSP_FLASH_RECORDS][3];
int g_iFlashWriteIndex;
float g_fLastDeadlyFlashThrowTime[MAXPLAYERS + 1];
int g_iLastDeadlyFlashThrowRound[MAXPLAYERS + 1];
bool g_bDeadlyFlashForceKill[MAXPLAYERS + 1];
bool g_bLastFlashWasDeadly[MAXPLAYERS + 1];
bool g_bLastFlashWasLong[MAXPLAYERS + 1];
float g_fLastLongFlashThrowTime[MAXPLAYERS + 1];
int g_iLastLongFlashThrowRound[MAXPLAYERS + 1];
bool g_bHadDeadlyFlashThisRound[MAXPLAYERS + 1];
bool g_bLastHEWasExecutioner[MAXPLAYERS + 1];
bool g_bLastHEWasEnder[MAXPLAYERS + 1];
float g_fLastHEThrowTime[MAXPLAYERS + 1];
int g_iLastHERound[MAXPLAYERS + 1];
bool g_bFlashRecordDeadly[RSP_FLASH_RECORDS];
bool g_bFlashRecordLong[RSP_FLASH_RECORDS];
bool g_bFlashKillPending[MAXPLAYERS + 1];
bool g_bFlashKillFallback[MAXPLAYERS + 1];
int g_iFlashKillOwnerUserId[MAXPLAYERS + 1];
bool g_bFlashScoreRepairPending[MAXPLAYERS + 1];
int g_iFlashScoreRepairOwnerUserId[MAXPLAYERS + 1];
int g_iFlashScoreRepairVictimTeam[MAXPLAYERS + 1];
int g_iBurnOwnerUserId[MAXPLAYERS + 1];
int g_iBurnOwnerRound[MAXPLAYERS + 1];
float g_fBurnOwnerUntil[MAXPLAYERS + 1];
bool g_bIncendiaryArmorRestorePending[MAXPLAYERS + 1];
int g_iIncendiaryArmorRestoreValue[MAXPLAYERS + 1];
int g_iIncendiaryArmorRestoreRound[MAXPLAYERS + 1];
bool g_bAimbotArmorRestorePending[MAXPLAYERS + 1];
int g_iAimbotArmorRestoreValue[MAXPLAYERS + 1];
int g_iAimbotArmorRestoreRound[MAXPLAYERS + 1];
bool g_bBurnDeathPending[MAXPLAYERS + 1];
int g_iBurnDeathOwnerUserId[MAXPLAYERS + 1];
int g_iBurnDeathRound[MAXPLAYERS + 1];
bool g_bTeslaDeathDissolvePending[MAXPLAYERS + 1];
int g_iTeslaDeathDissolveRound[MAXPLAYERS + 1];
float g_fTeslaDeathDissolveTime[MAXPLAYERS + 1];
int g_iTeslaDeathOwnerUserId[MAXPLAYERS + 1];
int g_iTeslaDeathCashCandidateOwnerUserId[MAXPLAYERS + 1];
int g_iTeslaDeathCashCandidateRound[MAXPLAYERS + 1];
int g_iTeslaDeathCashBefore[MAXPLAYERS + 1];
int g_iTeslaCashOwnerUserId[MAXPLAYERS + 1];
int g_iTeslaCashBefore[MAXPLAYERS + 1];
int g_iTeslaCashRound[MAXPLAYERS + 1];
int g_iTeslaCashKillCount[MAXPLAYERS + 1];
bool g_bTeslaCashCorrectionQueued[MAXPLAYERS + 1];
bool g_bTeslaRagdollDirectionValid[MAXPLAYERS + 1];
float g_fTeslaRagdollDirection[MAXPLAYERS + 1][3];
bool g_bTeslaHeadshotPending[MAXPLAYERS + 1];
int g_iTeslaHeadshotRound[MAXPLAYERS + 1];
float g_fTeslaHeadshotTime[MAXPLAYERS + 1];
// Separate player_hurt hitgroup metadata from killfeed headshot attribution.
bool g_bTeslaHitFeedbackPending[MAXPLAYERS + 1];
int g_iTeslaHitFeedbackOwnerUserId[MAXPLAYERS + 1];
int g_iTeslaHitFeedbackRound[MAXPLAYERS + 1];
int g_iTeslaHitFeedbackHitgroup[MAXPLAYERS + 1];
int g_iTeslaHitFeedbackSerial[MAXPLAYERS + 1];
float g_fTeslaHitFeedbackTime[MAXPLAYERS + 1];
bool g_bBurnScoreRepairPending[MAXPLAYERS + 1];
int g_iBurnScoreRepairOwnerUserId[MAXPLAYERS + 1];
int g_iBurnScoreRepairVictimTeam[MAXPLAYERS + 1];
bool g_bBurnVictimWasSuicide[MAXPLAYERS + 1];
bool g_bExecutionerHEKillPending[MAXPLAYERS + 1];
int g_iExecutionerHEKillOwnerUserId[MAXPLAYERS + 1];
int g_iBlindCheckRound[MAXPLAYERS + 1];
Handle g_hBlindCheckTimer[MAXPLAYERS + 1];
Handle g_hLongFlashTimer[MAXPLAYERS + 1];
int g_iLongFlashCheckRound[MAXPLAYERS + 1];
int g_iLongFlashCheckAttempts[MAXPLAYERS + 1];
int g_iZombieRespawnAttempts[MAXPLAYERS + 1];
int g_iBlindCheckAttempts[MAXPLAYERS + 1];
int g_iExecutionerPendingAttackerUserId[MAXPLAYERS + 1];
// Each enemy gets an 8-point parented 3D box and 12 persistent env_beam edges.
// The 0.30-second timer only maintains the set; the engine moves the parented points continuously.
int g_iWallhackAnchorEntity[MAXPLAYERS + 1][8];
int g_iWallhackBeamEntity[MAXPLAYERS + 1][12];
int g_iWallhackMarkerTarget[RSP_MAX_ENTITIES];
int g_iWallhackBeamModel = 0;
bool g_bWallhackRefreshQueued;
static const int g_iWallhackEdges[12][2] =
{
    {0, 1}, {1, 2}, {2, 3}, {3, 0},
    {4, 5}, {5, 6}, {6, 7}, {7, 4},
    {0, 4}, {1, 5}, {2, 6}, {3, 7}
};
static const float g_fWallhackAnchorOffsets[8][3] =
{
    {-RSP_WALLHACK_HALF_WIDTH, -RSP_WALLHACK_HALF_WIDTH, RSP_WALLHACK_BOTTOM_OFFSET},
    { RSP_WALLHACK_HALF_WIDTH, -RSP_WALLHACK_HALF_WIDTH, RSP_WALLHACK_BOTTOM_OFFSET},
    { RSP_WALLHACK_HALF_WIDTH,  RSP_WALLHACK_HALF_WIDTH, RSP_WALLHACK_BOTTOM_OFFSET},
    {-RSP_WALLHACK_HALF_WIDTH,  RSP_WALLHACK_HALF_WIDTH, RSP_WALLHACK_BOTTOM_OFFSET},
    {-RSP_WALLHACK_HALF_WIDTH, -RSP_WALLHACK_HALF_WIDTH, RSP_WALLHACK_TOP_OFFSET},
    { RSP_WALLHACK_HALF_WIDTH, -RSP_WALLHACK_HALF_WIDTH, RSP_WALLHACK_TOP_OFFSET},
    { RSP_WALLHACK_HALF_WIDTH,  RSP_WALLHACK_HALF_WIDTH, RSP_WALLHACK_TOP_OFFSET},
    {-RSP_WALLHACK_HALF_WIDTH,  RSP_WALLHACK_HALF_WIDTH, RSP_WALLHACK_TOP_OFFSET}
};
int g_iFlashProjectileOwnerUserId[RSP_MAX_ENTITIES];
bool g_bFlashProjectileDeadly[RSP_MAX_ENTITIES];
bool g_bFlashProjectileLong[RSP_MAX_ENTITIES];
int g_iFlashProjectileRound[RSP_MAX_ENTITIES];
float g_fFlashProjectileSpawnTime[RSP_MAX_ENTITIES];
int g_iHEProjectileOwnerUserId[RSP_MAX_ENTITIES];
bool g_bHEProjectileDemolition[RSP_MAX_ENTITIES];
int g_iHEProjectileTeam[RSP_MAX_ENTITIES];
bool g_bHEProjectileExecutioner[RSP_MAX_ENTITIES];
bool g_bHEProjectileEnder[RSP_MAX_ENTITIES];
int g_iHEProjectileRound[RSP_MAX_ENTITIES];
float g_fHEProjectileSpawnTime[RSP_MAX_ENTITIES];
int g_iSmokeProjectileOwnerUserId[RSP_MAX_ENTITIES];
int g_iSmokeProjectileTeam[RSP_MAX_ENTITIES];
int g_iSmokeProjectileRound[RSP_MAX_ENTITIES];
int g_iSmokeProjectileType[RSP_MAX_ENTITIES];
float g_fSmokeProjectileSpawnTime[RSP_MAX_ENTITIES];

// Stock CS:S weapon-fire game-sound scripts indexed by Shotgun Shot m_iWeaponID.
Handle g_hGhostMaintenanceTimer;
Handle g_hWallhackRefreshTimer;
ConVar g_hMpFreezeTime;
ConVar g_hMpFriendlyFire;
ConVar g_hMpMaxMoney;
UserMsg g_umUpdateRadar;
bool g_bRadarHooked;
// Never start a usermessage from inside Hook_UpdateRadarMessage. The hook stores the
// newest filtered payload and emits at most one replacement per viewer per frame.
bool g_bRadarRewriteQueued[MAXPLAYERS + 1];
int g_iRadarQueuedCount[MAXPLAYERS + 1];
int g_iRadarQueuedIds[MAXPLAYERS + 1][MAXPLAYERS + 1];
int g_iRadarQueuedX[MAXPLAYERS + 1][MAXPLAYERS + 1];
int g_iRadarQueuedY[MAXPLAYERS + 1][MAXPLAYERS + 1];
int g_iRadarQueuedZ[MAXPLAYERS + 1][MAXPLAYERS + 1];
int g_iRadarQueuedYaw[MAXPLAYERS + 1][MAXPLAYERS + 1];

// Project credits:
// Author: PaK
// Testers & Contributors: Jesse James, ainnoway, BluMachinima, GhettoSensei, Laps
// Contributions: Gameplay testing, feedback, and ideas.
public Plugin myinfo =
{
    name = "[CS:S] Random Super Powers",
    author = "PaK",
    description = "Per-round random super powers for CS:S, including safe bind-activated abilities.",
    version = PLUGIN_VERSION,
    url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    MarkNativeAsOptional("CS2Mag_RemoveReserveMagazines");
    MarkNativeAsOptional("CS2Mag_TransferReserveMagazines");
    return APLRes_Success;
}

public void OnPluginStart()
{
    g_bMagazineSystemDetected = LibraryExists("cs2_magazine_system");
    RegAdminCmd("rsp_enable", Command_Enable, ADMFLAG_CONFIG, "Enable Random Super Powers on any map.");
    RegAdminCmd("rsp_disable", Command_Disable, ADMFLAG_CONFIG, "Disable Random Super Powers and restore player state.");
    RegAdminCmd("rsp_status", Command_Status, ADMFLAG_CONFIG, "Show Random Super Powers status.");
    // Listen-server host testing commands. Both handlers verify the local host by loopback IP;
    // they do not depend on SourceMod admin flags and are unavailable on dedicated servers.
    RegConsoleCmd("rsp_getpower", Command_GivePower,
        "Give the listen-server host a selected RSP power for testing.");
    RegConsoleCmd("rsp_givepower", Command_GivePowerToTarget,
        "Give a selected RSP power to a player by user ID or exact name.");
    RegConsoleCmd("rsp_givepowerall", Command_GivePowerAll,
        "Give the same selected RSP power to every living player (listen-server host only).");
    // Both command aliases share one dispatcher. The bare rsp_useskill alias is intended for direct binds; listen-server host client-index handling is resolved inside Command_UseSkill.
    RegConsoleCmd("sm_rsp_useskill", Command_UseSkill, "Activate a bound RSP power.");
    RegConsoleCmd("rsp_useskill", Command_UseSkill, "Activate a bound RSP power (bare bind alias).");
    RegConsoleCmd("rsp_powerslist", Command_PowersList, "List active RSP powers alphabetically in console.");
    AddCommandListener(Command_GamblerChat, "say");
    AddCommandListener(Command_GamblerChat, "say_team");
    AddCommandListener(Command_BlockSpectatorInput, "radio1");
    AddCommandListener(Command_BlockSpectatorInput, "radio2");
    AddCommandListener(Command_BlockSpectatorInput, "radio3");
    AddCommandListener(Command_BlockSpectatorInput, "messagemode");
    AddCommandListener(Command_BlockSpectatorInput, "messagemode2");
    AddCommandListener(Command_BlockSpectatorInput, "+voicerecord");
    AddCommandListener(Command_BlockSpectatorInput, "coverme");
    AddCommandListener(Command_BlockSpectatorInput, "takepoint");
    AddCommandListener(Command_BlockSpectatorInput, "holdpos");
    AddCommandListener(Command_BlockSpectatorInput, "regroup");
    AddCommandListener(Command_BlockSpectatorInput, "followme");
    AddCommandListener(Command_BlockSpectatorInput, "takingfire");
    AddCommandListener(Command_BlockSpectatorInput, "go");
    AddCommandListener(Command_BlockSpectatorInput, "fallback");
    AddCommandListener(Command_BlockSpectatorInput, "sticktog");
    AddCommandListener(Command_BlockSpectatorInput, "report");
    AddCommandListener(Command_BlockSpectatorInput, "roger");
    AddCommandListener(Command_BlockSpectatorInput, "enemyspot");
    AddCommandListener(Command_BlockSpectatorInput, "needbackup");
    AddCommandListener(Command_BlockSpectatorInput, "sectorclear");
    AddCommandListener(Command_BlockSpectatorInput, "inposition");
    AddCommandListener(Command_BlockSpectatorInput, "reportingin");
    AddCommandListener(Command_BlockSpectatorInput, "getout");
    AddCommandListener(Command_BlockSpectatorInput, "negative");
    AddCommandListener(Command_BlockSpectatorInput, "enemydown");
    AddCommandListener(Command_BlockSpectatorInput, "buy");
    AddCommandListener(Command_BlockSpectatorInput, "buyequip");
    AddCommandListener(Command_BlockSpectatorInput, "autobuy");
    AddCommandListener(Command_BlockSpectatorInput, "rebuy");
    AddCommandListener(Command_BlockSpectatorInput, "buyammo1");
    AddCommandListener(Command_BlockSpectatorInput, "buyammo2");
    AddCommandListener(Command_BlockSpectatorInput, "chooseteam");
    AddCommandListener(Command_BlockSpectatorInput, "jointeam");
    AddCommandListener(Command_BlockSpectatorInput, "joinclass");
    AddCommandListener(Command_BlockSpectatorInput, "menuselect");
    AddCommandListener(Command_BlockSpectatorInput, "callvote");
    AddCommandListener(Command_BlockSpectatorInput, "vote");
    AddCommandListener(Command_BlockSpectatorInput, "voteyes");
    AddCommandListener(Command_BlockSpectatorInput, "voteno");
    AddNormalSoundHook(Hook_RSPNormalSound);
    AddCommandListener(Command_BlockSpectatorInput, "drop");
    AddCommandListener(Command_BlockSpectatorInput, "nightvision");
    AddCommandListener(Command_BlockSpectatorInput, "use");
    AddCommandListener(Command_BlockSpectatorInput, "invnext");
    AddCommandListener(Command_BlockSpectatorInput, "invprev");
    AddCommandListener(Command_BlockSpectatorInput, "lastinv");
    AddCommandListener(Command_BlockSpectatorInput, "slot1");
    AddCommandListener(Command_BlockSpectatorInput, "slot2");
    AddCommandListener(Command_BlockSpectatorInput, "slot3");
    AddCommandListener(Command_BlockSpectatorInput, "slot4");
    AddCommandListener(Command_BlockSpectatorInput, "slot5");
    AddCommandListener(Command_BlockSpectatorInput, "slot6");
    g_hMpFreezeTime = FindConVar("mp_freezetime");
    g_hMpFriendlyFire = FindConVar("mp_friendlyfire");
    g_hMpMaxMoney = FindConVar("mp_maxmoney");
    HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
    HookEventEx("round_freeze_end", Event_RoundFreezeEnd, EventHookMode_Post);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_Post);
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
    HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
    HookEvent("player_team", Event_PlayerTeam, EventHookMode_Post);
    HookEvent("flashbang_detonate", Event_FlashbangDetonate, EventHookMode_Post);
    HookEvent("hegrenade_detonate", Event_HEGrenadeDetonate, EventHookMode_Post);
    HookEvent("smokegrenade_detonate", Event_SmokeGrenadeDetonate, EventHookMode_Post);
    HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Post);
    HookEvent("bullet_impact", Event_BulletImpact, EventHookMode_Post);
    HookEvent("player_blind", Event_PlayerBlind, EventHookMode_Post);
    HookEventEx("bomb_beginplant", Event_BombBeginPlant, EventHookMode_Post);
    HookEventEx("bomb_abortplant", Event_BombAbortPlant, EventHookMode_Post);
    HookEventEx("bomb_planted", Event_BombPlanted, EventHookMode_Post);
    HookEventEx("bomb_begindefuse", Event_BombBeginDefuse, EventHookMode_Post);

    g_iBuilderFenceModelIndex = PrecacheModel(RSP_BUILDER_FENCE_MODEL, true);
    g_iInventorTurretModelIndex = PrecacheModel(RSP_INVENTOR_TURRET_MODEL, true);
    PrecacheModel(RSP_LOOTBOX_MODEL, true);
    PrecacheModel("models/props_combine/combine_mine01.mdl", true);
    PrecacheSound("items/itempickup.wav", true);
    for (int debrisIndex = 0; debrisIndex < sizeof(g_sBuilderDebrisModels); debrisIndex++)
    {
        PrecacheModel(g_sBuilderDebrisModels[debrisIndex], true);
    }
    PrecacheSound(RSP_INVENTOR_TURRET_LOOP_SOUND, true);
    PrecacheSound(RSP_INVENTOR_TURRET_SHOT_SOUND, true);
    PrecacheSound(RSP_INVENTOR_TURRET_EXPLOSION_SOUND, true);
    PrecacheScriptSound("Player.DamageHeadShot");
    PrecacheScriptSound("Player.DamageHelmet");
    g_iHookBeamModel = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    PrecacheModel("sprites/laserbeam.vmt", true);
    g_iTeslaMainBeamModelIndex = PrecacheModel("materials/sprites/physbeam.vmt", true);
    g_iTeslaImpactSpriteModelIndex = PrecacheModel(RSP_INVENTOR_TURRET_IMPACT_SPRITE, true);
    g_iExplosiveBulletSprite = PrecacheModel("sprites/zerogxplode.spr", true);
    g_iExplosiveBulletDecal = PrecacheDecal(RSP_EXPLOSIVE_AMMO_DECAL, true);
    PrecacheSound(RSP_EXPLOSIVE_AMMO_SOUND_1, true);
    PrecacheSound(RSP_EXPLOSIVE_AMMO_SOUND_2, true);
    PrecacheSound(RSP_EXPLOSIVE_AMMO_SOUND_3, true);
    TryHookRadarMessage();

    for (int client = 1; client <= MaxClients; client++)
    {
        ResetClientData(client);
        if (IsClientInGame(client))
        {
            HookClient(client);
        }
    }

    DetectCurrentMap();

}

public void OnMapStart()
{
    g_iBuilderFenceModelIndex = PrecacheModel(RSP_BUILDER_FENCE_MODEL, true);
    g_iInventorTurretModelIndex = PrecacheModel(RSP_INVENTOR_TURRET_MODEL, true);
    PrecacheModel(RSP_LOOTBOX_MODEL, true);
    PrecacheModel("models/props_combine/combine_mine01.mdl", true);
    PrecacheSound("items/itempickup.wav", true);
    for (int debrisIndex = 0; debrisIndex < sizeof(g_sBuilderDebrisModels); debrisIndex++)
    {
        PrecacheModel(g_sBuilderDebrisModels[debrisIndex], true);
    }
    PrecacheSound(RSP_INVENTOR_TURRET_LOOP_SOUND, true);
    PrecacheSound(RSP_INVENTOR_TURRET_SHOT_SOUND, true);
    PrecacheSound(RSP_INVENTOR_TURRET_EXPLOSION_SOUND, true);
    PrecacheScriptSound("Player.DamageHeadShot");
    PrecacheScriptSound("Player.DamageHelmet");
    ClearDeferredEliminationState();
    ClearToxicSmokeClouds();
    ClearIncendiaryTracking();
    StopGhostMaintenanceTimer();
    StopWallhackTimer();
    TryHookRadarMessage();
    PrecacheDisguiseModels();
    g_iHookBeamModel = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    PrecacheModel("sprites/laserbeam.vmt", true);
    g_iTeslaMainBeamModelIndex = PrecacheModel("materials/sprites/physbeam.vmt", true);
    g_iTeslaImpactSpriteModelIndex = PrecacheModel(RSP_INVENTOR_TURRET_IMPACT_SPRITE, true);
    g_iExplosiveBulletSprite = PrecacheModel("sprites/zerogxplode.spr", true);
    g_iExplosiveBulletDecal = PrecacheDecal(RSP_EXPLOSIVE_AMMO_DECAL, true);
    PrecacheSound(RSP_EXPLOSIVE_AMMO_SOUND_1, true);
    PrecacheSound(RSP_EXPLOSIVE_AMMO_SOUND_2, true);
    PrecacheSound(RSP_EXPLOSIVE_AMMO_SOUND_3, true);
    g_iExplodingBarrelModelIndex = PrecacheModel(RSP_EXPLODING_BARREL_MODEL, true);
    for (int client = 1; client <= MaxClients; client++)
    {
        StopClientPistolRestoreTimer(client);
    }
    // If freeze time is configured to zero, do not depend on round_freeze_end firing.
    g_bRoundFreezeEnded = (g_hMpFreezeTime != null && g_hMpFreezeTime.FloatValue <= 0.0);
    for (int target = 1; target <= MaxClients; target++)
    {
        g_bCurserTargetCursed[target] = false;
        g_iCurserTargetCurseRound[target] = 0;
        g_iCurserOwnerUserId[target] = 0;
    }
    for (int client = 1; client <= MaxClients; client++)
    {
        g_iCurserEnemyHitCounter[client] = 0;
        g_iCurserResolvedEnemyHitCounter[client] = 0;
        g_bGamblerPendingSelection[client] = false;
        g_bGamblerChatIntercept[client] = false;
        g_bGamblerApplyingChoice[client] = false;
        g_iGamblerSelectedOfferIndex[client] = -1;
    }
    g_bWallhackRefreshQueued = false;
    g_iWallhackBeamModel = 0;
    if (FileExists(RSP_WALLHACK_BEAM_VMT))
    {
        AddFileToDownloadsTable(RSP_WALLHACK_BEAM_VMT);
        if (FileExists(RSP_WALLHACK_BEAM_VTF))
        {
            AddFileToDownloadsTable(RSP_WALLHACK_BEAM_VTF);
        }
        g_iWallhackBeamModel = PrecacheModel(RSP_WALLHACK_BEAM_VMT, true);
    }
    g_bRoundReady = false;
    g_bRoundEnding = false;
    g_iRoundSerial = 0;
    g_iFlashWriteIndex = 0;
    DetectCurrentMap();

    for (int client = 1; client <= MaxClients; client++)
    {
        g_bResurrectionUsedThisRound[client] = false;
        StopHook(client);
        ClearAnomalyHistory(client);
        g_bRadarRewriteQueued[client] = false;
        g_iRadarQueuedCount[client] = 0;
        if (IsClientInGame(client))
        {
            ResetClientPower(client, true);
        }
        g_iAssignedRound[client] = 0;
        g_fZombieDropCleanupUntil[client] = 0.0;
        g_iBlindCheckRound[client] = 0;
        g_iBlindCheckAttempts[client] = 0;
        g_iExecutionerPendingAttackerUserId[client] = 0;
    }

    ClearFlashRecords();
    ClearVisualTracking();

}

public void OnMapEnd()
{
    ClearAllToxicAmmoEffects();
    ClearDeferredEliminationState();
    ClearToxicSmokeClouds();
    ClearIncendiaryTracking();
    StopGhostMaintenanceTimer();
    StopWallhackTimer();
    g_bRoundEnding = false;
    g_bRoundReady = false;
    ClearAllReplicaEntities();
    ClearAllBuildables();
    ClearAllGiftEntities();
    ClearAllMinerMines();
    ResetAllClientPowers(true);
    for (int client = 1; client <= MaxClients; client++)
    {
        StopClientPistolRestoreTimer(client);
        if (IsClientInGame(client))
        {
            g_fFrozenUntil[client] = 0.0;
            UpdateRSPTemporaryVoiceMute(client);
            if (g_fConcussionDspUntil[client] > 0.0)
                ClientCommand(client, "dsp_player 0");
        }
        g_fConcussionDspUntil[client] = 0.0;
        g_iConcussionDspEffect[client] = 0;
        // TIMER_FLAG_NO_MAPCHANGE cancels queued observer roster timers automatically.
        // Clear the debounce marker as well so it cannot survive onto the next map.
        g_bObserverRosterRefreshQueued[client] = false;
    }
    ClearFlashRecords();
    ClearVisualTracking();
}

public void OnPluginEnd()
{
    RemoveNormalSoundHook(Hook_RSPNormalSound);
    ClearAllToxicAmmoEffects();
    // Detached ragdolls are no longer associated with a player's m_hRagdoll handle.
    // Remove them on unload/reload to avoid orphaned corpses lingering across plugin lifecycle.
    ClearPreservedRagdolls();
    ClearDeferredEliminationState();
    ClearToxicSmokeClouds();
    ClearIncendiaryTracking();
    StopGhostMaintenanceTimer();
    StopWallhackTimer();
    g_bRoundEnding = false;
    g_bRoundReady = false;
    ClearAllReplicaEntities();
    ClearAllBuildables();
    ClearAllGiftEntities();
    ClearAllMinerMines();
    ResetAllClientPowers(true);
    for (int client = 1; client <= MaxClients; client++)
    {
        StopClientPistolRestoreTimer(client);
        if (IsClientInGame(client))
        {
            g_fFrozenUntil[client] = 0.0;
            UpdateRSPTemporaryVoiceMute(client);
            if (g_fConcussionDspUntil[client] > 0.0)
                ClientCommand(client, "dsp_player 0");
        }
        g_fConcussionDspUntil[client] = 0.0;
        g_iConcussionDspEffect[client] = 0;
    }
    ClearVisualTracking();
}

public void OnClientPutInServer(int client)
{
    ResetClientData(client);
    HookClient(client);
}

public void OnClientDisconnect(int client)
{
    int departingTeam = GetClientTeam(client);
    int departingUserId = GetClientUserId(client);
    ClearBlackoutEffect(client, false);
    ClearReplicaEntitiesForOwner(departingUserId);
    // Dropped gifts and deployed mines are world objects: keep them until the next round_start.
    ClearBuildablesForOwner(departingUserId);
    DestroyWallhackMarker(client);
    RestoreBunnyMaxSpeed(client);
    ResetClientPower(client, false);
    StopRagdollForceHook(client);
    SDKUnhook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
    SDKUnhook(client, SDKHook_OnTakeDamagePost, Hook_OnTakeDamagePost);
    SDKUnhook(client, SDKHook_OnTakeDamageAlivePost, Hook_RobinHoodDamageAlivePost);
    SDKUnhook(client, SDKHook_PreThinkPost, Hook_RSPNoRecoilPreThink);
    SDKUnhook(client, SDKHook_PostThinkPost, Hook_RSPNoRecoilPostThink);
    SDKUnhook(client, SDKHook_TraceAttack, Hook_TraceAttack);
    SDKUnhook(client, SDKHook_SetTransmit, Hook_RSPSetTransmit);
    SDKUnhook(client, SDKHook_WeaponCanUse, Hook_WeaponCanUse);
    SDKUnhook(client, SDKHook_WeaponEquipPost, Hook_WeaponEquipPost);
    SDKUnhook(client, SDKHook_WeaponDropPost, Hook_WeaponDropPost);
    g_iExpensiveAmmoOwnerUserId[client] = 0;
    g_iExpensiveAmmoRound[client] = 0;
    g_iHackerOwnerUserId[client] = 0;
    g_iHackerRound[client] = 0;
    ResetClientData(client);
    // A disconnect also cancels any pending life. Recheck a held elimination after
    // SourceMod has removed the departing player from team/alive counts.
    if (departingTeam == CS_TEAM_T || departingTeam == CS_TEAM_CT)
    {
        RequestFrame(Frame_CheckDeferredElimination, departingTeam);
    }
    ScheduleDeferredEliminationChecks();
    QueueWallhackRefresh();
    QueueRefreshActiveTargetSelections();
}

void ClearRapidFireWeaponTrackingForEntity(int entity)
{
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES)
    {
        return;
    }
    g_iRapidFireOwnerUserId[entity] = 0;
    g_iRapidFireWeaponEntRef[entity] = INVALID_ENT_REFERENCE;
    for (int propertyIndex = 0; propertyIndex < 2; propertyIndex++)
    {
        g_fRapidFireOriginalNextAttack[entity][propertyIndex] = 0.0;
        g_fRapidFireAppliedNextAttack[entity][propertyIndex] = 0.0;
        g_bRapidFireAttackTracked[entity][propertyIndex] = false;
    }
}

void RestoreRapidFireAdjustmentsForOwner(int ownerUserId)
{
    if (ownerUserId == 0)
    {
        return;
    }

    char properties[2][32] = {"m_flNextPrimaryAttack", "m_flNextSecondaryAttack"};
    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iRapidFireOwnerUserId[entity] != ownerUserId)
        {
            continue;
        }

        int recordedRef = g_iRapidFireWeaponEntRef[entity];
        bool sameEntity = IsValidEntity(entity) && recordedRef != INVALID_ENT_REFERENCE &&
            EntIndexToEntRef(entity) == recordedRef;
        if (sameEntity)
        {
            for (int propertyIndex = 0; propertyIndex < sizeof(properties); propertyIndex++)
            {
                if (!g_bRapidFireAttackTracked[entity][propertyIndex] ||
                    !HasEntProp(entity, Prop_Data, properties[propertyIndex]))
                {
                    continue;
                }

                float currentValue = GetEntPropFloat(entity, Prop_Data, properties[propertyIndex]);
                // Do not overwrite a later value written by the engine or another plugin.
                if (FloatAbs(currentValue - g_fRapidFireAppliedNextAttack[entity][propertyIndex]) <= 0.02)
                {
                    SetEntPropFloat(entity, Prop_Data, properties[propertyIndex],
                        g_fRapidFireOriginalNextAttack[entity][propertyIndex]);
                }
            }
        }
        ClearRapidFireWeaponTrackingForEntity(entity);
    }
}

public void OnEntityDestroyed(int entity)
{
    if (entity > MaxClients && entity < RSP_MAX_ENTITIES)
    {
        ClearRapidFireWeaponTrackingForEntity(entity);
    }
    if (entity > 0 && entity < RSP_MAX_ENTITIES)
    {
        int wallhackTarget = g_iWallhackMarkerTarget[entity];
        if (wallhackTarget >= 1 && wallhackTarget <= MaxClients)
        {
            for (int point = 0; point < 8; point++)
            {
                if (g_iWallhackAnchorEntity[wallhackTarget][point] == entity)
                {
                    g_iWallhackAnchorEntity[wallhackTarget][point] = 0;
                }
            }
            for (int edge = 0; edge < 12; edge++)
            {
                if (g_iWallhackBeamEntity[wallhackTarget][edge] == entity)
                {
                    g_iWallhackBeamEntity[wallhackTarget][edge] = 0;
                }
            }
        }
        g_iWallhackMarkerTarget[entity] = 0;
        g_iGhostEntityOwnerUserId[entity] = 0;
        g_iGiftOwnerUserId[entity] = 0;
        g_iGiftTeam[entity] = 0;
        g_iMinerOwnerUserId[entity] = 0;
        g_iMinerTeam[entity] = 0;
        g_iMinerRound[entity] = 0;
        g_bMinerDetonating[entity] = false;
        g_iReplicaOwnerUserId[entity] = 0;
        g_fReplicaHealth[entity] = 0.0;
        g_bReplicaPendingRemoval[entity] = false;
        if (g_hBuildableTurretTimer[entity] != null)
        {
            delete g_hBuildableTurretTimer[entity];
            g_hBuildableTurretTimer[entity] = null;
        }
        StopBuildableLoopSound(entity);
        StopBuildableAntennaArcEntity(entity);
        g_iBuildableOwnerUserId[entity] = 0;
        g_iBuildableType[entity] = 0;
        g_fBuildableHealth[entity] = 0.0;
        g_iBuildableLoopSoundRef[entity] = INVALID_ENT_REFERENCE;
        g_iBuildableAntennaTeslaRef[entity] = INVALID_ENT_REFERENCE;
        g_fBuildableYaw[entity] = 0.0;
        g_bBuildableBeamOffsetValid[entity] = false;
        for (int beamAxis = 0; beamAxis < 3; beamAxis++)
        {
            g_fBuildableBeamOffset[entity][beamAxis] = 0.0;
        }
        g_iRSPDeathExplosionTeam[entity] = 0;
        g_iFlashProjectileOwnerUserId[entity] = 0;
        g_bFlashProjectileDeadly[entity] = false;
        g_bFlashProjectileLong[entity] = false;
        g_iFlashProjectileRound[entity] = 0;
        g_fFlashProjectileSpawnTime[entity] = 0.0;
        g_iHEProjectileOwnerUserId[entity] = 0;
        g_bHEProjectileDemolition[entity] = false;
        g_iHEProjectileTeam[entity] = 0;
        g_bHEProjectileExecutioner[entity] = false;
        g_bHEProjectileEnder[entity] = false;
        g_iHEProjectileRound[entity] = 0;
        g_fHEProjectileSpawnTime[entity] = 0.0;
        g_iSmokeProjectileOwnerUserId[entity] = 0;
        g_iSmokeProjectileTeam[entity] = 0;
        g_iSmokeProjectileRound[entity] = 0;
        g_iSmokeProjectileType[entity] = 0;
        g_fSmokeProjectileSpawnTime[entity] = 0.0;
    }
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES)
    {
        return;
    }

    ClearRapidFireWeaponTrackingForEntity(entity);
    g_iWallhackMarkerTarget[entity] = 0;
    g_iGhostEntityOwnerUserId[entity] = 0;
    g_iGiftOwnerUserId[entity] = 0;
    g_iGiftTeam[entity] = 0;
    g_iMinerOwnerUserId[entity] = 0;
    g_iMinerTeam[entity] = 0;
    g_iMinerRound[entity] = 0;
    g_bMinerDetonating[entity] = false;
    if (StrEqual(classname, "prop_dynamic_override", false))
    {
        for (int viewer = 1; viewer <= MaxClients; viewer++)
        {
            g_bMinerDiscoveredBy[entity][viewer] = false;
        }
    }
    g_iReplicaOwnerUserId[entity] = 0;
    g_fReplicaHealth[entity] = 0.0;
    g_bReplicaPendingRemoval[entity] = false;
    if (g_hBuildableTurretTimer[entity] != null)
    {
        delete g_hBuildableTurretTimer[entity];
        g_hBuildableTurretTimer[entity] = null;
    }
    g_iBuildableOwnerUserId[entity] = 0;
    g_iBuildableType[entity] = 0;
    g_fBuildableHealth[entity] = 0.0;
    g_iBuildableLoopSoundRef[entity] = INVALID_ENT_REFERENCE;
    g_iBuildableAntennaTeslaRef[entity] = INVALID_ENT_REFERENCE;
    g_fBuildableYaw[entity] = 0.0;
    g_bBuildableBeamOffsetValid[entity] = false;
    for (int beamAxis = 0; beamAxis < 3; beamAxis++)
    {
        g_fBuildableBeamOffset[entity][beamAxis] = 0.0;
    }
    g_iRSPDeathExplosionTeam[entity] = 0;
    g_iFlashProjectileOwnerUserId[entity] = 0;
    g_bFlashProjectileDeadly[entity] = false;
    g_bFlashProjectileLong[entity] = false;
    g_iFlashProjectileRound[entity] = 0;
    g_fFlashProjectileSpawnTime[entity] = 0.0;
    g_iHEProjectileOwnerUserId[entity] = 0;
    g_bHEProjectileDemolition[entity] = false;
    g_iHEProjectileTeam[entity] = 0;
    g_bHEProjectileExecutioner[entity] = false;
        g_bHEProjectileEnder[entity] = false;
    g_iHEProjectileRound[entity] = 0;
    g_fHEProjectileSpawnTime[entity] = 0.0;
    g_iSmokeProjectileOwnerUserId[entity] = 0;
    g_iSmokeProjectileTeam[entity] = 0;
    g_iSmokeProjectileRound[entity] = 0;
    g_iSmokeProjectileType[entity] = 0;
    g_fSmokeProjectileSpawnTime[entity] = 0.0;

    if (StrEqual(classname, "flashbang_projectile", false))
    {
        SDKHook(entity, SDKHook_SpawnPost, Hook_FlashbangProjectileSpawnPost);
    }
    else if (StrEqual(classname, "hegrenade_projectile", false))
    {
        SDKHook(entity, SDKHook_SpawnPost, Hook_HEGrenadeProjectileSpawnPost);
    }
    else if (StrEqual(classname, "smokegrenade_projectile", false))
    {
        SDKHook(entity, SDKHook_SpawnPost, Hook_SmokeGrenadeProjectileSpawnPost);
    }
    else if (StrEqual(classname, "cs_ragdoll", false))
    {
        // Try at Spawn first (native force values are usually assigned before DispatchSpawn),
        // then at SpawnPost and through the bounded per-victim fallback if needed.
        SDKHook(entity, SDKHook_Spawn, Hook_RagdollForceSpawn);
        SDKHook(entity, SDKHook_SpawnPost, Hook_RagdollForceSpawnPost);
    }
}

public void Hook_FlashbangProjectileSpawnPost(int entity)
{
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES || !IsValidEntity(entity))
    {
        return;
    }

    int owner = -1;
    if (HasEntProp(entity, Prop_Send, "m_hThrower"))
    {
        owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
    }
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner))
    {
        return;
    }

    g_iFlashProjectileOwnerUserId[entity] = GetClientUserId(owner);
    g_bFlashProjectileDeadly[entity] = HasDeadlyFlashAttribution(owner);
    g_bFlashProjectileLong[entity] = g_iPower[owner] == RSP_FlashPro;
    g_iFlashProjectileRound[entity] = g_iRoundSerial;
    g_fFlashProjectileSpawnTime[entity] = GetGameTime();
}

public void Hook_HEGrenadeProjectileSpawnPost(int entity)
{
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES || !IsValidEntity(entity))
        return;

    int owner = -1;
    if (HasEntProp(entity, Prop_Send, "m_hThrower"))
        owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
    if ((owner < 1 || owner > MaxClients || !IsClientInGame(owner)) &&
        HasEntProp(entity, Prop_Data, "m_hOwnerEntity"))
        owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner))
        return;

    g_iHEProjectileOwnerUserId[entity] = GetClientUserId(owner);
    g_iHEProjectileTeam[entity] = GetClientTeam(owner);
    float lastHEAge = GetGameTime() - g_fLastHEThrowTime[owner];
    g_bHEProjectileExecutioner[entity] = (g_iPower[owner] == RSP_Executioner) ||
        (g_bLastHEWasExecutioner[owner] && g_iLastHERound[owner] == g_iRoundSerial &&
            lastHEAge >= 0.0 && lastHEAge <= RSP_EXECUTIONER_HE_GRACE);
    g_bHEProjectileEnder[entity] = g_iPower[owner] == RSP_EnderGrenade &&
        g_iAssignedRound[owner] == g_iRoundSerial;

    g_bHEProjectileDemolition[entity] =
        g_iPower[owner] == RSP_Demolition && g_iAssignedRound[owner] == g_iRoundSerial;
    if (g_bHEProjectileDemolition[entity])
        RequestFrame(Frame_ApplyDemolitionToHEProjectile, EntIndexToEntRef(entity));

    g_iHEProjectileRound[entity] = g_iRoundSerial;
    g_fHEProjectileSpawnTime[entity] = GetGameTime();
}

public void Frame_ApplyDemolitionToHEProjectile(any entityRef)
{
    int entity = EntRefToEntIndex(entityRef);
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES || !IsValidEntity(entity))
        return;

    if (!g_bHEProjectileDemolition[entity] || g_iHEProjectileRound[entity] != g_iRoundSerial)
        return;

    float damage = 0.0;
    float radius = 0.0;
    bool hasDamage = false;
    bool hasRadius = false;

    if (HasEntProp(entity, Prop_Data, "m_flDamage"))
    {
        damage = GetEntPropFloat(entity, Prop_Data, "m_flDamage");
        hasDamage = true;
    }
    else if (HasEntProp(entity, Prop_Send, "m_flDamage"))
    {
        damage = GetEntPropFloat(entity, Prop_Send, "m_flDamage");
        hasDamage = true;
    }

    if (HasEntProp(entity, Prop_Data, "m_DmgRadius"))
    {
        radius = GetEntPropFloat(entity, Prop_Data, "m_DmgRadius");
        hasRadius = true;
    }
    else if (HasEntProp(entity, Prop_Send, "m_DmgRadius"))
    {
        radius = GetEntPropFloat(entity, Prop_Send, "m_DmgRadius");
        hasRadius = true;
    }

    // Scale the projectile's actual CS:S defaults rather than relying on fixed
    // constants. This runs next-frame, after weapon throw code finalized its fields.
    if (hasDamage && damage > 0.0)
    {
        if (HasEntProp(entity, Prop_Data, "m_flDamage"))
            SetEntPropFloat(entity, Prop_Data, "m_flDamage",
                damage * RSP_DEMOLITION_DAMAGE_MULTIPLIER);
        else
            SetEntPropFloat(entity, Prop_Send, "m_flDamage",
                damage * RSP_DEMOLITION_DAMAGE_MULTIPLIER);
    }

    if (hasRadius && radius > 0.0)
    {
        if (HasEntProp(entity, Prop_Data, "m_DmgRadius"))
            SetEntPropFloat(entity, Prop_Data, "m_DmgRadius",
                radius * RSP_DEMOLITION_RADIUS_MULTIPLIER);
        else
            SetEntPropFloat(entity, Prop_Send, "m_DmgRadius",
                radius * RSP_DEMOLITION_RADIUS_MULTIPLIER);
    }
}

public void Hook_SmokeGrenadeProjectileSpawnPost(int entity)
{
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES || !IsValidEntity(entity))
    {
        return;
    }

    int owner = -1;
    if (HasEntProp(entity, Prop_Send, "m_hThrower"))
    {
        owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
    }
    if ((owner < 1 || owner > MaxClients || !IsClientInGame(owner)) &&
        HasEntProp(entity, Prop_Data, "m_hOwnerEntity"))
    {
        owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
    }
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner))
    {
        return;
    }

    int smokeType = 0;
    if (g_iPower[owner] == RSP_ToxicSmoke && g_iAssignedRound[owner] == g_iRoundSerial)
    {
        smokeType = RSP_SMOKE_CLOUD_TOXIC;
    }
    else if (g_iPower[owner] == RSP_HealingSmoke && g_iAssignedRound[owner] == g_iRoundSerial)
    {
        smokeType = RSP_SMOKE_CLOUD_HEALING;
    }
    else if (HasRecentRSPSmokeThrowSnapshot(owner))
    {
        smokeType = g_bLastSmokeWasHealing[owner]
            ? RSP_SMOKE_CLOUD_HEALING : RSP_SMOKE_CLOUD_TOXIC;
    }

    if (smokeType == 0)
    {
        return;
    }

    int team = g_iLastSmokeThrowTeam[owner];
    if (team != CS_TEAM_CT && team != CS_TEAM_T)
    {
        team = GetClientTeam(owner);
    }
    if (team != CS_TEAM_CT && team != CS_TEAM_T)
    {
        return;
    }

    g_iSmokeProjectileOwnerUserId[entity] = GetClientUserId(owner);
    g_iSmokeProjectileTeam[entity] = team;
    g_iSmokeProjectileRound[entity] = g_iRoundSerial;
    g_iSmokeProjectileType[entity] = smokeType;
    g_fSmokeProjectileSpawnTime[entity] = GetGameTime();
}

void HookClient(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamagePost, Hook_OnTakeDamagePost);
    SDKHook(client, SDKHook_OnTakeDamageAlivePost, Hook_RobinHoodDamageAlivePost);
    SDKHook(client, SDKHook_PreThinkPost, Hook_RSPNoRecoilPreThink);
    SDKHook(client, SDKHook_PostThinkPost, Hook_RSPNoRecoilPostThink);
    SDKHook(client, SDKHook_TraceAttack, Hook_TraceAttack);
    SDKHook(client, SDKHook_SetTransmit, Hook_RSPSetTransmit);
    SDKHook(client, SDKHook_WeaponCanUse, Hook_WeaponCanUse);
    SDKHook(client, SDKHook_WeaponEquipPost, Hook_WeaponEquipPost);
    SDKHook(client, SDKHook_WeaponDropPost, Hook_WeaponDropPost);
}

void UpdateRSPTemporaryVoiceMute(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
        return;

    bool shouldMute = g_bEnabled && g_bSupportedMap &&
        (g_bSpectatorActive[client] || g_fFrozenUntil[client] > GetGameTime());

    if (shouldMute)
    {
        if (!g_bSpectatorVoiceFlagsSaved[client])
        {
            g_iSpectatorSavedVoiceFlags[client] = GetClientListeningFlags(client);
            g_bSpectatorVoiceFlagsSaved[client] = true;
        }

        int flags = GetClientListeningFlags(client);
        if ((flags & VOICE_MUTED) == 0)
            SetClientListeningFlags(client, flags | VOICE_MUTED);
    }
    else if (g_bSpectatorVoiceFlagsSaved[client])
    {
        SetClientListeningFlags(client, g_iSpectatorSavedVoiceFlags[client]);
        g_bSpectatorVoiceFlagsSaved[client] = false;
    }
}

int GetRSPSoundOwner(int entity)
{
    if (entity >= 1 && entity <= MaxClients)
        return entity;
    if (entity <= MaxClients || !IsValidEntity(entity))
        return 0;

    int owner = -1;
    if (HasEntProp(entity, Prop_Send, "m_hOwnerEntity"))
        owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
    if ((owner < 1 || owner > MaxClients) && HasEntProp(entity, Prop_Data, "m_hOwnerEntity"))
        owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
    if ((owner < 1 || owner > MaxClients) && HasEntProp(entity, Prop_Send, "m_hThrower"))
        owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
    if ((owner < 1 || owner > MaxClients) && HasEntProp(entity, Prop_Data, "m_hThrower"))
        owner = GetEntPropEnt(entity, Prop_Data, "m_hThrower");

    return (owner >= 1 && owner <= MaxClients && IsClientInGame(owner)) ? owner : 0;
}

public Action Hook_RSPNormalSound(int clients[MAXPLAYERS], int &numClients,
    char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume,
    int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
    if (!g_bEnabled || !g_bSupportedMap)
        return Plugin_Continue;

    int owner = GetRSPSoundOwner(entity);
    if (owner > 0 &&
        (g_bSpectatorActive[owner] || g_fFrozenUntil[owner] > GetGameTime()))
    {
        // Suppress sounds from the player and their owned weapon/projectile entities.
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// Tesla impulse must be applied to the native cs_ragdoll before its initial
// network update. Editing m_vecForce from the dead player's later PreThink can be
// too late: clients may already have constructed the client-side physics ragdoll.
void StoreRagdollForceDirection(int victim, int attacker)
{
    float direction[3];
    direction[0] = 1.0;
    direction[1] = 0.0;
    direction[2] = 0.20;

    if (victim >= 1 && victim <= MaxClients && IsClientInGame(victim) &&
        attacker >= 1 && attacker <= MaxClients && IsClientInGame(attacker) && attacker != victim)
    {
        float victimOrigin[3], attackerOrigin[3];
        GetClientAbsOrigin(victim, victimOrigin);
        GetClientAbsOrigin(attacker, attackerOrigin);
        direction[0] = victimOrigin[0] - attackerOrigin[0];
        direction[1] = victimOrigin[1] - attackerOrigin[1];
        direction[2] = victimOrigin[2] - attackerOrigin[2] + 24.0;
        if (GetVectorLength(direction) < 1.0)
        {
            float angles[3], forwardVector[3], right[3], up[3];
            GetClientEyeAngles(attacker, angles);
            GetAngleVectors(angles, forwardVector, right, up);
            direction[0] = -forwardVector[0];
            direction[1] = -forwardVector[1];
            direction[2] = 0.20;
        }
    }

    if (GetVectorLength(direction) < 0.01)
    {
        direction[0] = 1.0;
        direction[1] = 0.0;
        direction[2] = 0.20;
    }
    NormalizeVector(direction, direction);
    for (int axis = 0; axis < 3; axis++)
    {
        g_fRagdollForceDirection[victim][axis] = direction[axis];
    }
}

void StoreTeslaRagdollForceDirection(int victim, const float source[3], const float impact[3])
{
    if (victim < 1 || victim > MaxClients)
    {
        return;
    }

    // Direction is derived from the turret antenna to the actual beam endpoint,
    // not from the owner's player origin (the owner may be far away from their turret).
    float direction[3];
    direction[0] = impact[0] - source[0];
    direction[1] = impact[1] - source[1];
    direction[2] = impact[2] - source[2] + 24.0;
    if (GetVectorLength(direction) < 1.0)
    {
        direction[0] = 1.0;
        direction[1] = 0.0;
        direction[2] = 0.20;
    }
    NormalizeVector(direction, direction);
    g_bTeslaRagdollDirectionValid[victim] = true;
    for (int axis = 0; axis < 3; axis++)
    {
        g_fTeslaRagdollDirection[victim][axis] = direction[axis];
    }
}

void ApplyCachedTeslaRagdollForceDirection(int victim)
{
    if (victim < 1 || victim > MaxClients || !g_bTeslaRagdollDirectionValid[victim] ||
        !g_bRagdollForcePending[victim] ||
        g_fRagdollForceMultiplier[victim] != RSP_INVENTOR_TURRET_RAGDOLL_FORCE_MULTIPLIER)
    {
        return;
    }

    for (int axis = 0; axis < 3; axis++)
    {
        g_fRagdollForceDirection[victim][axis] = g_fTeslaRagdollDirection[victim][axis];
    }
}

void SetRagdollForcePending(int victim, int attacker, bool refresh, float forceMultiplier = RSP_RAGDOLL_FORCE_MULTIPLIER_MAX)
{
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return;
    }

    float now = GetGameTime();
    if (!refresh)
    {
        // Event_PlayerDeath may follow SpawnPost in the same death flow. Don't queue
        // a second application if this ragdoll has already received its one-time boost.
        if (g_bRagdollForceApplied[victim])
        {
            return;
        }
        if (g_bRagdollForcePending[victim] &&
            g_iRagdollForceRound[victim] == g_iRoundSerial &&
            now <= g_fRagdollForceUntil[victim])
        {
            return;
        }
    }
    else
    {
        // Called from the lethal damage hook before CSS builds the ragdoll.
        g_bRagdollForceApplied[victim] = false;
    }

    g_bRagdollForcePending[victim] = true;
    g_fRagdollForceMultiplier[victim] = (forceMultiplier >= 1.0 && forceMultiplier <= RSP_RAGDOLL_FORCE_MULTIPLIER_MAX)
        ? forceMultiplier : RSP_RAGDOLL_FORCE_MULTIPLIER_MAX;
    g_fRagdollForceUntil[victim] = now + RSP_RAGDOLL_FORCE_TIMEOUT;
    g_iRagdollForceRound[victim] = g_iRoundSerial;
    StoreRagdollForceDirection(victim, attacker);
    if (!g_bRagdollForceHooked[victim])
    {
        SDKHook(victim, SDKHook_PreThink, Hook_RagdollForceThink);
        g_bRagdollForceHooked[victim] = true;
    }
}

void MarkTeslaRagdollForcePending(int victim, int attacker)
{
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return;
    }

    // If Tesla is the accepted lethal hit, replace any stale pending force with its
    // own 15x directional impulse. An already-applied ragdoll is protected by the
    // shared applied-state guard.

    SetRagdollForcePending(victim, attacker, true,
        RSP_INVENTOR_TURRET_RAGDOLL_FORCE_MULTIPLIER);
    ApplyCachedTeslaRagdollForceDirection(victim);
}

void QueueRagdollForceWithMultiplier(int victim, int attacker, float forceMultiplier, bool useTeslaDirection = false)
{
    SetRagdollForcePending(victim, attacker, false, forceMultiplier);
    if (useTeslaDirection)
    {
        ApplyCachedTeslaRagdollForceDirection(victim);
    }
    // If this engine build already assigned the ragdoll handle by player_death,
    // attempt to update that exact entity instead of waiting for another SpawnPost.
    if (victim >= 1 && victim <= MaxClients && IsClientInGame(victim) &&
        HasEntProp(victim, Prop_Send, "m_hRagdoll"))
    {
        int ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");
        if (ragdoll > MaxClients && ragdoll < RSP_MAX_ENTITIES && IsValidEntity(ragdoll))
        {
            TryApplyRagdollForce(ragdoll, true);
        }
    }
    if (useTeslaDirection && victim >= 1 && victim <= MaxClients)
    {
        g_bTeslaRagdollDirectionValid[victim] = false;
    }
}

void QueueTeslaRagdollForce(int victim, int attacker)
{
    QueueRagdollForceWithMultiplier(victim, attacker, RSP_INVENTOR_TURRET_RAGDOLL_FORCE_MULTIPLIER, true);
}

void StopRagdollForceHook(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    if (g_bRagdollForceHooked[client])
    {
        SDKUnhook(client, SDKHook_PreThink, Hook_RagdollForceThink);
        g_bRagdollForceHooked[client] = false;
    }
    g_bRagdollForcePending[client] = false;
    g_bRagdollForceApplied[client] = false;
    g_bExecutionerSuicideFallbackPending[client] = false;
    g_fRagdollForceUntil[client] = 0.0;
    g_fRagdollForceMultiplier[client] = 0.0;
    g_iRagdollForceRound[client] = 0;
    for (int axis = 0; axis < 3; axis++)
    {
        g_fRagdollForceDirection[client][axis] = 0.0;
    }
}

float GetExecutionerLethalDamage(int victim)
{
    int health = 100;
    int armor = 0;
    if (victim >= 1 && victim <= MaxClients && IsClientInGame(victim))
    {
        health = GetClientHealth(victim);
        if (HasEntProp(victim, Prop_Send, "m_ArmorValue"))
        {
            armor = GetEntProp(victim, Prop_Send, "m_ArmorValue");
        }
    }
    if (health < 1)
    {
        health = 100;
    }
    if (armor < 0)
    {
        armor = 0;
    }
    // CS:S armor absorbs part of incoming damage. Health + 2*armor + a small
    // margin is enough to cross the armor pool without injecting 2,000-50,000
    // overkill damage into the native stats/kill pipeline.
    return float(health) + (float(armor) * RSP_EXECUTIONER_ARMOR_LETHAL_FACTOR) +
        RSP_EXECUTIONER_LETHAL_MARGIN;
}

void ClampRagdollForceVector(float vector[3], float maxMagnitude)
{
    float magnitude = GetVectorLength(vector);
    if (magnitude > maxMagnitude && magnitude > 0.001)
    {
        float scale = maxMagnitude / magnitude;
        vector[0] *= scale;
        vector[1] *= scale;
        vector[2] *= scale;
    }
}

int FindRagdollForceVictim(int ragdoll)
{
    if (HasEntProp(ragdoll, Prop_Send, "m_hPlayer"))
    {
        int owner = GetEntPropEnt(ragdoll, Prop_Send, "m_hPlayer");
        if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner))
        {
            return owner;
        }
    }
    if (HasEntProp(ragdoll, Prop_Data, "m_hPlayer"))
    {
        int owner = GetEntPropEnt(ragdoll, Prop_Data, "m_hPlayer");
        if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner))
        {
            return owner;
        }
    }

    // Some CS:S builds expose m_hPlayer late; the player's own ragdoll handle is a
    // safe fallback once it has been filled in by the server.
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || !HasEntProp(client, Prop_Send, "m_hRagdoll"))
        {
            continue;
        }
        if (GetEntPropEnt(client, Prop_Send, "m_hRagdoll") == ragdoll)
        {
            return client;
        }
    }
    return 0;
}

bool HasPendingRagdollForce()
{
    float now = GetGameTime();
    for (int client = 1; client <= MaxClients; client++)
    {
        if (g_bRagdollForcePending[client] &&
            g_iRagdollForceRound[client] == g_iRoundSerial &&
            now <= g_fRagdollForceUntil[client])
        {
            return true;
        }
    }
    return false;
}

bool TryApplyRagdollForce(int ragdoll, bool allowFallback)
{
    if (ragdoll <= MaxClients || ragdoll >= RSP_MAX_ENTITIES || !IsValidEntity(ragdoll))
    {
        return true;
    }

    int victim = FindRagdollForceVictim(ragdoll);
    if (victim < 1 || victim > MaxClients)
    {
        return false;
    }
    if (!g_bRagdollForcePending[victim])
    {
        return true;
    }
    if (g_iRagdollForceRound[victim] != g_iRoundSerial ||
        GetGameTime() > g_fRagdollForceUntil[victim])
    {
        StopRagdollForceHook(victim);
        return true;
    }

    bool hasForce = HasEntProp(ragdoll, Prop_Send, "m_vecForce");
    bool hasVelocity = HasEntProp(ragdoll, Prop_Send, "m_vecRagdollVelocity");
    if (!hasForce && !hasVelocity)
    {
        return false;
    }
    if (!allowFallback)
    {
        // The Spawn callback is deliberately conservative: only scale a populated
        // native force. If it is still zero, wait for SpawnPost/fallback rather than
        // writing a value which the game's own setup could overwrite.
        if (!hasForce)
        {
            return false;
        }
        float initialForce[3];
        GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", initialForce);
        if (GetVectorLength(initialForce) <= 0.01)
        {
            return false;
        }
    }

    float direction[3];
    for (int axis = 0; axis < 3; axis++)
    {
        direction[axis] = g_fRagdollForceDirection[victim][axis];
    }
    if (GetVectorLength(direction) < 0.01)
    {
        direction[0] = 1.0;
        direction[1] = 0.0;
        direction[2] = 0.20;
        NormalizeVector(direction, direction);
    }

    float forceMultiplier = g_fRagdollForceMultiplier[victim];
    if (forceMultiplier < 1.0 || forceMultiplier > RSP_RAGDOLL_FORCE_MULTIPLIER_MAX)
    {
        forceMultiplier = RSP_RAGDOLL_FORCE_MULTIPLIER_MAX;
    }
    float fallbackScale = forceMultiplier / RSP_RAGDOLL_FORCE_MULTIPLIER_MAX;

    // If this engine exposes velocity but not m_vecForce, the velocity fallback
    // must still be enabled; otherwise a zero native velocity would remain zero.
    bool usedFallbackForce = (!hasForce && hasVelocity);
    float vector[3];
    if (hasForce)
    {
        GetEntPropVector(ragdoll, Prop_Send, "m_vecForce", vector);
        if (GetVectorLength(vector) > 0.01)
        {
            vector[0] *= forceMultiplier;
            vector[1] *= forceMultiplier;
            vector[2] *= forceMultiplier;
            ClampRagdollForceVector(vector, RSP_RAGDOLL_FORCE_CAP);
        }
        else
        {
            // Damage types such as generic/reflected damage can create a ragdoll with
            // zero force. Supply a clear outward impulse instead of multiplying zero.
            vector[0] = direction[0] * RSP_RAGDOLL_FALLBACK_FORCE * fallbackScale;
            vector[1] = direction[1] * RSP_RAGDOLL_FALLBACK_FORCE * fallbackScale;
            vector[2] = direction[2] * RSP_RAGDOLL_FALLBACK_FORCE * fallbackScale;
            usedFallbackForce = true;
            if (HasEntProp(ragdoll, Prop_Send, "m_nForceBone"))
            {
                SetEntProp(ragdoll, Prop_Send, "m_nForceBone", 0);
            }
        }
        SetEntPropVector(ragdoll, Prop_Send, "m_vecForce", vector);
    }

    if (hasVelocity)
    {
        GetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", vector);
        if (GetVectorLength(vector) > 0.01)
        {
            vector[0] *= forceMultiplier;
            vector[1] *= forceMultiplier;
            vector[2] *= forceMultiplier;
            ClampRagdollForceVector(vector, RSP_RAGDOLL_VELOCITY_CAP);
        }
        else if (usedFallbackForce)
        {
            vector[0] = direction[0] * RSP_RAGDOLL_FALLBACK_VELOCITY * fallbackScale;
            vector[1] = direction[1] * RSP_RAGDOLL_FALLBACK_VELOCITY * fallbackScale;
            vector[2] = direction[2] * RSP_RAGDOLL_FALLBACK_VELOCITY * fallbackScale;
        }
        SetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", vector);
    }

    g_bRagdollForcePending[victim] = false;
    g_bRagdollForceApplied[victim] = true;
    g_fRagdollForceUntil[victim] = 0.0;
    g_iRagdollForceRound[victim] = 0;
    if (g_bRagdollForceHooked[victim])
    {
        SDKUnhook(victim, SDKHook_PreThink, Hook_RagdollForceThink);
        g_bRagdollForceHooked[victim] = false;
    }
    return true;
}

public Action Hook_RagdollForceSpawn(int entity)
{
    TryApplyRagdollForce(entity, false);
    return Plugin_Continue;
}

public void Hook_RagdollForceSpawnPost(int entity)
{
    if (TryApplyRagdollForce(entity, true))
    {
        return;
    }
    if (HasPendingRagdollForce())
    {
        // One-frame fallback covers builds which publish the ragdoll-to-player handle
        // after SpawnPost. The primary adjustment still happens before initial transmit.
        RequestFrame(Frame_RetryRagdollForce, EntIndexToEntRef(entity));
    }
}

public void Frame_RetryRagdollForce(any entityRef)
{
    int entity = EntRefToEntIndex(entityRef);
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES || !IsValidEntity(entity))
    {
        return;
    }
    TryApplyRagdollForce(entity, true);
}

public void Hook_RagdollForceThink(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }
    if (!g_bRagdollForcePending[client])
    {
        if (g_bRagdollForceHooked[client])
        {
            SDKUnhook(client, SDKHook_PreThink, Hook_RagdollForceThink);
            g_bRagdollForceHooked[client] = false;
        }
        return;
    }
    if (g_iRagdollForceRound[client] != g_iRoundSerial ||
        GetGameTime() > g_fRagdollForceUntil[client])
    {
        StopRagdollForceHook(client);
        return;
    }
    if (IsPlayerAlive(client) || !HasEntProp(client, Prop_Send, "m_hRagdoll"))
    {
        return;
    }
    int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
    if (ragdoll <= MaxClients || ragdoll >= RSP_MAX_ENTITIES || !IsValidEntity(ragdoll))
    {
        return;
    }
    char classname[32];
    GetEntityClassname(ragdoll, classname, sizeof(classname));
    if (StrEqual(classname, "cs_ragdoll", false))
    {
        TryApplyRagdollForce(ragdoll, true);
    }
}

void ResetClientData(int client)
{
    if (IsClientInGame(client))
    {
        if (g_fConcussionDspUntil[client] > 0.0)
            ClientCommand(client, "dsp_player 0");
        if (g_bSpectatorVoiceFlagsSaved[client])
            SetClientListeningFlags(client, g_iSpectatorSavedVoiceFlags[client]);
    }
    g_fConcussionDspUntil[client] = 0.0;
    g_iConcussionDspEffect[client] = 0;
    g_iSpectatorSavedVoiceFlags[client] = VOICE_NORMAL;
    g_bSpectatorVoiceFlagsSaved[client] = false;

    RestoreBunnyMaxSpeed(client);
    ClearBlackoutEffect(client, false);
    ClearToxicAmmoEffect(client);
    StopRagdollForceHook(client);
    StopHook(client);
    ClearAnomalyHistory(client);
    StopRSPTargetSelectionBuildTimer(client);
    g_iCachedClientUserId[client] = (IsClientInGame(client) ? GetClientUserId(client) : 0);
    StopInfiniteGrenadeRefillTimers(client);
    StopReviverCooldown(client);
    StopSkillCooldown(client);
    g_bRadarRewriteQueued[client] = false;
    g_iRadarQueuedCount[client] = 0;
    g_bObserverRosterRefreshQueued[client] = false;
    g_bHostPowerGrantedOutsideRound[client] = false;
    g_iPower[client] = RSP_None;
    g_iAssignedRound[client] = 0;
    g_iInventorUsesThisRound[client] = 0;
    g_iMinerUsesThisRound[client] = 0;
    g_iExplodingBarrelsPlacedTowardCooldown[client] = 0;
    g_iLeechChancePercent[client] = 0;
    g_iGrounderRound[client] = 0;
    g_iGrounderOwnerUserId[client] = 0;
    g_bGrounderUsedThisAssignment[client] = false;
    g_bGiftUseWasDown[client] = false;
    g_fNextGiftUseTime[client] = 0.0;
    g_bAvengerConsumedThisRound[client] = false;
    g_fWeakeningUntil[client] = 0.0;
    g_iWeakeningRound[client] = 0;
    g_iWeakeningOwnerUserId[client] = 0;
    g_fWeakeningBaseMovementValue[client] = 1.0;
    g_bWeakeningBaseMovementValid[client] = false;
    g_bGamblerPendingSelection[client] = false;
    g_bGamblerChatIntercept[client] = false;
    g_bGamblerApplyingChoice[client] = false;
    g_iGamblerSelectedOfferIndex[client] = -1;
    g_bCurserTargetCursed[client] = false;
    g_iCurserTargetCurseRound[client] = 0;
    g_iCurserOwnerUserId[client] = 0;
    g_iTargetSelectionType[client] = RSP_TARGET_SELECT_NONE;
    g_bTargetSelectionPending[client] = false;
    g_bTargetSelectionForceDisplay[client] = false;
    g_bTargetSelectionInitialized[client] = false;
    g_iTargetSelectionCount[client] = 0;
    g_iTargetSelectionRound[client] = 0;
    for (int selectionIndex = 0; selectionIndex <= MAXPLAYERS; selectionIndex++)
    {
        g_iTargetSelectionUserIds[client][selectionIndex] = 0;
        g_eTargetSelectionPowerSnapshot[client][selectionIndex] = RSP_None;
        g_iTargetSelectionTeamSnapshot[client][selectionIndex] = 0;
    }
    g_bThiefApplyingStolenPower[client] = false;
    g_iThiefSourceUserId[client] = 0;
    g_eThiefSourcePower[client] = RSP_None;
    g_fSoldierDamageMultiplier[client] = 1.0;
    g_iCurserEnemyHitCounter[client] = 0;
    g_iCurserResolvedEnemyHitCounter[client] = 0;
    g_bGravityStateSaved[client] = false;
    g_bOldGravityValid[client] = false;
    g_bMoveSpeedStateSaved[client] = false;
    g_bOldMoveSpeedValid[client] = false;
    g_fOldGravity[client] = 1.0;
    g_fLowGravityMultiplier[client] = 0.0;
    g_fOldMoveSpeed[client] = 1.0;
    g_iOldRamboHealth[client] = 100;
    g_iRamboRolledBonus[client] = 0;
    g_fOldModelScale[client] = 1.0;
    g_bModelScaleStateSaved[client] = false;
    g_bOldModelScaleValid[client] = false;
    g_fOldViewOffset[client][0] = 0.0;
    g_fOldViewOffset[client][1] = 0.0;
    g_fOldViewOffset[client][2] = 0.0;
    g_bOldViewOffsetValid[client] = false;
    g_bOldViewOffsetWasDucked[client] = false;
    g_fSelfModelScaleRatio[client] = 1.0;
    g_fGiantSelfScale[client] = 1.0;
    g_iGiantOldMaxHealth[client] = 100;
    g_bGiantHealthStateSaved[client] = false;
    g_iHealingAngelOldMaxHealth[client] = 100;
    g_bHealingAngelMaxHealthStateSaved[client] = false;
    g_fHealingAngelNextUseTime[client] = 0.0;
    g_bBlackoutActive[client] = false;
    g_bBlackoutUsedThisAssignment[client] = false;
    g_iBlackoutRound[client] = 0;
    g_hBlackoutRefadeTimer[client] = null;
    g_fOldCollisionMins[client][0] = 0.0;
    g_fOldCollisionMins[client][1] = 0.0;
    g_fOldCollisionMins[client][2] = 0.0;
    g_fOldCollisionMaxs[client][0] = 0.0;
    g_fOldCollisionMaxs[client][1] = 0.0;
    g_fOldCollisionMaxs[client][2] = 0.0;
    g_bOldCollisionBoundsValid[client] = false;
    g_bDisguiseApplied[client] = false;
    g_bDisguiseDeathTransition[client] = false;
    g_fDisguiseDeathTransitionUntil[client] = 0.0;
    g_sDisguiseOriginalModel[client][0] = '\0';
    g_bZombieUsedThisRound[client] = false;
    g_bZombieRespawnPending[client] = false;
    g_iZombieRespawnRound[client] = 0;
    g_hZombieRespawnTimer[client] = null;
    g_fNextSkillUseTime[client] = 0.0;
    g_fReverseControlsUntil[client] = 0.0;
    g_iReverseControlsRound[client] = 0;
    g_iReverseControlsOwnerUserId[client] = 0;
    g_fGhostDeathRevealUntil[client] = 0.0;
    g_hSkillReadyTimer[client] = null;
    g_fGodModeUntil[client] = 0.0;
    g_fZombieDropCleanupUntil[client] = 0.0;
    g_iZombieDroppedWeaponCount[client] = 0;
    g_iZombieDroppedCleanupAttempts[client] = 0;
    if (g_hZombieDroppedCleanupTimer[client] != null)
    {
        delete g_hZombieDroppedCleanupTimer[client];
        g_hZombieDroppedCleanupTimer[client] = null;
    }
    for (int itemIndex = 0; itemIndex < RSP_ZOMBIE_DROPPED_WEAPONS; itemIndex++)
    {
        g_iZombieDroppedWeaponRefs[client][itemIndex] = 0;
    }
    g_fArmouredDamageReduction[client] = RSP_ARMOURED_REDUCTION_MIN;
    g_fFrozenUntil[client] = 0.0;
    g_iCryoOwnerUserId[client] = 0;
    g_fNextDisorientTime[client] = 0.0;
    g_fDisorientTargetYaw[client] = 0.0;
    g_fDisorientViewUntil[client] = 0.0;
    g_iDisorientOwnerUserId[client] = 0;
    g_iCryoChancePercent[client] = 0;
    g_iDisorientChancePercent[client] = 0;
    g_iConcussionChancePercent[client] = 0;
    g_iVampirismDamageAttackerUserId[client] = 0;
    g_iVampirismHealthBeforeDamage[client] = 0;
    g_iVampirismDamageRound[client] = 0;
    g_fVampirismHealRemainder[client] = 0.0;
    g_bToxicSmokeDeathPending[client] = false;
    g_iToxicSmokeDeathOwnerUserId[client] = 0;
    g_iToxicSmokeDeathRound[client] = 0;
    g_fDoubleJumpReadyTime[client] = 0.0;
    g_bDoubleJumpWasDown[client] = false;
    g_fReviverNextUseTime[client] = 0.0;
    g_iMedicCharges[client] = 0;
    g_hReviverReadyTimer[client] = null;
    g_iReviverOwnerUserId[client] = 0;
    g_bThornsDamagePending[client] = false;
    g_iThornsAttackerUserId[client] = 0;
    g_iThornsHealthBeforeDamage[client] = 0;
    g_iThornsDamageRound[client] = 0;
    g_iThornsInflictorRef[client] = 0;
    g_fThornsReflectRemainder[client] = 0.0;
    g_bThornsReflectedDeathPending[client] = false;
    g_iThornsReflectedOwnerUserId[client] = 0;
    g_iThornsReflectedDeathRound[client] = 0;
    g_iThornsReflectedOwnerCashBefore[client] = -1;
    g_bDamagerDeathPending[client] = false;
    g_iDamagerDeathOwnerUserId[client] = 0;
    g_iDamagerDeathRound[client] = 0;
    g_iDamagerCashOwnerUserId[client] = 0;
    g_iDamagerCashBefore[client] = -1;
    g_iDamagerCashRound[client] = 0;
    g_iDamagerKillCount[client] = 0;
    g_bDamagerCashCorrectionQueued[client] = false;
    if (g_hNoclipTimer[client] != null)
    {
        delete g_hNoclipTimer[client];
        g_hNoclipTimer[client] = null;
    }
    g_bNoclipActive[client] = false;
    g_bNoclipWindowOpen[client] = false;
    g_bNoclipDamageRestoreQueued[client] = false;
    g_fNoclipExpiresAt[client] = 0.0;
    g_fNoclipNextSafeCheckTime[client] = 0.0;
    g_iNoclipOldMoveType[client] = view_as<int>(MOVETYPE_WALK);
    g_bNoclipLastSafeValid[client] = false;
    g_fNoclipLastSafeOrigin[client][0] = 0.0;
    g_fNoclipLastSafeOrigin[client][1] = 0.0;
    g_fNoclipLastSafeOrigin[client][2] = 0.0;
    g_bPhoenixUsedThisRound[client] = false;
    g_bResurrectionUsedThisRound[client] = false;
    g_bPowerRespawnPending[client] = false;
    g_iPowerRespawnRound[client] = 0;
    g_iPowerRespawnAttempts[client] = 0;
    g_iPowerRespawnKind[client] = 0;
    g_bDeathExplosionPending[client] = false;
    g_iDeathExplosionOwnerTeam[client] = 0;
    g_iDeathExplosionOwnerUserId[client] = 0;
    g_iDeathExplosionRound[client] = 0;
    g_fDeathExplosionOrigin[client][0] = 0.0;
    g_fDeathExplosionOrigin[client][1] = 0.0;
    g_fDeathExplosionOrigin[client][2] = 0.0;
    if (g_hPowerRespawnTimer[client] != null)
    {
        delete g_hPowerRespawnTimer[client];
        g_hPowerRespawnTimer[client] = null;
    }
    g_bLastSmokeWasToxic[client] = false;
    g_bLastSmokeWasHealing[client] = false;
    g_fLastSmokeThrowTime[client] = 0.0;
    g_iLastSmokeThrowRound[client] = 0;
    g_iLastSmokeThrowTeam[client] = 0;
    g_fSpeedBonus[client] = 0.0;
    g_fRapidFireMultiplier[client] = 1.0;
    g_iLastFiredWeaponRef[client] = 0;
    g_iDisarmChancePercent[client] = 0;
    g_iRichBoyRolledBonus[client] = 0;
    g_fSoldierDamageMultiplier[client] = 1.0;
    g_bDisarmPending[client] = false;
    g_iPendingDropWeaponRef[client] = 0;
    g_hRegenTimer[client] = null;
    g_iBlindCheckRound[client] = 0;
    g_hBlindCheckTimer[client] = null;
    if (g_hLongFlashTimer[client] != null)
    {
        delete g_hLongFlashTimer[client];
        g_hLongFlashTimer[client] = null;
    }
    g_iLongFlashCheckRound[client] = 0;
    g_iLongFlashCheckAttempts[client] = 0;
    g_iZombieRespawnAttempts[client] = 0;
    g_bZombieCleanupQueued[client] = false;
    g_iZombieCleanupRound[client] = 0;
    g_iZombieLoadoutRound[client] = 0;
    g_bZombieLoadoutApplying[client] = false;
    if (g_hPistolRestoreTimer[client] != null)
    {
        delete g_hPistolRestoreTimer[client];
        g_hPistolRestoreTimer[client] = null;
    }
    g_bGhostNeedsDefaultPistol[client] = false;
    g_iPistolRestoreAttempts[client] = 0;
    g_fLastDeadlyFlashThrowTime[client] = 0.0;
    g_iLastDeadlyFlashThrowRound[client] = 0;
    g_bLastFlashWasDeadly[client] = false;
    g_bLastFlashWasLong[client] = false;
    g_fLastLongFlashThrowTime[client] = 0.0;
    g_iLastLongFlashThrowRound[client] = 0;
    g_bHadDeadlyFlashThisRound[client] = false;
    g_bLastHEWasExecutioner[client] = false;
    g_bLastHEWasEnder[client] = false;
    g_fLastHEThrowTime[client] = 0.0;
    g_iLastHERound[client] = 0;
    g_bDeadlyFlashForceKill[client] = false;
    g_bFlashKillPending[client] = false;
    g_bFlashKillFallback[client] = false;
    g_iFlashKillOwnerUserId[client] = 0;
    g_bFlashScoreRepairPending[client] = false;
    g_iFlashScoreRepairOwnerUserId[client] = 0;
    g_iFlashScoreRepairVictimTeam[client] = 0;
    g_bExecutionerHEKillPending[client] = false;
    g_iExecutionerHEKillOwnerUserId[client] = 0;
    g_iBurnOwnerUserId[client] = 0;
    g_iBurnOwnerRound[client] = 0;
    g_fBurnOwnerUntil[client] = 0.0;
    g_bIncendiaryArmorRestorePending[client] = false;
    g_iIncendiaryArmorRestoreValue[client] = 0;
    g_iIncendiaryArmorRestoreRound[client] = 0;
    g_bAimbotArmorRestorePending[client] = false;
    g_iAimbotArmorRestoreValue[client] = 0;
    g_iAimbotArmorRestoreRound[client] = 0;
    g_bBurnDeathPending[client] = false;
    g_iBurnDeathOwnerUserId[client] = 0;
    g_iBurnDeathRound[client] = 0;
    g_bTeslaDeathDissolvePending[client] = false;
    g_iTeslaDeathDissolveRound[client] = 0;
    g_fTeslaDeathDissolveTime[client] = 0.0;
    g_iTeslaDeathOwnerUserId[client] = 0;
    g_bTeslaRagdollDirectionValid[client] = false;
    g_bTeslaHeadshotPending[client] = false;
    g_iTeslaHeadshotRound[client] = 0;
    g_fTeslaHeadshotTime[client] = 0.0;
    g_bTeslaHitFeedbackPending[client] = false;
    g_iTeslaHitFeedbackOwnerUserId[client] = 0;
    g_iTeslaHitFeedbackRound[client] = 0;
    g_iTeslaHitFeedbackHitgroup[client] = 0;
    g_iTeslaHitFeedbackSerial[client] = 0;
    g_fTeslaHitFeedbackTime[client] = 0.0;
    g_bBurnScoreRepairPending[client] = false;
    g_iBurnScoreRepairOwnerUserId[client] = 0;
    g_iBurnScoreRepairVictimTeam[client] = 0;
    g_bBurnVictimWasSuicide[client] = false;

    // 5.0 additions: initialize all per-slot state explicitly on connect/disconnect.
    g_iExplosiveBulletsChancePercent[client] = 0;
    g_iExplosiveBulletLastImpactTick[client] = -1;
    g_iKnockupChancePercent[client] = 0;
    g_bExplosiveBulletDamageInProgress[client] = false;
    g_bExplosiveBulletDeathPending[client] = false;
    g_iExplosiveBulletDeathOwnerUserId[client] = 0;
    g_iExplosiveBulletDeathRound[client] = 0;
    g_iExpensiveAmmoOwnerUserId[client] = 0;
    g_iExpensiveAmmoRound[client] = 0;
    g_iExpensiveAmmoPendingShots[client] = 0;
    g_bExpensiveAmmoFrameQueued[client] = false;
    g_iExpensiveAmmoShotTick[client] = 0;
    g_iLastFriendlyTraceTick[client] = 0;
    g_iHackerOwnerUserId[client] = 0;
    g_iHackerRound[client] = 0;
    if (g_hHackerRadarReapplyTimer[client] != null)
    {
        delete g_hHackerRadarReapplyTimer[client];
        g_hHackerRadarReapplyTimer[client] = null;
    }
    g_bHackerRadarFlashStateSaved[client] = false;
    g_bHackerRadarFlashOverrideActive[client] = false;
    g_fHackerOriginalFlashDuration[client] = 0.0;
    g_fHackerOriginalFlashMaxAlpha[client] = 255.0;
    g_fHackerRealFlashUntil[client] = 0.0;
    g_iHackerRadarPendingOwnerUserId[client] = 0;
    g_bGiantEffectActive[client] = false;
    g_iGiantOwnerUserId[client] = 0;
    g_fGiantOldScale[client] = 1.0;
    g_iSapperSpeedPercent[client] = 0;
    g_bSapperPlantAnimationActive[client] = false;
    g_iSapperViewModelRef[client] = INVALID_ENT_REFERENCE;
    g_bSapperViewModelRateSaved[client] = false;
    g_fSapperViewModelOriginalRate[client] = 1.0;
    g_bSapperPlayerRateSaved[client] = false;
    g_fSapperPlayerOriginalRate[client] = 1.0;
    g_iMachetePendingAttackerUserId[client] = 0;
    g_iMachetePendingRound[client] = 0;
}

bool IsSupportedMap()
{
    // RSP is available on every CS:S map. Keep this legacy helper so existing
    // runtime guards remain centralized, but do not whitelist or blacklist map prefixes.
    return true;
}

void DetectCurrentMap()
{
    g_bSupportedMap = IsSupportedMap();
}

RSPClientLanguage GetRSPClientLanguage(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return RSP_LANG_EN;
    }

    char languageCode[16];
    GetLanguageInfo(GetClientLanguage(client), languageCode, sizeof(languageCode));

    // Polish is the only non-English language built into this RSP release.
    // Every other client language intentionally uses the English fallback.
    if (StrEqual(languageCode, "pl", false) || StrEqual(languageCode, "pol", false) ||
        StrContains(languageCode, "pl-", false) == 0 || StrContains(languageCode, "pl_", false) == 0)
    {
        return RSP_LANG_PL;
    }

    return RSP_LANG_EN;
}

bool IsPolishClient(int client)
{
    return GetRSPClientLanguage(client) == RSP_LANG_PL;
}

void PrintRSPTargetEffectNotice(int target, int actor, RSPTargetNotice notice, float numericValue = 0.0)
{
    if (target < 1 || target > MaxClients || actor < 1 || actor > MaxClients ||
        target == actor || !IsClientInGame(target) || !IsClientInGame(actor) ||
        !IsValidPlayingClient(target) || !IsValidPlayingClient(actor))
    {
        return;
    }

    char actorColor[16];
    int actorTeam = GetClientTeam(actor);
    if (actorTeam == CS_TEAM_CT)
    {
        strcopy(actorColor, sizeof(actorColor), "\x0799CCFF");
    }
    else if (actorTeam == CS_TEAM_T)
    {
        strcopy(actorColor, sizeof(actorColor), "\x07FF4040");
    }
    else
    {
        strcopy(actorColor, sizeof(actorColor), "\x04");
    }

    RSPClientLanguage language = GetRSPClientLanguage(target);
    char actorLabel[24];
    switch (language)
    {
        case RSP_LANG_PL: strcopy(actorLabel, sizeof(actorLabel), "Gracz");
        default: strcopy(actorLabel, sizeof(actorLabel), "Player");
    }
    char suffix[192];
    char valueText[24];
    suffix[0] = '\0';
    Format(valueText, sizeof(valueText), "%.2f", numericValue);
    if (language != RSP_LANG_EN)
    {
        ReplaceString(valueText, sizeof(valueText), ".", ",");
    }

    switch (notice)
    {
        case RSP_NOTICE_BANKRUPT:
        {
            switch (language)
            {
                case RSP_LANG_PL: strcopy(suffix, sizeof(suffix), "wyzerował Ci gotówkę.");
                default: strcopy(suffix, sizeof(suffix), "reduced your cash to zero.");
            }
        }
        case RSP_NOTICE_EXTORTION:
        {
            switch (language)
            {
                case RSP_LANG_PL: strcopy(suffix, sizeof(suffix), "sprawił, że płacisz $50 za każdy strzał do śmierci lub końca rundy.");
                default: strcopy(suffix, sizeof(suffix), "made you pay $50 for every shot until you die or the round ends.");
            }
        }
        case RSP_NOTICE_HACKER:
        {
            switch (language)
            {
                case RSP_LANG_PL: strcopy(suffix, sizeof(suffix), "wyłączył Ci radar do śmierci lub końca rundy.");
                default: strcopy(suffix, sizeof(suffix), "disabled your radar until you die or the round ends.");
            }
        }
        case RSP_NOTICE_HACKER_PARTIAL:
        {
            switch (language)
            {
                case RSP_LANG_PL: strcopy(suffix, sizeof(suffix), "zakłócił Twoje kontakty na radarze do śmierci lub końca rundy.");
                default: strcopy(suffix, sizeof(suffix), "jammed your radar contacts until you die or the round ends.");
            }
        }
        case RSP_NOTICE_THIEF:
        {
            switch (language)
            {
                case RSP_LANG_PL: strcopy(suffix, sizeof(suffix), "ukradł Ci Twoją super moc!");
                default: strcopy(suffix, sizeof(suffix), "stole your superpower!");
            }
        }
        case RSP_NOTICE_DUPLICATOR:
        {
            switch (language)
            {
                case RSP_LANG_PL: strcopy(suffix, sizeof(suffix), "skopiował Twoją super moc.");
                default: strcopy(suffix, sizeof(suffix), "copied your superpower.");
            }
        }
        case RSP_NOTICE_CURSER:
        {
            switch (language)
            {
                case RSP_LANG_PL: strcopy(suffix, sizeof(suffix), "nałożył na Ciebie klątwę: tracisz 5 HP za każdy niecelny strzał do śmierci lub końca rundy.");
                default: strcopy(suffix, sizeof(suffix), "cursed you: every missed shot costs 5 HP until you die or the round ends.");
            }
        }
        case RSP_NOTICE_SCIENTIST:
        {
            switch (language)
            {
                case RSP_LANG_PL: Format(suffix, sizeof(suffix), "powiększył Twój model do x%s.", valueText);
                default: Format(suffix, sizeof(suffix), "enlarged your model to x%s.", valueText);
            }
        }
        case RSP_NOTICE_BLACKOUT:
        {
            switch (language)
            {
                case RSP_LANG_PL: strcopy(suffix, sizeof(suffix), "nałożył na Ciebie Blackout. Strzelaj, aby rozjaśnić ekran.");
                default: strcopy(suffix, sizeof(suffix), "applied Blackout to you. Fire to clear your screen.");
            }
        }
        case RSP_NOTICE_GROUNDER:
        {
            switch (language)
            {
                case RSP_LANG_PL: strcopy(suffix, sizeof(suffix), "zablokował Ci skakanie do śmierci lub końca rundy.");
                default: strcopy(suffix, sizeof(suffix), "blocked your ability to jump until you die or the round ends.");
            }
        }
        case RSP_NOTICE_WEAPON_SWAP:
        {
            switch (language)
            {
                case RSP_LANG_PL: strcopy(suffix, sizeof(suffix), "wymienił się z Tobą bronią.");
                default: strcopy(suffix, sizeof(suffix), "swapped weapons with you.");
            }
        }
    }

    PrintToChat(target, "\x07FF4040[RSP]\x01 %s %s%N\x01 %s", actorLabel, actorColor, actor, suffix);
}

void PrintRSPChameleonDuplicateNotice(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    char notice[192];
    switch (GetRSPClientLanguage(client))
    {
        case RSP_LANG_PL: strcopy(notice, sizeof(notice), "Gracz, którego zabiłeś, miał tę samą super moc. Nie doszło do skopiowania.");
        default: strcopy(notice, sizeof(notice), "The player you killed had the same superpower. No copy was made.");
    }
    PrintToChat(client, "\x07FF66CC[RSP]\x01 %s", notice);
}

void PrintRSPAvengerDuplicateNotice(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    char notice[192];
    switch (GetRSPClientLanguage(client))
    {
        case RSP_LANG_PL: strcopy(notice, sizeof(notice), "Twój sojusznik również miał moc Avenger, więc nie została ci ona przydzielona.");
        default: strcopy(notice, sizeof(notice), "Your teammate also had Avenger, so the power was not assigned to you.");
    }
    PrintToChat(client, "\x07FF66CC[RSP]\x01 %s", notice);
}

bool UsesDecimalComma(RSPClientLanguage language)
{
    return language == RSP_LANG_PL;
}

void CopyPowerDescriptionForLanguage(RSPClientLanguage language, int powerIndex, char[] description, int maxlen)
{
    switch (language)
    {
        case RSP_LANG_PL: strcopy(description, maxlen, g_sPowerDescriptions[powerIndex]);
        default: strcopy(description, maxlen, g_sPowerDescriptionsEn[powerIndex]);
    }
}


void PrintRSPToggleNoticeAll(bool enabled)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client))
        {
            continue;
        }

        RSPClientLanguage language = GetRSPClientLanguage(client);
        if (enabled)
        {
            switch (language)
            {
                case RSP_LANG_PL: PrintToChat(client, "\x04[RSP]\x01 Random Super Powers zostało włączone. Każdy gracz otrzyma losową moc w następnej rundzie.");
                default: PrintToChat(client, "\x04[RSP]\x01 Random Super Powers enabled. Each player receives a random power next round.");
            }
        }
        else
        {
            switch (language)
            {
                case RSP_LANG_PL: PrintToChat(client, "\x04[RSP]\x01 Random Super Powers zostało wyłączone. Stan graczy został przywrócony.");
                default: PrintToChat(client, "\x04[RSP]\x01 Random Super Powers disabled. Player state restored.");
            }
        }
    }
}

public Action Command_Enable(int client, int args)
{
    DetectCurrentMap();
    if (!g_bSupportedMap)
    {
        if (client >= 1 && client <= MaxClients && IsClientInGame(client))
        {
            PrintToChat(client, "\x04[RSP]\x01 RSP jest dostępne na każdej mapie.");
        }
        return Plugin_Handled;
    }

    if (g_bEnabled)
    {
        if (client >= 1 && client <= MaxClients && IsClientInGame(client))
        {
            PrintToChat(client, "\x04[RSP]\x01 RSP jest już włączone.");
        }
        return Plugin_Handled;
    }

    g_bEnabled = true;
    PrintRSPToggleNoticeAll(true);

    return Plugin_Handled;
}

public Action Command_Disable(int client, int args)
{
    if (!g_bEnabled)
    {
        if (client >= 1 && client <= MaxClients && IsClientInGame(client))
        {
            PrintToChat(client, "\x04[RSP]\x01 RSP jest już wyłączone.");
        }
        return Plugin_Handled;
    }
    g_bEnabled = false;
    g_bRoundEnding = false;
    g_bRoundReady = false;
    ClearDeferredEliminationState();
    ClearToxicSmokeClouds();
    ClearIncendiaryTracking();
    StopGhostMaintenanceTimer();
    StopWallhackTimer();
    ClearAllReplicaEntities();
    ClearAllBuildables();
    ResetAllClientPowers(true);
    for (int player = 1; player <= MaxClients; player++)
    {
        if (IsClientInGame(player) && IsPlayerAlive(player) && g_bGhostNeedsDefaultPistol[player])
        {
            QueueDefaultPistolRestore(player);
        }
    }
    ClearFlashRecords();
    ClearVisualTracking();
    PrintRSPToggleNoticeAll(false);

    return Plugin_Handled;
}

public Action Command_Status(int client, int args)
{
    if (client >= 1 && client <= MaxClients && IsClientInGame(client))
    {
        PrintToChat(client, "\x04[RSP]\x01 Tryb: %s | Mapa: %s | Runda aktywna: %s",
            g_bEnabled ? "włączony" : "wyłączony",
            g_bSupportedMap ? "obsługiwana" : "nieobsługiwana",
            g_bRoundReady ? "tak" : "nie");
    }
    return Plugin_Handled;
}

public Action Command_PowersList(int client, int args)
{
    // Generate output solely from the selectable pool. Filter invalid/duplicate IDs first,
    // then alphabetically sort by canonical English power name before numbering the rows.
    int sortedPowerIndexes[sizeof(g_RSPSelectablePowers)];
    bool seen[RSP_PowerCount];
    for (int i = 0; i < view_as<int>(RSP_PowerCount); i++)
    {
        seen[i] = false;
    }

    int powerCount = 0;
    bool realClient = (client >= 1 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client));
    for (int i = 0; i < sizeof(g_RSPSelectablePowers); i++)
    {
        int powerIndex = view_as<int>(g_RSPSelectablePowers[i]);
        if (powerIndex <= view_as<int>(RSP_None) || powerIndex >= view_as<int>(RSP_PowerCount) ||
            seen[powerIndex] || g_sPowerNamesEn[powerIndex][0] == '\0')
        {
            continue;
        }
        seen[powerIndex] = true;
        sortedPowerIndexes[powerCount++] = powerIndex;
    }

    // Stable insertion sort; enum index is a deterministic tie-breaker for equal names.
    for (int i = 1; i < powerCount; i++)
    {
        int keyIndex = sortedPowerIndexes[i];
        char keyName[32];
        strcopy(keyName, sizeof(keyName), g_sPowerNamesEn[keyIndex]);
        int j = i - 1;
        while (j >= 0)
        {
            int currentIndex = sortedPowerIndexes[j];
            int compare = strcmp(g_sPowerNamesEn[currentIndex], keyName, false);
            if (compare < 0 || (compare == 0 && currentIndex <= keyIndex))
            {
                break;
            }
            sortedPowerIndexes[j + 1] = sortedPowerIndexes[j];
            j--;
        }
        sortedPowerIndexes[j + 1] = keyIndex;
    }

    int printedCount = 0;
    for (int i = 0; i < powerCount; i++)
    {
        int powerIndex = sortedPowerIndexes[i];
        char description[256];
        strcopy(description, sizeof(description), g_sPowerDescriptionsEn[powerIndex]);
        printedCount++;
        if (realClient)
        {
            PrintToConsole(client, "%02d. %s - %s", printedCount, g_sPowerNamesEn[powerIndex], description);
        }
        else
        {
            PrintToServer("%02d. %s - %s", printedCount, g_sPowerNamesEn[powerIndex], description);
        }
    }

    if (realClient)
    {
        PrintToConsole(client, "Total active powers: %d", printedCount);
    }
    else
    {
        PrintToServer("Total active powers: %d", printedCount);
    }
    return Plugin_Handled;
}

// Keep a respawning player's previous corpse as an independent cs_ragdoll entity.
// CS:S CCSPlayer::Spawn normally removes m_hRagdoll, and CreateRagdollEntity can reuse
// the same entity on a later death. Detach the handle before CS_RespawnPlayer to avoid
// both behaviors; track it by EntRef so edict-index reuse cannot delete a different entity.
void PreservePlayerRagdollBeforeRespawn(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !HasEntProp(client, Prop_Send, "m_hRagdoll"))
    {
        return;
    }

    int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
    if (ragdoll <= MaxClients || ragdoll >= RSP_MAX_ENTITIES || !IsValidEntity(ragdoll))
    {
        return;
    }

    char classname[32];
    GetEntityClassname(ragdoll, classname, sizeof(classname));
    if (!StrEqual(classname, "cs_ragdoll", false))
    {
        return;
    }

    int ragdollRef = EntIndexToEntRef(ragdoll);
    if (ragdollRef == INVALID_ENT_REFERENCE)
    {
        return;
    }

    // Reserve the body before detaching it. If we cannot clear the handle, undo the
    // tracking entry so the native player-spawn cleanup remains the owner of this body.
    g_iPreservedRagdollRefByEntity[ragdoll] = ragdollRef;
    SetEntPropEnt(client, Prop_Send, "m_hRagdoll", -1);
    if (GetEntPropEnt(client, Prop_Send, "m_hRagdoll") == ragdoll)
    {
        if (g_iPreservedRagdollRefByEntity[ragdoll] == ragdollRef)
        {
            g_iPreservedRagdollRefByEntity[ragdoll] = 0;
        }
    }
}

// Detached ragdolls are not covered by the player's normal m_hRagdoll cleanup anymore.
// Remove only the exact entities tracked by RSP at the round boundary (or plugin unload).
void ClearPreservedRagdolls()
{
    for (int slot = MaxClients + 1; slot < RSP_MAX_ENTITIES; slot++)
    {
        int ragdollRef = g_iPreservedRagdollRefByEntity[slot];
        if (ragdollRef == 0)
        {
            continue;
        }
        g_iPreservedRagdollRefByEntity[slot] = 0;

        int ragdoll = EntRefToEntIndex(ragdollRef);
        if (ragdoll <= MaxClients || ragdoll >= RSP_MAX_ENTITIES || !IsValidEntity(ragdoll))
        {
            continue;
        }

        char classname[32];
        GetEntityClassname(ragdoll, classname, sizeof(classname));
        if (StrEqual(classname, "cs_ragdoll", false))
        {
            RemoveEntity(ragdoll);
        }
    }
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    // Retire tracked Tesla dissolvers from the prior round before normal corpse cleanup.

    // Bodies detached by respawn powers belong to the previous round and must be
    // explicitly removed: the engine can no longer find them through m_hRagdoll.
    ClearPreservedRagdolls();

    // Keep the new round closed while the previous round's full state is restored.
    // Treat this as a cleanup phase even on the first round or after a manual restart.
    // The runtime is reopened only after every client/global reset has completed.
    g_bRoundReady = false;
    g_bRoundEnding = true;
    ClearDeferredEliminationState();

    ClearAllToxicAmmoEffects();

    for (int client = 1; client <= MaxClients; client++)
    {
        g_bHostPowerGrantedOutsideRound[client] = false;
        g_iInventorUsesThisRound[client] = 0;
        g_iMinerUsesThisRound[client] = 0;
        g_iGrounderRound[client] = 0;
        g_iGrounderOwnerUserId[client] = 0;
        g_bGrounderUsedThisAssignment[client] = false;
        g_bGiftUseWasDown[client] = false;
        g_fNextGiftUseTime[client] = 0.0;
        g_bAvengerConsumedThisRound[client] = false;
        ClearWeakeningAmmoState(client, true);
        // Deferred effects from the previous round must not cross the reset boundary.
        StopClientPistolRestoreTimer(client);
        StopRagdollForceHook(client);
        // Invalidate a radar packet queued during the previous round; its RequestFrame
        // callback will see the cleared flag and discard the stale packet.
        g_bRadarRewriteQueued[client] = false;
        g_iRadarQueuedCount[client] = 0;
    }
    ClearToxicSmokeClouds();
    ClearIncendiaryTracking();
    StopGhostMaintenanceTimer();
    StopWallhackTimer();
    // With no freeze duration, manual skills are ready immediately.
    g_bRoundFreezeEnded = (g_hMpFreezeTime != null && g_hMpFreezeTime.FloatValue <= 0.0);
    for (int target = 1; target <= MaxClients; target++)
    {
        g_bCurserTargetCursed[target] = false;
        g_iCurserTargetCurseRound[target] = 0;
        g_iCurserOwnerUserId[target] = 0;
    }
    for (int client = 1; client <= MaxClients; client++)
    {
        g_bGamblerPendingSelection[client] = false;
        g_bGamblerChatIntercept[client] = false;
        g_bGamblerApplyingChoice[client] = false;
        g_iGamblerSelectedOfferIndex[client] = -1;
        g_iCurserEnemyHitCounter[client] = 0;
        g_iCurserResolvedEnemyHitCounter[client] = 0;
    }

    // The single authoritative reset for all client powers. Reset before changing the
    // round serial so old-round effects can restore their saved player/client state.
    ResetAllClientPowers(true);
    ClearAllReplicaEntities();
    ClearAllBuildables();
    ClearAllGiftEntities();
    ClearAllMinerMines();
    ClearRoundScopedExplosionEntities();
    ClearVisualTracking();
    ClearFlashRecords();

    // Clear all remaining round-scoped bookkeeping before opening the new round,
    // including when powers are disabled or the current map is unsupported.
    for (int client = 1; client <= MaxClients; client++)
    {
        // Invalidate any deferred Zombie inventory callback from the previous round.
        g_bZombieCleanupQueued[client] = false;
        g_iZombieCleanupRound[client] = 0;
        g_iZombieLoadoutRound[client] = 0;
        g_bZombieLoadoutApplying[client] = false;
        g_fZombieDropCleanupUntil[client] = 0.0;
        g_iBurnOwnerUserId[client] = 0;
        g_iBurnOwnerRound[client] = 0;
        g_fBurnOwnerUntil[client] = 0.0;
        g_bIncendiaryArmorRestorePending[client] = false;
        g_iIncendiaryArmorRestoreValue[client] = 0;
        g_iIncendiaryArmorRestoreRound[client] = 0;
        g_bAimbotArmorRestorePending[client] = false;
        g_iAimbotArmorRestoreValue[client] = 0;
        g_iAimbotArmorRestoreRound[client] = 0;
        g_bBurnDeathPending[client] = false;
        g_iBurnDeathOwnerUserId[client] = 0;
        g_iBurnDeathRound[client] = 0;
        g_bTeslaDeathDissolvePending[client] = false;
        g_iTeslaDeathDissolveRound[client] = 0;
        g_fTeslaDeathDissolveTime[client] = 0.0;
        g_bTeslaHeadshotPending[client] = false;
        g_iTeslaHeadshotRound[client] = 0;
        g_fTeslaHeadshotTime[client] = 0.0;
        g_bTeslaHitFeedbackPending[client] = false;
        g_iTeslaHitFeedbackOwnerUserId[client] = 0;
        g_iTeslaHitFeedbackRound[client] = 0;
        g_iTeslaHitFeedbackHitgroup[client] = 0;
        g_iTeslaHitFeedbackSerial[client] = 0;
        g_fTeslaHitFeedbackTime[client] = 0.0;
        // Pending death-score repair is also round-scoped. Clear it separately from
        // burn attribution so a delayed frame cannot repair cash in the next round.
        g_bBurnScoreRepairPending[client] = false;
        g_iBurnScoreRepairOwnerUserId[client] = 0;
        g_iBurnScoreRepairVictimTeam[client] = 0;
        g_bBurnVictimWasSuicide[client] = false;
        g_bToxicSmokeDeathPending[client] = false;
        g_iToxicSmokeDeathOwnerUserId[client] = 0;
        g_iToxicSmokeDeathRound[client] = 0;
        g_bFlashKillPending[client] = false;
        g_bFlashKillFallback[client] = false;
        g_iFlashKillOwnerUserId[client] = 0;
        g_bDeadlyFlashForceKill[client] = false;
        g_bFlashScoreRepairPending[client] = false;
        g_iFlashScoreRepairOwnerUserId[client] = 0;
        g_iFlashScoreRepairVictimTeam[client] = 0;
        g_iExecutionerPendingAttackerUserId[client] = 0;
        g_fGhostDeathRevealUntil[client] = 0.0;
        // Extortion is a target-side effect: the target may not own the power,
        // so ResetClientPower must not be relied on to erase this owner attribution.
        g_iExpensiveAmmoOwnerUserId[client] = 0;
        g_iExpensiveAmmoRound[client] = 0;
        g_iGrounderOwnerUserId[client] = 0;
        g_bGrounderUsedThisAssignment[client] = false;
        g_iWeakeningOwnerUserId[client] = 0;
        g_iCurserOwnerUserId[client] = 0;
        g_iReverseControlsOwnerUserId[client] = 0;
        g_iCryoOwnerUserId[client] = 0;
        g_iDisorientOwnerUserId[client] = 0;
        g_bZombieUsedThisRound[client] = false;
        g_bPhoenixUsedThisRound[client] = false;
        g_bResurrectionUsedThisRound[client] = false;
        g_fVampirismHealRemainder[client] = 0.0;
        g_fThornsReflectRemainder[client] = 0.0;
        g_bThornsDamagePending[client] = false;
        g_iThornsAttackerUserId[client] = 0;
        g_iThornsHealthBeforeDamage[client] = 0;
        g_iThornsDamageRound[client] = 0;
        g_iThornsInflictorRef[client] = 0;
        g_bThornsReflectedDeathPending[client] = false;
        g_iThornsReflectedOwnerUserId[client] = 0;
        g_iThornsReflectedDeathRound[client] = 0;
        g_iThornsReflectedOwnerCashBefore[client] = -1;
        g_bDamagerDeathPending[client] = false;
        g_iDamagerDeathOwnerUserId[client] = 0;
        g_iDamagerDeathRound[client] = 0;
        g_iDamagerCashOwnerUserId[client] = 0;
        g_iDamagerCashBefore[client] = -1;
        g_iDamagerCashRound[client] = 0;
        g_iDamagerKillCount[client] = 0;
        g_bDamagerCashCorrectionQueued[client] = false;
        g_iMedicCharges[client] = 0;
        g_fDoubleJumpReadyTime[client] = 0.0;
        g_bDoubleJumpWasDown[client] = false;
        g_bDeathExplosionPending[client] = false;
        g_iDeathExplosionOwnerTeam[client] = 0;
        g_iDeathExplosionOwnerUserId[client] = 0;
        g_iDeathExplosionRound[client] = 0;
        g_bExplosiveBulletDeathPending[client] = false;
        g_iExplosiveBulletDeathOwnerUserId[client] = 0;
        g_iExplosiveBulletDeathRound[client] = 0;
        g_iExplosiveBulletLastImpactTick[client] = -1;
        g_bExplosiveBulletDamageInProgress[client] = false;
        g_fFrozenUntil[client] = 0.0;
        g_iCryoOwnerUserId[client] = 0;
        g_fNextDisorientTime[client] = 0.0;
        g_fDisorientTargetYaw[client] = 0.0;
        g_fDisorientViewUntil[client] = 0.0;
        g_iDisorientOwnerUserId[client] = 0;
        g_iCryoChancePercent[client] = 0;
        g_iDisorientChancePercent[client] = 0;
    g_iConcussionChancePercent[client] = 0;
        g_iVampirismDamageAttackerUserId[client] = 0;
        g_iVampirismHealthBeforeDamage[client] = 0;
        g_iVampirismDamageRound[client] = 0;
        g_bLastSmokeWasToxic[client] = false;
        g_bLastSmokeWasHealing[client] = false;
        g_fLastSmokeThrowTime[client] = 0.0;
        g_iLastSmokeThrowRound[client] = 0;
        g_iLastSmokeThrowTeam[client] = 0;
        g_bZombieRespawnPending[client] = false;
        g_iZombieRespawnRound[client] = 0;
        g_iZombieRespawnAttempts[client] = 0;
        g_fNextSkillUseTime[client] = 0.0;
        g_fGodModeUntil[client] = 0.0;
        g_iZombieDroppedWeaponCount[client] = 0;
        g_iZombieDroppedCleanupAttempts[client] = 0;
        if (g_hZombieDroppedCleanupTimer[client] != null)
        {
            delete g_hZombieDroppedCleanupTimer[client];
            g_hZombieDroppedCleanupTimer[client] = null;
        }
        for (int itemIndex = 0; itemIndex < RSP_ZOMBIE_DROPPED_WEAPONS; itemIndex++)
        {
            g_iZombieDroppedWeaponRefs[client][itemIndex] = 0;
        }

        // Ghost/Zombie may have removed the default pistol. Queue a post-round-start
        // check after loadout setup, but before new powers are assigned.
        if (g_bEnabled && g_bSupportedMap && IsClientInGame(client) && IsPlayerAlive(client) &&
            g_bGhostNeedsDefaultPistol[client])
        {
            QueueDefaultPistolRestore(client);
        }

        // No active power or pending selection/transfer may retain the previous
        // round's identity, even when the plugin/map is disabled and serial won't advance.
        g_iAssignedRound[client] = 0;
        g_bThiefApplyingStolenPower[client] = false;
        g_iThiefSourceUserId[client] = 0;
        g_eThiefSourcePower[client] = RSP_None;
        for (int offer = 0; offer < RSP_GAMBLER_OPTIONS; offer++)
        {
            g_eGamblerOffers[client][offer] = RSP_None;
            g_iGamblerRamboBonus[client][offer] = 0;
            g_iGamblerRichBoyBonus[client][offer] = 0;
            g_fGamblerLowGravity[client][offer] = 0.0;
            g_fGamblerSpeedBonus[client][offer] = 0.0;
            g_iGamblerDisarmChance[client][offer] = 0;
            g_iGamblerLeechChance[client][offer] = 0;
            g_fGamblerModelScale[client][offer] = 0.0;
            g_fGamblerArmouredReduction[client][offer] = 0.0;
            g_fGamblerRapidFireMultiplier[client][offer] = 0.0;
            g_iGamblerCryoChance[client][offer] = 0;
            g_iGamblerDisorientChance[client][offer] = 0;
            g_iGamblerKnockupChance[client][offer] = 0;
        }
    }

    // Cleanup is complete. Re-open the round transition state only now, never before
    // old effects have had a chance to restore their saved player/client values.
    g_bRoundEnding = false;

    if (!g_bEnabled || !g_bSupportedMap)
    {
        // All stale client/global state is now cleared, but this round stays closed
        // and no new power assignment is scheduled.
        return;
    }

    // Publish the new round only after the entire old power state, every timer, and
    // all round-scoped bookkeeping have been cleared. Assignment remains delayed so
    // the engine can finish its round-start/loadout work first.
    g_iRoundSerial++;
    if (g_iRoundSerial <= 0)
    {
        g_iRoundSerial = 1;
    }
    g_bRoundReady = true;
    // Spectators do not receive an assignment callback of their own, so refresh their
    // two-team roster after every new round becomes ready as well as on team-switch.
    for (int viewer = 1; viewer <= MaxClients; viewer++)
    {
        if (IsClientInGame(viewer) && GetClientTeam(viewer) == CS_TEAM_SPECTATOR)
        {
            QueueObserverPowerRoster(viewer);
        }
    }
    CreateTimer(RSP_ASSIGN_DELAY, Timer_AssignRoundPowers, g_iRoundSerial, TIMER_FLAG_NO_MAPCHANGE);
}

public void Event_RoundFreezeEnd(Event event, const char[] name, bool dontBroadcast)
{
    g_bRoundFreezeEnded = true;
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    // Once a round end is accepted, no old-round respawn may execute during the
    // end-of-round delay. Elimination rounds with an eligible respawn must be held
    // in CS_OnTerminateRound before this event can be emitted; this is the final
    // safety boundary for objective/time/other accepted round endings and race paths.
    CancelPendingRespawnsAtRoundEnd();
    ClearDeferredEliminationState();
    // Do not remove deployed mines/gifts or completed Grounder effects here.
    // The next round_start performs the single authoritative round reset.
    if (!g_bEnabled || !g_bSupportedMap)
    {
        g_bRoundReady = false;
        g_bRoundEnding = false;
        StopGhostMaintenanceTimer();
        StopWallhackTimer();
        ClearToxicSmokeClouds();
        ClearIncendiaryTracking();
        ClearAllReplicaEntities();
        ClearAllBuildables();
        ResetAllClientPowers(true);
        ClearFlashRecords();
        ClearVisualTracking();
        return;
    }

    // Do not reset powers or cancel their existing effect timers here. The flag only
    // prevents new random assignments during the transition; existing powers remain live;
    // ongoing passive effects and already-running power timers are allowed to finish.
    // The single authoritative full cleanup happens at the next round_start, regardless
    // of mp_round_restart_delay. Hook/NoClip and other ongoing power effects remain
    // until round_start; pending life-respawn timers are cancelled immediately above
    // at this accepted round_end boundary so they cannot spawn players in intermission.
    g_bRoundEnding = true;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client >= 1 && client <= MaxClients && IsClientInGame(client))
    {
        ClearToxicAmmoEffect(client); // Defensive: a resurrected life starts without previous poison.
    }
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client))
    {
        return;
    }
    if (g_bEnabled && g_bSupportedMap && g_bRoundReady && !g_bRoundEnding &&
        g_iPower[client] == RSP_HealingAngel && g_iAssignedRound[client] == g_iRoundSerial)
    {
        SetRSPClientMaxHealth(client, RSP_HEALING_ANGEL_MAX_HEALTH);
        if (g_hRegenTimer[client] == null)
        {
            g_hRegenTimer[client] = CreateTimer(RSP_REGENERATION_INTERVAL, Timer_Regeneration,
                GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        }
    }
ScheduleDeferredEliminationChecks();
    ClearWeakeningAmmoState(client, true);
    g_bGiftUseWasDown[client] = false;


    StopRagdollForceHook(client);
    QueueRefreshActiveTargetSelections();

    // If a disguised player died, preserve the alternate model through the death
    // animation. Restore it as the player respawns, since the power was cleared on death.
    if (g_bDisguiseApplied[client] && g_iPower[client] != RSP_Impostor)
    {
        RestoreDisguiseModel(client);
    }
    else if (!g_bDisguiseApplied[client])
    {
        g_bDisguiseDeathTransition[client] = false;
        g_fDisguiseDeathTransitionUntil[client] = 0.0;
    }

    // Reapply target effects after the engine restores the player's HUD state on spawn.
    if (IsRSPRadarDisabled(client))
    {
        ApplyHackerRadarHud(client, false);
    }
    // A fresh life must not inherit a pending Ghost death-transition reveal.
    g_fGhostDeathRevealUntil[client] = 0.0;

    // A fresh life must not inherit burn attribution from the previous life.
    g_iBurnOwnerUserId[client] = 0;
    g_iBurnOwnerRound[client] = 0;
    g_fBurnOwnerUntil[client] = 0.0;
    g_bIncendiaryArmorRestorePending[client] = false;
    g_iIncendiaryArmorRestoreValue[client] = 0;
    g_iIncendiaryArmorRestoreRound[client] = 0;
    g_bAimbotArmorRestorePending[client] = false;
    g_iAimbotArmorRestoreValue[client] = 0;
    g_iAimbotArmorRestoreRound[client] = 0;
    g_bBurnDeathPending[client] = false;
    g_iBurnDeathOwnerUserId[client] = 0;
    g_iBurnDeathRound[client] = 0;
    g_bTeslaDeathDissolvePending[client] = false;
    g_iTeslaDeathDissolveRound[client] = 0;
    g_fTeslaDeathDissolveTime[client] = 0.0;
    g_iTeslaDeathOwnerUserId[client] = 0;
    g_bTeslaRagdollDirectionValid[client] = false;

    // Queue an immediate sprite refresh after spawn; the bounded maintenance timer keeps it continuous.
    QueueWallhackRefresh();

    // Always verify the secondary slot after the engine has completed spawn loadout.
    // This also recovers a missing default pistol after Zombie/Ghost removed weapon entities.
    if (g_bGhostNeedsDefaultPistol[client])
    {
        QueueDefaultPistolRestore(client);
    }

    if (!g_bEnabled || !g_bSupportedMap || !g_bRoundReady || g_bRoundEnding || g_bZombieRespawnPending[client])
    {
        return;
    }

    if (g_iAssignedRound[client] != g_iRoundSerial)
    {
        CreateTimer(0.10, Timer_AssignSinglePower, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    }
}

void StopClientPistolRestoreTimer(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    if (g_hPistolRestoreTimer[client] != null)
    {
        delete g_hPistolRestoreTimer[client];
        g_hPistolRestoreTimer[client] = null;
    }
    g_iPistolRestoreAttempts[client] = 0;
}

void QueueDefaultPistolRestore(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))
    {
        return;
    }

    if (g_hPistolRestoreTimer[client] != null)
    {
        delete g_hPistolRestoreTimer[client];
        g_hPistolRestoreTimer[client] = null;
    }

    g_iPistolRestoreAttempts[client] = 0;
    g_hPistolRestoreTimer[client] = CreateTimer(RSP_GHOST_PISTOL_RESTORE_DELAY,
        Timer_RestoreGhostDefaultPistol, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_RestoreGhostDefaultPistol(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))
    {
        if (client >= 1 && client <= MaxClients)
        {
            if (g_hPistolRestoreTimer[client] == timer)
            {
                g_hPistolRestoreTimer[client] = null;
            }
        }
        return Plugin_Stop;
    }

    if (g_hPistolRestoreTimer[client] == timer)
    {
        g_hPistolRestoreTimer[client] = null;
    }

    // Ghost must remain firearm-free. Zombie respawn must keep its knife-only inventory.
    // Keep the restore marker for the next ordinary spawn.
    if (g_iPower[client] == RSP_Ghost ||
        (g_iPower[client] == RSP_Zombie && g_bZombieUsedThisRound[client]))
    {
        g_bGhostNeedsDefaultPistol[client] = true;
        return Plugin_Stop;
    }

    int team = GetClientTeam(client);
    if (team != CS_TEAM_CT && team != CS_TEAM_T)
    {
        return Plugin_Stop;
    }

    int pistol = GetPlayerWeaponSlot(client, 1);
    if (pistol > MaxClients && IsValidEntity(pistol))
    {
        g_bGhostNeedsDefaultPistol[client] = false;
        g_iPistolRestoreAttempts[client] = 0;
        return Plugin_Stop;
    }

    // A missing pistol can be caused by the spawn inventory still being rebuilt.
    // Retry a bounded number of times instead of issuing client commands in a loop.
    g_bGhostNeedsDefaultPistol[client] = true;
    char pistolClass[32];
    strcopy(pistolClass, sizeof(pistolClass), team == CS_TEAM_CT ? "weapon_usp" : "weapon_glock");
    int given = GivePlayerItem(client, pistolClass);
    if (given > MaxClients && IsValidEntity(given))
    {
        g_bGhostNeedsDefaultPistol[client] = false;
        g_iPistolRestoreAttempts[client] = 0;
        return Plugin_Stop;
    }

    g_iPistolRestoreAttempts[client]++;
    if (g_iPistolRestoreAttempts[client] < RSP_PISTOL_RESTORE_MAX_ATTEMPTS)
    {
        g_hPistolRestoreTimer[client] = CreateTimer(RSP_GHOST_PISTOL_RESTORE_DELAY,
            Timer_RestoreGhostDefaultPistol, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Stop;
    }

    // Leave the marker set. A later spawn will get a fresh, bounded retry sequence.
    return Plugin_Stop;
}

bool HasFlashbangInInventory(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !HasEntProp(client, Prop_Send, "m_hMyWeapons"))
    {
        return false;
    }

    int count = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
    for (int index = 0; index < count; index++)
    {
        int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", index);
        if (weapon <= MaxClients || !IsValidEntity(weapon))
        {
            continue;
        }

        char classname[32];
        GetEntityClassname(weapon, classname, sizeof(classname));
        if (StrEqual(classname, "weapon_flashbang", false))
        {
            return true;
        }
    }

    return false;
}

void TryAvengerInheritanceFromDeath(int deadClient, RSPPower deadPower, int deadTeam)
{
    if (!g_bEnabled || !g_bSupportedMap || !g_bRoundReady || g_bRoundEnding ||
        !IsRSPPowerRuntimeActive() || !IsRSPPowerSelectable(deadPower) ||
        deadClient < 1 || deadClient > MaxClients || !IsClientInGame(deadClient) ||
        (deadTeam != CS_TEAM_T && deadTeam != CS_TEAM_CT))
    {
        return;
    }

    int deadUserId = GetClientUserId(deadClient);
    if (deadUserId == 0)
    {
        return;
    }

    // Each living Avenger receives exactly the first eligible dead teammate's power.
    // Roll values are copied synchronously through the established thief-source path,
    // while the dead player's original power state has not yet been reset.
    for (int recipient = 1; recipient <= MaxClients; recipient++)
    {
        if (recipient == deadClient || !IsValidPlayingClient(recipient) || !IsPlayerAlive(recipient) ||
            GetClientTeam(recipient) != deadTeam || g_iAssignedRound[recipient] != g_iRoundSerial ||
            g_iPower[recipient] != RSP_Avenger || g_bAvengerConsumedThisRound[recipient])
        {
            continue;
        }

        if (deadPower == RSP_Avenger)
        {
            // Like Chameleon, a duplicate Avenger cannot inherit itself. Do not consume
            // the power: a later eligible teammate death may still grant a real power.
            PrintRSPAvengerDuplicateNotice(recipient);
            continue;
        }

        g_bAvengerConsumedThisRound[recipient] = true;
        g_bThiefApplyingStolenPower[recipient] = true;
        g_iThiefSourceUserId[recipient] = deadUserId;
        g_eThiefSourcePower[recipient] = deadPower;
        AssignPowerToClient(recipient, deadPower, false, false, false, false, false, true);
        g_bThiefApplyingStolenPower[recipient] = false;
        g_iThiefSourceUserId[recipient] = 0;
        g_eThiefSourcePower[recipient] = RSP_None;
    }
}

void ClearRSPIncomingTargetEffectsOnDeath(int target)
{
    if (target < 1 || target > MaxClients)
    {
        return;
    }

    // Grounder: remove the jump lock from this life. The activator's one-use charge
    // remains consumed, but the same target is clean after a same-round respawn.
    g_iGrounderRound[target] = 0;
    g_iGrounderOwnerUserId[target] = 0;

    // Curser: invalidate both the curse and any deferred shot-resolution snapshot.
    g_bCurserTargetCursed[target] = false;
    g_iCurserTargetCurseRound[target] = 0;
    g_iCurserOwnerUserId[target] = 0;
    g_iCurserEnemyHitCounter[target] = 0;
    g_iCurserResolvedEnemyHitCounter[target] = 0;

    // Extortion: cancel any queued shot batch before the player can respawn.
    g_iExpensiveAmmoOwnerUserId[target] = 0;
    g_iExpensiveAmmoRound[target] = 0;
    g_iExpensiveAmmoPendingShots[target] = 0;
    g_iExpensiveAmmoShotTick[target] = 0;
    g_bExpensiveAmmoFrameQueued[target] = false;
    g_iLastFriendlyTraceTick[target] = 0;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return Plugin_Continue;
    }
    int deathTeamForRoundCheck = GetClientTeam(client);
    ClearBlackoutEffect(client, true);
    if (g_bSpectatorActive[client])
    {
        StopSpectatorMode(client, false);
    }
    ClearToxicAmmoEffect(client); // Clear victim-side stacks before Resurrection can run.
    ClearRSPIncomingTargetEffectsOnDeath(client);

    // Snapshot the victim's current power and the native attacker before any death handler
    // can rewrite the event or reset either player's RSP state. Chameleon uses these
    // event-entry snapshots so its first enemy kill is not dependent on later handlers.
    RSPPower deadPower = g_iPower[client];
    int originalAttacker = GetClientOfUserId(event.GetInt("attacker"));
    RSPPower originalAttackerPower = RSP_None;
    int originalAttackerUserId = 0;
    if (originalAttacker >= 1 && originalAttacker <= MaxClients && IsClientInGame(originalAttacker))
    {
        originalAttackerPower = g_iPower[originalAttacker];
        originalAttackerUserId = GetClientUserId(originalAttacker);
    }

    if (g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive() &&
        originalAttacker >= 1 && originalAttacker <= MaxClients && originalAttacker != client &&
        IsValidPlayingClient(originalAttacker) && IsPlayerAlive(originalAttacker) &&
        originalAttackerPower == RSP_Bloodlust &&
        g_iAssignedRound[originalAttacker] == g_iRoundSerial &&
        GetClientTeam(originalAttacker) != deathTeamForRoundCheck)
    {
        SetEntityHealth(originalAttacker, GetClientHealth(originalAttacker) + RSP_BLOODLUST_HEAL);
    }

    // Tesla kills use a map/model inflictor but must always receive a fixed $150
    // enemy-kill reward, regardless of the weapon the owner is holding or server weapon cash.
    bool wasTeslaKill = IsRSPPowerRuntimeActive() && g_bTeslaDeathDissolvePending[client] &&
        g_iTeslaDeathDissolveRound[client] == g_iRoundSerial &&
        GetGameTime() - g_fTeslaDeathDissolveTime[client] <= 0.25 &&
        originalAttacker >= 1 && originalAttacker <= MaxClients && originalAttacker != client &&
        IsClientInGame(originalAttacker) &&
        GetClientUserId(originalAttacker) == g_iTeslaDeathOwnerUserId[client] &&
        g_iTeslaDeathCashCandidateOwnerUserId[client] == GetClientUserId(originalAttacker) &&
        g_iTeslaDeathCashCandidateRound[client] == g_iRoundSerial &&
        g_iTeslaDeathCashBefore[client] >= 0 &&
        GetClientTeam(originalAttacker) != GetClientTeam(client);
    if (wasTeslaKill)
    {
        QueueTeslaKillCash(originalAttacker, g_iTeslaDeathCashBefore[client], GetClientTeam(client));
    }
    g_iTeslaDeathCashCandidateOwnerUserId[client] = 0;
    g_iTeslaDeathCashCandidateRound[client] = 0;
    g_iTeslaDeathCashBefore[client] = -1;

    // Only rewrite the death event when the emergency ForcePlayerSuicide fallback was
    // actually used. Normal native Executioner kills retain their original weapon/icon.
    int pendingExecutionerUserId = g_iExecutionerPendingAttackerUserId[client];
    int pendingExecutionerAttacker = GetClientOfUserId(pendingExecutionerUserId);
    if (g_bExecutionerSuicideFallbackPending[client] && pendingExecutionerUserId != 0 &&
        pendingExecutionerAttacker >= 1 && pendingExecutionerAttacker <= MaxClients &&
        IsClientInGame(pendingExecutionerAttacker) && pendingExecutionerAttacker != client &&
        g_iPower[pendingExecutionerAttacker] == RSP_Executioner &&
        g_iAssignedRound[pendingExecutionerAttacker] == g_iRoundSerial)
    {
        event.SetInt("attacker", pendingExecutionerUserId);
        event.SetString("weapon", "world");
        event.SetBool("headshot", false);
    }
    g_iExecutionerPendingAttackerUserId[client] = 0;
    g_bExecutionerSuicideFallbackPending[client] = false;

    // Tesla is the only RSP power that applies a directional ragdoll impulse.
    if (IsRSPPowerRuntimeActive() && g_bTeslaDeathDissolvePending[client] &&
        g_iTeslaDeathDissolveRound[client] == g_iRoundSerial &&
        GetGameTime() - g_fTeslaDeathDissolveTime[client] <= 0.25 &&
        originalAttacker >= 1 && originalAttacker <= MaxClients &&
        originalAttacker != client && IsClientInGame(originalAttacker) &&
        GetClientUserId(originalAttacker) == g_iTeslaDeathOwnerUserId[client] &&
        (GetClientTeam(originalAttacker) == CS_TEAM_T || GetClientTeam(originalAttacker) == CS_TEAM_CT) &&
        (GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT) &&
        GetClientTeam(originalAttacker) != GetClientTeam(client))
    {
        QueueTeslaRagdollForce(client, originalAttacker);
    }
    else
    {
        // Prevent any expired or non-Tesla impulse state from affecting a later ragdoll.
        StopRagdollForceHook(client);
    }

    // Capture the cause and dissolve type before death cleanup resets per-client state.
    // Deadly Flash takes precedence if both special-death records happen to be set.
    int dissolveType = -1;
    if (g_bFlashKillPending[client] || g_bDeadlyFlashForceKill[client])
    {
        dissolveType = RSP_DEADLY_FLASH_DISSOLVE_STYLE;
    }
    else if (g_bBurnDeathPending[client] && g_iBurnDeathRound[client] == g_iRoundSerial)
    {
        dissolveType = RSP_INCENDIARY_AMMO_DISSOLVE_STYLE;
    }
    else if (g_bTeslaDeathDissolvePending[client] &&
        g_iTeslaDeathDissolveRound[client] == g_iRoundSerial &&
        GetGameTime() - g_fTeslaDeathDissolveTime[client] <= 0.25 &&
        g_iTeslaDeathOwnerUserId[client] != 0 &&
        originalAttacker >= 1 && originalAttacker <= MaxClients && IsClientInGame(originalAttacker) &&
        GetClientUserId(originalAttacker) == g_iTeslaDeathOwnerUserId[client])
    {
        // Tesla uses the same native electrical dissolve style and unmodified engine timing.
        dissolveType = RSP_INCENDIARY_AMMO_DISSOLVE_STYLE;
    }

    // Consume the per-life Tesla marker immediately so it cannot affect an unrelated death.
    g_bTeslaDeathDissolvePending[client] = false;
    g_iTeslaDeathDissolveRound[client] = 0;
    g_fTeslaDeathDissolveTime[client] = 0.0;
    g_iTeslaDeathOwnerUserId[client] = 0;
    g_bTeslaRagdollDirectionValid[client] = false;

    // DataPack preserves userid and selected dissolve type after death cleanup resets attribution.
    if (dissolveType >= 0)
    {
        DataPack dissolvePack;
        CreateDataTimer(0.10, Timer_DissolveRSPDeathRagdoll, dissolvePack, TIMER_FLAG_NO_MAPCHANGE);
        dissolvePack.WriteCell(GetClientUserId(client));
        dissolvePack.WriteCell(dissolveType);
    }

    // CS:S may apply a customized native cash award after the forced Deadly Flash death.
    // Clamp the thrower's balance on the next frame, after all native death rewards settle.
    if (g_bFlashKillPending[client] || g_bDeadlyFlashForceKill[client])
    {
        int flashOwner = GetClientOfUserId(g_iFlashKillOwnerUserId[client]);
        if (flashOwner >= 1 && flashOwner <= MaxClients && IsClientInGame(flashOwner) && flashOwner != client)
        {
            RequestFrame(Frame_ClampDeadlyFlashCash, GetClientUserId(flashOwner));
        }
    }

    bool changedDeathEvent = false;
    bool damagerDeathEvent = false;
    int damagerDeathOwnerUserIdForEvent = 0;
    ClearGiantEffect(client);
    TryAvengerInheritanceFromDeath(client, deadPower, deathTeamForRoundCheck);
    if (g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive() &&
        originalAttacker >= 1 && originalAttacker <= MaxClients && originalAttacker != client &&
        IsClientInGame(originalAttacker) && IsValidPlayingClient(originalAttacker) &&
        g_iPower[originalAttacker] == RSP_Lootbox &&
        g_iAssignedRound[originalAttacker] == g_iRoundSerial &&
        GetClientTeam(originalAttacker) != GetClientTeam(client))
    {
        CreateRSPGift(client, originalAttacker);
    }
    if (g_bNoclipWindowOpen[client] || g_bNoclipActive[client])
    {
        StopNoclip(client, false, false, true);
    }

    // Keep the alternate model through the engine's death animation. player_death is
    // hooked before the normal death transition is fully complete, so IsPlayerAlive()
    // may still be true while ResetClientPower is called below.
    if (g_bDisguiseApplied[client])
    {
        g_bDisguiseDeathTransition[client] = true;
        g_fDisguiseDeathTransitionUntil[client] = GetGameTime() + RSP_IMPOSTOR_DEATH_TRANSITION_DURATION;
    }

    // Open a short transmission window at the actual Ghost death event so the corpse/ragdoll
    // is guaranteed to finish its death transition for players and spectators.
    if (deadPower == RSP_Ghost)
    {
        g_fGhostDeathRevealUntil[client] = GetGameTime() + RSP_GHOST_DEATH_REVEAL_DURATION;
    }

    // Toxic Smoke damage is credited to the cloud owner, never to the weapon the
    // owner happened to be holding. Use a neutral world/skull icon instead of knife.
    if (g_bToxicSmokeDeathPending[client] && g_iToxicSmokeDeathRound[client] == g_iRoundSerial)
    {
        int smokeOwnerUserId = g_iToxicSmokeDeathOwnerUserId[client];
        int smokeOwner = GetClientOfUserId(smokeOwnerUserId);
        if (smokeOwnerUserId != 0 && smokeOwner >= 1 && smokeOwner <= MaxClients &&
            IsClientInGame(smokeOwner) && smokeOwner != client)
        {
            event.SetInt("attacker", smokeOwnerUserId);
            event.SetString("weapon", "world");
            event.SetBool("headshot", false);
            changedDeathEvent = true;
        }
    }
    g_bToxicSmokeDeathPending[client] = false;
    g_iToxicSmokeDeathOwnerUserId[client] = 0;
    g_iToxicSmokeDeathRound[client] = 0;

    // Damager must be credited as a power kill, not as the weapon that happened to be held.
    // Keep the engine's attacker userid for frag attribution, but publish a neutral skull icon.
    if (g_bDamagerDeathPending[client])
    {
        int damagerOwnerUserId = g_iDamagerDeathOwnerUserId[client];
        int damagerOwner = GetClientOfUserId(damagerOwnerUserId);
        bool validDamagerOwner = g_iDamagerDeathRound[client] == g_iRoundSerial &&
            damagerOwnerUserId != 0 && damagerOwner >= 1 && damagerOwner <= MaxClients &&
            IsClientInGame(damagerOwner) && damagerOwner != client;

        if (validDamagerOwner)
        {
            damagerDeathEvent = true;
            damagerDeathOwnerUserIdForEvent = damagerOwnerUserId;
            event.SetInt("attacker", damagerOwnerUserId);
            event.SetString("weapon", "world");
            event.SetBool("headshot", false);
            changedDeathEvent = true;

            if (g_iDamagerCashOwnerUserId[damagerOwner] == damagerOwnerUserId &&
                g_iDamagerCashRound[damagerOwner] == g_iRoundSerial)
            {
                g_iDamagerKillCount[damagerOwner]++;
                if (!g_bDamagerCashCorrectionQueued[damagerOwner])
                {
                    g_bDamagerCashCorrectionQueued[damagerOwner] = true;
                    RequestFrame(Frame_ApplyDamagerKillCash, damagerOwnerUserId);
                }
            }
        }

        g_bDamagerDeathPending[client] = false;
        g_iDamagerDeathOwnerUserId[client] = 0;
        g_iDamagerDeathRound[client] = 0;
    }

    // Thorns kills are credited to the defender who reflected the damage, but use
    // the same neutral world/skull icon as other non-weapon power kills. The fixed
    // $300 award is reconciled next frame after CSS has completed native rewards.
    if (g_bThornsReflectedDeathPending[client] &&
        g_iThornsReflectedDeathRound[client] == g_iRoundSerial)
    {
        int thornsOwnerUserId = g_iThornsReflectedOwnerUserId[client];
        int thornsOwner = GetClientOfUserId(thornsOwnerUserId);
        int ownerCashBefore = g_iThornsReflectedOwnerCashBefore[client];
        if (!changedDeathEvent && thornsOwnerUserId != 0 && thornsOwner >= 1 &&
            thornsOwner <= MaxClients && IsClientInGame(thornsOwner) && thornsOwner != client)
        {
            event.SetInt("attacker", thornsOwnerUserId);
            event.SetString("weapon", "world");
            event.SetBool("headshot", false);
            changedDeathEvent = true;

            if (ownerCashBefore >= 0)
            {
                DataPack thornsCashPack = new DataPack();
                thornsCashPack.WriteCell(thornsOwnerUserId);
                thornsCashPack.WriteCell(ownerCashBefore);
                RequestFrame(Frame_ApplyThornsKillCash, thornsCashPack);
            }
        }
        g_bThornsReflectedDeathPending[client] = false;
        g_iThornsReflectedOwnerUserId[client] = 0;
        g_iThornsReflectedDeathRound[client] = 0;
        g_iThornsReflectedOwnerCashBefore[client] = -1;
    }

    if (HasDeadlyFlashAttribution(client) && HasFlashbangInInventory(client))
    {
        // Snapshot before RSP clears the power on death. CSS may switch away from the
        // selected grenade as part of its death/drop sequence, so inspect all inventory slots.
        g_bLastFlashWasDeadly[client] = true;
        g_fLastDeadlyFlashThrowTime[client] = GetGameTime();
        g_iLastDeadlyFlashThrowRound[client] = g_iRoundSerial;
    }

    if (!changedDeathEvent && (g_bFlashKillPending[client] || g_bDeadlyFlashForceKill[client]))
    {
        // Keep the killer's name/score attribution but force the neutral world/skull
        // icon instead of whatever weapon the killer selected after throwing the flash.
        int flashOwnerUserId = g_iFlashKillOwnerUserId[client];
        int flashOwner = GetClientOfUserId(flashOwnerUserId);
        if (flashOwnerUserId != 0 && flashOwner >= 1 && flashOwner <= MaxClients && IsClientInGame(flashOwner))
        {
            event.SetInt("attacker", flashOwnerUserId);
            if (g_bFlashKillFallback[client] && flashOwner != client)
            {
                g_bFlashScoreRepairPending[client] = true;
                g_iFlashScoreRepairOwnerUserId[client] = flashOwnerUserId;
                g_iFlashScoreRepairVictimTeam[client] = GetClientTeam(client);
                RequestFrame(Frame_CorrectFlashFallbackScore, GetClientUserId(client));
            }
        }
        else
        {
            // If the thrower disconnected, use world/self attribution rather than
            // putting an invalid attacker index into the death event.
            event.SetInt("attacker", event.GetInt("userid"));
        }
        event.SetString("weapon", "world"); // Neutral/world skull icon; attacker field retains the thrower's userid.
        event.SetBool("headshot", false);
        changedDeathEvent = true;
        g_bFlashKillPending[client] = false;
        g_bFlashKillFallback[client] = false;
        g_iFlashKillOwnerUserId[client] = 0;
    }

    // If One-Shot HE killed the player after its thrower had died, the damage hook
    // restores the saved thrower userid for the killfeed and keeps the HE icon.
    if (!changedDeathEvent && g_bExecutionerHEKillPending[client])
    {
        int heOwnerUserId = g_iExecutionerHEKillOwnerUserId[client];
        int heOwner = GetClientOfUserId(heOwnerUserId);
        if (heOwnerUserId != 0 && heOwner >= 1 && heOwner <= MaxClients && IsClientInGame(heOwner))
        {
            event.SetInt("attacker", heOwnerUserId);
            event.SetString("weapon", "hegrenade");
            event.SetBool("headshot", false);
            changedDeathEvent = true;
        }
        g_bExecutionerHEKillPending[client] = false;
        g_iExecutionerHEKillOwnerUserId[client] = 0;
    }

    if (!changedDeathEvent && g_bBurnDeathPending[client] && g_iBurnDeathRound[client] == g_iRoundSerial)
    {
        int burnOwnerUserId = g_iBurnDeathOwnerUserId[client];
        int burnOwner = GetClientOfUserId(burnOwnerUserId);
        int burnOriginalAttackerUserId = event.GetInt("attacker");
        if (burnOwnerUserId != 0 && burnOwner >= 1 && burnOwner <= MaxClients &&
            IsClientInGame(burnOwner) && burnOwner != client)
        {
            // The neutral world icon is intentional; the attacker userid remains the
            // incendiary shooter, so score/cash follow the owner rather than suicide.
            event.SetInt("attacker", burnOwnerUserId);
            event.SetString("weapon", "world");
            event.SetBool("headshot", false);
            changedDeathEvent = true;

            if (burnOriginalAttackerUserId != burnOwnerUserId)
            {
                g_bBurnScoreRepairPending[client] = true;
                g_iBurnScoreRepairOwnerUserId[client] = burnOwnerUserId;
                g_iBurnScoreRepairVictimTeam[client] = GetClientTeam(client);
                g_bBurnVictimWasSuicide[client] = burnOriginalAttackerUserId == event.GetInt("userid");
                RequestFrame(Frame_CorrectBurnFallbackScore, GetClientUserId(client));
            }
        }
        g_bBurnDeathPending[client] = false;
        g_iBurnDeathOwnerUserId[client] = 0;
        g_iBurnDeathRound[client] = 0;
    }

    // Explosive Bullets kills are caused by the impact blast, not the firearm itself.
    // Keep the shooter as the attacker, use the neutral world/skull icon, and leave
    // the money correction to the synchronous damage caller after CS:S applies its award.
    if (!changedDeathEvent && g_bExplosiveBulletDeathPending[client] &&
        g_iExplosiveBulletDeathRound[client] == g_iRoundSerial)
    {
        int blastOwnerUserId = g_iExplosiveBulletDeathOwnerUserId[client];
        int blastOwner = GetClientOfUserId(blastOwnerUserId);
        if (blastOwnerUserId != 0 && blastOwner >= 1 && blastOwner <= MaxClients &&
            IsClientInGame(blastOwner))
        {
            event.SetInt("attacker", blastOwnerUserId);
        }
        else
        {
            // Never leave an invalid/stale attacker index in the death event.
            event.SetInt("attacker", event.GetInt("userid"));
        }
        event.SetString("weapon", "world");
        event.SetBool("headshot", false);
        changedDeathEvent = true;
    }
    g_bExplosiveBulletDeathPending[client] = false;
    g_iExplosiveBulletDeathOwnerUserId[client] = 0;
    g_iExplosiveBulletDeathRound[client] = 0;

    // Clear the active burn attribution after handling a possible fatal burn tick.
    g_iBurnOwnerUserId[client] = 0;
    g_iBurnOwnerRound[client] = 0;
    g_fBurnOwnerUntil[client] = 0.0;

    // Tesla headshots are rolled by its targeting system rather than a firearm TraceAttack.
    // Rewrite the pre player_death event so the standard CS:S killfeed shows the headshot icon.
    if (g_bTeslaHeadshotPending[client] && g_iTeslaHeadshotRound[client] == g_iRoundSerial &&
        GetGameTime() - g_fTeslaHeadshotTime[client] >= 0.0 &&
        GetGameTime() - g_fTeslaHeadshotTime[client] <= 0.25)
    {
        event.SetBool("headshot", true);
        changedDeathEvent = true;
    }
    g_bTeslaHeadshotPending[client] = false;
    g_iTeslaHeadshotRound[client] = 0;
    g_fTeslaHeadshotTime[client] = 0.0;

    // Damager always has the neutral skull icon, even if another recent hit left
    // temporary headshot metadata on this victim.
    if (damagerDeathEvent)
    {
        event.SetInt("attacker", damagerDeathOwnerUserIdForEvent);
        event.SetString("weapon", "world");
        event.SetBool("headshot", false);
        changedDeathEvent = true;
    }

    // Restore the legacy Aimbot killfeed behavior: firearm kills by an active Aimbot
    // count as headshots even when the final physical TraceAttack hitgroup was the body.
    if (!changedDeathEvent && !event.GetBool("headshot") && !g_bDeadlyFlashForceKill[client] &&
        g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive())
    {
        int aimbotKiller = GetClientOfUserId(event.GetInt("attacker"));
        char aimbotDeathWeapon[32];
        event.GetString("weapon", aimbotDeathWeapon, sizeof(aimbotDeathWeapon));
        if (aimbotKiller >= 1 && aimbotKiller <= MaxClients && aimbotKiller != client &&
            IsClientInGame(aimbotKiller) && g_iPower[aimbotKiller] == RSP_Aimbot &&
            g_iAssignedRound[aimbotKiller] == g_iRoundSerial &&
            IsRSPFirearmEventWeapon(aimbotDeathWeapon))
        {
            event.SetBool("headshot", true);
            changedDeathEvent = true;
        }
    }

    // Tell the victim only which superpower the opposing killer had. Never expose
    // randomized values here; the death notification intentionally stays concise.
    int killerUserId = event.GetInt("attacker");
    int killer = GetClientOfUserId(killerUserId);
    if (killer >= 1 && killer <= MaxClients && killer != client && IsClientInGame(killer) &&
        IsValidPlayingClient(killer) && IsValidPlayingClient(client) && GetClientTeam(killer) != GetClientTeam(client) &&
        g_iPower[killer] != RSP_None && g_iAssignedRound[killer] == g_iRoundSerial)
    {
        int killerPowerIndex = view_as<int>(g_iPower[killer]);
        if (killerPowerIndex > 0 && killerPowerIndex < view_as<int>(RSP_PowerCount))
        {
            PrintToChat(client, IsPolishClient(client)
                ? "\x04[RSP]\x01 Supermoc twojego zabójcy: \x04%s\x01"
                : "\x04[RSP]\x01 Your killer's superpower: \x04%s\x01",
                g_sPowerNamesEn[killerPowerIndex]);
        }
    }

    bool triggerZombie = g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive() &&
        !g_bRoundEnding && !g_bDeadlyFlashForceKill[client] &&
        deadPower == RSP_Zombie && !g_bZombieUsedThisRound[client] && IsValidPlayingClient(client);

    if (g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive() &&
        deadPower == RSP_DeathBomb)
    {
        QueueDeathExplosion(client);
    }

    // Resurrection is a guaranteed one-time respawn per round. CS_RespawnPlayer
    // follows the native CSS spawn/loadout path, so do not manually give a knife or pistol.
    if (g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive() &&
        !g_bDeadlyFlashForceKill[client] && deadPower == RSP_Resurrection &&
        !g_bResurrectionUsedThisRound[client] && IsValidPlayingClient(client))
    {
        g_bResurrectionUsedThisRound[client] = true;
        QueuePowerRespawn(client, RSP_POWER_RESPAWN_RESURRECTION);
    }

    // Phoenix is passive and may trigger on the owner's death. Reviver is manual only:
    // no teammate is ever respawned automatically by Reviver.
    if (g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive() &&
        !g_bDeadlyFlashForceKill[client] && deadPower == RSP_Phoenix &&
        !g_bPhoenixUsedThisRound[client])
    {
        g_bPhoenixUsedThisRound[client] = true;
        if (GetRandomInt(1, 2) == 1)
        {
            QueuePowerRespawn(client, RSP_POWER_RESPAWN_PHOENIX);
        }
    }

    if (triggerZombie)
    {
        // WeaponDropPost can be dispatched after this pre-death event has already
        // reset g_iPower. Preserve a short timestamp window to catch Source's drop.
        g_fZombieDropCleanupUntil[client] = GetGameTime() + RSP_ZOMBIE_DROP_CLEANUP_WINDOW;
    }

    // Chameleon reacts to the first eligible enemy death using both event-entry snapshots.
    // Do not read the death event's rewritten attacker field or the victim's potentially
    // reset power later in this callback. The attacker must still be alive to receive it.
    int chameleonKiller = originalAttacker;
    if (g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive() &&
        chameleonKiller >= 1 && chameleonKiller <= MaxClients && chameleonKiller != client &&
        IsClientInGame(chameleonKiller) && IsValidPlayingClient(chameleonKiller) &&
        GetClientUserId(chameleonKiller) == originalAttackerUserId && IsPlayerAlive(chameleonKiller) &&
        GetClientTeam(chameleonKiller) != deathTeamForRoundCheck &&
        originalAttackerPower == RSP_Chameleon && g_iAssignedRound[chameleonKiller] == g_iRoundSerial)
    {
        if (deadPower == RSP_Chameleon)
        {
            PrintRSPChameleonDuplicateNotice(chameleonKiller);
        }
        else if (IsRSPPowerCopyableByChameleon(deadPower))
        {
            g_bThiefApplyingStolenPower[chameleonKiller] = true;
            g_iThiefSourceUserId[chameleonKiller] = GetClientUserId(client);
            g_eThiefSourcePower[chameleonKiller] = deadPower;
            AssignPowerToClient(chameleonKiller, deadPower, false, true);
            g_bThiefApplyingStolenPower[chameleonKiller] = false;
            g_iThiefSourceUserId[chameleonKiller] = 0;
            g_eThiefSourcePower[chameleonKiller] = RSP_None;
        }
    }

    // If the engine already completed this death, don't run the One-Shot fallback
    // against a later respawn of the same client slot.
    g_iExecutionerPendingAttackerUserId[client] = 0;
    g_fFrozenUntil[client] = 0.0;
    UpdateRSPTemporaryVoiceMute(client);
    if (g_fConcussionDspUntil[client] > 0.0 && IsClientInGame(client))
        ClientCommand(client, "dsp_player 0");
    g_fConcussionDspUntil[client] = 0.0;
    g_iConcussionDspEffect[client] = 0;
    g_iCryoOwnerUserId[client] = 0;
    ClearWeakeningAmmoState(client, true);
    g_fNextDisorientTime[client] = 0.0;
    g_fDisorientTargetYaw[client] = 0.0;
    g_fDisorientViewUntil[client] = 0.0;
    g_iDisorientOwnerUserId[client] = 0;
    g_iCryoChancePercent[client] = 0;
    g_iDisorientChancePercent[client] = 0;
    g_iConcussionChancePercent[client] = 0;
    g_bExecutionerHEKillPending[client] = false;
    g_iExecutionerHEKillOwnerUserId[client] = 0;
    StopClientBlindTimer(client);
    ResetClientPower(client, false);
    QueueRefreshActiveTargetSelections();

    if (triggerZombie && IsClientInGame(client))
    {
        g_bZombieUsedThisRound[client] = true;
        g_bZombieRespawnPending[client] = true;
        g_iZombieRespawnRound[client] = g_iRoundSerial;
        g_iZombieRespawnAttempts[client] = 0;
        if (g_hZombieRespawnTimer[client] != null)
        {
            delete g_hZombieRespawnTimer[client];
        }
        g_hZombieRespawnTimer[client] = CreateTimer(RSP_ZOMBIE_RESPAWN_DELAY,
            Timer_ReZombieRespawn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
        if (g_hZombieRespawnTimer[client] == null)
        {
            g_bZombieRespawnPending[client] = false;
            g_iZombieRespawnRound[client] = 0;
            g_iZombieRespawnAttempts[client] = 0;
        }
    }

    // This runs on the next frame, after the engine has completed the death transition.
    // If a previously deferred team has now lost its final life and no respawn remains,
    // finish the elimination even on engine paths that do not issue a second win check.
    if (deathTeamForRoundCheck == CS_TEAM_T || deathTeamForRoundCheck == CS_TEAM_CT)
    {
        ScheduleDeferredEliminationChecks();
    }

    return changedDeathEvent ? Plugin_Changed : Plugin_Continue;
}

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
    if (!g_bEnabled || !g_bSupportedMap || !g_bRoundReady ||
        (reason != CSRoundEnd_CTWin && reason != CSRoundEnd_TerroristWin))
    {
        return Plugin_Continue;
    }

    int eliminatedTeam = (reason == CSRoundEnd_CTWin) ? CS_TEAM_T : CS_TEAM_CT;
    if (HasPendingRespawnOnTeam(eliminatedTeam) || HasEligibleUnqueuedRespawnOnTeam(eliminatedTeam))
    {
        // A guaranteed/queued respawn granted from a Lootbox must be allowed to resolve
        // before team-elimination wins, even if C4 is planted. The deferred frame still
        // waits for an active planted-C4 objective, so it cannot override bomb detonation
        // or defuse. The check must precede the planted-bomb early return, or Event_RoundEnd
        // can cancel Resurrection/Phoenix/Re-Zombie before their timer executes.
        g_bDeferredEliminationWin[eliminatedTeam] = true;
        g_iDeferredEliminationRound[eliminatedTeam] = g_iRoundSerial;
        RequestFrame(Frame_CheckDeferredElimination, eliminatedTeam);
        return Plugin_Handled;
    }

    // With no eligible respawn pending, leave all planted-C4 outcome decisions native.
    if (HasPlantedBombObjective())
    {
        return Plugin_Continue;
    }

    // A previous termination may have been held before a power respawn. If native
    // termination is being attempted again now, let it proceed and retire this marker.
    if (g_bDeferredEliminationWin[eliminatedTeam] &&
        g_iDeferredEliminationRound[eliminatedTeam] == g_iRoundSerial)
    {
        g_bDeferredEliminationWin[eliminatedTeam] = false;
        g_iDeferredEliminationRound[eliminatedTeam] = 0;
    }

    return Plugin_Continue;
}

// Applies the selected native dissolve style only to the dead player's cs_ragdoll.
// The server owner verified type 0 as the upward sci-fi effect and type 1 as a natural ragdoll fall followed by dissolve. RSP uses type 1 for both special death causes in 5.4.
// The live player, damage, killfeed and attacker attribution remain untouched.
public Action Timer_DissolveRSPDeathRagdoll(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    int dissolveType = pack.ReadCell();
    if (dissolveType < 0 || dissolveType > 3)
    {
        return Plugin_Stop;
    }

    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !HasEntProp(client, Prop_Send, "m_hRagdoll"))
    {
        return Plugin_Stop;
    }

    int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
    if (ragdoll <= MaxClients || !IsValidEntity(ragdoll))
    {
        return Plugin_Stop;
    }

    char classname[32];
    GetEntityClassname(ragdoll, classname, sizeof(classname));
    if (!StrEqual(classname, "cs_ragdoll", false))
    {
        return Plugin_Stop;
    }

    static int dissolveSerial;
    dissolveSerial++;
    char targetName[64];
    Format(targetName, sizeof(targetName), "rsp_death_dissolve_%d_%d", userid, dissolveSerial);
    DispatchKeyValue(ragdoll, "targetname", targetName);

    int dissolver = CreateEntityByName("env_entity_dissolver");
    if (dissolver <= MaxClients || !IsValidEntity(dissolver))
    {
        return Plugin_Stop;
    }

    char dissolveTypeText[4];
    IntToString(dissolveType, dissolveTypeText, sizeof(dissolveTypeText));
    DispatchKeyValue(dissolver, "dissolvetype", dissolveTypeText);
    DispatchKeyValue(dissolver, "target", targetName);
    DispatchKeyValue(dissolver, "magnitude", "0");
    if (!DispatchSpawn(dissolver) || !IsValidEntity(dissolver))
    {
        if (IsValidEntity(dissolver))
        {
            RemoveEntity(dissolver);
        }
        return Plugin_Stop;
    }

    ActivateEntity(dissolver);

    // Let env_entity_dissolver use the Source engine's native, unmodified fade timeline.
    AcceptEntityInput(dissolver, "Dissolve");

    AcceptEntityInput(dissolver, "Kill");
    return Plugin_Stop;
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    int oldTeam = event.GetInt("oldteam");
    int newTeam = event.GetInt("team");
    bool hadActiveTargetSelection = g_iTargetSelectionType[client] != RSP_TARGET_SELECT_NONE ||
        g_bTargetSelectionPending[client];
    if (newTeam != CS_TEAM_T && newTeam != CS_TEAM_CT)
    {
        ResetClientPower(client, false);
    }
    else if ((oldTeam == CS_TEAM_T || oldTeam == CS_TEAM_CT) && oldTeam != newTeam)
    {
        // A team switch changes target eligibility. Clear stale incoming/outgoing effects,
        // invalidate old /N lists, and rebuild selection for an active target-selection power.
        ClearRSPTargetSelection(client);
        ClearHackerEffect(client);
        ClearGiantEffect(client);
        g_iExpensiveAmmoOwnerUserId[client] = 0;
        g_iExpensiveAmmoRound[client] = 0;
        g_iExpensiveAmmoPendingShots[client] = 0;
        g_bExpensiveAmmoFrameQueued[client] = false;
        ClearOwnedRSPTargetEffects(client);

        if (g_bEnabled && g_bSupportedMap && g_bRoundReady && IsPlayerAlive(client))
        {
            if (g_iPower[client] == RSP_None || g_iAssignedRound[client] != g_iRoundSerial)
            {
                // A previous move through spectator may have reset the power but left
                // this round's serial intact. Clear it so Timer_AssignSinglePower can run.
                g_iAssignedRound[client] = 0;
                CreateTimer(0.10, Timer_AssignSinglePower, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
            }
            else
            {
                int selectionType = GetTargetSelectionTypeForPower(g_iPower[client]);
                if (selectionType != RSP_TARGET_SELECT_NONE && hadActiveTargetSelection)
                {
                    QueueRSPTargetSelection(client, selectionType);
                }
            }
        }
    }
    else if (g_bEnabled && g_bSupportedMap && g_bRoundReady &&
             IsPlayerAlive(client) && (g_iAssignedRound[client] != g_iRoundSerial || g_iPower[client] == RSP_None))
    {
        if (g_iPower[client] == RSP_None) g_iAssignedRound[client] = 0;
        CreateTimer(0.10, Timer_AssignSinglePower, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    }
    if (oldTeam != newTeam)
    {
        // A placed mine keeps its original team and remains armed if its owner changes teams.
        // A completed Grounder lock remains attached to its target across team changes;
        // target death or the next round_start removes it.
    }

    if (newTeam == CS_TEAM_SPECTATOR && oldTeam != CS_TEAM_SPECTATOR)
    {
        // Let the team switch and any simultaneous power cleanup settle first, then show
        // both teams to the observer. Queueing is debounced to prevent duplicate rosters.
        QueueObserverPowerRoster(client);
    }
    ScheduleDeferredEliminationChecks();
    QueueWallhackRefresh();
    QueueRefreshActiveTargetSelections();
}

public Action Timer_AssignRoundPowers(Handle timer, any roundSerial)
{
    if (!g_bEnabled || !g_bSupportedMap || !g_bRoundReady || g_bRoundEnding || roundSerial != g_iRoundSerial)
    {
        return Plugin_Stop;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsValidPlayingClient(client) && IsPlayerAlive(client) && g_iAssignedRound[client] != g_iRoundSerial)
        {
            AssignRandomPower(client, true);
        }
    }

    QueueWallhackRefresh();
    return Plugin_Stop;
}

public Action Timer_AssignSinglePower(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (!g_bEnabled || !g_bSupportedMap || !g_bRoundReady || g_bRoundEnding ||
        !IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iAssignedRound[client] == g_iRoundSerial)
    {
        return Plugin_Stop;
    }

    // The deferred assignment callback owns the complete chat sequence for this client:
    // own power, optional enemy list, then one teammate roster. Do not queue another roster.
    AssignRandomPower(client, true);
    QueueWallhackRefresh();
    return Plugin_Stop;
}

void AssignRandomPower(int client, bool deferRoundNotice = false)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) || !g_bRoundReady || g_bRoundEnding)
    {
        return;
    }

    // Uniform draw from all powers supported by this player type. Bots cannot use chat-based target selection or a local third-person camera.
    RSPPower availablePowers[sizeof(g_RSPSelectablePowers)];
    int availableCount = 0;
    bool isBot = IsFakeClient(client);
    for (int i = 0; i < sizeof(g_RSPSelectablePowers); i++)
    {
        RSPPower candidate = g_RSPSelectablePowers[i];
        if (isBot && candidate == RSP_Blackout)
        {
            continue;
        }
        availablePowers[availableCount++] = candidate;
    }
    if (availableCount <= 0)
    {
        return;
    }
    RSPPower power = availablePowers[GetRandomInt(0, availableCount - 1)];
    AssignPowerToClient(client, power, false, false, false, deferRoundNotice);
}

void ResetPowerLimitsForFreshAssignment(int client, RSPPower power)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }
    switch (power)
    {
        case RSP_Inventor: g_iInventorUsesThisRound[client] = 0;
        case RSP_Miner: g_iMinerUsesThisRound[client] = 0;
        case RSP_Medic: g_iMedicCharges[client] = RSP_MEDIC_CHARGES;
        case RSP_Zombie: g_bZombieUsedThisRound[client] = false;
        case RSP_Phoenix: g_bPhoenixUsedThisRound[client] = false;
        case RSP_Resurrection: g_bResurrectionUsedThisRound[client] = false;
        case RSP_Blackout: g_bBlackoutUsedThisAssignment[client] = false;
    }
}


void AssignPowerToClient(int client, RSPPower power, bool allowOutsideRound = false, bool chameleonCopy = false, bool duplicatorCopy = false, bool deferRoundNotice = false, bool giftReward = false, bool avengerReward = false, int gamblerOfferIndex = -1)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        (!g_bRoundReady && !allowOutsideRound) ||
        !IsRSPPowerSelectable(power))
    {
        return;
    }

    // If replacing Deadly Flash during a round, stop treating future flashbangs as lethal.
    // Already-spawned flash projectiles keep their captured g_bFlashProjectileDeadly value.
    if (g_iPower[client] == RSP_DeadlyFlash && power != RSP_DeadlyFlash)
    {
        g_bHadDeadlyFlashThisRound[client] = false;
        g_bLastFlashWasDeadly[client] = false;
        g_fLastDeadlyFlashThrowTime[client] = 0.0;
        g_iLastDeadlyFlashThrowRound[client] = 0;
    }

    // A power reassignment resets this owner's own power state. Completed effects already
    // applied to other players by selected/one-shot powers remain until their own expiry or
    // round cleanup. Deployed mines, gifts and completed Grounder effects are cleared
    // by the single authoritative round_start reset.
    // Incoming target effects are preserved; they belong to their original source. Existing
    // world entities (turrets/mines/gifts/projectiles) keep their own lifecycle.
    RSPPower previousPower = g_iPower[client];
    ResetClientPower(client, true, true, true);
    g_bHostPowerGrantedOutsideRound[client] = allowOutsideRound && !g_bRoundReady;

    g_iAssignedRound[client] = g_iRoundSerial;
    g_iPower[client] = power;
    g_bGamblerPendingSelection[client] = false;
    g_bGamblerChatIntercept[client] = false;
    g_bGamblerApplyingChoice[client] = gamblerOfferIndex >= 0 && gamblerOfferIndex < RSP_GAMBLER_OPTIONS;
    g_iGamblerSelectedOfferIndex[client] = g_bGamblerApplyingChoice[client] ? gamblerOfferIndex : -1;
    if (power == RSP_Avenger && !avengerReward)
    {
        g_bAvengerConsumedThisRound[client] = false;
    }
    ResetPowerLimitsForFreshAssignment(client, power);
    g_iPowerNoticeGeneration[client]++;
    if (g_iPowerNoticeGeneration[client] <= 0)
    {
        g_iPowerNoticeGeneration[client] = 1;
    }
    // No initial cooldown: powers with active cooldowns are ready after freeze time.
    ApplyPower(client, power);

    // Ghost strips all firearms. If a live Ghost (or active Re-Zombie life) receives a
    // different power from a Lootbox reward, there is no new spawn event to restore
    // the standard team pistol. Restore it immediately after the new power is applied,
    // but never while the new power is Ghost. Keep the pistol in inventory without
    // forcibly switching the player's active weapon on a gift reassignment.
    if ((previousPower == RSP_Ghost || previousPower == RSP_Zombie) && power != RSP_Ghost)
    {
        RestorePistolAfterGhostTheft(client, false);
    }

    g_bGamblerApplyingChoice[client] = false;
    g_iGamblerSelectedOfferIndex[client] = -1;
    if (g_fWeakeningUntil[client] > GetGameTime() && g_iWeakeningRound[client] == g_iRoundSerial &&
        power != RSP_SpeedDemon && power != RSP_Berserker &&
        HasEntProp(client, Prop_Data, "m_flLaggedMovementValue"))
    {
        // ResetClientPower restores the previous power's baseline before ApplyPower;
        // refresh it so an unrelated new power does not inherit the old slow's scalar.
        g_fWeakeningBaseMovementValue[client] = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
        g_bWeakeningBaseMovementValid[client] = true;
    }

    // Keep this as the only success message path. Normal round assignments queue
    // the notice for the shared roster window; steals/copies/manual grants stay immediate.
    bool stolenMessage = g_bThiefApplyingStolenPower[client] && !chameleonCopy && !duplicatorCopy && !avengerReward;
    if (deferRoundNotice)
    {
        // Schedule the owner notice first; the selection timer is queued next and
        // the shared teammate roster last. All three callbacks share the same deadline.
        QueuePowerAssignmentNotice(client, power, stolenMessage, chameleonCopy, duplicatorCopy);
    }
    else if (giftReward)
    {
        PrintGiftPowerAssignment(client, power);
    }
    else
    {
        PrintPowerAssignment(client, power, stolenMessage, chameleonCopy, duplicatorCopy, avengerReward);
    }

    // Every immediate assignment must enter its target-selection flow, including
    // Thief thefts, Duplicator copies, Chameleon copies and Avenger rewards.
    // The previous ThiefApplying guard suppressed /1, /2 lists for any copied
    // target-selection power (e.g. Blackout), even though the assignment message
    // was printed correctly. Deferred round assignments queue their list alongside
    // the owner notice in Timer_PrintDeferredPowerAssignment instead.
    if (!deferRoundNotice)
    {
        QueueTargetSelectionForAssignedPower(client, power);
    }
    QueueRefreshActiveTargetSelections();
}

bool IsRSPPowerSelectable(RSPPower power)
{
    for (int i = 0; i < sizeof(g_RSPSelectablePowers); i++)
    {
        if (g_RSPSelectablePowers[i] == power)
        {
            return true;
        }
    }
    return false;
}

bool ResolveSelectablePowerName(const char[] requestedName, RSPPower &power)
{
    char requested[96];
    strcopy(requested, sizeof(requested), requestedName);
    TrimString(requested);
    if (requested[0] == '\0')
    {
        return false;
    }

    // Canonical official English name: Ender Grenade.
    if (StrEqual(requested, "Ender Grenade", false))
    {
        power = RSP_EnderGrenade;
        return true;
    }

    // Only the exact canonical English name shown in PrintPowerAssignment and
    // rsp_powerslist is accepted. Comparison is case-insensitive, but spaces,
    // hyphens, punctuation, localized aliases, and enum prefixes are not rewritten.
    for (int i = 0; i < sizeof(g_RSPSelectablePowers); i++)
    {
        RSPPower candidate = g_RSPSelectablePowers[i];
        int index = view_as<int>(candidate);
        if (index <= view_as<int>(RSP_None) || index >= view_as<int>(RSP_PowerCount))
        {
            continue;
        }

        if (StrEqual(requested, g_sPowerNamesEn[index], false))
        {
            power = candidate;
            return true;
        }
    }
    return false;
}

// SourceMod server-side RegConsoleCmd has no live argument autocomplete callback.
// Accept only the complete canonical English power name: partial input must never
// grant a power by accident. Native argument TAB completion needs client-side support.
void ReportUnknownSelectablePowerName(int client, const char[] requestedName)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    PrintToChat(client, "\x04[RSP]\x01 Nieznana lub niedostępna moc: %s. Użyj pełnej angielskiej nazwy z rsp_powerslist.", requestedName);
}

bool IsRSPPowerRuntimeActive()
{
    if (g_bRoundReady)
    {
        return true;
    }
    if (!g_bEnabled || !g_bSupportedMap)
    {
        return false;
    }
    for (int client = 1; client <= MaxClients; client++)
    {
        if (g_bHostPowerGrantedOutsideRound[client] && IsClientInGame(client) &&
            !IsFakeClient(client) && g_iPower[client] != RSP_None)
        {
            return true;
        }
    }
    return false;
}

bool IsRSPPowerRuntimeActiveForClient(int client)
{
    if (g_bRoundReady)
    {
        return true;
    }
    return client >= 1 && client <= MaxClients && g_bEnabled && g_bSupportedMap &&
        IsClientInGame(client) && !IsFakeClient(client) &&
        g_bHostPowerGrantedOutsideRound[client] && g_iPower[client] != RSP_None;
}

bool IsRSPListenHostClient(int candidate)
{
    if (candidate < 1 || candidate > MaxClients || !IsClientInGame(candidate) || IsFakeClient(candidate))
    {
        return false;
    }

    char address[64];
    if (!GetClientIP(candidate, address, sizeof(address), true))
    {
        return false;
    }

    // On a listen server, the local host is exposed to SourceMod as loopback.
    // Accept common IPv4/IPv6 loopback representations, never ordinary remote addresses.
    if (StrEqual(address, "loopback", false) ||
        StrEqual(address, "localhost", false) ||
        StrEqual(address, "::1", false) ||
        StrContains(address, "127.", false) == 0 ||
        StrContains(address, "::ffff:127.", false) == 0)
    {
        return true;
    }

    return false;
}

int FindRSPListenHostClient()
{
    if (IsDedicatedServer())
    {
        return 0;
    }

    for (int candidate = 1; candidate <= MaxClients; candidate++)
    {
        if (IsRSPListenHostClient(candidate))
        {
            return candidate;
        }
    }

    return 0;
}

public Action Command_GivePower(int client, int args)
{
    // GivePower never changes the engine's round state. It can grant a power
    // outside a real round while RSP is enabled on a supported map.
    if (IsDedicatedServer())
    {
        return Plugin_Handled;
    }

    int recipient = client;
    if (recipient == 0)
    {
        recipient = FindRSPListenHostClient();
    }

    if (!IsRSPListenHostClient(recipient) || (client > 0 && client != recipient) ||
        !IsValidPlayingClient(recipient))
    {
        return Plugin_Handled;
    }
    if (!g_bEnabled || !g_bSupportedMap)
    {
        PrintToChat(recipient, "\x04[RSP]\x01 Włącz RSP na obsługiwanej mapie przed nadaniem mocy.");
        return Plugin_Handled;
    }
    if (!IsPlayerAlive(recipient))
    {
        PrintToChat(recipient, "\x04[RSP]\x01 Musisz żyć, aby przetestować moc.");
        return Plugin_Handled;
    }

    char requestedName[96];
    GetCmdArgString(requestedName, sizeof(requestedName));
    StripQuotes(requestedName);
    TrimString(requestedName);

    RSPPower power;
    if (!ResolveSelectablePowerName(requestedName, power))
    {
        ReportUnknownSelectablePowerName(recipient, requestedName);
        return Plugin_Handled;
    }

    // Only this assignment gets an out-of-round runtime context. No fake round,
    // no round serial change, no random assignment, and no effects granted to others.
    AssignPowerToClient(recipient, power, true);
    return Plugin_Handled;
}


public Action Command_GivePowerToTarget(int client, int args)
{
    // This testing command is restricted to the local listen-server host.
    // It is intentionally unavailable on a dedicated server or to remote clients.
    if (IsDedicatedServer())
    {
        return Plugin_Handled;
    }

    int host = client;
    if (host == 0)
    {
        host = FindRSPListenHostClient();
    }

    if (!IsRSPListenHostClient(host) || (client > 0 && client != host))
    {
        if (client >= 1 && client <= MaxClients && IsClientInGame(client))
        {
            PrintToChat(client, "\x04[RSP]\x01 Ta komenda jest dostępna tylko dla hosta lokalnego serwera.");
        }
        return Plugin_Handled;
    }

    if (args < 2)
    {
        PrintToChat(host, "\x04[RSP]\x01 Użycie: rsp_givepower <ID lub \"nick\"> <nazwa mocy>.");
        PrintToChat(host, "\x04[RSP]\x01 Przykład: rsp_givepower 13 Toxic Smoke");
        return Plugin_Handled;
    }

    if (!g_bEnabled || !g_bSupportedMap)
    {
        PrintToChat(host, "\x04[RSP]\x01 Włącz RSP na obsługiwanej mapie przed nadaniem mocy.");
        return Plugin_Handled;
    }

    char targetArg[128];
    GetCmdArg(1, targetArg, sizeof(targetArg));
    TrimString(targetArg);

    bool ambiguous = false;
    int recipient = ResolveRSPCommandTarget(targetArg, ambiguous);
    if (ambiguous)
    {
        PrintToChat(host, "\x04[RSP]\x01 Ta nazwa pasuje do kilku graczy. Użyj ID z komendy status.");
        return Plugin_Handled;
    }
    if (recipient < 1 || recipient > MaxClients || !IsValidPlayingClient(recipient))
    {
        PrintToChat(host, "\x04[RSP]\x01 Nie znaleziono gracza. Użyj jego ID z komendy status lub dokładnej nazwy w cudzysłowie.");
        return Plugin_Handled;
    }
    if (!IsPlayerAlive(recipient))
    {
        char targetName[MAX_NAME_LENGTH];
        GetClientName(recipient, targetName, sizeof(targetName));
        PrintToChat(host, "\x04[RSP]\x01 Gracz %s musi żyć, aby otrzymać moc.", targetName);
        return Plugin_Handled;
    }

    char requestedName[96];
    requestedName[0] = '\0';
    for (int arg = 2; arg <= args; arg++)
    {
        char part[48];
        GetCmdArg(arg, part, sizeof(part));
        if (requestedName[0] != '\0')
        {
            StrCat(requestedName, sizeof(requestedName), " ");
        }
        StrCat(requestedName, sizeof(requestedName), part);
    }
    TrimString(requestedName);

    RSPPower power;
    if (!ResolveSelectablePowerName(requestedName, power))
    {
        ReportUnknownSelectablePowerName(host, requestedName);
        return Plugin_Handled;
    }

    // Use the same native assignment path and normal player notification as random assignment.
    // Like rsp_getpower, this can be used outside a real round without faking round state.
    AssignPowerToClient(recipient, power, true);
    return Plugin_Handled;
}

public Action Command_GivePowerAll(int client, int args)
{
    // Match the existing test-command security model: listen-server host only, never a remote client or dedicated server.
    if (IsDedicatedServer())
    {
        return Plugin_Handled;
    }

    int host = client;
    if (host == 0)
    {
        host = FindRSPListenHostClient();
    }

    if (!IsRSPListenHostClient(host) || (client > 0 && client != host))
    {
        if (client >= 1 && client <= MaxClients && IsClientInGame(client))
        {
            PrintToChat(client, "\x04[RSP]\x01 Ta komenda jest dostępna tylko dla hosta lokalnego serwera.");
        }
        return Plugin_Handled;
    }

    if (!g_bEnabled || !g_bSupportedMap)
    {
        PrintToChat(host, "\x04[RSP]\x01 Włącz RSP na obsługiwanej mapie przed nadaniem mocy.");
        return Plugin_Handled;
    }

    if (args < 1)
    {
        PrintToChat(host, "\x04[RSP]\x01 Użycie: rsp_givepowerall <nazwa mocy>.");
        PrintToChat(host, "\x04[RSP]\x01 Przykład: rsp_givepowerall Deadly Flash");
        return Plugin_Handled;
    }

    char requestedName[96];
    GetCmdArgString(requestedName, sizeof(requestedName));
    StripQuotes(requestedName);
    TrimString(requestedName);

    RSPPower power;
    if (!ResolveSelectablePowerName(requestedName, power))
    {
        ReportUnknownSelectablePowerName(host, requestedName);
        return Plugin_Handled;
    }

    int assignedCount = 0;
    for (int target = 1; target <= MaxClients; target++)
    {
        if (!IsValidPlayingClient(target) || !IsPlayerAlive(target))
        {
            continue;
        }

        // Reuse the normal power assignment path so per-player cleanup, rolled state,
        // bind instructions and localized power descriptions stay consistent.
        AssignPowerToClient(target, power, true);
        assignedCount++;
    }

    if (assignedCount == 0)
    {
        PrintToChat(host, "\x04[RSP]\x01 Nie ma żywych graczy w drużynach T/CT, którym można nadać moc.");
        return Plugin_Handled;
    }

    int powerIndex = view_as<int>(power);
    PrintToChat(host, IsPolishClient(host)
        ? "\x04[RSP]\x01 Nadano moc \x04%s\x01 wszystkim żywym graczom: \x04%d\x01."
        : "\x04[RSP]\x01 Granted \x04%s\x01 to all living players: \x04%d\x01.",
        g_sPowerNamesEn[powerIndex], assignedCount);
    return Plugin_Handled;
}

int ResolveRSPCommandTarget(const char[] targetArg, bool &ambiguous)
{
    ambiguous = false;
    if (targetArg[0] == '\0')
    {
        return 0;
    }

    char numericText[32];
    strcopy(numericText, sizeof(numericText), targetArg);
    bool forceUserId = false;
    if (numericText[0] == '#')
    {
        forceUserId = true;
        for (int i = 0; numericText[i] != '\0'; i++)
        {
            numericText[i] = numericText[i + 1];
        }
    }

    bool numeric = numericText[0] != '\0';
    for (int i = 0; numericText[i] != '\0'; i++)
    {
        if (numericText[i] < '0' || numericText[i] > '9')
        {
            numeric = false;
            break;
        }
    }

    if (numeric)
    {
        int userId = StringToInt(numericText);
        int byUserId = GetClientOfUserId(userId);
        if (byUserId >= 1 && byUserId <= MaxClients && IsClientInGame(byUserId))
        {
            return byUserId;
        }
        // Numeric IDs refer to the user ID shown by `status`. A leading # makes
        // the ID-only request explicit, so it must not fall through to a name match.
        if (forceUserId)
        {
            return 0;
        }
        // If no user ID matches, an unprefixed numeric string may still be an exact player name.
    }

    int match = 0;
    for (int candidate = 1; candidate <= MaxClients; candidate++)
    {
        if (!IsClientInGame(candidate))
        {
            continue;
        }

        char currentName[MAX_NAME_LENGTH];
        GetClientName(candidate, currentName, sizeof(currentName));
        if (StrEqual(currentName, targetArg, false))
        {
            if (match != 0)
            {
                ambiguous = true;
                return 0;
            }
            match = candidate;
        }
    }
    return match;
}

void FormatLocalizedDynamicPowerDescription(int client, RSPPower power, RSPClientLanguage language, char[] description, int maxlen)
{
    bool comma = UsesDecimalComma(language);
    switch (power)
    {
        case RSP_Leech:
        {
            int percent = g_iLeechChancePercent[client];
            if (percent < RSP_LEECH_CHANCE_MIN || percent > RSP_LEECH_CHANCE_MAX)
            {
                percent = RSP_LEECH_CHANCE_MIN;
            }
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Trafienie przeciwnika ma %d%% szansy na kradzież jego zapasowej amunicji (zakres: 20–40%%)", percent);
                default: Format(description, maxlen, "A hit steals the enemy's reserve ammo with a %d%% chance (range: 20–40%%)", percent);
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_Soldier:
        {
            float multiplier = g_fSoldierDamageMultiplier[client];
            if (multiplier < 1.15 || multiplier > 1.30) multiplier = 1.15;
            int percent = RoundToNearest((multiplier - 1.0) * 100.0);
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Zadajesz o %d%% większe obrażenia (zakres: 15–30%%)", percent);
                default: Format(description, maxlen, "You deal %d%% more damage (range: 15–30%%)", percent);
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_Rambo:
        {
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Otrzymujesz dodatkowe %d HP (zakres: +%d–%d HP)", g_iRamboRolledBonus[client], RSP_RAMBO_BONUS_MIN, RSP_RAMBO_BONUS_MAX);
                default: Format(description, maxlen, "You receive an additional %d HP (range: +%d–%d HP)", g_iRamboRolledBonus[client], RSP_RAMBO_BONUS_MIN, RSP_RAMBO_BONUS_MAX);
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_Astronaut:
        {
            float value = g_fLowGravityMultiplier[client];
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Grawitacja jest zmniejszona do x%.2f (zakres: x%.2f–x%.2f)", value, RSP_ASTRONAUT_GRAVITY_MIN, RSP_ASTRONAUT_GRAVITY_MAX);
                default: Format(description, maxlen, "Gravity is reduced to x%.2f (range: x%.2f–x%.2f)", value, RSP_ASTRONAUT_GRAVITY_MIN, RSP_ASTRONAUT_GRAVITY_MAX);
            }
            if (comma) ReplaceString(description, maxlen, ".", ",", false);
            StrCat(description, maxlen, ".");
        }
        case RSP_SpeedDemon:
        {
            float value = g_fSpeedBonus[client];
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Prędkość ruchu jest zwiększona do x%.2f (zakres: x%.2f–x%.2f)", value, RSP_SPEED_DEMON_MIN, RSP_SPEED_DEMON_MAX);
                default: Format(description, maxlen, "Your movement speed is increased to x%.2f (range: x%.2f–x%.2f)", value, RSP_SPEED_DEMON_MIN, RSP_SPEED_DEMON_MAX);
            }
            if (comma) ReplaceString(description, maxlen, ".", ",", false);
            StrCat(description, maxlen, ".");
        }
        case RSP_Armoured:
        {
            float reduction = g_fArmouredDamageReduction[client];
            if (reduction < RSP_ARMOURED_REDUCTION_MIN || reduction > RSP_ARMOURED_REDUCTION_MAX)
            {
                reduction = RSP_ARMOURED_REDUCTION_MIN;
            }
            int percent = RoundToNearest(reduction * 100.0);
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Redukcja otrzymywanych obrażeń o %d%% (zakres: 65–85%%)", percent);
                default: Format(description, maxlen, "You reduce incoming damage by %d%% (range: 65–85%%)", percent);
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_Disarmament:
        {
            int percent = g_iDisarmChancePercent[client];
            if (!IsValidDisarmChancePercent(percent)) percent = 30;
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Trafienie ma %d%% szansy na wyrzucenie trzymanej broni przeciwnika (zakres: 20–40%%)", percent);
                default: Format(description, maxlen, "A hit has a %d%% chance to make the enemy drop their held weapon (range: 20–40%%)", percent);
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_RichBoy:
        {
            int rolled = g_iRichBoyRolledBonus[client];
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Wylosowana premia: +$%d", rolled);
                default: Format(description, maxlen, "Rolled cash bonus: +$%d", rolled);
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_Dwarf:
        {
            if (g_bOldModelScaleValid[client] && HasEntProp(client, Prop_Send, "m_flModelScale"))
            {
                float scale = GetEntPropFloat(client, Prop_Send, "m_flModelScale");
                switch (language)
                {
                    case RSP_LANG_PL: Format(description, maxlen, "Twój model jest zmniejszony do x%.2f (zakres: x%.2f–x%.2f)", scale, RSP_DWARF_SCALE_MIN, RSP_DWARF_SCALE_MAX);
                    default: Format(description, maxlen, "Your model is scaled down to x%.2f (range: x%.2f–x%.2f)", scale, RSP_DWARF_SCALE_MIN, RSP_DWARF_SCALE_MAX);
                }
                if (comma) ReplaceString(description, maxlen, ".", ",", false);
                StrCat(description, maxlen, ".");
            }
            else
            {
                switch (language)
                {
                    case RSP_LANG_PL: strcopy(description, maxlen, "Zmiana rozmiaru modelu nie jest obsługiwana przez tę wersję CS:S.");
                    default: strcopy(description, maxlen, "Model scaling is not supported by this CS:S build.");
                }
            }
        }
        case RSP_Giant:
        {
            if (g_bOldModelScaleValid[client] && HasEntProp(client, Prop_Send, "m_flModelScale"))
            {
                float scale = GetEntPropFloat(client, Prop_Send, "m_flModelScale");
                int totalHealth = GetGiantTotalHealthForScale(scale);
                int additionalHealth = totalHealth - 100;
                switch (language)
                {
                    case RSP_LANG_PL: Format(description, maxlen, "Twój model jest powiększony do x%.2f (zakres: x%.2f–x%.2f). Dodatek: +%d HP za rozmiar", scale, RSP_GIANT_SCALE_MIN, RSP_GIANT_SCALE_MAX, additionalHealth);
                    default: Format(description, maxlen, "Your model is enlarged to x%.2f (range: x%.2f–x%.2f). Bonus: +%d HP for size", scale, RSP_GIANT_SCALE_MIN, RSP_GIANT_SCALE_MAX, additionalHealth);
                }
                if (comma) ReplaceString(description, maxlen, ".", ",", false);
                StrCat(description, maxlen, ".");
            }
            else
            {
                switch (language)
                {
                    case RSP_LANG_PL: strcopy(description, maxlen, "Zmiana rozmiaru modelu nie jest obsługiwana przez tę wersję CS:S.");
                    default: strcopy(description, maxlen, "Model scaling is not supported by this CS:S build.");
                }
            }
        }
        case RSP_RapidFire:
        {
            int percent = RoundToNearest((g_fRapidFireMultiplier[client] - 1.0) * 100.0);
            int minPercent = RoundToNearest((RSP_RAPID_FIRE_MIN - 1.0) * 100.0);
            int maxPercent = RoundToNearest((RSP_RAPID_FIRE_MAX - 1.0) * 100.0);
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Szybkostrzelność jest zwiększona o %d%% (zakres: +%d–%d%%)", percent, minPercent, maxPercent);
                default: Format(description, maxlen, "Your weapon fires %d%% faster (range: +%d–%d%%)", percent, minPercent, maxPercent);
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_ExplosiveAmmo:
        {
            int percent = g_iExplosiveBulletsChancePercent[client];
            if (percent < RSP_EXPLOSIVE_AMMO_CHANCE_MIN || percent > RSP_EXPLOSIVE_AMMO_CHANCE_MAX)
                percent = RSP_EXPLOSIVE_AMMO_CHANCE_MIN;
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Uderzenie pocisku ma %d%% szansy na wybuch zadający do %d obrażeń. (zakres: 15–30%%)", percent, RoundToNearest(RSP_EXPLOSIVE_AMMO_DAMAGE));
                default: Format(description, maxlen, "A bullet impact has a %d%% chance to trigger an explosion dealing up to %d damage. (range: 15–30%%)", percent, RoundToNearest(RSP_EXPLOSIVE_AMMO_DAMAGE));
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_Knockup:
        {
            int percent = g_iKnockupChancePercent[client];
            if (percent < RSP_KNOCKUP_CHANCE_MIN || percent > RSP_KNOCKUP_CHANCE_MAX)
                percent = RSP_KNOCKUP_CHANCE_MIN;
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Masz %d%% szans na podbicie wroga po trafieniu. (zakres: 20–40%%)", percent);
                default: Format(description, maxlen, "You have a %d%% chance to launch the enemy upward on hit. (range: 20–40%%)", percent);
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_Sapper:
        {
            int percent = g_iSapperSpeedPercent[client];
            if (percent < RSP_SAPPER_SPEED_MIN || percent > RSP_SAPPER_SPEED_MAX)
                percent = RSP_SAPPER_SPEED_MIN;
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Czas podkładania i rozbrajania C4 jest krótszy o %d%% (zakres: 20–60%%)", percent);
                default: Format(description, maxlen, "Planting and defusing C4 take %d%% less time (range: 20–60%%)", percent);
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_FreezingAmmo:
        {
            int percent = g_iCryoChancePercent[client];
            if (!IsValidCryoChancePercent(percent)) percent = 30;
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Trafienie ma %d%% szansy na zamrożenie ruchu oraz ataku przeciwnika na 3 sekundy. (zakres: 20–40%%)", percent);
                default: Format(description, maxlen, "A hit has a %d%% chance to freeze the enemy’s movement and block their attacks for 3 seconds. (range: 20–40%%)", percent);
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_Disorient:
        {
            int percent = g_iDisorientChancePercent[client];
            if (!IsValidDisorientChancePercent(percent)) percent = 30;
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Trafienie ma %d%% szansy na obrócenie przeciwnika o 180° (zakres: 20–40%%)", percent);
                default: Format(description, maxlen, "A hit has a %d%% chance to turn the enemy 180° (range: 20–40%%)", percent);
            }
            StrCat(description, maxlen, ".");
        }
        case RSP_Concussion:
        {
            int percent = g_iConcussionChancePercent[client];
            if (percent < RSP_CONCUSSION_CHANCE_MIN || percent > RSP_CONCUSSION_CHANCE_MAX)
                percent = RSP_CONCUSSION_CHANCE_MIN;
            switch (language)
            {
                case RSP_LANG_PL: Format(description, maxlen, "Trafienie ma %d%% szansy na oślepienie przeciwnika. (zakres: 15-30%%)", percent);
                default: Format(description, maxlen, "A hit has a %d%% chance to blind the enemy. (range: 15-30%%)", percent);
            }
            StrCat(description, maxlen, ".");
        }
    }
}

void QueuePowerAssignmentNotice(int client, RSPPower power, bool stolen, bool chameleonCopy, bool duplicatorCopy)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    DataPack pack;
    Handle timer = CreateDataTimer(RSP_POWER_ASSIGNMENT_NOTICE_DELAY, Timer_PrintDeferredPowerAssignment,
        pack, TIMER_FLAG_NO_MAPCHANGE);
    if (timer == null)
    {
        // Allocation failure fallback. Keep the same ordered helper path where possible.
        PrintPowerAssignment(client, power, stolen, chameleonCopy, duplicatorCopy);
        int selectionType = GetTargetSelectionTypeForPower(power);
        if (selectionType != RSP_TARGET_SELECT_NONE)
        {
            QueueRoundAssignmentTargetSelection(client, power, selectionType, g_iPowerNoticeGeneration[client]);
        }
        QueueRoundAssignmentRoster(client, power, g_iPowerNoticeGeneration[client]);
        return;
    }

    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(g_iRoundSerial);
    pack.WriteCell(view_as<int>(power));
    pack.WriteCell(g_iPowerNoticeGeneration[client]);
    pack.WriteCell(stolen ? 1 : 0);
    pack.WriteCell(chameleonCopy ? 1 : 0);
    pack.WriteCell(duplicatorCopy ? 1 : 0);
}

public Action Timer_PrintDeferredPowerAssignment(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    int roundSerial = pack.ReadCell();
    RSPPower power = view_as<RSPPower>(pack.ReadCell());
    int generation = pack.ReadCell();
    bool stolen = pack.ReadCell() != 0;
    bool chameleonCopy = pack.ReadCell() != 0;
    bool duplicatorCopy = pack.ReadCell() != 0;

    int client = GetClientOfUserId(userid);
    if (!g_bEnabled || !g_bSupportedMap || !g_bRoundReady ||
        client < 1 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client) ||
        roundSerial != g_iRoundSerial || g_iAssignedRound[client] != roundSerial ||
        g_iPower[client] != power || g_iPowerNoticeGeneration[client] != generation)
    {
        return Plugin_Stop;
    }

    PrintPowerAssignment(client, power, stolen, chameleonCopy, duplicatorCopy);

    int selectionType = GetTargetSelectionTypeForPower(power);
    if (selectionType != RSP_TARGET_SELECT_NONE)
    {
        QueueRoundAssignmentTargetSelection(client, power, selectionType, generation);
    }
    QueueRoundAssignmentRoster(client, power, generation);
    return Plugin_Stop;
}

void QueueRoundAssignmentTargetSelection(int client, RSPPower power, int selectionType, int generation)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    // This is a new assignment: always display its initial list 0.10 s after
    // the assignment description, even when the eligible roster matches an old snapshot.
    // Candidate construction and eligibility rules below are intentionally unchanged.
    g_bTargetSelectionForceDisplay[client] = true;
    // Cancel an older generic roster-build timer so it cannot race the precise +0.1 s list.
    StopRSPTargetSelectionBuildTimer(client);
    g_iTargetSelectionType[client] = selectionType;
    g_bTargetSelectionPending[client] = true;
    g_iTargetSelectionRound[client] = g_iRoundSerial;

    DataPack pack;
    Handle timer = CreateDataTimer(RSP_ROUND_TARGET_SELECTION_DELAY,
        Timer_BeginRoundAssignmentTargetSelection, pack, TIMER_FLAG_NO_MAPCHANGE);
    if (timer == null)
    {
        g_bTargetSelectionPending[client] = false;
        BeginRSPTargetSelection(client, selectionType);
        return;
    }
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(g_iRoundSerial);
    pack.WriteCell(view_as<int>(power));
    pack.WriteCell(generation);
    pack.WriteCell(selectionType);
}

public Action Timer_BeginRoundAssignmentTargetSelection(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    int roundSerial = pack.ReadCell();
    RSPPower power = view_as<RSPPower>(pack.ReadCell());
    int generation = pack.ReadCell();
    int selectionType = pack.ReadCell();
    int client = GetClientOfUserId(userid);
    if (!g_bEnabled || !g_bSupportedMap || !g_bRoundReady ||
        client < 1 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client) ||
        roundSerial != g_iRoundSerial || g_iAssignedRound[client] != roundSerial ||
        g_iPower[client] != power || g_iPowerNoticeGeneration[client] != generation ||
        g_iTargetSelectionType[client] != selectionType || !g_bTargetSelectionPending[client] ||
        !IsValidPlayingClient(client) || !IsPlayerAlive(client))
    {
        return Plugin_Stop;
    }

    StopRSPTargetSelectionBuildTimer(client);
    g_bTargetSelectionPending[client] = false;
    BeginRSPTargetSelection(client, selectionType);
    return Plugin_Stop;
}

void QueueRoundAssignmentRoster(int client, RSPPower power, int generation)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    DataPack pack;
    Handle timer = CreateDataTimer(RSP_ROUND_POWER_ROSTER_DELAY,
        Timer_PrintRoundAssignmentRoster, pack, TIMER_FLAG_NO_MAPCHANGE);
    if (timer == null)
    {
        PrintPowerRosterForClient(client);
        return;
    }
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(g_iRoundSerial);
    pack.WriteCell(view_as<int>(power));
    pack.WriteCell(generation);
}

public Action Timer_PrintRoundAssignmentRoster(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    int roundSerial = pack.ReadCell();
    RSPPower power = view_as<RSPPower>(pack.ReadCell());
    int generation = pack.ReadCell();
    int client = GetClientOfUserId(userid);
    if (!g_bEnabled || !g_bSupportedMap || !g_bRoundReady ||
        client < 1 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client) ||
        roundSerial != g_iRoundSerial || g_iAssignedRound[client] != roundSerial ||
        g_iPower[client] != power || g_iPowerNoticeGeneration[client] != generation)
    {
        return Plugin_Stop;
    }

    PrintPowerRosterForClient(client);
    return Plugin_Stop;
}

void QueueTargetSelectionForAssignedPower(int client, RSPPower power)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    int selectionType = GetTargetSelectionTypeForPower(power);
    if (selectionType == RSP_TARGET_SELECT_NONE)
    {
        return;
    }

    // A new assignment always displays the initial list, even if a previous
    // snapshot for this same selection type was identical. This changes display
    // timing/refresh only; the candidate and eligibility filters are untouched.
    g_bTargetSelectionForceDisplay[client] = true;
    QueueRSPTargetSelection(client, selectionType);
}

bool IsRSPManualSkillPower(RSPPower power)
{
    return power == RSP_Reviver || power == RSP_Medic || power == RSP_Swapper ||
        power == RSP_Retreat || power == RSP_EnemySpawn || power == RSP_NoClip ||
        power == RSP_GodMode || power == RSP_RandomWeapon || power == RSP_StripWeapons ||
        power == RSP_ExplodingBarrel || power == RSP_Dash || power == RSP_Reverser ||
        power == RSP_Replica || power == RSP_Hook || power == RSP_Anomaly ||
        power == RSP_Spectator ||
        power == RSP_Builder || power == RSP_Inventor || power == RSP_WeaponSwap ||
        power == RSP_Miner || power == RSP_Entropy || power == RSP_Damager ||
        power == RSP_HealingAngel;
}

void PrintRSPBindInstruction(int client, RSPClientLanguage language)
{
    switch (language)
    {
        case RSP_LANG_PL:
        {
            PrintToChat(client, "\x077FFFD4[RSP]\x01 Aktywacja: musisz użyć binda, wpisz w konsoli:");
            PrintToChat(client, "\x077FFFD4bind \"x\" \"rsp_useskill\"\x01 (x zastąp dowolnym klawiszem)");
        }
        default:
        {
            PrintToChat(client, "\x077FFFD4[RSP]\x01 Activation: you must use a bind. Enter in console:");
            PrintToChat(client, "\x077FFFD4bind \"x\" \"rsp_useskill\"\x01 (replace x with any key)");
        }
    }
}

void PrintPowerAssignment(int client, RSPPower power, bool stolen = false, bool chameleonCopy = false, bool duplicatorCopy = false, bool avengerReward = false)
{
    int powerIndex = view_as<int>(power);
    RSPClientLanguage language = GetRSPClientLanguage(client);
    char description[512];
    CopyPowerDescriptionForLanguage(language, powerIndex, description, sizeof(description));
    FormatLocalizedDynamicPowerDescription(client, power, language, description, sizeof(description));
    char label[96];
    if (chameleonCopy)
    {
        switch (language)
        {
            case RSP_LANG_PL: strcopy(label, sizeof(label), "Chameleon skopiował supermoc");
            default: strcopy(label, sizeof(label), "Chameleon copied the superpower");
        }
    }
    else if (duplicatorCopy)
    {
        switch (language)
        {
            case RSP_LANG_PL: strcopy(label, sizeof(label), "Skopiowałeś supermoc");
            default: strcopy(label, sizeof(label), "You copied the superpower");
        }
    }
    else if (avengerReward)
    {
        switch (language)
        {
            case RSP_LANG_PL: strcopy(label, sizeof(label), "Otrzymałeś super moc po martwym sojuszniku");
            default: strcopy(label, sizeof(label), "You received the superpower of a fallen teammate");
        }
    }
    else if (stolen)
    {
        switch (language)
        {
            case RSP_LANG_PL: strcopy(label, sizeof(label), "Ukradłeś supermoc");
            default: strcopy(label, sizeof(label), "You stole the superpower");
        }
    }
    else
    {
        switch (language)
        {
            case RSP_LANG_PL: strcopy(label, sizeof(label), "Twoja super moc");
            default: strcopy(label, sizeof(label), "Your superpower");
        }
    }

    // Preserve team colors for player names; power names are green and descriptions use default color.
    PrintToChat(client, "\x04[RSP]\x01 %s: \x04%s\x01 - \x01%s",
        label, g_sPowerNamesEn[powerIndex], description);

    if (IsRSPManualSkillPower(power))
    {
        PrintRSPBindInstruction(client, language);
    }

    if (power == RSP_Gambler)
    {
        PrintGamblerOffers(client);
    }
}

bool GetPowerRosterValue(int client, RSPClientLanguage language, char[] suffix, int maxlen)
{
    suffix[0] = '\0';
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return false;
    }

    bool comma = UsesDecimalComma(language);
    switch (g_iPower[client])
    {
        case RSP_Soldier:
        {
            int percent = RoundToNearest((g_fSoldierDamageMultiplier[client] - 1.0) * 100.0);
            Format(suffix, maxlen, " +%d%%", percent);
        }
        case RSP_Rambo:
            Format(suffix, maxlen, " +%d HP", g_iRamboRolledBonus[client]);
        case RSP_Astronaut:
        {
            Format(suffix, maxlen, " x%.2f", g_fLowGravityMultiplier[client]);
            if (comma) ReplaceString(suffix, maxlen, ".", ",", false);
        }
        case RSP_SpeedDemon:
        {
            Format(suffix, maxlen, " x%.2f", g_fSpeedBonus[client]);
            if (comma) ReplaceString(suffix, maxlen, ".", ",", false);
        }
        case RSP_Disarmament:
        {
            int percent = g_iDisarmChancePercent[client];
            if (IsValidDisarmChancePercent(percent))
            {
                Format(suffix, maxlen, " %d%%", percent);
            }
        }
        case RSP_RichBoy:
        {
            Format(suffix, maxlen, " +$%d", g_iRichBoyRolledBonus[client]);
        }
        case RSP_ExplosiveAmmo:
        {
            int percent = g_iExplosiveBulletsChancePercent[client];
            if (percent < RSP_EXPLOSIVE_AMMO_CHANCE_MIN || percent > RSP_EXPLOSIVE_AMMO_CHANCE_MAX)
            {
                percent = RSP_EXPLOSIVE_AMMO_CHANCE_MIN;
            }
            Format(suffix, maxlen, " %d%%", percent);
        }
        case RSP_Leech:
        {
            int percent = g_iLeechChancePercent[client];
            if (percent < RSP_LEECH_CHANCE_MIN || percent > RSP_LEECH_CHANCE_MAX)
            {
                percent = RSP_LEECH_CHANCE_MIN;
            }
            Format(suffix, maxlen, " %d%%", percent);
        }
        case RSP_Knockup:
        {
            int percent = g_iKnockupChancePercent[client];
            if (percent < RSP_KNOCKUP_CHANCE_MIN || percent > RSP_KNOCKUP_CHANCE_MAX)
            {
                percent = RSP_KNOCKUP_CHANCE_MIN;
            }
            Format(suffix, maxlen, " %d%%", percent);
        }
        case RSP_Sapper:
        {
            int percent = g_iSapperSpeedPercent[client];
            if (percent < RSP_SAPPER_SPEED_MIN || percent > RSP_SAPPER_SPEED_MAX)
            {
                percent = RSP_SAPPER_SPEED_MIN;
            }
            Format(suffix, maxlen, " +%d%%", percent);
        }
        case RSP_Armoured:
        {
            float reduction = g_fArmouredDamageReduction[client];
            if (reduction < RSP_ARMOURED_REDUCTION_MIN || reduction > RSP_ARMOURED_REDUCTION_MAX)
            {
                reduction = RSP_ARMOURED_REDUCTION_MIN;
            }
            Format(suffix, maxlen, " -%d%%", RoundToNearest(reduction * 100.0));
        }
        case RSP_Dwarf, RSP_Giant:
        {
            if (HasEntProp(client, Prop_Send, "m_flModelScale"))
            {
                float scale = GetEntPropFloat(client, Prop_Send, "m_flModelScale");
                Format(suffix, maxlen, " x%.2f", scale);
                if (comma) ReplaceString(suffix, maxlen, ".", ",", false);
            }
        }
        case RSP_RapidFire:
        {
            int percent = RoundToNearest((g_fRapidFireMultiplier[client] - 1.0) * 100.0);
            Format(suffix, maxlen, " +%d%%", percent);
        }
        case RSP_FreezingAmmo:
        {
            int percent = g_iCryoChancePercent[client];
            if (IsValidCryoChancePercent(percent))
            {
                Format(suffix, maxlen, " %d%%", percent);
            }
        }
        case RSP_Disorient:
        {
            int percent = g_iDisorientChancePercent[client];
            if (IsValidDisorientChancePercent(percent))
            {
                Format(suffix, maxlen, " %d%%", percent);
            }
        }
    }
    return suffix[0] != '\0';
}

void PrintPowerRosterForClient(int recipient)
{
    if (recipient < 1 || recipient > MaxClients || !IsClientInGame(recipient) || IsFakeClient(recipient))
    {
        return;
    }

    int recipientTeam = GetClientTeam(recipient);
    RSPClientLanguage language = GetRSPClientLanguage(recipient);
    if ((recipientTeam == CS_TEAM_CT || recipientTeam == CS_TEAM_T) && IsPlayerAlive(recipient))
    {
        int memberClients[MAXPLAYERS + 1];
        int powerIndexes[MAXPLAYERS + 1];
        int listed = 0;
        for (int member = 1; member <= MaxClients; member++)
        {
            if (member == recipient || !IsClientInGame(member) || !IsPlayerAlive(member) ||
                GetClientTeam(member) != recipientTeam || g_iAssignedRound[member] != g_iRoundSerial ||
                g_iPower[member] == RSP_None)
            {
                continue;
            }
            int powerIndex = view_as<int>(g_iPower[member]);
            if (powerIndex < 0 || powerIndex >= view_as<int>(RSP_PowerCount)) continue;
            memberClients[listed] = member;
            powerIndexes[listed] = powerIndex;
            listed++;
        }
        if (listed == 0) return;
        char teammateHeading[64];
        GetTeammateRosterHeading(language, teammateHeading, sizeof(teammateHeading));
        PrintToChat(recipient, "\x04[RSP]\x01 %s", teammateHeading);
        for (int i = 0; i < listed; i++)
        {
            char valueSuffix[64];
            GetPowerRosterValue(memberClients[i], language, valueSuffix, sizeof(valueSuffix));
            PrintToChat(recipient, recipientTeam == CS_TEAM_CT
                ? "\x0799CCFF%N\x01 - \x04%s\x01%s"
                : "\x07FF4040%N\x01 - \x04%s\x01%s",
                memberClients[i], g_sPowerNamesEn[powerIndexes[i]], valueSuffix);
        }
        return;
    }

    for (int teamIndex = 0; teamIndex < 2; teamIndex++)
    {
        int team = teamIndex == 0 ? CS_TEAM_CT : CS_TEAM_T;
        int memberClients[MAXPLAYERS + 1];
        int powerIndexes[MAXPLAYERS + 1];
        int listed = 0;
        for (int member = 1; member <= MaxClients; member++)
        {
            if (!IsClientInGame(member) || !IsPlayerAlive(member) || GetClientTeam(member) != team ||
                g_iAssignedRound[member] != g_iRoundSerial || g_iPower[member] == RSP_None)
            {
                continue;
            }
            int powerIndex = view_as<int>(g_iPower[member]);
            if (powerIndex < 0 || powerIndex >= view_as<int>(RSP_PowerCount)) continue;
            memberClients[listed] = member;
            powerIndexes[listed] = powerIndex;
            listed++;
        }
        if (listed == 0) continue;

        char rosterLead[32];
        char teamLabel[40];
        GetSpectatorRosterLead(language, rosterLead, sizeof(rosterLead));
        if (team == CS_TEAM_CT)
        {
            GetCTTeamLabel(language, teamLabel, sizeof(teamLabel));
            PrintToChat(recipient, "\x04[RSP]\x01 %s \x0799CCFF%s:\x01", rosterLead, teamLabel);
        }
        else
        {
            GetTTeamLabel(language, teamLabel, sizeof(teamLabel));
            PrintToChat(recipient, "\x04[RSP]\x01 %s \x07FF4040%s:\x01", rosterLead, teamLabel);
        }

        for (int i = 0; i < listed; i++)
        {
            char valueSuffix[64];
            GetPowerRosterValue(memberClients[i], language, valueSuffix, sizeof(valueSuffix));
            PrintToChat(recipient, team == CS_TEAM_CT
                ? "\x0799CCFF%N\x01 - \x04%s\x01%s"
                : "\x07FF4040%N\x01 - \x04%s\x01%s",
                memberClients[i], g_sPowerNamesEn[powerIndexes[i]], valueSuffix);
        }
    }
}

void QueueObserverPowerRoster(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !g_bEnabled || !g_bSupportedMap || !g_bRoundReady ||
        GetClientTeam(client) != CS_TEAM_SPECTATOR || g_bObserverRosterRefreshQueued[client])
    {
        return;
    }

    g_bObserverRosterRefreshQueued[client] = true;
    Handle timer = CreateTimer(RSP_OBSERVER_ROSTER_REFRESH_DELAY,
        Timer_PrintObserverPowerRoster, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    if (timer == null)
    {
        g_bObserverRosterRefreshQueued[client] = false;
        // Best-effort fallback: this is an observer-only roster, not an assignment notice.
        PrintPowerRosterForClient(client);
    }
}

public Action Timer_PrintObserverPowerRoster(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return Plugin_Stop;
    }

    g_bObserverRosterRefreshQueued[client] = false;
    if (!g_bEnabled || !g_bSupportedMap || !g_bRoundReady ||
        GetClientTeam(client) != CS_TEAM_SPECTATOR || IsPlayerAlive(client))
    {
        return Plugin_Stop;
    }

    PrintPowerRosterForClient(client);
    return Plugin_Stop;
}

void GetTeammateRosterHeading(RSPClientLanguage language, char[] text, int maxlen)
{
    switch (language)
    {
        case RSP_LANG_PL: strcopy(text, maxlen, "Supermoce kolegów:");
        default: strcopy(text, maxlen, "Teammate powers:");
    }
}

void GetSpectatorRosterLead(RSPClientLanguage language, char[] text, int maxlen)
{
    switch (language)
    {
        case RSP_LANG_PL: strcopy(text, maxlen, "Supermoce");
        default: strcopy(text, maxlen, "Powers");
    }
}

void GetCTTeamLabel(RSPClientLanguage language, char[] text, int maxlen)
{
    switch (language)
    {
        case RSP_LANG_PL: strcopy(text, maxlen, "antyterrorystów");
        default: strcopy(text, maxlen, "Counter-Terrorists");
    }
}

void GetTTeamLabel(RSPClientLanguage language, char[] text, int maxlen)
{
    switch (language)
    {
        case RSP_LANG_PL: strcopy(text, maxlen, "terrorystów");
        default: strcopy(text, maxlen, "Terrorists");
    }
}

void PrecacheDisguiseModels()
{
    for (int i = 0; i < sizeof(g_sDisguiseCTModels); i++)
    {
        if (!IsModelPrecached(g_sDisguiseCTModels[i]))
        {
            PrecacheModel(g_sDisguiseCTModels[i], true);
        }
    }

    for (int i = 0; i < sizeof(g_sDisguiseTModels); i++)
    {
        if (!IsModelPrecached(g_sDisguiseTModels[i]))
        {
            PrecacheModel(g_sDisguiseTModels[i], true);
        }
    }
}

void ApplyDisguiseModel(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) ||
        g_bDisguiseApplied[client])
    {
        return;
    }

    int team = GetClientTeam(client);
    if (team != CS_TEAM_CT && team != CS_TEAM_T)
    {
        return;
    }

    char originalModel[PLATFORM_MAX_PATH];
    GetClientModel(client, originalModel, sizeof(originalModel));
    if (originalModel[0] == '\0')
    {
        return;
    }

    char disguiseModel[PLATFORM_MAX_PATH];
    if (team == CS_TEAM_CT)
    {
        strcopy(disguiseModel, sizeof(disguiseModel), g_sDisguiseTModels[GetRandomInt(0, sizeof(g_sDisguiseTModels) - 1)]);
    }
    else
    {
        strcopy(disguiseModel, sizeof(disguiseModel), g_sDisguiseCTModels[GetRandomInt(0, sizeof(g_sDisguiseCTModels) - 1)]);
    }

    if (!IsModelPrecached(disguiseModel))
    {
        return;
    }

    strcopy(g_sDisguiseOriginalModel[client], sizeof(g_sDisguiseOriginalModel[]), originalModel);
    SetEntityModel(client, disguiseModel);
    g_bDisguiseApplied[client] = true;
}

void RestoreDisguiseModel(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    if (g_bDisguiseApplied[client] && IsClientInGame(client) && IsValidEntity(client) &&
        g_sDisguiseOriginalModel[client][0] != '\0')
    {
        SetEntityModel(client, g_sDisguiseOriginalModel[client]);
    }

    g_bDisguiseApplied[client] = false;
    g_bDisguiseDeathTransition[client] = false;
    g_fDisguiseDeathTransitionUntil[client] = 0.0;
    g_sDisguiseOriginalModel[client][0] = '\0';
}

void BuildGamblerOffers(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    RSPPower candidates[sizeof(g_RSPSelectablePowers)];
    int candidateCount = 0;
    for (int i = 0; i < sizeof(g_RSPSelectablePowers); i++)
    {
        // Only exclude Gambler itself to prevent a nested Gambler selection loop.
        // Thief, Duplicator and Chameleon are valid, intentional risk/reward offers.
        if (g_RSPSelectablePowers[i] == RSP_Gambler)
        {
            continue;
        }
        candidates[candidateCount++] = g_RSPSelectablePowers[i];
    }

    if (candidateCount < RSP_GAMBLER_OPTIONS)
    {
        g_bGamblerPendingSelection[client] = false;
        g_bGamblerChatIntercept[client] = false;
        return;
    }

    // Partial Fisher-Yates: three distinct choices, drawn uniformly from all active powers except Gambler itself.
    for (int i = 0; i < RSP_GAMBLER_OPTIONS; i++)
    {
        int chosen = GetRandomInt(i, candidateCount - 1);
        RSPPower temporary = candidates[i];
        candidates[i] = candidates[chosen];
        candidates[chosen] = temporary;
        g_eGamblerOffers[client][i] = candidates[i];
        RollGamblerOfferParameters(client, i, candidates[i]);
    }

    g_bGamblerPendingSelection[client] = true;
    g_bGamblerChatIntercept[client] = true;
    g_bGamblerApplyingChoice[client] = false;
    g_iGamblerSelectedOfferIndex[client] = -1;
}

void RollGamblerOfferParameters(int client, int index, RSPPower power)
{
    g_iGamblerRamboBonus[client][index] = 0;
    g_iGamblerRichBoyBonus[client][index] = 0;
    g_fGamblerLowGravity[client][index] = 0.0;
    g_fGamblerSpeedBonus[client][index] = 0.0;
    g_iGamblerDisarmChance[client][index] = 0;
    g_iGamblerLeechChance[client][index] = 0;
    g_fGamblerModelScale[client][index] = 1.0;
    g_fGamblerArmouredReduction[client][index] = RSP_ARMOURED_REDUCTION_MIN;
    g_fGamblerRapidFireMultiplier[client][index] = 1.0;
    g_iGamblerCryoChance[client][index] = 0;
    g_iGamblerDisorientChance[client][index] = 0;
    g_iGamblerKnockupChance[client][index] = 0;

    switch (power)
    {
        case RSP_Rambo: g_iGamblerRamboBonus[client][index] = GetRandomInt(RSP_RAMBO_BONUS_MIN, RSP_RAMBO_BONUS_MAX);
        case RSP_RichBoy: g_iGamblerRichBoyBonus[client][index] = GetRandomInt(RSP_RICH_BOY_MIN / RSP_RICH_BOY_STEP, RSP_RICH_BOY_MAX / RSP_RICH_BOY_STEP) * RSP_RICH_BOY_STEP;
        case RSP_Astronaut: g_fGamblerLowGravity[client][index] = GetRandomFloat(RSP_ASTRONAUT_GRAVITY_MIN, RSP_ASTRONAUT_GRAVITY_MAX);
        case RSP_SpeedDemon: g_fGamblerSpeedBonus[client][index] = GetRandomFloat(RSP_SPEED_DEMON_MIN, RSP_SPEED_DEMON_MAX);
        case RSP_Disarmament: g_iGamblerDisarmChance[client][index] = RollDisarmChancePercent();
        case RSP_Leech: g_iGamblerLeechChance[client][index] = GetRandomInt(RSP_LEECH_CHANCE_MIN, RSP_LEECH_CHANCE_MAX);
        case RSP_Dwarf: g_fGamblerModelScale[client][index] = GetRandomFloat(RSP_DWARF_SCALE_MIN, RSP_DWARF_SCALE_MAX);
        case RSP_Giant: g_fGamblerModelScale[client][index] = GetRandomGiantScale();
        case RSP_Armoured: g_fGamblerArmouredReduction[client][index] = GetRandomFloat(RSP_ARMOURED_REDUCTION_MIN, RSP_ARMOURED_REDUCTION_MAX);
        case RSP_RapidFire: g_fGamblerRapidFireMultiplier[client][index] = GetRandomFloat(RSP_RAPID_FIRE_MIN, RSP_RAPID_FIRE_MAX);
        case RSP_FreezingAmmo: g_iGamblerCryoChance[client][index] = GetRandomInt(20, 40);
        case RSP_Disorient: g_iGamblerDisorientChance[client][index] = GetRandomInt(20, 40);
        case RSP_Knockup: g_iGamblerKnockupChance[client][index] = GetRandomInt(RSP_KNOCKUP_CHANCE_MIN, RSP_KNOCKUP_CHANCE_MAX);
    }
}

void PrintGamblerOffers(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !g_bGamblerPendingSelection[client])
    {
        return;
    }
    for (int i = 0; i < RSP_GAMBLER_OPTIONS; i++)
    {
        int powerIndex = view_as<int>(g_eGamblerOffers[client][i]);
        // Do not reveal rolled values before the player commits to an offer.
        // The rolled parameters remain cached and are applied if that option is chosen.
        PrintToChat(client, "\x01/%d - \x04%s", i + 1,
            g_sPowerNamesEn[powerIndex]);
    }
}

bool ParseRSPNumericSelection(const char[] text, int &number)
{
    int length = strlen(text);
    if (length < 2 || length > 8 || text[0] != '/')
    {
        return false;
    }
    number = 0;
    for (int i = 1; i < length; i++)
    {
        if (text[i] < '0' || text[i] > '9')
        {
            return false;
        }
        number = (number * 10) + (text[i] - '0');
    }
    return true;
}

public Action Command_GamblerChat(int client, const char[] command, int argc)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return Plugin_Continue;
    }
    if (g_bSpectatorActive[client])
        return Plugin_Handled;

    char text[64];
    GetCmdArgString(text, sizeof(text));
    StripQuotes(text);
    TrimString(text);

    int selectionNumber;
    if (!ParseRSPNumericSelection(text, selectionNumber))
    {
        return Plugin_Continue;
    }

    if (g_bTargetSelectionPending[client])
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Przygotowuję listę przeciwników. Spróbuj ponownie za chwilę."
            : "\x04[RSP]\x01 Preparing the enemy list. Try again in a moment.");
        return Plugin_Handled;
    }
    if (g_iTargetSelectionType[client] != RSP_TARGET_SELECT_NONE)
    {
        return HandleRSPTargetSelectionChat(client, selectionNumber);
    }

    if (strlen(text) != 2 || selectionNumber < 1 || selectionNumber > RSP_GAMBLER_OPTIONS)
    {
        return Plugin_Continue;
    }
    if (!g_bGamblerChatIntercept[client])
    {
        return Plugin_Continue;
    }
    if (!g_bGamblerPendingSelection[client] || g_iPower[client] != RSP_Gambler)
    {
        g_bGamblerChatIntercept[client] = false;
        return Plugin_Continue;
    }
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
        !IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iAssignedRound[client] != g_iRoundSerial)
    {
        return Plugin_Handled;
    }

    int option = text[1] - '1';
    RSPPower chosenPower = g_eGamblerOffers[client][option];
    if (chosenPower == RSP_None || chosenPower == RSP_Gambler ||
        view_as<int>(chosenPower) < 0 || view_as<int>(chosenPower) >= view_as<int>(RSP_PowerCount))
    {
        return Plugin_Handled;
    }

    // Route the choice through the same reset/assignment path as every other power.
    // The offer index carries the already-rolled parameters into ApplyPower unchanged.
    AssignPowerToClient(client, chosenPower, false, false, false, false, false, false, option);
    return Plugin_Handled;
}

void QueueCurserShotResolution(int client)
{
    if (client < 1 || client > MaxClients || !IsValidPlayingClient(client) ||
        !IsPlayerAlive(client) || !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client))
    {
        return;
    }

    if (!g_bCurserTargetCursed[client] || g_iCurserTargetCurseRound[client] != g_iRoundSerial)
    {
        return;
    }

    int hitCounterAtFire = g_iCurserEnemyHitCounter[client];
    if (hitCounterAtFire > g_iCurserResolvedEnemyHitCounter[client])
    {
        // The engine already traced this firing event into an enemy before weapon_fire.
        g_iCurserResolvedEnemyHitCounter[client] = hitCounterAtFire;
        return;
    }

    // Defer one frame in case this build emits weapon_fire before TraceAttack for the same shot.
    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(hitCounterAtFire);
    RequestFrame(Frame_ResolveCurserShot, pack);
}

public void Frame_ResolveCurserShot(any data)
{
    DataPack pack = view_as<DataPack>(data);
    if (pack == null)
    {
        return;
    }

    pack.Reset();
    int userid = pack.ReadCell();
    int hitCounterAtFire = pack.ReadCell();
    delete pack;

    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsValidPlayingClient(client) ||
        !IsPlayerAlive(client) || !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client))
    {
        return;
    }

    if (!g_bCurserTargetCursed[client] || g_iCurserTargetCurseRound[client] != g_iRoundSerial)
    {
        return;
    }

    int currentHitCounter = g_iCurserEnemyHitCounter[client];
    if (currentHitCounter > hitCounterAtFire)
    {
        // A TraceAttack arrived after weapon_fire but before this frame.
        if (currentHitCounter > g_iCurserResolvedEnemyHitCounter[client])
        {
            g_iCurserResolvedEnemyHitCounter[client] = currentHitCounter;
        }
        return;
    }

    if (hitCounterAtFire > g_iCurserResolvedEnemyHitCounter[client])
    {
        g_iCurserResolvedEnemyHitCounter[client] = hitCounterAtFire;
    }

    int health = GetClientHealth(client);
    if (health <= 5)
    {
        ForcePlayerSuicide(client);
    }
    else
    {
        SetEntityHealth(client, health - 5);
    }
}

void StopRSPTargetSelectionBuildTimer(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }
    if (g_hTargetSelectionBuildTimer[client] != null)
    {
        delete g_hTargetSelectionBuildTimer[client];
        g_hTargetSelectionBuildTimer[client] = null;
    }
}

void ClearRSPTargetSelection(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }
    StopRSPTargetSelectionBuildTimer(client);
    g_iTargetSelectionType[client] = RSP_TARGET_SELECT_NONE;
    g_bTargetSelectionPending[client] = false;
    g_bTargetSelectionForceDisplay[client] = false;
    g_bTargetSelectionInitialized[client] = false;
    g_iTargetSelectionCount[client] = 0;
    g_iTargetSelectionRound[client] = 0;
    for (int i = 0; i <= MAXPLAYERS; i++)
    {
        g_iTargetSelectionUserIds[client][i] = 0;
        g_eTargetSelectionPowerSnapshot[client][i] = RSP_None;
        g_iTargetSelectionTeamSnapshot[client][i] = 0;
    }
}

void FormatShortTargetName(int target, char[] output, int maxlen)
{
    output[0] = '\0';
    if (target < 1 || target > MaxClients || !IsClientInGame(target) || maxlen < 2)
    {
        return;
    }

    char original[MAX_NAME_LENGTH];
    GetClientName(target, original, sizeof(original));
    int originalLength = strlen(original);
    int pos = 0;
    int written = 0;
    int visibleChars = 0;
    while (pos < originalLength && visibleChars < 20 && written < maxlen - 1)
    {
        int firstByte = original[pos] & 0xFF;
        int charBytes = 1;
        if ((firstByte & 0xE0) == 0xC0) charBytes = 2;
        else if ((firstByte & 0xF0) == 0xE0) charBytes = 3;
        else if ((firstByte & 0xF8) == 0xF0) charBytes = 4;
        if (pos + charBytes > originalLength || written + charBytes >= maxlen)
        {
            break;
        }
        for (int b = 0; b < charBytes; b++)
        {
            output[written++] = original[pos + b];
        }
        pos += charBytes;
        visibleChars++;
    }
    if (pos < originalLength && written + 3 < maxlen)
    {
        output[written++] = '.';
        output[written++] = '.';
        output[written++] = '.';
    }
    output[written] = '\0';
}

bool IsRSPTargetSelectionType(int selectionType)
{
    return selectionType >= RSP_TARGET_SELECT_THIEF && selectionType <= RSP_TARGET_SELECT_BLACKOUT;
}

bool DoesClientOwnTargetPower(int client, int selectionType)
{
    if (client < 1 || client > MaxClients)
    {
        return false;
    }
    switch (selectionType)
    {
        case RSP_TARGET_SELECT_THIEF: return g_iPower[client] == RSP_Thief;
        case RSP_TARGET_SELECT_CURSER: return g_iPower[client] == RSP_Curser;
        case RSP_TARGET_SELECT_BANKRUPT: return g_iPower[client] == RSP_Bankrupt;
        case RSP_TARGET_SELECT_EXTORTION: return g_iPower[client] == RSP_Extortion;
        case RSP_TARGET_SELECT_DUPLICATOR: return g_iPower[client] == RSP_Duplicator;
        case RSP_TARGET_SELECT_HACKER: return g_iPower[client] == RSP_Hacker;
        case RSP_TARGET_SELECT_SCIENTIST: return g_iPower[client] == RSP_Scientist;
        case RSP_TARGET_SELECT_GROUNDER: return g_iPower[client] == RSP_Grounder && !g_bGrounderUsedThisAssignment[client];
        case RSP_TARGET_SELECT_BLACKOUT: return g_iPower[client] == RSP_Blackout && !g_bBlackoutUsedThisAssignment[client];
    }
    return false;
}

int GetTargetSelectionTypeForPower(RSPPower power)
{
    switch (power)
    {
        case RSP_Thief: return RSP_TARGET_SELECT_THIEF;
        case RSP_Curser: return RSP_TARGET_SELECT_CURSER;
        case RSP_Bankrupt: return RSP_TARGET_SELECT_BANKRUPT;
        case RSP_Extortion: return RSP_TARGET_SELECT_EXTORTION;
        case RSP_Duplicator: return RSP_TARGET_SELECT_DUPLICATOR;
        case RSP_Hacker: return RSP_TARGET_SELECT_HACKER;
        case RSP_Scientist: return RSP_TARGET_SELECT_SCIENTIST;
        case RSP_Grounder: return RSP_TARGET_SELECT_GROUNDER;
        case RSP_Blackout: return RSP_TARGET_SELECT_BLACKOUT;
    }
    return RSP_TARGET_SELECT_NONE;
}

bool IsRSPPowerCopyable(RSPPower power)
{
    if (!IsRSPPowerSelectable(power)) return false;
    switch (power)
    {
        case RSP_Gambler, RSP_Thief, RSP_Curser, RSP_Bankrupt, RSP_Extortion,
             RSP_Duplicator, RSP_Hacker, RSP_Scientist, RSP_Chameleon:
            return false;
    }
    return true;
}

// Chameleon copies the first enemy's selectable power on the first kill.
// Unlike Thief/Duplicator candidate rules, it can inherit another target-selection
// power (for example Blackout, Grounder, Thief or Scientist); only Chameleon itself
// is excluded to prevent recursive Chameleon inheritance.
bool IsRSPPowerCopyableByChameleon(RSPPower power)
{
    return IsRSPPowerSelectable(power) && power != RSP_Chameleon;
}

bool IsRSPPowerCopyableByTargetSelection(RSPPower power)
{
    if (!IsRSPPowerSelectable(power))
    {
        return false;
    }

    // Thief/Duplicator may deliberately choose Chameleon; Chameleon's automatic kill-copy
    // still uses IsRSPPowerCopyable and therefore cannot chain Chameleon into Chameleon.
    if (power == RSP_Chameleon)
    {
        return true;
    }
    return IsRSPPowerCopyable(power);
}

bool IsRSPRadarDisabled(int client)
{
    return client >= 1 && client <= MaxClients && IsClientInGame(client) &&
        g_iHackerOwnerUserId[client] != 0 && g_iHackerRound[client] == g_iRoundSerial;
}


void CompleteHackerEffectNotice(int target, int ownerUserId, bool fullRadarHidden)
{
    int owner = GetClientOfUserId(ownerUserId);
    if (target < 1 || target > MaxClients || !IsClientInGame(target) ||
        !IsRSPRadarDisabled(target) || g_iHackerOwnerUserId[target] != ownerUserId ||
        owner < 1 || owner > MaxClients || !IsClientInGame(owner))
    {
        return;
    }

    g_iHackerRadarPendingOwnerUserId[target] = 0;
    if (fullRadarHidden)
    {
        PrintToChat(owner, IsPolishClient(owner)
            ? "\x04[RSP]\x01 Radar przeciwnika został całkowicie ukryty."
            : "\x04[RSP]\x01 The enemy's radar panel has been hidden.");
        PrintRSPTargetEffectNotice(target, owner, RSP_NOTICE_HACKER);
    }
    else
    {
        PrintToChat(owner, IsPolishClient(owner)
            ? "\x04[RSP]\x01 Zakłócono kontakty radarowe, ale nie udało się ukryć całego panelu radaru."
            : "\x04[RSP]\x01 Radar contacts are jammed, but the full radar panel could not be hidden.");
        PrintRSPTargetEffectNotice(target, owner, RSP_NOTICE_HACKER_PARTIAL);
    }
}

void RecordHackerRealFlashEndTime(int target)
{
    if (target < 1 || target > MaxClients || !IsClientInGame(target) ||
        !HasEntProp(target, Prop_Send, "m_flFlashDuration"))
    {
        return;
    }

    float duration = GetEntPropFloat(target, Prop_Send, "m_flFlashDuration");
    if (duration <= 0.0)
    {
        return;
    }

    float endTime = GetGameTime() + duration;
    if (HasEntProp(target, Prop_Send, "m_flFlashStartTime"))
    {
        float startTime = GetEntPropFloat(target, Prop_Send, "m_flFlashStartTime");
        endTime = startTime + duration;
    }
    if (endTime > g_fHackerRealFlashUntil[target])
    {
        g_fHackerRealFlashUntil[target] = endTime;
    }
}

bool GetHackerRealFlashTimeRemaining(int target, float &remaining)
{
    remaining = 0.0;
    if (target < 1 || target > MaxClients || !IsClientInGame(target))
    {
        return false;
    }

    float now = GetGameTime();
    if (g_fHackerRealFlashUntil[target] > now + 0.05)
    {
        remaining = g_fHackerRealFlashUntil[target] - now;
        return true;
    }

    // A start-time sendprop permits an independent current-flash check. Do not fall back
    // to m_flFlashDuration alone: CS:S can leave that duration nonzero after a flash fades.
    if (HasEntProp(target, Prop_Send, "m_flFlashDuration") &&
        HasEntProp(target, Prop_Send, "m_flFlashStartTime"))
    {
        float duration = GetEntPropFloat(target, Prop_Send, "m_flFlashDuration");
        float startTime = GetEntPropFloat(target, Prop_Send, "m_flFlashStartTime");
        float endTime = startTime + duration;
        if (duration > 0.0 && endTime > now + 0.05)
        {
            g_fHackerRealFlashUntil[target] = endTime;
            remaining = endTime - now;
            return true;
        }
    }

    return false;
}

bool ApplyHackerRadarFlashOverride(int target)
{
    if (target < 1 || target > MaxClients || !IsClientInGame(target) ||
        !HasEntProp(target, Prop_Send, "m_flFlashDuration") ||
        !HasEntProp(target, Prop_Send, "m_flFlashMaxAlpha"))
    {
        return false;
    }
    // Reassert the values on respawn even if the active flag survived the life change;
    // CS:S may reset player flash properties during spawn while the RSP effect persists.
    if (!g_bHackerRadarFlashStateSaved[target])
    {
        g_fHackerOriginalFlashDuration[target] = GetEntPropFloat(target, Prop_Send, "m_flFlashDuration");
        g_fHackerOriginalFlashMaxAlpha[target] = GetEntPropFloat(target, Prop_Send, "m_flFlashMaxAlpha");
        g_bHackerRadarFlashStateSaved[target] = true;
    }

    // CSS hides the radar while flashed. The 0.5 alpha is effectively transparent,
    // while the long duration keeps the radar panel suppressed. UpdateRadar usermessages
    // are separately filtered so enemy contacts cannot leak even if HUD rendering differs.
    SetEntPropFloat(target, Prop_Send, "m_flFlashDuration", 3600.0);
    SetEntPropFloat(target, Prop_Send, "m_flFlashMaxAlpha", 0.5);
    g_bHackerRadarFlashOverrideActive[target] = true;
    return true;
}

bool QueueHackerRadarReapply(int target, float delay, int noticeOwnerUserId)
{
    if (target < 1 || target > MaxClients || !IsClientInGame(target) ||
        !IsRSPRadarDisabled(target))
    {
        return false;
    }

    if (noticeOwnerUserId != 0)
    {
        g_iHackerRadarPendingOwnerUserId[target] = noticeOwnerUserId;
    }
    if (g_hHackerRadarReapplyTimer[target] != null)
    {
        delete g_hHackerRadarReapplyTimer[target];
        g_hHackerRadarReapplyTimer[target] = null;
    }

    if (delay < 0.10)
    {
        delay = 0.10;
    }
    g_hHackerRadarReapplyTimer[target] = CreateTimer(delay,
        Timer_ReapplyHackerRadarAfterFlash, GetClientUserId(target), TIMER_FLAG_NO_MAPCHANGE);
    if (g_hHackerRadarReapplyTimer[target] == null)
    {
        g_iHackerRadarPendingOwnerUserId[target] = 0;
        return false;
    }
    return true;
}

public Action Timer_ReapplyHackerRadarAfterFlash(Handle timer, any userid)
{
    int target = GetClientOfUserId(userid);
    if (target < 1 || target > MaxClients || !IsClientInGame(target))
    {
        for (int slot = 1; slot <= MaxClients; slot++)
        {
            if (g_hHackerRadarReapplyTimer[slot] == timer)
            {
                g_hHackerRadarReapplyTimer[slot] = null;
                break;
            }
        }
        return Plugin_Stop;
    }

    if (g_hHackerRadarReapplyTimer[target] == timer)
    {
        g_hHackerRadarReapplyTimer[target] = null;
    }
    if (!IsRSPRadarDisabled(target))
    {
        g_iHackerRadarPendingOwnerUserId[target] = 0;
        return Plugin_Stop;
    }

    float remaining;
    if (GetHackerRealFlashTimeRemaining(target, remaining))
    {
        QueueHackerRadarReapply(target, remaining + 0.10,
            g_iHackerRadarPendingOwnerUserId[target]);
        return Plugin_Stop;
    }

    int noticeOwnerUserId = g_iHackerRadarPendingOwnerUserId[target];
    g_iHackerRadarPendingOwnerUserId[target] = 0;
    bool applied = ApplyHackerRadarFlashOverride(target);
    if (noticeOwnerUserId != 0)
    {
        CompleteHackerEffectNotice(target, noticeOwnerUserId, applied);
    }
    return Plugin_Stop;
}

bool ApplyHackerRadarHud(int target, bool notifyOwner)
{
    if (target < 1 || target > MaxClients || !IsClientInGame(target) || !IsRSPRadarDisabled(target))
    {
        return false;
    }

    // Spawn refreshes must not re-announce an effect already active on this target.
    if (g_bHackerRadarFlashOverrideActive[target])
    {
        return true;
    }

    int ownerUserId = g_iHackerOwnerUserId[target];
    float remaining;
    if (GetHackerRealFlashTimeRemaining(target, remaining))
    {
        return QueueHackerRadarReapply(target, remaining + 0.10,
            notifyOwner ? ownerUserId : 0);
    }

    bool applied = ApplyHackerRadarFlashOverride(target);
    if (notifyOwner && applied)
    {
        CompleteHackerEffectNotice(target, ownerUserId, true);
    }
    return applied;
}

void ClearHackerEffect(int target)
{
    if (target < 1 || target > MaxClients)
    {
        return;
    }

    if (g_hHackerRadarReapplyTimer[target] != null)
    {
        delete g_hHackerRadarReapplyTimer[target];
        g_hHackerRadarReapplyTimer[target] = null;
    }

    // Restore flash props only when our near-transparent override is still active.
    // If a real flashbang arrived, Event_PlayerBlind drops the override-active flag so
    // cleanup never cancels that legitimate flash.
    if (g_bHackerRadarFlashOverrideActive[target] && g_bHackerRadarFlashStateSaved[target] &&
        IsClientInGame(target))
    {
        if (HasEntProp(target, Prop_Send, "m_flFlashDuration"))
        {
            SetEntPropFloat(target, Prop_Send, "m_flFlashDuration", g_fHackerOriginalFlashDuration[target]);
        }
        if (HasEntProp(target, Prop_Send, "m_flFlashMaxAlpha"))
        {
            SetEntPropFloat(target, Prop_Send, "m_flFlashMaxAlpha", g_fHackerOriginalFlashMaxAlpha[target]);
        }
    }

    g_bHackerRadarFlashStateSaved[target] = false;
    g_bHackerRadarFlashOverrideActive[target] = false;
    g_fHackerOriginalFlashDuration[target] = 0.0;
    g_fHackerOriginalFlashMaxAlpha[target] = 255.0;
    g_fHackerRealFlashUntil[target] = 0.0;
    g_iHackerRadarPendingOwnerUserId[target] = 0;
    g_iHackerOwnerUserId[target] = 0;
    g_iHackerRound[target] = 0;
}


void ClearGiantEffect(int target)
{
    if (target < 1 || target > MaxClients)
    {
        return;
    }
    if (g_bGiantEffectActive[target] && IsClientInGame(target) &&
        HasEntProp(target, Prop_Send, "m_flModelScale"))
    {
        SetEntPropFloat(target, Prop_Send, "m_flModelScale", g_fGiantOldScale[target]);
    }
    g_bGiantEffectActive[target] = false;
    g_iGiantOwnerUserId[target] = 0;
    g_fGiantOldScale[target] = 1.0;
}

void ClearAllGrounderEffects()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        g_iGrounderRound[client] = 0;
        g_iGrounderOwnerUserId[client] = 0;
    }
}

void ClearOwnedRSPTargetEffects(int owner)
{
    // Used for team-change cleanup only, when changing sides invalidates target eligibility.
    // Ordinary power reassignment and source death/disconnect do not cancel completed effects;
    // normal target expiry and round cleanup own their lifecycle.
    if (owner < 1 || owner > MaxClients)
    {
        return;
    }
    int ownerUserId = IsClientInGame(owner) ? GetClientUserId(owner) : g_iCachedClientUserId[owner];
    if (ownerUserId == 0)
    {
        return;
    }

    bool changed = false;
    for (int target = 1; target <= MaxClients; target++)
    {
        if (g_iExpensiveAmmoOwnerUserId[target] == ownerUserId)
        {
            g_iExpensiveAmmoOwnerUserId[target] = 0;
            g_iExpensiveAmmoRound[target] = 0;
            g_iExpensiveAmmoPendingShots[target] = 0;
            g_iExpensiveAmmoShotTick[target] = 0;
            g_bExpensiveAmmoFrameQueued[target] = false;
            changed = true;
        }
        if (g_iHackerOwnerUserId[target] == ownerUserId)
        {
            // Also cancels Hacker's delayed radar re-apply timer and restores saved HUD state.
            ClearHackerEffect(target);
            changed = true;
        }
        if (g_iGiantOwnerUserId[target] == ownerUserId)
        {
            ClearGiantEffect(target);
            changed = true;
        }
        // Grounder persists through owner reassignment/disconnect, but target death and round-end clear it.
        if (g_iCurserOwnerUserId[target] == ownerUserId)
        {
            g_bCurserTargetCursed[target] = false;
            g_iCurserTargetCurseRound[target] = 0;
            g_iCurserOwnerUserId[target] = 0;
            g_iCurserEnemyHitCounter[target] = 0;
            g_iCurserResolvedEnemyHitCounter[target] = 0;
            changed = true;
        }
        if (g_iWeakeningOwnerUserId[target] == ownerUserId)
        {
            ClearWeakeningAmmoState(target, true);
            changed = true;
        }
        if (g_iCryoOwnerUserId[target] == ownerUserId)
        {
            g_fFrozenUntil[target] = 0.0;
            g_iCryoOwnerUserId[target] = 0;
            changed = true;
        }
        if (g_iDisorientOwnerUserId[target] == ownerUserId)
        {
            g_fDisorientViewUntil[target] = 0.0;
            g_fDisorientTargetYaw[target] = 0.0;
            g_fNextDisorientTime[target] = 0.0;
            g_iDisorientOwnerUserId[target] = 0;
            changed = true;
        }
        if (g_iReverseControlsOwnerUserId[target] == ownerUserId)
        {
            g_fReverseControlsUntil[target] = 0.0;
            g_iReverseControlsRound[target] = 0;
            g_iReverseControlsOwnerUserId[target] = 0;
            changed = true;
        }
    }
    if (changed)
    {
        QueueRefreshActiveTargetSelections();
    }
}

bool ApplyGiantEffect(int owner, int target)
{
    if (owner < 1 || owner > MaxClients || target < 1 || target > MaxClients ||
        owner == target || !IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
        !HasEntProp(target, Prop_Send, "m_flModelScale"))
    {
        return false;
    }
    ClearGiantEffect(target);
    float oldScale = GetEntPropFloat(target, Prop_Send, "m_flModelScale");
    if (oldScale <= 0.01) oldScale = 1.0;
    float multiplier = GetRandomGiantScale();
    g_bGiantEffectActive[target] = true;
    g_iGiantOwnerUserId[target] = GetClientUserId(owner);
    g_fGiantOldScale[target] = oldScale;
    SetEntPropFloat(target, Prop_Send, "m_flModelScale", multiplier);
    char successNotice[256];
    RSPClientLanguage language = GetRSPClientLanguage(owner);
    switch (language)
    {
        case RSP_LANG_PL: Format(successNotice, sizeof(successNotice), "\x04[RSP]\x01 Scientist: wybrany przeciwnik został powiększony do x%.2f (zakres: x1,10–x1,40)", multiplier);
        default: Format(successNotice, sizeof(successNotice), "\x04[RSP]\x01 Scientist: the selected enemy was enlarged to x%.2f (range: x1.10–x1.40)", multiplier);
    }
    if (language != RSP_LANG_EN)
    {
        ReplaceString(successNotice, sizeof(successNotice), ".", ",", false);
    }
    StrCat(successNotice, sizeof(successNotice), ".");
    PrintToChat(owner, "%s", successNotice);
    PrintRSPTargetEffectNotice(target, owner, RSP_NOTICE_SCIENTIST, multiplier);
    return true;
}

void QueueRSPTargetSelection(int client, int selectionType)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client) ||
        !IsRSPTargetSelectionType(selectionType))
    {
        return;
    }

    // Coalesce spawn/team/death/assignment events and build against the settled roster.
    StopRSPTargetSelectionBuildTimer(client);
    g_iTargetSelectionType[client] = selectionType;
    g_bTargetSelectionPending[client] = true;
    g_iTargetSelectionRound[client] = g_iRoundSerial;
    Handle buildTimer = CreateTimer(RSP_TARGET_SELECTION_BUILD_DELAY,
        Timer_BeginQueuedRSPTargetSelection, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    if (buildTimer == null)
    {
        // Do not leave a target-selection power silently pending if timer allocation
        // fails. Build the list immediately as a safe fallback.
        g_bTargetSelectionPending[client] = false;
        g_hTargetSelectionBuildTimer[client] = null;
        BeginRSPTargetSelection(client, selectionType);
        return;
    }
    g_hTargetSelectionBuildTimer[client] = buildTimer;
}

public Action Timer_BeginQueuedRSPTargetSelection(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        for (int slot = 1; slot <= MaxClients; slot++)
        {
            if (g_hTargetSelectionBuildTimer[slot] == timer)
            {
                g_hTargetSelectionBuildTimer[slot] = null;
                break;
            }
        }
        return Plugin_Stop;
    }

    if (g_hTargetSelectionBuildTimer[client] != timer)
    {
        return Plugin_Stop;
    }
    g_hTargetSelectionBuildTimer[client] = null;

    if (!g_bTargetSelectionPending[client])
    {
        return Plugin_Stop;
    }

    int selectionType = g_iTargetSelectionType[client];
    g_bTargetSelectionPending[client] = false;
    if (g_iTargetSelectionRound[client] != g_iRoundSerial ||
        !DoesClientOwnTargetPower(client, selectionType) ||
        !IsValidPlayingClient(client) || !IsPlayerAlive(client))
    {
        ClearRSPTargetSelection(client);
        return Plugin_Stop;
    }

    BeginRSPTargetSelection(client, selectionType);
    return Plugin_Stop;
}

void QueueRefreshActiveTargetSelections()
{
    if (!g_bEnabled || !g_bSupportedMap || !g_bRoundReady || g_iRoundSerial <= 0)
    {
        return;
    }

    for (int owner = 1; owner <= MaxClients; owner++)
    {
        if (!IsValidPlayingClient(owner) || !IsPlayerAlive(owner) || IsFakeClient(owner) ||
            g_iAssignedRound[owner] != g_iRoundSerial)
        {
            continue;
        }

        int selectionType = GetTargetSelectionTypeForPower(g_iPower[owner]);
        if (selectionType != RSP_TARGET_SELECT_NONE &&
            (g_iTargetSelectionType[owner] == selectionType || g_bTargetSelectionPending[owner]))
        {
            QueueRSPTargetSelection(owner, selectionType);
        }
    }
}

bool HasRSPAccountProperty(int target)
{
    if (target < 1 || target > MaxClients || !IsClientInGame(target))
    {
        return false;
    }
    return HasEntProp(target, Prop_Send, "m_iAccount") ||
        HasEntProp(target, Prop_Data, "m_iAccount");
}

bool SetRSPAccount(int target, int amount)
{
    if (target < 1 || target > MaxClients || !IsClientInGame(target))
    {
        return false;
    }
    if (HasEntProp(target, Prop_Send, "m_iAccount"))
    {
        SetEntProp(target, Prop_Send, "m_iAccount", amount);
        return true;
    }
    if (HasEntProp(target, Prop_Data, "m_iAccount"))
    {
        SetEntProp(target, Prop_Data, "m_iAccount", amount);
        return true;
    }
    return false;
}

void BeginRSPTargetSelection(int client, int selectionType)
{
    if (client < 1 || client > MaxClients || !IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        !IsRSPTargetSelectionType(selectionType))
    {
        if (client >= 1 && client <= MaxClients) ClearRSPTargetSelection(client);
        return;
    }

    if (!DoesClientOwnTargetPower(client, selectionType))
    {
        ClearRSPTargetSelection(client);
        return;
    }

    int previousCount = g_iTargetSelectionCount[client];
    if (previousCount < 0 || previousCount > MAXPLAYERS)
    {
        previousCount = 0;
    }
    int previousUserIds[MAXPLAYERS + 1];
    RSPPower previousTargetPowers[MAXPLAYERS + 1];
    int previousTargetTeams[MAXPLAYERS + 1];
    for (int i = 0; i < previousCount; i++)
    {
        previousUserIds[i] = g_iTargetSelectionUserIds[client][i];
        previousTargetPowers[i] = g_eTargetSelectionPowerSnapshot[client][i];
        previousTargetTeams[i] = g_iTargetSelectionTeamSnapshot[client][i];
    }
    bool hadPreviousSnapshot = g_bTargetSelectionInitialized[client] &&
        g_iTargetSelectionType[client] == selectionType &&
        g_iTargetSelectionRound[client] == g_iRoundSerial;
    bool forceDisplay = g_bTargetSelectionForceDisplay[client];

    int candidateUserIds[MAXPLAYERS + 1];
    int candidateCount = 0;
    int ownTeam = GetClientTeam(client);
    for (int target = 1; target <= MaxClients; target++)
    {
        if (target == client || !IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
            GetClientTeam(target) == ownTeam)
        {
            continue;
        }
        // Real Ghost/ReZombie players remain valid Blackout targets. Exclude bots because
        // they cannot meaningfully receive a client-side screen fade.
        if (selectionType == RSP_TARGET_SELECT_BLACKOUT && IsFakeClient(target))
        {
            continue;
        }
        if (selectionType == RSP_TARGET_SELECT_BLACKOUT &&
            (g_bBlackoutActive[target] && g_iBlackoutRound[target] == g_iRoundSerial))
        {
            continue;
        }

        if (selectionType == RSP_TARGET_SELECT_THIEF &&
            (g_iAssignedRound[target] != g_iRoundSerial || g_iPower[target] == RSP_None ||
             !IsRSPPowerSelectable(g_iPower[target])))
        {
            continue;
        }
        if (selectionType == RSP_TARGET_SELECT_CURSER && g_bCurserTargetCursed[target] &&
            g_iCurserTargetCurseRound[target] == g_iRoundSerial)
        {
            continue;
        }
        if ((selectionType == RSP_TARGET_SELECT_THIEF || selectionType == RSP_TARGET_SELECT_DUPLICATOR) &&
            !IsRSPPowerCopyableByTargetSelection(g_iPower[target]))
        {
            continue;
        }
        if (selectionType == RSP_TARGET_SELECT_BANKRUPT && !HasRSPAccountProperty(target))
        {
            continue;
        }

        if (candidateCount < MAXPLAYERS + 1)
        {
            candidateUserIds[candidateCount++] = GetClientUserId(target);
        }
    }

    bool rosterChanged = !hadPreviousSnapshot || candidateCount != previousCount;
    if (!rosterChanged)
    {
        for (int i = 0; i < candidateCount; i++)
        {
            if (candidateUserIds[i] != previousUserIds[i])
            {
                rosterChanged = true;
                break;
            }

            int currentTarget = GetClientOfUserId(candidateUserIds[i]);
            if (currentTarget < 1 || currentTarget > MaxClients || !IsClientInGame(currentTarget))
            {
                rosterChanged = true;
                break;
            }
            if (GetClientTeam(currentTarget) != previousTargetTeams[i])
            {
                rosterChanged = true;
                break;
            }
            if ((selectionType == RSP_TARGET_SELECT_THIEF || selectionType == RSP_TARGET_SELECT_DUPLICATOR) &&
                g_iPower[currentTarget] != previousTargetPowers[i])
            {
                rosterChanged = true;
                break;
            }
        }
    }

    g_bTargetSelectionPending[client] = false;
    g_bTargetSelectionForceDisplay[client] = false;
    g_iTargetSelectionType[client] = selectionType;
    g_iTargetSelectionRound[client] = g_iRoundSerial;
    g_iTargetSelectionCount[client] = candidateCount;
    g_bTargetSelectionInitialized[client] = true;
    for (int i = 0; i <= MAXPLAYERS; i++)
    {
        g_iTargetSelectionUserIds[client][i] = (i < candidateCount) ? candidateUserIds[i] : 0;
        if (i < candidateCount)
        {
            int snapshotTarget = GetClientOfUserId(candidateUserIds[i]);
            if (snapshotTarget >= 1 && snapshotTarget <= MaxClients && IsClientInGame(snapshotTarget))
            {
                g_eTargetSelectionPowerSnapshot[client][i] = g_iPower[snapshotTarget];
                g_iTargetSelectionTeamSnapshot[client][i] = GetClientTeam(snapshotTarget);
            }
            else
            {
                g_eTargetSelectionPowerSnapshot[client][i] = RSP_None;
                g_iTargetSelectionTeamSnapshot[client][i] = 0;
            }
        }
        else
        {
            g_eTargetSelectionPowerSnapshot[client][i] = RSP_None;
            g_iTargetSelectionTeamSnapshot[client][i] = 0;
        }
    }

    bool polish = IsPolishClient(client);
    if (candidateCount <= 0)
    {
        if (rosterChanged || forceDisplay)
        {
            PrintToChat(client, polish
                ? "\x04[RSP]\x01 Brak dostępnych przeciwników do wyboru."
                : "\x04[RSP]\x01 No eligible enemies are available.");
        }
        // Keep this selection active with an empty list so spawn/team/assignment events can repopulate it.
        return;
    }

    if (!rosterChanged && !forceDisplay)
    {
        return;
    }

    for (int i = 0; i < candidateCount; i++)
    {
        int target = GetClientOfUserId(candidateUserIds[i]);
        if (target < 1 || target > MaxClients || !IsClientInGame(target) || !IsValidPlayingClient(target) || !IsPlayerAlive(target))
        {
            continue;
        }

        char shortName[96];
        char suffix[48];
        FormatShortTargetName(target, shortName, sizeof(shortName));
        suffix[0] = '\0';
        if (selectionType == RSP_TARGET_SELECT_THIEF || selectionType == RSP_TARGET_SELECT_DUPLICATOR)
        {
            GetPowerRosterValue(target, GetRSPClientLanguage(client), suffix, sizeof(suffix));
            int powerIndex = view_as<int>(g_iPower[target]);
            if (powerIndex > view_as<int>(RSP_None) && powerIndex < view_as<int>(RSP_PowerCount))
            {
                PrintToChat(client, GetClientTeam(target) == CS_TEAM_CT
                    ? "\x01/%d - \x0799CCFF%s\x01 - \x04%s\x01%s"
                    : "\x01/%d - \x07FF4040%s\x01 - \x04%s\x01%s",
                    i + 1, shortName, g_sPowerNamesEn[powerIndex], suffix);
            }
        }
        else
        {
            PrintToChat(client, GetClientTeam(target) == CS_TEAM_CT
                ? "\x01/%d - \x0799CCFF%s"
                : "\x01/%d - \x07FF4040%s",
                i + 1, shortName);
        }
    }
}

void PrintFreezeGateFeedback(int client, bool polish)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    // Explain blocked manual activations through normal in-game chat only.
    PrintToChat(client, polish
        ? "\x04[RSP]\x01 Możesz użyć tej supermocy dopiero po zakończeniu czasu zamrożenia."
        : "\x04[RSP]\x01 You can use this power only after freeze time ends.");
}

Action HandleRSPTargetSelectionChat(int client, int selectionNumber)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    int selectionType = g_iTargetSelectionType[client];
    bool polish = IsPolishClient(client);
    if (selectionType == RSP_TARGET_SELECT_NONE)
    {
        return Plugin_Continue;
    }

    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
        !IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iAssignedRound[client] != g_iRoundSerial || g_iTargetSelectionRound[client] != g_iRoundSerial ||
        !DoesClientOwnTargetPower(client, selectionType))
    {
        ClearRSPTargetSelection(client);
        return Plugin_Handled;
    }

    // Target selections (/1, /2, etc.) are deliberate freezetime exceptions.
    // Manual movement/teleport skills still retain their ordinary freeze-time gate.
    if (selectionNumber < 1 || selectionNumber > g_iTargetSelectionCount[client])
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Numer nie pasuje do aktualnej listy. Odświeżam listę przeciwników."
            : "\x04[RSP]\x01 That number is not on the current list. Refreshing the enemy list.");
        g_bTargetSelectionInitialized[client] = false;
        QueueRSPTargetSelection(client, selectionType);
        return Plugin_Handled;
    }

    int target = GetClientOfUserId(g_iTargetSelectionUserIds[client][selectionNumber - 1]);
    bool targetValid = target >= 1 && target <= MaxClients && IsValidPlayingClient(target) &&
        IsPlayerAlive(target) && GetClientTeam(target) != GetClientTeam(client);
    if (targetValid && selectionType == RSP_TARGET_SELECT_THIEF)
    {
        targetValid = g_iAssignedRound[target] == g_iRoundSerial && IsRSPPowerCopyableByTargetSelection(g_iPower[target]);
    }
    if (targetValid && selectionType == RSP_TARGET_SELECT_DUPLICATOR)
    {
        targetValid = g_iAssignedRound[target] == g_iRoundSerial && IsRSPPowerCopyableByTargetSelection(g_iPower[target]);
    }
    if (targetValid && selectionType == RSP_TARGET_SELECT_BANKRUPT)
    {
        targetValid = HasRSPAccountProperty(target);
    }
    if (targetValid && selectionType == RSP_TARGET_SELECT_CURSER)
    {
        targetValid = !(g_bCurserTargetCursed[target] && g_iCurserTargetCurseRound[target] == g_iRoundSerial);
    }
    if (targetValid && selectionType == RSP_TARGET_SELECT_BLACKOUT)
    {
        // Ghost/ReZombie powers do not protect a player from Blackout; bots are excluded
        // because they have no meaningful client screen to fade.
        targetValid = !IsFakeClient(target) &&
            !(g_bBlackoutActive[target] && g_iBlackoutRound[target] == g_iRoundSerial);
    }
    if (!targetValid)
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Cel jest już niedostępny. Odświeżam listę przeciwników."
            : "\x04[RSP]\x01 That target is no longer available. Refreshing the enemy list.");
        g_bTargetSelectionInitialized[client] = false;
        QueueRSPTargetSelection(client, selectionType);
        return Plugin_Handled;
    }

    if (selectionType == RSP_TARGET_SELECT_BLACKOUT)
    {
        if (!ApplyBlackoutEffect(client, target))
        {
            ClearRSPTargetSelection(client);
            switch (GetRSPClientLanguage(client))
            {
                case RSP_LANG_PL: PrintToChat(client, "\x04[RSP]\x01 Nie udało się nałożyć Blackout na wybranego przeciwnika.");
                default: PrintToChat(client, "\x04[RSP]\x01 Could not apply Blackout to the selected enemy.");
            }
            QueueRSPTargetSelection(client, RSP_TARGET_SELECT_BLACKOUT);
        }
        else
        {
            g_bBlackoutUsedThisAssignment[client] = true;
            ClearRSPTargetSelection(client);
            switch (GetRSPClientLanguage(client))
            {
                case RSP_LANG_PL: PrintToChat(client, "\x04[RSP]\x01 Blackout aktywowany na wybranym przeciwniku.");
                default: PrintToChat(client, "\x04[RSP]\x01 Blackout applied to the selected enemy.");
            }
        }
        return Plugin_Handled;
    }

    if (selectionType == RSP_TARGET_SELECT_GROUNDER)
    {
        g_iGrounderRound[target] = g_iRoundSerial;
        g_iGrounderOwnerUserId[target] = GetClientUserId(client);
        g_bGrounderUsedThisAssignment[client] = true;
        ClearRSPTargetSelection(client);
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Zablokowałeś skakanie wybranemu przeciwnikowi do jego śmierci lub końca rundy."
            : "\x04[RSP]\x01 You disabled the selected enemy's jump until they die or the round ends.");
        PrintRSPTargetEffectNotice(target, client, RSP_NOTICE_GROUNDER);
        return Plugin_Handled;
    }

    if (selectionType == RSP_TARGET_SELECT_BANKRUPT)
    {
        if (!SetRSPAccount(target, RSP_BANKRUPT_NONE))
        {
            PrintToChat(client, polish
                ? "\x04[RSP]\x01 Nie można zmienić gotówki wybranego gracza. Lista zostanie odświeżona."
                : "\x04[RSP]\x01 The selected player's cash cannot be changed. The list will refresh.");
            QueueRSPTargetSelection(client, selectionType);
            return Plugin_Handled;
        }
        ClearRSPTargetSelection(client);
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Zbankrutowałeś wybranego przeciwnika."
            : "\x04[RSP]\x01 The selected enemy has been bankrupted.");
        PrintRSPTargetEffectNotice(target, client, RSP_NOTICE_BANKRUPT);
        return Plugin_Handled;
    }

    if (selectionType == RSP_TARGET_SELECT_EXTORTION)
    {
        g_iExpensiveAmmoOwnerUserId[target] = GetClientUserId(client);
        g_iExpensiveAmmoRound[target] = g_iRoundSerial;
        ClearRSPTargetSelection(client);
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Wybrany przeciwnik będzie płacić $50 za strzał."
            : "\x04[RSP]\x01 The selected enemy will pay $50 per firearm shot.");
        PrintRSPTargetEffectNotice(target, client, RSP_NOTICE_EXTORTION);
        return Plugin_Handled;
    }

    if (selectionType == RSP_TARGET_SELECT_HACKER)
    {
        ClearHackerEffect(target);
        g_iHackerOwnerUserId[target] = GetClientUserId(client);
        g_iHackerRound[target] = g_iRoundSerial;
        bool radarNoticeQueued = ApplyHackerRadarHud(target, true);
        ClearRSPTargetSelection(client);
        if (!radarNoticeQueued)
        {
            CompleteHackerEffectNotice(target, GetClientUserId(client), false);
        }
        return Plugin_Handled;
    }

    if (selectionType == RSP_TARGET_SELECT_SCIENTIST)
    {
        ClearRSPTargetSelection(client);
        if (!ApplyGiantEffect(client, target))
        {
            PrintToChat(client, polish
                ? "\x04[RSP]\x01 Nie można zmienić skali modelu tego gracza."
                : "\x04[RSP]\x01 This player's model scale cannot be changed.");
        }
        return Plugin_Handled;
    }


    if (selectionType == RSP_TARGET_SELECT_DUPLICATOR)
    {
        RSPPower copiedPower = g_iPower[target];
        int sourceUserId = GetClientUserId(target);
        ClearRSPTargetSelection(client);
        g_bThiefApplyingStolenPower[client] = true;
        g_iThiefSourceUserId[client] = sourceUserId;
        g_eThiefSourcePower[client] = copiedPower;
        // Give the copied parameters from the source but use one Duplicator-specific
        // success message with the same dynamic description shown for this power.
        AssignPowerToClient(client, copiedPower, false, false, true);
        int duplicatedTarget = GetClientOfUserId(sourceUserId);
        if (duplicatedTarget >= 1 && duplicatedTarget <= MaxClients && IsValidPlayingClient(duplicatedTarget))
        {
            PrintRSPTargetEffectNotice(duplicatedTarget, client, RSP_NOTICE_DUPLICATOR);
        }
        g_bThiefApplyingStolenPower[client] = false;
        g_iThiefSourceUserId[client] = 0;
        g_eThiefSourcePower[client] = RSP_None;
        return Plugin_Handled;
    }

    if (selectionType == RSP_TARGET_SELECT_CURSER)
    {
        g_bCurserTargetCursed[target] = true;
        g_iCurserTargetCurseRound[target] = g_iRoundSerial;
        g_iCurserOwnerUserId[target] = GetClientUserId(client);
        ClearRSPTargetSelection(client);
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Przekląłeś wybranego przeciwnika."
            : "\x04[RSP]\x01 You cursed the selected enemy.");
        PrintRSPTargetEffectNotice(target, client, RSP_NOTICE_CURSER);
        QueueRefreshActiveTargetSelections();
        return Plugin_Handled;
    }

    if (selectionType == RSP_TARGET_SELECT_THIEF)
    {
        RSPPower stolenPower = g_iPower[target];
        // Keep the source powered while the thief's ApplyPower copies its rolled parameters.
        int targetUserId = GetClientUserId(target);
        g_bThiefApplyingStolenPower[client] = true;
        g_iThiefSourceUserId[client] = targetUserId;
        g_eThiefSourcePower[client] = stolenPower;
        ClearRSPTargetSelection(client);
        AssignPowerToClient(client, stolenPower);

        // Only after ApplyPower has copied the source's rolled parameters do we remove the original power.
        target = GetClientOfUserId(targetUserId);
        if (target >= 1 && target <= MaxClients && IsValidPlayingClient(target) && IsPlayerAlive(target) && target != client)
        {
            PrintRSPTargetEffectNotice(target, client, RSP_NOTICE_THIEF);
            ResetClientPower(target, true);
            g_iAssignedRound[target] = g_iRoundSerial;
            if (stolenPower == RSP_Ghost)
            {
                // Ghost removes all firearms and blocks weapon pickups. Once stolen,
                // the former Ghost is unrestricted again and immediately gets their
                // team's default pistol (USP for CT, Glock for T).
                RestorePistolAfterGhostTheft(target);
            }
        }

        g_bThiefApplyingStolenPower[client] = false;
        g_iThiefSourceUserId[client] = 0;
        g_eThiefSourcePower[client] = RSP_None;

        // Target-selection powers are only ready to select a new target after the source loses its power.
        if (g_iPower[client] == RSP_Thief)
        {
            BeginRSPTargetSelection(client, RSP_TARGET_SELECT_THIEF);
        }
        else if (g_iPower[client] == RSP_Curser)
        {
            BeginRSPTargetSelection(client, RSP_TARGET_SELECT_CURSER);
        }
        QueueWallhackRefresh();
        QueueRefreshActiveTargetSelections();
        return Plugin_Handled;
    }

    ClearRSPTargetSelection(client);
    return Plugin_Handled;
}


void RestorePistolAfterGhostTheft(int client, bool equipPistol = true)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))
    {
        return;
    }

    int team = GetClientTeam(client);
    if (team != CS_TEAM_CT && team != CS_TEAM_T)
    {
        return;
    }

    int existingPistol = GetPlayerWeaponSlot(client, 1);
    if (existingPistol > MaxClients && IsValidEntity(existingPistol))
    {
        g_bGhostNeedsDefaultPistol[client] = false;
        StopClientPistolRestoreTimer(client);
        return;
    }

    char pistolClass[32];
    strcopy(pistolClass, sizeof(pistolClass), team == CS_TEAM_CT ? "weapon_usp" : "weapon_glock");
    int pistol = GivePlayerItem(client, pistolClass);
    if (pistol > MaxClients && IsValidEntity(pistol))
    {
        g_bGhostNeedsDefaultPistol[client] = false;
        StopClientPistolRestoreTimer(client);
        if (equipPistol)
        {
            EquipPlayerWeapon(client, pistol);
        }
        return;
    }

    // Do not spin/retry in the same frame; use the existing bounded restore path.
    g_bGhostNeedsDefaultPistol[client] = true;
    QueueDefaultPistolRestore(client);
}

int GetThiefSourceForPower(int client, RSPPower power)
{
    if (client < 1 || client > MaxClients || !g_bThiefApplyingStolenPower[client] ||
        g_eThiefSourcePower[client] != power || g_iThiefSourceUserId[client] == 0)
    {
        return 0;
    }
    int source = GetClientOfUserId(g_iThiefSourceUserId[client]);
    // Copy effects are read synchronously before a dead Chameleon target is reset.
    // The source must still occupy a valid in-game player slot in this round, but need not be alive.
    if (source < 1 || source > MaxClients || !IsValidPlayingClient(source) ||
        g_iAssignedRound[source] != g_iRoundSerial || g_iPower[source] != power)
    {
        return 0;
    }
    return source;
}

void ApplyPower(int client, RSPPower power)
{
    switch (power)
    {
        case RSP_Gambler:
        {
            int source = GetThiefSourceForPower(client, RSP_Gambler);
            if (source > 0)
            {
                // Avenger inherits the dead Gambler's existing three offers and their
                // pre-rolled values instead of silently receiving a different set.
                for (int offer = 0; offer < RSP_GAMBLER_OPTIONS; offer++)
                {
                    g_eGamblerOffers[client][offer] = g_eGamblerOffers[source][offer];
                    g_iGamblerRamboBonus[client][offer] = g_iGamblerRamboBonus[source][offer];
                    g_iGamblerRichBoyBonus[client][offer] = g_iGamblerRichBoyBonus[source][offer];
                    g_fGamblerLowGravity[client][offer] = g_fGamblerLowGravity[source][offer];
                    g_fGamblerSpeedBonus[client][offer] = g_fGamblerSpeedBonus[source][offer];
                    g_iGamblerDisarmChance[client][offer] = g_iGamblerDisarmChance[source][offer];
                    g_iGamblerLeechChance[client][offer] = g_iGamblerLeechChance[source][offer];
                    g_fGamblerModelScale[client][offer] = g_fGamblerModelScale[source][offer];
                    g_fGamblerArmouredReduction[client][offer] = g_fGamblerArmouredReduction[source][offer];
                    g_fGamblerRapidFireMultiplier[client][offer] = g_fGamblerRapidFireMultiplier[source][offer];
                    g_iGamblerCryoChance[client][offer] = g_iGamblerCryoChance[source][offer];
                    g_iGamblerDisorientChance[client][offer] = g_iGamblerDisorientChance[source][offer];
                    g_iGamblerKnockupChance[client][offer] = g_iGamblerKnockupChance[source][offer];
                }
                g_bGamblerPendingSelection[client] = true;
                g_bGamblerChatIntercept[client] = true;
                g_bGamblerApplyingChoice[client] = false;
                g_iGamblerSelectedOfferIndex[client] = -1;
            }
            else
            {
                BuildGamblerOffers(client);
            }
        }
        case RSP_Curser:
        {
            // The selected enemy is cursed through the silent /number chat selection.
        }
        case RSP_Thief:
        {
            // The selected enemy's power is transferred through the private /number chat selection.
        }
        case RSP_Soldier:
        {
            int thiefSource = GetThiefSourceForPower(client, RSP_Soldier);
            g_fSoldierDamageMultiplier[client] = thiefSource > 0
                ? g_fSoldierDamageMultiplier[thiefSource]
                : GetRandomFloat(1.15, 1.30);
        }
        case RSP_Wallhack:
        {
            QueueWallhackRefresh();
            StartWallhackTimer();
        }
        case RSP_Rambo:
        {
            g_iOldRamboHealth[client] = GetClientHealth(client);
            int offerIndex = g_iGamblerSelectedOfferIndex[client];
            int thiefSource = GetThiefSourceForPower(client, RSP_Rambo);
            int bonus = thiefSource > 0 ? g_iRamboRolledBonus[thiefSource]
                : ((g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                    ? g_iGamblerRamboBonus[client][offerIndex]
                    : GetRandomInt(RSP_RAMBO_BONUS_MIN, RSP_RAMBO_BONUS_MAX));
            g_iRamboRolledBonus[client] = bonus;
            int health = g_iOldRamboHealth[client] + bonus;
            SetEntityHealth(client, health);
        }
        case RSP_Astronaut:
        {
            SaveGravityState(client);
            int offerIndex = g_iGamblerSelectedOfferIndex[client];
            int thiefSource = GetThiefSourceForPower(client, RSP_Astronaut);
            g_fLowGravityMultiplier[client] = thiefSource > 0 ? g_fLowGravityMultiplier[thiefSource]
                : ((g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                    ? g_fGamblerLowGravity[client][offerIndex]
                    : GetRandomFloat(RSP_ASTRONAUT_GRAVITY_MIN, RSP_ASTRONAUT_GRAVITY_MAX));
            if (g_bOldGravityValid[client])
            {
                SetEntityGravity(client, g_fLowGravityMultiplier[client]);
            }
        }
        case RSP_SpeedDemon:
        {
            SaveMoveSpeedState(client);
            int offerIndex = g_iGamblerSelectedOfferIndex[client];
            int thiefSource = GetThiefSourceForPower(client, RSP_SpeedDemon);
            g_fSpeedBonus[client] = thiefSource > 0 ? g_fSpeedBonus[thiefSource]
                : ((g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                    ? g_fGamblerSpeedBonus[client][offerIndex]
                    : GetRandomFloat(RSP_SPEED_DEMON_MIN, RSP_SPEED_DEMON_MAX));
            if (g_bOldMoveSpeedValid[client])
            {
                SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue",
                    g_fOldMoveSpeed[client] * g_fSpeedBonus[client]);
            }
        }
        case RSP_DeadlyFlash:
        {
            // Persist ownership until round cleanup so a grenade released/dropped during death
            // remains linked to the power after ResetClientPower clears g_iPower.
            g_bHadDeadlyFlashThisRound[client] = true;
        }
        case RSP_Ghost:
        {
            TrackGhostInventoryWeapons(client);
            StripGhostFirearms(client);
            FakeClientCommand(client, "use weapon_knife");
            StartGhostMaintenanceTimer();
            QueueWallhackRefresh();
        }
        case RSP_Armoured:
        {
            int offerIndex = g_iGamblerSelectedOfferIndex[client];
            int thiefSource = GetThiefSourceForPower(client, RSP_Armoured);
            g_fArmouredDamageReduction[client] = thiefSource > 0
                ? g_fArmouredDamageReduction[thiefSource]
                : ((g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                    ? g_fGamblerArmouredReduction[client][offerIndex]
                    : GetRandomFloat(RSP_ARMOURED_REDUCTION_MIN, RSP_ARMOURED_REDUCTION_MAX));
        }
        case RSP_Regeneration:
        {
            StopClientRegenTimer(client);
            g_hRegenTimer[client] = CreateTimer(RSP_REGENERATION_INTERVAL, Timer_Regeneration,
                GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        }
        case RSP_HealingAngel:
        {
            g_iHealingAngelOldMaxHealth[client] = GetRSPClientMaxHealth(client);
            if (g_iHealingAngelOldMaxHealth[client] <= 0) g_iHealingAngelOldMaxHealth[client] = 100;
            g_bHealingAngelMaxHealthStateSaved[client] = true;
            SetRSPClientMaxHealth(client, RSP_HEALING_ANGEL_MAX_HEALTH);
            SetEntityHealth(client, RSP_HEALING_ANGEL_MAX_HEALTH);
            g_fHealingAngelNextUseTime[client] = 0.0;
            StopClientRegenTimer(client);
            g_hRegenTimer[client] = CreateTimer(RSP_REGENERATION_INTERVAL, Timer_Regeneration,
                GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        }
        case RSP_Blackout:
        {
            // Blackout uses assignment-time target selection.
        }
        case RSP_Disarmament:
        {
            int offerIndex = g_iGamblerSelectedOfferIndex[client];
            int thiefSource = GetThiefSourceForPower(client, RSP_Disarmament);
            g_iDisarmChancePercent[client] = thiefSource > 0 ? g_iDisarmChancePercent[thiefSource]
                : ((g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                    ? g_iGamblerDisarmChance[client][offerIndex]
                    : RollDisarmChancePercent());
        }
        case RSP_Thorns:
        {
            g_fThornsReflectRemainder[client] = 0.0;
        }
        case RSP_ExplosiveAmmo:
        {
            int source = GetThiefSourceForPower(client, RSP_ExplosiveAmmo);
            g_iExplosiveBulletsChancePercent[client] = source > 0
                ? g_iExplosiveBulletsChancePercent[source]
                : GetRandomInt(RSP_EXPLOSIVE_AMMO_CHANCE_MIN, RSP_EXPLOSIVE_AMMO_CHANCE_MAX);
        }
        case RSP_Knockup:
        {
            int offerIndex = g_iGamblerSelectedOfferIndex[client];
            int source = GetThiefSourceForPower(client, RSP_Knockup);
            g_iKnockupChancePercent[client] = source > 0
                ? g_iKnockupChancePercent[source]
                : ((g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                    ? g_iGamblerKnockupChance[client][offerIndex]
                    : GetRandomInt(RSP_KNOCKUP_CHANCE_MIN, RSP_KNOCKUP_CHANCE_MAX));
        }
        case RSP_Berserker:
        {
            SaveMoveSpeedState(client);
        }
        case RSP_Sapper:
        {
            int source = GetThiefSourceForPower(client, RSP_Sapper);
            g_iSapperSpeedPercent[client] = source > 0
                ? g_iSapperSpeedPercent[source]
                : GetRandomInt(RSP_SAPPER_SPEED_MIN, RSP_SAPPER_SPEED_MAX);
        }
        case RSP_Medic:
        {
            g_iMedicCharges[client] = RSP_MEDIC_CHARGES;
        }
        case RSP_FeatherFalling, RSP_Lootbox, RSP_Avenger, RSP_Crippler:
        {
            // Passive powers are handled by damage and death hooks.
        }
        case RSP_Leech:
        {
            int source = GetThiefSourceForPower(client, RSP_Leech);
            int offerIndex = g_iGamblerSelectedOfferIndex[client];
            g_iLeechChancePercent[client] = source > 0
                ? g_iLeechChancePercent[source]
                : ((g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                    ? g_iGamblerLeechChance[client][offerIndex]
                    : GetRandomInt(RSP_LEECH_CHANCE_MIN, RSP_LEECH_CHANCE_MAX));
        }
        case RSP_WeaponSwap, RSP_Miner, RSP_Entropy:
        {
            // Activated powers use the shared bind dispatcher.
        }
        case RSP_Grounder:
        {
            // Grounder is resolved through the assignment-time /1, /2 target list.
        }
        case RSP_RichBoy:
        {
            int currentMoney = 0;
            if (HasEntProp(client, Prop_Send, "m_iAccount"))
            {
                currentMoney = GetEntProp(client, Prop_Send, "m_iAccount");
            }
            int offerIndex = g_iGamblerSelectedOfferIndex[client];
            int thiefSource = GetThiefSourceForPower(client, RSP_RichBoy);
            int bonus = thiefSource > 0 ? g_iRichBoyRolledBonus[thiefSource]
                : ((g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                    ? g_iGamblerRichBoyBonus[client][offerIndex]
                    : GetRandomInt(RSP_RICH_BOY_MIN / RSP_RICH_BOY_STEP,
                        RSP_RICH_BOY_MAX / RSP_RICH_BOY_STEP) * RSP_RICH_BOY_STEP);
            // The account must respect mp_maxmoney, but chat reports the full rolled bonus.
            int moneyLimit = 16000;
            ConVar maxMoneyCvar = FindConVar("mp_maxmoney");
            if (maxMoneyCvar != null && maxMoneyCvar.IntValue > 0 && maxMoneyCvar.IntValue < moneyLimit)
            {
                moneyLimit = maxMoneyCvar.IntValue;
            }

            int newMoney = currentMoney + bonus;
            if (newMoney > moneyLimit)
            {
                newMoney = moneyLimit;
            }
            if (newMoney < 0)
            {
                newMoney = 0;
            }

            g_iRichBoyRolledBonus[client] = bonus;
            if (HasEntProp(client, Prop_Send, "m_iAccount"))
            {
                SetEntProp(client, Prop_Send, "m_iAccount", newMoney);
            }
        }
        case RSP_Dwarf, RSP_Giant:
        {
            bool isGiant = (power == RSP_Giant);
            g_bModelScaleStateSaved[client] = true;
            g_bOldModelScaleValid[client] = HasEntProp(client, Prop_Send, "m_flModelScale");
            g_bOldViewOffsetValid[client] = HasEntProp(client, Prop_Data, "m_vecViewOffset");
            g_bOldCollisionBoundsValid[client] = HasEntProp(client, Prop_Send, "m_vecMins") &&
                HasEntProp(client, Prop_Send, "m_vecMaxs");
            g_bOldViewOffsetWasDucked[client] = HasEntProp(client, Prop_Send, "m_bDucked") &&
                GetEntProp(client, Prop_Send, "m_bDucked") != 0;

            if (g_bOldViewOffsetValid[client])
            {
                GetEntPropVector(client, Prop_Data, "m_vecViewOffset", g_fOldViewOffset[client]);
            }
            if (g_bOldCollisionBoundsValid[client])
            {
                GetEntPropVector(client, Prop_Send, "m_vecMins", g_fOldCollisionMins[client]);
                GetEntPropVector(client, Prop_Send, "m_vecMaxs", g_fOldCollisionMaxs[client]);
            }

            if (g_bOldModelScaleValid[client])
            {
                g_fOldModelScale[client] = GetEntPropFloat(client, Prop_Send, "m_flModelScale");
                if (g_fOldModelScale[client] < 0.01) g_fOldModelScale[client] = 1.0;
                int offerIndex = g_iGamblerSelectedOfferIndex[client];
                int thiefSource = GetThiefSourceForPower(client, power);
                float minScale = isGiant ? RSP_GIANT_SCALE_MIN : RSP_DWARF_SCALE_MIN;
                float maxScale = isGiant ? RSP_GIANT_SCALE_MAX : RSP_DWARF_SCALE_MAX;
                float scale;
                if (thiefSource > 0)
                {
                    scale = isGiant ? g_fGiantSelfScale[thiefSource]
                        : GetEntPropFloat(thiefSource, Prop_Send, "m_flModelScale");
                }
                else if (g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                {
                    scale = g_fGamblerModelScale[client][offerIndex];
                }
                else
                {
                    scale = isGiant ? GetRandomGiantScale() : GetRandomFloat(minScale, maxScale);
                }
                if (scale < minScale || scale > maxScale)
                {
                    scale = isGiant ? GetRandomGiantScale() : GetRandomFloat(minScale, maxScale);
                }

                g_fSelfModelScaleRatio[client] = scale / g_fOldModelScale[client];
                SetEntPropFloat(client, Prop_Send, "m_flModelScale", scale);
                if (isGiant)
                {
                    g_fGiantSelfScale[client] = scale;
                    g_bGiantHealthStateSaved[client] = true;
                    g_iGiantOldMaxHealth[client] = GetRSPClientMaxHealth(client);
                    int totalHealth = GetGiantTotalHealthForScale(scale);
                    SetRSPClientMaxHealth(client, totalHealth);
                    if (IsPlayerAlive(client)) SetEntityHealth(client, totalHealth);
                    ApplyGiantCollisionBounds(client);
                }
                else
                {
                    ApplyDwarfCollisionBounds(client);
                }
                ApplySelfModelScaleViewOffset(client);
            }
        }
        case RSP_Zombie:
        {
            // First life stays normal; apply the Zombie loadout only after the one-time respawn.
        }
        case RSP_Swapper, RSP_Retreat, RSP_EnemySpawn, RSP_GodMode,
            RSP_RandomWeapon, RSP_NoClip:
        {
            // Active powers are activated manually through the shared rsp_useskill bind.
            g_fGodModeUntil[client] = 0.0;
        }
        case RSP_StripWeapons:
        {
            // Heist is activated through the shared bind dispatcher.
        }
        case RSP_Grenadier, RSP_Sunshine, RSP_Smoker:
        {
            // Each grenade power refills only its own grenade type after a throw.
        }
        case RSP_Bunny:
        {
            // Bunnyhop is handled by OnPlayerRunCmd and does not alter global server cvars.
        }
        case RSP_DoubleJump:
        {
            g_fDoubleJumpReadyTime[client] = GetGameTime() + RSP_DOUBLE_JUMP_DELAY;
        }
        case RSP_RapidFire:
        {
            int offerIndex = g_iGamblerSelectedOfferIndex[client];
            int thiefSource = GetThiefSourceForPower(client, RSP_RapidFire);
            g_fRapidFireMultiplier[client] = thiefSource > 0 ? g_fRapidFireMultiplier[thiefSource]
                : ((g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                    ? g_fGamblerRapidFireMultiplier[client][offerIndex]
                    : GetRandomFloat(RSP_RAPID_FIRE_MIN, RSP_RAPID_FIRE_MAX));
        }
        case RSP_InfiniteAmmo:
        {
            RequestFrame(Frame_ApplyInfiniteAmmo, GetClientUserId(client));
        }
        case RSP_Impostor:
        {
            ApplyDisguiseModel(client);
        }
        case RSP_FreezingAmmo:
        {
            // Freezing Ammo uses a whole-number chance in the 20-40% range.
            int offerIndex = g_iGamblerSelectedOfferIndex[client];
            int thiefSource = GetThiefSourceForPower(client, RSP_FreezingAmmo);
            g_iCryoChancePercent[client] = thiefSource > 0 ? g_iCryoChancePercent[thiefSource]
                : ((g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                    ? g_iGamblerCryoChance[client][offerIndex]
                    : GetRandomInt(20, 40));
        }
        case RSP_Concussion:
        {
            int source = GetThiefSourceForPower(client, RSP_Concussion);
            g_iConcussionChancePercent[client] = source > 0
                ? g_iConcussionChancePercent[source]
                : GetRandomInt(RSP_CONCUSSION_CHANCE_MIN, RSP_CONCUSSION_CHANCE_MAX);
        }
        case RSP_Disorient:
        {
            // Enemy Rotation is intentionally less frequent: 20%-40%, fixed for the round.
            int offerIndex = g_iGamblerSelectedOfferIndex[client];
            int thiefSource = GetThiefSourceForPower(client, RSP_Disorient);
            g_iDisorientChancePercent[client] = thiefSource > 0 ? g_iDisorientChancePercent[thiefSource]
                : ((g_bGamblerApplyingChoice[client] && offerIndex >= 0 && offerIndex < RSP_GAMBLER_OPTIONS)
                    ? g_iGamblerDisorientChance[client][offerIndex]
                    : GetRandomInt(20, 40));
        }
    }
}

void SaveGravityState(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(client))
    {
        return;
    }

    if (g_bGravityStateSaved[client])
    {
        return;
    }

    g_bGravityStateSaved[client] = true;
    g_bOldGravityValid[client] = HasEntProp(client, Prop_Data, "m_flGravity");
    if (g_bOldGravityValid[client])
    {
        g_fOldGravity[client] = GetEntityGravity(client);
    }
}

void SaveMoveSpeedState(int client)
{
    // RequestFrame callbacks can outlive a client slot during death/disconnect.
    // Never call HasEntProp on a stale or non-player entity index.
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(client))
    {
        return;
    }

    if (g_bMoveSpeedStateSaved[client])
    {
        return;
    }

    g_bMoveSpeedStateSaved[client] = true;
    g_bOldMoveSpeedValid[client] = HasEntProp(client, Prop_Data, "m_flLaggedMovementValue");
    if (g_bOldMoveSpeedValid[client])
    {
        g_fOldMoveSpeed[client] = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
    }
}

void ResetClientPower(int client, bool clampBonusHealth, bool preserveAnomalyHistory = false, bool preserveIncomingTargetEffects = false)
{
    StopHook(client);
    if (client < 1 || client > MaxClients)
    {
        return;
    }
    RestoreBunnyMaxSpeed(client);
    if (!preserveAnomalyHistory)
    {
        ClearAnomalyHistory(client);
    }

    StopInfiniteGrenadeRefillTimers(client);
    StopReviverCooldown(client);
    StopSkillCooldown(client);
    StopSapperPlantAnimation(client);
    StopRSPTargetSelectionBuildTimer(client);
    g_iTargetSelectionType[client] = RSP_TARGET_SELECT_NONE;
    g_bTargetSelectionPending[client] = false;
    g_bTargetSelectionForceDisplay[client] = false;
    g_bTargetSelectionInitialized[client] = false;
    g_iTargetSelectionCount[client] = 0;
    g_iTargetSelectionRound[client] = 0;
    for (int selectionIndex = 0; selectionIndex <= MAXPLAYERS; selectionIndex++)
    {
        g_iTargetSelectionUserIds[client][selectionIndex] = 0;
        g_eTargetSelectionPowerSnapshot[client][selectionIndex] = RSP_None;
        g_iTargetSelectionTeamSnapshot[client][selectionIndex] = 0;
    }
    g_bHostPowerGrantedOutsideRound[client] = false;
    if (g_bNoclipWindowOpen[client] || g_bNoclipActive[client])
    {
        StopNoclip(client, false, true, true);
    }
    if (g_bSpectatorActive[client])
    {
        StopSpectatorMode(client, IsPlayerAlive(client));
    }
    RSPPower oldPower = g_iPower[client];
    bool inGame = IsClientInGame(client);
    if (oldPower == RSP_HealingAngel && g_bHealingAngelMaxHealthStateSaved[client])
    {
        int oldAngelMaxHealth = g_iHealingAngelOldMaxHealth[client] > 0
            ? g_iHealingAngelOldMaxHealth[client] : 100;
        if (inGame)
        {
            SetRSPClientMaxHealth(client, oldAngelMaxHealth);
            if (clampBonusHealth && IsPlayerAlive(client) && GetClientHealth(client) > oldAngelMaxHealth)
            {
                SetEntityHealth(client, oldAngelMaxHealth);
            }
        }
        g_bHealingAngelMaxHealthStateSaved[client] = false;
        g_iHealingAngelOldMaxHealth[client] = 100;
        g_fHealingAngelNextUseTime[client] = 0.0;
    }
    if (oldPower == RSP_Giant && g_bGiantHealthStateSaved[client])
    {
        int oldMaxHealth = g_iGiantOldMaxHealth[client] > 0 ? g_iGiantOldMaxHealth[client] : 100;
        if (inGame)
        {
            SetRSPClientMaxHealth(client, oldMaxHealth);
            if (clampBonusHealth && IsPlayerAlive(client) && GetClientHealth(client) > oldMaxHealth)
            {
                SetEntityHealth(client, oldMaxHealth);
            }
        }
        g_bGiantHealthStateSaved[client] = false;
        g_iGiantOldMaxHealth[client] = 100;
        g_fGiantSelfScale[client] = 1.0;
    }

    // Always reconcile any saved attack-time adjustment for this player, not only when
    // oldPower still says Rapid Fire. This also repairs stale tracking left by an earlier
    // interrupted reassignment, while the helper only writes back values still matching
    // our own last write and never blindly overwrites a newer engine/plugin timestamp.
    int rapidFireUserId = (inGame ? GetClientUserId(client) : g_iCachedClientUserId[client]);
    RestoreRapidFireAdjustmentsForOwner(rapidFireUserId);
    if (!preserveIncomingTargetEffects)
    {
        // An incoming Grounder lock survives ordinary power reassignment while its
        // target is alive. Event_PlayerDeath explicitly removes it before any respawn.
        ClearHackerEffect(client);
        ClearGiantEffect(client);
    }
    g_bGrounderUsedThisAssignment[client] = false;
    g_iLeechChancePercent[client] = 0;
    if (oldPower == RSP_Gambler)
    {
        g_bGamblerPendingSelection[client] = false;
        g_bGamblerChatIntercept[client] = false;
        g_bGamblerApplyingChoice[client] = false;
        g_iGamblerSelectedOfferIndex[client] = -1;
    }
    if (g_hZombieRespawnTimer[client] != null)
    {
        delete g_hZombieRespawnTimer[client];
        g_hZombieRespawnTimer[client] = null;
    }
    g_bZombieRespawnPending[client] = false;
    g_iZombieRespawnRound[client] = 0;
    g_bZombieCleanupQueued[client] = false;
    g_iZombieCleanupRound[client] = 0;
    g_iZombieLoadoutRound[client] = 0;
    g_bZombieLoadoutApplying[client] = false;

    StopClientRegenTimer(client);
    StopClientBlindTimer(client);
    g_bDisarmPending[client] = false;
    g_iPendingDropWeaponRef[client] = 0;

    if (oldPower == RSP_Ghost || oldPower == RSP_Zombie)
    {
        // Ghost and Zombie remove weapon entities. Restore a normal team pistol
        // on the next non-Ghost/non-Zombie spawn; removed entities cannot return.
        g_bGhostNeedsDefaultPistol[client] = true;
    }

    if (oldPower == RSP_Ghost)
    {
        UntrackGhostInventoryWeapons(client);
        int ownerUserId = inGame ? GetClientUserId(client) : 0;
        if (ownerUserId != 0)
        {
            for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
            {
                if (g_iGhostEntityOwnerUserId[entity] != ownerUserId)
                {
                    continue;
                }

                if (IsValidEntity(entity))
                {
                    UntrackGhostWeaponEntity(entity);
                }
                else
                {
                    g_iGhostEntityOwnerUserId[entity] = 0;
                }
            }
        }
    }

    if (inGame)
    {
        if (oldPower == RSP_FlashPro)
        {
            if (HasEntProp(client, Prop_Send, "m_flFlashDuration"))
            {
                SetEntPropFloat(client, Prop_Send, "m_flFlashDuration", 0.0);
            }
            if (HasEntProp(client, Prop_Send, "m_flFlashMaxAlpha"))
            {
                SetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha", 255.0);
            }
        }
        if (g_bDisguiseApplied[client] &&
            ((!g_bDisguiseDeathTransition[client] &&
                (IsPlayerAlive(client) || g_bRoundEnding || !g_bEnabled || !g_bRoundReady)) ||
                (g_bDisguiseDeathTransition[client] &&
                    (g_bRoundEnding || GetGameTime() >= g_fDisguiseDeathTransitionUntil[client]))))
        {
            // Do not replace the model during the pre-death player_death event.
            // Retain it for the full death transition, then restore on respawn or cleanup.
            RestoreDisguiseModel(client);
        }
        if (g_fWeakeningUntil[client] > GetGameTime() && g_iWeakeningRound[client] == g_iRoundSerial &&
            g_bWeakeningBaseMovementValid[client] && HasEntProp(client, Prop_Data, "m_flLaggedMovementValue"))
        {
            // Remove the temporary weakening scale before restoring the old power;
            // the power-specific baseline restoration below can then run normally.
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_fWeakeningBaseMovementValue[client]);
        }
        if (g_bGravityStateSaved[client] && g_bOldGravityValid[client] &&
            HasEntProp(client, Prop_Data, "m_flGravity"))
        {
            SetEntityGravity(client, g_fOldGravity[client]);
        }
        if (g_bMoveSpeedStateSaved[client] && g_bOldMoveSpeedValid[client] &&
            HasEntProp(client, Prop_Data, "m_flLaggedMovementValue"))
        {
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_fOldMoveSpeed[client]);
        }
        if (g_bModelScaleStateSaved[client])
        {
            if (g_bOldModelScaleValid[client] && HasEntProp(client, Prop_Send, "m_flModelScale"))
            {
                SetEntPropFloat(client, Prop_Send, "m_flModelScale", g_fOldModelScale[client]);
            }
            if (g_bOldCollisionBoundsValid[client] && oldPower == RSP_Dwarf)
            {
                // Restore the normal hull for the player's current stance before forgetting the snapshot.
                ApplyDwarfCollisionBounds(client);
            }
            else if (g_bOldCollisionBoundsValid[client] && oldPower == RSP_Giant)
            {
                SetRSPCollisionBounds(client, g_fOldCollisionMins[client], g_fOldCollisionMaxs[client]);
            }
            if (g_bOldViewOffsetValid[client] && HasEntProp(client, Prop_Data, "m_vecViewOffset"))
            {
                float restoreViewOffset[3];
                for (int axis = 0; axis < 3; axis++)
                {
                    restoreViewOffset[axis] = g_fOldViewOffset[client][axis];
                }
                if (HasEntProp(client, Prop_Send, "m_bDucked"))
                {
                    bool isDucked = GetEntProp(client, Prop_Send, "m_bDucked") != 0;
                    if (isDucked != g_bOldViewOffsetWasDucked[client])
                    {
                        restoreViewOffset[2] += isDucked ? -RSP_DWARF_DUCK_VIEW_HEIGHT_DELTA : RSP_DWARF_DUCK_VIEW_HEIGHT_DELTA;
                    }
                }
                SetEntPropVector(client, Prop_Data, "m_vecViewOffset", restoreViewOffset);
            }
        }

        if (clampBonusHealth && oldPower == RSP_Rambo && IsPlayerAlive(client))
        {
            int health = GetClientHealth(client);
            if (health > g_iOldRamboHealth[client] && g_iOldRamboHealth[client] > 0)
            {
                SetEntityHealth(client, g_iOldRamboHealth[client]);
            }
        }
    }

    g_iPowerNoticeGeneration[client]++;
    if (g_iPowerNoticeGeneration[client] <= 0)
    {
        g_iPowerNoticeGeneration[client] = 1;
    }
    g_iPower[client] = RSP_None;
    g_fNextSkillUseTime[client] = 0.0;
    if (!preserveIncomingTargetEffects)
    {
        g_fReverseControlsUntil[client] = 0.0;
        g_iReverseControlsRound[client] = 0;
        g_iReverseControlsOwnerUserId[client] = 0;
    }
    g_fGodModeUntil[client] = 0.0;
    g_fVampirismHealRemainder[client] = 0.0;
    g_fDoubleJumpReadyTime[client] = 0.0;
    g_bDoubleJumpWasDown[client] = false;
    g_bGravityStateSaved[client] = false;
    g_bOldGravityValid[client] = false;
    g_fLowGravityMultiplier[client] = 0.0;
    g_bMoveSpeedStateSaved[client] = false;
    g_bOldMoveSpeedValid[client] = false;
    g_bModelScaleStateSaved[client] = false;
    g_bOldModelScaleValid[client] = false;
    g_bOldViewOffsetValid[client] = false;
    g_bOldViewOffsetWasDucked[client] = false;
    g_fSelfModelScaleRatio[client] = 1.0;
    g_fGiantSelfScale[client] = 1.0;
    g_iGiantOldMaxHealth[client] = 100;
    g_bGiantHealthStateSaved[client] = false;
    g_fHealingAngelNextUseTime[client] = 0.0;
    g_iHealingAngelOldMaxHealth[client] = 100;
    g_bHealingAngelMaxHealthStateSaved[client] = false;
    g_bBlackoutUsedThisAssignment[client] = false;
    g_bOldCollisionBoundsValid[client] = false;
    g_iOldRamboHealth[client] = 100;
    g_iRamboRolledBonus[client] = 0;
    g_fArmouredDamageReduction[client] = RSP_ARMOURED_REDUCTION_MIN;
    g_iCryoChancePercent[client] = 0;
    g_iDisorientChancePercent[client] = 0;
    g_iConcussionChancePercent[client] = 0;
    g_fSpeedBonus[client] = 0.0;
    g_fRapidFireMultiplier[client] = 1.0;
    g_iLastFiredWeaponRef[client] = 0;
    g_iDisarmChancePercent[client] = 0;
    g_iRichBoyRolledBonus[client] = 0;
    g_fSoldierDamageMultiplier[client] = 1.0;
    g_iExplosiveBulletsChancePercent[client] = 0;
    g_iExplosiveBulletLastImpactTick[client] = -1;
    g_iKnockupChancePercent[client] = 0;
    g_bExplosiveBulletDamageInProgress[client] = false;
    g_iExpensiveAmmoPendingShots[client] = 0;
    g_bExpensiveAmmoFrameQueued[client] = false;
    g_iExpensiveAmmoShotTick[client] = 0;
    g_iLastFriendlyTraceTick[client] = 0;
    g_iSapperSpeedPercent[client] = 0;
    g_bSapperPlantAnimationActive[client] = false;
    g_iSapperViewModelRef[client] = INVALID_ENT_REFERENCE;
    g_bSapperViewModelRateSaved[client] = false;
    g_fSapperViewModelOriginalRate[client] = 1.0;
    g_bSapperPlayerRateSaved[client] = false;
    g_fSapperPlayerOriginalRate[client] = 1.0;
    g_iMachetePendingAttackerUserId[client] = 0;
    g_iMachetePendingRound[client] = 0;

    if (oldPower == RSP_Wallhack || oldPower == RSP_Ghost)
    {
        QueueWallhackRefresh();
    }
}

void ResetAllClientPowers(bool clampBonusHealth)
{
    ClearAllGrounderEffects();
    ClearAllBlackoutEffects(true);
    for (int client = 1; client <= MaxClients; client++)
    {
        CancelPowerRespawn(client);
        g_bAvengerConsumedThisRound[client] = false;
        ClearWeakeningAmmoState(client, true);
        ResetClientPower(client, clampBonusHealth);
    }
}

void QueueExecutionerHEAttribution(int victim, int ownerUserId)
{
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim) || ownerUserId == 0)
    {
        return;
    }

    g_bExecutionerHEKillPending[victim] = true;
    g_iExecutionerHEKillOwnerUserId[victim] = ownerUserId;
    // If another hook cancels the damage and no death occurs this frame, discard
    // the pending attribution before an unrelated later death can reuse it.
    RequestFrame(Frame_ClearExecutionerHEAttribution, GetClientUserId(victim));
}

public void Frame_ClearExecutionerHEAttribution(any userid)
{
    int victim = GetClientOfUserId(userid);
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return;
    }

    if (IsPlayerAlive(victim))
    {
        g_bExecutionerHEKillPending[victim] = false;
        g_iExecutionerHEKillOwnerUserId[victim] = 0;
    }
}

bool IsRSPGodModeActive(int client)
{
    return client >= 1 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client) &&
        g_iPower[client] == RSP_GodMode && g_iAssignedRound[client] == g_iRoundSerial &&
        g_fGodModeUntil[client] > GetGameTime();
}

// Source's MOVETYPE_NOCLIP makes a player effectively non-solid to some attack
// paths in CS:S. Briefly restore the player's pre-noclip movement type when a
// hit enters the damage pipeline, then re-enable noclip after damage processing.
// The RequestFrame callback is a fallback in case a damage path exits before the
// OnTakeDamagePost hook runs; it is queued at most once per client at a time.
void PrepareNoclipVictimForDamage(int victim)
{
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim) || !IsPlayerAlive(victim) ||
        !g_bNoclipActive[victim] || g_iPower[victim] != RSP_NoClip ||
        g_iAssignedRound[victim] != g_iRoundSerial || GetEntityMoveType(victim) != MOVETYPE_NOCLIP)
    {
        return;
    }

    MoveType restoreMoveType = view_as<MoveType>(g_iNoclipOldMoveType[victim]);
    if (restoreMoveType == MOVETYPE_NOCLIP || restoreMoveType == MOVETYPE_NONE)
    {
        restoreMoveType = MOVETYPE_WALK;
    }
    SetEntityMoveType(victim, restoreMoveType);

    if (!g_bNoclipDamageRestoreQueued[victim])
    {
        g_bNoclipDamageRestoreQueued[victim] = true;
        RequestFrame(Frame_RestoreNoclipAfterDamage, GetClientUserId(victim));
    }
}

void RestoreNoclipAfterDamage(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) ||
        !g_bNoclipActive[client] || g_iPower[client] != RSP_NoClip ||
        g_iAssignedRound[client] != g_iRoundSerial || GetGameTime() >= g_fNoclipExpiresAt[client])
    {
        return;
    }

    SetEntityMoveType(client, MOVETYPE_NOCLIP);
}

public void Frame_RestoreNoclipAfterDamage(any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    g_bNoclipDamageRestoreQueued[client] = false;
    RestoreNoclipAfterDamage(client);
}

bool IsRSPFriendlyFireEnabled()
{
    return g_hMpFriendlyFire != null && g_hMpFriendlyFire.BoolValue;
}

bool CanRSPApplyHitEffect(int attacker, int victim)
{
    if (attacker < 1 || attacker > MaxClients || victim < 1 || victim > MaxClients ||
        attacker == victim || !IsClientInGame(attacker) || !IsClientInGame(victim))
    {
        return false;
    }

    if (GetClientTeam(attacker) != GetClientTeam(victim))
    {
        return true;
    }

    return IsRSPFriendlyFireEnabled();
}

bool IsRSPMacheteMeleeHit(int attacker, int victim, int inflictor, int damagetype)
{
    if (attacker < 1 || attacker > MaxClients || victim < 1 || victim > MaxClients ||
        attacker == victim || !IsClientInGame(attacker) || !IsClientInGame(victim) ||
        !IsPlayerAlive(attacker) || !IsPlayerAlive(victim) || g_iPower[attacker] != RSP_Machete ||
        !CanRSPApplyHitEffect(attacker, victim))
    {
        return false;
    }

    bool isMeleeDamage = (damagetype & (DMG_SLASH | DMG_CLUB)) != 0;
    if (!isMeleeDamage && inflictor > MaxClients && inflictor < RSP_MAX_ENTITIES && IsValidEntity(inflictor))
    {
        char inflictorClass[32];
        GetEntityClassname(inflictor, inflictorClass, sizeof(inflictorClass));
        isMeleeDamage = StrEqual(inflictorClass, "weapon_knife", false);
    }
    if (!isMeleeDamage)
    {
        return false;
    }

    int activeWeapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
    if (activeWeapon > MaxClients && activeWeapon < RSP_MAX_ENTITIES && IsValidEntity(activeWeapon))
    {
        char activeWeaponEntityClass[64];
        GetEntityClassname(activeWeapon, activeWeaponEntityClass, sizeof(activeWeaponEntityClass));
        if (StrEqual(activeWeaponEntityClass, "weapon_knife", false))
        {
            return true;
        }
    }

    char activeWeaponClass[64];
    GetClientWeapon(attacker, activeWeaponClass, sizeof(activeWeaponClass));
    return StrEqual(activeWeaponClass, "weapon_knife", false);
}

bool IsRSPAttackerBehindVictim(int attacker, int victim)
{
    if (attacker < 1 || attacker > MaxClients || victim < 1 || victim > MaxClients ||
        attacker == victim || !IsClientInGame(attacker) || !IsClientInGame(victim))
    {
        return false;
    }

    float victimAngles[3], forwardVec[3], rightVec[3], upVec[3];
    GetClientEyeAngles(victim, victimAngles);
    GetAngleVectors(victimAngles, forwardVec, rightVec, upVec);
    forwardVec[2] = 0.0;
    float forwardLength = SquareRoot(forwardVec[0] * forwardVec[0] + forwardVec[1] * forwardVec[1]);
    if (forwardLength < 0.001)
    {
        return false;
    }
    forwardVec[0] /= forwardLength;
    forwardVec[1] /= forwardLength;

    float victimOrigin[3], attackerOrigin[3];
    GetClientAbsOrigin(victim, victimOrigin);
    GetClientAbsOrigin(attacker, attackerOrigin);
    float toAttacker[3];
    toAttacker[0] = attackerOrigin[0] - victimOrigin[0];
    toAttacker[1] = attackerOrigin[1] - victimOrigin[1];
    toAttacker[2] = 0.0;
    float attackerLength = SquareRoot(toAttacker[0] * toAttacker[0] + toAttacker[1] * toAttacker[1]);
    if (attackerLength < 0.001)
    {
        return false;
    }
    toAttacker[0] /= attackerLength;
    toAttacker[1] /= attackerLength;

    // Dot <= -0.5 means the attacker's position lies within a 120-degree cone behind the victim.
    float facingDot = forwardVec[0] * toAttacker[0] + forwardVec[1] * toAttacker[1];
    return facingDot <= -0.5;
}

public Action Hook_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!g_bEnabled || !g_bSupportedMap ||
        victim < 1 || victim > MaxClients || !IsClientInGame(victim) || !IsPlayerAlive(victim))
    {
        return Plugin_Continue;
    }

    if (g_bSpectatorActive[victim] ||
        (attacker >= 1 && attacker <= MaxClients && g_bSpectatorActive[attacker]))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    if ((damagetype & DMG_FALL) != 0 && damage > 0.0 &&
        g_iPower[victim] == RSP_FeatherFalling && g_iAssignedRound[victim] == g_iRoundSerial &&
        (IsRSPPowerRuntimeActive() || g_bRoundEnding))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    if (damage > 0.0 && (damagetype & DMG_BLAST) != 0 &&
        inflictor > MaxClients && inflictor < RSP_MAX_ENTITIES && IsValidEntity(inflictor) &&
        g_bHEProjectileEnder[inflictor] && g_iHEProjectileRound[inflictor] == g_iRoundSerial &&
        g_iHEProjectileOwnerUserId[inflictor] == GetClientUserId(victim))
    {
        // Ender Grenade must not hurt its own thrower at the instant of teleportation.
        damage = 0.0;
        return Plugin_Handled;
    }

    if (damage > 0.0)
    {
        PrepareNoclipVictimForDamage(victim);
    }

    // Blast Protection blocks all damage tagged by CS:S as blast damage, regardless
    // of whether it came from HE/C4, Explosive Bullets, Exploding Barrel, or death explosions.
    if (damage > 0.0 && (damagetype & DMG_BLAST) != 0 &&
        g_iPower[victim] == RSP_BlastProtection &&
        g_iAssignedRound[victim] == g_iRoundSerial &&
        (IsRSPPowerRuntimeActive() || g_bRoundEnding))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    g_bThornsDamagePending[victim] = false;
    g_iThornsInflictorRef[victim] = 0;
    if (!g_bApplyingThornsDamage && IsRSPPowerRuntimeActive() && damage > 0.0 &&
        g_iPower[victim] == RSP_Thorns && attacker >= 1 && attacker <= MaxClients &&
        attacker != victim && IsClientInGame(attacker))
    {
        bool incomingTeslaShot = inflictor > MaxClients && inflictor < RSP_MAX_ENTITIES &&
            IsValidEntity(inflictor) && g_iBuildableType[inflictor] == RSP_BUILDABLE_TURRET &&
            g_iBuildableOwnerUserId[inflictor] == GetClientUserId(attacker);
        bool thornsSourceAllowed = false;
        if (incomingTeslaShot)
        {
            int sourceTeam = GetClientTeam(attacker);
            int targetTeam = GetClientTeam(victim);
            thornsSourceAllowed = (sourceTeam == CS_TEAM_T || sourceTeam == CS_TEAM_CT) &&
                (targetTeam == CS_TEAM_T || targetTeam == CS_TEAM_CT) && sourceTeam != targetTeam;
        }
        else
        {
            thornsSourceAllowed = IsPlayerAlive(attacker) && CanRSPApplyHitEffect(attacker, victim);
        }

        if (thornsSourceAllowed)
        {
            g_bThornsDamagePending[victim] = true;
            g_iThornsAttackerUserId[victim] = GetClientUserId(attacker);
            g_iThornsHealthBeforeDamage[victim] = GetClientHealth(victim);
            g_iThornsDamageRound[victim] = g_iRoundSerial;
            if (incomingTeslaShot)
            {
                g_iThornsInflictorRef[victim] = EntIndexToEntRef(inflictor);
            }
        }
    }

    if (IsRSPPowerRuntimeActive() && g_iPower[victim] == RSP_Ghost && damage > 0.0 &&
        damage >= float(GetClientHealth(victim)))
    {
        g_fGhostDeathRevealUntil[victim] = GetGameTime() + RSP_GHOST_DEATH_REVEAL_DURATION;
    }

    if ((damagetype & DMG_BLAST) != 0 && inflictor > MaxClients &&
        inflictor < RSP_MAX_ENTITIES && IsValidEntity(inflictor) && victim != attacker &&
        g_iRSPDeathExplosionTeam[inflictor] > CS_TEAM_SPECTATOR &&
        GetClientTeam(victim) == g_iRSPDeathExplosionTeam[inflictor] && !IsRSPFriendlyFireEnabled())
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    if (IsRSPGodModeActive(victim))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    if (IsRSPPowerRuntimeActive() && damage > 0.0 &&
        IsRSPMacheteMeleeHit(attacker, victim, inflictor, damagetype))
    {
        damage = float(GetClientHealth(victim) + 50000);
        return Plugin_Changed;
    }

    if (g_bDeadlyFlashForceKill[victim])
    {
        return Plugin_Continue;
    }

    // Capture victim health before damage; the post-hook compares actual HP lost
    // rather than trusting nominal overkill or damage absorbed by immunity/armor.
    if (IsRSPPowerRuntimeActive() && damage > 0.0 && attacker >= 1 && attacker <= MaxClients &&
        attacker != victim && IsClientInGame(attacker) && IsPlayerAlive(attacker) &&
        g_iPower[attacker] == RSP_Dracula && CanRSPApplyHitEffect(attacker, victim))
    {
        g_iVampirismDamageAttackerUserId[victim] = GetClientUserId(attacker);
        g_iVampirismHealthBeforeDamage[victim] = GetClientHealth(victim);
        g_iVampirismDamageRound[victim] = g_iRoundSerial;
    }

    bool burnOwnerApplied = false;
    if ((IsRSPPowerRuntimeActive() || g_bRoundEnding) &&
        ((damagetype & DMG_BURN) != 0 || (damagetype & DMG_SLOWBURN) != 0) &&
        g_iBurnOwnerUserId[victim] != 0 && g_iBurnOwnerRound[victim] == g_iRoundSerial &&
        GetGameTime() <= g_fBurnOwnerUntil[victim])
    {
        // IgniteEntity's native burn tick is allowed to hit health instead of armor.
        // Preserve the armor value and restore it in OnTakeDamagePost, after the
        // engine has applied this native tick; no custom health damage is added.
        if (!g_bIncendiaryArmorRestorePending[victim] &&
            HasEntProp(victim, Prop_Send, "m_ArmorValue"))
        {
            int armorValue = GetEntProp(victim, Prop_Send, "m_ArmorValue");
            if (armorValue > 0)
            {
                g_bIncendiaryArmorRestorePending[victim] = true;
                g_iIncendiaryArmorRestoreValue[victim] = armorValue;
                g_iIncendiaryArmorRestoreRound[victim] = g_iRoundSerial;
                SetEntProp(victim, Prop_Send, "m_ArmorValue", 0);
            }
        }

        int burnOwner = GetClientOfUserId(g_iBurnOwnerUserId[victim]);
        if (burnOwner >= 1 && burnOwner <= MaxClients && IsClientInGame(burnOwner) && burnOwner != victim)
        {
            attacker = burnOwner;
            burnOwnerApplied = true;
            if (damage >= float(GetClientHealth(victim)))
            {
                g_bBurnDeathPending[victim] = true;
                g_iBurnDeathOwnerUserId[victim] = GetClientUserId(burnOwner);
                g_iBurnDeathRound[victim] = g_iRoundSerial;
                RequestFrame(Frame_ClearBurnDeathPending, GetClientUserId(victim));
            }
        }
    }

    // Preferred path: resolve Executioner from a snapshot stored on the projectile itself.
    // This does not depend on the now-dead owner's current power or damage attacker field.
    if ((IsRSPPowerRuntimeActive() || g_bRoundEnding) && damage > 0.0 &&
        (damagetype & DMG_BLAST) != 0 && inflictor > MaxClients && inflictor < RSP_MAX_ENTITIES &&
        IsValidEntity(inflictor) && g_bHEProjectileExecutioner[inflictor] &&
        g_iHEProjectileRound[inflictor] == g_iRoundSerial &&
        GetGameTime() - g_fHEProjectileSpawnTime[inflictor] >= 0.0 &&
        GetGameTime() - g_fHEProjectileSpawnTime[inflictor] <= RSP_EXECUTIONER_HE_GRACE)
    {
        int heOwnerUserId = g_iHEProjectileOwnerUserId[inflictor];
        int heOwner = GetClientOfUserId(heOwnerUserId);
        int heOwnerTeam = g_iHEProjectileTeam[inflictor];
        if (heOwner >= 1 && heOwner <= MaxClients && IsClientInGame(heOwner))
        {
            heOwnerTeam = GetClientTeam(heOwner);
            if (heOwner == victim)
            {
                // Executioner must not exempt its owner from the owner's own HE blast.
                // Native lethal damage handles the self-kill without fake attacker attribution.
                attacker = heOwner;
                damage = GetExecutionerLethalDamage(victim);
                return Plugin_Changed;
            }
            if (!CanRSPApplyHitEffect(heOwner, victim))
            {
                return Plugin_Continue;
            }
            attacker = heOwner;
        }
        else if (heOwnerTeam == GetClientTeam(victim) && !IsRSPFriendlyFireEnabled())
        {
            return Plugin_Continue;
        }
        QueueExecutionerHEAttribution(victim, heOwnerUserId);
        QueueExecutionerGuaranteedKillByUserId(victim, heOwnerUserId);
        damage = GetExecutionerLethalDamage(victim);
        return Plugin_Changed;
    }

    // Legacy attribution fallback for CS:S builds which pass the thrower but not the tracked entity.
    if ((IsRSPPowerRuntimeActive() || g_bRoundEnding) && damage > 0.0 &&
        attacker >= 1 && attacker <= MaxClients && IsClientInGame(attacker) &&
        (damagetype & DMG_BLAST) != 0 && inflictor > MaxClients && IsValidEntity(inflictor))
    {
        char inflictorClass[64];
        GetEntityClassname(inflictor, inflictorClass, sizeof(inflictorClass));
        float heAge = GetGameTime() - g_fLastHEThrowTime[attacker];
        if (StrEqual(inflictorClass, "hegrenade_projectile", false) &&
            g_bLastHEWasExecutioner[attacker] && g_iLastHERound[attacker] == g_iRoundSerial &&
            heAge >= 0.0 && heAge <= RSP_EXECUTIONER_HE_GRACE &&
            (attacker == victim || CanRSPApplyHitEffect(attacker, victim)))
        {
            if (attacker == victim)
            {
                // Keep the fallback path consistent with tracked projectiles.
                damage = GetExecutionerLethalDamage(victim);
                return Plugin_Changed;
            }
            QueueExecutionerHEAttribution(victim, GetClientUserId(attacker));
            QueueExecutionerGuaranteedKill(victim, attacker);
            damage = GetExecutionerLethalDamage(victim);
            return Plugin_Changed;
        }
    }

    // Other powers are active only during the live round.
    if (!IsRSPPowerRuntimeActive())
    {
        return burnOwnerApplied ? Plugin_Changed : Plugin_Continue;
    }

    // Executioner applies to all damage types.
    // Bullet and buckshot hits are handled in TraceAttack; this branch covers
    // non-trace damage such as knife slashes and non-HE explosions without
    // duplicating the firearm path. The tracked HE path above retains thrower credit.
    if (damage > 0.0 && attacker >= 1 && attacker <= MaxClients && attacker != victim &&
        IsValidPlayingClient(attacker) && IsPlayerAlive(attacker) &&
        CanRSPApplyHitEffect(attacker, victim) &&
        g_iPower[attacker] == RSP_Executioner && g_iAssignedRound[attacker] == g_iRoundSerial &&
        (damagetype & DMG_BULLET) == 0 && (damagetype & DMG_BUCKSHOT) == 0)
    {
        damage = GetExecutionerLethalDamage(victim);
        QueueExecutionerGuaranteedKill(victim, attacker);
        return Plugin_Changed;
    }

    // Aimbot firearm body hits have already been normalized to 4x headshot-equivalent
    // damage in Hook_TraceAttack. A real CS:S headshot against a player without a helmet
    // bypasses vest armor, so temporarily zero armor for this damage application as well.
    // Restore the saved vest value in Hook_OnTakeDamagePost so the hit neither absorbs nor
    // consumes armor. Helmeted targets retain normal armor handling, matching headshots.
    if (damage > 0.0 && attacker >= 1 && attacker <= MaxClients && attacker != victim &&
        IsClientInGame(attacker) && IsPlayerAlive(attacker) &&
        g_iPower[attacker] == RSP_Aimbot && g_iAssignedRound[attacker] == g_iRoundSerial &&
        CanRSPApplyHitEffect(attacker, victim) &&
        (damagetype & (DMG_BULLET | DMG_BUCKSHOT)) != 0 &&
        HasEntProp(victim, Prop_Send, "m_bHasHelmet") &&
        GetEntProp(victim, Prop_Send, "m_bHasHelmet") == 0 &&
        HasEntProp(victim, Prop_Send, "m_ArmorValue") &&
        !g_bIncendiaryArmorRestorePending[victim] && !g_bAimbotArmorRestorePending[victim])
    {
        char aimbotDamageWeapon[64];
        GetClientWeapon(attacker, aimbotDamageWeapon, sizeof(aimbotDamageWeapon));
        if (IsRSPFirearmEventWeapon(aimbotDamageWeapon))
        {
            int savedAimbotArmor = GetEntProp(victim, Prop_Send, "m_ArmorValue");
            if (savedAimbotArmor > 0)
            {
                g_bAimbotArmorRestorePending[victim] = true;
                g_iAimbotArmorRestoreValue[victim] = savedAimbotArmor;
                g_iAimbotArmorRestoreRound[victim] = g_iRoundSerial;
                SetEntProp(victim, Prop_Send, "m_ArmorValue", 0);
            }
        }
    }

    bool weakeningDamageApplied = false;
    if (damage > 0.0 && attacker >= 1 && attacker <= MaxClients && attacker != victim &&
        IsClientInGame(attacker) && g_fWeakeningUntil[attacker] > GetGameTime() &&
        g_iWeakeningRound[attacker] == g_iRoundSerial)
    {
        damage *= RSP_CRIPPLER_DAMAGE_MULTIPLIER;
        weakeningDamageApplied = true;
    }

    bool soldierDamageApplied = false;
    bool berserkerDamageApplied = false;
    bool assassinDamageApplied = false;
    if (damage > 0.0 && attacker >= 1 && attacker <= MaxClients && attacker != victim &&
        IsValidPlayingClient(attacker) && IsPlayerAlive(attacker) &&
        CanRSPApplyHitEffect(attacker, victim) &&
        g_iPower[attacker] == RSP_Berserker && GetClientHealth(attacker) > 0 &&
        GetClientHealth(attacker) <= RSP_BERSERKER_TRIGGER_HP &&
        g_iAssignedRound[attacker] == g_iRoundSerial)
    {
        damage *= RSP_BERSERKER_DAMAGE_MULTIPLIER;
        berserkerDamageApplied = true;
    }

    // Soldier modifies the native damage value before armor/reduction processing;
    // this preserves the original attacker and lets CS:S handle killfeed, frags and money.
    if (damage > 0.0 && attacker >= 1 && attacker <= MaxClients && attacker != victim &&
        IsValidPlayingClient(attacker) && IsPlayerAlive(attacker) &&
        CanRSPApplyHitEffect(attacker, victim) &&
        g_iPower[attacker] == RSP_Soldier && g_iAssignedRound[attacker] == g_iRoundSerial)
    {
        float multiplier = g_fSoldierDamageMultiplier[attacker];
        if (multiplier < 1.15 || multiplier > 1.30)
        {
            multiplier = 1.15;
        }
        damage *= multiplier;
        soldierDamageApplied = true;
    }

    // Assassin doubles only direct player attacks from behind. Explosions, burn, poison,
    // fall damage and other lingering/environmental damage do not inherit the attacker's position.
    if (damage > 0.0 && attacker >= 1 && attacker <= MaxClients && attacker != victim &&
        IsValidPlayingClient(attacker) && IsPlayerAlive(attacker) &&
        CanRSPApplyHitEffect(attacker, victim) &&
        g_iPower[attacker] == RSP_Assassin &&
        (g_iAssignedRound[attacker] == g_iRoundSerial || g_bHostPowerGrantedOutsideRound[attacker]) &&
        (damagetype & (DMG_BULLET | DMG_BUCKSHOT | DMG_SLASH | DMG_CLUB)) != 0 &&
        IsRSPAttackerBehindVictim(attacker, victim))
    {
        damage *= 2.0;
        assassinDamageApplied = true;
    }

    if (g_iPower[victim] == RSP_Zombie && !g_bZombieUsedThisRound[victim] &&
        IsValidPlayingClient(victim) && damage >= float(GetClientHealth(victim)))
    {
        g_bZombieRespawnPending[victim] = true;
        g_iZombieRespawnRound[victim] = g_iRoundSerial;
        RequestFrame(Frame_ClearZombieLethalPending, GetClientUserId(victim));
    }

    if (g_iPower[victim] == RSP_Armoured && damage > 0.0)
    {
        damage *= (1.0 - g_fArmouredDamageReduction[victim]);
        return Plugin_Changed;
    }

    return (burnOwnerApplied || weakeningDamageApplied || soldierDamageApplied || berserkerDamageApplied || assassinDamageApplied) ? Plugin_Changed : Plugin_Continue;
}

public void Hook_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return;
    }

    // Re-enter noclip only after the engine has processed the incoming hit.
    // Frame_RestoreNoclipAfterDamage remains as a backup for handled/short-circuit paths.
    if (g_bNoclipDamageRestoreQueued[victim])
    {
        RestoreNoclipAfterDamage(victim);
    }

    if (g_bAimbotArmorRestorePending[victim])
    {
        int armorToRestore = g_iAimbotArmorRestoreValue[victim];
        int armorRestoreRound = g_iAimbotArmorRestoreRound[victim];
        g_bAimbotArmorRestorePending[victim] = false;
        g_iAimbotArmorRestoreValue[victim] = 0;
        g_iAimbotArmorRestoreRound[victim] = 0;

        if (IsPlayerAlive(victim) && armorRestoreRound == g_iRoundSerial && armorToRestore > 0 &&
            HasEntProp(victim, Prop_Send, "m_ArmorValue"))
        {
            int currentArmor = GetEntProp(victim, Prop_Send, "m_ArmorValue");
            if (currentArmor < armorToRestore)
            {
                SetEntProp(victim, Prop_Send, "m_ArmorValue", armorToRestore);
            }
        }
    }

    if (g_bIncendiaryArmorRestorePending[victim])
    {
        int armorToRestore = g_iIncendiaryArmorRestoreValue[victim];
        int armorRestoreRound = g_iIncendiaryArmorRestoreRound[victim];
        g_bIncendiaryArmorRestorePending[victim] = false;
        g_iIncendiaryArmorRestoreValue[victim] = 0;
        g_iIncendiaryArmorRestoreRound[victim] = 0;
        if (IsPlayerAlive(victim) && armorRestoreRound == g_iRoundSerial &&
            armorToRestore > 0 && HasEntProp(victim, Prop_Send, "m_ArmorValue"))
        {
            int currentArmor = GetEntProp(victim, Prop_Send, "m_ArmorValue");
            if (currentArmor < armorToRestore)
            {
                SetEntProp(victim, Prop_Send, "m_ArmorValue", armorToRestore);
            }
        }
    }

    if (g_bThornsDamagePending[victim])
    {
        int thornsAttackerUserId = g_iThornsAttackerUserId[victim];
        int thornsHealthBefore = g_iThornsHealthBeforeDamage[victim];
        int thornsRound = g_iThornsDamageRound[victim];
        int thornsInflictorRef = g_iThornsInflictorRef[victim];
        g_bThornsDamagePending[victim] = false;
        g_iThornsAttackerUserId[victim] = 0;
        g_iThornsHealthBeforeDamage[victim] = 0;
        g_iThornsDamageRound[victim] = 0;
        g_iThornsInflictorRef[victim] = 0;

        int thornsAttacker = GetClientOfUserId(thornsAttackerUserId);
        int thornsTesla = (thornsInflictorRef != 0) ? EntRefToEntIndex(thornsInflictorRef) : -1;
        bool reflectToTesla = thornsTesla > MaxClients && thornsTesla < RSP_MAX_ENTITIES &&
            IsValidEntity(thornsTesla) && g_iBuildableType[thornsTesla] == RSP_BUILDABLE_TURRET &&
            g_iBuildableOwnerUserId[thornsTesla] == thornsAttackerUserId &&
            thornsAttacker >= 1 && thornsAttacker <= MaxClients && IsClientInGame(thornsAttacker) &&
            IsValidPlayingClient(thornsAttacker) && IsValidPlayingClient(victim) &&
            GetClientTeam(thornsAttacker) != GetClientTeam(victim);
        bool reflectToPlayer = !reflectToTesla && thornsAttacker >= 1 && thornsAttacker <= MaxClients &&
            thornsAttacker != victim && IsValidPlayingClient(thornsAttacker) &&
            IsPlayerAlive(thornsAttacker) && CanRSPApplyHitEffect(thornsAttacker, victim);
        int healthAfter = IsPlayerAlive(victim) ? GetClientHealth(victim) : 0;
        int actualHealthDamage = thornsHealthBefore - healthAfter;
        if (!g_bApplyingThornsDamage && g_bEnabled && g_bSupportedMap &&
            thornsRound == g_iRoundSerial && actualHealthDamage > 0 &&
            (reflectToTesla || reflectToPlayer))
        {
            g_fThornsReflectRemainder[victim] += float(actualHealthDamage) * RSP_THORNS_REFLECT_RATIO;
            int reflectedDamage = RoundToFloor(g_fThornsReflectRemainder[victim] + 0.0001);
            if (reflectedDamage > 0)
            {
                g_fThornsReflectRemainder[victim] -= float(reflectedDamage);
                g_bApplyingThornsDamage = true;
                if (reflectToTesla)
                {
                    // Tesla-origin damage reflects into the attacking turret, never its owner.
                    // The turret's own damage hook validates hostile-team damage and tracks HP.
                    SDKHooks_TakeDamage(thornsTesla, victim, victim, float(reflectedDamage),
                        DMG_GENERIC, -1, NULL_VECTOR, NULL_VECTOR, false);
                }
                else
                {
                    // Set death attribution before TakeDamage: CS:S can fire player_death
                    // synchronously inside SDKHooks_TakeDamage. Snapshot the Thorns owner's
                    // balance so the kill receives exactly +$300 regardless of held weapon.
                    int thornsOwnerCashBefore = -1;
                    if (HasEntProp(victim, Prop_Send, "m_iAccount"))
                    {
                        thornsOwnerCashBefore = GetEntProp(victim, Prop_Send, "m_iAccount");
                    }
                    else if (HasEntProp(victim, Prop_Data, "m_iAccount"))
                    {
                        thornsOwnerCashBefore = GetEntProp(victim, Prop_Data, "m_iAccount");
                    }

                    g_bThornsReflectedDeathPending[thornsAttacker] = true;
                    g_iThornsReflectedOwnerUserId[thornsAttacker] = GetClientUserId(victim);
                    g_iThornsReflectedDeathRound[thornsAttacker] = thornsRound;
                    g_iThornsReflectedOwnerCashBefore[thornsAttacker] = thornsOwnerCashBefore;
                    SDKHooks_TakeDamage(thornsAttacker, victim, victim, float(reflectedDamage), DMG_GENERIC);

                    // A surviving attacker cannot be killed later by this stale reflection marker.
                    if (IsPlayerAlive(thornsAttacker) && g_bThornsReflectedDeathPending[thornsAttacker])
                    {
                        g_bThornsReflectedDeathPending[thornsAttacker] = false;
                        g_iThornsReflectedOwnerUserId[thornsAttacker] = 0;
                        g_iThornsReflectedDeathRound[thornsAttacker] = 0;
                        g_iThornsReflectedOwnerCashBefore[thornsAttacker] = -1;
                    }
                }
                g_bApplyingThornsDamage = false;
            }
        }
    }

    int ownerUserId = g_iVampirismDamageAttackerUserId[victim];
    int healthBefore = g_iVampirismHealthBeforeDamage[victim];
    int damageRound = g_iVampirismDamageRound[victim];
    g_iVampirismDamageAttackerUserId[victim] = 0;
    g_iVampirismHealthBeforeDamage[victim] = 0;
    g_iVampirismDamageRound[victim] = 0;

    if (ownerUserId == 0 || damage <= 0.0 || !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive() ||
        damageRound != g_iRoundSerial || healthBefore <= 0)
    {
        return;
    }

    int owner = GetClientOfUserId(ownerUserId);
    if (owner < 1 || owner > MaxClients || owner == victim ||
        !IsValidPlayingClient(owner) || !IsPlayerAlive(owner) ||
        g_iPower[owner] != RSP_Dracula || GetClientTeam(owner) == GetClientTeam(victim))
    {
        return;
    }

    int healthAfter = IsPlayerAlive(victim) ? GetClientHealth(victim) : 0;
    int actualHealthDamage = healthBefore - healthAfter;
    if (actualHealthDamage <= 0)
    {
        return;
    }

    // Use the processed damage amount, not the victim's HP loss. This keeps
    // weapon overkill in the calculation (e.g. a 450-damage AWP hit) while
    // requiring that the hit actually removed health. Fractional healing is
    // rounded to whole HP; the signed remainder balances rounding over later hits.
    int maxHealth = RSP_DRACULA_MAX_HEALTH;
    int ownerHealth = GetClientHealth(owner);
    if (ownerHealth >= maxHealth)
    {
        g_fVampirismHealRemainder[owner] = 0.0;
        return;
    }

    float calculatedHeal = (damage * RSP_DRACULA_HEAL_MULTIPLIER) + g_fVampirismHealRemainder[owner];
    int heal = RoundToFloor(calculatedHeal + 0.5);
    float healRemainder = calculatedHeal - float(heal);
    if (heal < 1)
    {
        g_fVampirismHealRemainder[owner] = healRemainder;
        return;
    }

    int newHealth = ownerHealth + heal;
    if (newHealth > maxHealth)
    {
        newHealth = maxHealth;
    }
    if (newHealth > ownerHealth)
    {
        SetEntityHealth(owner, newHealth);
    }
    // Never bank excess healing while at the 200 HP cap.
    g_fVampirismHealRemainder[owner] = (newHealth >= maxHealth) ? 0.0 : healRemainder;
}

public void Frame_ClearTeslaDeathDissolvePending(any userid)
{
    int victim = GetClientOfUserId(userid);
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return;
    }

    // Keep the mark only if the Tesla shot actually killed the victim in this frame.
    if (IsPlayerAlive(victim))
    {
        if (g_bRagdollForcePending[victim] &&
            g_iRagdollForceRound[victim] == g_iRoundSerial &&
            g_fRagdollForceMultiplier[victim] == RSP_INVENTOR_TURRET_RAGDOLL_FORCE_MULTIPLIER)
        {
            StopRagdollForceHook(victim);
        }
        g_bTeslaRagdollDirectionValid[victim] = false;
        g_bTeslaDeathDissolvePending[victim] = false;
        g_iTeslaDeathDissolveRound[victim] = 0;
        g_fTeslaDeathDissolveTime[victim] = 0.0;
        g_iTeslaDeathOwnerUserId[victim] = 0;
        g_bTeslaHeadshotPending[victim] = false;
        g_iTeslaHeadshotRound[victim] = 0;
        g_fTeslaHeadshotTime[victim] = 0.0;
        ClearTeslaHitFeedback(victim);
    }
}

public void Frame_ClearBurnDeathPending(any userid)
{
    int victim = GetClientOfUserId(userid);
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return;
    }

    // If the victim is still alive, later damage may cause an unrelated death,
    // so clear the mark. If already dead, keep it until the pre player_death event
    // consumes it; frame callbacks can be ordered after engine death processing.
    if (IsPlayerAlive(victim))
    {
        g_bBurnDeathPending[victim] = false;
        g_iBurnDeathOwnerUserId[victim] = 0;
        g_iBurnDeathRound[victim] = 0;
    }
}

public void Frame_CorrectBurnFallbackScore(any victimUserId)
{
    int victim = GetClientOfUserId(victimUserId);
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim) || !g_bBurnScoreRepairPending[victim])
    {
        return;
    }

    int ownerUserId = g_iBurnScoreRepairOwnerUserId[victim];
    int victimTeam = g_iBurnScoreRepairVictimTeam[victim];
    bool undoVictimSuicide = g_bBurnVictimWasSuicide[victim];
    g_bBurnScoreRepairPending[victim] = false;
    g_iBurnScoreRepairOwnerUserId[victim] = 0;
    g_iBurnScoreRepairVictimTeam[victim] = 0;
    g_bBurnVictimWasSuicide[victim] = false;

    int owner = GetClientOfUserId(ownerUserId);
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner) || owner == victim)
    {
        return;
    }

    CorrectFlashFallbackScore(victim, owner, victimTeam, undoVictimSuicide);
}

public void Frame_ClearZombieLethalPending(any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    // Event_PlayerDeath sets g_bZombieUsedThisRound and schedules the real respawn.
    // If it did not happen, this was not a completed death and the guard must clear.
    if (!g_bZombieUsedThisRound[client] && g_iPower[client] == RSP_Zombie)
    {
        g_bZombieRespawnPending[client] = false;
        g_iZombieRespawnRound[client] = 0;
    }
}

bool IsClientHoldingKnife(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))
    {
        return false;
    }

    char weapon[64];
    GetClientWeapon(client, weapon, sizeof(weapon));
    return StrEqual(weapon, "weapon_knife", false);
}

public void Frame_ApplyKnockup(any userid)
{
    int victim = GetClientOfUserId(userid);
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive() ||
        victim < 1 || victim > MaxClients || !IsClientInGame(victim) || !IsPlayerAlive(victim) ||
        !IsValidPlayingClient(victim) || g_iAssignedRound[victim] != g_iRoundSerial ||
        GetEntityMoveType(victim) == MOVETYPE_NOCLIP)
    {
        return;
    }

    float velocity[3];
    GetEntPropVector(victim, Prop_Data, "m_vecVelocity", velocity);
    // Keep horizontal movement unchanged and apply a consistent vertical launch.
    // 416 Source units/s is approximately two normal CS:S jump heights.
    velocity[2] = RSP_KNOCKUP_VERTICAL_SPEED;
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, velocity);
}

void ClearToxicAmmoEffect(int target)
{
    if (target < 1 || target > MaxClients)
    {
        return;
    }
    if (g_hToxicAmmoTimer[target] != null)
    {
        delete g_hToxicAmmoTimer[target];
        g_hToxicAmmoTimer[target] = null;
    }
    g_bToxicAmmoActive[target] = false;
    g_iToxicAmmoRound[target] = 0;
    g_iToxicAmmoStacks[target] = 0;
}

void ClearAllToxicAmmoEffects()
{
    for (int target = 1; target <= MaxClients; target++)
    {
        ClearToxicAmmoEffect(target);
    }
}

bool ApplyToxicAmmoEffect(int target)
{
    if (target < 1 || target > MaxClients || !IsValidPlayingClient(target) ||
        !IsPlayerAlive(target) || !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        return false;
    }

    // Every firearm hit adds one poison stack, but does not reset the tick schedule.
    // The timer is stored on the victim (not the shooter), so shooter death/disconnect
    // cannot cancel it. An overflow-safe ceiling is far beyond any practical round.
    if (g_bToxicAmmoActive[target] && g_iToxicAmmoRound[target] == g_iRoundSerial &&
        g_hToxicAmmoTimer[target] != null)
    {
        int maximumSafeStacks = 2147483647 / RSP_VIPER_DAMAGE;
        if (g_iToxicAmmoStacks[target] < maximumSafeStacks)
        {
            g_iToxicAmmoStacks[target]++;
        }
        return true;
    }

    ClearToxicAmmoEffect(target);
    g_bToxicAmmoActive[target] = true;
    g_iToxicAmmoRound[target] = g_iRoundSerial;
    g_iToxicAmmoStacks[target] = 1;
    g_hToxicAmmoTimer[target] = CreateTimer(RSP_VIPER_INTERVAL, Timer_ToxicAmmoTick,
        GetClientUserId(target), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    if (g_hToxicAmmoTimer[target] == null)
    {
        g_bToxicAmmoActive[target] = false;
        g_iToxicAmmoRound[target] = 0;
        g_iToxicAmmoStacks[target] = 0;
        return false;
    }
    return true;
}

public Action Timer_ToxicAmmoTick(Handle timer, any userid)
{
    int target = GetClientOfUserId(userid);
    if (target < 1 || target > MaxClients || !IsClientInGame(target))
    {
        return Plugin_Stop;
    }
    if (g_hToxicAmmoTimer[target] != timer)
    {
        return Plugin_Stop;
    }
    if (!IsPlayerAlive(target))
    {
        // Let the timer return Plugin_Stop naturally; do not delete its own handle
        // while the callback is executing.
        g_hToxicAmmoTimer[target] = null;
        g_bToxicAmmoActive[target] = false;
        g_iToxicAmmoRound[target] = 0;
        g_iToxicAmmoStacks[target] = 0;
        return Plugin_Stop;
    }
    if (!g_bToxicAmmoActive[target] || g_iToxicAmmoRound[target] != g_iRoundSerial ||
        !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        g_hToxicAmmoTimer[target] = null;
        g_bToxicAmmoActive[target] = false;
        g_iToxicAmmoRound[target] = 0;
        g_iToxicAmmoStacks[target] = 0;
        return Plugin_Stop;
    }

    // The effect belongs to the victim and persists through the shooter's death.
    // A victim death or respawn clears all stacks; the timer also self-clears if the
    // victim is no longer alive. Poison itself can never kill: health is clamped to 1.
    if (IsPlayerAlive(target))
    {
        int health = GetClientHealth(target);
        if (health > 1)
        {
            int stacks = g_iToxicAmmoStacks[target];
            if (stacks < 1)
            {
                stacks = 1;
            }
            int tickDamage = stacks * RSP_VIPER_DAMAGE;
            // Use the same native damage pipeline as Toxic Smoke: CS:S generates its
            // normal player_hurt/damage feedback. Cap the input to current HP - 1 so
            // this power itself cannot deliver a lethal poison tick.
            int safeDamage = health - 1;
            if (safeDamage > tickDamage)
            {
                safeDamage = tickDamage;
            }
            if (safeDamage > 0)
            {
                // Viper bypasses armor, but must not consume or permanently alter it.
                int savedArmor = -1;
                if (HasEntProp(target, Prop_Send, "m_ArmorValue"))
                {
                    savedArmor = GetEntProp(target, Prop_Send, "m_ArmorValue");
                    if (savedArmor > 0)
                    {
                        SetEntProp(target, Prop_Send, "m_ArmorValue", 0);
                    }
                }

                SDKHooks_TakeDamage(target, 0, 0, float(safeDamage), DMG_POISON);

                if (savedArmor >= 0 && IsClientInGame(target) && HasEntProp(target, Prop_Send, "m_ArmorValue"))
                {
                    SetEntProp(target, Prop_Send, "m_ArmorValue", savedArmor);
                }
            }
        }
    }
    return Plugin_Continue;
}

bool GetRSPAccountValue(int client, int &amount)
{
    amount = 0;
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return false;
    }
    if (HasEntProp(client, Prop_Send, "m_iAccount"))
    {
        amount = GetEntProp(client, Prop_Send, "m_iAccount");
        return true;
    }
    if (HasEntProp(client, Prop_Data, "m_iAccount"))
    {
        amount = GetEntProp(client, Prop_Data, "m_iAccount");
        return true;
    }
    return false;
}

public void Hook_RobinHoodDamageAlivePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive() || damage <= 0.0 ||
        victim < 1 || victim > MaxClients || attacker < 1 || attacker > MaxClients ||
        victim == attacker || !IsClientInGame(victim) || !IsClientInGame(attacker) ||
        GetClientTeam(victim) < CS_TEAM_T || GetClientTeam(victim) > CS_TEAM_CT ||
        GetClientTeam(attacker) < CS_TEAM_T || GetClientTeam(attacker) > CS_TEAM_CT ||
        GetClientTeam(victim) == GetClientTeam(attacker) ||
        g_iPower[attacker] != RSP_RobinHood ||
        (g_iAssignedRound[attacker] != g_iRoundSerial && !g_bHostPowerGrantedOutsideRound[attacker]))
    {
        return;
    }

    // Robin Hood transfers exactly $10 per point of applied damage, rounded only to
    // whole dollars. A single computed amount is used for both balances; no per-hit $50
    // bucket rounding can make the displayed transfer feel inconsistent with damage.
    int transfer = RoundToNearest(damage * 10.0);
    if (transfer <= 0)
    {
        return;
    }

    int victimCash, attackerCash;
    if (!GetRSPAccountValue(victim, victimCash) || !GetRSPAccountValue(attacker, attackerCash))
    {
        return;
    }

    int maxMoney = 16000;
    if (g_hMpMaxMoney != null && g_hMpMaxMoney.IntValue > 0)
    {
        maxMoney = g_hMpMaxMoney.IntValue;
    }
    int walletSpace = maxMoney - attackerCash;
    if (walletSpace <= 0 || victimCash <= 0)
    {
        return;
    }
    if (transfer > victimCash)
    {
        transfer = victimCash;
    }
    if (transfer > walletSpace)
    {
        transfer = walletSpace;
    }
    if (transfer <= 0)
    {
        return;
    }

    // Treat the debit + credit as one logical transaction. Confirm the two replicated
    // balances after both writes; if either side does not match the same transfer amount,
    // restore both original balances instead of leaving a partial/mismatched transfer.
    int expectedVictimCash = victimCash - transfer;
    int expectedAttackerCash = attackerCash + transfer;
    if (!SetRSPAccount(victim, expectedVictimCash))
    {
        return;
    }
    if (!SetRSPAccount(attacker, expectedAttackerCash))
    {
        SetRSPAccount(victim, victimCash);
        return;
    }

    int verifiedVictimCash = -1;
    int verifiedAttackerCash = -1;
    bool victimMatches = GetRSPAccountValue(victim, verifiedVictimCash) &&
        verifiedVictimCash == expectedVictimCash;
    bool attackerMatches = GetRSPAccountValue(attacker, verifiedAttackerCash) &&
        verifiedAttackerCash == expectedAttackerCash;
    if (!victimMatches || !attackerMatches)
    {
        SetRSPAccount(attacker, attackerCash);
        SetRSPAccount(victim, victimCash);
    }
}

bool IsRSPWeakeningAmmoActive(int client, float now = -1.0)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        g_iWeakeningRound[client] != g_iRoundSerial || g_fWeakeningUntil[client] <= 0.0)
    {
        return false;
    }
    if (now < 0.0) now = GetGameTime();
    return g_fWeakeningUntil[client] > now;
}

float GetWeakeningBaseMovementValue(int client)
{
    if (g_iPower[client] == RSP_SpeedDemon && g_iAssignedRound[client] == g_iRoundSerial &&
        g_bOldMoveSpeedValid[client] && g_fSpeedBonus[client] >= RSP_SPEED_DEMON_MIN &&
        g_fSpeedBonus[client] <= RSP_SPEED_DEMON_MAX)
    {
        return g_fOldMoveSpeed[client] * g_fSpeedBonus[client];
    }
    if (g_iPower[client] == RSP_Berserker && g_iAssignedRound[client] == g_iRoundSerial &&
        g_bOldMoveSpeedValid[client])
    {
        float multiplier = (GetClientHealth(client) > 0 && GetClientHealth(client) <= RSP_BERSERKER_TRIGGER_HP)
            ? RSP_BERSERKER_SPEED_MULTIPLIER : 1.0;
        return g_fOldMoveSpeed[client] * multiplier;
    }
    if (g_bWeakeningBaseMovementValid[client])
    {
        return g_fWeakeningBaseMovementValue[client];
    }
    if (g_bOldMoveSpeedValid[client] && g_bMoveSpeedStateSaved[client])
    {
        return g_fOldMoveSpeed[client];
    }
    if (HasEntProp(client, Prop_Data, "m_flLaggedMovementValue"))
    {
        return GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
    }
    return 1.0;
}

float GetWeakeningSpeedScale()
{
    // m_flLaggedMovementValue is a multiplier in CS:S. Applying 0.50 to the already
    // composed baseline halves the target's effective movement speed, including their
    // rolled Speed Demon multiplier, instead of subtracting a fixed units-per-second value.
    return RSP_CRIPPLER_SPEED_MULTIPLIER;
}

void ClearWeakeningAmmoState(int client, bool restoreMovement)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }
    if (restoreMovement && IsClientInGame(client) &&
        g_bWeakeningBaseMovementValid[client] && HasEntProp(client, Prop_Data, "m_flLaggedMovementValue"))
    {
        float baseSpeed = GetWeakeningBaseMovementValue(client);
        if (baseSpeed > 0.0)
        {
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", baseSpeed);
        }
    }
    g_fWeakeningUntil[client] = 0.0;
    g_iWeakeningRound[client] = 0;
    g_iWeakeningOwnerUserId[client] = 0;
    g_fWeakeningBaseMovementValue[client] = 1.0;
    g_bWeakeningBaseMovementValid[client] = false;
}

void ApplyWeakeningAmmoEffect(int victim, float now, int attacker)
{
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim) || !IsPlayerAlive(victim))
    {
        return;
    }

    bool alreadyActive = IsRSPWeakeningAmmoActive(victim, now);
    if (!alreadyActive)
    {
        // If an expired effect has not yet received a user command to restore speed,
        // clear it first so a new hit never captures an already-slowed scalar.
        UpdateWeakeningMovementState(victim, now);
        g_bWeakeningBaseMovementValid[victim] = HasEntProp(victim, Prop_Data, "m_flLaggedMovementValue");
        if (g_bWeakeningBaseMovementValid[victim])
        {
            g_fWeakeningBaseMovementValue[victim] = GetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue");
        }
        else
        {
            g_fWeakeningBaseMovementValue[victim] = 1.0;
        }
    }

    g_fWeakeningUntil[victim] = now + RSP_CRIPPLER_DURATION;
    g_iWeakeningRound[victim] = g_iRoundSerial;
    g_iWeakeningOwnerUserId[victim] = GetClientUserId(attacker);
    UpdateWeakeningMovementState(victim, now);
}

void UpdateWeakeningMovementState(int client, float now)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) ||
        !HasEntProp(client, Prop_Data, "m_flLaggedMovementValue"))
    {
        return;
    }

    bool active = g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive() &&
        IsRSPWeakeningAmmoActive(client, now);
    if (active)
    {
        float baseSpeed = GetWeakeningBaseMovementValue(client);
        float desiredSpeed = baseSpeed * GetWeakeningSpeedScale();
        if (desiredSpeed < 0.1) desiredSpeed = 0.1;
        float currentSpeed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
        if (FloatAbs(currentSpeed - desiredSpeed) > 0.005)
        {
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", desiredSpeed);
        }
    }
    else if (g_fWeakeningUntil[client] != 0.0 || g_bWeakeningBaseMovementValid[client])
    {
        float baseSpeed = GetWeakeningBaseMovementValue(client);
        if (baseSpeed > 0.0)
        {
            float currentSpeed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
            if (FloatAbs(currentSpeed - baseSpeed) > 0.005)
            {
                SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", baseSpeed);
            }
        }
        ClearWeakeningAmmoState(client, false);
    }
}

public Action Hook_TraceAttack(int victim, int &attacker, int &inflictor, float &damage,
    int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive() ||
        victim < 1 || victim > MaxClients || attacker < 1 || attacker > MaxClients ||
        victim == attacker || !IsClientInGame(victim) || !IsClientInGame(attacker) ||
        !IsPlayerAlive(victim) || !IsPlayerAlive(attacker))
    {
        return Plugin_Continue;
    }

    if (g_bSpectatorActive[victim] || g_bSpectatorActive[attacker])
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    // God Mode takes priority over Executioner, Machete and all hit-triggered secondary powers.
    // Do not queue deferred kill fallbacks or status effects against an invulnerable target.
    if (IsRSPGodModeActive(victim))
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    // Make an active Noclip player damageable before CS:S finishes the trace attack.
    // The normal movement type is restored by OnTakeDamagePost or the queued frame.
    if (damage > 0.0)
    {
        PrepareNoclipVictimForDamage(victim);
    }

    if (damage > 0.0 && IsRSPMacheteMeleeHit(attacker, victim, inflictor, damagetype))
    {
        damage = float(GetClientHealth(victim) + 50000);
        return Plugin_Changed;
    }

    if ((damagetype & DMG_BULLET) == 0 && (damagetype & DMG_BUCKSHOT) == 0)
    {
        return Plugin_Continue;
    }

    char attackerWeapon[64];
    GetClientWeapon(attacker, attackerWeapon, sizeof(attackerWeapon));
    bool attackerUsingFirearm = IsRSPFirearmEventWeapon(attackerWeapon);
    bool canApplyHitEffects = CanRSPApplyHitEffect(attacker, victim);

    if (damage > 0.0 && g_iPower[victim] == RSP_Blademaster &&
        g_iAssignedRound[victim] == g_iRoundSerial &&
        canApplyHitEffects && IsClientHoldingKnife(victim) &&
        GetRandomInt(1, 100) <= RSP_BLADEMASTER_DEFLECT_CHANCE)
    {
        // Zero this firearm trace before hit-triggered powers can react to it.
        damage = 0.0;
        return Plugin_Changed;
    }

    // Count actual bullet traces against living enemy players for the selected Curser target.
    // Compare with the weapon_fire snapshot to avoid ambiguous timestamp windows.
    int attackerTeam = GetClientTeam(attacker);
    if (GetClientTeam(victim) == attackerTeam && g_iExpensiveAmmoOwnerUserId[attacker] != 0 &&
        g_iExpensiveAmmoRound[attacker] == g_iRoundSerial)
    {
        g_iLastFriendlyTraceTick[attacker] = GetGameTickCount();
    }
    if (GetClientTeam(victim) != attackerTeam && attackerTeam >= CS_TEAM_T && attackerTeam <= CS_TEAM_CT &&
        g_bCurserTargetCursed[attacker] && g_iCurserTargetCurseRound[attacker] == g_iRoundSerial)
    {
        g_iCurserEnemyHitCounter[attacker]++;
    }

    // Offensive hit-triggered powers may affect a teammate only when mp_friendlyfire is enabled.
    // Immunity to bullet zones blocks direct damage, not these secondary effects.
    if (canApplyHitEffects)
    {
        float now = GetGameTime();
        if (damage > 0.0 && attackerUsingFirearm && g_iPower[attacker] == RSP_Viper &&
            g_iAssignedRound[attacker] == g_iRoundSerial)
        {
            ApplyToxicAmmoEffect(victim);
        }

        // Crippler has no chance roll: every eligible firearm hit refreshes
        // the same short debuff, independent of the target's distance or hitgroup.
        if (damage > 0.0 && attackerUsingFirearm && g_iPower[attacker] == RSP_Crippler &&
            g_iAssignedRound[attacker] == g_iRoundSerial)
        {
            ApplyWeakeningAmmoEffect(victim, now, attacker);
        }

        if (damage > 0.0 && attackerUsingFirearm &&
            g_iPower[attacker] == RSP_Concussion &&
            g_iAssignedRound[attacker] == g_iRoundSerial &&
            GetRandomInt(1, 100) <= g_iConcussionChancePercent[attacker])
        {
            ApplyConcussionFlash(victim, attacker);
        }

        if (g_iPower[attacker] == RSP_FreezingAmmo && now >= g_fFrozenUntil[victim])
        {
            int chancePercent = g_iCryoChancePercent[attacker];
            if (!IsValidCryoChancePercent(chancePercent))
                chancePercent = 30;
            if (GetRandomInt(1, 100) <= chancePercent)
            {
                g_fFrozenUntil[victim] = now + RSP_FREEZING_AMMO_DURATION;
                g_iCryoOwnerUserId[victim] = GetClientUserId(attacker);
            }
        }

        if (g_iPower[attacker] == RSP_Disorient && now >= g_fNextDisorientTime[victim])
        {
            int chancePercent = g_iDisorientChancePercent[attacker];
            if (!IsValidDisorientChancePercent(chancePercent))
                chancePercent = 30;
            if (GetRandomInt(1, 100) <= chancePercent)
            {
                float victimAngles[3];
                GetClientEyeAngles(victim, victimAngles);
                float targetYaw = victimAngles[1] + 180.0;
                if (targetYaw > 180.0)
                {
                    targetYaw -= 360.0;
                }
                else if (targetYaw < -180.0)
                {
                    targetYaw += 360.0;
                }
                victimAngles[1] = targetYaw;
                victimAngles[2] = 0.0;
                TeleportEntity(victim, NULL_VECTOR, victimAngles, NULL_VECTOR);
                g_fDisorientTargetYaw[victim] = targetYaw;
                g_fDisorientViewUntil[victim] = now + RSP_DISORIENT_VIEW_TIMEOUT;
                g_iDisorientOwnerUserId[victim] = GetClientUserId(attacker);
                g_fNextDisorientTime[victim] = now + RSP_DISORIENT_COOLDOWN;
            }
        }

        if (damage > 0.0 && g_iPower[attacker] == RSP_Knockup)
        {
            int chancePercent = g_iKnockupChancePercent[attacker];
            if (chancePercent < RSP_KNOCKUP_CHANCE_MIN || chancePercent > RSP_KNOCKUP_CHANCE_MAX)
                chancePercent = RSP_KNOCKUP_CHANCE_MIN;
            if (GetRandomInt(1, 100) <= chancePercent)
            {
                RequestFrame(Frame_ApplyKnockup, GetClientUserId(victim));
            }
        }
    }

    // Disarmament is a hit-triggered secondary power, not damage. Evaluate it
    // before damage-immunity branches so Steel Head/Juggernaut cannot suppress it.
    int disarmChancePercent = g_iDisarmChancePercent[attacker];
    if (!IsValidDisarmChancePercent(disarmChancePercent))
    {
        disarmChancePercent = 30;
    }
    if (g_iPower[attacker] == RSP_Disarmament && canApplyHitEffects && !g_bDisarmPending[victim] &&
        GetRandomInt(1, 100) <= disarmChancePercent)
    {
        int activeWeapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
        int primary = GetPlayerWeaponSlot(victim, 0);
        int secondary = GetPlayerWeaponSlot(victim, 1);
        if (activeWeapon > MaxClients && IsValidEntity(activeWeapon) &&
            (activeWeapon == primary || activeWeapon == secondary))
        {
            g_bDisarmPending[victim] = true;
            g_iPendingDropWeaponRef[victim] = EntIndexToEntRef(activeWeapon);
            RequestFrame(Frame_DisarmVictim, GetClientUserId(victim));
        }
    }

    // Fire is a secondary effect of the hit, independent of damage immunity.
    // Juggernaut / Steel Head may block the bullet damage but must not cancel ignition.
    if (g_iPower[attacker] == RSP_IncendiaryAmmo && canApplyHitEffects)
    {
        // IgniteEntity has no attacker parameter in CS:S. Keep a short, per-victim
        // ownership record so native burn ticks can be credited to this shooter.
        float burnStart = GetGameTime();
        g_iBurnOwnerUserId[victim] = GetClientUserId(attacker);
        g_iBurnOwnerRound[victim] = g_iRoundSerial;
        g_fBurnOwnerUntil[victim] = burnStart + RSP_INCENDIARY_AMMO_DURATION + 1.0;
        IgniteEntity(victim, RSP_INCENDIARY_AMMO_DURATION);
    }

    // Friendly Fire belongs to the shooter: a firearm hit heals the teammate for 5%
    // of its expected body-hit damage and cancels the shot. CS:S applies hitgroup scaling
    // after this hook, so calculate it here; head hits deliberately use the stomach (1.25x)
    // multiplier rather than the much larger headshot multiplier. Round each hit normally:
    // below .5 HP rounds down; .5 HP and above rounds up. No fraction carries to later hits.
    // Healing is intentionally not capped at m_iMaxHealth; keep only integer-overflow protection.
    if (g_iPower[attacker] == RSP_FriendlyFire &&
        g_iAssignedRound[attacker] == g_iRoundSerial &&
        GetClientTeam(attacker) == GetClientTeam(victim))
    {
        if (damage > 0.0)
        {
            int healHitgroup = (hitgroup == 1) ? 3 : hitgroup;
            float hitgroupMultiplier = GetRSPHitgroupMultiplier(healHitgroup);
            if (hitgroupMultiplier > 0.0)
            {
                float pendingHeal = damage * hitgroupMultiplier * RSP_FRIENDLY_FIRE_HEAL_RATIO;
                // Avoid converting an out-of-range float to int; realistic CS:S weapon hits are far below this guard.
                if (pendingHeal > 0.0 && pendingHeal < 2147483520.0)
                {
                    int healAmount = RoundToFloor(pendingHeal + 0.5);
                    if (healAmount > 0)
                    {
                        int health = GetClientHealth(victim);
                        // Do not impose the game's normal max-HP cap; only prevent signed-int overflow.
                        if (health > 0 && health < 2147483647 && healAmount <= 2147483647 - health)
                        {
                            SetEntityHealth(victim, health + healAmount);
                        }
                    }
                }
            }
        }
        damage = 0.0;
        return Plugin_Changed;
    }

    // Aimbot firearm hits are treated as headshots for Steel Head protection even when
    // the physical trace hit the body: the power's damage/killfeed semantics emulate a headshot.
    // Juggernaut remains a physical body-hit defense, so real body hitgroups are still blocked.
    bool physicalHeadshot = (hitgroup == 1);
    bool aimbotFirearmHit = attackerUsingFirearm && g_iPower[attacker] == RSP_Aimbot &&
        g_iAssignedRound[attacker] == g_iRoundSerial && canApplyHitEffects;
    bool countsAsSteelHeadHit = physicalHeadshot || aimbotFirearmHit;
    if ((g_iPower[victim] == RSP_SteelHead && countsAsSteelHeadHit) ||
        (g_iPower[victim] == RSP_Juggernaut && !physicalHeadshot))
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    // Executioner cannot bypass protected hit zones or server friendly-fire settings.
    if (g_iPower[attacker] == RSP_Executioner && canApplyHitEffects)
    {
        float executionerDamage = GetExecutionerLethalDamage(victim);
        float hitgroupMultiplier = GetRSPHitgroupMultiplier(hitgroup);
        if (hitgroupMultiplier < 0.1)
        {
            hitgroupMultiplier = 1.0;
        }
        // TraceAttack runs before CS:S applies its native hitgroup multiplier.
        // Normalize here so a headshot doesn't generate 4x overkill/stat values.
        damage = executionerDamage / hitgroupMultiplier;
        QueueExecutionerGuaranteedKill(victim, attacker);
        return Plugin_Changed;
    }

    bool damageModified = false;
    if (damage > 0.0 && aimbotFirearmHit && !physicalHeadshot)
    {
        float hitgroupMultiplier = GetRSPHitgroupMultiplier(hitgroup);
        if (hitgroupMultiplier > 0.0)
        {
            // CS:S applies hitgroup scaling after TraceAttack. Normalize here so the
            // final damage equals a real headshot irrespective of the physical body hitgroup.
            damage *= 4.0 / hitgroupMultiplier;
            damageModified = true;
        }
    }

    return damageModified ? Plugin_Changed : Plugin_Continue;
}

float GetRSPHitgroupMultiplier(int hitgroup)
{
    switch (hitgroup)
    {
        case 1: return 4.0;   // head
        case 3: return 1.25;  // stomach
        case 6, 7: return 0.75; // legs
        default: return 1.0;  // chest and arms
    }
}

void ClearTeslaHitFeedback(int victim)
{
    if (victim < 1 || victim > MaxClients)
    {
        return;
    }
    g_bTeslaHitFeedbackPending[victim] = false;
    g_iTeslaHitFeedbackOwnerUserId[victim] = 0;
    g_iTeslaHitFeedbackRound[victim] = 0;
    g_iTeslaHitFeedbackHitgroup[victim] = 0;
    g_fTeslaHitFeedbackTime[victim] = 0.0;
}

void MarkTeslaHitFeedback(int victim, int owner, bool headshot)
{
    if (victim < 1 || victim > MaxClients || owner < 1 || owner > MaxClients ||
        !IsClientInGame(victim) || !IsClientInGame(owner))
    {
        return;
    }
    g_bTeslaHitFeedbackPending[victim] = true;
    g_iTeslaHitFeedbackOwnerUserId[victim] = GetClientUserId(owner);
    g_iTeslaHitFeedbackRound[victim] = g_iRoundSerial;
    // CS:S client hit-confirmation sounds follow player_hurt.hitgroup. Tesla is a
    // direct SDKHooks damage call, so write the intended group explicitly: head only
    // for Tesla's rolled headshot; chest for its normal non-headshot hit.
    g_iTeslaHitFeedbackHitgroup[victim] = headshot ? 1 : 2;
    g_fTeslaHitFeedbackTime[victim] = GetGameTime();
    g_iTeslaHitFeedbackSerial[victim]++;
    if (g_iTeslaHitFeedbackSerial[victim] <= 0)
    {
        g_iTeslaHitFeedbackSerial[victim] = 1;
    }

    DataPack clearPack;
    Handle clearTimer = CreateDataTimer(0.12, Timer_ClearTeslaHitFeedback, clearPack,
        TIMER_FLAG_NO_MAPCHANGE);
    if (clearTimer != null)
    {
        clearPack.WriteCell(GetClientUserId(victim));
        clearPack.WriteCell(g_iTeslaHitFeedbackSerial[victim]);
    }
    else
    {
        ClearTeslaHitFeedback(victim);
    }
}

public Action Timer_ClearTeslaHitFeedback(Handle timer, DataPack pack)
{
    pack.Reset();
    int userId = pack.ReadCell();
    int serial = pack.ReadCell();
    int victim = GetClientOfUserId(userId);
    if (victim >= 1 && victim <= MaxClients && IsClientInGame(victim) &&
        g_iTeslaHitFeedbackSerial[victim] == serial)
    {
        ClearTeslaHitFeedback(victim);
    }
    return Plugin_Stop;
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        return Plugin_Continue;
    }

    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));
    char hurtWeapon[32];
    event.GetString("weapon", hurtWeapon, sizeof(hurtWeapon));
    if (attacker < 1 || attacker > MaxClients || victim < 1 || victim > MaxClients ||
        !IsClientInGame(attacker) || !IsClientInGame(victim) || attacker == victim)
    {
        return Plugin_Continue;
    }

    bool changedHitFeedback = false;
    if (g_bTeslaHitFeedbackPending[victim] &&
        g_iTeslaHitFeedbackRound[victim] == g_iRoundSerial &&
        g_iTeslaHitFeedbackOwnerUserId[victim] == GetClientUserId(attacker) &&
        GetGameTime() - g_fTeslaHitFeedbackTime[victim] >= 0.0 &&
        GetGameTime() - g_fTeslaHitFeedbackTime[victim] <= 0.12)
    {
        event.SetInt("hitgroup", g_iTeslaHitFeedbackHitgroup[victim]);
        ClearTeslaHitFeedback(victim);
        changedHitFeedback = true;
    }

    if (g_iPower[attacker] == RSP_Leech && g_iAssignedRound[attacker] == g_iRoundSerial &&
        g_iLeechChancePercent[attacker] >= RSP_LEECH_CHANCE_MIN &&
        g_iLeechChancePercent[attacker] <= RSP_LEECH_CHANCE_MAX &&
        IsRSPFirearmEventWeapon(hurtWeapon) && IsPlayerAlive(victim) &&
        CanRSPApplyHitEffect(attacker, victim) &&
        GetRandomInt(1, 100) <= g_iLeechChancePercent[attacker])
    {
        ApplyLeechAmmoTransfer(attacker, victim);
    }

    // CSS knife damage can bypass the weapon-based path used by the main damage hook.
    // If the victim survived a hit registered as a knife strike, finish the kill next frame
    // with the original attacker as the damage owner; don't alter the already-fatal case.
    if (g_iPower[attacker] == RSP_Machete &&
        (StrEqual(hurtWeapon, "knife", false) || StrEqual(hurtWeapon, "weapon_knife", false)) &&
        IsPlayerAlive(victim) && CanRSPApplyHitEffect(attacker, victim))
    {
        g_iMachetePendingAttackerUserId[victim] = GetClientUserId(attacker);
        g_iMachetePendingRound[victim] = g_iRoundSerial;
        RequestFrame(Frame_EnforceMacheteKill, GetClientUserId(victim));
        return changedHitFeedback ? Plugin_Changed : Plugin_Continue;
    }

    if (!changedHitFeedback && g_iPower[attacker] == RSP_Aimbot &&
        g_iAssignedRound[attacker] == g_iRoundSerial &&
        IsRSPFirearmEventWeapon(hurtWeapon) && event.GetInt("hitgroup") != 1)
    {
        // player_hurt's hitgroup drives client-side hit feedback. Damage was already
        // normalized in TraceAttack; rewrite only body-hit metadata, not actual damage.
        event.SetInt("hitgroup", 1);
        return Plugin_Changed;
    }

    return changedHitFeedback ? Plugin_Changed : Plugin_Continue;
}

public void Frame_EnforceMacheteKill(any victimUserId)
{
    int victim = GetClientOfUserId(victimUserId);
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return;
    }

    int attackerUserId = g_iMachetePendingAttackerUserId[victim];
    int pendingRound = g_iMachetePendingRound[victim];
    g_iMachetePendingAttackerUserId[victim] = 0;
    g_iMachetePendingRound[victim] = 0;

    if (attackerUserId == 0 || pendingRound != g_iRoundSerial || !IsPlayerAlive(victim))
    {
        return;
    }
    int attacker = GetClientOfUserId(attackerUserId);
    if (attacker < 1 || attacker > MaxClients || !IsClientInGame(attacker) ||
        !CanRSPApplyHitEffect(attacker, victim))
    {
        return;
    }

    SDKHooks_TakeDamage(victim, attacker, attacker,
        float(GetClientHealth(victim) + 50000), DMG_SLASH);
}

// All successful Executioner hit paths use the same deferred kill guarantee. The
// initial engine damage normally kills natively; if HP/armor changed between the
// hit hook and damage application, this next-frame check recalculates lethal damage
// and retains ForcePlayerSuicide as the final fallback only when TakeDamage fails.
void QueueExecutionerGuaranteedKill(int victim, int attacker)
{
    if (victim < 1 || victim > MaxClients || attacker < 1 || attacker > MaxClients ||
        victim == attacker || !IsClientInGame(victim) || !IsClientInGame(attacker) ||
        !IsPlayerAlive(victim))
    {
        return;
    }

    g_iExecutionerPendingAttackerUserId[victim] = GetClientUserId(attacker);
    RequestFrame(Frame_EnforceExecutionerKill, GetClientUserId(victim));
}

// Projectile owners can disconnect between throwing an HE and its explosion. Keep
// the pending userid when possible so the deferred guarantee still executes; if the
// userid no longer resolves, the frame fallback can force the accepted kill without
// inventing a different attacker.
void QueueExecutionerGuaranteedKillByUserId(int victim, int attackerUserId)
{
    if (victim < 1 || victim > MaxClients || attackerUserId == 0 ||
        !IsClientInGame(victim) || !IsPlayerAlive(victim))
    {
        return;
    }

    int attacker = GetClientOfUserId(attackerUserId);
    if (attacker >= 1 && attacker <= MaxClients && IsClientInGame(attacker) && attacker != victim)
    {
        QueueExecutionerGuaranteedKill(victim, attacker);
        return;
    }

    g_iExecutionerPendingAttackerUserId[victim] = attackerUserId;
    RequestFrame(Frame_EnforceExecutionerKill, GetClientUserId(victim));
}

public void Frame_EnforceExecutionerKill(any victimUserId)
{
    int victim = GetClientOfUserId(victimUserId);
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return;
    }

    int attackerUserId = g_iExecutionerPendingAttackerUserId[victim];
    g_iExecutionerPendingAttackerUserId[victim] = 0;
    if (attackerUserId == 0 || !IsPlayerAlive(victim))
    {
        // The original hit already killed the target (or its pending record was
        // cleared by death cleanup). Never act on a later respawn.
        return;
    }

    int attacker = GetClientOfUserId(attackerUserId);
    bool hasAttacker = attacker >= 1 && attacker <= MaxClients &&
        IsClientInGame(attacker) && attacker != victim;

    // The damage hook already accepted this hit after checking God Mode, protected
    // hit zones and friendly-fire rules. Do not repeat those checks on the next frame:
    // teams/settings/HP can change between the accepted hit and this guarantee.
    if (hasAttacker)
    {
        float lethalDamage = GetExecutionerLethalDamage(victim);
        SDKHooks_TakeDamage(victim, attacker, attacker, lethalDamage, DMG_BULLET);
        if (!IsClientInGame(victim) || !IsPlayerAlive(victim))
        {
            return;
        }

        // The victim survived the recalculated lethal damage, so another plugin may
        // have canceled/overridden damage or HP may be changing unusually. Force the
        // accepted Executioner kill while preserving attacker attribution in death.
        g_iExecutionerPendingAttackerUserId[victim] = attackerUserId;
        g_bExecutionerSuicideFallbackPending[victim] = true;
        ForcePlayerSuicide(victim);
        return;
    }

    // The original attacker disconnected after the hit was accepted. We can no longer
    // credit a live attacker entity, but still guarantee the death rather than leaving
    // the victim alive because GetClientOfUserId() failed between frames.
    g_bExecutionerSuicideFallbackPending[victim] = false;
    ForcePlayerSuicide(victim);
}

public void Hook_WeaponEquipPost(int client, int weapon)
{
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive() ||
        client < 1 || client > MaxClients || !IsClientInGame(client) ||
        weapon <= MaxClients || weapon >= RSP_MAX_ENTITIES || !IsValidEntity(weapon))
    {
        return;
    }

    if (g_iPower[client] == RSP_Ghost)
    {
        TrackGhostWeaponEntity(client, weapon);
    }
    else if (g_iPower[client] == RSP_Zombie && g_bZombieUsedThisRound[client] &&
        !g_bZombieLoadoutApplying[client] && !g_bZombieCleanupQueued[client])
    {
        g_bZombieCleanupQueued[client] = true;
        g_iZombieCleanupRound[client] = g_iRoundSerial;
        RequestFrame(Frame_CleanZombieInventory, GetClientUserId(client));
    }
}

public void Hook_WeaponDropPost(int client, int weapon)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        weapon <= MaxClients || weapon >= RSP_MAX_ENTITIES || !IsValidEntity(weapon))
    {
        return;
    }


    char classname[32];
    GetEntityClassname(weapon, classname, sizeof(classname));

    bool deathTransitionDrop = g_fZombieDropCleanupUntil[client] > GetGameTime();
    bool zombieDeathDrop = g_iPower[client] == RSP_Zombie && !IsPlayerAlive(client);
    bool activeZombieDrop = g_iPower[client] == RSP_Zombie && g_bZombieUsedThisRound[client];
    if ((deathTransitionDrop || zombieDeathDrop || activeZombieDrop) && !g_bZombieLoadoutApplying[client])
    {
        // Preserve objective items if a Zombie drops them; ordinary firearms, grenades
        // and a dropped knife are removed from the world after Source completes the drop.
        bool objectiveItem = StrEqual(classname, "weapon_c4", false) ||
            StrEqual(classname, "weapon_defuser", false) ||
            StrEqual(classname, "item_defuser", false);

        if (!objectiveItem)
        {
            int ref = EntIndexToEntRef(weapon);
            bool alreadyTracked = false;
            for (int i = 0; i < g_iZombieDroppedWeaponCount[client]; i++)
            {
                if (g_iZombieDroppedWeaponRefs[client][i] == ref)
                {
                    alreadyTracked = true;
                    break;
                }
            }
            if (!alreadyTracked && g_iZombieDroppedWeaponCount[client] < RSP_ZOMBIE_DROPPED_WEAPONS)
            {
                g_iZombieDroppedWeaponRefs[client][g_iZombieDroppedWeaponCount[client]++] = ref;
            }
            if (g_hZombieDroppedCleanupTimer[client] == null)
            {
                g_iZombieDroppedCleanupAttempts[client] = 0;
                g_hZombieDroppedCleanupTimer[client] = CreateTimer(0.05, Timer_CleanZombieDroppedWeapons,
                    GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
            }
        }
    }

    // Keep the existing Deadly Flash ownership path intact for a flashbang dropped
    // during a death transition, and always untrack ghost weapons after a real drop.
    if (StrEqual(classname, "weapon_flashbang", false) && HasDeadlyFlashAttribution(client))
    {
        g_bLastFlashWasDeadly[client] = true;
        g_fLastDeadlyFlashThrowTime[client] = GetGameTime();
        g_iLastDeadlyFlashThrowRound[client] = g_iRoundSerial;
    }

    UntrackGhostWeaponEntity(weapon);
}

public Action Timer_CleanZombieDroppedWeapons(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return Plugin_Stop;
    }

    if (g_hZombieDroppedCleanupTimer[client] != timer)
    {
        return Plugin_Stop;
    }

    // Keep ordinary voluntary drops. If Source dropped the Zombie's inventory in
    // the death transition, the Zombie flag is set by Event_PlayerDeath before this
    // 50 ms check and the dropped entities are removed instead of remaining pickups.
    if (g_bZombieUsedThisRound[client] || g_fZombieDropCleanupUntil[client] > GetGameTime())
    {
        for (int i = 0; i < g_iZombieDroppedWeaponCount[client]; i++)
        {
            int entity = EntRefToEntIndex(g_iZombieDroppedWeaponRefs[client][i]);
            if (entity > MaxClients && IsValidEntity(entity))
            {
                RemoveEntity(entity);
            }
            g_iZombieDroppedWeaponRefs[client][i] = 0;
        }
        g_iZombieDroppedWeaponCount[client] = 0;
        g_iZombieDroppedCleanupAttempts[client] = 0;
        g_hZombieDroppedCleanupTimer[client] = null;
        return Plugin_Stop;
    }

    if (IsPlayerAlive(client) || ++g_iZombieDroppedCleanupAttempts[client] >= 4)
    {
        for (int i = 0; i < g_iZombieDroppedWeaponCount[client]; i++)
        {
            g_iZombieDroppedWeaponRefs[client][i] = 0;
        }
        g_iZombieDroppedWeaponCount[client] = 0;
        g_iZombieDroppedCleanupAttempts[client] = 0;
        g_hZombieDroppedCleanupTimer[client] = null;
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

public Action Hook_WeaponCanUse(int client, int weapon)
{
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive() ||
        client < 1 || client > MaxClients || !IsClientInGame(client) ||
        weapon <= MaxClients || !IsValidEntity(weapon))
    {
        return Plugin_Continue;
    }

    if (g_bSpectatorActive[client])
    {
        return Plugin_Handled;
    }

    if (g_iPower[client] == RSP_Ghost)
    {
        char ghostClassname[32];
        GetEntityClassname(weapon, ghostClassname, sizeof(ghostClassname));
        return IsGhostAllowedWeapon(ghostClassname) ? Plugin_Continue : Plugin_Handled;
    }

    // On the first life Zombie is not yet a zombie: keep the complete vanilla loadout.
    if (g_iPower[client] != RSP_Zombie || !g_bZombieUsedThisRound[client])
    {
        return Plugin_Continue;
    }

    char classname[32];
    GetEntityClassname(weapon, classname, sizeof(classname));
    return IsZombieAllowedWeapon(client, classname) ? Plugin_Continue : Plugin_Handled;
}

bool IsZombieAllowedWeapon(int client, const char[] classname)
{
    if (StrEqual(classname, "weapon_knife", false))
    {
        return true;
    }

    int team = GetClientTeam(client);
    if (team == CS_TEAM_T)
    {
        return StrEqual(classname, "weapon_c4", false);
    }
    if (team == CS_TEAM_CT)
    {
        return StrEqual(classname, "weapon_defuser", false) ||
            StrEqual(classname, "item_defuser", false);
    }
    return false;
}

bool IsGhostAllowedWeapon(const char[] classname)
{
    return StrEqual(classname, "weapon_knife", false) ||
        StrEqual(classname, "weapon_hegrenade", false) ||
        StrEqual(classname, "weapon_flashbang", false) ||
        StrEqual(classname, "weapon_smokegrenade", false) ||
        StrEqual(classname, "weapon_c4", false) ||
        StrEqual(classname, "weapon_defuser", false) ||
        StrEqual(classname, "item_defuser", false);
}

void StripGhostFirearms(int client)
{
    for (int slot = 0; slot <= 1; slot++)
    {
        int weapon = GetPlayerWeaponSlot(client, slot);
        if (weapon <= MaxClients || !IsValidEntity(weapon))
        {
            continue;
        }

        char classname[32];
        GetEntityClassname(weapon, classname, sizeof(classname));
        if (!IsGhostAllowedWeapon(classname))
        {
            RemovePlayerItem(client, weapon);
            RemoveEntity(weapon);
        }
    }
}

void TrackGhostInventoryWeapons(int client)
{
    for (int slot = 0; slot <= 4; slot++)
    {
        int weapon = GetPlayerWeaponSlot(client, slot);
        if (weapon > MaxClients && weapon < RSP_MAX_ENTITIES && IsValidEntity(weapon))
        {
            TrackGhostWeaponEntity(client, weapon);
        }
    }
}

void TrackGhostWeaponEntity(int client, int weapon)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        weapon <= MaxClients || weapon >= RSP_MAX_ENTITIES || !IsValidEntity(weapon))
    {
        return;
    }

    int userId = GetClientUserId(client);
    if (g_iGhostEntityOwnerUserId[weapon] == userId)
    {
        return;
    }

    if (g_iGhostEntityOwnerUserId[weapon] != 0)
    {
        SDKUnhook(weapon, SDKHook_SetTransmit, Hook_RSPSetTransmit);
    }

    g_iGhostEntityOwnerUserId[weapon] = userId;
    SDKHook(weapon, SDKHook_SetTransmit, Hook_RSPSetTransmit);
}

void UntrackGhostInventoryWeapons(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    for (int slot = 0; slot <= 4; slot++)
    {
        int weapon = GetPlayerWeaponSlot(client, slot);
        if (weapon > MaxClients && weapon < RSP_MAX_ENTITIES && IsValidEntity(weapon))
        {
            UntrackGhostWeaponEntity(weapon);
        }
    }
}

void UntrackGhostWeaponEntity(int weapon)
{
    if (weapon <= MaxClients || weapon >= RSP_MAX_ENTITIES || !IsValidEntity(weapon))
    {
        return;
    }

    if (g_iGhostEntityOwnerUserId[weapon] != 0)
    {
        g_iGhostEntityOwnerUserId[weapon] = 0;
        SDKUnhook(weapon, SDKHook_SetTransmit, Hook_RSPSetTransmit);
    }
}

bool IsGhostVisibleToViewer(int viewer, int ghostOwner)
{
    if (viewer < 1 || viewer > MaxClients || ghostOwner < 1 || ghostOwner > MaxClients ||
        viewer == ghostOwner || !IsClientInGame(viewer) || !IsClientInGame(ghostOwner) ||
        IsPlayerAlive(viewer))
    {
        return false;
    }

    // Spectator-team clients can roam freely and must still see a live Ghost even with no
    // m_hObserverTarget. This exception is only for non-alive viewers; living T/CT remain hidden.
    if (GetClientTeam(viewer) == CS_TEAM_SPECTATOR)
    {
        return true;
    }

    // A dead T/CT client in roaming mode is also a free camera, while first-/third-person
    // observers are allowed to see only the Ghost they are currently following.
    if (HasEntProp(viewer, Prop_Send, "m_iObserverMode") &&
        GetEntProp(viewer, Prop_Send, "m_iObserverMode") == RSP_OBSERVER_MODE_ROAMING)
    {
        return true;
    }

    if (!HasEntProp(viewer, Prop_Send, "m_hObserverTarget"))
    {
        return false;
    }
    return GetEntPropEnt(viewer, Prop_Send, "m_hObserverTarget") == ghostOwner;
}

public Action Hook_RSPSetTransmit(int entity, int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return Plugin_Continue;
    }

    if (entity > MaxClients && entity < RSP_MAX_ENTITIES && g_iWallhackMarkerTarget[entity] > 0)
    {
        return CanViewerSeeWallhackMarker(client, g_iWallhackMarkerTarget[entity])
            ? Plugin_Continue : Plugin_Handled;
    }

    if (entity > MaxClients && entity < RSP_MAX_ENTITIES && IsValidEntity(entity))
    {
        if (g_iGiftOwnerUserId[entity] != 0)
        {
            int giftTeam = g_iGiftTeam[entity];
            return (giftTeam > 0 && GetClientTeam(client) == giftTeam)
                ? Plugin_Continue : Plugin_Handled;
        }
        if (g_iMinerOwnerUserId[entity] != 0)
        {
            int viewerTeam = GetClientTeam(client);
            int mineTeam = g_iMinerTeam[entity];
            int viewerUserId = GetClientUserId(client);
            if (viewerUserId == g_iMinerOwnerUserId[entity] || viewerTeam == mineTeam)
            {
                return Plugin_Continue;
            }
            if ((viewerTeam == CS_TEAM_T || viewerTeam == CS_TEAM_CT) &&
                (mineTeam == CS_TEAM_T || mineTeam == CS_TEAM_CT) && viewerTeam != mineTeam)
            {
                // Once an opponent discovers this mine within the short reveal radius,
                // remember it for that viewer until this mine is removed/round-reset.
                if (g_bMinerDiscoveredBy[entity][client])
                {
                    return Plugin_Continue;
                }
                float mineOrigin[3], viewerOrigin[3];
                GetEntPropVector(entity, Prop_Send, "m_vecOrigin", mineOrigin);
                GetClientAbsOrigin(client, viewerOrigin);
                if (GetVectorDistance(mineOrigin, viewerOrigin) <= RSP_MINER_ENEMY_VISIBILITY_RADIUS)
                {
                    g_bMinerDiscoveredBy[entity][client] = true;
                    return Plugin_Continue;
                }
                return Plugin_Handled;
            }
            // Spectators are not opposing players and may observe the mine.
            return Plugin_Continue;
        }
    }

    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        return Plugin_Continue;
    }

    if (entity >= 1 && entity <= MaxClients)
    {
        // Preserve the existing short death-transition window. It applies only after death;
        // the live Ghost itself is never transmitted to an ordinary living player.
        if (entity != client && !IsPlayerAlive(entity) &&
            g_fGhostDeathRevealUntil[entity] > GetGameTime())
        {
            return Plugin_Continue;
        }

        if (entity != client && g_iPower[entity] == RSP_Ghost && IsPlayerAlive(entity))
        {
            return IsGhostVisibleToViewer(client, entity) ? Plugin_Continue : Plugin_Handled;
        }
        return Plugin_Continue;
    }

    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES || !IsValidEntity(entity))
    {
        return Plugin_Continue;
    }

    int ghostOwner = GetClientOfUserId(g_iGhostEntityOwnerUserId[entity]);
    if (ghostOwner >= 1 && ghostOwner <= MaxClients && ghostOwner != client &&
        g_iPower[ghostOwner] == RSP_Ghost)
    {
        // Tracked Ghost inventory entities follow the same spectator/observer rule as its model.
        return IsGhostVisibleToViewer(client, ghostOwner) ? Plugin_Continue : Plugin_Handled;
    }

    return Plugin_Continue;
}

void ClearIncendiaryTracking()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        g_iBurnOwnerUserId[client] = 0;
        g_iBurnOwnerRound[client] = 0;
        g_fBurnOwnerUntil[client] = 0.0;
        g_bBurnDeathPending[client] = false;
        g_iBurnDeathOwnerUserId[client] = 0;
        g_iBurnDeathRound[client] = 0;
    }
}

void TryHookRadarMessage()
{
    if (g_bRadarHooked)
    {
        return;
    }

    int messageId = view_as<int>(GetUserMessageId("UpdateRadar"));
    if (messageId == -1)
    {
        return;
    }

    g_umUpdateRadar = view_as<UserMsg>(messageId);
    HookUserMessage(g_umUpdateRadar, Hook_UpdateRadarMessage, true);
    g_bRadarHooked = true;
}

bool ViewerNeedsRadarRewrite(int viewer)
{
    if (viewer < 1 || viewer > MaxClients || !IsClientInGame(viewer))
    {
        return false;
    }
    if (IsRSPRadarDisabled(viewer))
    {
        return true;
    }

    int viewerTeam = GetClientTeam(viewer);
    if (viewerTeam != CS_TEAM_T && viewerTeam != CS_TEAM_CT &&
        !(viewerTeam == CS_TEAM_SPECTATOR && !IsPlayerAlive(viewer)))
    {
        return false;
    }

    // Any live Ghost contact needs viewer-specific filtering: living players must not receive it;
    // non-alive Spectator-team/free-roaming viewers and viewers following that Ghost may.
    for (int target = 1; target <= MaxClients; target++)
    {
        if (target == viewer || !IsClientInGame(target) || !IsPlayerAlive(target) ||
            g_iPower[target] != RSP_Ghost)
        {
            continue;
        }
        return true;
    }
    return false;
}

public Action Hook_UpdateRadarMessage(UserMsg msgId, BfRead msg, const int[] players,
    int playersNum, bool reliable, bool init)
{
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive() ||
        playersNum < 1 || playersNum > MAXPLAYERS)
    {
        return Plugin_Continue;
    }

    bool anyAffectedViewer = false;
    for (int recipientIndex = 0; recipientIndex < playersNum; recipientIndex++)
    {
        if (ViewerNeedsRadarRewrite(players[recipientIndex]))
        {
            anyAffectedViewer = true;
            break;
        }
    }
    if (!anyAffectedViewer)
    {
        return Plugin_Continue;
    }

    // Decode the payload once. If a batched usermessage has a single affected recipient,
    // the original is intercepted and an equivalent viewer-specific packet is sent to every
    // recipient; otherwise unaffected teammates/clients would miss that radar update.
    int sourceIds[MAXPLAYERS + 1];
    int sourceX[MAXPLAYERS + 1];
    int sourceY[MAXPLAYERS + 1];
    int sourceZ[MAXPLAYERS + 1];
    int sourceYaw[MAXPLAYERS + 1];
    int sourceCount = 0;
    bool terminatorSeen = false;
    while (BfGetNumBytesLeft(msg) > 0)
    {
        int id = BfReadByte(msg);
        if (id == 0)
        {
            terminatorSeen = true;
            break;
        }
        if (BfGetNumBytesLeft(msg) < 6 || sourceCount >= MAXPLAYERS)
        {
            return Plugin_Continue;
        }
        sourceIds[sourceCount] = id;
        sourceX[sourceCount] = ReadSignedBits(msg, 13);
        sourceY[sourceCount] = ReadSignedBits(msg, 13);
        sourceZ[sourceCount] = ReadSignedBits(msg, 13);
        sourceYaw[sourceCount] = ReadSignedBits(msg, 9);
        sourceCount++;
    }
    if (!terminatorSeen)
    {
        return Plugin_Continue;
    }

    for (int recipientIndex = 0; recipientIndex < playersNum; recipientIndex++)
    {
        int viewer = players[recipientIndex];
        if (viewer < 1 || viewer > MaxClients || !IsClientInGame(viewer))
        {
            continue;
        }
        bool hideRadar = IsRSPRadarDisabled(viewer);
        bool ghostSeen[MAXPLAYERS + 1];
        for (int i = 0; i <= MAXPLAYERS; i++) ghostSeen[i] = false;

        int count = 0;
        for (int record = 0; record < sourceCount && count < MAXPLAYERS; record++)
        {
            int id = sourceIds[record];
            int x = sourceX[record];
            int y = sourceY[record];
            int z = sourceZ[record];
            int yaw = sourceYaw[record];
            if (id >= 1 && id <= MaxClients) ghostSeen[id] = true;

            bool isHiddenGhostContact = id >= 1 && id <= MaxClients && id != viewer &&
                IsClientInGame(id) && IsPlayerAlive(id) && g_iPower[id] == RSP_Ghost &&
                !IsGhostVisibleToViewer(viewer, id);

            // Hide every live Ghost contact from living players. Non-alive Spectator-team/free-roaming
            // viewers and dead players following this exact Ghost may receive its real position.
            // Omit hidden contacts instead of moving them to a fake off-map point.
            if (isHiddenGhostContact)
            {
                continue;
            }

            if (hideRadar && id != viewer)
            {
                x = RSP_RADAR_HIDDEN_COORD;
                y = RSP_RADAR_HIDDEN_COORD;
                z = RSP_RADAR_HIDDEN_COORD;
            }
            g_iRadarQueuedIds[viewer][count] = id;
            g_iRadarQueuedX[viewer][count] = x;
            g_iRadarQueuedY[viewer][count] = y;
            g_iRadarQueuedZ[viewer][count] = z;
            g_iRadarQueuedYaw[viewer][count] = yaw;
            count++;
        }

        // When Hacker disables this viewer's entire radar, insert hidden contacts for
        // missing player indexes to clear stale positions. Omitted Ghost contacts are not
        // synthesized as fake off-map markers; absence of the contact clears stale positions.
        for (int target = 1; target <= MaxClients && count < MAXPLAYERS; target++)
        {
            if (target == viewer || ghostSeen[target] || !IsClientInGame(target))
            {
                continue;
            }
            bool needsHiddenRecord = false;
            if (hideRadar)
            {
                int team = GetClientTeam(target);
                needsHiddenRecord = (team == CS_TEAM_T || team == CS_TEAM_CT);
            }
            // Do not synthesize an off-map record for an omitted Ghost; the absent contact
            // itself clears its stale radar position on the replacement packet.
            if (needsHiddenRecord)
            {
                g_iRadarQueuedIds[viewer][count] = target;
                g_iRadarQueuedX[viewer][count] = RSP_RADAR_HIDDEN_COORD;
                g_iRadarQueuedY[viewer][count] = RSP_RADAR_HIDDEN_COORD;
                g_iRadarQueuedZ[viewer][count] = RSP_RADAR_HIDDEN_COORD;
                g_iRadarQueuedYaw[viewer][count] = 0;
                count++;
            }
        }

        g_iRadarQueuedCount[viewer] = count;
        if (!g_bRadarRewriteQueued[viewer])
        {
            g_bRadarRewriteQueued[viewer] = true;
            RequestFrame(Frame_SendQueuedRadar, GetClientUserId(viewer));
        }
    }
    return Plugin_Handled;
}

public void Frame_SendQueuedRadar(any userid)
{
    int viewer = GetClientOfUserId(userid);
    if (viewer < 1 || viewer > MaxClients)
    {
        return;
    }

    if (!g_bRadarRewriteQueued[viewer])
    {
        return;
    }

    if (!IsClientInGame(viewer) || !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        g_bRadarRewriteQueued[viewer] = false;
        g_iRadarQueuedCount[viewer] = 0;
        return;
    }

    int count = g_iRadarQueuedCount[viewer];
    if (count < 0 || count > MAXPLAYERS)
    {
        g_bRadarRewriteQueued[viewer] = false;
        g_iRadarQueuedCount[viewer] = 0;
        return;
    }

    // This callback runs on the next frame, outside Hook_UpdateRadarMessage.
    // USERMSG_BLOCKHOOKS is an additional guard against recursive interception.
    Handle output = StartMessageOne("UpdateRadar", viewer, USERMSG_BLOCKHOOKS);
    if (output == null)
    {
        g_bRadarRewriteQueued[viewer] = false;
        g_iRadarQueuedCount[viewer] = 0;
        return;
    }

    for (int i = 0; i < count; i++)
    {
        BfWriteByte(output, g_iRadarQueuedIds[viewer][i]);
        WriteSignedBits(output, g_iRadarQueuedX[viewer][i], 13);
        WriteSignedBits(output, g_iRadarQueuedY[viewer][i], 13);
        WriteSignedBits(output, g_iRadarQueuedZ[viewer][i], 13);
        WriteSignedBits(output, g_iRadarQueuedYaw[viewer][i], 9);
    }
    BfWriteByte(output, 0);
    EndMessage();

    g_iRadarQueuedCount[viewer] = 0;
    g_bRadarRewriteQueued[viewer] = false;
}

int ReadSignedBits(Handle buffer, int bitCount)
{
    int value = 0;
    for (int bit = 0; bit < bitCount; bit++)
    {
        if (BfReadBool(buffer))
        {
            value |= (1 << bit);
        }
    }
    if ((value & (1 << (bitCount - 1))) != 0)
    {
        value |= (-1 << bitCount);
    }
    return value;
}

void WriteSignedBits(Handle buffer, int value, int bitCount)
{
    for (int bit = 0; bit < bitCount; bit++)
    {
        BfWriteBool(buffer, (value & (1 << bit)) != 0);
    }
}

void SetRSPCollisionBounds(int client, const float mins[3], const float maxs[3])
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !HasEntProp(client, Prop_Send, "m_vecMins") || !HasEntProp(client, Prop_Send, "m_vecMaxs"))
    {
        return;
    }

    float currentMins[3], currentMaxs[3];
    GetEntPropVector(client, Prop_Send, "m_vecMins", currentMins);
    GetEntPropVector(client, Prop_Send, "m_vecMaxs", currentMaxs);

    bool changed = false;
    for (int axis = 0; axis < 3; axis++)
    {
        if (FloatAbs(currentMins[axis] - mins[axis]) > 0.05 ||
            FloatAbs(currentMaxs[axis] - maxs[axis]) > 0.05)
        {
            changed = true;
            break;
        }
    }

    float size[3];
    SubtractVectors(maxs, mins, size);
    float desiredRadius = GetVectorLength(size) * 0.5;
    bool radiusChanged = false;
    if (HasEntProp(client, Prop_Data, "m_flRadius"))
    {
        radiusChanged = FloatAbs(GetEntPropFloat(client, Prop_Data, "m_flRadius") - desiredRadius) > 0.05;
    }

    if (!changed && !radiusChanged)
    {
        return;
    }

    if (changed)
    {
        SetEntPropVector(client, Prop_Send, "m_vecMins", mins);
        SetEntPropVector(client, Prop_Send, "m_vecMaxs", maxs);
    }

    if (HasEntProp(client, Prop_Data, "m_flRadius"))
    {
        SetEntPropFloat(client, Prop_Data, "m_flRadius", desiredRadius);
    }

    if (HasEntProp(client, Prop_Data, "m_iEFlags"))
    {
        int entityFlags = GetEntProp(client, Prop_Data, "m_iEFlags");
        if ((entityFlags & RSP_EFL_DIRTY_SURR_COLLISION_BOUNDS) == 0)
        {
            SetEntProp(client, Prop_Data, "m_iEFlags", entityFlags | RSP_EFL_DIRTY_SURR_COLLISION_BOUNDS);
        }
    }
}

float GetRandomGiantScale()
{
    // Roll exact hundredths so the displayed scale, collision scale, and health formula all use the same value.
    int minHundredths = RoundToNearest(RSP_GIANT_SCALE_MIN * 100.0);
    int maxHundredths = RoundToNearest(RSP_GIANT_SCALE_MAX * 100.0);
    return float(GetRandomInt(minHundredths, maxHundredths)) / 100.0;
}

int GetGiantTotalHealthForScale(float scale)
{
    if (scale < RSP_GIANT_SCALE_MIN) scale = RSP_GIANT_SCALE_MIN;
    if (scale > RSP_GIANT_SCALE_MAX) scale = RSP_GIANT_SCALE_MAX;
    float fraction = (scale - RSP_GIANT_SCALE_MIN) / (RSP_GIANT_SCALE_MAX - RSP_GIANT_SCALE_MIN);
    return RoundToNearest(float(RSP_GIANT_HEALTH_MIN) + fraction * float(RSP_GIANT_HEALTH_MAX - RSP_GIANT_HEALTH_MIN));
}

int GetRSPClientMaxHealth(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return 100;
    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
    {
        int value = GetEntProp(client, Prop_Data, "m_iMaxHealth");
        if (value > 0) return value;
    }
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
    {
        int value = GetEntProp(client, Prop_Send, "m_iMaxHealth");
        if (value > 0) return value;
    }
    return 100;
}

void SetRSPClientMaxHealth(int client, int value)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || value <= 0) return;
    if (HasEntProp(client, Prop_Data, "m_iMaxHealth")) SetEntProp(client, Prop_Data, "m_iMaxHealth", value);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth")) SetEntProp(client, Prop_Send, "m_iMaxHealth", value);
}

void SetDwarfCollisionBounds(int client, const float mins[3], const float maxs[3])
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    float modelScale = 1.0;
    if (HasEntProp(client, Prop_Send, "m_flModelScale"))
    {
        modelScale = GetEntPropFloat(client, Prop_Send, "m_flModelScale");
    }
    if (modelScale < 0.01)
    {
        modelScale = 1.0;
    }

    // Source scales collision bounds from m_vecMinsPreScaled/m_vecMaxsPreScaled.
    // Compensate those source bounds by 1/scale so the effective movement hull stays
    // the original world size and cannot be used to push the eye camera through walls.
    if (HasEntProp(client, Prop_Send, "m_vecMinsPreScaled") &&
        HasEntProp(client, Prop_Send, "m_vecMaxsPreScaled"))
    {
        float preMins[3], preMaxs[3], currentPreMins[3], currentPreMaxs[3];
        bool preChanged = false;
        for (int axis = 0; axis < 3; axis++)
        {
            preMins[axis] = mins[axis] / modelScale;
            preMaxs[axis] = maxs[axis] / modelScale;
        }

        GetEntPropVector(client, Prop_Send, "m_vecMinsPreScaled", currentPreMins);
        GetEntPropVector(client, Prop_Send, "m_vecMaxsPreScaled", currentPreMaxs);
        for (int axis = 0; axis < 3; axis++)
        {
            if (FloatAbs(currentPreMins[axis] - preMins[axis]) > 0.05 ||
                FloatAbs(currentPreMaxs[axis] - preMaxs[axis]) > 0.05)
            {
                preChanged = true;
                break;
            }
        }

        if (preChanged)
        {
            SetEntPropVector(client, Prop_Send, "m_vecMinsPreScaled", preMins);
            SetEntPropVector(client, Prop_Send, "m_vecMaxsPreScaled", preMaxs);
        }
    }

    // Directly enforce the effective server hull as well; network-property changes
    // alone do not call CCollisionProperty::SetCollisionBounds on the server.
    SetRSPCollisionBounds(client, mins, maxs);
}

void ApplyDwarfCollisionBounds(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        g_iPower[client] != RSP_Dwarf || !g_bOldCollisionBoundsValid[client])
    {
        return;
    }

    float mins[3], maxs[3];
    for (int axis = 0; axis < 3; axis++)
    {
        mins[axis] = g_fOldCollisionMins[client][axis];
        maxs[axis] = g_fOldCollisionMaxs[client][axis];
    }

    if (HasEntProp(client, Prop_Send, "m_bDucked"))
    {
        bool isDucked = GetEntProp(client, Prop_Send, "m_bDucked") != 0;
        if (isDucked != g_bOldViewOffsetWasDucked[client])
        {
            maxs[2] += isDucked ? -RSP_DWARF_DUCK_VIEW_HEIGHT_DELTA : RSP_DWARF_DUCK_VIEW_HEIGHT_DELTA;
        }
    }

    SetDwarfCollisionBounds(client, mins, maxs);
}

void ApplyGiantCollisionBounds(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        g_iPower[client] != RSP_Giant || !g_bOldCollisionBoundsValid[client])
    {
        return;
    }

    // The collision hull must follow the actual model scale, not merely the ratio
    // against a previous target-scale effect that may have been active before Giant.
    float ratio = GetEntPropFloat(client, Prop_Send, "m_flModelScale");
    if (ratio < 0.01) ratio = 1.0;
    float mins[3], maxs[3];
    bool isDucked = HasEntProp(client, Prop_Send, "m_bDucked") && GetEntProp(client, Prop_Send, "m_bDucked") != 0;
    for (int axis = 0; axis < 3; axis++)
    {
        mins[axis] = g_fOldCollisionMins[client][axis] * ratio;
        maxs[axis] = g_fOldCollisionMaxs[client][axis] * ratio;
    }
    if (HasEntProp(client, Prop_Send, "m_bDucked"))
    {
        bool oldDucked = g_bOldViewOffsetWasDucked[client];
        if (isDucked != oldDucked)
        {
            maxs[2] += (isDucked ? -RSP_DWARF_DUCK_VIEW_HEIGHT_DELTA : RSP_DWARF_DUCK_VIEW_HEIGHT_DELTA) * ratio;
        }
    }
    SetRSPCollisionBounds(client, mins, maxs);
}

void ApplySelfModelScaleViewOffset(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) ||
        (g_iPower[client] != RSP_Dwarf && g_iPower[client] != RSP_Giant) || !g_bOldViewOffsetValid[client] ||
        g_fSelfModelScaleRatio[client] <= 0.01 || !HasEntProp(client, Prop_Data, "m_vecViewOffset"))
    {
        return;
    }

    float baseHeight = g_fOldViewOffset[client][2];
    if (HasEntProp(client, Prop_Send, "m_bDucked"))
    {
        bool isDucked = GetEntProp(client, Prop_Send, "m_bDucked") != 0;
        if (isDucked != g_bOldViewOffsetWasDucked[client])
        {
            baseHeight += isDucked ? -RSP_DWARF_DUCK_VIEW_HEIGHT_DELTA : RSP_DWARF_DUCK_VIEW_HEIGHT_DELTA;
        }
    }

    float targetHeight = baseHeight * g_fSelfModelScaleRatio[client];
    float viewOffset[3];
    GetEntPropVector(client, Prop_Data, "m_vecViewOffset", viewOffset);
    if (FloatAbs(viewOffset[2] - targetHeight) > 0.05)
    {
        viewOffset[2] = targetHeight;
        SetEntPropVector(client, Prop_Data, "m_vecViewOffset", viewOffset);
    }
}

public bool TraceFilter_AimbotHeadRedirect(int entity, int contentsMask, any data)
{
    // Ignore only the shooter; world geometry, props, and other players remain blockers.
    return entity != data;
}

bool IsValidAimbotEnemy(int client, int target)
{
    return target >= 1 && target <= MaxClients && target != client &&
        IsValidPlayingClient(target) && IsPlayerAlive(target) &&
        GetClientTeam(target) != GetClientTeam(client) && g_iPower[target] != RSP_Ghost;
}

void GetAimbotHeadPoint(int target, float headPoint[3])
{
    GetClientEyePosition(target, headPoint);
    // Eye position is slightly above the center of common CS:S head hitboxes.
    headPoint[2] -= RSP_AIMBOT_HEAD_POINT_OFFSET;
}

bool CanTraceToAimbotHead(int client, int target, const float eyePosition[3], const float headPoint[3])
{
    float direction[3], endPosition[3];
    MakeVectorFromPoints(eyePosition, headPoint, direction);
    float distance = NormalizeVector(direction, direction);
    if (distance <= 0.0)
    {
        return false;
    }

    for (int axis = 0; axis < 3; axis++)
    {
        endPosition[axis] = headPoint[axis] + direction[axis] * 4.0;
    }

    TR_TraceRayFilter(eyePosition, endPosition, MASK_SHOT, RayType_EndPoint,
        TraceFilter_AimbotHeadRedirect, client);
    return TR_DidHit() && !TR_StartSolid() && TR_GetEntityIndex() == target;
}

bool TryRedirectAimbotShotToHead(int client, float angles[3])
{
    if (client < 1 || client > MaxClients || !IsValidPlayingClient(client) || !IsPlayerAlive(client))
    {
        return false;
    }

    float eyePosition[3];
    GetClientEyePosition(client, eyePosition);

    // Preserve a native headshot: if the unmodified command ray already intersects an
    // enemy head hitgroup, leave its angles and all native hit effects untouched.
    int target = 0;
    TR_TraceRayFilter(eyePosition, angles, MASK_SHOT, RayType_Infinite,
        TraceFilter_AimbotHeadRedirect, client);
    if (TR_DidHit() && !TR_StartSolid())
    {
        int rayEntity = TR_GetEntityIndex();
        if (IsValidAimbotEnemy(client, rayEntity))
        {
            if (TR_GetHitGroup() == 1)
            {
                return false;
            }
            target = rayEntity;
        }
    }

    float candidateHead[3];
    float bestScore = 1.0e30;
    if (target == 0)
    {
        for (int candidate = 1; candidate <= MaxClients; candidate++)
        {
            if (!IsValidAimbotEnemy(client, candidate))
            {
                continue;
            }

            GetAimbotHeadPoint(candidate, candidateHead);
            if (!CanTraceToAimbotHead(client, candidate, eyePosition, candidateHead))
            {
                continue;
            }

            float direction[3], desiredAngles[3];
            MakeVectorFromPoints(eyePosition, candidateHead, direction);
            GetVectorAngles(direction, desiredAngles);
            float pitchDelta = NormalizeRSPAngle(desiredAngles[0] - angles[0]);
            float yawDelta = NormalizeRSPAngle(desiredAngles[1] - angles[1]);
            if (FloatAbs(yawDelta) > RSP_AIMBOT_ACQUIRE_MAX_YAW ||
                FloatAbs(pitchDelta) > RSP_AIMBOT_ACQUIRE_MAX_PITCH)
            {
                continue;
            }

            float score = yawDelta * yawDelta + (pitchDelta * pitchDelta * 0.35);
            if (score < bestScore)
            {
                bestScore = score;
                target = candidate;
            }
        }
    }

    if (target == 0)
    {
        return false;
    }

    GetAimbotHeadPoint(target, candidateHead);
    if (!CanTraceToAimbotHead(client, target, eyePosition, candidateHead))
    {
        return false;
    }

    float direction[3], correctedAngles[3];
    MakeVectorFromPoints(eyePosition, candidateHead, direction);
    GetVectorAngles(direction, correctedAngles);
    float pitchDelta = NormalizeRSPAngle(correctedAngles[0] - angles[0]);
    float yawDelta = NormalizeRSPAngle(correctedAngles[1] - angles[1]);
    if (FloatAbs(pitchDelta) < 0.15 && FloatAbs(yawDelta) < 0.15)
    {
        return false;
    }

    angles[0] = NormalizeRSPAngle(correctedAngles[0]);
    angles[1] = NormalizeRSPAngle(correctedAngles[1]);
    angles[2] = 0.0;
    return true;
}

bool IsRSPNoRecoilHolder(int client)
{
    return client >= 1 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client) &&
        g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActiveForClient(client) &&
        g_iPower[client] == RSP_NoRecoil &&
        (g_iAssignedRound[client] == g_iRoundSerial || g_bHostPowerGrantedOutsideRound[client]);
}

void ClearRSPNoRecoilPunchState(int client)
{
    float zero[3] = {0.0, 0.0, 0.0};

    // CS:S nests these player-local vectors in the localdata SendTable. Write the
    // actual network path as well as the authoritative datamap member so server
    // simulation and the owning client's prediction correction stay synchronized.
    if (HasEntProp(client, Prop_Send, "localdata.m_vecPunchAngle"))
    {
        SetEntPropVector(client, Prop_Send, "localdata.m_vecPunchAngle", zero);
    }
    else if (HasEntProp(client, Prop_Send, "m_vecPunchAngle"))
    {
        SetEntPropVector(client, Prop_Send, "m_vecPunchAngle", zero);
    }
    if (HasEntProp(client, Prop_Data, "m_Local.m_vecPunchAngle"))
    {
        SetEntPropVector(client, Prop_Data, "m_Local.m_vecPunchAngle", zero);
    }
    else if (HasEntProp(client, Prop_Data, "m_vecPunchAngle"))
    {
        SetEntPropVector(client, Prop_Data, "m_vecPunchAngle", zero);
    }

    if (HasEntProp(client, Prop_Send, "localdata.m_vecPunchAngleVel"))
    {
        SetEntPropVector(client, Prop_Send, "localdata.m_vecPunchAngleVel", zero);
    }
    else if (HasEntProp(client, Prop_Send, "m_vecPunchAngleVel"))
    {
        SetEntPropVector(client, Prop_Send, "m_vecPunchAngleVel", zero);
    }
    if (HasEntProp(client, Prop_Data, "m_Local.m_vecPunchAngleVel"))
    {
        SetEntPropVector(client, Prop_Data, "m_Local.m_vecPunchAngleVel", zero);
    }
    else if (HasEntProp(client, Prop_Data, "m_vecPunchAngleVel"))
    {
        SetEntPropVector(client, Prop_Data, "m_vecPunchAngleVel", zero);
    }
}

public void Hook_RSPNoRecoilPreThink(int client)
{
    if (IsRSPNoRecoilHolder(client))
    {
        ClearRSPNoRecoilPunchState(client);
    }
}

public void Hook_RSPNoRecoilPostThink(int client)
{
    if (IsRSPNoRecoilHolder(client))
    {
        ClearRSPNoRecoilPunchState(client);
    }
}

void RestoreBunnyMaxSpeed(int client)
{
    if (client < 1 || client > MaxClients || !g_bBunnyMaxSpeedOverride[client])
    {
        return;
    }

    if (IsClientInGame(client) && HasEntProp(client, Prop_Data, "m_flMaxspeed"))
    {
        SetEntPropFloat(client, Prop_Data, "m_flMaxspeed", g_fBunnyOriginalMaxSpeed[client]);
    }

    g_bBunnyMaxSpeedOverride[client] = false;
    g_fBunnyOriginalMaxSpeed[client] = 0.0;
}

void PrepareBunnyJumpSpeed(int client)
{
    if (g_bBunnyMaxSpeedOverride[client] || !HasEntProp(client, Prop_Data, "m_flMaxspeed") ||
        !HasEntProp(client, Prop_Data, "m_vecVelocity"))
    {
        return;
    }

    float originalMaxSpeed = GetEntPropFloat(client, Prop_Data, "m_flMaxspeed");
    if (originalMaxSpeed <= 0.0)
    {
        return;
    }

    float velocity[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
    float currentSpeed = GetVectorLength(velocity);
    float requiredMaxSpeed = (currentSpeed / 1.1) + 1.0;

    // No override is needed until the player's current momentum exceeds the stock 1.1x cap.
    if (requiredMaxSpeed <= originalMaxSpeed)
    {
        return;
    }

    g_fBunnyOriginalMaxSpeed[client] = originalMaxSpeed;
    g_bBunnyMaxSpeedOverride[client] = true;
    SetEntPropFloat(client, Prop_Data, "m_flMaxspeed", requiredMaxSpeed);
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3],
    const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed,
    const int mouse[2])
{
    RestoreBunnyMaxSpeed(client);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float move[3], float angles[3],
    int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return Plugin_Continue;
    }

    float inputTime = GetGameTime();
    if (g_fConcussionDspUntil[client] > 0.0 && inputTime >= g_fConcussionDspUntil[client])
    {
        ClientCommand(client, "dsp_player 0");
        g_fConcussionDspUntil[client] = 0.0;
        g_iConcussionDspEffect[client] = 0;
    }
    UpdateRSPTemporaryVoiceMute(client);
    UpdateSapperPlantAnimationRate(client);

    if (g_bSpectatorActive[client])
    {
        if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
            !IsPlayerAlive(client) || g_iPower[client] != RSP_Spectator ||
            g_iAssignedRound[client] != g_iRoundSerial || g_hSpectatorTimer[client] == null)
        {
            StopSpectatorMode(client, false);
            return Plugin_Changed;
        }
        buttons &= (IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT | IN_JUMP | IN_DUCK);
        impulse = 0;
        weapon = 0;
        subtype = 0;
        move[2] = 0.0;
        return Plugin_Changed;
    }

    if (g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActiveForClient(client) &&
        IsPlayerAlive(client) && g_fFrozenUntil[client] > inputTime)
    {
        // Full freeze gate runs before gifts, ability input, weapon input, or movement
        // processing so a frozen player cannot create misleading gameplay feedback.
        if (g_bHookActive[client])
            StopHook(client);

        buttons &= IN_SCORE;
        impulse = 0;
        weapon = 0;
        subtype = 0;
        move[0] = 0.0;
        move[1] = 0.0;
        move[2] = 0.0;
        g_bDoubleJumpWasDown[client] = false;
        if (HasEntProp(client, Prop_Data, "m_vecVelocity"))
        {
            float frozenVelocity[3] = {0.0, 0.0, 0.0};
            SetEntPropVector(client, Prop_Data, "m_vecVelocity", frozenVelocity);
        }
        return Plugin_Changed;
    }

    if (g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActiveForClient(client) &&
        IsPlayerAlive(client))
    {
        // Keep a small rolling buffer for living players, not just current Anomaly owners.
        // This lets a newly assigned Anomaly use the actual position from 7 seconds earlier.
        RecordAnomalyPosition(client);
    }

    bool commandChanged = false;

    // Hook never owns player input. Keep the original movement command, view angles,
    // firing, reloading and weapon switching untouched while the rope pulls.
    // Space only releases the rope; the same user command continues through normal
    // Source movement so the jump and the current airborne momentum are preserved.
    if (g_bHookActive[client])
    {
        if (g_hHookTimer[client] == null || !g_bEnabled || !g_bSupportedMap ||
            !IsPlayerAlive(client) || !IsRSPPowerRuntimeActiveForClient(client) ||
            g_iPower[client] != RSP_Hook || g_iAssignedRound[client] != g_iRoundSerial)
        {
            StopHook(client);
        }
        else if ((buttons & IN_JUMP) != 0)
        {
            StopHook(client);
        }
    }

    // Legacy Aimbot redirects only firearm shots toward a visible enemy head. Any body
    // hit is also normalized to headshot damage/feedback by TraceAttack and the events.
    // Ghost, walls, non-firearms and the round freeze are still excluded.
    if (g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActiveForClient(client) &&
        IsPlayerAlive(client) && g_bRoundFreezeEnded &&
        g_iPower[client] == RSP_Aimbot && g_iAssignedRound[client] == g_iRoundSerial &&
        (buttons & IN_ATTACK) != 0)
    {
        char aimbotWeapon[32];
        GetClientWeapon(client, aimbotWeapon, sizeof(aimbotWeapon));
        if (IsRSPFirearmEventWeapon(aimbotWeapon) && TryRedirectAimbotShotToHead(client, angles))
        {
            commandChanged = true;
        }
    }

    // Snapshot Toxic Smoke as soon as the player starts priming the smoke grenade.
    // weapon_fire may arrive after player_death has already cleared the active power.
    if (g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActiveForClient(client) && IsPlayerAlive(client) &&
        (buttons & IN_ATTACK) != 0 &&
        (g_iPower[client] == RSP_ToxicSmoke || g_iPower[client] == RSP_HealingSmoke) &&
        g_iAssignedRound[client] == g_iRoundSerial)
    {
        int activeSmokeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
        if (activeSmokeWeapon > MaxClients && IsValidEntity(activeSmokeWeapon))
        {
            char activeSmokeClass[32];
            GetEntityClassname(activeSmokeWeapon, activeSmokeClass, sizeof(activeSmokeClass));
            if (StrEqual(activeSmokeClass, "weapon_smokegrenade", false))
            {
                SnapshotRSPSmokeThrow(client);
            }
        }
    }

    if (g_bNoclipActive[client])
    {
        if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
            !IsPlayerAlive(client) || g_iPower[client] != RSP_NoClip ||
            g_iAssignedRound[client] != g_iRoundSerial)
        {
            StopNoclip(client, false, IsPlayerAlive(client));
        }
        else if (GetGameTime() >= g_fNoclipExpiresAt[client])
        {
            StopNoclip(client, true, true);
        }
        else if (GetGameTime() >= g_fNoclipNextSafeCheckTime[client])
        {
            // During active NoClip, never cancel movement on contact with a wall,
            // floor, prop or even when the player goes outside playable geometry.
            // This timer only refreshes a grounded rescue point; validation happens
            // after the power ends, so open-air deactivation preserves natural falling.
            g_fNoclipNextSafeCheckTime[client] = GetGameTime() + RSP_NOCLIP_SAFE_CHECK_INTERVAL;
            float currentOrigin[3];
            GetClientAbsOrigin(client, currentOrigin);
            bool outsideWorld = IsNoclipPointOutsideWorld(currentOrigin);
            bool hullClear = IsSwapHullPositionClear(client, currentOrigin, client, 0);
            bool groundSupport = HasNoclipGroundSupport(currentOrigin, client);
            float minSpawnZ, maxSpawnZ;
            bool hasSpawnEnvelope = GetNoclipSpawnVerticalBounds(minSpawnZ, maxSpawnZ);
            bool highSupportedSurface = hasSpawnEnvelope &&
                currentOrigin[2] > maxSpawnZ + RSP_NOCLIP_HIGH_RESCUE_MARGIN && groundSupport;
            bool highPlayerClipSurface = IsNoclipElevatedPlayerClipSurface(currentOrigin, client);
            bool elevatedNoDrawSurface = IsNoclipElevatedNoDrawSurface(currentOrigin, client);
            bool elevatedSkySurface = IsNoclipElevatedSkySurface(currentOrigin, client);
            bool skyboxArea = IsNoclipIn3DSkyboxArea(currentOrigin);

            if (!outsideWorld && hullClear && groundSupport &&
                !highSupportedSurface && !highPlayerClipSurface && !elevatedNoDrawSurface &&
                !elevatedSkySurface && !skyboxArea)
            {
                g_bNoclipLastSafeValid[client] = true;
                for (int axis = 0; axis < 3; axis++)
                {
                    g_fNoclipLastSafeOrigin[client][axis] = currentOrigin[axis];
                }
            }
        }
    }

    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) || !IsPlayerAlive(client))
    {
        return Plugin_Continue;
    }

    float commandTime = GetGameTime();

    if (g_iGrounderRound[client] == g_iRoundSerial && g_iGrounderOwnerUserId[client] != 0)
    {
        // Grounder remains active through the post-win restart delay, but only for this
        // life. Event_PlayerDeath removes the lock before the player can respawn.
        if ((buttons & IN_JUMP) != 0)
        {
            buttons &= ~IN_JUMP;
            commandChanged = true;

            // Cancel only the residual grounded jump impulse. Do not touch vertical
            // velocity while the target is walking normally or is airborne.
            if ((GetEntityFlags(client) & FL_ONGROUND) != 0 &&
                HasEntProp(client, Prop_Data, "m_vecVelocity"))
            {
                float groundVelocity[3];
                GetEntPropVector(client, Prop_Data, "m_vecVelocity", groundVelocity);
                if (groundVelocity[2] != 0.0)
                {
                    groundVelocity[2] = 0.0;
                    SetEntPropVector(client, Prop_Data, "m_vecVelocity", groundVelocity);
                }
            }
        }
    }
    else if (g_iGrounderRound[client] != 0 || g_iGrounderOwnerUserId[client] != 0)
    {
        g_iGrounderRound[client] = 0;
        g_iGrounderOwnerUserId[client] = 0;
    }

    bool useIsDown = (buttons & IN_USE) != 0;
    if (useIsDown && !g_bGiftUseWasDown[client])
    {
        TryOpenNearbyGift(client);
    }
    g_bGiftUseWasDown[client] = useIsDown;

    // Reverse Controls is an effect applied by another player's manual power.
    // Invert the target's movement axes, not specific key bindings, for any client config.
    if (g_fReverseControlsUntil[client] > commandTime &&
        g_iReverseControlsRound[client] == g_iRoundSerial)
    {
        move[0] = -move[0];
        move[1] = -move[1];
        commandChanged = true;
    }
    else if (g_fReverseControlsUntil[client] != 0.0)
    {
        g_fReverseControlsUntil[client] = 0.0;
        g_iReverseControlsRound[client] = 0;
        g_iReverseControlsOwnerUserId[client] = 0;
    }

    if (g_iAssignedRound[client] == g_iRoundSerial)
    {
        if (g_iPower[client] == RSP_Dwarf) ApplyDwarfCollisionBounds(client);
        else if (g_iPower[client] == RSP_Giant) ApplyGiantCollisionBounds(client);
        if (g_iPower[client] == RSP_Dwarf || g_iPower[client] == RSP_Giant)
            ApplySelfModelScaleViewOffset(client);
    }

    // Some CSS entity/physics interactions or other movement plugins can overwrite
    // m_flGravity during a live round. Keep the assigned roll stable while this
    // player still owns Low Gravity; never modify global movement ConVars.
    if (g_iPower[client] == RSP_Astronaut &&
        g_iAssignedRound[client] == g_iRoundSerial &&
        g_fLowGravityMultiplier[client] >= RSP_ASTRONAUT_GRAVITY_MIN &&
        g_fLowGravityMultiplier[client] <= RSP_ASTRONAUT_GRAVITY_MAX &&
        HasEntProp(client, Prop_Data, "m_flGravity"))
    {
        float currentGravity = GetEntityGravity(client);
        if (FloatAbs(currentGravity - g_fLowGravityMultiplier[client]) > 0.005)
        {
            SetEntityGravity(client, g_fLowGravityMultiplier[client]);
        }
    }

    if (g_iPower[client] == RSP_Berserker && g_iAssignedRound[client] == g_iRoundSerial &&
        g_bOldMoveSpeedValid[client] && HasEntProp(client, Prop_Data, "m_flLaggedMovementValue"))
    {
        float desiredSpeed = g_fOldMoveSpeed[client] *
            ((GetClientHealth(client) > 0 && GetClientHealth(client) <= RSP_BERSERKER_TRIGGER_HP)
                ? RSP_BERSERKER_SPEED_MULTIPLIER : 1.0);
        float currentSpeed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
        if (FloatAbs(currentSpeed - desiredSpeed) > 0.005)
        {
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", desiredSpeed);
        }
    }

    UpdateWeakeningMovementState(client, commandTime);

    bool jumpIsDown = (buttons & IN_JUMP) != 0;
    bool jumpWasPressed = jumpIsDown && !g_bDoubleJumpWasDown[client];
    g_bDoubleJumpWasDown[client] = jumpIsDown;
    if (g_fDisorientViewUntil[client] > commandTime)
    {
        float yawError = NormalizeRSPAngle(angles[1] - g_fDisorientTargetYaw[client]);
        if (FloatAbs(yawError) <= RSP_DISORIENT_ANGLE_ACK_TOLERANCE)
        {
            // The client's next user command now carries the reversed view angle.
            // Release the correction on acknowledgement so it does not snap back later.
            g_fDisorientViewUntil[client] = 0.0;
            g_fDisorientTargetYaw[client] = 0.0;
        }
        else
        {
            angles[1] = g_fDisorientTargetYaw[client];
            angles[2] = 0.0;
            commandChanged = true;
        }
    }
    else if (g_fDisorientViewUntil[client] != 0.0)
    {
        // Safety timeout: never hold or override the client's view indefinitely.
        g_fDisorientViewUntil[client] = 0.0;
        g_fDisorientTargetYaw[client] = 0.0;
    }
    if (g_fDisorientViewUntil[client] == 0.0 &&
        g_fNextDisorientTime[client] <= commandTime)
    {
        g_iDisorientOwnerUserId[client] = 0;
    }

    if (g_fFrozenUntil[client] != 0.0 && g_fFrozenUntil[client] <= commandTime)
    {
        g_fFrozenUntil[client] = 0.0;
        UpdateRSPTemporaryVoiceMute(client);
        g_iCryoOwnerUserId[client] = 0;
    }

    int flags = GetEntityFlags(client);
    bool onGround = (flags & FL_ONGROUND) != 0;
    if (g_iPower[client] == RSP_Bunny && jumpIsDown)
    {
        if (onGround)
        {
            // Match sv_enablebunnyhopping for this player only: temporarily raise the
            // per-player maxspeed just for this jump command, enough to keep the current
            // momentum below the engine's 1.1x clamp. OnPlayerRunCmdPost restores it.
            PrepareBunnyJumpSpeed(client);
        }
        else
        {
            // Owner-only auto-bhop input handling. Holding jump queues the next landing hop.
            buttons &= ~IN_JUMP;
            return Plugin_Changed;
        }
    }

    if (g_iPower[client] == RSP_DoubleJump)
    {
        if (onGround)
        {
            // The first mid-air bounce becomes available half a second after takeoff.
            g_fDoubleJumpReadyTime[client] = commandTime + RSP_DOUBLE_JUMP_DELAY;
        }
        else if (jumpWasPressed && commandTime >= g_fDoubleJumpReadyTime[client])
        {
            // Each mid-air boost requires a fresh jump-button press; holding the key cannot repeat it.
            float velocity[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
            velocity[2] = RSP_DOUBLE_JUMP_VERTICAL_SPEED;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
            g_fDoubleJumpReadyTime[client] = commandTime + RSP_DOUBLE_JUMP_DELAY;
            commandChanged = true;
        }
    }
    else
    {
        g_fDoubleJumpReadyTime[client] = 0.0;
    }

    return commandChanged ? Plugin_Changed : Plugin_Continue;
}

float NormalizeRSPAngle(float angle)
{
    while (angle > 180.0)
    {
        angle -= 360.0;
    }
    while (angle < -180.0)
    {
        angle += 360.0;
    }
    return angle;
}

bool IsRSPFirearmEventWeapon(const char[] weapon)
{
    char normalized[32];
    strcopy(normalized, sizeof(normalized), weapon);
    if (StrContains(normalized, "weapon_", false) == 0)
    {
        ReplaceString(normalized, sizeof(normalized), "weapon_", "", false);
    }

    return StrEqual(normalized, "usp", false) || StrEqual(normalized, "glock", false) ||
        StrEqual(normalized, "deagle", false) || StrEqual(normalized, "p228", false) ||
        StrEqual(normalized, "fiveseven", false) || StrEqual(normalized, "elite", false) ||
        StrEqual(normalized, "m3", false) || StrEqual(normalized, "xm1014", false) ||
        StrEqual(normalized, "mac10", false) || StrEqual(normalized, "tmp", false) ||
        StrEqual(normalized, "mp5navy", false) || StrEqual(normalized, "ump45", false) ||
        StrEqual(normalized, "p90", false) || StrEqual(normalized, "ak47", false) ||
        StrEqual(normalized, "m4a1", false) || StrEqual(normalized, "galil", false) ||
        StrEqual(normalized, "famas", false) || StrEqual(normalized, "aug", false) ||
        StrEqual(normalized, "sg552", false) || StrEqual(normalized, "scout", false) ||
        StrEqual(normalized, "awp", false) || StrEqual(normalized, "g3sg1", false) ||
        StrEqual(normalized, "sg550", false) || StrEqual(normalized, "m249", false);
}

int GetRSPWeaponMaxClip(int weapon)
{
    if (weapon <= MaxClients || !IsValidEntity(weapon)) return -1;
    char classname[32];
    GetEntityClassname(weapon, classname, sizeof(classname));

    if (StrEqual(classname, "weapon_usp")) return 12;
    if (StrEqual(classname, "weapon_glock")) return 20;
    if (StrEqual(classname, "weapon_deagle")) return 7;
    if (StrEqual(classname, "weapon_p228")) return 13;
    if (StrEqual(classname, "weapon_fiveseven")) return 20;
    if (StrEqual(classname, "weapon_elite")) return 30;
    if (StrEqual(classname, "weapon_m3")) return 8;
    if (StrEqual(classname, "weapon_xm1014")) return 7;
    if (StrEqual(classname, "weapon_mac10")) return 30;
    if (StrEqual(classname, "weapon_tmp")) return 30;
    if (StrEqual(classname, "weapon_mp5navy")) return 30;
    if (StrEqual(classname, "weapon_ump45")) return 25;
    if (StrEqual(classname, "weapon_p90")) return 50;
    if (StrEqual(classname, "weapon_ak47")) return 30;
    if (StrEqual(classname, "weapon_m4a1")) return 30;
    if (StrEqual(classname, "weapon_galil")) return 35;
    if (StrEqual(classname, "weapon_famas")) return 25;
    if (StrEqual(classname, "weapon_aug")) return 30;
    if (StrEqual(classname, "weapon_sg552")) return 30;
    if (StrEqual(classname, "weapon_scout")) return 10;
    if (StrEqual(classname, "weapon_awp")) return 5;
    if (StrEqual(classname, "weapon_g3sg1")) return 20;
    if (StrEqual(classname, "weapon_sg550")) return 20;
    if (StrEqual(classname, "weapon_m249")) return 100;
    return -1;
}

public void Frame_ApplyRapidFireShot(any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) ||
        !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
        g_iPower[client] != RSP_RapidFire || g_fRapidFireMultiplier[client] <= 1.0)
    {
        return;
    }

    int weapon = EntRefToEntIndex(g_iLastFiredWeaponRef[client]);
    if (weapon <= MaxClients || weapon >= RSP_MAX_ENTITIES || !IsValidEntity(weapon) ||
        GetRSPWeaponMaxClip(weapon) <= 0)
    {
        return;
    }

    int weaponRef = EntIndexToEntRef(weapon);
    int ownerUserId = GetClientUserId(client);
    if (g_iRapidFireWeaponEntRef[weapon] != weaponRef)
    {
        ClearRapidFireWeaponTrackingForEntity(weapon);
    }
    if (g_iRapidFireOwnerUserId[weapon] != 0 && g_iRapidFireOwnerUserId[weapon] != ownerUserId)
    {
        RestoreRapidFireAdjustmentsForOwner(g_iRapidFireOwnerUserId[weapon]);
    }
    if (g_iRapidFireWeaponEntRef[weapon] != weaponRef)
    {
        ClearRapidFireWeaponTrackingForEntity(weapon);
        g_iRapidFireWeaponEntRef[weapon] = weaponRef;
    }
    g_iRapidFireOwnerUserId[weapon] = ownerUserId;

    float now = GetGameTime();
    char properties[2][32] = {"m_flNextPrimaryAttack", "m_flNextSecondaryAttack"};
    for (int propertyIndex = 0; propertyIndex < sizeof(properties); propertyIndex++)
    {
        if (!HasEntProp(weapon, Prop_Data, properties[propertyIndex]))
        {
            continue;
        }

        float nextAttack = GetEntPropFloat(weapon, Prop_Data, properties[propertyIndex]);
        if (g_bRapidFireAttackTracked[weapon][propertyIndex])
        {
            // If the current timestamp no longer matches our last write, the engine has
            // advanced the weapon to a new shot; use that fresh timestamp as the baseline.
            if (FloatAbs(nextAttack - g_fRapidFireAppliedNextAttack[weapon][propertyIndex]) <= 0.02)
            {
                continue;
            }
            g_bRapidFireAttackTracked[weapon][propertyIndex] = false;
        }

        float remaining = nextAttack - now;
        if (remaining <= 0.01)
        {
            continue;
        }

        g_fRapidFireOriginalNextAttack[weapon][propertyIndex] = nextAttack;
        float acceleratedTime = now + remaining / g_fRapidFireMultiplier[client];
        SetEntPropFloat(weapon, Prop_Data, properties[propertyIndex], acceleratedTime);
        g_fRapidFireAppliedNextAttack[weapon][propertyIndex] = acceleratedTime;
        g_bRapidFireAttackTracked[weapon][propertyIndex] = true;
    }
}

public void Frame_ApplyInfiniteAmmo(any userid)
{
    int client = GetClientOfUserId(userid);
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
        client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_InfiniteAmmo)
    {
        return;
    }

    int weapon = EntRefToEntIndex(g_iLastFiredWeaponRef[client]);
    if (weapon <= MaxClients || !IsValidEntity(weapon))
    {
        weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    }
    int maxClip = GetRSPWeaponMaxClip(weapon);
    if (maxClip > 0 && HasEntProp(weapon, Prop_Send, "m_iClip1"))
    {
        SetEntProp(weapon, Prop_Send, "m_iClip1", maxClip);
    }
}

// Explosive Bullets uses bullet_impact to learn the fired bullet's final endpoint, then
// traces the actual line from the shooter's eye to that endpoint. This reconstructs the
// first collision before penetrable surfaces/players, instead of exploding behind them.
public void Event_BulletImpact(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        return;
    }

    int attacker = GetClientOfUserId(event.GetInt("userid"));
    if (attacker < 1 || attacker > MaxClients || !IsValidPlayingClient(attacker) ||
        !IsPlayerAlive(attacker) || !IsRSPPowerRuntimeActiveForClient(attacker) ||
        g_iPower[attacker] != RSP_ExplosiveAmmo ||
        g_iAssignedRound[attacker] != g_iRoundSerial ||
        g_bExplosiveBulletDamageInProgress[attacker])
    {
        return;
    }

    char weapon[64];
    GetClientWeapon(attacker, weapon, sizeof(weapon));
    if (!IsRSPFirearmEventWeapon(weapon))
    {
        return;
    }

    // A single FireBullets call can emit several bullet_impact events (penetration,
    // or multiple shotgun pellets). Only one chance/one explosion is processed for
    // this client in the same server tick, preventing duplicate blasts at the first hit.
    int impactTick = GetGameTickCount();
    if (g_iExplosiveBulletLastImpactTick[attacker] == impactTick)
    {
        return;
    }
    g_iExplosiveBulletLastImpactTick[attacker] = impactTick;

    int chancePercent = g_iExplosiveBulletsChancePercent[attacker];
    if (chancePercent < RSP_EXPLOSIVE_AMMO_CHANCE_MIN ||
        chancePercent > RSP_EXPLOSIVE_AMMO_CHANCE_MAX ||
        GetRandomInt(1, 100) > chancePercent)
    {
        return;
    }

    float finalImpact[3];
    finalImpact[0] = event.GetFloat("x");
    finalImpact[1] = event.GetFloat("y");
    finalImpact[2] = event.GetFloat("z");
    if (TR_PointOutsideWorld(finalImpact))
    {
        return;
    }

    float firstImpact[3];
    float impactNormal[3] = {0.0, 0.0, 1.0};
    int impactEntity = -1;
    int impactSurfaceFlags = 0;
    if (!ResolveFirstExplosiveBulletImpact(attacker, finalImpact, firstImpact, impactEntity,
        impactSurfaceFlags, impactNormal) || TR_PointOutsideWorld(firstImpact))
    {
        return;
    }

    CreateExplosiveBulletBlast(attacker, firstImpact, impactEntity, impactSurfaceFlags, impactNormal);
}

bool ResolveFirstExplosiveBulletImpact(int attacker, const float finalImpact[3], float firstImpact[3],
    int &impactEntity, int &impactSurfaceFlags, float impactNormal[3])
{
    impactEntity = -1;
    impactSurfaceFlags = 0;
    impactNormal[0] = 0.0;
    impactNormal[1] = 0.0;
    impactNormal[2] = 1.0;

    if (attacker < 1 || attacker > MaxClients || !IsClientInGame(attacker))
    {
        return false;
    }

    float shootOrigin[3];
    GetClientEyePosition(attacker, shootOrigin);
    if (GetVectorDistance(shootOrigin, finalImpact) < 1.0)
    {
        firstImpact[0] = finalImpact[0];
        firstImpact[1] = finalImpact[1];
        firstImpact[2] = finalImpact[2];
        return true;
    }

    // bullet_impact coordinates can lie exactly on the collision plane. Extend the
    // trace a few units beyond that point so the engine reports the first surface
    // instead of treating the event endpoint as an unobstructed end position.
    float traceDirection[3], traceEnd[3];
    MakeVectorFromPoints(shootOrigin, finalImpact, traceDirection);
    if (NormalizeVector(traceDirection, traceDirection) <= 0.0)
    {
        firstImpact[0] = finalImpact[0];
        firstImpact[1] = finalImpact[1];
        firstImpact[2] = finalImpact[2];
        return true;
    }
    for (int axis = 0; axis < 3; axis++)
    {
        traceEnd[axis] = finalImpact[axis] + traceDirection[axis] * 12.0;
    }

    TR_TraceRayFilter(shootOrigin, traceEnd, MASK_SHOT, RayType_EndPoint,
        TraceFilter_ExplosiveBulletFirstImpact, attacker);
    if (TR_DidHit() && !TR_StartSolid() && !TR_AllSolid())
    {
        TR_GetEndPosition(firstImpact);
        impactEntity = TR_GetEntityIndex();
        impactSurfaceFlags = TR_GetSurfaceFlags(INVALID_HANDLE);
        TR_GetPlaneNormal(INVALID_HANDLE, impactNormal);
        if (NormalizeVector(impactNormal, impactNormal) <= 0.0)
        {
            impactNormal[0] = 0.0;
            impactNormal[1] = 0.0;
            impactNormal[2] = 1.0;
        }
        return true;
    }

    // Trace fallback for unusual entities/content masks: still use the engine event
    // endpoint rather than discarding a valid impact entirely. Its surface type is unknown.
    firstImpact[0] = finalImpact[0];
    firstImpact[1] = finalImpact[1];
    firstImpact[2] = finalImpact[2];
    return true;
}

public bool TraceFilter_ExplosiveBulletFirstImpact(int entity, int contentsMask, any data)
{
    // The ray starts close to the shooter's eye and must never immediately hit its owner.
    return entity != data;
}

bool IsExplosiveBulletDecalSurface(int entity)
{
    if (entity == 0)
    {
        return true; // world BSP geometry
    }
    if (entity <= MaxClients || !IsValidEntity(entity))
    {
        return false; // never project scorch marks onto players or ordinary props
    }

    char classname[64];
    GetEntityClassname(entity, classname, sizeof(classname));
    // Map brush entities can be valid decal surfaces too (e.g. func_brush/func_wall).
    return StrContains(classname, "func_", false) == 0;
}

void CreateExplosiveBulletBlast(int attacker, const float blastOrigin[3], int impactEntity,
    int impactSurfaceFlags, const float impactNormal[3])
{
    if (attacker < 1 || attacker > MaxClients || !IsClientInGame(attacker))
    {
        return;
    }

    // Keep the HE-style temp-entity visual; its built-in audio is suppressed so the
    // spatially attenuated sample below is the sole explosion sound.
    if (g_iExplosiveBulletSprite > 0)
    {
        TE_SetupExplosion(blastOrigin, g_iExplosiveBulletSprite, 1.0, 15,
            TE_EXPLFLAG_NOSOUND, RoundToNearest(RSP_EXPLOSIVE_AMMO_RADIUS),
            RoundToNearest(RSP_EXPLOSIVE_AMMO_DAMAGE));
        TE_SendToAll();
    }

    char explosionSound[64];
    switch (GetRandomInt(1, 3))
    {
        case 1: strcopy(explosionSound, sizeof(explosionSound), RSP_EXPLOSIVE_AMMO_SOUND_1);
        case 2: strcopy(explosionSound, sizeof(explosionSound), RSP_EXPLOSIVE_AMMO_SOUND_2);
        default: strcopy(explosionSound, sizeof(explosionSound), RSP_EXPLOSIVE_AMMO_SOUND_3);
    }
    // SNDLEVEL_NORMAL gives the HE sample natural distance falloff instead of the
    // global-sounding 140 dB gunfire level used by the previous experimental build.
    EmitSoundToAll(explosionSound, SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL,
        SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, blastOrigin);

    // Keep the HE-style explosion visual/sound and add one scorch only on a valid
    // decal-enabled world/brush impact surface.
    bool decalSurfaceAllowed = (impactSurfaceFlags & (SURF_NODECALS | SURF_NODRAW | SURF_SKY)) == 0;
    bool worldSurfaceImpact = IsExplosiveBulletDecalSurface(impactEntity) && decalSurfaceAllowed;
    bool manualWorldScorch = worldSurfaceImpact && g_iExplosiveBulletDecal > 0;

    // env_explosion's built-in scorch trace travels vertically downward from the entity,
    // so it is not tied to the bullet's actual impact point and can miss floor marks or
    // leave a stray mark. Suppress that ray for this custom blast and project the scorch
    // directly onto the traced, decal-enabled world/func_* surface below.
    g_bExplosiveBulletDamageInProgress[attacker] = true;

    bool aliveBefore[MAXPLAYERS + 1];
    int teamBefore[MAXPLAYERS + 1];
    for (int target = 1; target <= MaxClients; target++)
    {
        aliveBefore[target] = false;
        teamBefore[target] = 0;
        if (!IsValidPlayingClient(target) || !IsPlayerAlive(target))
        {
            continue;
        }

        aliveBefore[target] = true;
        teamBefore[target] = GetClientTeam(target);
        // player_death is raised synchronously while env_explosion performs native
        // radius damage, so mark eligible victims before firing its Explode input.
        g_bExplosiveBulletDeathPending[target] = true;
        g_iExplosiveBulletDeathOwnerUserId[target] = GetClientUserId(attacker);
        g_iExplosiveBulletDeathRound[target] = g_iRoundSerial;
    }

    int ownerMoneyBefore = -1;
    if (HasEntProp(attacker, Prop_Send, "m_iAccount"))
    {
        ownerMoneyBefore = GetEntProp(attacker, Prop_Send, "m_iAccount");
    }

    int explosion = CreateEntityByName("env_explosion");
    bool nativeExplosionFired = false;
    if (explosion > MaxClients && IsValidEntity(explosion))
    {
        char magnitude[16], radius[16], spawnFlags[16];
        IntToString(RoundToNearest(RSP_EXPLOSIVE_AMMO_DAMAGE), magnitude, sizeof(magnitude));
        IntToString(RoundToNearest(RSP_EXPLOSIVE_AMMO_RADIUS), radius, sizeof(radius));
        // SF_ENVEXPLOSION_NOFIREBALL | NOSMOKE | NODECAL | NOSPARKS | NOSOUND |
        // NOFIREBALLSMOKE | NOPARTICLES | NODLIGHTS. The HE-style temp entity above
        // retains the explosion visual; the decal is projected at the actual impact point.
        int flags = 4 | 8 | (1 << 4) | 32 | 64 | 128 | 256 | 512;
        IntToString(flags, spawnFlags, sizeof(spawnFlags));
        DispatchKeyValue(explosion, "iMagnitude", magnitude);
        DispatchKeyValue(explosion, "iRadiusOverride", radius);
        DispatchKeyValue(explosion, "spawnflags", spawnFlags);
        DispatchSpawn(explosion);
        TeleportEntity(explosion, blastOrigin, NULL_VECTOR, NULL_VECTOR);

        if (explosion < RSP_MAX_ENTITIES)
        {
            g_iRSPDeathExplosionTeam[explosion] = GetClientTeam(attacker);
        }
        if (HasEntProp(explosion, Prop_Data, "m_hOwnerEntity"))
        {
            SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", attacker);
        }

        nativeExplosionFired = AcceptEntityInput(explosion, "Explode", attacker, attacker);
        if (nativeExplosionFired)
        {
            CreateTimer(0.20, Timer_RemoveExplosion, EntIndexToEntRef(explosion), TIMER_FLAG_NO_MAPCHANGE);
        }
        else if (IsValidEntity(explosion))
        {
            AcceptEntityInput(explosion, "Kill");
        }
    }

    // Explicitly project the scorch for floors, slopes, walls and ceilings alike.
    // The impact surface filter above excludes SKY/NODRAW/NODECALS, players and props.
    if (nativeExplosionFired && manualWorldScorch)
    {
        SendExplosiveBulletScorchDecal(blastOrigin, impactNormal, impactEntity);
    }

    // Defensive fallback for an unexpected missing/failed env_explosion entity.
    // Normal CS:S operation uses the native branch above.
    if (!nativeExplosionFired)
    {
        for (int target = 1; target <= MaxClients; target++)
        {
            if (!aliveBefore[target] || !IsClientInGame(target) || !IsPlayerAlive(target))
            {
                continue;
            }
            if (target != attacker && !CanRSPApplyHitEffect(attacker, target))
            {
                continue;
            }

            float targetOrigin[3];
            GetClientAbsOrigin(target, targetOrigin);
            targetOrigin[2] += 40.0;
            float distance = GetVectorDistance(blastOrigin, targetOrigin);
            if (distance >= RSP_EXPLOSIVE_AMMO_RADIUS)
            {
                continue;
            }

            // CS-style Gaussian attenuation: radius is approximately three standard
            // deviations, matching the current non-legacy CS grenade falloff profile.
            float sigma = RSP_EXPLOSIVE_AMMO_RADIUS / 3.0;
            float exponent = -(distance * distance) / (2.0 * sigma * sigma);
            float falloff = Pow(2.718281828, exponent);
            float damage = RSP_EXPLOSIVE_AMMO_DAMAGE * falloff;
            if (damage < 1.0)
            {
                continue;
            }

            g_bExplosiveBulletDeathPending[target] = true;
            g_iExplosiveBulletDeathOwnerUserId[target] = GetClientUserId(attacker);
            g_iExplosiveBulletDeathRound[target] = g_iRoundSerial;
            SDKHooks_TakeDamage(target, attacker, attacker, damage, DMG_BLAST);
        }
        if (manualWorldScorch)
        {
            SendExplosiveBulletScorchDecal(blastOrigin, impactNormal, impactEntity);
        }
    }

    // Native engine awards have now settled. Normalize each kill sequentially so a
    // multi-kill blast awards exactly $300 per enemy (and the standard team-kill
    // penalty where applicable), without overwriting the preceding kill's correction.
    int moneyCursor = ownerMoneyBefore;
    for (int target = 1; target <= MaxClients; target++)
    {
        if (!aliveBefore[target])
        {
            continue;
        }

        if (IsClientInGame(target) && !IsPlayerAlive(target))
        {
            if (target != attacker && moneyCursor >= 0 && IsClientInGame(attacker))
            {
                ApplyFixedKillCash(attacker, moneyCursor, teamBefore[target]);
                if (HasEntProp(attacker, Prop_Send, "m_iAccount"))
                {
                    moneyCursor = GetEntProp(attacker, Prop_Send, "m_iAccount");
                }
            }
        }
        else if (g_iExplosiveBulletDeathOwnerUserId[target] == GetClientUserId(attacker))
        {
            // The victim survived or was protected; don't leave stale death attribution.
            g_bExplosiveBulletDeathPending[target] = false;
            g_iExplosiveBulletDeathOwnerUserId[target] = 0;
            g_iExplosiveBulletDeathRound[target] = 0;
        }
    }

    g_bExplosiveBulletDamageInProgress[attacker] = false;
}

void SendExplosiveBulletScorchDecal(const float position[3], const float surfaceNormal[3], int impactEntity)
{
    if (g_iExplosiveBulletDecal <= 0)
    {
        return;
    }

    float worldCheckPosition[3];
    for (int axis = 0; axis < 3; axis++)
    {
        worldCheckPosition[axis] = position[axis];
    }
    if (TR_PointOutsideWorld(worldCheckPosition) || !IsExplosiveBulletDecalSurface(impactEntity))
    {
        return;
    }

    // Use a surface-normal-oriented Projected Decal for world BSP as well as func_* brush
    // entities. The 2-unit offset starts just outside the collision plane; the 48-unit
    // projection crosses the impact surface on floors, slopes, walls and ceilings.
    float normal[3], projectionDirection[3], projectionOrigin[3], projectionAngles[3];
    for (int axis = 0; axis < 3; axis++)
    {
        normal[axis] = surfaceNormal[axis];
    }
    if (NormalizeVector(normal, normal) <= 0.0)
    {
        normal[0] = 0.0;
        normal[1] = 0.0;
        normal[2] = 1.0;
    }
    for (int axis = 0; axis < 3; axis++)
    {
        projectionOrigin[axis] = position[axis] + normal[axis] * 2.0;
        projectionDirection[axis] = -normal[axis];
    }
    GetVectorAngles(projectionDirection, projectionAngles);

    TE_Start("Projected Decal");
    TE_WriteVector("m_vecOrigin", projectionOrigin);
    TE_WriteVector("m_angRotation", projectionAngles);
    TE_WriteFloat("m_flDistance", 48.0);
    TE_WriteNum("m_nIndex", g_iExplosiveBulletDecal);
    TE_SendToAll();
}













public void Event_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        return;
    }

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }

    char weapon[32];
    event.GetString("weapon", weapon, sizeof(weapon));

    if (g_bBlackoutActive[client] && IsPlayerAlive(client) &&
        g_iBlackoutRound[client] == g_iRoundSerial && IsRSPFirearmEventWeapon(weapon))
    {
        ResetBlackoutFadeAfterShot(client);
    }

    // Curser resolves one miss per weapon_fire. The counter compares enemy traces from this shot,
    // while the deferred frame supports CSS builds that emit weapon_fire before TraceAttack.
    if (IsPlayerAlive(client) && IsRSPFirearmEventWeapon(weapon))
    {
        QueueCurserShotResolution(client);
    }

    int grenadeType = GetRSPGrenadeType(weapon);
    if (grenadeType != -1 && g_iPower[client] == RSP_Reclaimer &&
        IsPlayerAlive(client) && g_iAssignedRound[client] == g_iRoundSerial &&
        GetRandomInt(1, 100) <= RSP_RECLAIMER_CHANCE)
    {
        QueueReclaimerGrenadeRefund(client, grenadeType);
    }
    if (grenadeType != -1 && IsInfiniteGrenadePowerForType(view_as<RSPPower>(g_iPower[client]), grenadeType) && IsPlayerAlive(client))
    {
        QueueInfiniteGrenadeRefill(client, grenadeType, true);
    }
    if (g_iPower[client] == RSP_Knockback && IsRSPFirearmEventWeapon(weapon) && IsPlayerAlive(client))
    {
        RequestFrame(Frame_ApplyBulletJumpImpulse, GetClientUserId(client));
    }
    if (StrContains(weapon, "flashbang", false) != -1)
    {
        // Keep the owner's power snapshot for the grenade even if the thrower dies
        // and their active power is cleared before the flash detonates.
        g_bLastFlashWasLong[client] = g_iPower[client] == RSP_FlashPro;
        g_fLastLongFlashThrowTime[client] = g_bLastFlashWasLong[client] ? GetGameTime() : 0.0;
        g_iLastLongFlashThrowRound[client] = g_bLastFlashWasLong[client] ? g_iRoundSerial : 0;

        if (HasDeadlyFlashAttribution(client))
        {
            // Snapshot only positive ownership. A late weapon_fire after death must not
            // overwrite the already-recorded Deadly Flash flag with false.
            g_bLastFlashWasDeadly[client] = true;
            g_fLastDeadlyFlashThrowTime[client] = GetGameTime();
            g_iLastDeadlyFlashThrowRound[client] = g_iRoundSerial;
        }
    }
    else if (StrContains(weapon, "hegrenade", false) != -1)
    {
        g_bLastHEWasExecutioner[client] = g_iPower[client] == RSP_Executioner;
        g_bLastHEWasEnder[client] = g_iPower[client] == RSP_EnderGrenade &&
            g_iAssignedRound[client] == g_iRoundSerial;
        g_fLastHEThrowTime[client] = GetGameTime();
        g_iLastHERound[client] = g_iRoundSerial;
    }
    else if (StrContains(weapon, "smokegrenade", false) != -1)
    {
        // Never overwrite a recent positive Toxic Smoke snapshot with false here:
        // on some death/throw sequences weapon_fire can arrive after player_death
        // cleared g_iPower[client]. Keep the launch-time snapshot in that case.
        if ((g_iPower[client] == RSP_ToxicSmoke || g_iPower[client] == RSP_HealingSmoke) &&
            g_iAssignedRound[client] == g_iRoundSerial)
        {
            SnapshotRSPSmokeThrow(client);
        }
        else if (!HasRecentRSPSmokeThrowSnapshot(client))
        {
            g_bLastSmokeWasToxic[client] = false;
            g_bLastSmokeWasHealing[client] = false;
            g_fLastSmokeThrowTime[client] = GetGameTime();
            g_iLastSmokeThrowRound[client] = g_iRoundSerial;
            g_iLastSmokeThrowTeam[client] = GetClientTeam(client);
        }
    }

    if (IsPlayerAlive(client) && IsRSPFirearmEventWeapon(weapon) &&
        g_iExpensiveAmmoOwnerUserId[client] != 0 && g_iExpensiveAmmoRound[client] == g_iRoundSerial)
    {
        if (g_iExpensiveAmmoPendingShots[client] < 32)
        {
            g_iExpensiveAmmoPendingShots[client]++;
        }
        g_iExpensiveAmmoShotTick[client] = GetGameTickCount();
        if (!g_bExpensiveAmmoFrameQueued[client])
        {
            g_bExpensiveAmmoFrameQueued[client] = true;
            RequestFrame(Frame_ResolveExpensiveAmmo, GetClientUserId(client));
        }
    }

    int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if (activeWeapon > MaxClients && activeWeapon < RSP_MAX_ENTITIES && IsValidEntity(activeWeapon))
    {
        g_iLastFiredWeaponRef[client] = EntIndexToEntRef(activeWeapon);
        // Both mechanics are for firearm shots only. Do not touch grenade, knife,
        // C4 or other utility cooldown properties from weapon_fire events.
        int maxClip = GetRSPWeaponMaxClip(activeWeapon);
        if (maxClip > 0 && g_iPower[client] == RSP_RapidFire)
        {
            RequestFrame(Frame_ApplyRapidFireShot, GetClientUserId(client));
        }
        else if (maxClip > 0 && g_iPower[client] == RSP_InfiniteAmmo)
        {
            RequestFrame(Frame_ApplyInfiniteAmmo, GetClientUserId(client));
        }
    }
}

void ShortenFutureTimeProperty(int entity, const char[] prop, float factor)
{
    if (entity <= MaxClients || !IsValidEntity(entity)) return;
    float now = GetGameTime();
    // Prop_Data and Prop_Send can alias the same underlying netprop on CS:S builds.
    // Change the first valid future timestamp only once, avoiding accidental double scaling.
    if (HasEntProp(entity, Prop_Send, prop))
    {
        float value = GetEntPropFloat(entity, Prop_Send, prop);
        if (value > now + 0.05)
        {
            SetEntPropFloat(entity, Prop_Send, prop, now + (value - now) * factor);
            return;
        }
    }
    if (HasEntProp(entity, Prop_Data, prop))
    {
        float value = GetEntPropFloat(entity, Prop_Data, prop);
        if (value > now + 0.05)
        {
            SetEntPropFloat(entity, Prop_Data, prop, now + (value - now) * factor);
        }
    }
}

void SetProgressBarToDeadline(int client, float deadline)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !HasEntProp(client, Prop_Send, "m_iProgressBarDuration") ||
        !HasEntProp(client, Prop_Send, "m_flProgressBarStartTime"))
    {
        return;
    }

    float now = GetGameTime();
    float remaining = deadline - now;
    if (remaining <= 0.0)
    {
        SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
        SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", 0.0);
        return;
    }

    // The engine countdown uses fractional seconds while this netprop is an integer.
    // Use the nearest whole-second duration, then backdate the start time so the bar reaches
    // 100% at the exact server deadline rather than stopping halfway when the action completes.
    int duration = RoundToNearest(remaining);
    if (duration < 1) duration = 1;
    SetEntProp(client, Prop_Send, "m_iProgressBarDuration", duration);
    SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", deadline - float(duration));
}

void RestoreSapperViewModelRate(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    int viewModel = EntRefToEntIndex(g_iSapperViewModelRef[client]);
    if (g_bSapperViewModelRateSaved[client] && viewModel > MaxClients && IsValidEntity(viewModel) &&
        HasEntProp(viewModel, Prop_Send, "m_flPlaybackRate"))
    {
        SetEntPropFloat(viewModel, Prop_Send, "m_flPlaybackRate", g_fSapperViewModelOriginalRate[client]);
    }
    g_iSapperViewModelRef[client] = INVALID_ENT_REFERENCE;
    g_bSapperViewModelRateSaved[client] = false;
    g_fSapperViewModelOriginalRate[client] = 1.0;
}

void StopSapperPlantAnimation(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    RestoreSapperViewModelRate(client);
    if (g_bSapperPlayerRateSaved[client] && IsClientInGame(client) &&
        HasEntProp(client, Prop_Send, "m_flPlaybackRate"))
    {
        SetEntPropFloat(client, Prop_Send, "m_flPlaybackRate", g_fSapperPlayerOriginalRate[client]);
    }
    g_bSapperPlayerRateSaved[client] = false;
    g_fSapperPlayerOriginalRate[client] = 1.0;
    g_bSapperPlantAnimationActive[client] = false;
}

void UpdateSapperPlantAnimationRate(int client)
{
    if (client < 1 || client > MaxClients || !g_bSapperPlantAnimationActive[client])
    {
        return;
    }
    if (!IsSapperPlantClient(client))
    {
        StopSapperPlantAnimation(client);
        return;
    }

    int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if (weapon <= MaxClients || !IsValidEntity(weapon))
    {
        StopSapperPlantAnimation(client);
        return;
    }
    char classname[32];
    GetEntityClassname(weapon, classname, sizeof(classname));
    if (!StrEqual(classname, "weapon_c4", false))
    {
        StopSapperPlantAnimation(client);
        return;
    }

    float factor = GetSapperTimeFactor(client);
    if (factor >= 1.0)
    {
        return;
    }
    float speedMultiplier = 1.0 / factor;

    if (HasEntProp(client, Prop_Send, "m_flPlaybackRate"))
    {
        if (!g_bSapperPlayerRateSaved[client])
        {
            g_fSapperPlayerOriginalRate[client] = GetEntPropFloat(client, Prop_Send, "m_flPlaybackRate");
            if (g_fSapperPlayerOriginalRate[client] < 0.1 || g_fSapperPlayerOriginalRate[client] > 4.0)
            {
                g_fSapperPlayerOriginalRate[client] = 1.0;
            }
            g_bSapperPlayerRateSaved[client] = true;
        }
        float desiredPlayerRate = g_fSapperPlayerOriginalRate[client] * speedMultiplier;
        if (FloatAbs(GetEntPropFloat(client, Prop_Send, "m_flPlaybackRate") - desiredPlayerRate) > 0.03)
        {
            SetEntPropFloat(client, Prop_Send, "m_flPlaybackRate", desiredPlayerRate);
        }
    }

    if (HasEntProp(client, Prop_Send, "m_hViewModel"))
    {
        int viewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel", 0);
        if (viewModel > MaxClients && IsValidEntity(viewModel) &&
            HasEntProp(viewModel, Prop_Send, "m_flPlaybackRate"))
        {
            int viewModelRef = EntIndexToEntRef(viewModel);
            if (!g_bSapperViewModelRateSaved[client] || g_iSapperViewModelRef[client] != viewModelRef)
            {
                RestoreSapperViewModelRate(client);
                g_iSapperViewModelRef[client] = viewModelRef;
                g_fSapperViewModelOriginalRate[client] = GetEntPropFloat(viewModel, Prop_Send, "m_flPlaybackRate");
                if (g_fSapperViewModelOriginalRate[client] < 0.1 || g_fSapperViewModelOriginalRate[client] > 4.0)
                {
                    g_fSapperViewModelOriginalRate[client] = 1.0;
                }
                g_bSapperViewModelRateSaved[client] = true;
            }

            float desiredViewModelRate = g_fSapperViewModelOriginalRate[client] * speedMultiplier;
            if (FloatAbs(GetEntPropFloat(viewModel, Prop_Send, "m_flPlaybackRate") - desiredViewModelRate) > 0.03)
            {
                SetEntPropFloat(viewModel, Prop_Send, "m_flPlaybackRate", desiredViewModelRate);
            }
        }
    }
}

float GetSapperTimeFactor(int client)
{
    int percent = g_iSapperSpeedPercent[client];
    if (percent < RSP_SAPPER_SPEED_MIN || percent > RSP_SAPPER_SPEED_MAX)
    {
        return 1.0;
    }
    // "X% faster" means speed is multiplied by (1 + X/100), so duration is divided
    // by that multiplier. Example: 52% makes a 10-second no-kit defuse take ~6.58 s
    // and a 5-second kit defuse take ~3.29 s. Keep deadlines and the defuse HUD in sync.
    return 1.0 / (1.0 + float(percent) / 100.0);
}

bool IsSapperPlantClient(int client)
{
    return g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive() &&
        client >= 1 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client) &&
        GetClientTeam(client) == CS_TEAM_T && g_iPower[client] == RSP_Sapper &&
        g_iAssignedRound[client] == g_iRoundSerial;
}

bool IsSapperDefuseClient(int client)
{
    return g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive() &&
        client >= 1 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client) &&
        GetClientTeam(client) == CS_TEAM_CT && g_iPower[client] == RSP_Sapper &&
        g_iAssignedRound[client] == g_iRoundSerial;
}

public void Event_BombBeginPlant(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsSapperPlantClient(client))
    {
        g_bSapperPlantAnimationActive[client] = true;
        RequestFrame(Frame_ApplySapperPlant, GetClientUserId(client));
    }
}

public void Event_BombAbortPlant(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client >= 1 && client <= MaxClients)
    {
        StopSapperPlantAnimation(client);
    }
}

public void Event_BombPlanted(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client >= 1 && client <= MaxClients)
    {
        StopSapperPlantAnimation(client);
    }
}

public void Frame_ApplySapperPlant(any userid)
{
    int client = GetClientOfUserId(userid);
    if (!IsSapperPlantClient(client))
    {
        return;
    }
    float factor = GetSapperTimeFactor(client);
    if (factor >= 1.0) return;
    int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    ShortenFutureTimeProperty(weapon, "m_fArmedTime", factor);
    ShortenFutureTimeProperty(weapon, "m_flNextPrimaryAttack", factor);
    ShortenFutureTimeProperty(weapon, "m_flNextSecondaryAttack", factor);

    // Keep native CS:S planting HUD behavior: Sapper accelerates the weapon deadline
    // and the viewmodel/player animation, but must not introduce an extra progress bar.
    UpdateSapperPlantAnimationRate(client);
}

public void Event_BombBeginDefuse(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsSapperDefuseClient(client))
    {
        RequestFrame(Frame_ApplySapperDefuse, GetClientUserId(client));
    }
}

public void Frame_ApplySapperDefuse(any userid)
{
    int client = GetClientOfUserId(userid);
    if (!IsSapperDefuseClient(client))
    {
        return;
    }
    float factor = GetSapperTimeFactor(client);
    if (factor >= 1.0) return;

    int bomb = -1;
    while ((bomb = FindEntityByClassname(bomb, "planted_c4")) != -1)
    {
        if (!IsValidEntity(bomb) || !HasEntProp(bomb, Prop_Send, "m_flDefuseCountDown"))
        {
            continue;
        }
        float now = GetGameTime();
        float deadline = GetEntPropFloat(bomb, Prop_Send, "m_flDefuseCountDown");
        if (deadline > now + 0.05)
        {
            float acceleratedDeadline = now + (deadline - now) * factor;
            SetEntPropFloat(bomb, Prop_Send, "m_flDefuseCountDown", acceleratedDeadline);
            SetProgressBarToDeadline(client, acceleratedDeadline);
        }
    }
}

public void Frame_ResolveExpensiveAmmo(any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients)
    {
        return;
    }
    int pending = g_iExpensiveAmmoPendingShots[client];
    int shotTick = g_iExpensiveAmmoShotTick[client];
    g_iExpensiveAmmoPendingShots[client] = 0;
    g_bExpensiveAmmoFrameQueued[client] = false;
    if (pending <= 0 || !IsClientInGame(client) || !g_bEnabled || !g_bSupportedMap ||
        g_iExpensiveAmmoOwnerUserId[client] == 0 || g_iExpensiveAmmoRound[client] != g_iRoundSerial)
    {
        return;
    }
    // TraceAttack and weapon_fire can arrive in either order on CSS builds. A teammate trace in
    // the same game tick exempts the shot batch, preserving Friendly Fire's healing use case.
    if (g_iLastFriendlyTraceTick[client] == shotTick)
    {
        return;
    }
    if (!HasEntProp(client, Prop_Send, "m_iAccount"))
    {
        return;
    }
    int money = GetEntProp(client, Prop_Send, "m_iAccount");
    int cost = pending * RSP_EXTORTION_COST;
    if (cost > money) cost = money;
    if (cost > 0) SetEntProp(client, Prop_Send, "m_iAccount", money - cost);
}

void SnapshotRSPSmokeThrow(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
        (g_iPower[client] != RSP_ToxicSmoke && g_iPower[client] != RSP_HealingSmoke) ||
        g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    int team = GetClientTeam(client);
    if (team != CS_TEAM_CT && team != CS_TEAM_T)
    {
        return;
    }

    g_bLastSmokeWasToxic[client] = g_iPower[client] == RSP_ToxicSmoke;
    g_bLastSmokeWasHealing[client] = g_iPower[client] == RSP_HealingSmoke;
    g_fLastSmokeThrowTime[client] = GetGameTime();
    g_iLastSmokeThrowRound[client] = g_iRoundSerial;
    g_iLastSmokeThrowTeam[client] = team;
}

bool HasRecentRSPSmokeThrowSnapshot(int client)
{
    if (client < 1 || client > MaxClients ||
        (!g_bLastSmokeWasToxic[client] && !g_bLastSmokeWasHealing[client]) ||
        g_iLastSmokeThrowRound[client] != g_iRoundSerial)
    {
        return false;
    }

    float age = GetGameTime() - g_fLastSmokeThrowTime[client];
    return age >= 0.0 && age <= RSP_TOXIC_SMOKE_THROW_MAX_AGE;
}

int FindTrackedSmokeProjectileAt(int ownerUserId, const float detonationOrigin[3])
{
    int bestEntity = -1;
    float bestDistance = 256.0;
    float now = GetGameTime();

    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iSmokeProjectileOwnerUserId[entity] != ownerUserId ||
            g_iSmokeProjectileType[entity] == 0 ||
            g_iSmokeProjectileRound[entity] != g_iRoundSerial ||
            g_fSmokeProjectileSpawnTime[entity] <= 0.0 ||
            now - g_fSmokeProjectileSpawnTime[entity] > RSP_SMOKE_PROJECTILE_MAX_AGE ||
            !IsValidEntity(entity) || !HasEntProp(entity, Prop_Send, "m_vecOrigin"))
        {
            continue;
        }

        float projectileOrigin[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", projectileOrigin);
        float distance = GetVectorDistance(projectileOrigin, detonationOrigin);
        if (distance < bestDistance)
        {
            bestDistance = distance;
            bestEntity = entity;
        }
    }

    return bestEntity;
}

void CreateRSPSmokeCloud(int ownerUserId, int ownerTeam, const float origin[3], int cloudType)
{
    if ((cloudType != RSP_SMOKE_CLOUD_TOXIC && cloudType != RSP_SMOKE_CLOUD_HEALING) ||
        (ownerTeam != CS_TEAM_CT && ownerTeam != CS_TEAM_T))
    {
        return;
    }

    int freeSlot = -1;
    float oldestExpiry = GetGameTime() + RSP_TOXIC_SMOKE_DURATION;
    for (int slot = 0; slot < RSP_TOXIC_SMOKE_MAX_CLOUDS; slot++)
    {
        if (!g_bToxicSmokeCloudActive[slot])
        {
            freeSlot = slot;
            break;
        }
        if (g_fToxicSmokeCloudExpires[slot] < oldestExpiry)
        {
            oldestExpiry = g_fToxicSmokeCloudExpires[slot];
            freeSlot = slot;
        }
    }

    if (freeSlot == -1)
    {
        return;
    }

    float now = GetGameTime();
    g_bToxicSmokeCloudActive[freeSlot] = true;
    g_iToxicSmokeCloudType[freeSlot] = cloudType;
    g_iToxicSmokeCloudOwnerUserId[freeSlot] = ownerUserId;
    g_iToxicSmokeCloudTeam[freeSlot] = ownerTeam;
    g_iToxicSmokeCloudRound[freeSlot] = g_iRoundSerial;
    g_fToxicSmokeCloudOrigin[freeSlot][0] = origin[0];
    g_fToxicSmokeCloudOrigin[freeSlot][1] = origin[1];
    g_fToxicSmokeCloudOrigin[freeSlot][2] = origin[2];
    g_fToxicSmokeCloudExpires[freeSlot] = now + RSP_TOXIC_SMOKE_DURATION;
    g_fToxicSmokeCloudNextDamage[freeSlot] = now + RSP_TOXIC_SMOKE_TICK_INTERVAL;

    if (g_hToxicSmokeTimer == null)
    {
        g_hToxicSmokeTimer = CreateTimer(RSP_TOXIC_SMOKE_TIMER_INTERVAL, Timer_ToxicSmokeDamage,
            _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    }
}

int GetRSPGrenadeType(const char[] weaponName)
{
    if (StrEqual(weaponName, "hegrenade", false) || StrEqual(weaponName, "weapon_hegrenade", false))
    {
        return RSP_GRENADE_HE;
    }
    if (StrEqual(weaponName, "flashbang", false) || StrEqual(weaponName, "weapon_flashbang", false))
    {
        return RSP_GRENADE_FLASH;
    }
    if (StrEqual(weaponName, "smokegrenade", false) || StrEqual(weaponName, "weapon_smokegrenade", false))
    {
        return RSP_GRENADE_SMOKE;
    }
    return -1;
}

bool IsInfiniteGrenadePowerForType(RSPPower power, int grenadeType)
{
    if (grenadeType == RSP_GRENADE_HE)
    {
        return power == RSP_Grenadier;
    }
    if (grenadeType == RSP_GRENADE_FLASH)
    {
        return power == RSP_Sunshine;
    }
    if (grenadeType == RSP_GRENADE_SMOKE)
    {
        return power == RSP_Smoker;
    }
    return false;
}

void QueueInfiniteGrenadeRefill(int client, int grenadeType, bool fromWeaponFire)
{
    if (grenadeType < 0 || grenadeType >= RSP_GRENADE_TYPE_COUNT ||
        client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !IsPlayerAlive(client) || !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
        !IsInfiniteGrenadePowerForType(view_as<RSPPower>(g_iPower[client]), grenadeType) || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    float now = GetGameTime();
    if (!fromWeaponFire)
    {
        if (g_hInfiniteGrenadeRefillTimer[client][grenadeType] != null)
        {
            return;
        }
        float age = now - g_fInfiniteGrenadeLastFireTime[client][grenadeType];
        if (g_fInfiniteGrenadeLastFireTime[client][grenadeType] > 0.0 &&
            age >= 0.0 && age <= RSP_INFINITE_GRENADE_FALLBACK_GUARD)
        {
            return;
        }
        // The detonation event is the fallback for builds where weapon_fire was absent.
        g_fInfiniteGrenadeLastFireTime[client][grenadeType] = now;
    }
    else
    {
        g_fInfiniteGrenadeLastFireTime[client][grenadeType] = now;
    }

    if (g_hInfiniteGrenadeRefillTimer[client][grenadeType] != null)
    {
        return;
    }

    DataPack pack;
    Handle timer = CreateDataTimer(RSP_INFINITE_GRENADE_REFILL_DELAY,
        Timer_RefillInfiniteGrenade, pack, TIMER_FLAG_NO_MAPCHANGE);
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(grenadeType);
    g_hInfiniteGrenadeRefillTimer[client][grenadeType] = timer;
}

void StopInfiniteGrenadeRefillTimers(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }
    for (int grenadeType = 0; grenadeType < RSP_GRENADE_TYPE_COUNT; grenadeType++)
    {
        if (g_hInfiniteGrenadeRefillTimer[client][grenadeType] != null)
        {
            delete g_hInfiniteGrenadeRefillTimer[client][grenadeType];
            g_hInfiniteGrenadeRefillTimer[client][grenadeType] = null;
        }
        if (g_hReclaimerRefillTimer[client][grenadeType] != null)
        {
            delete g_hReclaimerRefillTimer[client][grenadeType];
            g_hReclaimerRefillTimer[client][grenadeType] = null;
        }
        g_fInfiniteGrenadeLastFireTime[client][grenadeType] = 0.0;
    }
}

int FindRSPInventoryWeapon(int client, const char[] wantedClassname)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !HasEntProp(client, Prop_Send, "m_hMyWeapons"))
    {
        return -1;
    }
    int count = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
    for (int index = 0; index < count; index++)
    {
        int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", index);
        if (weapon <= MaxClients || !IsValidEntity(weapon))
        {
            continue;
        }
        char classname[64];
        GetEntityClassname(weapon, classname, sizeof(classname));
        if (StrEqual(classname, wantedClassname, false))
        {
            return weapon;
        }
    }
    return -1;
}

void SetRSPGrenadeAmmoToOne(int client, int weapon)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        weapon <= MaxClients || !IsValidEntity(weapon) ||
        !HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType") ||
        !HasEntProp(client, Prop_Send, "m_iAmmo"))
    {
        return;
    }
    char classname[64];
    GetEntityClassname(weapon, classname, sizeof(classname));
    if (GetRSPGrenadeType(classname) == -1)
    {
        return;
    }
    int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if (ammoType < 0 || ammoType >= 32)
    {
        return;
    }
    // Match the proven GunGame refill method: one real grenade in the client's ammo pool,
    // not a fake high ammo count and not a dropped replacement entity.
    SetEntProp(client, Prop_Send, "m_iAmmo", 1, 4, ammoType);
}

public Action Timer_RefillInfiniteGrenade(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    int grenadeType = pack.ReadCell();
    int client = GetClientOfUserId(userid);

    if (client >= 1 && client <= MaxClients && grenadeType >= 0 && grenadeType < RSP_GRENADE_TYPE_COUNT &&
        g_hInfiniteGrenadeRefillTimer[client][grenadeType] == timer)
    {
        g_hInfiniteGrenadeRefillTimer[client][grenadeType] = null;
    }

    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) ||
        !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
        !IsInfiniteGrenadePowerForType(view_as<RSPPower>(g_iPower[client]), grenadeType) || g_iAssignedRound[client] != g_iRoundSerial ||
        grenadeType < 0 || grenadeType >= RSP_GRENADE_TYPE_COUNT)
    {
        return Plugin_Stop;
    }

    static const char grenadeClasses[RSP_GRENADE_TYPE_COUNT][32] =
    {
        "weapon_hegrenade", "weapon_flashbang", "weapon_smokegrenade"
    };
    int existing = FindRSPInventoryWeapon(client, grenadeClasses[grenadeType]);
    if (existing > MaxClients && IsValidEntity(existing))
    {
        SetRSPGrenadeAmmoToOne(client, existing);
        return Plugin_Stop;
    }

    int grenade = GivePlayerItem(client, grenadeClasses[grenadeType]);
    if (grenade > MaxClients && IsValidEntity(grenade))
    {
        SetRSPGrenadeAmmoToOne(client, grenade);
    }
    return Plugin_Stop;
}

void QueueReclaimerGrenadeRefund(int client, int grenadeType)
{
    if (client < 1 || client > MaxClients || grenadeType < 0 ||
        grenadeType >= RSP_GRENADE_TYPE_COUNT || !IsClientInGame(client) ||
        !IsPlayerAlive(client) || g_iPower[client] != RSP_Reclaimer ||
        g_iAssignedRound[client] != g_iRoundSerial ||
        g_hReclaimerRefillTimer[client][grenadeType] != null)
    {
        return;
    }
    DataPack pack;
    Handle timer = CreateDataTimer(RSP_INFINITE_GRENADE_REFILL_DELAY,
        Timer_ReclaimerGrenadeRefund, pack, TIMER_FLAG_NO_MAPCHANGE);
    if (timer == null) return;
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(grenadeType);
    g_hReclaimerRefillTimer[client][grenadeType] = timer;
}

public Action Timer_ReclaimerGrenadeRefund(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    int grenadeType = pack.ReadCell();
    int client = GetClientOfUserId(userid);
    if (client >= 1 && client <= MaxClients && grenadeType >= 0 &&
        grenadeType < RSP_GRENADE_TYPE_COUNT &&
        g_hReclaimerRefillTimer[client][grenadeType] == timer)
    {
        g_hReclaimerRefillTimer[client][grenadeType] = null;
    }
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !IsPlayerAlive(client) || g_iPower[client] != RSP_Reclaimer ||
        g_iAssignedRound[client] != g_iRoundSerial ||
        grenadeType < 0 || grenadeType >= RSP_GRENADE_TYPE_COUNT)
    {
        return Plugin_Stop;
    }
    static const char classes[RSP_GRENADE_TYPE_COUNT][32] =
    {
        "weapon_hegrenade", "weapon_flashbang", "weapon_smokegrenade"
    };
    int weapon = FindRSPInventoryWeapon(client, classes[grenadeType]);
    if (weapon > MaxClients && IsValidEntity(weapon) &&
        HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType") &&
        HasEntProp(client, Prop_Send, "m_iAmmo"))
    {
        int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
        if (ammoType >= 0 && ammoType < 32)
        {
            int count = GetEntProp(client, Prop_Send, "m_iAmmo", 4, ammoType);
            int maxCount = grenadeType == RSP_GRENADE_FLASH ? 2 : 1;
            if (count < maxCount)
                SetEntProp(client, Prop_Send, "m_iAmmo", count + 1, 4, ammoType);
        }
        return Plugin_Stop;
    }
    int added = GivePlayerItem(client, classes[grenadeType]);
    if (added > MaxClients && IsValidEntity(added))
        SetRSPGrenadeAmmoToOne(client, added);
    return Plugin_Stop;
}

int FindTrackedEnderGrenadeNearOrigin(int ownerUserId, const float blastOrigin[3])
{
    int bestEntity = -1;
    float bestDistanceSquared = 128.0 * 128.0;
    float projectileOrigin[3];

    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (!IsValidEntity(entity) || !g_bHEProjectileEnder[entity] ||
            g_iHEProjectileRound[entity] != g_iRoundSerial)
        {
            continue;
        }
        if (ownerUserId != 0 && g_iHEProjectileOwnerUserId[entity] != ownerUserId)
        {
            continue;
        }

        if (HasEntProp(entity, Prop_Send, "m_vecOrigin"))
        {
            GetEntPropVector(entity, Prop_Send, "m_vecOrigin", projectileOrigin);
        }
        else if (HasEntProp(entity, Prop_Data, "m_vecOrigin"))
        {
            GetEntPropVector(entity, Prop_Data, "m_vecOrigin", projectileOrigin);
        }
        else
        {
            continue;
        }

        float distanceSquared = GetVectorDistance(projectileOrigin, blastOrigin, true);
        if (distanceSquared < bestDistanceSquared)
        {
            bestDistanceSquared = distanceSquared;
            bestEntity = entity;
        }
    }
    return bestEntity;
}

bool IsEnderGrenadeSpawnHullClear(int client, const float origin[3])
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return false;
    }

    float checkOrigin[3];
    for (int axis = 0; axis < 3; axis++) checkOrigin[axis] = origin[axis];
    if (TR_PointOutsideWorld(checkOrigin))
    {
        return false;
    }

    float hullMins[3], hullMaxs[3];
    GetClientMins(client, hullMins);
    GetClientMaxs(client, hullMaxs);

    // The ground ray excludes playerclip so it cannot select clip brushes as a floor.
    // The full player-hull clearance intentionally uses MASK_PLAYERSOLID instead,
    // so a candidate is rejected if the player's body would overlap playerclip or
    // monsterclip volumes, plus solid props and other players.
    TR_TraceHullFilter(origin, origin, hullMins, hullMaxs,
        MASK_PLAYERSOLID | CONTENTS_DEBRIS | CONTENTS_HITBOX,
        TraceFilter_EnderSpawnHull, client);

    return !TR_StartSolid() && !TR_AllSolid() && (!TR_DidHit() || TR_GetFraction() >= 0.999);
}

public bool TraceFilter_EnderSpawnHull(int entity, int contentsMask, any owner)
{
    // Ignore the teleporting player's own current hull; every other entity,
    // including teammates/opponents and solid props, remains an obstruction.
    return entity != owner;
}

bool FindEnderGrenadeGroundAtXY(int client, const float xy[3], float referenceZ, float ground[3])
{
    float rayStart[3], rayEnd[3], hitPosition[3], planeNormal[3];
    rayStart[0] = xy[0];
    rayStart[1] = xy[1];
    rayStart[2] = referenceZ + 64.0;
    rayEnd[0] = xy[0];
    rayEnd[1] = xy[1];
    rayEnd[2] = referenceZ - 16384.0;

    // A grenade may detonate high above the playable floor. Walk downward
    // through up to eight unsuitable surfaces (clip/nodraw/sky/steep) until a
    // genuine, walkable surface is found below them.
    for (int surfacePass = 0; surfacePass < 8; surfacePass++)
    {
        if (rayStart[2] <= rayEnd[2] + 8.0)
        {
            return false;
        }

        TR_TraceRayFilter(rayStart, rayEnd,
            MASK_SOLID | CONTENTS_DEBRIS | CONTENTS_HITBOX,
            RayType_EndPoint, TraceFilter_EnderGround, client);
        if (!TR_DidHit() || TR_StartSolid() || TR_AllSolid())
        {
            return false;
        }

        TR_GetEndPosition(hitPosition);
        int surfaceFlags = TR_GetSurfaceFlags(INVALID_HANDLE);
        TR_GetPlaneNormal(INVALID_HANDLE, planeNormal);

        bool unusableSurface = TR_PointOutsideWorld(hitPosition) ||
            (surfaceFlags & (SURF_NODRAW | SURF_SKY)) != 0 ||
            planeNormal[2] < 0.70;
        if (unusableSurface)
        {
            rayStart[2] = hitPosition[2] - 8.0;
            continue;
        }

        // Keep the player's feet just above the actual ground plane.
        ground[0] = hitPosition[0] + planeNormal[0] * 2.0;
        ground[1] = hitPosition[1] + planeNormal[1] * 2.0;
        ground[2] = hitPosition[2] + planeNormal[2] * 2.0;

        if (IsEnderGrenadeSpawnHullClear(client, ground))
        {
            return true;
        }

        // If the floor is real but the player hull cannot fit there (low ceiling,
        // prop, or another player), continue below it and test the next surface.
        rayStart[2] = hitPosition[2] - 8.0;
    }

    return false;
}

public bool TraceFilter_EnderGround(int entity, int contentsMask, any data)
{
    if (entity >= 1 && entity <= MaxClients)
    {
        return false;
    }

    // Most func_*clip surfaces are already excluded by MASK_SOLID. Explicitly
    // skip any brush/prop entity whose classname still identifies it as a clip.
    if (entity > MaxClients && IsValidEntity(entity))
    {
        char classname[64];
        GetEntityClassname(entity, classname, sizeof(classname));
        if (StrContains(classname, "clip", false) != -1)
        {
            return false;
        }
    }

    return true;
}

bool FindSafeEnderGrenadeDestination(int client, const float blastOrigin[3], float destination[3])
{
    float xy[3], ground[3];

    // Search the requested default radius first. Only if no safe ground exists
    // anywhere in this 350-unit area do we search the expanded 3x radius.
    for (int pass = 0; pass < 2; pass++)
    {
        int firstRadius = (pass == 0) ? 0 : 400;
        int radiusStep = (pass == 0) ? 35 : 65;
        int maxRadius = (pass == 0) ? 350 : 1050;

        for (int radius = firstRadius; radius <= maxRadius; radius += radiusStep)
        {
            int directions = (radius == 0) ? 1 : 16;
            for (int direction = 0; direction < directions; direction++)
            {
                float radians = float(direction) * 6.28318530718 / float(directions);
                xy[0] = blastOrigin[0] + Cosine(radians) * float(radius);
                xy[1] = blastOrigin[1] + Sine(radians) * float(radius);
                xy[2] = blastOrigin[2];

                if (!FindEnderGrenadeGroundAtXY(client, xy, blastOrigin[2], ground))
                {
                    continue;
                }

                destination[0] = ground[0];
                destination[1] = ground[1];
                destination[2] = ground[2];
                return true;
            }
        }
    }

    return false;
}

void HandleEnderGrenadeDetonation(int eventOwnerUserId, const float blastOrigin[3])
{
    int projectile = FindTrackedEnderGrenadeNearOrigin(eventOwnerUserId, blastOrigin);
    bool enderDetonation = projectile > MaxClients && projectile < RSP_MAX_ENTITIES && IsValidEntity(projectile);
    int ownerUserId = eventOwnerUserId;
    if (enderDetonation)
    {
        ownerUserId = g_iHEProjectileOwnerUserId[projectile];
    }
    else
    {
        int eventOwner = GetClientOfUserId(eventOwnerUserId);
        if (eventOwner < 1 || eventOwner > MaxClients || !IsClientInGame(eventOwner) ||
            !g_bLastHEWasEnder[eventOwner] || g_iLastHERound[eventOwner] != g_iRoundSerial)
        {
            return;
        }
        float age = GetGameTime() - g_fLastHEThrowTime[eventOwner];
        if (age < 0.0 || age > RSP_ENDER_GRENADE_MAX_FLIGHT_TIME)
        {
            return;
        }
        enderDetonation = true;
        ownerUserId = GetClientUserId(eventOwner);
    }

    if (!enderDetonation)
    {
        return;
    }

    int owner = GetClientOfUserId(ownerUserId);
    if (owner < 1 || owner > MaxClients || !IsValidPlayingClient(owner) || !IsPlayerAlive(owner))
    {
        return;
    }

    float destination[3];
    if (!FindSafeEnderGrenadeDestination(owner, blastOrigin, destination))
    {
        // Never teleport into solid geometry if this detonation site has no safe nearby hull.
        return;
    }

    float zeroVelocity[3] = {0.0, 0.0, 0.0};
    TeleportEntity(owner, destination, NULL_VECTOR, zeroVelocity);
}

public void Event_HEGrenadeDetonate(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        return;
    }

    float blastOrigin[3];
    blastOrigin[0] = event.GetFloat("x");
    blastOrigin[1] = event.GetFloat("y");
    blastOrigin[2] = event.GetFloat("z");
    int ownerUserId = event.GetInt("userid");
    HandleEnderGrenadeDetonation(ownerUserId, blastOrigin);

    int owner = GetClientOfUserId(ownerUserId);
    if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner))
    {
        QueueInfiniteGrenadeRefill(owner, RSP_GRENADE_HE, false);
    }
}

public void Event_SmokeGrenadeDetonate(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        return;
    }

    int ownerUserId = event.GetInt("userid");
    int owner = GetClientOfUserId(ownerUserId);
    if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner))
    {
        QueueInfiniteGrenadeRefill(owner, RSP_GRENADE_SMOKE, false);
    }

    float origin[3];
    origin[0] = event.GetFloat("x");
    origin[1] = event.GetFloat("y");
    origin[2] = event.GetFloat("z");

    int cloudType = 0;
    int ownerTeam = 0;
    int projectile = FindTrackedSmokeProjectileAt(ownerUserId, origin);
    if (projectile > MaxClients && IsValidEntity(projectile))
    {
        cloudType = g_iSmokeProjectileType[projectile];
        ownerTeam = g_iSmokeProjectileTeam[projectile];
        g_iSmokeProjectileOwnerUserId[projectile] = 0;
        g_iSmokeProjectileTeam[projectile] = 0;
        g_iSmokeProjectileRound[projectile] = 0;
        g_iSmokeProjectileType[projectile] = 0;
        g_fSmokeProjectileSpawnTime[projectile] = 0.0;
    }

    if (cloudType == 0 && owner >= 1 && owner <= MaxClients && IsClientInGame(owner) &&
        HasRecentRSPSmokeThrowSnapshot(owner))
    {
        float age = GetGameTime() - g_fLastSmokeThrowTime[owner];
        if (age >= 0.0 && age <= RSP_TOXIC_SMOKE_THROW_MAX_AGE)
        {
            cloudType = g_bLastSmokeWasHealing[owner]
                ? RSP_SMOKE_CLOUD_HEALING : RSP_SMOKE_CLOUD_TOXIC;
            ownerTeam = g_iLastSmokeThrowTeam[owner];
        }
    }

    if (cloudType == 0 || (ownerTeam != CS_TEAM_CT && ownerTeam != CS_TEAM_T))
    {
        return;
    }

    CreateRSPSmokeCloud(ownerUserId, ownerTeam, origin, cloudType);

    if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner))
    {
        g_bLastSmokeWasToxic[owner] = false;
        g_bLastSmokeWasHealing[owner] = false;
        g_fLastSmokeThrowTime[owner] = 0.0;
        g_iLastSmokeThrowRound[owner] = 0;
        g_iLastSmokeThrowTeam[owner] = 0;
    }
}

public Action Timer_ToxicSmokeDamage(Handle timer, any data)
{
    if (g_hToxicSmokeTimer != timer)
    {
        return Plugin_Stop;
    }

    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        for (int slot = 0; slot < RSP_TOXIC_SMOKE_MAX_CLOUDS; slot++)
        {
            g_bToxicSmokeCloudActive[slot] = false;
            g_iToxicSmokeCloudType[slot] = 0;
        }
        g_hToxicSmokeTimer = null;
        return Plugin_Stop;
    }

    float now = GetGameTime();
    bool anyActive = false;
    for (int slot = 0; slot < RSP_TOXIC_SMOKE_MAX_CLOUDS; slot++)
    {
        if (!g_bToxicSmokeCloudActive[slot])
        {
            continue;
        }

        if (g_iToxicSmokeCloudRound[slot] != g_iRoundSerial || now >= g_fToxicSmokeCloudExpires[slot])
        {
            g_bToxicSmokeCloudActive[slot] = false;
            g_iToxicSmokeCloudType[slot] = 0;
            continue;
        }

        anyActive = true;
        int owner = GetClientOfUserId(g_iToxicSmokeCloudOwnerUserId[slot]);
        int damageAttacker = (owner >= 1 && owner <= MaxClients && IsClientInGame(owner)) ? owner : 0;
        int cloudTeam = g_iToxicSmokeCloudTeam[slot];
        int cloudType = g_iToxicSmokeCloudType[slot];

        // Keep each cloud on its own 0.5-second schedule. Advancing from the deadline
        // avoids timer drift; delayed callbacks process any missed due ticks.
        while (g_bToxicSmokeCloudActive[slot] &&
            g_fToxicSmokeCloudNextDamage[slot] <= now &&
            g_fToxicSmokeCloudNextDamage[slot] < g_fToxicSmokeCloudExpires[slot])
        {
            g_fToxicSmokeCloudNextDamage[slot] += RSP_TOXIC_SMOKE_TICK_INTERVAL;
            for (int victim = 1; victim <= MaxClients; victim++)
            {
                if (!IsValidPlayingClient(victim) || !IsPlayerAlive(victim))
                {
                    continue;
                }

                int victimTeam = GetClientTeam(victim);
                if ((cloudType == RSP_SMOKE_CLOUD_HEALING && victimTeam != cloudTeam) ||
                    (cloudType == RSP_SMOKE_CLOUD_TOXIC &&
                     (victimTeam == cloudTeam ||
                      (g_iToxicSmokeCloudOwnerUserId[slot] != 0 &&
                       GetClientUserId(victim) == g_iToxicSmokeCloudOwnerUserId[slot]))))
                {
                    continue;
                }

                float victimOrigin[3];
                GetClientAbsOrigin(victim, victimOrigin);
                if (GetVectorDistance(victimOrigin, g_fToxicSmokeCloudOrigin[slot]) > RSP_TOXIC_SMOKE_RADIUS)
                {
                    continue;
                }

                if (cloudType == RSP_SMOKE_CLOUD_HEALING)
                {
                    int health = GetClientHealth(victim);
                    if (health > 0 && health < RSP_MEDIC_MAX_HEALTH)
                    {
                        int healed = health + RSP_HEALING_SMOKE_AMOUNT;
                        if (healed > RSP_MEDIC_MAX_HEALTH)
                        {
                            healed = RSP_MEDIC_MAX_HEALTH;
                        }
                        SetEntityHealth(victim, healed);
                    }
                    continue;
                }

                bool validSmokeOwner = damageAttacker >= 1 && damageAttacker <= MaxClients &&
                    damageAttacker != victim && IsClientInGame(damageAttacker);
                bool mayKillWithThisTick = validSmokeOwner &&
                    GetClientHealth(victim) <= RoundToCeil(RSP_TOXIC_SMOKE_DAMAGE);
                int ownerMoneyBefore = -1;
                int victimTeamBefore = victimTeam;
                if (mayKillWithThisTick)
                {
                    if (HasEntProp(damageAttacker, Prop_Send, "m_iAccount"))
                    {
                        ownerMoneyBefore = GetEntProp(damageAttacker, Prop_Send, "m_iAccount");
                    }
                    g_bToxicSmokeDeathPending[victim] = true;
                    g_iToxicSmokeDeathOwnerUserId[victim] = GetClientUserId(damageAttacker);
                    g_iToxicSmokeDeathRound[victim] = g_iRoundSerial;
                }

                int originalArmor = 0;
                bool hasArmorProp = HasEntProp(victim, Prop_Send, "m_ArmorValue");
                if (hasArmorProp)
                {
                    originalArmor = GetEntProp(victim, Prop_Send, "m_ArmorValue");
                    if (originalArmor > 0)
                    {
                        SetEntProp(victim, Prop_Send, "m_ArmorValue", 0);
                    }
                }

                SDKHooks_TakeDamage(victim, damageAttacker, damageAttacker,
                    RSP_TOXIC_SMOKE_DAMAGE, DMG_POISON);

                if (hasArmorProp && originalArmor > 0 && IsClientInGame(victim) && IsPlayerAlive(victim))
                {
                    int currentArmor = GetEntProp(victim, Prop_Send, "m_ArmorValue");
                    if (currentArmor < originalArmor)
                    {
                        SetEntProp(victim, Prop_Send, "m_ArmorValue", originalArmor);
                    }
                }

                if (mayKillWithThisTick && !IsPlayerAlive(victim) && ownerMoneyBefore >= 0)
                {
                    // CSS can award the held knife's $1500 native reward even though
                    // poison killed the victim. Normalize this single death to the
                    // ordinary $300 enemy-kill reward; frag/death stats remain native.
                    ApplyFixedKillCash(damageAttacker, ownerMoneyBefore, victimTeamBefore);
                }
                g_bToxicSmokeDeathPending[victim] = false;
                g_iToxicSmokeDeathOwnerUserId[victim] = 0;
                g_iToxicSmokeDeathRound[victim] = 0;
            }
        }
    }

    if (!anyActive)
    {
        g_hToxicSmokeTimer = null;
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

void ClearToxicSmokeClouds()
{
    for (int slot = 0; slot < RSP_TOXIC_SMOKE_MAX_CLOUDS; slot++)
    {
        g_bToxicSmokeCloudActive[slot] = false;
        g_iToxicSmokeCloudType[slot] = 0;
        g_iToxicSmokeCloudOwnerUserId[slot] = 0;
        g_iToxicSmokeCloudTeam[slot] = 0;
        g_iToxicSmokeCloudRound[slot] = 0;
        g_fToxicSmokeCloudExpires[slot] = 0.0;
        g_fToxicSmokeCloudNextDamage[slot] = 0.0;
        g_fToxicSmokeCloudOrigin[slot][0] = 0.0;
        g_fToxicSmokeCloudOrigin[slot][1] = 0.0;
        g_fToxicSmokeCloudOrigin[slot][2] = 0.0;
    }
    if (g_hToxicSmokeTimer != null)
    {
        delete g_hToxicSmokeTimer;
        g_hToxicSmokeTimer = null;
    }
    for (int client = 1; client <= MaxClients; client++)
    {
        g_bLastSmokeWasToxic[client] = false;
        g_bLastSmokeWasHealing[client] = false;
        g_fLastSmokeThrowTime[client] = 0.0;
        g_iLastSmokeThrowRound[client] = 0;
        g_iLastSmokeThrowTeam[client] = 0;
    }
}

int RollDisarmChancePercent()
{
    return GetRandomInt(RSP_DISARM_CHANCE_MIN, RSP_DISARM_CHANCE_MAX);
}

bool IsValidDisarmChancePercent(int chancePercent)
{
    return chancePercent >= RSP_DISARM_CHANCE_MIN && chancePercent <= RSP_DISARM_CHANCE_MAX;
}

bool IsValidCryoChancePercent(int chancePercent)
{
    return chancePercent >= 20 && chancePercent <= 40;
}

bool IsValidDisorientChancePercent(int chancePercent)
{
    return chancePercent >= 20 && chancePercent <= 40;
}

bool HasDeadlyFlashAttribution(int owner)
{
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner))
    {
        return false;
    }

    if (g_iPower[owner] == RSP_DeadlyFlash || g_bHadDeadlyFlashThisRound[owner])
    {
        return true;
    }

    float age = GetGameTime() - g_fLastDeadlyFlashThrowTime[owner];
    return g_bLastFlashWasDeadly[owner] && g_iLastDeadlyFlashThrowRound[owner] == g_iRoundSerial &&
        age >= 0.0 && age <= RSP_DEADLY_FLASH_THROW_GRACE;
}

void RecordFlashDetonation(int ownerUserId, const float origin[3], bool isDeadly, bool isLong)
{
    int slot = g_iFlashWriteIndex;
    g_iFlashWriteIndex = (g_iFlashWriteIndex + 1) % RSP_FLASH_RECORDS;

    g_iFlashOwnerUserId[slot] = ownerUserId;
    g_iFlashRound[slot] = g_iRoundSerial;
    g_fFlashTime[slot] = GetGameTime();
    g_fFlashProDuration[slot] = isLong
        ? RSP_FLASH_PRO_DURATION : 0.0;
    g_fFlashOrigin[slot][0] = origin[0];
    g_fFlashOrigin[slot][1] = origin[1];
    g_fFlashOrigin[slot][2] = origin[2];
    g_bFlashRecordDeadly[slot] = isDeadly;
    g_bFlashRecordLong[slot] = isLong;
}

public void Event_FlashbangDetonate(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled || !g_bSupportedMap || (!IsRSPPowerRuntimeActive() && !g_bRoundEnding))
    {
        return;
    }

    int eventUserId = event.GetInt("userid");
    int owner = GetClientOfUserId(eventUserId);
    if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner))
    {
        QueueInfiniteGrenadeRefill(owner, RSP_GRENADE_FLASH, false);
    }
    float origin[3];
    origin[0] = event.GetFloat("x");
    origin[1] = event.GetFloat("y");
    origin[2] = event.GetFloat("z");

    int ownerUserId = 0;
    bool deadly = false;
    bool longFlash = false;
    if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner))
    {
        ownerUserId = GetClientUserId(owner);
        deadly = HasDeadlyFlashAttribution(owner);
        float longThrowAge = GetGameTime() - g_fLastLongFlashThrowTime[owner];
        longFlash = g_iPower[owner] == RSP_FlashPro ||
            (g_bLastFlashWasLong[owner] && g_iLastLongFlashThrowRound[owner] == g_iRoundSerial &&
             longThrowAge >= 0.0 && longThrowAge <= RSP_DEADLY_FLASH_THROW_GRACE);
    }

    // Preserve both Deadly Flash and Flash-Pro ownership from the projectile,
    // including grenades that detonate after their thrower dies.
    int projectile = FindTrackedFlashProjectileAt(origin);
    if (projectile > MaxClients)
    {
        if (ownerUserId == 0)
        {
            ownerUserId = g_iFlashProjectileOwnerUserId[projectile];
        }
        deadly = deadly || g_bFlashProjectileDeadly[projectile];
        longFlash = longFlash || g_bFlashProjectileLong[projectile];
    }

    int ownerForTeam = GetClientOfUserId(ownerUserId);
    if (ownerForTeam >= 1 && ownerForTeam <= MaxClients && IsClientInGame(ownerForTeam))
    {
        if (GetClientTeam(ownerForTeam) != CS_TEAM_CT && GetClientTeam(ownerForTeam) != CS_TEAM_T)
        {
            longFlash = false;
        }
    }
    RecordFlashDetonation(ownerUserId, origin, deadly, longFlash);
}
int FindTrackedFlashProjectileAt(const float detonationOrigin[3])
{
    int bestEntity = -1;
    float bestDistance = 256.0;
    float now = GetGameTime();

    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if ((!g_bFlashProjectileDeadly[entity] && !g_bFlashProjectileLong[entity]) ||
            g_iFlashProjectileOwnerUserId[entity] == 0 ||
            g_iFlashProjectileRound[entity] != g_iRoundSerial ||
            g_fFlashProjectileSpawnTime[entity] <= 0.0 ||
            now - g_fFlashProjectileSpawnTime[entity] > RSP_DEADLY_FLASH_THROW_GRACE ||
            !IsValidEntity(entity) || !HasEntProp(entity, Prop_Send, "m_vecOrigin"))
        {
            continue;
        }

        float projectileOrigin[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", projectileOrigin);
        float distance = GetVectorDistance(projectileOrigin, detonationOrigin);
        if (distance < bestDistance)
        {
            bestDistance = distance;
            bestEntity = entity;
        }
    }

    return bestEntity;
}

int FindRecentDeadlyFlashOwner(int victim)
{
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return 0;
    }

    float victimOrigin[3];
    GetClientAbsOrigin(victim, victimOrigin);
    int selectedUserId = 0;
    float closestDistance = RSP_FLASH_MAX_DISTANCE;
    float now = GetGameTime();

    // CS:S player_blind does not carry a thrower id. Choose the nearest recent
    // detonation that is positively known to belong to a Deadly Flash holder.
    for (int i = 0; i < RSP_FLASH_RECORDS; i++)
    {
        if (g_iFlashRound[i] != g_iRoundSerial || g_fFlashTime[i] <= 0.0)
        {
            continue;
        }

        bool deadlyRecord = g_bFlashRecordDeadly[i];
        if (!deadlyRecord)
        {
            int recordOwner = GetClientOfUserId(g_iFlashOwnerUserId[i]);
            if (recordOwner > 0 && HasDeadlyFlashAttribution(recordOwner))
            {
                deadlyRecord = true;
                g_bFlashRecordDeadly[i] = true;
            }
        }
        if (!deadlyRecord)
        {
            continue;
        }

        float age = now - g_fFlashTime[i];
        if (age < 0.0 || age > RSP_FLASH_MAX_AGE)
        {
            continue;
        }

        float distance = GetVectorDistance(victimOrigin, g_fFlashOrigin[i]);
        if (distance <= closestDistance)
        {
            closestDistance = distance;
            selectedUserId = g_iFlashOwnerUserId[i];
        }
    }

    return selectedUserId;
}

int FindRecentLongFlashOwner(int victim, float &targetDuration)
{
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return 0;
    }

    targetDuration = RSP_FLASH_PRO_DURATION;
    float victimOrigin[3];
    GetClientAbsOrigin(victim, victimOrigin);
    int selectedUserId = 0;
    float closestDistance = RSP_FLASH_MAX_DISTANCE;
    float now = GetGameTime();
    for (int i = 0; i < RSP_FLASH_RECORDS; i++)
    {
        if (!g_bFlashRecordLong[i] || g_iFlashRound[i] != g_iRoundSerial || g_fFlashTime[i] <= 0.0)
        {
            continue;
        }

        float age = now - g_fFlashTime[i];
        if (age < 0.0 || age > RSP_LONG_FLASH_MAX_AGE)
        {
            continue;
        }

        int owner = GetClientOfUserId(g_iFlashOwnerUserId[i]);
        if (owner < 1 || owner > MaxClients || !IsClientInGame(owner) ||
            GetClientTeam(owner) == GetClientTeam(victim))
        {
            continue;
        }

        float distance = GetVectorDistance(victimOrigin, g_fFlashOrigin[i]);
        if (distance <= closestDistance)
        {
            closestDistance = distance;
            selectedUserId = g_iFlashOwnerUserId[i];
            targetDuration = g_fFlashProDuration[i];
        }
    }
    return selectedUserId;
}

bool HasRecentLongFlashPotential()
{
    float now = GetGameTime();
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client))
        {
            continue;
        }
        if (g_iPower[client] == RSP_FlashPro && IsPlayerAlive(client))
        {
            return true;
        }
        float throwAge = now - g_fLastLongFlashThrowTime[client];
        if (g_bLastFlashWasLong[client] && g_iLastLongFlashThrowRound[client] == g_iRoundSerial &&
            throwAge >= 0.0 && throwAge <= RSP_DEADLY_FLASH_THROW_GRACE)
        {
            return true;
        }
    }
    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_bFlashProjectileLong[entity] && g_iFlashProjectileRound[entity] == g_iRoundSerial &&
            g_fFlashProjectileSpawnTime[entity] > 0.0 &&
            now - g_fFlashProjectileSpawnTime[entity] <= RSP_DEADLY_FLASH_THROW_GRACE &&
            IsValidEntity(entity))
        {
            return true;
        }
    }
    return false;
}

bool HasRecentDeadlyFlashPotential()
{
    float now = GetGameTime();
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client))
        {
            continue;
        }

        // Also queue/retry while a current skill holder may have thrown before
        // flashbang_detonate is delivered by this CS:S build.
        if (g_iPower[client] == RSP_DeadlyFlash || g_bHadDeadlyFlashThisRound[client])
        {
            return true;
        }

        float age = now - g_fLastDeadlyFlashThrowTime[client];
        if (g_bLastFlashWasDeadly[client] && g_iLastDeadlyFlashThrowRound[client] == g_iRoundSerial &&
            age >= 0.0 && age <= RSP_DEADLY_FLASH_THROW_GRACE)
        {
            return true;
        }
    }
    return false;
}

void QueueDeadlyFlashKill(int victim)
{
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return;
    }

    if (g_hBlindCheckTimer[victim] != null)
    {
        delete g_hBlindCheckTimer[victim];
        g_hBlindCheckTimer[victim] = null;
    }

    g_iBlindCheckRound[victim] = g_iRoundSerial;
    g_iBlindCheckAttempts[victim] = 0;
    g_hBlindCheckTimer[victim] = CreateTimer(RSP_BLIND_CHECK_DELAY, Timer_CheckDeadlyFlash,
        GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
}

void ApplyAntiFlashImmunity(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_FlashPro)
    {
        return;
    }
    if (HasEntProp(client, Prop_Send, "m_flFlashDuration"))
    {
        SetEntPropFloat(client, Prop_Send, "m_flFlashDuration", 0.0);
    }
    if (HasEntProp(client, Prop_Send, "m_flFlashMaxAlpha"))
    {
        SetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha", 0.0);
    }
}

public void Frame_ApplyAntiFlashImmunity(any userid)
{
    int client = GetClientOfUserId(userid);
    ApplyAntiFlashImmunity(client);
}

void ApplyConcussionFlash(int victim, int attacker)
{
    if (victim < 1 || victim > MaxClients || attacker < 1 || attacker > MaxClients ||
        !IsClientInGame(victim) || !IsClientInGame(attacker) ||
        !IsPlayerAlive(victim) || g_iPower[victim] == RSP_FlashPro)
    {
        return;
    }

    float now = GetGameTime();
    float duration = RSP_CONCUSSION_FLASH_DURATION;

    // CS:S applies the flash fade to the same networked properties. Keep a stronger
    // overlapping flash instead of shortening it, and add a small duration delta so
    // repeated equal-duration flashes always re-trigger the client-side fade.
    float currentDuration = 0.0;
    float currentStart = now;
    if (HasEntProp(victim, Prop_Send, "m_flFlashDuration"))
    {
        currentDuration = GetEntPropFloat(victim, Prop_Send, "m_flFlashDuration");
        if (HasEntProp(victim, Prop_Send, "m_flFlashBangTime"))
            currentStart = GetEntPropFloat(victim, Prop_Send, "m_flFlashBangTime");
    }
    else if (HasEntProp(victim, Prop_Data, "m_flFlashDuration"))
    {
        currentDuration = GetEntPropFloat(victim, Prop_Data, "m_flFlashDuration");
        if (HasEntProp(victim, Prop_Data, "m_flFlashBangTime"))
            currentStart = GetEntPropFloat(victim, Prop_Data, "m_flFlashBangTime");
    }

    if (currentDuration > 0.0)
    {
        float remaining = currentStart + currentDuration - now;
        if (remaining > duration)
            duration = remaining;
    }

    if (HasEntProp(victim, Prop_Send, "m_flFlashDuration"))
        SetEntPropFloat(victim, Prop_Send, "m_flFlashDuration", duration);
    else if (HasEntProp(victim, Prop_Data, "m_flFlashDuration"))
        SetEntPropFloat(victim, Prop_Data, "m_flFlashDuration", duration);

    if (HasEntProp(victim, Prop_Send, "m_flFlashMaxAlpha"))
        SetEntPropFloat(victim, Prop_Send, "m_flFlashMaxAlpha", 255.0);
    else if (HasEntProp(victim, Prop_Data, "m_flFlashMaxAlpha"))
        SetEntPropFloat(victim, Prop_Data, "m_flFlashMaxAlpha", 255.0);

    if (HasEntProp(victim, Prop_Send, "m_flFlashBangTime"))
        SetEntPropFloat(victim, Prop_Send, "m_flFlashBangTime", now);
    else if (HasEntProp(victim, Prop_Data, "m_flFlashBangTime"))
        SetEntPropFloat(victim, Prop_Data, "m_flFlashBangTime", now);

    // CCSPlayer::Deafen uses DSP 134 (<600u), 135 (<800u) and 136 (<1000u).
    // Select the same tier from the attacker-victim distance, extend to 3 seconds,
    // and never replace a stronger overlapping DSP with a weaker one.
    float attackerOrigin[3], victimOrigin[3];
    GetClientAbsOrigin(attacker, attackerOrigin);
    GetClientAbsOrigin(victim, victimOrigin);
    float distance = GetVectorDistance(attackerOrigin, victimOrigin);
    int effect = 0;
    if (distance < 600.0) effect = 134;
    else if (distance < 800.0) effect = 135;
    else if (distance < 1000.0) effect = 136;

    if (effect != 0)
    {
        if (g_fConcussionDspUntil[victim] > now &&
            g_iConcussionDspEffect[victim] >= 134 &&
            g_iConcussionDspEffect[victim] < effect)
        {
            effect = g_iConcussionDspEffect[victim];
        }
        ClientCommand(victim, "dsp_player %d", effect);
        g_iConcussionDspEffect[victim] = effect;
        g_fConcussionDspUntil[victim] = now + RSP_CONCUSSION_FLASH_DURATION;
    }
}
void ApplyLongFlashDuration(int victim, float targetDuration)
{
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim) || !IsPlayerAlive(victim) ||
        !HasEntProp(victim, Prop_Send, "m_flFlashDuration"))
    {
        return;
    }

    float currentDuration = GetEntPropFloat(victim, Prop_Send, "m_flFlashDuration");
    // Use the duration rolled for this grenade, never shorten a stronger overlapping flash.
    if (currentDuration > 0.0 && currentDuration < targetDuration)
    {
        SetEntPropFloat(victim, Prop_Send, "m_flFlashDuration", targetDuration);
    }
}

void QueueLongFlashCheck(int victim)
{
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim))
    {
        return;
    }
    if (g_hLongFlashTimer[victim] != null)
    {
        return;
    }
    g_iLongFlashCheckRound[victim] = g_iRoundSerial;
    g_iLongFlashCheckAttempts[victim] = 0;
    g_hLongFlashTimer[victim] = CreateTimer(RSP_BLIND_CHECK_DELAY, Timer_CheckLongFlash,
        GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_CheckLongFlash(Handle timer, any userid)
{
    int victim = GetClientOfUserId(userid);
    if (victim < 1 || victim > MaxClients)
    {
        return Plugin_Stop;
    }
    if (g_hLongFlashTimer[victim] == timer)
    {
        g_hLongFlashTimer[victim] = null;
    }

    if (!g_bEnabled || !g_bSupportedMap || (!IsRSPPowerRuntimeActive() && !g_bRoundEnding) ||
        !IsClientInGame(victim) || !IsPlayerAlive(victim) ||
        g_iLongFlashCheckRound[victim] != g_iRoundSerial)
    {
        g_iLongFlashCheckRound[victim] = 0;
        g_iLongFlashCheckAttempts[victim] = 0;
        return Plugin_Stop;
    }
    if (g_iPower[victim] == RSP_FlashPro)
    {
        ApplyAntiFlashImmunity(victim);
        g_iLongFlashCheckRound[victim] = 0;
        g_iLongFlashCheckAttempts[victim] = 0;
        return Plugin_Stop;
    }

    float targetDuration;
    int ownerUserId = FindRecentLongFlashOwner(victim, targetDuration);
    if (ownerUserId != 0)
    {
        ApplyLongFlashDuration(victim, targetDuration);
        g_iLongFlashCheckRound[victim] = 0;
        g_iLongFlashCheckAttempts[victim] = 0;
        return Plugin_Stop;
    }

    g_iLongFlashCheckAttempts[victim]++;
    if (g_iLongFlashCheckAttempts[victim] >= RSP_BLIND_RETRY_COUNT || !HasRecentLongFlashPotential())
    {
        g_iLongFlashCheckRound[victim] = 0;
        g_iLongFlashCheckAttempts[victim] = 0;
        return Plugin_Stop;
    }

    g_hLongFlashTimer[victim] = CreateTimer(RSP_BLIND_CHECK_DELAY, Timer_CheckLongFlash,
        GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Stop;
}

void StopClientBlindTimer(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    if (g_hLongFlashTimer[client] != null)
    {
        delete g_hLongFlashTimer[client];
        g_hLongFlashTimer[client] = null;
    }
    g_iLongFlashCheckRound[client] = 0;
    g_iLongFlashCheckAttempts[client] = 0;

    if (g_hBlindCheckTimer[client] != null)
    {
        delete g_hBlindCheckTimer[client];
        g_hBlindCheckTimer[client] = null;
    }
    g_iBlindCheckRound[client] = 0;
    g_iBlindCheckAttempts[client] = 0;
}

public void Event_PlayerBlind(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled || !g_bSupportedMap || (!IsRSPPowerRuntimeActive() && !g_bRoundEnding))
    {
        return;
    }

    int victim = GetClientOfUserId(event.GetInt("userid"));
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim) || !IsPlayerAlive(victim))
    {
        return;
    }

    // Track genuine flashbangs before Hacker's near-transparent CSS radar override is
    // restored. Never shorten a real flash merely because its victim has Hacker.
    RecordHackerRealFlashEndTime(victim);
    bool hackerRadarTarget = IsRSPRadarDisabled(victim);
    if (hackerRadarTarget)
    {
        g_bHackerRadarFlashOverrideActive[victim] = false;
    }

    // Flash-Pro protects the owner from flash blindness. Each thrown flash gets
    // its own fixed 7-second blindness duration for enemies.
    if (g_iPower[victim] == RSP_FlashPro)
    {
        ApplyAntiFlashImmunity(victim);
        RequestFrame(Frame_ApplyAntiFlashImmunity, GetClientUserId(victim));
        g_fHackerRealFlashUntil[victim] = GetGameTime();
        if (hackerRadarTarget)
        {
            QueueHackerRadarReapply(victim, 0.10, g_iHackerRadarPendingOwnerUserId[victim]);
        }
        StopClientBlindTimer(victim);
        return;
    }

    float longFlashDuration;
    int longFlashOwnerUserId = FindRecentLongFlashOwner(victim, longFlashDuration);
    if (longFlashOwnerUserId == 0 && HasRecentLongFlashPotential())
    {
        // CS:S may emit player_blind before flashbang_detonate; retry shortly so the
        // just-detonated Flash-Pro grenade has time to be recorded.
        QueueLongFlashCheck(victim);
    }
    else if (longFlashOwnerUserId != 0)
    {
        ApplyLongFlashDuration(victim, longFlashDuration);
        RecordHackerRealFlashEndTime(victim);
    }

    if (hackerRadarTarget)
    {
        float remaining;
        float delay = GetHackerRealFlashTimeRemaining(victim, remaining) ? remaining + 0.10 : 0.10;
        QueueHackerRadarReapply(victim, delay, g_iHackerRadarPendingOwnerUserId[victim]);
    }

    int ownerUserId = FindRecentDeadlyFlashOwner(victim);
    if (ownerUserId != 0 || HasRecentDeadlyFlashPotential())
    {
        // Always re-resolve the flash after this frame: player_blind can arrive
        // before flashbang_detonate in CS:S.
        QueueDeadlyFlashKill(victim);
    }
}

public Action Timer_CheckDeadlyFlash(Handle timer, any userid)
{
    int victim = GetClientOfUserId(userid);
    if (victim < 1 || victim > MaxClients)
    {
        return Plugin_Stop;
    }

    if (g_hBlindCheckTimer[victim] == timer)
    {
        g_hBlindCheckTimer[victim] = null;
    }

    if (!g_bEnabled || !g_bSupportedMap || (!IsRSPPowerRuntimeActive() && !g_bRoundEnding) ||
        !IsClientInGame(victim) || !IsPlayerAlive(victim) ||
        g_iBlindCheckRound[victim] != g_iRoundSerial || g_iPower[victim] == RSP_FlashPro ||
        (g_iPower[victim] == RSP_GodMode && g_fGodModeUntil[victim] > GetGameTime()))
    {
        StopClientBlindTimer(victim);
        return Plugin_Stop;
    }

    int ownerUserId = FindRecentDeadlyFlashOwner(victim);
    if (ownerUserId == 0 && g_iBlindCheckAttempts[victim] < RSP_BLIND_RETRY_COUNT &&
        HasRecentDeadlyFlashPotential())
    {
        g_iBlindCheckAttempts[victim]++;
        g_hBlindCheckTimer[victim] = CreateTimer(RSP_BLIND_CHECK_DELAY, Timer_CheckDeadlyFlash,
            GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Stop;
    }

    g_iBlindCheckAttempts[victim] = 0;
    if (ownerUserId == 0)
    {
        return Plugin_Stop;
    }

    // First apply lethal damage with the recorded thrower as attacker. That lets CS:S
    // perform its normal kill/score/cash handling. Only if friendly-fire or build-specific
    // rules reject the damage do we fall back to a forced death plus explicit score repair.
    int owner = GetClientOfUserId(ownerUserId);
    g_bDeadlyFlashForceKill[victim] = true;
    g_bFlashKillPending[victim] = true;
    g_bFlashKillFallback[victim] = false;
    g_iFlashKillOwnerUserId[victim] = ownerUserId;

    float lethalDamage = float(GetClientHealth(victim) + 50000);
    int ownerMoneyBefore = -1;
    int victimTeamBefore = GetClientTeam(victim);
    bool canCorrectNativeCash = owner >= 1 && owner <= MaxClients && IsClientInGame(owner) &&
        owner != victim && HasEntProp(owner, Prop_Send, "m_iAccount");
    if (canCorrectNativeCash)
    {
        ownerMoneyBefore = GetEntProp(owner, Prop_Send, "m_iAccount");
    }

    if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner))
    {
        SDKHooks_TakeDamage(victim, owner, owner, lethalDamage, DMG_BLAST);

        // CS:S may use a customized cash_player_killed_enemy_default value (e.g. $1500).
        // Normalize the synchronous native kill reward to the requested vanilla $300
        // per enemy kill. This runs immediately after this one victim's death, so it
        // cannot multiply a single configured reward across every flash victim.
        // A later native round-win award remains owned by the game and is not touched.
        if (canCorrectNativeCash && !IsPlayerAlive(victim) && ownerMoneyBefore >= 0)
        {
            ApplyFixedKillCash(owner, ownerMoneyBefore, victimTeamBefore);
        }
    }

    if (IsClientInGame(victim) && IsPlayerAlive(victim))
    {
        g_bFlashKillFallback[victim] = true;
        ForcePlayerSuicide(victim);
    }
    if (IsClientInGame(victim) && IsPlayerAlive(victim))
    {
        SDKHooks_TakeDamage(victim, victim, victim, 100000.0, DMG_GENERIC);
    }
    g_bDeadlyFlashForceKill[victim] = false;

    return Plugin_Stop;
}

public void Frame_CorrectFlashFallbackScore(any victimUserId)
{
    int victim = GetClientOfUserId(victimUserId);
    if (victim < 1 || victim > MaxClients || !IsClientInGame(victim) || !g_bFlashScoreRepairPending[victim])
    {
        return;
    }

    int ownerUserId = g_iFlashScoreRepairOwnerUserId[victim];
    int victimTeam = g_iFlashScoreRepairVictimTeam[victim];
    g_bFlashScoreRepairPending[victim] = false;
    g_iFlashScoreRepairOwnerUserId[victim] = 0;
    g_iFlashScoreRepairVictimTeam[victim] = 0;

    int owner = GetClientOfUserId(ownerUserId);
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner) || owner == victim)
    {
        return;
    }

    CorrectFlashFallbackScore(victim, owner, victimTeam, true);
}

void ApplyFixedKillCash(int owner, int moneyBefore, int victimTeam)
{
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner) ||
        !HasEntProp(owner, Prop_Send, "m_iAccount"))
    {
        return;
    }

    ConVar playerCashAwards = FindConVar("mp_playercashawards");
    if (playerCashAwards != null && !playerCashAwards.BoolValue)
    {
        return;
    }

    bool teamKill = victimTeam == GetClientTeam(owner);
    int desiredDelta = teamKill ? -RSP_FLASH_TEAMKILL_PENALTY : RSP_FLASH_ENEMY_KILL_REWARD;
    int money = moneyBefore + desiredDelta;
    if (money < 0)
    {
        money = 0;
    }

    int moneyLimit = RSP_DEADLY_FLASH_MONEY_CAP;
    ConVar maxMoney = FindConVar("mp_maxmoney");
    if (maxMoney != null && maxMoney.IntValue > 0 && maxMoney.IntValue < moneyLimit)
    {
        moneyLimit = maxMoney.IntValue;
    }
    if (money > moneyLimit)
    {
        money = moneyLimit;
    }

    SetEntProp(owner, Prop_Send, "m_iAccount", money);
}

void QueueTeslaKillCash(int owner, int moneyBefore, int victimTeam)
{
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner) || owner == 0 ||
        moneyBefore < 0 || victimTeam == GetClientTeam(owner) ||
        (victimTeam != CS_TEAM_T && victimTeam != CS_TEAM_CT))
    {
        return;
    }

    int ownerUserId = GetClientUserId(owner);
    if (g_iTeslaCashOwnerUserId[owner] != ownerUserId || g_iTeslaCashRound[owner] != g_iRoundSerial)
    {
        g_iTeslaCashOwnerUserId[owner] = ownerUserId;
        g_iTeslaCashBefore[owner] = moneyBefore;
        g_iTeslaCashRound[owner] = g_iRoundSerial;
        g_iTeslaCashKillCount[owner] = 0;
        g_bTeslaCashCorrectionQueued[owner] = false;
    }
    if (g_iTeslaCashBefore[owner] < 0)
    {
        g_iTeslaCashBefore[owner] = moneyBefore;
    }
    g_iTeslaCashKillCount[owner]++;
    if (!g_bTeslaCashCorrectionQueued[owner])
    {
        g_bTeslaCashCorrectionQueued[owner] = true;
        RequestFrame(Frame_ApplyTeslaKillCash, ownerUserId);
    }
}

public void Frame_ApplyTeslaKillCash(any ownerUserId)
{
    int owner = GetClientOfUserId(ownerUserId);
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner) ||
        g_iTeslaCashOwnerUserId[owner] != ownerUserId || g_iTeslaCashRound[owner] != g_iRoundSerial)
    {
        return;
    }

    int moneyBefore = g_iTeslaCashBefore[owner];
    int killCount = g_iTeslaCashKillCount[owner];
    g_iTeslaCashOwnerUserId[owner] = 0;
    g_iTeslaCashBefore[owner] = -1;
    g_iTeslaCashRound[owner] = 0;
    g_iTeslaCashKillCount[owner] = 0;
    g_bTeslaCashCorrectionQueued[owner] = false;
    if (moneyBefore < 0 || killCount <= 0 || !HasRSPAccountProperty(owner))
    {
        return;
    }

    int moneyLimit = 16000;
    ConVar maxMoney = FindConVar("mp_maxmoney");
    if (maxMoney != null && maxMoney.IntValue > 0 && maxMoney.IntValue < moneyLimit)
    {
        moneyLimit = maxMoney.IntValue;
    }
    int money = moneyBefore + 150 * killCount;
    if (money > moneyLimit) money = moneyLimit;
    if (money < 0) money = 0;
    SetRSPAccount(owner, money);
}

public void Frame_ApplyDamagerKillCash(any ownerUserId)
{
    int owner = GetClientOfUserId(ownerUserId);
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner) ||
        g_iDamagerCashOwnerUserId[owner] != ownerUserId ||
        g_iDamagerCashRound[owner] != g_iRoundSerial)
    {
        return;
    }

    int moneyBefore = g_iDamagerCashBefore[owner];
    int killCount = g_iDamagerKillCount[owner];
    g_iDamagerCashOwnerUserId[owner] = 0;
    g_iDamagerCashBefore[owner] = -1;
    g_iDamagerCashRound[owner] = 0;
    g_iDamagerKillCount[owner] = 0;
    g_bDamagerCashCorrectionQueued[owner] = false;

    if (moneyBefore < 0 || killCount <= 0 || !HasRSPAccountProperty(owner))
    {
        return;
    }

    // Damager gives $300 per enemy kill, independent of the weapon the owner held.
    int money = moneyBefore + (300 * killCount);
    int moneyLimit = 16000;
    ConVar maxMoney = FindConVar("mp_maxmoney");
    if (maxMoney != null && maxMoney.IntValue > 0 && maxMoney.IntValue < moneyLimit)
    {
        moneyLimit = maxMoney.IntValue;
    }
    if (money > moneyLimit)
    {
        money = moneyLimit;
    }
    if (money < 0)
    {
        money = 0;
    }

    SetRSPAccount(owner, money);
}

public void Frame_ApplyThornsKillCash(any data)
{
    DataPack pack = view_as<DataPack>(data);
    if (pack == null)
    {
        return;
    }

    pack.Reset();
    int ownerUserId = pack.ReadCell();
    int moneyBefore = pack.ReadCell();
    delete pack;

    int owner = GetClientOfUserId(ownerUserId);
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner) || moneyBefore < 0 ||
        !HasRSPAccountProperty(owner))
    {
        return;
    }

    // Thorns has a fixed $300 enemy-kill reward instead of inheriting the weapon
    // award selected by the engine. Honor the server's maximum-money setting.
    int money = moneyBefore + 300;
    int moneyLimit = 16000;
    ConVar maxMoney = FindConVar("mp_maxmoney");
    if (maxMoney != null && maxMoney.IntValue > 0 && maxMoney.IntValue < moneyLimit)
    {
        moneyLimit = maxMoney.IntValue;
    }
    if (money > moneyLimit)
    {
        money = moneyLimit;
    }
    if (money < 0)
    {
        money = 0;
    }

    SetRSPAccount(owner, money);
}

public void Frame_ClampDeadlyFlashCash(any ownerUserId)
{
    int owner = GetClientOfUserId(ownerUserId);
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner) ||
        !HasEntProp(owner, Prop_Send, "m_iAccount"))
    {
        return;
    }

    int moneyLimit = RSP_DEADLY_FLASH_MONEY_CAP;
    ConVar maxMoney = FindConVar("mp_maxmoney");
    if (maxMoney != null && maxMoney.IntValue > 0 && maxMoney.IntValue < moneyLimit)
    {
        moneyLimit = maxMoney.IntValue;
    }

    int money = GetEntProp(owner, Prop_Send, "m_iAccount");
    if (money > moneyLimit)
    {
        SetEntProp(owner, Prop_Send, "m_iAccount", moneyLimit);
    }
}

void CorrectFlashFallbackScore(int victim, int owner, int victimTeam, bool undoVictimSuicide = true)
{
    if (victim < 1 || victim > MaxClients || owner < 1 || owner > MaxClients ||
        !IsClientInGame(victim) || !IsClientInGame(owner) || victim == owner)
    {
        return;
    }

    // This runs after the event's native score update. When the original death was
    // counted as suicide, undo that frag penalty before applying the owner/teamkill frag.
    if (undoVictimSuicide && HasEntProp(victim, Prop_Data, "m_iFrags"))
    {
        SetEntProp(victim, Prop_Data, "m_iFrags", GetEntProp(victim, Prop_Data, "m_iFrags") + 1);
    }

    bool teamKill = victimTeam == GetClientTeam(owner);
    if (HasEntProp(owner, Prop_Data, "m_iFrags"))
    {
        int ownerFrags = GetEntProp(owner, Prop_Data, "m_iFrags");
        SetEntProp(owner, Prop_Data, "m_iFrags", ownerFrags + (teamKill ? -1 : 1));
    }

    // Fallback only: the native CS:S scoring path did not credit the intended owner.
    ConVar playerCashAwards = FindConVar("mp_playercashawards");
    if (playerCashAwards != null && !playerCashAwards.BoolValue)
    {
        return;
    }

    // For this exceptional forced-suicide fallback, use the intended CS:S per-kill
    // reward directly. Do not inherit a customized cash CVar (e.g. $1500 per kill),
    // which multiplied across a five-player flash can produce a misleading $7500 grant.
    int cashDelta = teamKill ? -RSP_FLASH_TEAMKILL_PENALTY : RSP_FLASH_ENEMY_KILL_REWARD;

    // Counter-Strike: Source does not provide CS_GetClientMoney/CS_SetClientMoney
    // natives in the user's SourceMod include set. Use the same validated network
    // property already used by Rich Boy elsewhere in this plugin.
    if (!IsClientInGame(owner) || !HasEntProp(owner, Prop_Send, "m_iAccount"))
    {
        return;
    }

    int money = GetEntProp(owner, Prop_Send, "m_iAccount") + cashDelta;
    if (money < 0)
    {
        money = 0;
    }
    ConVar maxMoney = FindConVar("mp_maxmoney");
    if (maxMoney != null && money > maxMoney.IntValue)
    {
        money = maxMoney.IntValue;
    }
    SetEntProp(owner, Prop_Send, "m_iAccount", money);
}

public Action Timer_GhostMaintenance(Handle timer)
{
    // This maintenance timer is exclusively for Ghost inventory entities.
    // Wallhack outlines are serviced by their own lower-cost drawing timer.
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        g_hGhostMaintenanceTimer = null;
        return Plugin_Stop;
    }

    bool hasMaintenanceWork = false;
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsValidPlayingClient(client) || !IsPlayerAlive(client))
        {
            continue;
        }

        if (g_iPower[client] == RSP_Ghost)
        {
            hasMaintenanceWork = true;
            TrackGhostInventoryWeapons(client);
            StripGhostFirearms(client);
        }

    }

    if (!hasMaintenanceWork)
    {
        g_hGhostMaintenanceTimer = null;
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

public Action Timer_WallhackRefresh(Handle timer, any data)
{
    if (g_hWallhackRefreshTimer != timer)
    {
        return Plugin_Stop;
    }

    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive() || !HasActiveWallhackViewer() ||
        g_iWallhackBeamModel <= 0)
    {
        ClearAllWallhackMarkers();
        g_hWallhackRefreshTimer = null;
        return Plugin_Stop;
    }

    MaintainWallhackMarkers();
    return Plugin_Continue;
}

void StartWallhackTimer()
{
    if (g_hWallhackRefreshTimer == null && g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActive())
    {
        g_hWallhackRefreshTimer = CreateTimer(RSP_WALLHACK_REFRESH_INTERVAL,
            Timer_WallhackRefresh, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    }
}

void StopWallhackTimer()
{
    if (g_hWallhackRefreshTimer != null)
    {
        delete g_hWallhackRefreshTimer;
        g_hWallhackRefreshTimer = null;
    }
    ClearAllWallhackMarkers();
}

void ClearVisualTracking()
{
    // Wallhack endpoint anchors and persistent edge beams are removed by ClearAllWallhackMarkers() during cleanup.
    // This function only clears persistent ownership tracking for Ghost weapons and projectiles.
    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iGhostEntityOwnerUserId[entity] != 0)
        {
            if (IsValidEntity(entity))
            {
                UntrackGhostWeaponEntity(entity);
            }
            else
            {
                g_iGhostEntityOwnerUserId[entity] = 0;
            }
        }

        g_iFlashProjectileOwnerUserId[entity] = 0;
        g_bFlashProjectileDeadly[entity] = false;
        g_bFlashProjectileLong[entity] = false;
        g_iFlashProjectileRound[entity] = 0;
        g_fFlashProjectileSpawnTime[entity] = 0.0;
        g_iHEProjectileOwnerUserId[entity] = 0;
        g_bHEProjectileDemolition[entity] = false;
        g_iHEProjectileTeam[entity] = 0;
        g_bHEProjectileExecutioner[entity] = false;
        g_bHEProjectileEnder[entity] = false;
        g_iHEProjectileRound[entity] = 0;
        g_fHEProjectileSpawnTime[entity] = 0.0;
        g_iSmokeProjectileOwnerUserId[entity] = 0;
        g_iSmokeProjectileTeam[entity] = 0;
        g_iSmokeProjectileRound[entity] = 0;
        g_iSmokeProjectileType[entity] = 0;
        g_fSmokeProjectileSpawnTime[entity] = 0.0;
    }
}

void QueueWallhackRefresh()
{
    if (g_bWallhackRefreshQueued)
    {
        return;
    }

    g_bWallhackRefreshQueued = true;
    RequestFrame(Frame_RefreshWallhackMarkers);
}

public void Frame_RefreshWallhackMarkers(any data)
{
    g_bWallhackRefreshQueued = false;
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive() || !HasActiveWallhackViewer() ||
        g_iWallhackBeamModel <= 0)
    {
        ClearAllWallhackMarkers();
        return;
    }

    MaintainWallhackMarkers();
    StartWallhackTimer();
}

bool HasActiveWallhackViewer()
{
    for (int viewer = 1; viewer <= MaxClients; viewer++)
    {
        if (IsValidPlayingClient(viewer) && IsPlayerAlive(viewer) &&
            IsRSPPowerRuntimeActiveForClient(viewer) && g_iPower[viewer] == RSP_Wallhack &&
            g_iAssignedRound[viewer] == g_iRoundSerial)
        {
            return true;
        }
    }
    return false;
}

bool CanViewerSeeWallhackMarker(int viewer, int target)
{
    return viewer >= 1 && viewer <= MaxClients && target >= 1 && target <= MaxClients &&
        viewer != target && IsValidPlayingClient(viewer) && IsPlayerAlive(viewer) &&
        IsRSPPowerRuntimeActiveForClient(viewer) && g_iPower[viewer] == RSP_Wallhack &&
        g_iAssignedRound[viewer] == g_iRoundSerial && IsValidPlayingClient(target) &&
        IsPlayerAlive(target) && g_iPower[target] != RSP_Ghost &&
        GetClientTeam(viewer) != GetClientTeam(target);
}

bool HasEnemyWallhackViewer(int target)
{
    if (target < 1 || target > MaxClients || !IsValidPlayingClient(target) ||
        !IsPlayerAlive(target) || g_iPower[target] == RSP_Ghost)
    {
        return false;
    }

    for (int viewer = 1; viewer <= MaxClients; viewer++)
    {
        if (viewer != target && IsValidPlayingClient(viewer) && IsPlayerAlive(viewer) &&
            IsRSPPowerRuntimeActiveForClient(viewer) && g_iPower[viewer] == RSP_Wallhack &&
            g_iAssignedRound[viewer] == g_iRoundSerial &&
            GetClientTeam(viewer) != GetClientTeam(target))
        {
            return true;
        }
    }
    return false;
}

void MaintainWallhackMarkers()
{
    if (!HasActiveWallhackViewer() || g_iWallhackBeamModel <= 0)
    {
        ClearAllWallhackMarkers();
        return;
    }

    for (int target = 1; target <= MaxClients; target++)
    {
        if (IsValidPlayingClient(target) && IsPlayerAlive(target) && HasEnemyWallhackViewer(target))
        {
            EnsureWallhackMarker(target);
        }
        else
        {
            DestroyWallhackMarker(target);
        }
    }
}

void EnsureWallhackMarker(int target)
{
    if (target < 1 || target > MaxClients || !IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
        g_iWallhackBeamModel <= 0 || !HasEnemyWallhackViewer(target))
    {
        DestroyWallhackMarker(target);
        return;
    }

    bool complete = true;
    for (int point = 0; point < 8; point++)
    {
        int anchor = g_iWallhackAnchorEntity[target][point];
        if (anchor <= MaxClients || anchor >= RSP_MAX_ENTITIES || !IsValidEntity(anchor) ||
            g_iWallhackMarkerTarget[anchor] != target)
        {
            complete = false;
            break;
        }
    }
    if (complete)
    {
        for (int edge = 0; edge < 12; edge++)
        {
            int beam = g_iWallhackBeamEntity[target][edge];
            if (beam <= MaxClients || beam >= RSP_MAX_ENTITIES || !IsValidEntity(beam) ||
                g_iWallhackMarkerTarget[beam] != target)
            {
                complete = false;
                break;
            }
        }
    }
    if (complete)
    {
        return;
    }

    DestroyWallhackMarker(target);

    int anchors[8];
    for (int point = 0; point < 8; point++)
    {
        anchors[point] = CreateWallhackAnchor(target, point);
        if (anchors[point] == 0)
        {
            DestroyWallhackMarker(target);
            return;
        }
    }

    for (int edge = 0; edge < 12; edge++)
    {
        int startAnchor = anchors[g_iWallhackEdges[edge][0]];
        int endAnchor = anchors[g_iWallhackEdges[edge][1]];
        int beam = CreateWallhackEdge(target, edge, startAnchor, endAnchor);
        if (beam == 0)
        {
            DestroyWallhackMarker(target);
            return;
        }
    }
}

int CreateWallhackAnchor(int target, int point)
{
    int anchor = CreateEntityByName("point_viewcontrol");
    if (anchor <= MaxClients || anchor >= RSP_MAX_ENTITIES || !IsValidEntity(anchor))
    {
        if (anchor > MaxClients && IsValidEntity(anchor))
        {
            RemoveEntity(anchor);
        }
        return 0;
    }

    float playerOrigin[3], playerAngles[3], worldOrigin[3];
    GetClientAbsOrigin(target, playerOrigin);
    GetClientAbsAngles(target, playerAngles);

    float yawRadians = DegToRad(playerAngles[1]);
    float localX = g_fWallhackAnchorOffsets[point][0];
    float localY = g_fWallhackAnchorOffsets[point][1];
    float localZ = g_fWallhackAnchorOffsets[point][2];
    worldOrigin[0] = playerOrigin[0] + localX * Cosine(yawRadians) - localY * Sine(yawRadians);
    worldOrigin[1] = playerOrigin[1] + localX * Sine(yawRadians) + localY * Cosine(yawRadians);
    worldOrigin[2] = playerOrigin[2] + localZ;

    DispatchKeyValueVector(anchor, "origin", worldOrigin);
    char anchorName[64];
    Format(anchorName, sizeof(anchorName), "rsp_wallhack_anchor_%d_%d", target, point);
    DispatchKeyValue(anchor, "targetname", anchorName);
    if (!DispatchSpawn(anchor))
    {
        RemoveEntity(anchor);
        return 0;
    }
    ActivateEntity(anchor);

    // Establish the world-space position first, then parent. Source maintains this offset
    // and continuously interpolates the endpoint together with the player entity.
    SetVariantString("!activator");
    AcceptEntityInput(anchor, "SetParent", target, anchor);

    g_iWallhackAnchorEntity[target][point] = anchor;
    g_iWallhackMarkerTarget[anchor] = target;
    SDKHook(anchor, SDKHook_SetTransmit, Hook_RSPSetTransmit);
    return anchor;
}

int CreateWallhackEdge(int target, int edge, int startAnchor, int endAnchor)
{
    if (startAnchor <= MaxClients || endAnchor <= MaxClients ||
        !IsValidEntity(startAnchor) || !IsValidEntity(endAnchor))
    {
        return 0;
    }

    // CEnvBeam resolves LightningStart/LightningEnd during Spawn. Setting only
    // m_hAttachEntity after Spawn can leave an env_beam without initialized endpoints
    // on some CS:S builds, so provide the named endpoints through native KeyValues.
    char startName[64], endName[64], beamName[64], originString[64];
    Format(startName, sizeof(startName), "rsp_wallhack_anchor_%d_%d", target,
        g_iWallhackEdges[edge][0]);
    Format(endName, sizeof(endName), "rsp_wallhack_anchor_%d_%d", target,
        g_iWallhackEdges[edge][1]);
    Format(beamName, sizeof(beamName), "rsp_wallhack_beam_%d_%d", target, edge);

    int beam = CreateEntityByName("env_beam");
    if (beam <= MaxClients || beam >= RSP_MAX_ENTITIES || !IsValidEntity(beam))
    {
        if (beam > MaxClients && IsValidEntity(beam))
        {
            RemoveEntity(beam);
        }
        return 0;
    }

    float targetOrigin[3];
    GetClientAbsOrigin(target, targetOrigin);
    Format(originString, sizeof(originString), "%f %f %f",
        targetOrigin[0], targetOrigin[1], targetOrigin[2]);
    DispatchKeyValue(beam, "targetname", beamName);
    DispatchKeyValue(beam, "LightningStart", startName);
    DispatchKeyValue(beam, "LightningEnd", endName);
    DispatchKeyValue(beam, "texture", RSP_WALLHACK_BEAM_TEXTURE);
    DispatchKeyValue(beam, "rendercolor", "0 255 0");
    DispatchKeyValue(beam, "renderamt", "255");
    DispatchKeyValue(beam, "life", "0");
    DispatchKeyValueFloat(beam, "BoltWidth", RSP_WALLHACK_BEAM_WIDTH);
    DispatchKeyValue(beam, "NoiseAmplitude", "0");
    DispatchKeyValue(beam, "TextureScroll", "0");
    DispatchKeyValue(beam, "spawnflags", "1"); // start on
    DispatchKeyValue(beam, "origin", originString);

    if (!DispatchSpawn(beam))
    {
        RemoveEntity(beam);
        return 0;
    }
    ActivateEntity(beam);
    AcceptEntityInput(beam, "TurnOn");

    if (HasEntProp(beam, Prop_Data, "m_fWidth"))
    {
        SetEntPropFloat(beam, Prop_Data, "m_fWidth", RSP_WALLHACK_BEAM_WIDTH);
    }
    if (HasEntProp(beam, Prop_Data, "m_fEndWidth"))
    {
        SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", RSP_WALLHACK_BEAM_WIDTH);
    }

    g_iWallhackBeamEntity[target][edge] = beam;
    g_iWallhackMarkerTarget[beam] = target;
    SDKHook(beam, SDKHook_SetTransmit, Hook_RSPSetTransmit);
    return beam;
}

void DestroyWallhackMarker(int target)
{
    if (target < 1 || target > MaxClients)
    {
        return;
    }

    // Remove edges before endpoint anchors so no beam can retain an invalid endpoint handle.
    for (int edge = 0; edge < 12; edge++)
    {
        int beam = g_iWallhackBeamEntity[target][edge];
        g_iWallhackBeamEntity[target][edge] = 0;
        if (beam > MaxClients && beam < RSP_MAX_ENTITIES && IsValidEntity(beam))
        {
            g_iWallhackMarkerTarget[beam] = 0;
            SDKUnhook(beam, SDKHook_SetTransmit, Hook_RSPSetTransmit);
            AcceptEntityInput(beam, "TurnOff");
            RemoveEntity(beam);
        }
    }

    for (int point = 0; point < 8; point++)
    {
        int anchor = g_iWallhackAnchorEntity[target][point];
        g_iWallhackAnchorEntity[target][point] = 0;
        if (anchor > MaxClients && anchor < RSP_MAX_ENTITIES && IsValidEntity(anchor))
        {
            g_iWallhackMarkerTarget[anchor] = 0;
            SDKUnhook(anchor, SDKHook_SetTransmit, Hook_RSPSetTransmit);
            RemoveEntity(anchor);
        }
    }
}

void ClearAllWallhackMarkers()
{
    for (int target = 1; target <= MaxClients; target++)
    {
        DestroyWallhackMarker(target);
    }
}

public void Frame_ApplyBulletJumpImpulse(any userid)
{
    int client = GetClientOfUserId(userid);
    if (client >= 1 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client) &&
        g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActiveForClient(client) && g_iPower[client] == RSP_Knockback)
    {
        ApplyBulletJumpImpulse(client);
    }
}

void ApplyBulletJumpImpulse(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))
    {
        return;
    }

    float eyeAngles[3], forwardVec[3], rightVec[3], upVec[3], velocity[3];
    GetClientEyeAngles(client, eyeAngles);
    GetAngleVectors(eyeAngles, forwardVec, rightVec, upVec);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
    bool onGround = (GetEntityFlags(client) & FL_ONGROUND) != 0;

    // Always push horizontally opposite the shot direction. Vertical recoil is ignored
    // for ordinary aim angles so tiny downward corrections cannot launch the player.
    velocity[0] -= forwardVec[0] * RSP_KNOCKBACK_IMPULSE;
    velocity[1] -= forwardVec[1] * RSP_KNOCKBACK_IMPULSE;

    // Only a deliberately steep downward aim (about 45 degrees or more) adds upward
    // impulse. A grounded player receives a defined takeoff only in that case.
    bool steepDownwardAim = forwardVec[2] <= -RSP_KNOCKBACK_VERTICAL_AIM_THRESHOLD;
    if (steepDownwardAim)
    {
        velocity[2] -= forwardVec[2] * RSP_KNOCKBACK_IMPULSE;
        if (onGround && velocity[2] < RSP_KNOCKBACK_GROUND_LAUNCH_MIN)
        {
            velocity[2] = RSP_KNOCKBACK_GROUND_LAUNCH_MIN;
        }
    }

    float horizontalSpeed = SquareRoot(velocity[0] * velocity[0] + velocity[1] * velocity[1]);
    if (horizontalSpeed > RSP_KNOCKBACK_MAX_HORIZONTAL_SPEED)
    {
        float scale = RSP_KNOCKBACK_MAX_HORIZONTAL_SPEED / horizontalSpeed;
        velocity[0] *= scale;
        velocity[1] *= scale;
    }
    if (velocity[2] > RSP_KNOCKBACK_MAX_VERTICAL_SPEED)
    {
        velocity[2] = RSP_KNOCKBACK_MAX_VERTICAL_SPEED;
    }
    else if (velocity[2] < -RSP_KNOCKBACK_MAX_VERTICAL_SPEED)
    {
        velocity[2] = -RSP_KNOCKBACK_MAX_VERTICAL_SPEED;
    }

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
}

void QueueDeathExplosion(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !IsRSPPowerRuntimeActiveForClient(client))
    {
        return;
    }
    GetClientAbsOrigin(client, g_fDeathExplosionOrigin[client]);
    g_bDeathExplosionPending[client] = true;
    g_iDeathExplosionOwnerTeam[client] = GetClientTeam(client);
    g_iDeathExplosionOwnerUserId[client] = GetClientUserId(client);
    g_iDeathExplosionRound[client] = g_iRoundSerial;
    RequestFrame(Frame_DeathExplosion, GetClientUserId(client));
}

public void Frame_DeathExplosion(any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !g_bDeathExplosionPending[client])
    {
        return;
    }

    int ownerUserId = g_iDeathExplosionOwnerUserId[client];
    int ownerTeam = g_iDeathExplosionOwnerTeam[client];
    int roundSerial = g_iDeathExplosionRound[client];
    float origin[3];
    origin[0] = g_fDeathExplosionOrigin[client][0];
    origin[1] = g_fDeathExplosionOrigin[client][1];
    origin[2] = g_fDeathExplosionOrigin[client][2];
    g_bDeathExplosionPending[client] = false;
    g_iDeathExplosionOwnerTeam[client] = 0;
    g_iDeathExplosionOwnerUserId[client] = 0;
    g_iDeathExplosionRound[client] = 0;

    if (!g_bEnabled || !g_bSupportedMap || roundSerial != g_iRoundSerial)
    {
        return;
    }

    int explosion = CreateEntityByName("env_explosion");
    if (explosion == -1 || !IsValidEntity(explosion))
    {
        return;
    }

    char magnitude[16], radius[16];
    IntToString(RSP_DEATH_BOMB_MAGNITUDE, magnitude, sizeof(magnitude));
    IntToString(RSP_DEATH_BOMB_RADIUS, radius, sizeof(radius));
    DispatchKeyValue(explosion, "iMagnitude", magnitude);
    DispatchKeyValue(explosion, "iRadiusOverride", radius);
    // NODECAL suppresses the native vertical-only scorch; RSP projects one at the actual ground point.
    DispatchKeyValue(explosion, "spawnflags", "16");
    DispatchSpawn(explosion);
    TeleportEntity(explosion, origin, NULL_VECTOR, NULL_VECTOR);
    if (explosion > MaxClients && explosion < RSP_MAX_ENTITIES)
    {
        g_iRSPDeathExplosionTeam[explosion] = ownerTeam;
    }

    int owner = GetClientOfUserId(ownerUserId);
    if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner) &&
        HasEntProp(explosion, Prop_Data, "m_hOwnerEntity"))
    {
        SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", owner);
    }
    if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner))
    {
        AcceptEntityInput(explosion, "Explode", owner, owner);
    }
    else
    {
        AcceptEntityInput(explosion, "Explode");
    }
    SendDeathBombGroundScorch(origin);
    CreateTimer(0.20, Timer_RemoveExplosion, EntIndexToEntRef(explosion), TIMER_FLAG_NO_MAPCHANGE);
}

public bool TraceFilter_DeathBombDecal(int entity, int contentsMask, any data)
{
    if (entity >= 1 && entity <= MaxClients)
    {
        return false;
    }
    if (entity <= MaxClients || !IsValidEntity(entity))
    {
        return true;
    }
    char classname[64];
    GetEntityClassname(entity, classname, sizeof(classname));
    // Skip ragdolls and movable model props so the trace can reach the map floor underneath.
    if (StrContains(classname, "prop_", false) == 0)
    {
        return false;
    }
    return true;
}

void SendDeathBombGroundScorch(const float explosionOrigin[3])
{
    if (g_iExplosiveBulletDecal <= 0)
    {
        return;
    }
    float traceStart[3], traceEnd[3];
    for (int axis = 0; axis < 3; axis++)
    {
        traceStart[axis] = explosionOrigin[axis];
        traceEnd[axis] = explosionOrigin[axis];
    }
    traceStart[2] += 24.0;
    traceEnd[2] -= 128.0;
    TR_TraceRayFilter(traceStart, traceEnd, MASK_SOLID | CONTENTS_DEBRIS,
        RayType_EndPoint, TraceFilter_DeathBombDecal, 0);
    if (!TR_DidHit() || TR_StartSolid() || TR_AllSolid())
    {
        return;
    }
    float impactPosition[3], impactNormal[3];
    TR_GetEndPosition(impactPosition);
    TR_GetPlaneNormal(INVALID_HANDLE, impactNormal);
    int impactEntity = TR_GetEntityIndex();
    int surfaceFlags = TR_GetSurfaceFlags();
    if (impactNormal[2] < 0.5 ||
        (surfaceFlags & (SURF_NODECALS | SURF_NODRAW | SURF_SKY)) != 0 ||
        !IsExplosiveBulletDecalSurface(impactEntity))
    {
        return;
    }
    SendExplosiveBulletScorchDecal(impactPosition, impactNormal, impactEntity);
}

public Action Timer_RemoveExplosion(Handle timer, any entityRef)
{
    int entity = EntRefToEntIndex(entityRef);
    if (entity > MaxClients && IsValidEntity(entity))
    {
        AcceptEntityInput(entity, "Kill");
    }
    return Plugin_Stop;
}

void RemovePhoenixWeaponEntity(int client, int weapon)
{
    if (weapon <= MaxClients || !IsValidEntity(weapon))
    {
        return;
    }
    if (RemovePlayerItem(client, weapon) && IsValidEntity(weapon))
    {
        RemoveEntity(weapon);
    }
}

bool IsPhoenixBombObjectiveMap()
{
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "func_bomb_target")) != -1)
    {
        if (IsValidEntity(entity)) return true;
    }
    return false;
}

void RestorePhoenixLoadout(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        g_bRoundEnding || !IsPlayerAlive(client)) return;

    int team = GetClientTeam(client);
    char primary[24];
    if (team == CS_TEAM_CT) strcopy(primary, sizeof(primary), "weapon_m4a1");
    else if (team == CS_TEAM_T) strcopy(primary, sizeof(primary), "weapon_ak47");
    else return;

    // CS:S already gives the normal team pistol and knife on respawn.
    int oldPrimary = GetPlayerWeaponSlot(client, 0);
    if (oldPrimary > MaxClients && IsValidEntity(oldPrimary))
        RemovePhoenixWeaponEntity(client, oldPrimary);

    // Leave exactly one HE grenade; no old flash/smoke stock is carried over.
    int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
    int oldGrenades[16], count = 0;
    for (int i = 0; i < size && count < sizeof(oldGrenades); i++)
    {
        int item = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
        if (item <= MaxClients || !IsValidEntity(item)) continue;
        char classname[64];
        GetEntityClassname(item, classname, sizeof(classname));
        if (StrEqual(classname, "weapon_hegrenade", false) ||
            StrEqual(classname, "weapon_flashbang", false) ||
            StrEqual(classname, "weapon_smokegrenade", false))
            oldGrenades[count++] = item;
    }
    for (int i = 0; i < count; i++)
        RemovePhoenixWeaponEntity(client, oldGrenades[i]);

    int rifle = GivePlayerItem(client, primary);
    if (rifle > MaxClients && IsValidEntity(rifle)) EquipPlayerWeapon(client, rifle);
    GivePlayerItem(client, "weapon_hegrenade");

    if (HasEntProp(client, Prop_Send, "m_ArmorValue"))
        SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
    if (HasEntProp(client, Prop_Send, "m_bHasHelmet"))
        SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
    if (HasEntProp(client, Prop_Send, "m_bHasDefuser"))
        SetEntProp(client, Prop_Send, "m_bHasDefuser",
            (team == CS_TEAM_CT && IsPhoenixBombObjectiveMap()) ? 1 : 0);

}

void Frame_RestorePhoenixLoadout(any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    RestorePhoenixLoadout(client);
}

bool QueuePowerRespawn(int client, int kind)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !IsValidPlayingClient(client) || !IsRSPPowerRuntimeActiveForClient(client) ||
        g_bRoundEnding || g_bPowerRespawnPending[client] ||
        (g_bZombieRespawnPending[client] && g_iZombieRespawnRound[client] == g_iRoundSerial))
    {
        return false;
    }

    g_bPowerRespawnPending[client] = true;
    g_iPowerRespawnRound[client] = g_iRoundSerial;
    g_iPowerRespawnAttempts[client] = 0;
    g_iPowerRespawnKind[client] = kind;
    if (g_hPowerRespawnTimer[client] != null)
    {
        delete g_hPowerRespawnTimer[client];
    }
    g_hPowerRespawnTimer[client] = CreateTimer(RSP_POWER_RESPAWN_DELAY,
        Timer_PowerRespawn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    if (g_hPowerRespawnTimer[client] == null)
    {
        CancelPowerRespawn(client);
        return false;
    }
    return true;
}

void CancelPowerRespawn(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }
    if (g_hPowerRespawnTimer[client] != null)
    {
        delete g_hPowerRespawnTimer[client];
        g_hPowerRespawnTimer[client] = null;
    }
    g_bPowerRespawnPending[client] = false;
    g_iPowerRespawnRound[client] = 0;
    g_iPowerRespawnAttempts[client] = 0;
    g_iPowerRespawnKind[client] = 0;
    g_iReviverOwnerUserId[client] = 0;
}

public Action Timer_PowerRespawn(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients)
    {
        return Plugin_Stop;
    }
    if (g_hPowerRespawnTimer[client] == timer)
    {
        g_hPowerRespawnTimer[client] = null;
    }

    if (!g_bEnabled || !g_bSupportedMap || g_bRoundEnding || !IsRSPPowerRuntimeActiveForClient(client) ||
        !IsClientInGame(client) || !IsValidPlayingClient(client) ||
        !g_bPowerRespawnPending[client] || g_iPowerRespawnRound[client] != g_iRoundSerial)
    {
        bool failedCurrentRoundRespawn = g_bPowerRespawnPending[client] &&
            g_iPowerRespawnRound[client] == g_iRoundSerial;
        int failedTeamBeforeCleanup = IsClientInGame(client) ? GetClientTeam(client) : 0;
        int failedKind = g_iPowerRespawnKind[client];
        int failedMedicUserId = (failedKind == RSP_POWER_RESPAWN_REVIVER)
            ? g_iReviverOwnerUserId[client] : 0;
        CancelPowerRespawn(client);
        if (failedKind == RSP_POWER_RESPAWN_REVIVER)
        {
            NotifyReviverOutcome(failedMedicUserId, false);
        }
        // CS_OnTerminateRound may already have held the elimination while this timer
        // was pending. If the current-round respawn is abandoned, release that hold.
        if (failedCurrentRoundRespawn)
        {
            EndRoundIfRespawnFailureLeavesTeamEliminated(failedTeamBeforeCleanup);
        }
        return Plugin_Stop;
    }

    if (IsPlayerAlive(client))
    {
        int kindAlive = g_iPowerRespawnKind[client];
        int medicUserIdAlive = (kindAlive == RSP_POWER_RESPAWN_REVIVER)
            ? g_iReviverOwnerUserId[client] : 0;
        CancelPowerRespawn(client);
        if (kindAlive == RSP_POWER_RESPAWN_PHOENIX)
        {
            RequestFrame(Frame_RestorePhoenixLoadout, GetClientUserId(client));
        }
        NotifyPowerRespawn(client, kindAlive);
        if (kindAlive == RSP_POWER_RESPAWN_REVIVER)
        {
            NotifyReviverOutcome(medicUserIdAlive, true);
        }
        return Plugin_Stop;
    }

    g_iPowerRespawnAttempts[client]++;
    PreservePlayerRagdollBeforeRespawn(client);
    CS_RespawnPlayer(client);
    if (IsPlayerAlive(client))
    {
        int kind = g_iPowerRespawnKind[client];
        int medicUserId = (kind == RSP_POWER_RESPAWN_REVIVER)
            ? g_iReviverOwnerUserId[client] : 0;
        CancelPowerRespawn(client);
        if (kind == RSP_POWER_RESPAWN_PHOENIX)
        {
            RequestFrame(Frame_RestorePhoenixLoadout, GetClientUserId(client));
        }
        NotifyPowerRespawn(client, kind);
        if (kind == RSP_POWER_RESPAWN_REVIVER)
        {
            NotifyReviverOutcome(medicUserId, true);
        }
        return Plugin_Stop;
    }

    if (g_iPowerRespawnAttempts[client] < RSP_POWER_RESPAWN_RETRIES)
    {
        Handle retryTimer = CreateTimer(RSP_POWER_RESPAWN_RETRY_DELAY,
            Timer_PowerRespawn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
        if (retryTimer != null)
        {
            g_hPowerRespawnTimer[client] = retryTimer;
            return Plugin_Stop;
        }

        int failedTeam = GetClientTeam(client);
        int failedKindOnRetry = g_iPowerRespawnKind[client];
        int failedMedicUserIdOnRetry = (failedKindOnRetry == RSP_POWER_RESPAWN_REVIVER)
            ? g_iReviverOwnerUserId[client] : 0;
        CancelPowerRespawn(client);
        if (failedKindOnRetry == RSP_POWER_RESPAWN_REVIVER)
        {
            NotifyReviverOutcome(failedMedicUserIdOnRetry, false);
        }
        EndRoundIfRespawnFailureLeavesTeamEliminated(failedTeam);
        return Plugin_Stop;
    }

    int team = GetClientTeam(client);
    int failedKind = g_iPowerRespawnKind[client];
    int failedMedicUserId = (failedKind == RSP_POWER_RESPAWN_REVIVER)
        ? g_iReviverOwnerUserId[client] : 0;
    CancelPowerRespawn(client);
    if (failedKind == RSP_POWER_RESPAWN_REVIVER)
    {
        NotifyReviverOutcome(failedMedicUserId, false);
    }
    EndRoundIfRespawnFailureLeavesTeamEliminated(team);
    return Plugin_Stop;
}

void NotifyPowerRespawn(int client, int kind)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }
    if (kind == RSP_POWER_RESPAWN_PHOENIX)
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Phoenix: wracasz do rundy."
            : "\x04[RSP]\x01 Phoenix: you are back in the round.");
    }
    else if (kind == RSP_POWER_RESPAWN_RESURRECTION)
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Resurrection: odradzasz się po śmierci."
            : "\x04[RSP]\x01 Resurrection: you have returned to the round.");
    }
}

void NotifyReviverOutcome(int medicUserId, bool success)
{
    int medic = GetClientOfUserId(medicUserId);
    if (medic < 1 || medic > MaxClients || !IsClientInGame(medic))
    {
        return;
    }

    if (success)
    {
        PrintToChat(medic, IsPolishClient(medic)
            ? "\x04[RSP]\x01 Sojusznik został pomyślnie ożywiony."
            : "\x04[RSP]\x01 Teammate successfully revived.");
    }
    else
    {
        PrintToChat(medic, IsPolishClient(medic)
            ? "\x04[RSP]\x01 Tym razem nie udało się ożywić sojusznika."
            : "\x04[RSP]\x01 This time, the teammate could not be revived.");
    }
}

void StopReviverCooldown(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    if (g_hReviverReadyTimer[client] != null)
    {
        delete g_hReviverReadyTimer[client];
        g_hReviverReadyTimer[client] = null;
    }
    g_fReviverNextUseTime[client] = 0.0;
}

void StartReviverCooldown(int medic)
{
    if (medic < 1 || medic > MaxClients || !IsClientInGame(medic))
    {
        return;
    }

    if (g_hReviverReadyTimer[medic] != null)
    {
        delete g_hReviverReadyTimer[medic];
        g_hReviverReadyTimer[medic] = null;
    }

    g_fReviverNextUseTime[medic] = GetEngineTime() + RSP_REVIVER_COOLDOWN;
    g_hReviverReadyTimer[medic] = CreateTimer(RSP_REVIVER_COOLDOWN,
        Timer_MedicCooldownReady, GetClientUserId(medic), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_MedicCooldownReady(Handle timer, any userid)
{
    int medic = GetClientOfUserId(userid);
    if (medic < 1 || medic > MaxClients || !IsClientInGame(medic))
    {
        return Plugin_Stop;
    }
    if (g_hReviverReadyTimer[medic] != timer)
    {
        return Plugin_Stop;
    }

    g_hReviverReadyTimer[medic] = null;
    float remaining = g_fReviverNextUseTime[medic] - GetEngineTime();
    if (remaining > 0.05)
    {
        g_hReviverReadyTimer[medic] = CreateTimer(remaining,
            Timer_MedicCooldownReady, GetClientUserId(medic), TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Stop;
    }

    g_fReviverNextUseTime[medic] = 0.0;
    if (g_bEnabled && g_bSupportedMap && IsRSPPowerRuntimeActiveForClient(medic) &&
        IsValidPlayingClient(medic) && IsPlayerAlive(medic) &&
        g_iPower[medic] == RSP_Reviver && g_iAssignedRound[medic] == g_iRoundSerial)
    {
        PrintToChat(medic, IsPolishClient(medic)
            ? "\x04[RSP]\x01 Znów możesz spróbować wskrzeszyć sojusznika."
            : "\x04[RSP]\x01 You can try to revive a teammate again.");
    }
    return Plugin_Stop;
}

void StopSkillCooldown(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }


    g_iExplodingBarrelsPlacedTowardCooldown[client] = 0;

    if (g_hSkillReadyTimer[client] != null)
    {
        delete g_hSkillReadyTimer[client];
        g_hSkillReadyTimer[client] = null;
    }
    g_fNextSkillUseTime[client] = 0.0;
}

void StartSkillCooldown(int client, float duration)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || duration <= 0.0)
    {
        return;
    }

    if (g_hSkillReadyTimer[client] != null)
    {
        delete g_hSkillReadyTimer[client];
        g_hSkillReadyTimer[client] = null;
    }

    g_fNextSkillUseTime[client] = GetEngineTime() + duration;
    g_hSkillReadyTimer[client] = CreateTimer(duration,
        Timer_SkillCooldownReady, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_SkillCooldownReady(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return Plugin_Stop;
    }
    if (g_hSkillReadyTimer[client] != timer)
    {
        return Plugin_Stop;
    }

    g_hSkillReadyTimer[client] = null;
    float remaining = g_fNextSkillUseTime[client] - GetEngineTime();
    if (remaining > 0.05)
    {
        g_hSkillReadyTimer[client] = CreateTimer(remaining,
            Timer_SkillCooldownReady, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Stop;
    }

    g_fNextSkillUseTime[client] = 0.0;
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
        !IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iAssignedRound[client] != g_iRoundSerial)
    {
        return Plugin_Stop;
    }

    bool polish = IsPolishClient(client);
    switch (g_iPower[client])
    {
        case RSP_Swapper:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Znów możesz użyć Swappera."
                : "\x04[RSP]\x01 You can use Swapper again.");
        }
        case RSP_Retreat:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Znów możesz wrócić na spawn."
                : "\x04[RSP]\x01 You can retreat to spawn again.");
        }
        case RSP_EnemySpawn:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Znów możesz teleportować się na spawn przeciwnika."
                : "\x04[RSP]\x01 You can teleport to the enemy spawn again.");
        }
        case RSP_NoClip:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Ponownie możesz użyć Noclip."
                : "\x04[RSP]\x01 You can use NoClip again.");
        }
        case RSP_GodMode:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Znów możesz użyć God Mode."
                : "\x04[RSP]\x01 You can use God Mode again.");
        }
        case RSP_RandomWeapon:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Znów możesz użyć Random Weapon."
                : "\x04[RSP]\x01 You can use Random Weapon again.");
        }
        case RSP_StripWeapons:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Znów możesz użyć Heist."
                : "\x04[RSP]\x01 You can use Heist again.");
        }
        case RSP_ExplodingBarrel:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Znów możesz postawić wybuchową beczkę."
                : "\x04[RSP]\x01 You can place an explosive barrel again.");
        }
        case RSP_Dash:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Dash jest ponownie gotowy."
                : "\x04[RSP]\x01 Dash is ready again.");
        }
        case RSP_Reverser:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Reverser jest ponownie gotowy."
                : "\x04[RSP]\x01 Reverser is ready again.");
        }
        case RSP_Replica:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Możesz ponownie postawić replikę."
                : "\x04[RSP]\x01 You can place another Replica.");
        }
        case RSP_Hook:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Lina jest ponownie gotowa."
                : "\x04[RSP]\x01 Hook is ready again.");
        }
        case RSP_Anomaly:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Anomaly jest ponownie gotowa."
                : "\x04[RSP]\x01 Anomaly is ready again.");
        }
        case RSP_Builder:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Możesz ponownie postawić płot."
                : "\x04[RSP]\x01 You can place another fence.");
        }
        case RSP_Inventor:
        {
            // Only announce readiness when there is a charge and a slot for another Tesla.
            int ownerUserId = GetClientUserId(client);
            if (g_iInventorUsesThisRound[client] < RSP_INVENTOR_USES_PER_ROUND &&
                CountBuildablesForOwner(ownerUserId, RSP_BUILDABLE_TURRET) < RSP_INVENTOR_MAX_TURRETS)
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Działko jest ponownie gotowe."
                    : "\x04[RSP]\x01 Your turret is ready again.");
            }
        }
        case RSP_WeaponSwap:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Weapon Swap jest ponownie gotowy."
                : "\x04[RSP]\x01 Weapon Swap is ready again.");
        }
        case RSP_Miner:
        {
            if (g_iMinerUsesThisRound[client] < RSP_MINER_USES_PER_ROUND)
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Możesz ponownie postawić minę."
                    : "\x04[RSP]\x01 You can place another mine.");
            }
        }
        case RSP_Damager:
        {
            PrintToChat(client, polish ? "\x04[RSP]\x01 Damager jest ponownie gotowy."
                : "\x04[RSP]\x01 Damager is ready again.");
        }
    }
    return Plugin_Stop;
}

void ActivateMedic(int medic)
{
    if (medic < 1 || medic > MaxClients || !IsClientInGame(medic) ||
        g_iPower[medic] != RSP_Reviver)
    {
        return;
    }

    // Invalid round/player states are silent. Do not emit repeated failure text
    // from a dead player or during round transitions.
    if (!IsPlayerAlive(medic) || !IsValidPlayingClient(medic) ||
        !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(medic) ||
        g_iAssignedRound[medic] != g_iRoundSerial)
    {
        return;
    }

    bool polish = IsPolishClient(medic);
    float remaining = g_fReviverNextUseTime[medic] - GetEngineTime();
    if (remaining > 0.0)
    {
        int seconds = RoundToCeil(remaining);
        if (polish)
        {
            PrintToChat(medic, "\x04[RSP]\x01 Możesz użyć tej supermocy za %d s.", seconds);
        }
        else
        {
            PrintToChat(medic, "\x04[RSP]\x01 You can use this power again in %d s.", seconds);
        }
        return;
    }

    int deadTeammates[MAXPLAYERS + 1];
    int deadCount = 0;
    int team = GetClientTeam(medic);
    for (int target = 1; target <= MaxClients; target++)
    {
        if (target == medic || !IsValidPlayingClient(target) || IsPlayerAlive(target) ||
            GetClientTeam(target) != team || g_bPowerRespawnPending[target] ||
            (g_bZombieRespawnPending[target] && g_iZombieRespawnRound[target] == g_iRoundSerial))
        {
            continue;
        }
        deadTeammates[deadCount++] = target;
    }

    if (deadCount == 0)
    {
        // No valid target: explain why the command had no effect, but do not
        // start cooldown. A later death can make the power usable immediately.
        PrintToChat(medic, polish
            ? "\x04[RSP]\x01 Nie ma martwych sojuszników do wskrzeszenia."
            : "\x04[RSP]\x01 There are no dead teammates to revive.");
        return;
    }

    int target = deadTeammates[GetRandomInt(0, deadCount - 1)];
    // Every real attempt uses the 20-second cooldown whether the chance succeeds
    // or fails. Repeated command calls during cooldown only report remaining time.
    StartReviverCooldown(medic);

    if (GetRandomInt(1, 2) != 1)
    {
        NotifyReviverOutcome(GetClientUserId(medic), false);
        return;
    }

    if (!QueuePowerRespawn(target, RSP_POWER_RESPAWN_REVIVER))
    {
        NotifyReviverOutcome(GetClientUserId(medic), false);
        return;
    }

    // Result notification occurs only when the teammate has actually respawned,
    // or when the respawn handler gives up. Never auto-trigger Medic on death.
    g_iReviverOwnerUserId[target] = GetClientUserId(medic);
}

void SendRSPBlackoutFadeAlpha(int client, int alpha)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    if (alpha < 0) alpha = 0;
    if (alpha > 255) alpha = 255;

    Handle message = StartMessageOne("Fade", client, USERMSG_RELIABLE);
    if (message == null) return;

    // Zero-duration transparent PURGE immediately clears the current overlay.
    BfWriteShort(message, 0);
    BfWriteShort(message, 0);
    BfWriteShort(message, RSP_SCREEN_FADE_IN | RSP_SCREEN_FADE_PURGE);
    BfWriteByte(message, 0);
    BfWriteByte(message, 0);
    BfWriteByte(message, 0);
    BfWriteByte(message, alpha);
    EndMessage();
}

void SendRSPBlackoutFadeOut(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    Handle message = StartMessageOne("Fade", client, USERMSG_RELIABLE);
    if (message == null) return;

    int duration = RoundToNearest(RSP_BLACKOUT_FADE_DURATION * float(1 << RSP_SCREEN_FADE_FRACBITS));
    BfWriteShort(message, duration);
    BfWriteShort(message, 0);
    BfWriteShort(message, RSP_SCREEN_FADE_OUT | RSP_SCREEN_FADE_STAYOUT | RSP_SCREEN_FADE_PURGE);
    BfWriteByte(message, 0);
    BfWriteByte(message, 0);
    BfWriteByte(message, 0);
    BfWriteByte(message, 255);
    EndMessage();
}

void StopBlackoutRefadeTimer(int target)
{
    if (target < 1 || target > MaxClients) return;
    if (g_hBlackoutRefadeTimer[target] != null)
    {
        delete g_hBlackoutRefadeTimer[target];
        g_hBlackoutRefadeTimer[target] = null;
    }
}

void ClearBlackoutEffect(int target, bool restoreScreen)
{
    if (target < 1 || target > MaxClients) return;
    bool wasActive = g_bBlackoutActive[target];
    StopBlackoutRefadeTimer(target);
    g_bBlackoutActive[target] = false;
    g_iBlackoutRound[target] = 0;
    if (wasActive && restoreScreen && IsClientInGame(target))
    {
        SendRSPBlackoutFadeAlpha(target, 0);
    }
}

void ClearAllBlackoutEffects(bool restoreScreens)
{
    for (int target = 1; target <= MaxClients; target++)
    {
        ClearBlackoutEffect(target, restoreScreens);
    }
}

bool StartBlackoutRefadeTimer(int target)
{
    if (target < 1 || target > MaxClients || !IsClientInGame(target) || !g_bBlackoutActive[target]) return false;
    if (g_hBlackoutRefadeTimer[target] != null) return true;

    // Native Fade animates smoothly; this one-shot timer only owns/validates effect state.
    g_hBlackoutRefadeTimer[target] = CreateTimer(RSP_BLACKOUT_FADE_DURATION + 0.05,
        Timer_BlackoutRefade, GetClientUserId(target), TIMER_FLAG_NO_MAPCHANGE);
    if (g_hBlackoutRefadeTimer[target] == null)
    {
        ClearBlackoutEffect(target, true);
        return false;
    }
    return true;
}

public Action Timer_BlackoutRefade(Handle timer, any userid)
{
    int target = GetClientOfUserId(userid);
    if (target < 1 || target > MaxClients || !IsClientInGame(target) || g_hBlackoutRefadeTimer[target] != timer)
    {
        return Plugin_Stop;
    }
    if (!g_bBlackoutActive[target] || g_iBlackoutRound[target] != g_iRoundSerial || !IsPlayerAlive(target))
    {
        g_hBlackoutRefadeTimer[target] = null;
        ClearBlackoutEffect(target, true);
        return Plugin_Stop;
    }

    // Leave the engine-managed black overlay in place; it reaches full opacity at 3.0 s.
    g_hBlackoutRefadeTimer[target] = null;
    return Plugin_Stop;
}

void ResetBlackoutFadeAfterShot(int target)
{
    if (target < 1 || target > MaxClients || !IsClientInGame(target) || !g_bBlackoutActive[target] ||
        g_iBlackoutRound[target] != g_iRoundSerial || !IsPlayerAlive(target))
    {
        return;
    }
    StopBlackoutRefadeTimer(target);
    SendRSPBlackoutFadeAlpha(target, 0);
    SendRSPBlackoutFadeOut(target);
    StartBlackoutRefadeTimer(target);
}

bool ApplyBlackoutEffect(int owner, int target)
{
    if (owner < 1 || owner > MaxClients || target < 1 || target > MaxClients || owner == target ||
        !IsValidPlayingClient(owner) || !IsPlayerAlive(owner) || !IsValidPlayingClient(target) ||
        !IsPlayerAlive(target) || GetClientTeam(owner) == GetClientTeam(target))
    {
        return false;
    }
    if (g_bBlackoutActive[target] && g_iBlackoutRound[target] == g_iRoundSerial)
    {
        return false;
    }

    ClearBlackoutEffect(target, true);
    g_bBlackoutActive[target] = true;
    g_iBlackoutRound[target] = g_iRoundSerial;
    SendRSPBlackoutFadeAlpha(target, 0);
    SendRSPBlackoutFadeOut(target);
    if (!StartBlackoutRefadeTimer(target)) return false;
    PrintRSPTargetEffectNotice(target, owner, RSP_NOTICE_BLACKOUT);
    return true;
}

void PrintHealingAngelCooldown(int client, int seconds)
{
    switch (GetRSPClientLanguage(client))
    {
        case RSP_LANG_PL: PrintToChat(client, "\x04[RSP]\x01 Healing Angel będzie gotowy za \x04%d s\x01.", seconds);
        default: PrintToChat(client, "\x04[RSP]\x01 Healing Angel will be ready in \x04%d s\x01.", seconds);
    }
}

void PrintHealingAngelNoTarget(int client)
{
    switch (GetRSPClientLanguage(client))
    {
        case RSP_LANG_PL: PrintToChat(client, "\x04[RSP]\x01 Żaden żywy sojusznik nie potrzebuje leczenia.");
        default: PrintToChat(client, "\x04[RSP]\x01 No living teammate needs healing.");
    }
}

void PrintHealingAngelSuccess(int client, int healedCount)
{
    switch (GetRSPClientLanguage(client))
    {
        case RSP_LANG_PL: PrintToChat(client, "\x04[RSP]\x01 Healing Angel: uleczono \x04%d\x01 sojuszników.", healedCount);
        default: PrintToChat(client, "\x04[RSP]\x01 Healing Angel: healed \x04%d\x01 teammates.", healedCount);
    }
}

void PrintHealingAngelTargetNotice(int target, int healer, int amount)
{
    if (target < 1 || target > MaxClients || healer < 1 || healer > MaxClients ||
        !IsClientInGame(target) || !IsClientInGame(healer) || amount <= 0)
    {
        return;
    }

    char healerColor[16];
    int team = GetClientTeam(healer);
    if (team == CS_TEAM_CT) strcopy(healerColor, sizeof(healerColor), "\x0799CCFF");
    else if (team == CS_TEAM_T) strcopy(healerColor, sizeof(healerColor), "\x07FF4040");
    else strcopy(healerColor, sizeof(healerColor), "\x04");

    switch (GetRSPClientLanguage(target))
    {
        case RSP_LANG_PL: PrintToChat(target, "\x04[RSP]\x01 Gracz %s%N\x01 uleczył Cię o \x04%d HP\x01.", healerColor, healer, amount);
        default: PrintToChat(target, "\x04[RSP]\x01 Player %s%N\x01 healed you for \x04%d HP\x01.", healerColor, healer, amount);
    }
}

void ActivateHealingAngel(int healer)
{
    if (healer < 1 || healer > MaxClients || !IsClientInGame(healer) || IsFakeClient(healer) ||
        g_iPower[healer] != RSP_HealingAngel || !IsPlayerAlive(healer) ||
        !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(healer) ||
        g_iAssignedRound[healer] != g_iRoundSerial)
    {
        return;
    }

    float remaining = g_fHealingAngelNextUseTime[healer] - GetEngineTime();
    if (remaining > 0.0)
    {
        PrintHealingAngelCooldown(healer, RoundToCeil(remaining));
        return;
    }

    int team = GetClientTeam(healer);
    int healedCount = 0;
    for (int target = 1; target <= MaxClients; target++)
    {
        if (target == healer || !IsValidPlayingClient(target) || !IsPlayerAlive(target) || GetClientTeam(target) != team)
        {
            continue;
        }
        int health = GetClientHealth(target);
        if (health <= 0 || health >= RSP_HEALING_ANGEL_ALLY_MAX_HEALTH) continue;

        int newHealth = health + RSP_HEALING_ANGEL_HEAL_AMOUNT;
        if (newHealth > RSP_HEALING_ANGEL_ALLY_MAX_HEALTH) newHealth = RSP_HEALING_ANGEL_ALLY_MAX_HEALTH;
        int healedAmount = newHealth - health;
        if (healedAmount <= 0) continue;
        SetEntityHealth(target, newHealth);
        PrintHealingAngelTargetNotice(target, healer, healedAmount);
        healedCount++;
    }

    if (healedCount <= 0)
    {
        PrintHealingAngelNoTarget(healer);
        return;
    }

    g_fHealingAngelNextUseTime[healer] = GetEngineTime() + RSP_HEALING_ANGEL_COOLDOWN;
    PrintHealingAngelSuccess(healer, healedCount);
}








public Action Command_UseSkill(int client, int args)
{
    // SourceMod does not natively support listen-server attribution consistently:
    // a command entered by the local host can reach this handler with client == 0.
    // Recover the host's real player index only on a listen server. Remote clients
    // keep their own index, and a dedicated server never redirects a console command.
    if (client == 0)
    {
        client = FindRSPListenHostClient();
    }

    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    RSPPower activePower = g_iPower[client];
    if (!IsRSPManualSkillPower(activePower))
    {
        return Plugin_Handled;
    }

    bool polish = IsPolishClient(client);
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
        !IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iAssignedRound[client] != g_iRoundSerial)
    {
        return Plugin_Handled;
    }

    float now = GetEngineTime();

    // The first use is free of cooldown, but no manual power may be activated during freeze time.
    if (g_bRoundReady && !g_bRoundFreezeEnded)
    {
        PrintFreezeGateFeedback(client, polish);
        return Plugin_Handled;
    }

    if (activePower == RSP_Spectator && g_bSpectatorActive[client])
    {
        StopSpectatorMode(client, true, true);
        return Plugin_Handled;
    }

    if (activePower == RSP_NoClip && g_bNoclipWindowOpen[client] &&
        now >= g_fNoclipExpiresAt[client])
    {
        bool wasNoclipActive = g_bNoclipActive[client];
        StopNoclip(client, true, wasNoclipActive, true);
        return Plugin_Handled;
    }

    if (activePower == RSP_Reviver)
    {
        ActivateMedic(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_HealingAngel)
    {
        ActivateHealingAngel(client);
        return Plugin_Handled;
    }
    // Inventor has a per-round placement charge and active turret cap; Builder walls
    // are unlimited and use only their normal 5-second cooldown.
    int buildableOwnerUserId = GetClientUserId(client);
    if (activePower == RSP_Inventor)
    {
        if (g_iInventorUsesThisRound[client] >= RSP_INVENTOR_USES_PER_ROUND)
        {
            PrintToChat(client, polish
                ? "\x04[RSP]\x01 Wykorzystałeś oba użycia Inventora w tej rundzie."
                : "\x04[RSP]\x01 You have used both Inventor uses this round.");
            return Plugin_Handled;
        }
        if (CountBuildablesForOwner(buildableOwnerUserId, RSP_BUILDABLE_TURRET) >= RSP_INVENTOR_MAX_TURRETS)
        {
            PrintToChat(client, polish
                ? "\x04[RSP]\x01 Masz już maksymalną liczbę działek (2). Zniszcz jedno, aby postawić kolejne."
                : "\x04[RSP]\x01 You already have the maximum of 2 turrets. Destroy one to place another.");
            return Plugin_Handled;
        }
    }

    // Hook uses a strict five-second cooldown from each successful cast, even while
    // the rope is active. After the cooldown expires a valid new cast may replace the
    // current rope; invalid traces leave the existing pull intact.
    if (now < g_fNextSkillUseTime[client])
    {
        int seconds = RoundToCeil(g_fNextSkillUseTime[client] - now);
        switch (activePower)
        {
            case RSP_Swapper:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Swapper będzie gotowy za %d s."
                    : "\x04[RSP]\x01 Swapper will be ready in %d s.", seconds);
            }
            case RSP_Retreat:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Retreat będzie gotowy za %d s."
                    : "\x04[RSP]\x01 Retreat will be ready in %d s.", seconds);
            }
            case RSP_EnemySpawn:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Enemy Spawn będzie gotowy za %d s."
                    : "\x04[RSP]\x01 Enemy Spawn will be ready in %d s.", seconds);
            }
            case RSP_NoClip:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Noclip będzie gotowy za %d s."
                    : "\x04[RSP]\x01 NoClip will be ready in %d s.", seconds);
            }
            case RSP_Spectator:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Spectator będzie gotowy za %d s."
                    : "\x04[RSP]\x01 Spectator will be ready in %d s.", seconds);
            }
            case RSP_GodMode:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 God Mode będzie gotowy za %d s."
                    : "\x04[RSP]\x01 God Mode will be ready in %d s.", seconds);
            }
            case RSP_RandomWeapon:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Random Weapon będzie gotowy za %d s."
                    : "\x04[RSP]\x01 Random Weapon will be ready in %d s.", seconds);
            }
            case RSP_StripWeapons:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Heist będzie gotowy za %d s."
                    : "\x04[RSP]\x01 Heist will be ready in %d s.", seconds);
            }
            case RSP_ExplodingBarrel:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Wybuchowa beczka będzie gotowa za %d s."
                    : "\x04[RSP]\x01 Exploding Barrel will be ready in %d s.", seconds);
            }
            case RSP_Dash:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Dash będzie gotowy za %d s."
                    : "\x04[RSP]\x01 Dash will be ready in %d s.", seconds);
            }
            case RSP_Reverser:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Reverser będzie gotowy za %d s."
                    : "\x04[RSP]\x01 Reverser will be ready in %d s.", seconds);
            }
            case RSP_Replica:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Replika będzie gotowa za %d s."
                    : "\x04[RSP]\x01 Replica will be ready in %d s.", seconds);
            }
            case RSP_Hook:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Lina będzie gotowa za %d s."
                    : "\x04[RSP]\x01 Hook will be ready in %d s.", seconds);
            }
            case RSP_Anomaly:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Anomaly będzie gotowa za %d s."
                    : "\x04[RSP]\x01 Anomaly will be ready in %d s.", seconds);
            }
            case RSP_Builder:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Płot będzie gotowy za %d s."
                    : "\x04[RSP]\x01 Builder will be ready in %d s.", seconds);
            }
            case RSP_Inventor:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Działko będzie gotowe za %d s."
                    : "\x04[RSP]\x01 Inventor will be ready in %d s.", seconds);
            }
            case RSP_WeaponSwap:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Weapon Swap będzie gotowy za %d s."
                    : "\x04[RSP]\x01 Weapon Swap will be ready in %d s.", seconds);
            }
            case RSP_Entropy:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Entropy będzie gotowe za %d s."
                    : "\x04[RSP]\x01 Entropy will be ready in %d s.", seconds);
            }
            case RSP_Miner:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Kolejna mina będzie gotowa za %d s."
                    : "\x04[RSP]\x01 Your next mine will be ready in %d s.", seconds);
            }
            case RSP_Damager:
            {
                PrintToChat(client, polish ? "\x04[RSP]\x01 Damager będzie gotowy za %d s."
                    : "\x04[RSP]\x01 Damager will be ready in %d s.", seconds);
            }
        }
        return Plugin_Handled;
    }

    if (activePower == RSP_Retreat)
    {
        ActivateRetreat(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_EnemySpawn)
    {
        ActivateEnemySpawn(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_NoClip)
    {
        ActivateNoclip(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_Spectator)
    {
        ActivateSpectatorMode(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_Medic)
    {
        ActivateFirstAid(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_GodMode)
    {
        ActivateGodMode(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_RandomWeapon)
    {
        ActivateRandomWeapon(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_StripWeapons)
    {
        ActivateStripWeapons(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_ExplodingBarrel)
    {
        ActivateExplodingBarrel(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_Dash)
    {
        ActivateDash(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_Reverser)
    {
        ActivateReverseControls(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_Replica)
    {
        ActivateReplica(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_Hook)
    {
        ActivateHook(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_Anomaly)
    {
        ActivateAnomaly(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_Builder)
    {
        ActivateBuilder(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_Inventor)
    {
        ActivateInventor(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_WeaponSwap)
    {
        ActivateWeaponSwap(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_Entropy)
    {
        ActivateEntropy(client);
        return Plugin_Handled;
    }
    if (activePower == RSP_Damager)
    {
        ActivateDamager(client);
        return Plugin_Handled;
    }
    // Grounder is a target-selection power, not an rsp_useskill ability.
    if (activePower == RSP_Miner)
    {
        ActivateMiner(client);
        return Plugin_Handled;
    }
    // Swapper continues below after a fresh cooldown/state check.
    int enemies[MAXPLAYERS + 1];
    int enemyCount = 0;
    int myTeam = GetClientTeam(client);
    for (int target = 1; target <= MaxClients; target++)
    {
        if (target == client || !IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
            GetClientTeam(target) == myTeam)
        {
            continue;
        }
        enemies[enemyCount++] = target;
    }

    if (enemyCount == 0)
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Brak żywych przeciwników do zamiany pozycji."
            : "\x04[RSP]\x01 No living enemy is available for a position swap.");
        return Plugin_Handled;
    }

    float clientOrigin[3], clientAngles[3];
    GetClientAbsOrigin(client, clientOrigin);
    GetClientEyeAngles(client, clientAngles);

    // Start at a random position in the enemy list. If a particular enemy's
    // position cannot be made safe, try the remaining enemies without consuming
    // cooldown or moving either player.
    int startIndex = GetRandomInt(0, enemyCount - 1);
    int chosenTarget = 0;
    float clientDestination[3], targetDestination[3], chosenTargetAngles[3];
    float noAvoidOrigin[3] = {0.0, 0.0, 0.0};

    for (int step = 0; step < enemyCount; step++)
    {
        int listIndex = (startIndex + step) % enemyCount;
        int target = enemies[listIndex];
        if (!IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
            GetClientTeam(target) == myTeam)
        {
            continue;
        }

        float targetOrigin[3], targetAngles[3];
        GetClientAbsOrigin(target, targetOrigin);
        GetClientEyeAngles(target, targetAngles);

        float proposedClientDestination[3];
        float proposedTargetDestination[3];

        // The first player is tested against the target's current position.
        // The second destination is also tested against the first destination,
        // so fallback offsets cannot put both players into overlapping hulls.
        if (!FindSafeSwapPosition(client, targetOrigin, target, client, target,
                0, noAvoidOrigin, proposedClientDestination))
        {
            continue;
        }

        if (!FindSafeSwapPosition(target, clientOrigin, client, client, target,
                client, proposedClientDestination, proposedTargetDestination))
        {
            continue;
        }

        if (!SwapHullsAreSeparated(client, proposedClientDestination,
                target, proposedTargetDestination))
        {
            continue;
        }

        chosenTarget = target;
        for (int axis = 0; axis < 3; axis++)
        {
            clientDestination[axis] = proposedClientDestination[axis];
            targetDestination[axis] = proposedTargetDestination[axis];
            chosenTargetAngles[axis] = targetAngles[axis];
        }
        break;
    }

    if (chosenTarget == 0)
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Nie znaleziono bezpiecznych miejsc do zamiany. Spróbuj ponownie."
            : "\x04[RSP]\x01 No safe positions were found for the swap. Try again.");
        return Plugin_Handled;
    }

    // Revalidate immediately before moving either player. There are no timers or
    // asynchronous callbacks between the safety checks and these teleports.
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        !IsValidPlayingClient(chosenTarget) || !IsPlayerAlive(chosenTarget) ||
        GetClientTeam(chosenTarget) == myTeam)
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Cel Swappera zmienił stan. Spróbuj ponownie."
            : "\x04[RSP]\x01 The Swapper target changed state. Try again.");
        return Plugin_Handled;
    }

    float zeroVelocity[3] = {0.0, 0.0, 0.0};
    TeleportEntity(client, clientDestination, chosenTargetAngles, zeroVelocity);
    TeleportEntity(chosenTarget, targetDestination, clientAngles, zeroVelocity);

    StartSkillCooldown(client, RSP_SWAPPER_COOLDOWN);

    // Only the ability owner receives success feedback. Do not disclose the swap
    // or identify the selected enemy in chat.
    PrintToChat(client, polish
        ? "\x04[RSP]\x01 Pomyślnie doszło do teleportacji."
        : "\x04[RSP]\x01 Teleportation completed successfully.");

    return Plugin_Handled;
}

void ActivateDash(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Dash || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    if (!HasEntProp(client, Prop_Data, "m_vecVelocity"))
    {
        return;
    }

    float viewAngles[3];
    GetClientEyeAngles(client, viewAngles);
    // The boost follows the player's facing direction horizontally, not pitch,
    // so looking down never turns the ability into a ground slam.
    viewAngles[0] = 0.0;
    viewAngles[2] = 0.0;

    float forwardVector[3], rightVector[3], upVector[3];
    GetAngleVectors(viewAngles, forwardVector, rightVector, upVector);

    float velocity[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
    velocity[0] += forwardVector[0] * RSP_DASH_FORWARD_IMPULSE;
    velocity[1] += forwardVector[1] * RSP_DASH_FORWARD_IMPULSE;

    // On the ground, Source's friction can eat most of a horizontal impulse before
    // it carries the player forward. Add a short hop to enter the air immediately;
    // an already airborne Dash keeps its original vertical impulse.
    if ((GetEntityFlags(client) & FL_ONGROUND) != 0)
    {
        velocity[2] = RSP_DASH_GROUND_VERTICAL_IMPULSE;
    }
    else
    {
        velocity[2] += RSP_DASH_VERTICAL_IMPULSE;
    }

    // Prevent repeated boosts on a 4-second cooldown from growing horizontal
    // velocity without bound while retaining existing momentum where reasonable.
    float horizontalSpeed = SquareRoot(velocity[0] * velocity[0] + velocity[1] * velocity[1]);
    if (horizontalSpeed > 1100.0)
    {
        float scale = 1100.0 / horizontalSpeed;
        velocity[0] *= scale;
        velocity[1] *= scale;
    }
    if (velocity[2] > 500.0)
    {
        velocity[2] = 500.0;
    }

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
    StartSkillCooldown(client, RSP_DASH_COOLDOWN);
    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Dash aktywowany."
        : "\x04[RSP]\x01 Dash activated.");
}

void ActivateReverseControls(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Reverser || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    int enemies[MAXPLAYERS + 1];
    int enemyCount = 0;
    int ownerTeam = GetClientTeam(client);
    for (int target = 1; target <= MaxClients; target++)
    {
        if (target == client || !IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
            GetClientTeam(target) == ownerTeam)
        {
            continue;
        }
        enemies[enemyCount++] = target;
    }

    if (enemyCount == 0)
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Brak żywych przeciwników dla Reversera."
            : "\x04[RSP]\x01 No living enemy is available for Reverser.");
        return;
    }

    int target = enemies[GetRandomInt(0, enemyCount - 1)];
    if (!IsValidPlayingClient(target) || !IsPlayerAlive(target) || GetClientTeam(target) == ownerTeam)
    {
        return;
    }

    // The effect is stored on the target, so the caster can die or lose their power
    // without corrupting the target's movement state; the shared round reset clears it.
    g_fReverseControlsUntil[target] = GetGameTime() + RSP_REVERSER_DURATION;
    g_iReverseControlsRound[target] = g_iRoundSerial;
    g_iReverseControlsOwnerUserId[target] = GetClientUserId(client);
    StartSkillCooldown(client, RSP_REVERSER_COOLDOWN);

    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Odwrócono sterowanie losowemu przeciwnikowi na 10 sekund."
        : "\x04[RSP]\x01 A random enemy's movement is reversed for 10 seconds.");
}

void ActivateEnemySpawn(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_EnemySpawn || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    float destination[3];
    if (!FindSafeEnemySpawnPosition(client, destination))
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Nie znaleziono bezpiecznego miejsca na spawnie przeciwnika. Spróbuj ponownie."
            : "\x04[RSP]\x01 No safe position was found at the enemy spawn. Try again.");
        return;
    }

    float angles[3];
    float zeroVelocity[3] = {0.0, 0.0, 0.0};
    GetClientEyeAngles(client, angles);
    TeleportEntity(client, destination, angles, zeroVelocity);
    StartSkillCooldown(client, RSP_RETREAT_COOLDOWN);
    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Teleportowałeś się na spawn przeciwnika."
        : "\x04[RSP]\x01 You teleported to the enemy spawn.");
}

void ActivateRetreat(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Retreat || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    float destination[3];
    if (!FindSafeTeamSpawnPosition(client, destination))
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Nie znaleziono bezpiecznego miejsca na spawnie. Spróbuj ponownie."
            : "\x04[RSP]\x01 No safe position was found at your spawn. Try again.");
        return;
    }

    float angles[3];
    float zeroVelocity[3] = {0.0, 0.0, 0.0};
    GetClientEyeAngles(client, angles);
    TeleportEntity(client, destination, angles, zeroVelocity);
    StartSkillCooldown(client, RSP_RETREAT_COOLDOWN);
    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Wróciłeś na spawn swojej drużyny."
        : "\x04[RSP]\x01 You returned to your team's spawn.");
}

bool FindSafeTeamSpawnPosition(int client, float safeOrigin[3])
{
    return FindSafeSpawnPositionForTeam(client, GetClientTeam(client), safeOrigin);
}

bool FindSafeEnemySpawnPosition(int client, float safeOrigin[3])
{
    if (!IsValidPlayingClient(client))
    {
        return false;
    }
    int team = GetClientTeam(client);
    if (team == CS_TEAM_CT)
    {
        team = CS_TEAM_T;
    }
    else if (team == CS_TEAM_T)
    {
        team = CS_TEAM_CT;
    }
    else
    {
        return false;
    }
    return FindSafeSpawnPositionForTeam(client, team, safeOrigin);
}

bool FindSafeSpawnPositionForTeam(int client, int team, float safeOrigin[3])
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client))
    {
        return false;
    }

    char spawnClass[40];
    if (team == CS_TEAM_CT)
    {
        strcopy(spawnClass, sizeof(spawnClass), "info_player_counterterrorist");
    }
    else if (team == CS_TEAM_T)
    {
        strcopy(spawnClass, sizeof(spawnClass), "info_player_terrorist");
    }
    else
    {
        return false;
    }

    int spawns[128];
    int spawnCount = 0;
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, spawnClass)) != -1)
    {
        if (entity <= MaxClients || !IsValidEntity(entity))
        {
            continue;
        }
        if (spawnCount < sizeof(spawns))
        {
            spawns[spawnCount++] = entity;
        }
    }
    if (spawnCount == 0)
    {
        return false;
    }

    int start = GetRandomInt(0, spawnCount - 1);
    float desired[3];
    float safe[3];
    float noAvoidOrigin[3] = {0.0, 0.0, 0.0};
    for (int step = 0; step < spawnCount; step++)
    {
        int spawn = spawns[(start + step) % spawnCount];
        if (!IsValidEntity(spawn))
        {
            continue;
        }

        // Spawn point entities may expose their origin through either sendprops or
        // datamap depending on the CSS build/entity implementation. Try both so a
        // valid team spawn is not skipped just because one property table lacks it.
        bool gotSpawnOrigin = false;
        if (HasEntProp(spawn, Prop_Send, "m_vecOrigin"))
        {
            GetEntPropVector(spawn, Prop_Send, "m_vecOrigin", desired);
            gotSpawnOrigin = true;
        }
        else if (HasEntProp(spawn, Prop_Data, "m_vecOrigin"))
        {
            GetEntPropVector(spawn, Prop_Data, "m_vecOrigin", desired);
            gotSpawnOrigin = true;
        }
        else if (HasEntProp(spawn, Prop_Data, "m_vecAbsOrigin"))
        {
            GetEntPropVector(spawn, Prop_Data, "m_vecAbsOrigin", desired);
            gotSpawnOrigin = true;
        }

        if (!gotSpawnOrigin)
        {
            continue;
        }
        if (FindSafeSwapPosition(client, desired, client, client, 0, 0,
                noAvoidOrigin, safe))
        {
            for (int axis = 0; axis < 3; axis++)
            {
                safeOrigin[axis] = safe[axis];
            }
            return true;
        }
    }
    return false;
}

void ActivateFirstAid(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Medic || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    bool polish = IsPolishClient(client);
    int health = GetClientHealth(client);
    if (g_iMedicCharges[client] <= 0)
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Nie masz już apteczek w tej rundzie."
            : "\x04[RSP]\x01 You have no medkits left this round.");
        return;
    }
    if (health >= RSP_MEDIC_MAX_HEALTH)
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Masz już co najmniej 100 HP — apteczka nie została zużyta."
            : "\x04[RSP]\x01 You already have at least 100 HP; no medkit was consumed.");
        return;
    }

    int healed = health + RSP_MEDIC_AMOUNT;
    if (healed > RSP_MEDIC_MAX_HEALTH)
    {
        healed = RSP_MEDIC_MAX_HEALTH;
    }
    SetEntityHealth(client, healed);
    g_iMedicCharges[client]--;
    PrintToChat(client, polish
        ? "\x04[RSP]\x01 Apteczka: odzyskano %d HP. Pozostałe użycia: %d."
        : "\x04[RSP]\x01 Medkit restored %d HP. Uses remaining: %d.",
        healed - health, g_iMedicCharges[client]);
}

void RestoreSpectatorWeaponVisibility(int client)
{
    for (int slot = 0; slot < 5; slot++)
    {
        int weapon = EntRefToEntIndex(g_iSpectatorWeaponRefs[client][slot]);
        if (weapon > MaxClients && IsValidEntity(weapon))
        {
            SetEntityRenderMode(weapon, view_as<RenderMode>(g_iSpectatorWeaponRenderMode[client][slot]));
            SetEntityRenderColor(weapon,
                g_iSpectatorWeaponRenderColor[client][slot][0],
                g_iSpectatorWeaponRenderColor[client][slot][1],
                g_iSpectatorWeaponRenderColor[client][slot][2],
                g_iSpectatorWeaponRenderColor[client][slot][3]);
        }
        g_iSpectatorWeaponRefs[client][slot] = INVALID_ENT_REFERENCE;
    }
}

void StopSpectatorMode(int client, bool restorePosition = true, bool startCooldown = false)
{
    if (client < 1 || client > MaxClients) return;
    if (g_hSpectatorTimer[client] != null)
    {
        delete g_hSpectatorTimer[client];
        g_hSpectatorTimer[client] = null;
    }
    bool active = g_bSpectatorActive[client];
    g_bSpectatorActive[client] = false;
    if (!active || !IsClientInGame(client) || !IsValidEntity(client))
    {
        if (IsClientInGame(client))
            UpdateRSPTemporaryVoiceMute(client);
        return;
    }

    MoveType oldMoveType = view_as<MoveType>(g_iSpectatorOldMoveType[client]);
    if (oldMoveType == MOVETYPE_NOCLIP || oldMoveType == MOVETYPE_NONE)
        oldMoveType = MOVETYPE_WALK;
    SetEntityMoveType(client, oldMoveType);
    SetEntityRenderMode(client, view_as<RenderMode>(g_iSpectatorOldRenderMode[client]));
    SetEntityRenderColor(client,
        g_iSpectatorOldRenderColor[client][0],
        g_iSpectatorOldRenderColor[client][1],
        g_iSpectatorOldRenderColor[client][2],
        g_iSpectatorOldRenderColor[client][3]);

    if (g_bSpectatorOldDrawViewModelValid[client] && HasEntProp(client, Prop_Send, "m_bDrawViewmodel"))
        SetEntProp(client, Prop_Send, "m_bDrawViewmodel", g_iSpectatorOldDrawViewModel[client]);
    g_bSpectatorOldDrawViewModelValid[client] = false;
    RestoreSpectatorWeaponVisibility(client);

    if (IsPlayerAlive(client) && restorePosition)
    {
        float origin[3], angles[3], velocity[3] = {0.0, 0.0, 0.0};
        for (int axis = 0; axis < 3; axis++)
        {
            origin[axis] = g_fSpectatorOrigin[client][axis];
            angles[axis] = g_fSpectatorAngles[client][axis];
        }
        TeleportEntity(client, origin, angles, velocity);
    }

    UpdateRSPTemporaryVoiceMute(client);
    if (startCooldown && g_bEnabled && g_bSupportedMap &&
        IsValidPlayingClient(client) && IsPlayerAlive(client) &&
        g_iPower[client] == RSP_Spectator && g_iAssignedRound[client] == g_iRoundSerial)
    {
        StartSkillCooldown(client, RSP_SPECTATOR_COOLDOWN);
    }
}

public Action Timer_SpectatorModeExpired(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        g_hSpectatorTimer[client] != timer) return Plugin_Stop;
    g_hSpectatorTimer[client] = null;
    StopSpectatorMode(client, true, true);
    return Plugin_Stop;
}

void ActivateSpectatorMode(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Spectator || g_iAssignedRound[client] != g_iRoundSerial ||
        g_bSpectatorActive[client]) return;

    GetClientAbsOrigin(client, g_fSpectatorOrigin[client]);
    GetClientEyeAngles(client, g_fSpectatorAngles[client]);
    g_iSpectatorOldMoveType[client] = view_as<int>(GetEntityMoveType(client));
    g_iSpectatorOldRenderMode[client] = view_as<int>(GetEntityRenderMode(client));
    GetEntityRenderColor(client,
        g_iSpectatorOldRenderColor[client][0],
        g_iSpectatorOldRenderColor[client][1],
        g_iSpectatorOldRenderColor[client][2],
        g_iSpectatorOldRenderColor[client][3]);

    g_bSpectatorOldDrawViewModelValid[client] = HasEntProp(client, Prop_Send, "m_bDrawViewmodel");
    if (g_bSpectatorOldDrawViewModelValid[client])
    {
        g_iSpectatorOldDrawViewModel[client] = GetEntProp(client, Prop_Send, "m_bDrawViewmodel");
        SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
    }

    for (int slot = 0; slot < 5; slot++)
    {
        g_iSpectatorWeaponRefs[client][slot] = INVALID_ENT_REFERENCE;
        int weapon = GetPlayerWeaponSlot(client, slot);
        if (weapon > MaxClients && IsValidEntity(weapon))
        {
            g_iSpectatorWeaponRefs[client][slot] = EntIndexToEntRef(weapon);
            g_iSpectatorWeaponRenderMode[client][slot] = view_as<int>(GetEntityRenderMode(weapon));
            GetEntityRenderColor(weapon,
                g_iSpectatorWeaponRenderColor[client][slot][0],
                g_iSpectatorWeaponRenderColor[client][slot][1],
                g_iSpectatorWeaponRenderColor[client][slot][2],
                g_iSpectatorWeaponRenderColor[client][slot][3]);
            SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);
            SetEntityRenderColor(weapon, 255, 255, 255, 0);
        }
    }

    g_bSpectatorActive[client] = true;
    UpdateRSPTemporaryVoiceMute(client);
    SetEntityRenderMode(client, RENDER_TRANSCOLOR);
    SetEntityRenderColor(client, 255, 255, 255, 0);
    SetEntityMoveType(client, MOVETYPE_NOCLIP);

    g_hSpectatorTimer[client] = CreateTimer(RSP_SPECTATOR_DURATION,
        Timer_SpectatorModeExpired, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    if (g_hSpectatorTimer[client] == null)
    {
        StopSpectatorMode(client, true);
        return;
    }
    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Spectator aktywny przez 5 s. Użyj binda ponownie, aby zakończyć wcześniej."
        : "\x04[RSP]\x01 Spectator is active for 5 s. Use your bind again to end it early.");
}

public Action Command_BlockSpectatorInput(int client, const char[] command, int argc)
{
    return (client >= 1 && client <= MaxClients && IsClientInGame(client) &&
        g_bSpectatorActive[client]) ? Plugin_Handled : Plugin_Continue;
}

void ActivateNoclip(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_NoClip || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    // One activation starts the fixed 5-second window. A second use turns NoClip
    // off and closes that window, starting cooldown; it cannot be re-enabled
    // again until the cooldown has expired.
    if (g_bNoclipActive[client])
    {
        StopNoclip(client, true, true, true);
        return;
    }

    // The window is normally closed after manual shutdown or expiry. This guard
    // prevents reactivation inside the same window if a future code path leaves it open.
    if (g_bNoclipWindowOpen[client] && GetGameTime() < g_fNoclipExpiresAt[client])
    {
        return;
    }

    bool newWindow = !g_bNoclipWindowOpen[client] ||
        GetGameTime() >= g_fNoclipExpiresAt[client];

    g_iNoclipOldMoveType[client] = view_as<int>(GetEntityMoveType(client));
    if (newWindow)
    {
        g_bNoclipLastSafeValid[client] = false;
        float origin[3];
        GetClientAbsOrigin(client, origin);
        bool outsideWorld = IsNoclipPointOutsideWorld(origin);
        bool hullClear = IsSwapHullPositionClear(client, origin, client, 0);
        bool groundSupport = HasNoclipGroundSupport(origin, client);
        float minSpawnZ, maxSpawnZ;
        bool hasSpawnEnvelope = GetNoclipSpawnVerticalBounds(minSpawnZ, maxSpawnZ);
        bool highSupportedSurface = hasSpawnEnvelope &&
            origin[2] > maxSpawnZ + RSP_NOCLIP_HIGH_RESCUE_MARGIN && groundSupport;
        bool highPlayerClipSurface = IsNoclipElevatedPlayerClipSurface(origin, client);
        bool elevatedNoDrawSurface = IsNoclipElevatedNoDrawSurface(origin, client);
        bool elevatedSkySurface = IsNoclipElevatedSkySurface(origin, client);
        bool skyboxArea = IsNoclipIn3DSkyboxArea(origin);
        if (!outsideWorld && hullClear && groundSupport &&
            !highSupportedSurface && !highPlayerClipSurface && !elevatedNoDrawSurface &&
            !elevatedSkySurface && !skyboxArea)
        {
            g_bNoclipLastSafeValid[client] = true;
            for (int axis = 0; axis < 3; axis++)
            {
                g_fNoclipLastSafeOrigin[client][axis] = origin[axis];
            }
        }

        g_bNoclipWindowOpen[client] = true;
        g_fNoclipExpiresAt[client] = GetGameTime() + RSP_NOCLIP_DURATION;
        if (g_hNoclipTimer[client] != null)
        {
            delete g_hNoclipTimer[client];
        }
        g_hNoclipTimer[client] = CreateTimer(RSP_NOCLIP_DURATION, Timer_NoclipExpired,
            GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    }

    g_bNoclipActive[client] = true;
    g_fNoclipNextSafeCheckTime[client] = 0.0;
    SetEntityMoveType(client, MOVETYPE_NOCLIP);
    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Noclip aktywny."
        : "\x04[RSP]\x01 NoClip active.");
}

public Action Timer_NoclipExpired(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        g_hNoclipTimer[client] != timer || !g_bNoclipWindowOpen[client])
    {
        return Plugin_Stop;
    }

    bool wasActive = g_bNoclipActive[client];
    g_hNoclipTimer[client] = null;
    StopNoclip(client, true, wasActive, true);
    return Plugin_Stop;
}

void StopNoclip(int client, bool applyCooldown, bool repositionSafely, bool closeWindow = true)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    // MOVETYPE_NOCLIP has a real movement velocity. Save it before changing move type;
    // applying zero here would make the player drop vertically instead of carrying momentum.
    float exitVelocity[3] = {0.0, 0.0, 0.0};
    bool hasExitVelocity = false;
    if (IsClientInGame(client) && IsPlayerAlive(client))
    {
        if (HasEntProp(client, Prop_Data, "m_vecVelocity"))
        {
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", exitVelocity);
            hasExitVelocity = true;
        }
        else if (HasEntProp(client, Prop_Send, "m_vecVelocity"))
        {
            GetEntPropVector(client, Prop_Send, "m_vecVelocity", exitVelocity);
            hasExitVelocity = true;
        }
    }

    bool wasActive = g_bNoclipActive[client];
    if (closeWindow)
    {
        if (g_hNoclipTimer[client] != null)
        {
            delete g_hNoclipTimer[client];
            g_hNoclipTimer[client] = null;
        }
        g_bNoclipWindowOpen[client] = false;
        g_fNoclipExpiresAt[client] = 0.0;
    }
    g_bNoclipActive[client] = false;
    g_fNoclipNextSafeCheckTime[client] = 0.0;

    if (wasActive && IsClientInGame(client) && IsValidEntity(client))
    {
        MoveType restoreMoveType = view_as<MoveType>(g_iNoclipOldMoveType[client]);
        if (restoreMoveType == MOVETYPE_NOCLIP || restoreMoveType == MOVETYPE_NONE)
        {
            restoreMoveType = MOVETYPE_WALK;
        }
        SetEntityMoveType(client, restoreMoveType);

        if (IsPlayerAlive(client))
        {
            bool preserveMomentum = !repositionSafely;
            bool recoveryAttempted = false;
            bool recoverySucceeded = false;

            if (repositionSafely)
            {
                recoveryAttempted = true;
                float currentOrigin[3];
                GetClientAbsOrigin(client, currentOrigin);
                bool outsideWorld = IsNoclipPointOutsideWorld(currentOrigin);
                float minSpawnZ, maxSpawnZ;
                bool hasSpawnEnvelope = GetNoclipSpawnVerticalBounds(minSpawnZ, maxSpawnZ);
                bool belowPlayableEnvelope = hasSpawnEnvelope && currentOrigin[2] < minSpawnZ - 1000.0;
                bool abovePlayableEnvelope = hasSpawnEnvelope &&
                    currentOrigin[2] > maxSpawnZ + RSP_NOCLIP_HIGH_RESCUE_MARGIN;
                bool elevatedPlayerClipSurface = IsNoclipElevatedPlayerClipSurface(currentOrigin, client);
                bool elevatedNoDrawSurface = IsNoclipElevatedNoDrawSurface(currentOrigin, client);
                bool elevatedSkySurface = IsNoclipElevatedSkySurface(currentOrigin, client);
                bool skyboxArea = IsNoclipIn3DSkyboxArea(currentOrigin);

                // Keep natural falling in ordinary open air. Elevated playerclip, NODRAW,
                // and non-2D SKY surfaces are not valid rescue ground, even when the BSP
                // point is in-world. The sky_camera check catches solid geometry in the 3D skybox.
                bool aboveClipSurface = elevatedPlayerClipSurface || elevatedNoDrawSurface ||
                    elevatedSkySurface || (abovePlayableEnvelope && HasNoclipGroundSupport(currentOrigin, client));
                bool outsidePlayableEnvelope = belowPlayableEnvelope || aboveClipSurface || skyboxArea;
                bool currentSafe = !outsideWorld && !outsidePlayableEnvelope &&
                    IsSwapHullPositionClear(client, currentOrigin, client, 0);

                if (currentSafe)
                {
                    preserveMomentum = true;
                }
                else
                {
                    preserveMomentum = false;
                    float safeOrigin[3];
                    bool foundSafe = false;

                    // Do not run a nearby search from an elevated/skybox position: it may
                    // select the same invalid platform as the destination.
                    if (!outsideWorld && !belowPlayableEnvelope && !abovePlayableEnvelope &&
                        !elevatedPlayerClipSurface && !elevatedNoDrawSurface &&
                        !elevatedSkySurface && !skyboxArea)
                    {
                        float noAvoidOrigin[3] = {0.0, 0.0, 0.0};
                        foundSafe = FindSafeSwapPosition(client, currentOrigin, client,
                            client, 0, 0, noAvoidOrigin, safeOrigin);
                        if (foundSafe && !HasNoclipGroundSupport(safeOrigin, client))
                        {
                            foundSafe = false;
                        }
                    }

                    if (!foundSafe && g_bNoclipLastSafeValid[client] &&
                        !IsNoclipPointOutsideWorld(g_fNoclipLastSafeOrigin[client]) &&
                        !IsNoclipIn3DSkyboxArea(g_fNoclipLastSafeOrigin[client]) &&
                        !IsNoclipElevatedPlayerClipSurface(g_fNoclipLastSafeOrigin[client], client) &&
                        !IsNoclipElevatedNoDrawSurface(g_fNoclipLastSafeOrigin[client], client) &&
                        !IsNoclipElevatedSkySurface(g_fNoclipLastSafeOrigin[client], client) &&
                        IsSwapHullPositionClear(client, g_fNoclipLastSafeOrigin[client], client, 0) &&
                        HasNoclipGroundSupport(g_fNoclipLastSafeOrigin[client], client))
                    {
                        for (int axis = 0; axis < 3; axis++)
                        {
                            safeOrigin[axis] = g_fNoclipLastSafeOrigin[client][axis];
                        }
                        foundSafe = true;
                    }
                    if (!foundSafe)
                    {
                        foundSafe = FindSafeTeamSpawnPosition(client, safeOrigin);
                    }
                    if (foundSafe)
                    {
                        float angles[3];
                        float zeroVelocity[3] = {0.0, 0.0, 0.0};
                        GetClientEyeAngles(client, angles);
                        TeleportEntity(client, safeOrigin, angles, zeroVelocity);
                        recoverySucceeded = true;
                    }
                }
            }

            if (preserveMomentum && hasExitVelocity)
            {
                // TeleportEntity with NULL_VECTOR for origin/angles applies the saved
                // velocity only. No position change occurs for a normal flight exit.
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, exitVelocity);
            }
            else if (recoveryAttempted && !recoverySucceeded)
            {
                // If no valid recovery point exists, avoid carrying skybox/out-of-world
                // speed into normal movement; the usual spawn fallback should succeed.
                float zeroVelocity[3] = {0.0, 0.0, 0.0};
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, zeroVelocity);
            }
        }
    }

    if (closeWindow)
    {
        g_bNoclipLastSafeValid[client] = false;
    }
    if (closeWindow && applyCooldown && IsClientInGame(client) && g_bEnabled && g_bSupportedMap &&
        IsRSPPowerRuntimeActiveForClient(client) && IsPlayerAlive(client) &&
        g_iPower[client] == RSP_NoClip && g_iAssignedRound[client] == g_iRoundSerial)
    {
        StartSkillCooldown(client, RSP_NOCLIP_COOLDOWN);
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Noclip zakończony. Odnowienie: 20 sekund."
            : "\x04[RSP]\x01 NoClip ended. Cooldown: 20 seconds.");
    }
}

bool IsNoclipPointOutsideWorld(const float origin[3])
{
    float worldCheckPoint[3];
    for (int axis = 0; axis < 3; axis++)
    {
        worldCheckPoint[axis] = origin[axis];
    }
    return TR_PointOutsideWorld(worldCheckPoint);
}

bool IsNoclipElevatedPlayerClipSurface(const float origin[3], int client)
{
    float minSpawnZ, maxSpawnZ;
    if (!GetNoclipSpawnVerticalBounds(minSpawnZ, maxSpawnZ) ||
        origin[2] <= maxSpawnZ + RSP_NOCLIP_PLAYERCLIP_RESCUE_MARGIN)
    {
        return false;
    }

    float start[3], end[3];
    for (int axis = 0; axis < 3; axis++)
    {
        start[axis] = origin[axis];
        end[axis] = origin[axis];
    }
    start[2] += 2.0;
    end[2] -= RSP_NOCLIP_PLAYERCLIP_TRACE_DEPTH;

    // CONTENTS_PLAYERCLIP isolates invisible player-blocking brushes instead of
    // treating every ordinary platform as a ceiling. The longer trace is intended to
    // detect an elevated model roof above the map's playerclip plane. This is a
    // map-dependent heuristic rather than a universal way to identify every exploit.
    int filterData = (client << 16);
    TR_TraceRayFilter(start, end, CONTENTS_PLAYERCLIP, RayType_EndPoint,
        TraceFilter_SwapParticipants, filterData);
    return TR_DidHit() && !TR_StartSolid();
}

// Treat an elevated NODRAW top face like an elevated playerclip surface during
// NoClip exit recovery. A short solid-world trace detects the surface immediately
// under the player and checks its BSP surface flags; it does not scan distant roofs
// far below the player's current position.
bool IsNoclipElevatedNoDrawSurface(const float origin[3], int client)
{
    float minSpawnZ, maxSpawnZ;
    if (!GetNoclipSpawnVerticalBounds(minSpawnZ, maxSpawnZ) ||
        origin[2] <= maxSpawnZ + RSP_NOCLIP_PLAYERCLIP_RESCUE_MARGIN)
    {
        return false;
    }

    float start[3], end[3];
    for (int axis = 0; axis < 3; axis++)
    {
        start[axis] = origin[axis];
        end[axis] = origin[axis];
    }
    start[2] += 2.0;
    end[2] -= RSP_NOCLIP_NODRAW_TRACE_DEPTH;

    int filterData = (client << 16);
    TR_TraceRayFilter(start, end, MASK_SOLID, RayType_EndPoint,
        TraceFilter_SwapParticipants, filterData);
    if (!TR_DidHit() || TR_StartSolid())
    {
        return false;
    }

    return (TR_GetSurfaceFlags(INVALID_HANDLE) & SURF_NODRAW) != 0;
}

// Treat elevated surfaces using the 3D SKY surface flag as unsafe NoClip rescue ground.
// SURF_SKY2D is deliberately not used: it marks the separate 2D-sky rendering behavior.
bool IsNoclipElevatedSkySurface(const float origin[3], int client)
{
    float minSpawnZ, maxSpawnZ;
    if (!GetNoclipSpawnVerticalBounds(minSpawnZ, maxSpawnZ) ||
        origin[2] <= maxSpawnZ + RSP_NOCLIP_PLAYERCLIP_RESCUE_MARGIN)
    {
        return false;
    }

    float start[3], end[3];
    for (int axis = 0; axis < 3; axis++)
    {
        start[axis] = origin[axis];
        end[axis] = origin[axis];
    }
    start[2] += 2.0;
    end[2] -= RSP_NOCLIP_SKY_TRACE_DEPTH;

    int filterData = (client << 16);
    TR_TraceRayFilter(start, end, MASK_SOLID, RayType_EndPoint,
        TraceFilter_SwapParticipants, filterData);
    if (!TR_DidHit() || TR_StartSolid())
    {
        return false;
    }

    int surfaceFlags = TR_GetSurfaceFlags(INVALID_HANDLE);
    return (surfaceFlags & SURF_SKY) != 0 && (surfaceFlags & SURF_SKY2D) == 0;
}

bool GetNoclipEntityOrigin(int entity, float origin[3])
{
    if (entity <= MaxClients || !IsValidEntity(entity))
    {
        return false;
    }
    if (HasEntProp(entity, Prop_Send, "m_vecOrigin"))
    {
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
        return true;
    }
    if (HasEntProp(entity, Prop_Data, "m_vecOrigin"))
    {
        GetEntPropVector(entity, Prop_Data, "m_vecOrigin", origin);
        return true;
    }
    if (HasEntProp(entity, Prop_Data, "m_vecAbsOrigin"))
    {
        GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", origin);
        return true;
    }
    return false;
}

float GetNoclipNearestSpawnDistanceSquared(const float position[3])
{
    static const char spawnClasses[][] =
    {
        "info_player_terrorist",
        "info_player_counterterrorist"
    };

    float nearestDistanceSquared = 999999999.0;
    bool foundSpawn = false;
    for (int classIndex = 0; classIndex < sizeof(spawnClasses); classIndex++)
    {
        int entity = -1;
        while ((entity = FindEntityByClassname(entity, spawnClasses[classIndex])) != -1)
        {
            float spawnOrigin[3];
            if (!GetNoclipEntityOrigin(entity, spawnOrigin))
            {
                continue;
            }
            float distanceSquared = GetVectorDistance(position, spawnOrigin, true);
            if (!foundSpawn || distanceSquared < nearestDistanceSquared)
            {
                nearestDistanceSquared = distanceSquared;
                foundSpawn = true;
            }
        }
    }
    return foundSpawn ? nearestDistanceSquared : -1.0;
}

bool IsNoclipIn3DSkyboxArea(const float origin[3])
{
    // SourceMod has no direct SDKTools native that answers whether a client is in
    // the map's 3D skybox. When a map exposes sky_camera, proximity to a camera
    // that is clearly separated from player spawns is a useful additional signal.
    float radiusSquared = RSP_NOCLIP_SKYCAMERA_RESCUE_RADIUS * RSP_NOCLIP_SKYCAMERA_RESCUE_RADIUS;
    float minSpawnDistanceSquared = RSP_NOCLIP_SKYCAMERA_MIN_SPAWN_DISTANCE * RSP_NOCLIP_SKYCAMERA_MIN_SPAWN_DISTANCE;

    int skyCamera = -1;
    while ((skyCamera = FindEntityByClassname(skyCamera, "sky_camera")) != -1)
    {
        float cameraOrigin[3];
        if (!GetNoclipEntityOrigin(skyCamera, cameraOrigin))
        {
            continue;
        }

        float nearestSpawnDistanceSquared = GetNoclipNearestSpawnDistanceSquared(cameraOrigin);
        if (nearestSpawnDistanceSquared >= 0.0 && nearestSpawnDistanceSquared < minSpawnDistanceSquared)
        {
            // Avoid treating a sky_camera placed inside/next to the playable spawn area as skybox.
            continue;
        }

        if (GetVectorDistance(origin, cameraOrigin, true) <= radiusSquared)
        {
            return true;
        }
    }
    return false;
}

bool GetNoclipSpawnVerticalBounds(float &minSpawnZ, float &maxSpawnZ)
{
    // Player spawns define a conservative playable vertical envelope. This is only
    // consulted when NoClip ends; it never interrupts active flight.
    minSpawnZ = 0.0;
    maxSpawnZ = 0.0;
    bool haveSpawn = false;
    static const char spawnClasses[][] =
    {
        "info_player_terrorist",
        "info_player_counterterrorist"
    };

    for (int classIndex = 0; classIndex < sizeof(spawnClasses); classIndex++)
    {
        int entity = -1;
        while ((entity = FindEntityByClassname(entity, spawnClasses[classIndex])) != -1)
        {
            if (!IsValidEntity(entity))
            {
                continue;
            }
            float spawnOrigin[3];
            if (!GetNoclipEntityOrigin(entity, spawnOrigin))
            {
                continue;
            }
            if (!haveSpawn)
            {
                minSpawnZ = spawnOrigin[2];
                maxSpawnZ = spawnOrigin[2];
                haveSpawn = true;
            }
            else
            {
                if (spawnOrigin[2] < minSpawnZ)
                {
                    minSpawnZ = spawnOrigin[2];
                }
                if (spawnOrigin[2] > maxSpawnZ)
                {
                    maxSpawnZ = spawnOrigin[2];
                }
            }
        }
    }
    return haveSpawn;
}

bool HasNoclipGroundSupport(const float origin[3], int client)
{
    // TR_PointOutsideWorld in SourceMod's SDKTools API requires a mutable
    // float[3] array. The supplied origin is const, so copy it before calling.
    float worldCheckPoint[3];
    for (int axis = 0; axis < 3; axis++)
    {
        worldCheckPoint[axis] = origin[axis];
    }
    if (TR_PointOutsideWorld(worldCheckPoint))
    {
        return false;
    }

    float start[3], end[3];
    for (int axis = 0; axis < 3; axis++)
    {
        start[axis] = origin[axis];
        end[axis] = origin[axis];
    }
    start[2] += 2.0;
    end[2] -= 192.0;
    int filterData = (client << 16);
    TR_TraceRayFilter(start, end, MASK_PLAYERSOLID, RayType_EndPoint,
        TraceFilter_SwapParticipants, filterData);
    return TR_DidHit() && !TR_StartSolid();
}

// Trace downward at one point and return a nearby, real supporting surface.
// The larger trace window accommodates small steps and shallow dips; the final
// height check still keeps the Replica close to the owner's current floor level.
bool TraceReplicaFloorAt(int client, float x, float y, float referenceZ, float &floorZ)
{
    float start[3], end[3], hitPosition[3];
    start[0] = x;
    start[1] = y;
    start[2] = referenceZ + RSP_REPLICA_FLOOR_TRACE_UP;
    end[0] = x;
    end[1] = y;
    end[2] = referenceZ - RSP_REPLICA_FLOOR_TRACE_DOWN;

    TR_TraceRayFilter(start, end, MASK_PLAYERSOLID, RayType_EndPoint,
        TraceFilter_ReplicaPlacement, client);
    if (!TR_DidHit() || TR_StartSolid() || TR_AllSolid())
    {
        return false;
    }

    TR_GetEndPosition(hitPosition);
    if (TR_PointOutsideWorld(hitPosition) || FloatAbs(hitPosition[2] - referenceZ) > 48.0)
    {
        return false;
    }

    floorZ = hitPosition[2];
    return true;
}

void ActivateReplica(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Replica || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    char model[PLATFORM_MAX_PATH];
    GetClientModel(client, model, sizeof(model));
    if (model[0] == '\0')
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Nie udało się pobrać modelu Twojej postaci."
            : "\x04[RSP]\x01 Could not read your player model.");
        return;
    }
    if (!IsModelPrecached(model))
    {
        PrecacheModel(model, true);
    }

    float origin[3], angles[3], forwardVector[3], right[3], up[3], destination[3];
    GetClientAbsOrigin(client, origin);
    GetClientEyeAngles(client, angles);
    angles[0] = 0.0;
    angles[2] = 0.0;
    GetAngleVectors(angles, forwardVector, right, up);

    // Ground is sampled beneath a 3x3 grid across the 32-unit footprint so
    // bumps, shallow dips and gentle ramps do not fail just because the center
    // trace and the model bounds disagree by a few units. The clearance hull
    // is lifted 2 units above the floor to avoid false start-solid results.
    float clearanceMins[3] = {-16.0, -16.0, 2.0};
    float clearanceMaxs[3] = {16.0, 16.0, RSP_REPLICA_COLLISION_HEIGHT};
    clearanceMaxs[2] += 2.0;
    bool foundPlacement = false;

    int placementAttempts = RoundToFloor((RSP_REPLICA_FORWARD_DISTANCE - RSP_REPLICA_MIN_FORWARD_DISTANCE)
        / RSP_REPLICA_FORWARD_STEP) + 1;
    for (int attempt = 0; attempt < placementAttempts; attempt++)
    {
        float candidateDistance = RSP_REPLICA_FORWARD_DISTANCE - (float(attempt) * RSP_REPLICA_FORWARD_STEP);
        float candidate[3];
        candidate[0] = origin[0] + forwardVector[0] * candidateDistance;
        candidate[1] = origin[1] + forwardVector[1] * candidateDistance;
        candidate[2] = origin[2];

        float centerGroundZ;
        if (!TraceReplicaFloorAt(client, candidate[0], candidate[1], origin[2], centerGroundZ))
        {
            continue;
        }

        float lowestGroundZ = centerGroundZ;
        float highestGroundZ = centerGroundZ;
        bool hasFullSupport = true;
        for (int sampleX = -1; sampleX <= 1 && hasFullSupport; sampleX++)
        {
            for (int sampleY = -1; sampleY <= 1; sampleY++)
            {
                if (sampleX == 0 && sampleY == 0)
                {
                    continue;
                }

                float sampleGroundZ;
                float sampleWorldX = candidate[0] + (float(sampleX) * RSP_REPLICA_FLOOR_SAMPLE_OFFSET);
                float sampleWorldY = candidate[1] + (float(sampleY) * RSP_REPLICA_FLOOR_SAMPLE_OFFSET);
                if (!TraceReplicaFloorAt(client, sampleWorldX, sampleWorldY, origin[2], sampleGroundZ))
                {
                    hasFullSupport = false;
                    break;
                }

                if (sampleGroundZ < lowestGroundZ)
                {
                    lowestGroundZ = sampleGroundZ;
                }
                if (sampleGroundZ > highestGroundZ)
                {
                    highestGroundZ = sampleGroundZ;
                }
            }
        }

        // A large height spread means the footprint is over a real ledge/drop,
        // not a small bump or ordinary ramp; reject it instead of floating.
        if (!hasFullSupport || (highestGroundZ - lowestGroundZ) > RSP_REPLICA_MAX_GROUND_VARIATION)
        {
            continue;
        }

        destination[0] = candidate[0];
        destination[1] = candidate[1];
        destination[2] = highestGroundZ + RSP_REPLICA_GROUND_CLEARANCE;
        if (TR_PointOutsideWorld(destination))
        {
            continue;
        }

        // Check walls, props and players with the full player-sized hull. The
        // 2-unit probe lift avoids false failures from exact floor contact, while
        // the extra 2 units above the model preserve headroom safety.
        TR_TraceHullFilter(destination, destination, clearanceMins, clearanceMaxs,
            MASK_PLAYERSOLID, TraceFilter_ReplicaPlacement, client);
        if (TR_StartSolid() || TR_AllSolid() || (TR_DidHit() && TR_GetFraction() < 0.999))
        {
            continue;
        }

        foundPlacement = true;
        break;
    }

    if (!foundPlacement)
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Brak miejsca przed Tobą, aby postawić replikę."
            : "\x04[RSP]\x01 There is not enough room in front of you to place the Replica.");
        return;
    }

    int replica = CreateEntityByName("prop_dynamic");
    if (replica <= MaxClients || replica >= RSP_MAX_ENTITIES || !IsValidEntity(replica))
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Nie udało się utworzyć repliki. Spróbuj ponownie."
            : "\x04[RSP]\x01 Could not create the Replica. Try again.");
        return;
    }

    char originValue[96], anglesValue[96];
    Format(originValue, sizeof(originValue), "%.1f %.1f %.1f", destination[0], destination[1], destination[2]);
    Format(anglesValue, sizeof(anglesValue), "0.0 %.1f 0.0", angles[1]);
    DispatchKeyValue(replica, "model", model);
    DispatchKeyValue(replica, "origin", originValue);
    DispatchKeyValue(replica, "angles", anglesValue);
    DispatchKeyValue(replica, "solid", "2");
    DispatchKeyValue(replica, "health", "100");
    DispatchKeyValue(replica, "DefaultAnim", "idle_lower");
    DispatchKeyValue(replica, "spawnflags", "0");
    DispatchKeyValue(replica, "targetname", "rsp_replica");

    if (!DispatchSpawn(replica) || !IsValidEntity(replica))
    {
        if (IsValidEntity(replica)) RemoveEntity(replica);
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Nie udało się utworzyć repliki. Spróbuj ponownie."
            : "\x04[RSP]\x01 Could not create the Replica. Try again.");
        return;
    }

    ActivateEntity(replica);
    // Keep the model's native prop_dynamic collision. Do not override its hull
    // or collision group; prior custom bounds/pushaway experiments caused snagging.
    if (HasEntProp(client, Prop_Send, "m_nSkin") && HasEntProp(replica, Prop_Send, "m_nSkin"))
    {
        SetEntProp(replica, Prop_Send, "m_nSkin", GetEntProp(client, Prop_Send, "m_nSkin"));
    }
    if (HasEntProp(client, Prop_Send, "m_nBody") && HasEntProp(replica, Prop_Send, "m_nBody"))
    {
        SetEntProp(replica, Prop_Send, "m_nBody", GetEntProp(client, Prop_Send, "m_nBody"));
    }

    if (HasEntProp(replica, Prop_Data, "m_takedamage"))
    {
        SetEntProp(replica, Prop_Data, "m_takedamage", 2, 1);
    }
    if (HasEntProp(replica, Prop_Data, "m_iHealth"))
    {
        SetEntProp(replica, Prop_Data, "m_iHealth", RSP_REPLICA_HEALTH);
    }

    // Keep only the known-good CS:S idle_lower animation. No extra weapon model,
    // attachment animation, or custom runtime collision is applied to the Replica.
    SetVariantString("idle_lower");
    AcceptEntityInput(replica, "SetAnimation");

    g_iReplicaOwnerUserId[replica] = GetClientUserId(client);
    g_fReplicaHealth[replica] = float(RSP_REPLICA_HEALTH);
    g_bReplicaPendingRemoval[replica] = false;

    // prop_dynamic may finish initializing/resetting its sequence at the end of
    // DispatchSpawn. Reassert the known-good CS:S pose next frame.
    RequestFrame(Frame_ApplyReplicaIdleAnimation, EntIndexToEntRef(replica));
    if (!SDKHookEx(replica, SDKHook_OnTakeDamage, Hook_ReplicaOnTakeDamage))
    {
        g_iReplicaOwnerUserId[replica] = 0;
        g_fReplicaHealth[replica] = 0.0;
        RemoveReplicaEntity(replica);
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Replika nie obsługuje obrażeń na tym serwerze."
            : "\x04[RSP]\x01 Replicas cannot receive damage on this server build.");
        return;
    }


    StartSkillCooldown(client, RSP_REPLICA_COOLDOWN);
    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Postawiono replikę. Odnowienie: 25 sekund."
        : "\x04[RSP]\x01 Replica placed. Cooldown: 25 seconds.");
}


// -----------------------------------------------------------------------------
// Builder / Inventor buildables. All props are round-scoped and owner-tracked.
// -----------------------------------------------------------------------------
int CountBuildablesForOwner(int ownerUserId, int buildableType)
{
    if (ownerUserId <= 0)
    {
        return 0;
    }

    int count = 0;
    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iBuildableOwnerUserId[entity] == ownerUserId &&
            g_iBuildableType[entity] == buildableType && IsValidEntity(entity))
        {
            count++;
        }
    }
    return count;
}

void ClearBuildableTracking(int entity, bool fromTimer = false)
{
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES)
    {
        return;
    }

    if (g_hBuildableTurretTimer[entity] != null)
    {
        if (!fromTimer)
        {
            delete g_hBuildableTurretTimer[entity];
        }
        g_hBuildableTurretTimer[entity] = null;
    }
    StopBuildableLoopSound(entity);
    StopBuildableAntennaArcEntity(entity);
    g_iBuildableOwnerUserId[entity] = 0;
    g_iBuildableType[entity] = RSP_BUILDABLE_NONE;
    g_fBuildableHealth[entity] = 0.0;
    g_fBuildableYaw[entity] = 0.0;
    g_bBuildableBeamOffsetValid[entity] = false;
    for (int beamAxis = 0; beamAxis < 3; beamAxis++)
    {
        g_fBuildableBeamOffset[entity][beamAxis] = 0.0;
    }
}

void RemoveBuildableEntity(int entity, bool fromTimer = false)
{
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES)
    {
        return;
    }

    ClearBuildableTracking(entity, fromTimer);
    if (IsValidEntity(entity))
    {
        RemoveEntity(entity);
    }
}

void ClearBuildablesForOwner(int ownerUserId)
{
    if (ownerUserId <= 0)
    {
        return;
    }

    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iBuildableOwnerUserId[entity] == ownerUserId)
        {
            RemoveBuildableEntity(entity);
        }
    }
}

void ClearAllBuildables()
{
    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iBuildableOwnerUserId[entity] != 0 || g_hBuildableTurretTimer[entity] != null)
        {
            RemoveBuildableEntity(entity);
        }
    }
}

bool FindBuildablePlacement(int client, int buildableType, float desiredDistance,
    const float hullMins[3], const float hullMaxs[3], float destination[3], float &yaw)
{
    float ignoredGroundSpread;
    return FindBuildablePlacementWithGroundSpread(client, buildableType, desiredDistance,
        hullMins, hullMaxs, destination, yaw, ignoredGroundSpread);
}

bool FindBuildablePlacementWithGroundSpread(int client, int buildableType, float desiredDistance,
    const float hullMins[3], const float hullMaxs[3], float destination[3], float &yaw,
    float &groundSpreadOut)
{
    groundSpreadOut = 0.0;
    float origin[3], eyeAngles[3], forwardVector[3], right[3], up[3];
    GetClientAbsOrigin(client, origin);
    GetClientEyeAngles(client, eyeAngles);
    eyeAngles[0] = 0.0;
    eyeAngles[2] = 0.0;
    yaw = eyeAngles[1];
    GetAngleVectors(eyeAngles, forwardVector, right, up);

    float eyePosition[3];
    GetClientEyePosition(client, eyePosition);

    // Sample buildable-specific ground support over the whole rotated footprint.
    // Try multiple positions from the requested distance back toward the player so
    // uneven ground or a small obstruction does not immediately reject the placement.
    // More placement candidates allow walls/turrets to be tucked closer to corners and cover.
    for (int attempt = 0; attempt < RSP_BUILDABLE_PLACEMENT_ATTEMPTS; attempt++)
    {
        float distance = desiredDistance - (float(attempt) * RSP_BUILDABLE_PLACEMENT_STEP);
        if (distance < 24.0)
        {
            continue;
        }

        float candidate[3];
        candidate[0] = origin[0] + forwardVector[0] * distance;
        candidate[1] = origin[1] + forwardVector[1] * distance;
        candidate[2] = origin[2];

        float centerGroundZ;
        if (!TraceBuildableFloorAt(client, candidate[0], candidate[1], origin[2], centerGroundZ))
        {
            continue;
        }

        float lowestGroundZ = centerGroundZ;
        float highestGroundZ = centerGroundZ;
        int supportedSamples = 1; // The center sample above is mandatory.

        // Sample the actual rotated footprint, not a small world-axis-aligned patch.
        // This is especially important for the long Builder fence and elevated ramps.
        float placementAngles[3];
        placementAngles[0] = 0.0;
        placementAngles[1] = yaw;
        placementAngles[2] = 0.0;
        if (buildableType == RSP_BUILDABLE_FENCE)
        {
            placementAngles[1] = yaw + 90.0;
        }
        float footprintForward[3], footprintRight[3], footprintUp[3];
        GetAngleVectors(placementAngles, footprintForward, footprintRight, footprintUp);
        float halfX = FloatAbs(hullMins[0]);
        if (FloatAbs(hullMaxs[0]) > halfX) halfX = FloatAbs(hullMaxs[0]);
        float halfY = FloatAbs(hullMins[1]);
        if (FloatAbs(hullMaxs[1]) > halfY) halfY = FloatAbs(hullMaxs[1]);
        // TraceHull is world-axis-aligned, so convert the rotated model footprint to its AABB.
        float worldHalfX = FloatAbs(footprintForward[0]) * halfX + FloatAbs(footprintRight[0]) * halfY;
        float worldHalfY = FloatAbs(footprintForward[1]) * halfX + FloatAbs(footprintRight[1]) * halfY;

        // 5x5 points cover corners, edges and the middle of the full footprint.
        // Missing edge samples are allowed when the object intentionally overhangs a ramp lip,
        // but the centre and a useful majority of the footprint must still have real ground.
        for (int sampleX = -2; sampleX <= 2; sampleX++)
        {
            for (int sampleY = -2; sampleY <= 2; sampleY++)
            {
                if (sampleX == 0 && sampleY == 0)
                {
                    continue;
                }

                float localX = halfX * (float(sampleX) * 0.5);
                float localY = halfY * (float(sampleY) * 0.5);
                float sampleWorldX = candidate[0] + footprintForward[0] * localX + footprintRight[0] * localY;
                float sampleWorldY = candidate[1] + footprintForward[1] * localX + footprintRight[1] * localY;
                float sampleGroundZ;
                if (!TraceBuildableFloorAt(client, sampleWorldX, sampleWorldY, origin[2], sampleGroundZ))
                {
                    continue;
                }
                supportedSamples++;

                if (sampleGroundZ < lowestGroundZ)
                {
                    lowestGroundZ = sampleGroundZ;
                }
                if (sampleGroundZ > highestGroundZ)
                {
                    highestGroundZ = sampleGroundZ;
                }
            }
        }

        float groundSpread = highestGroundZ - lowestGroundZ;
        if (supportedSamples < RSP_BUILDABLE_MIN_GROUND_SAMPLES ||
            groundSpread > RSP_BUILDABLE_MAX_GROUND_VARIATION)
        {
            continue;
        }

        destination[0] = candidate[0];
        destination[1] = candidate[1];
        // Anchor the prop at the lowest measured support point to prevent it floating
        // above the downhill side of a ramp. The higher-side clearance is checked below.
        destination[2] = lowestGroundZ + RSP_REPLICA_GROUND_CLEARANCE;
        if (TR_PointOutsideWorld(destination))
        {
            continue;
        }

        // Aim the clearance ray at the buildable's middle, not just 40 units above
        // the floor; this avoids sloped ground prematurely blocking an otherwise clear placement.
        float sightEnd[3];
        sightEnd[0] = destination[0];
        sightEnd[1] = destination[1];
        sightEnd[2] = destination[2] + (highestGroundZ - lowestGroundZ) +
            (hullMaxs[2] * RSP_BUILDABLE_CLEARANCE_HEIGHT_SCALE * 0.5);
        TR_TraceRayFilter(eyePosition, sightEnd, MASK_SOLID, RayType_EndPoint,
            TraceFilter_ReplicaPlacement, client);
        if (TR_StartSolid() || TR_AllSolid() || (TR_DidHit() && TR_GetFraction() < 0.97))
        {
            continue;
        }

        // Check the complete vertical envelope from just above the highest sampled ground.
        // Testing at the lowest anchor directly makes every valid ramp look like a solid
        // obstruction because its uphill side intersects the horizontal prop hull.
        float clearanceMins[3], clearanceMaxs[3], clearanceOrigin[3];
        // Keep the old tolerant clearance for Builder fences. Tesla uses the full rotated
        // footprint plus a small margin and MASK_SOLID, so a wall or solid prop touching
        // the model's outer edge is treated as an obstruction instead of being overlapped.
        int clearanceMask = MASK_PLAYERSOLID;
        float clearanceHalfX = worldHalfX * RSP_BUILDABLE_CLEARANCE_XY_SCALE;
        float clearanceHalfY = worldHalfY * RSP_BUILDABLE_CLEARANCE_XY_SCALE;
        clearanceMins[2] = hullMins[2];
        clearanceMaxs[2] = hullMaxs[2] * RSP_BUILDABLE_CLEARANCE_HEIGHT_SCALE;
        clearanceOrigin[0] = destination[0];
        clearanceOrigin[1] = destination[1];
        clearanceOrigin[2] = destination[2] + groundSpread;
        if (buildableType == RSP_BUILDABLE_TURRET)
        {
            // The visual transformer is wider than its legacy placement hull. Enforce a
            // conservative minimum footprint and include debris contents commonly used by props.
            if (clearanceHalfX < RSP_INVENTOR_TURRET_CLEARANCE_XY_MIN)
                clearanceHalfX = RSP_INVENTOR_TURRET_CLEARANCE_XY_MIN;
            if (clearanceHalfY < RSP_INVENTOR_TURRET_CLEARANCE_XY_MIN)
                clearanceHalfY = RSP_INVENTOR_TURRET_CLEARANCE_XY_MIN;
            clearanceHalfX = clearanceHalfX * RSP_INVENTOR_TURRET_CLEARANCE_XY_SCALE + RSP_INVENTOR_TURRET_CLEARANCE_PADDING;
            clearanceHalfY = clearanceHalfY * RSP_INVENTOR_TURRET_CLEARANCE_XY_SCALE + RSP_INVENTOR_TURRET_CLEARANCE_PADDING;
            clearanceMask = MASK_SOLID | CONTENTS_DEBRIS | CONTENTS_HITBOX;
            // Keep the clearance hull above the highest sampled support point. The lower
            // ground-contact band is validated separately by the post-spawn prop AABB check;
            // tracing from the lowest anchor made even slight slopes look like obstructions.
            clearanceOrigin[2] = destination[2] + groundSpread;
        }
        clearanceMins[0] = -clearanceHalfX;
        clearanceMins[1] = -clearanceHalfY;
        clearanceMaxs[0] = clearanceHalfX;
        clearanceMaxs[1] = clearanceHalfY;
        TR_TraceHullFilter(clearanceOrigin, clearanceOrigin, clearanceMins, clearanceMaxs,
            clearanceMask, TraceFilter_ReplicaPlacement, client);
        if (TR_StartSolid() || TR_AllSolid() || (TR_DidHit() && TR_GetFraction() < 0.999))
        {
            continue;
        }
        groundSpreadOut = groundSpread;
        return true;
    }
    return false;
}

bool GetBuildableLocalBounds(int entity, float mins[3], float maxs[3])
{
    if (entity <= MaxClients || !IsValidEntity(entity) ||
        !HasEntProp(entity, Prop_Data, "m_vecMins") ||
        !HasEntProp(entity, Prop_Data, "m_vecMaxs"))
    {
        return false;
    }

    GetEntPropVector(entity, Prop_Data, "m_vecMins", mins);
    GetEntPropVector(entity, Prop_Data, "m_vecMaxs", maxs);

    float height = maxs[2] - mins[2];
    // Reject uninitialized or obviously invalid bounds and use a conservative model-specific fallback.
    return height >= 8.0 && height <= 256.0 && mins[2] >= -256.0 && maxs[2] <= 512.0;
}

// Buildables can be placed on ramps and taller nearby rises than Replica.
// This uses a wider vertical trace but still requires a real supporting surface close
// enough to the player's level to avoid selecting an unrelated floor far above/below.
bool TraceBuildableFloorAt(int client, float x, float y, float referenceZ, float &floorZ)
{
    float start[3], end[3], hitPosition[3];
    start[0] = x;
    start[1] = y;
    start[2] = referenceZ + RSP_BUILDABLE_FLOOR_TRACE_UP;
    end[0] = x;
    end[1] = y;
    end[2] = referenceZ - RSP_BUILDABLE_FLOOR_TRACE_DOWN;

    TR_TraceRayFilter(start, end, MASK_PLAYERSOLID, RayType_EndPoint,
        TraceFilter_ReplicaPlacement, client);
    if (!TR_DidHit() || TR_StartSolid() || TR_AllSolid())
    {
        return false;
    }

    TR_GetEndPosition(hitPosition);
    if (TR_PointOutsideWorld(hitPosition) ||
        FloatAbs(hitPosition[2] - referenceZ) > RSP_BUILDABLE_MAX_REFERENCE_DELTA)
    {
        return false;
    }

    floorZ = hitPosition[2];
    return true;
}

// Trace only the Tesla entity, ignoring world props/players as candidate hits.
public bool TraceFilter_TeslaSurfaceOnly(int entity, int contentsMask, any data)
{
    return entity == data;
}

// Find the model's true lateral antenna position from its own VPhysics collision hull.
// We cast vertical rays only through the upper band of the model and keep the highest
// collision point. A second, denser pass refines the best candidate. The beam's Z is
// still calculated by the unchanged model-max-Z/inset rule in Timer_BuildableTurretFire.
bool FindTeslaAntennaSurfaceOffset(int turret, float offset[3])
{
    if (turret <= MaxClients || turret >= RSP_MAX_ENTITIES || !IsValidEntity(turret))
    {
        return false;
    }

    float origin[3], mins[3], maxs[3];
    GetEntPropVector(turret, Prop_Send, "m_vecOrigin", origin);
    if (!GetBuildableLocalBounds(turret, mins, maxs))
    {
        return false;
    }

    float spanX = maxs[0] - mins[0];
    float spanY = maxs[1] - mins[1];
    if (spanX < 4.0 || spanY < 4.0)
    {
        return false;
    }

    float turretAngles[3];
    turretAngles[0] = 0.0;
    turretAngles[1] = g_fBuildableYaw[turret];
    turretAngles[2] = 0.0;
    float forwardVector[3], rightVector[3], upVector[3];
    GetAngleVectors(turretAngles, forwardVector, rightVector, upVector);

    float rayStartZ = origin[2] + maxs[2] + 8.0;
    float rayEndZ = origin[2] + maxs[2] - RSP_INVENTOR_TURRET_BEAM_SURFACE_SCAN_DEPTH;
    float bestZ = -1.0e30;
    float bestLocalX = 0.0, bestLocalY = 0.0;
    bool found = false;
    int grid = RSP_INVENTOR_TURRET_BEAM_SURFACE_GRID;

    // Pass 1: find the highest point of the model's own collision surface.
    for (int xIndex = 0; xIndex <= grid; xIndex++)
    {
        float localX = mins[0] + spanX * float(xIndex) / float(grid);
        for (int yIndex = 0; yIndex <= grid; yIndex++)
        {
            float localY = mins[1] + spanY * float(yIndex) / float(grid);
            float traceStart[3], traceEnd[3], hitPosition[3];
            traceStart[0] = origin[0] + forwardVector[0] * localX + rightVector[0] * localY;
            traceStart[1] = origin[1] + forwardVector[1] * localX + rightVector[1] * localY;
            traceStart[2] = rayStartZ;
            traceEnd[0] = traceStart[0];
            traceEnd[1] = traceStart[1];
            traceEnd[2] = rayEndZ;

            TR_TraceRayFilter(traceStart, traceEnd, MASK_SOLID, RayType_EndPoint,
                TraceFilter_TeslaSurfaceOnly, turret);
            if (!TR_DidHit() || TR_StartSolid() || TR_AllSolid() || TR_GetEntityIndex() != turret)
            {
                continue;
            }
            TR_GetEndPosition(hitPosition);
            if (hitPosition[2] > bestZ)
            {
                bestZ = hitPosition[2];
                bestLocalX = localX;
                bestLocalY = localY;
                found = true;
            }
        }
    }

    if (!found)
    {
        return false;
    }

    // Pass 2: average all samples on the highest, nearly level surface. This centers
    // the point on the antenna cap instead of picking one outer grid sample at its edge.
    const float TOP_SURFACE_TOLERANCE = 1.25;
    float sumLocalX = 0.0, sumLocalY = 0.0, sumSurfaceZ = 0.0;
    int topSampleCount = 0;
    for (int xIndex = 0; xIndex <= grid; xIndex++)
    {
        float localX = mins[0] + spanX * float(xIndex) / float(grid);
        for (int yIndex = 0; yIndex <= grid; yIndex++)
        {
            float localY = mins[1] + spanY * float(yIndex) / float(grid);
            float traceStart[3], traceEnd[3], hitPosition[3];
            traceStart[0] = origin[0] + forwardVector[0] * localX + rightVector[0] * localY;
            traceStart[1] = origin[1] + forwardVector[1] * localX + rightVector[1] * localY;
            traceStart[2] = rayStartZ;
            traceEnd[0] = traceStart[0];
            traceEnd[1] = traceStart[1];
            traceEnd[2] = rayEndZ;

            TR_TraceRayFilter(traceStart, traceEnd, MASK_SOLID, RayType_EndPoint,
                TraceFilter_TeslaSurfaceOnly, turret);
            if (!TR_DidHit() || TR_StartSolid() || TR_AllSolid() || TR_GetEntityIndex() != turret)
            {
                continue;
            }
            TR_GetEndPosition(hitPosition);
            if (hitPosition[2] < bestZ - TOP_SURFACE_TOLERANCE)
            {
                continue;
            }
            sumLocalX += localX;
            sumLocalY += localY;
            sumSurfaceZ += hitPosition[2];
            topSampleCount++;
        }
    }

    float centerLocalX = bestLocalX;
    float centerLocalY = bestLocalY;
    float centerSurfaceZ = bestZ;
    if (topSampleCount > 0)
    {
        centerLocalX = sumLocalX / float(topSampleCount);
        centerLocalY = sumLocalY / float(topSampleCount);
        centerSurfaceZ = sumSurfaceZ / float(topSampleCount);
    }

    // Pass 3: refine the averaged center with a denser grid, still sampling only the
    // highest surface band. This keeps the beam centered even when the antenna top is small.
    float refineStepX = spanX / float(grid) / 4.0;
    float refineStepY = spanY / float(grid) / 4.0;
    sumLocalX = 0.0;
    sumLocalY = 0.0;
    float sumRefinedSurfaceZ = 0.0;
    int refinedSampleCount = 0;
    for (int xRefine = -4; xRefine <= 4; xRefine++)
    {
        float localX = centerLocalX + float(xRefine) * refineStepX;
        if (localX < mins[0] || localX > maxs[0]) continue;
        for (int yRefine = -4; yRefine <= 4; yRefine++)
        {
            float localY = centerLocalY + float(yRefine) * refineStepY;
            if (localY < mins[1] || localY > maxs[1]) continue;

            float traceStart[3], traceEnd[3], hitPosition[3];
            traceStart[0] = origin[0] + forwardVector[0] * localX + rightVector[0] * localY;
            traceStart[1] = origin[1] + forwardVector[1] * localX + rightVector[1] * localY;
            traceStart[2] = rayStartZ;
            traceEnd[0] = traceStart[0];
            traceEnd[1] = traceStart[1];
            traceEnd[2] = rayEndZ;

            TR_TraceRayFilter(traceStart, traceEnd, MASK_SOLID, RayType_EndPoint,
                TraceFilter_TeslaSurfaceOnly, turret);
            if (!TR_DidHit() || TR_StartSolid() || TR_AllSolid() || TR_GetEntityIndex() != turret)
            {
                continue;
            }
            TR_GetEndPosition(hitPosition);
            if (hitPosition[2] < bestZ - TOP_SURFACE_TOLERANCE)
            {
                continue;
            }
            sumLocalX += localX;
            sumLocalY += localY;
            sumRefinedSurfaceZ += hitPosition[2];
            refinedSampleCount++;
        }
    }
    if (refinedSampleCount > 0)
    {
        centerLocalX = sumLocalX / float(refinedSampleCount);
        centerLocalY = sumLocalY / float(refinedSampleCount);
        centerSurfaceZ = sumRefinedSurfaceZ / float(refinedSampleCount);
    }

    // Store the final center of the highest collision surface in world-relative X/Y.
    offset[0] = forwardVector[0] * centerLocalX + rightVector[0] * centerLocalY;
    offset[1] = forwardVector[1] * centerLocalX + rightVector[1] * centerLocalY;
    offset[2] = centerSurfaceZ - origin[2];
    return true;
}

bool GetTeslaBeamStartPosition(int turret, float beamStart[3])
{
    if (turret <= MaxClients || turret >= RSP_MAX_ENTITIES || !IsValidEntity(turret))
    {
        return false;
    }

    float turretOrigin[3], turretMins[3], turretMaxs[3];
    GetEntPropVector(turret, Prop_Send, "m_vecOrigin", turretOrigin);
    bool hasBounds = GetBuildableLocalBounds(turret, turretMins, turretMaxs);
    if (g_bBuildableBeamOffsetValid[turret])
    {
        beamStart[0] = turretOrigin[0] + g_fBuildableBeamOffset[turret][0];
        beamStart[1] = turretOrigin[1] + g_fBuildableBeamOffset[turret][1];
    }
    else
    {
        float turretAngles[3];
        turretAngles[0] = 0.0;
        turretAngles[1] = g_fBuildableYaw[turret];
        turretAngles[2] = 0.0;
        float forwardVector[3], rightVector[3], upVector[3];
        GetAngleVectors(turretAngles, forwardVector, rightVector, upVector);
        beamStart[0] = turretOrigin[0] + rightVector[0] * RSP_INVENTOR_TURRET_BEAM_RIGHT_OFFSET
            + forwardVector[0] * RSP_INVENTOR_TURRET_BEAM_FORWARD_OFFSET;
        beamStart[1] = turretOrigin[1] + rightVector[1] * RSP_INVENTOR_TURRET_BEAM_RIGHT_OFFSET
            + forwardVector[1] * RSP_INVENTOR_TURRET_BEAM_FORWARD_OFFSET;
    }

    // Use the sampled antenna top when available, with the same small inset as before.
    // Model bounds can include a broad hull whose upper Z does not describe the narrow cap.
    if (hasBounds && g_bBuildableBeamOffsetValid[turret])
    {
        beamStart[2] = turretOrigin[2] + g_fBuildableBeamOffset[turret][2]
            - RSP_INVENTOR_TURRET_ANTENNA_TOP_INSET;
    }
    else
    {
        beamStart[2] = hasBounds
            ? turretOrigin[2] + turretMaxs[2] - RSP_INVENTOR_TURRET_ANTENNA_TOP_INSET
            : turretOrigin[2] + RSP_INVENTOR_TURRET_MUZZLE_HEIGHT;
    }
    return true;
}

int CreateTrackedBuildable(int client, int buildableType, const char[] model,
    const float origin[3], const float angles[3], float health)
{
    int entity = CreateEntityByName("prop_dynamic_override");
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES || !IsValidEntity(entity))
    {
        return -1;
    }

    char originValue[96], anglesValue[96], healthValue[16];
    Format(originValue, sizeof(originValue), "%.1f %.1f %.1f", origin[0], origin[1], origin[2]);
    Format(anglesValue, sizeof(anglesValue), "%.1f %.1f %.1f", angles[0], angles[1], angles[2]);
    Format(healthValue, sizeof(healthValue), "%d", RoundToCeil(health));
    DispatchKeyValue(entity, "model", model);
    DispatchKeyValue(entity, "origin", originValue);
    DispatchKeyValue(entity, "angles", anglesValue);
    // Use each model's VPhysics collision hull. In particular, the transformer must not
    // fall back to the oversized axis-aligned box that made it feel like an invisible crate.
    DispatchKeyValue(entity, "solid", "6");
    DispatchKeyValue(entity, "health", healthValue);
    DispatchKeyValue(entity, "spawnflags", "0");

    if (!DispatchSpawn(entity) || !IsValidEntity(entity))
    {
        if (IsValidEntity(entity)) RemoveEntity(entity);
        return -1;
    }
    ActivateEntity(entity);

    // These model origins are not at the visible bottom. Align each model's lower
    // collision bound with the traced floor instead of burying its lower half.
    float localMins[3], localMaxs[3];
    float fallbackLift = (buildableType == RSP_BUILDABLE_FENCE)
        ? RSP_BUILDER_FENCE_FALLBACK_LIFT : RSP_INVENTOR_TURRET_FALLBACK_LIFT;
    float lift = fallbackLift;
    if (GetBuildableLocalBounds(entity, localMins, localMaxs) && localMins[2] < -1.0)
    {
        // Use the actual lower bound, even when it is less than the fallback;
        // this keeps the prop resting on the floor instead of leaving it floating.
        lift = -localMins[2];
    }

    float correctedOrigin[3];
    correctedOrigin[0] = origin[0];
    correctedOrigin[1] = origin[1];
    correctedOrigin[2] = origin[2] + lift;
    // The fence model has an open/cut-out lower section. Sink the aligned prop by 17 units
    // so the ground hides that gap and players' legs cannot be seen through its bottom.
    if (buildableType == RSP_BUILDABLE_FENCE)
    {
        correctedOrigin[2] -= RSP_BUILDER_FENCE_GROUND_SINK;
    }
    else if (buildableType == RSP_BUILDABLE_TURRET)
    {
        correctedOrigin[2] -= RSP_INVENTOR_TURRET_GROUND_SINK;
    }
    TeleportEntity(entity, correctedOrigin, NULL_VECTOR, NULL_VECTOR);

    if (HasEntProp(entity, Prop_Data, "m_takedamage"))
    {
        SetEntProp(entity, Prop_Data, "m_takedamage", 2, 1);
    }
    if (HasEntProp(entity, Prop_Data, "m_iHealth"))
    {
        SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(health));
    }

    g_iBuildableOwnerUserId[entity] = GetClientUserId(client);
    g_iBuildableType[entity] = buildableType;
    g_fBuildableHealth[entity] = health;
    g_fBuildableYaw[entity] = angles[1];
    g_bBuildableBeamOffsetValid[entity] = false;
    for (int beamAxis = 0; beamAxis < 3; beamAxis++)
    {
        g_fBuildableBeamOffset[entity][beamAxis] = 0.0;
    }
    if (buildableType == RSP_BUILDABLE_TURRET)
    {
        g_bBuildableBeamOffsetValid[entity] = FindTeslaAntennaSurfaceOffset(entity,
            g_fBuildableBeamOffset[entity]);
    }

    if (!SDKHookEx(entity, SDKHook_OnTakeDamage, Hook_BuildableOnTakeDamage))
    {
        RemoveBuildableEntity(entity);
        return -1;
    }

    // The electrical hum is a continuous ambient sound for the whole lifetime of the
    // Tesla. Only its decorative point_tesla storm is gated by visible hostile targets.
    if (buildableType == RSP_BUILDABLE_TURRET)
    {
        g_iBuildableLoopSoundRef[entity] = CreateTeslaLoopSound(entity);
    }
    return entity;
}

// Keeps Tesla's ambient lightning arcs alive only while the firing timer has a valid
// visible hostile target. The continuous hum is managed separately. EntRefs are checked
// because the helper entity may be removed externally or invalidated during cleanup.
void EnsureTeslaStormEffects(int turret, const float beamStart[3])
{
    if (turret <= MaxClients || turret >= RSP_MAX_ENTITIES || !IsValidEntity(turret))
    {
        return;
    }

    int arcEntity = EntRefToEntIndex(g_iBuildableAntennaTeslaRef[turret]);
    if (arcEntity <= MaxClients || arcEntity >= RSP_MAX_ENTITIES || !IsValidEntity(arcEntity))
    {
        g_iBuildableAntennaTeslaRef[turret] = INVALID_ENT_REFERENCE;
        g_iBuildableAntennaTeslaRef[turret] = CreateTeslaAntennaArcEntity(turret, beamStart);
    }
}

// Keep the ambient hum alive as long as the Tesla entity exists, even when it has
// no target or RSP temporarily pauses combat. The turret timer retries if the sound
// helper entity was removed or could not be created on the first attempt.
void EnsureTeslaLoopSound(int turret)
{
    if (turret <= MaxClients || turret >= RSP_MAX_ENTITIES || !IsValidEntity(turret) ||
        g_iBuildableType[turret] != RSP_BUILDABLE_TURRET)
    {
        return;
    }

    int loopEntity = EntRefToEntIndex(g_iBuildableLoopSoundRef[turret]);
    if (loopEntity <= MaxClients || loopEntity >= RSP_MAX_ENTITIES || !IsValidEntity(loopEntity))
    {
        g_iBuildableLoopSoundRef[turret] = INVALID_ENT_REFERENCE;
        g_iBuildableLoopSoundRef[turret] = CreateTeslaLoopSound(turret);
    }
}

void StopTeslaStormEffects(int turret)
{
    // Do not stop the loop hum here. This helper only disables target-gated lightning.
    StopBuildableAntennaArcEntity(turret);
}

int CreateTeslaAntennaArcEntity(int turret, const float origin[3])
{
    if (turret <= MaxClients || turret >= RSP_MAX_ENTITIES || !IsValidEntity(turret))
    {
        return INVALID_ENT_REFERENCE;
    }

    int tesla = CreateEntityByName("point_tesla");
    if (tesla <= MaxClients || tesla >= RSP_MAX_ENTITIES || !IsValidEntity(tesla))
    {
        return INVALID_ENT_REFERENCE;
    }

    char originValue[96];
    float arcOrigin[3];
    // Use exactly the same X/Y antenna point as the laser firing origin. Only the
    // configured vertical offset separates the decorative ambient arcs from the cap.
    arcOrigin[0] = origin[0];
    arcOrigin[1] = origin[1];
    arcOrigin[2] = origin[2] + RSP_INVENTOR_TURRET_ARC_HEIGHT_OFFSET;
    Format(originValue, sizeof(originValue), "%.1f %.1f %.1f", arcOrigin[0], arcOrigin[1], arcOrigin[2]);
    DispatchKeyValue(tesla, "origin", originValue);
    DispatchKeyValue(tesla, "texture", RSP_INVENTOR_TURRET_ARC_TEXTURE);
    DispatchKeyValue(tesla, "m_Color", RSP_INVENTOR_TURRET_ARC_COLOR);
    DispatchKeyValue(tesla, "m_flRadius", RSP_INVENTOR_TURRET_ARC_RADIUS);
    DispatchKeyValue(tesla, "beamcount_min", RSP_INVENTOR_TURRET_ARC_BEAMCOUNT_MIN);
    DispatchKeyValue(tesla, "beamcount_max", RSP_INVENTOR_TURRET_ARC_BEAMCOUNT_MAX);
    DispatchKeyValue(tesla, "thick_min", RSP_INVENTOR_TURRET_ARC_THICK_MIN);
    DispatchKeyValue(tesla, "thick_max", RSP_INVENTOR_TURRET_ARC_THICK_MAX);
    DispatchKeyValue(tesla, "lifetime_min", RSP_INVENTOR_TURRET_ARC_LIFETIME_MIN);
    DispatchKeyValue(tesla, "lifetime_max", RSP_INVENTOR_TURRET_ARC_LIFETIME_MAX);
    DispatchKeyValue(tesla, "interval_min", RSP_INVENTOR_TURRET_ARC_INTERVAL_MIN);
    DispatchKeyValue(tesla, "interval_max", RSP_INVENTOR_TURRET_ARC_INTERVAL_MAX);
    DispatchKeyValue(tesla, "m_bOn", "1");

    if (!DispatchSpawn(tesla) || !IsValidEntity(tesla))
    {
        if (IsValidEntity(tesla)) RemoveEntity(tesla);
        return INVALID_ENT_REFERENCE;
    }
    ActivateEntity(tesla);
    AcceptEntityInput(tesla, "TurnOn");
    // Emit the first electric arcs immediately instead of waiting for the first random interval.
    AcceptEntityInput(tesla, "DoSpark");
    return EntIndexToEntRef(tesla);
}

void StopBuildableAntennaArcEntity(int turret)
{
    if (turret <= MaxClients || turret >= RSP_MAX_ENTITIES)
    {
        return;
    }

    int sparkRef = g_iBuildableAntennaTeslaRef[turret];
    g_iBuildableAntennaTeslaRef[turret] = INVALID_ENT_REFERENCE;
    if (sparkRef == INVALID_ENT_REFERENCE || sparkRef == 0)
    {
        return;
    }

    int spark = EntRefToEntIndex(sparkRef);
    if (spark > MaxClients && spark < RSP_MAX_ENTITIES && IsValidEntity(spark))
    {
        AcceptEntityInput(spark, "TurnOff");
        RemoveEntity(spark);
    }
}

int CreateTeslaLoopSound(int turret)
{
    if (turret <= MaxClients || turret >= RSP_MAX_ENTITIES || !IsValidEntity(turret))
    {
        return INVALID_ENT_REFERENCE;
    }

    float turretOrigin[3], localMins[3], localMaxs[3], soundOrigin[3];
    GetEntPropVector(turret, Prop_Send, "m_vecOrigin", turretOrigin);
    if (GetBuildableLocalBounds(turret, localMins, localMaxs))
    {
        soundOrigin[0] = turretOrigin[0] + ((localMins[0] + localMaxs[0]) * 0.5);
        soundOrigin[1] = turretOrigin[1] + ((localMins[1] + localMaxs[1]) * 0.5);
        soundOrigin[2] = turretOrigin[2] + ((localMins[2] + localMaxs[2]) * 0.5);
    }
    else
    {
        soundOrigin[0] = turretOrigin[0];
        soundOrigin[1] = turretOrigin[1];
        soundOrigin[2] = turretOrigin[2] + 64.0;
    }

    int soundEntity = CreateEntityByName("ambient_generic");
    if (soundEntity <= MaxClients || soundEntity >= RSP_MAX_ENTITIES || !IsValidEntity(soundEntity))
    {
        return INVALID_ENT_REFERENCE;
    }

    char originValue[96];
    Format(originValue, sizeof(originValue), "%.1f %.1f %.1f", soundOrigin[0], soundOrigin[1], soundOrigin[2]);
    DispatchKeyValue(soundEntity, "message", RSP_INVENTOR_TURRET_LOOP_SOUND);
    DispatchKeyValue(soundEntity, "radius", RSP_INVENTOR_TURRET_LOOP_RADIUS);
    DispatchKeyValue(soundEntity, "health", RSP_INVENTOR_TURRET_LOOP_VOLUME);
    DispatchKeyValue(soundEntity, "pitch", "100");
    DispatchKeyValue(soundEntity, "spawnflags", RSP_TESLA_LOOP_SOUND_SPAWNFLAGS);
    DispatchKeyValue(soundEntity, "origin", originValue);

    if (!DispatchSpawn(soundEntity) || !IsValidEntity(soundEntity))
    {
        if (IsValidEntity(soundEntity))
        {
            RemoveEntity(soundEntity);
        }
        return INVALID_ENT_REFERENCE;
    }
    ActivateEntity(soundEntity);
    AcceptEntityInput(soundEntity, "PlaySound");
    return EntIndexToEntRef(soundEntity);
}

void StopBuildableLoopSound(int entity)
{
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES)
    {
        return;
    }

    int soundRef = g_iBuildableLoopSoundRef[entity];
    g_iBuildableLoopSoundRef[entity] = INVALID_ENT_REFERENCE;
    if (soundRef == INVALID_ENT_REFERENCE || soundRef == 0)
    {
        return;
    }

    int soundEntity = EntRefToEntIndex(soundRef);
    if (soundEntity > MaxClients && soundEntity < RSP_MAX_ENTITIES && IsValidEntity(soundEntity))
    {
        AcceptEntityInput(soundEntity, "StopSound");
        RemoveEntity(soundEntity);
    }
}

void SpawnBuilderFenceDebris(int fence)
{
    if (fence <= MaxClients || fence >= RSP_MAX_ENTITIES || !IsValidEntity(fence))
    {
        return;
    }

    float fenceOrigin[3];
    GetEntPropVector(fence, Prop_Send, "m_vecOrigin", fenceOrigin);
    // The fence itself is intentionally sunk 17 units. Debris starts at the original
    // ground plane plus a little height, so the fragments visibly fall onto the ground.
    fenceOrigin[2] += RSP_BUILDER_FENCE_GROUND_SINK + 12.0;

    for (int piece = 0; piece < RSP_BUILDER_DEBRIS_COUNT; piece++)
    {
        int debris = CreateEntityByName("prop_physics_override");
        if (debris <= MaxClients || debris >= RSP_MAX_ENTITIES || !IsValidEntity(debris))
        {
            continue;
        }

        float pieceOrigin[3], pieceAngles[3], velocity[3];
        pieceOrigin[0] = fenceOrigin[0] + GetRandomFloat(-20.0, 20.0);
        pieceOrigin[1] = fenceOrigin[1] + GetRandomFloat(-14.0, 14.0);
        pieceOrigin[2] = fenceOrigin[2] + GetRandomFloat(0.0, 10.0);
        pieceAngles[0] = GetRandomFloat(-35.0, 35.0);
        pieceAngles[1] = GetRandomFloat(0.0, 360.0);
        pieceAngles[2] = GetRandomFloat(-35.0, 35.0);
        velocity[0] = GetRandomFloat(-75.0, 75.0);
        velocity[1] = GetRandomFloat(-75.0, 75.0);
        velocity[2] = GetRandomFloat(45.0, 105.0);

        char originValue[96], anglesValue[96];
        Format(originValue, sizeof(originValue), "%.1f %.1f %.1f", pieceOrigin[0], pieceOrigin[1], pieceOrigin[2]);
        Format(anglesValue, sizeof(anglesValue), "%.1f %.1f %.1f", pieceAngles[0], pieceAngles[1], pieceAngles[2]);
        int debrisModelIndex = GetRandomInt(0, sizeof(g_sBuilderDebrisModels) - 1);
        DispatchKeyValue(debris, "model", g_sBuilderDebrisModels[debrisModelIndex]);
        DispatchKeyValue(debris, "origin", originValue);
        DispatchKeyValue(debris, "angles", anglesValue);
        // COLLISION_GROUP_DEBRIS behavior: debris collides with world geometry but not players/other debris.
        DispatchKeyValue(debris, "spawnflags", "4");

        if (!DispatchSpawn(debris) || !IsValidEntity(debris))
        {
            if (IsValidEntity(debris))
            {
                RemoveEntity(debris);
            }
            continue;
        }
        ActivateEntity(debris);
        TeleportEntity(debris, pieceOrigin, pieceAngles, velocity);
        CreateTimer(RSP_BUILDER_DEBRIS_LIFETIME, Timer_RemoveBuilderDebris,
            EntIndexToEntRef(debris), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Timer_RemoveBuilderDebris(Handle timer, any entityRef)
{
    int debris = EntRefToEntIndex(entityRef);
    if (debris > MaxClients && debris < RSP_MAX_ENTITIES && IsValidEntity(debris))
    {
        RemoveEntity(debris);
    }
    return Plugin_Stop;
}

void ActivateBuilder(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Builder || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    bool polish = IsPolishClient(client);
    if (g_iBuilderFenceModelIndex <= 0 || !IsModelPrecached(RSP_BUILDER_FENCE_MODEL))
    {
        PrintToChat(client, polish ? "\x04[RSP]\x01 Model płotu jest niedostępny." : "\x04[RSP]\x01 The fence model is unavailable.");
        return;
    }

    float mins[3] = {-48.0, -10.0, 2.0};
    float maxs[3] = {48.0, 10.0, 120.0};
    float destination[3], yaw;
    if (!FindBuildablePlacement(client, RSP_BUILDABLE_FENCE, 56.0, mins, maxs, destination, yaw))
    {
        PrintToChat(client, polish ? "\x04[RSP]\x01 Brak bezpiecznego miejsca przed Tobą na płot."
            : "\x04[RSP]\x01 There is no safe space in front of you for a fence.");
        return;
    }

    // Fence panels are broadside to the player's forward direction.
    float angles[3] = {0.0, 0.0, 0.0};
    angles[1] = yaw + 90.0;
    int fence = CreateTrackedBuildable(client, RSP_BUILDABLE_FENCE,
        RSP_BUILDER_FENCE_MODEL, destination, angles, RSP_BUILDER_FENCE_HEALTH);
    if (fence == -1)
    {
        PrintToChat(client, polish ? "\x04[RSP]\x01 Nie udało się postawić płotu."
            : "\x04[RSP]\x01 Could not place the fence.");
        return;
    }

    StartSkillCooldown(client, RSP_BUILDER_COOLDOWN);
    PrintToChat(client, polish
        ? "\x04[RSP]\x01 Zbudowano drewnianą ścianę."
        : "\x04[RSP]\x01 Wooden wall built.");
}

void PrintGiftPowerAssignment(int client, RSPPower power)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return;
    }
    int powerIndex = view_as<int>(power);
    if (powerIndex <= view_as<int>(RSP_None) || powerIndex >= view_as<int>(RSP_PowerCount))
    {
        return;
    }

    RSPClientLanguage language = GetRSPClientLanguage(client);
    char description[512];
    CopyPowerDescriptionForLanguage(language, powerIndex, description, sizeof(description));
    FormatLocalizedDynamicPowerDescription(client, power, language, description, sizeof(description));
    switch (language)
    {
        case RSP_LANG_PL:
            PrintToChat(client, "\x04[RSP]\x01 Rozpakowałeś prezent, dostałeś: \x04%s\x01 - %s", g_sPowerNamesEn[powerIndex], description);
        default:
            PrintToChat(client, "\x04[RSP]\x01 You opened the gift and received: \x04%s\x01 - %s", g_sPowerNamesEn[powerIndex], description);
    }
    if (IsRSPManualSkillPower(power))
    {
        PrintRSPBindInstruction(client, language);
    }
}

void CreateRSPGift(int victim, int owner)
{
    if (victim < 1 || victim > MaxClients || owner < 1 || owner > MaxClients ||
        !IsClientInGame(victim) || !IsClientInGame(owner) || victim == owner ||
        !IsValidEntity(victim) || !IsPlayerAlive(owner))
    {
        return;
    }

    // prop_physics_override supports this stock gift model. Spawn at the player's lower
    // torso from eye position; install collision rules BEFORE DispatchSpawn so VPhysics
    // never gets a player-overlap impulse that can eject the gift above the head.
    int gift = CreateEntityByName("prop_physics_override");
    if (gift == -1 || gift >= RSP_MAX_ENTITIES)
    {
        if (gift != -1 && IsValidEntity(gift)) RemoveEntity(gift);
        return;
    }

    DispatchKeyValue(gift, "model", RSP_LOOTBOX_MODEL);
    DispatchKeyValue(gift, "spawnflags", "0");
    DispatchKeyValue(gift, "disableshadows", "1");
    DispatchKeyValue(gift, "physdamagescale", "0");
    float origin[3], eyeOrigin[3];
    GetClientAbsOrigin(victim, origin);
    GetClientEyePosition(victim, eyeOrigin);
    float playerEyeSpan = eyeOrigin[2] - origin[2];
    if (playerEyeSpan < 32.0 || playerEyeSpan > 100.0)
    {
        playerEyeSpan = 64.0;
    }
    // Eye minus 0.60 of the eye span is the lower torso/belly area in CS:S. The prop
    // begins falling from here; unlike the former +32 keyvalue this is never an eye/head point.
    origin[2] = eyeOrigin[2] - (playerEyeSpan * 0.60);
    char originKey[64];
    Format(originKey, sizeof(originKey), "%f %f %f", origin[0], origin[1], origin[2]);
    DispatchKeyValue(gift, "origin", originKey);
    DispatchKeyValue(gift, "angles", "0 0 0");

    // Use INTERACTIVE_DEBRIS so gifts can collide with other interactive debris and
    // world/props. The per-entity ShouldCollide hook explicitly ignores players and their
    // movement hulls; unlike COLLISION_GROUP_NONE this is not a player-solid prop.
    g_iGiftOwnerUserId[gift] = GetClientUserId(owner);
    g_iGiftTeam[gift] = GetClientTeam(owner);
    SDKHook(gift, SDKHook_ShouldCollide, Hook_RSPGiftShouldCollide);
    SetEntityCollisionGroup(gift, RSP_COLLISION_GROUP_INTERACTIVE_DEBRIS);
    EntityCollisionRulesChanged(gift);

    if (!DispatchSpawn(gift) || !IsValidEntity(gift))
    {
        if (IsValidEntity(gift)) RemoveEntity(gift);
        g_iGiftOwnerUserId[gift] = 0;
        g_iGiftTeam[gift] = 0;
        return;
    }
    ActivateEntity(gift);
    // Refresh after spawn as some props reconstruct their collision rules in Spawn().
    SetEntityCollisionGroup(gift, RSP_COLLISION_GROUP_INTERACTIVE_DEBRIS);
    EntityCollisionRulesChanged(gift);
    // Reapply the belly origin and zero initial linear velocity. Since player collision
    // was disabled before DispatchSpawn, no player-hull depenetration should lift the gift.
    float zeroVelocity[3];
    zeroVelocity[0] = 0.0;
    zeroVelocity[1] = 0.0;
    zeroVelocity[2] = 0.0;
    TeleportEntity(gift, origin, NULL_VECTOR, zeroVelocity);
    SDKHook(gift, SDKHook_SetTransmit, Hook_RSPSetTransmit);
    // Gifts have no lifetime timer. They remain available through round_end and the
    // restart delay, until collected or removed by the next round_start/map cleanup.
}

public bool Hook_RSPGiftShouldCollide(int entity, int collisiongroup, int contentsmask, bool originalResult)
{
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES || g_iGiftOwnerUserId[entity] == 0)
    {
        return originalResult;
    }
    if (collisiongroup == RSP_COLLISION_GROUP_PLAYER ||
        collisiongroup == RSP_COLLISION_GROUP_PLAYER_MOVEMENT)
    {
        return false;
    }
    return originalResult;
}

void TryOpenNearbyGift(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) ||
        !g_bEnabled || !g_bSupportedMap || !g_bRoundReady ||
        g_iAssignedRound[client] != g_iRoundSerial || !IsValidPlayingClient(client))
    {
        return;
    }

    // Hidden technical debounce: repeated E input can only consume one gift every 1.2 s.
    if (GetGameTime() < g_fNextGiftUseTime[client])
    {
        return;
    }

    // Do not open a gift merely by standing near it: the crosshair trace must hit that
    // gift's actual physics hitbox, and the gift must also be within use distance.
    int aimedGift = GetClientAimTarget(client, false);
    if (aimedGift <= MaxClients || aimedGift >= RSP_MAX_ENTITIES || !IsValidEntity(aimedGift) ||
        g_iGiftOwnerUserId[aimedGift] == 0 || g_iGiftTeam[aimedGift] != GetClientTeam(client))
    {
        return;
    }

    float eyeOrigin[3], giftOrigin[3];
    GetClientEyePosition(client, eyeOrigin);
    GetEntPropVector(aimedGift, Prop_Send, "m_vecOrigin", giftOrigin);
    if (GetVectorDistance(eyeOrigin, giftOrigin) > RSP_LOOTBOX_USE_RADIUS)
    {
        return;
    }

    // Remove first, before assigning the new power, so two fast E presses cannot
    // open the same present or award its power to two teammates. The per-player debounce
    // also stops rapid opening of several gifts with repeated E input.
    g_fNextGiftUseTime[client] = GetGameTime() + RSP_LOOTBOX_USE_COOLDOWN;
    RemoveEntity(aimedGift);
    RSPPower power = GetRandomGiftRewardPower();
    if (power == RSP_None)
    {
        return;
    }
    EmitSoundToClient(client, "items/itempickup.wav");
    AssignPowerToClient(client, power, false, false, false, false, true);
}

RSPPower GetRandomGiftRewardPower()
{
    // Lootbox remains in the normal round pool and Gambler offers, but a gift must
    // grant a usable new power immediately rather than recursively requiring another kill.
    RSPPower candidates[sizeof(g_RSPSelectablePowers)];
    int candidateCount = 0;
    for (int i = 0; i < sizeof(g_RSPSelectablePowers); i++)
    {
        RSPPower candidate = g_RSPSelectablePowers[i];
        if (candidate == RSP_Lootbox)
        {
            continue;
        }
        candidates[candidateCount++] = candidate;
    }
    if (candidateCount <= 0)
    {
        return RSP_None;
    }
    return candidates[GetRandomInt(0, candidateCount - 1)];
}

void ClearAllGiftEntities()
{
    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iGiftOwnerUserId[entity] != 0)
        {
            g_iGiftOwnerUserId[entity] = 0;
            g_iGiftTeam[entity] = 0;
            if (IsValidEntity(entity)) RemoveEntity(entity);
        }
    }
}






// Send the impact glow as a temp entity, not a networked env_sprite. Both the laser
// BeamPoints and GlowSprite are sent in the same shot frame and use the exact same life,
// preventing the old entity timer/network creation from making the glow appear out of sync.
// Per-client line-of-sight checks retain the previous wall/prop occlusion behavior.
void CreateTeslaImpactSprite(const float origin[3], int target)
{
    if (g_iTeslaImpactSpriteModelIndex <= 0 || target <= 0 || target >= RSP_MAX_ENTITIES ||
        !IsValidEntity(target))
    {
        return;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client))
        {
            continue;
        }

        float eye[3];
        GetClientEyePosition(client, eye);
        int traceData = client * RSP_MAX_ENTITIES + target;
        bool visible = true;
        TR_TraceRayFilter(eye, origin, MASK_VISIBLE, RayType_EndPoint,
            TraceFilter_TeslaImpactLOS, traceData);
        if (TR_StartSolid() || TR_AllSolid() || (TR_DidHit() && TR_GetFraction() < 0.985))
        {
            visible = false;
        }
        if (visible)
        {
            TR_TraceRayFilter(eye, origin, MASK_SHOT, RayType_EndPoint,
                TraceFilter_TeslaImpactLOS, traceData);
            if (TR_StartSolid() || TR_AllSolid() || (TR_DidHit() && TR_GetFraction() < 0.985))
            {
                visible = false;
            }
        }
        if (visible)
        {
            TR_TraceRayFilter(eye, origin, MASK_SOLID, RayType_EndPoint,
                TraceFilter_TeslaImpactLOS, traceData);
            if (TR_StartSolid() || TR_AllSolid() || (TR_DidHit() && TR_GetFraction() < 0.985))
            {
                visible = false;
            }
        }
        if (!visible)
        {
            continue;
        }

        TE_SetupGlowSprite(origin, g_iTeslaImpactSpriteModelIndex,
            RSP_INVENTOR_TURRET_BEAM_LIFE, RSP_INVENTOR_TURRET_IMPACT_SPRITE_SIZE,
            RSP_INVENTOR_TURRET_IMPACT_SPRITE_BRIGHTNESS);
        TE_SendToClient(client);
    }
}

public bool TraceFilter_TeslaImpactLOS(int entity, int contentsMask, any data)
{
    int viewer = data / RSP_MAX_ENTITIES;
    int target = data % RSP_MAX_ENTITIES;
    if (entity == viewer || entity == target)
    {
        return false;
    }

    // A lethal hit can create the player's ragdoll before the delayed impact flash is
    // sent. Ignore that ragdoll as well, or it can incorrectly occlude its own impact.
    if (target >= 1 && target <= MaxClients && HasEntProp(target, Prop_Send, "m_hRagdoll"))
    {
        int ragdoll = GetEntPropEnt(target, Prop_Send, "m_hRagdoll");
        if (ragdoll > MaxClients && entity == ragdoll)
        {
            return false;
        }
    }
    return true;
}

bool IsRSPFirearmEntity(int weapon)
{
    if (weapon <= MaxClients || weapon >= RSP_MAX_ENTITIES || !IsValidEntity(weapon))
    {
        return false;
    }
    char classname[64];
    GetEntityClassname(weapon, classname, sizeof(classname));
    return IsRSPFirearmEventWeapon(classname);
}

bool GetWeaponAmmoState(int weapon, int &clip, int &ammoType)
{
    if (!IsRSPFirearmEntity(weapon) || !HasEntProp(weapon, Prop_Send, "m_iClip1") ||
        !HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"))
    {
        return false;
    }
    clip = GetEntProp(weapon, Prop_Send, "m_iClip1");
    ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    return ammoType >= 0 && ammoType < 32;
}

bool HasOtherWeaponUsingAmmoTypeExcept(int client, int ammoType, int skipA, int skipB)
{
    // If the inventory list is unavailable, treat the pool as shared/unknown and
    // refuse to move reserve ammo; falsely assuming isolation could steal ammo from another gun.
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        ammoType < 0 || ammoType >= 32 || !HasEntProp(client, Prop_Send, "m_hMyWeapons"))
    {
        return true;
    }
    int count = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
    if (count <= 0) return true;
    for (int i = 0; i < count; i++)
    {
        int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
        if (weapon <= MaxClients || weapon == skipA || weapon == skipB || !IsValidEntity(weapon) ||
            !HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"))
        {
            continue;
        }
        if (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType") == ammoType)
        {
            return true;
        }
    }
    return false;
}

void ActivateWeaponSwap(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) || g_iPower[client] != RSP_WeaponSwap ||
        g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    int heldWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    int heldSlot = -1;
    if (heldWeapon == GetPlayerWeaponSlot(client, 0)) heldSlot = 0;
    else if (heldWeapon == GetPlayerWeaponSlot(client, 1)) heldSlot = 1;

    int clientClip, clientAmmoType;
    if (heldSlot == -1 || !GetWeaponAmmoState(heldWeapon, clientClip, clientAmmoType))
    {
        RSPClientLanguage language = GetRSPClientLanguage(client);
        switch (language)
        {
            case RSP_LANG_PL: PrintToChat(client, "\x04[RSP]\x01 Musisz trzymać pistolet lub broń główną, aby użyć Weapon Swap.");
            default: PrintToChat(client, "\x04[RSP]\x01 Hold a pistol or primary firearm to use Weapon Swap.");
        }
        return;
    }

    int candidates[MAXPLAYERS + 1];
    int candidateWeapons[MAXPLAYERS + 1];
    int candidateSlots[MAXPLAYERS + 1];
    int candidateCount = 0;
    int team = GetClientTeam(client);

    // Any living enemy holding a primary firearm or pistol is eligible. If the enemy
    // is holding a knife, select an inventory firearm instead: prefer the same slot
    // as the activator's weapon, then fall back to the other firearm slot. The two
    // exchanged firearms may still be from different slots (e.g. AK for USP).
    for (int target = 1; target <= MaxClients; target++)
    {
        if (target == client || !IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
            GetClientTeam(target) == team)
        {
            continue;
        }

        int targetWeapon = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
        int targetSlot = -1;
        int targetPrimary = GetPlayerWeaponSlot(target, 0);
        int targetSecondary = GetPlayerWeaponSlot(target, 1);
        int targetKnife = GetPlayerWeaponSlot(target, 2);
        if (targetWeapon == targetPrimary) targetSlot = 0;
        else if (targetWeapon == targetSecondary) targetSlot = 1;
        else if (targetWeapon == targetKnife)
        {
            // A knife does not disqualify the target. Prefer the firearm in the
            // same slot as the activator's held weapon; use the other slot only
            // when the matching slot is empty or does not contain a valid firearm.
            targetSlot = heldSlot;
            targetWeapon = GetPlayerWeaponSlot(target, targetSlot);
            if (!IsRSPFirearmEntity(targetWeapon))
            {
                targetSlot = heldSlot == 0 ? 1 : 0;
                targetWeapon = GetPlayerWeaponSlot(target, targetSlot);
            }
        }
        int targetClip, targetAmmoType;
        if (targetSlot != -1 && GetWeaponAmmoState(targetWeapon, targetClip, targetAmmoType) &&
            candidateCount < MAXPLAYERS + 1)
        {
            candidates[candidateCount] = target;
            candidateWeapons[candidateCount] = targetWeapon;
            candidateSlots[candidateCount] = targetSlot;
            candidateCount++;
        }
    }

    if (candidateCount <= 0)
    {
        RSPClientLanguage language = GetRSPClientLanguage(client);
        switch (language)
        {
            case RSP_LANG_PL: PrintToChat(client, "\x04[RSP]\x01 Brak przeciwnika posiadającego pistolet lub broń główną do wymiany.");
            default: PrintToChat(client, "\x04[RSP]\x01 No enemy has a pistol or primary firearm available to swap.");
        }
        return;
    }

    int pick = GetRandomInt(0, candidateCount - 1);
    int target = candidates[pick];
    int targetWeapon = candidateWeapons[pick];
    int targetSlot = candidateSlots[pick];
    int targetClip, targetAmmoType;
    if (!IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
        !GetWeaponAmmoState(heldWeapon, clientClip, clientAmmoType) ||
        !GetWeaponAmmoState(targetWeapon, targetClip, targetAmmoType))
    {
        return;
    }

    // Each incoming weapon takes its native slot. If that slot already contains
    // another weapon, that old slot weapon is replaced and removed after the exchange.
    int clientDisplacedWeapon = GetPlayerWeaponSlot(client, targetSlot);
    if (clientDisplacedWeapon == heldWeapon) clientDisplacedWeapon = -1;
    else if (!IsRSPFirearmEntity(clientDisplacedWeapon)) clientDisplacedWeapon = -1;

    int targetDisplacedWeapon = GetPlayerWeaponSlot(target, heldSlot);
    if (targetDisplacedWeapon == targetWeapon) targetDisplacedWeapon = -1;
    else if (!IsRSPFirearmEntity(targetDisplacedWeapon)) targetDisplacedWeapon = -1;

    // With CS2 Magazine System loaded, each weapon entity owns its reserve-magazine
    // count (g_iWeaponMags[weapon]). Since Weapon Swap transfers the original entities,
    // their loaded clip and full spare-magazine count follow them automatically.
    // Do not rewrite the mirrored engine m_iAmmo array in that mode: it is only the
    // active-weapon display/engine bridge, not the companion plugin's source of truth.
    bool magazineSystemLoaded = IsCS2MagazineSystemLoaded();
    int clientReserve = 0;
    int targetReserve = 0;
    bool reservePoolsIsolated = false;
    if (!magazineSystemLoaded)
    {
        bool hasClientReserve = HasEntProp(client, Prop_Send, "m_iAmmo");
        bool hasTargetReserve = HasEntProp(target, Prop_Send, "m_iAmmo");
        if (hasClientReserve) clientReserve = GetEntProp(client, Prop_Send, "m_iAmmo", 4, clientAmmoType);
        if (hasTargetReserve) targetReserve = GetEntProp(target, Prop_Send, "m_iAmmo", 4, targetAmmoType);

        // Native CS:S reserve pools are shared by ammo type. Move them only when
        // both pools are isolated from all other surviving weapons.
        reservePoolsIsolated = hasClientReserve && hasTargetReserve &&
            !HasOtherWeaponUsingAmmoTypeExcept(client, clientAmmoType, heldWeapon, clientDisplacedWeapon) &&
            !HasOtherWeaponUsingAmmoTypeExcept(client, targetAmmoType, heldWeapon, clientDisplacedWeapon) &&
            !HasOtherWeaponUsingAmmoTypeExcept(target, clientAmmoType, targetWeapon, targetDisplacedWeapon) &&
            !HasOtherWeaponUsingAmmoTypeExcept(target, targetAmmoType, targetWeapon, targetDisplacedWeapon);
    }

    char incomingForClient[64], incomingForTarget[64];
    GetEntityClassname(targetWeapon, incomingForClient, sizeof(incomingForClient));
    GetEntityClassname(heldWeapon, incomingForTarget, sizeof(incomingForTarget));

    // Detach all participating entities before equipping anything. If any detach fails,
    // restore every entity already detached and leave the original inventories intact.
    bool clientHeldDetached = RemovePlayerItem(client, heldWeapon);
    if (!clientHeldDetached) return;

    bool targetHeldDetached = RemovePlayerItem(target, targetWeapon);
    if (!targetHeldDetached)
    {
        if (IsValidEntity(heldWeapon)) EquipPlayerWeapon(client, heldWeapon);
        return;
    }

    bool clientDisplacedDetached = false;
    if (clientDisplacedWeapon > MaxClients)
    {
        clientDisplacedDetached = RemovePlayerItem(client, clientDisplacedWeapon);
        if (!clientDisplacedDetached)
        {
            if (IsValidEntity(heldWeapon)) EquipPlayerWeapon(client, heldWeapon);
            if (IsValidEntity(targetWeapon)) EquipPlayerWeapon(target, targetWeapon);
            return;
        }
    }

    bool targetDisplacedDetached = false;
    if (targetDisplacedWeapon > MaxClients)
    {
        targetDisplacedDetached = RemovePlayerItem(target, targetDisplacedWeapon);
        if (!targetDisplacedDetached)
        {
            if (clientDisplacedDetached && IsValidEntity(clientDisplacedWeapon))
                EquipPlayerWeapon(client, clientDisplacedWeapon);
            if (IsValidEntity(heldWeapon)) EquipPlayerWeapon(client, heldWeapon);
            if (IsValidEntity(targetWeapon)) EquipPlayerWeapon(target, targetWeapon);
            return;
        }
    }

    // The actual exchange keeps each weapon entity (and its loaded magazine) intact.
    EquipPlayerWeapon(client, targetWeapon);
    EquipPlayerWeapon(target, heldWeapon);
    if (HasEntProp(targetWeapon, Prop_Send, "m_iClip1"))
        SetEntProp(targetWeapon, Prop_Send, "m_iClip1", targetClip);
    if (HasEntProp(heldWeapon, Prop_Send, "m_iClip1"))
        SetEntProp(heldWeapon, Prop_Send, "m_iClip1", clientClip);

    if (clientDisplacedDetached && IsValidEntity(clientDisplacedWeapon)) RemoveEntity(clientDisplacedWeapon);
    if (targetDisplacedDetached && IsValidEntity(targetDisplacedWeapon)) RemoveEntity(targetDisplacedWeapon);

    if (!magazineSystemLoaded && reservePoolsIsolated)
    {
        if (clientAmmoType == targetAmmoType)
        {
            SetEntProp(client, Prop_Send, "m_iAmmo", targetReserve, 4, clientAmmoType);
            SetEntProp(target, Prop_Send, "m_iAmmo", clientReserve, 4, targetAmmoType);
        }
        else
        {
            SetEntProp(client, Prop_Send, "m_iAmmo", targetReserve, 4, targetAmmoType);
            SetEntProp(client, Prop_Send, "m_iAmmo", 0, 4, clientAmmoType);
            SetEntProp(target, Prop_Send, "m_iAmmo", clientReserve, 4, clientAmmoType);
            SetEntProp(target, Prop_Send, "m_iAmmo", 0, 4, targetAmmoType);
        }
    }

    FakeClientCommand(client, "use %s", incomingForClient);
    FakeClientCommand(target, "use %s", incomingForTarget);
    StartSkillCooldown(client, RSP_WEAPON_SWAP_COOLDOWN);
    RSPClientLanguage swapLanguage = GetRSPClientLanguage(client);
    switch (swapLanguage)
    {
        case RSP_LANG_PL: PrintToChat(client, "\x04[RSP]\x01 Wymieniłeś trzymaną broń z losowym przeciwnikiem.");
        default: PrintToChat(client, "\x04[RSP]\x01 You swapped your held firearm with a random enemy.");
    }
    PrintRSPTargetEffectNotice(target, client, RSP_NOTICE_WEAPON_SWAP);
}

void ActivateMiner(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) || g_iPower[client] != RSP_Miner ||
        g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }
    if (g_iMinerUsesThisRound[client] >= RSP_MINER_USES_PER_ROUND)
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Wykorzystałeś już wszystkie 5 min w tej rundzie."
            : "\x04[RSP]\x01 You have used all 5 mines this round.");
        return;
    }

    float mins[3] = {-8.0, -8.0, 0.0};
    float maxs[3] = {8.0, 8.0, 18.0};
    float destination[3], yaw;
    if (!FindBuildablePlacement(client, RSP_BUILDABLE_FENCE, 46.0, mins, maxs, destination, yaw))
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Nie znaleziono bezpiecznego miejsca na minę."
            : "\x04[RSP]\x01 No safe placement was found for the mine.");
        return;
    }

    // Deliberately sink the mine five units below its previous placement.
    destination[2] -= 5.0;

    // Prevent stacking several mines at one point: compare candidate placement to all
    // active mines, including mines placed by other players/teams.
    for (int existingMine = MaxClients + 1; existingMine < RSP_MAX_ENTITIES; existingMine++)
    {
        if (g_iMinerOwnerUserId[existingMine] == 0 || !IsValidEntity(existingMine))
        {
            continue;
        }
        float existingOrigin[3];
        GetEntPropVector(existingMine, Prop_Send, "m_vecOrigin", existingOrigin);
        if (GetVectorDistance(destination, existingOrigin) < RSP_MINER_MIN_SEPARATION)
        {
            PrintToChat(client, IsPolishClient(client)
                ? "\x04[RSP]\x01 Za blisko innej miny. Wybierz inne miejsce."
                : "\x04[RSP]\x01 Too close to another mine. Choose a different spot.");
            return;
        }
    }

    int mine = CreateEntityByName("prop_dynamic_override");
    if (mine == -1 || mine >= RSP_MAX_ENTITIES)
    {
        if (mine != -1 && IsValidEntity(mine)) RemoveEntity(mine);
        return;
    }
    DispatchKeyValue(mine, "model", "models/props_combine/combine_mine01.mdl");
    DispatchKeyValue(mine, "solid", "0");
    DispatchKeyValue(mine, "spawnflags", "0");
    DispatchKeyValue(mine, "disableshadows", "1");
    if (!DispatchSpawn(mine))
    {
        RemoveEntity(mine);
        return;
    }
    ActivateEntity(mine);
    SetEntityMoveType(mine, MOVETYPE_NONE);
    float angles[3];
    angles[0] = 0.0;
    angles[1] = yaw;
    angles[2] = 0.0;
    TeleportEntity(mine, destination, angles, NULL_VECTOR);
    g_iMinerOwnerUserId[mine] = GetClientUserId(client);
    g_iMinerTeam[mine] = GetClientTeam(client);
    g_iMinerRound[mine] = g_iRoundSerial;
    g_bMinerDetonating[mine] = false;
    SDKHook(mine, SDKHook_SetTransmit, Hook_RSPSetTransmit);
    if (!StartMinerCheckTimer())
    {
        g_iMinerOwnerUserId[mine] = 0;
        g_iMinerTeam[mine] = 0;
        g_iMinerRound[mine] = 0;
        RemoveEntity(mine);
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Nie udało się uruchomić miny. Spróbuj ponownie."
            : "\x04[RSP]\x01 Could not activate the mine. Try again.");
        return;
    }
    g_iMinerUsesThisRound[client]++;
    StartSkillCooldown(client, RSP_MINER_COOLDOWN);
    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Mina postawiona (%d/%d)."
        : "\x04[RSP]\x01 Mine placed (%d/%d).",
        g_iMinerUsesThisRound[client], RSP_MINER_USES_PER_ROUND);
}

bool StartMinerCheckTimer()
{
    if (g_hMinerCheckTimer == null)
    {
        // Poll at 20 Hz so an opponent entering the 40-unit trigger radius is
        // detected promptly. The actual blast damage radius is independently 500 units.
        g_hMinerCheckTimer = CreateTimer(0.05, Timer_CheckMinerMines, 0,
            TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    }
    return g_hMinerCheckTimer != null;
}

public Action Timer_CheckMinerMines(Handle timer, any data)
{
    bool anyMines = false;
    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iMinerOwnerUserId[entity] == 0 || !IsValidEntity(entity))
        {
            continue;
        }
        anyMines = true;
        if (g_bMinerDetonating[entity]) continue;
        if (g_iMinerRound[entity] != g_iRoundSerial)
        {
            g_iMinerOwnerUserId[entity] = 0;
            g_iMinerTeam[entity] = 0;
            g_iMinerRound[entity] = 0;
            ClearMinerDiscoveryForEntity(entity);
            RemoveEntity(entity);
            continue;
        }

        float mineOrigin[3], playerOrigin[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", mineOrigin);
        int mineTeam = g_iMinerTeam[entity];
        for (int target = 1; target <= MaxClients; target++)
        {
            if (!IsValidPlayingClient(target) || !IsPlayerAlive(target) || GetClientTeam(target) == mineTeam)
            {
                continue;
            }
            GetClientAbsOrigin(target, playerOrigin);
            if (GetVectorDistance(mineOrigin, playerOrigin) <= RSP_MINER_TRIGGER_RADIUS)
            {
                DetonateMinerMine(entity);
                break;
            }
        }
    }

    if (!anyMines)
    {
        if (g_hMinerCheckTimer == timer) g_hMinerCheckTimer = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

public bool TraceFilter_MinerBlastLOS(int entity, int contentsMask, any data)
{
    int mine = data / RSP_MAX_ENTITIES;
    int target = data % RSP_MAX_ENTITIES;
    if (entity == mine || entity == target || (entity >= 1 && entity <= MaxClients))
    {
        // Player hitboxes do not shield other nearby players from this radial blast.
        return false;
    }
    return true;
}

public bool TraceFilter_MinerGroundScorch(int entity, int contentsMask, any data)
{
    if (entity == data || (entity >= 1 && entity <= MaxClients))
    {
        return false;
    }
    return true;
}

void SendMinerGroundScorch(int mine, const float mineOrigin[3])
{
    if (g_iExplosiveBulletDecal <= 0 || mine <= MaxClients || !IsValidEntity(mine))
    {
        return;
    }

    float traceStart[3], traceEnd[3];
    for (int axis = 0; axis < 3; axis++)
    {
        traceStart[axis] = mineOrigin[axis];
        traceEnd[axis] = mineOrigin[axis];
    }
    traceStart[2] += 48.0;
    traceEnd[2] -= 96.0;
    TR_TraceRayFilter(traceStart, traceEnd, MASK_SOLID, RayType_EndPoint,
        TraceFilter_MinerGroundScorch, mine);
    if (!TR_DidHit() || TR_StartSolid() || TR_AllSolid())
    {
        return;
    }

    float impactPosition[3], impactNormal[3];
    TR_GetEndPosition(impactPosition);
    TR_GetPlaneNormal(INVALID_HANDLE, impactNormal);
    int impactEntity = TR_GetEntityIndex();
    int surfaceFlags = TR_GetSurfaceFlags();
    if ((surfaceFlags & (SURF_NODECALS | SURF_NODRAW | SURF_SKY)) != 0 || impactNormal[2] < 0.5)
    {
        return;
    }

    // Reuse RSP's precached scorch1 projected decal, restricted to floor-like
    // world/brush surfaces (not players, props, SKY or NODRAW surfaces).
    SendExplosiveBulletScorchDecal(impactPosition, impactNormal, impactEntity);
}

void DetonateMinerMine(int mine)
{
    if (mine <= MaxClients || mine >= RSP_MAX_ENTITIES || !IsValidEntity(mine) ||
        g_iMinerOwnerUserId[mine] == 0 || g_bMinerDetonating[mine])
    {
        return;
    }
    g_bMinerDetonating[mine] = true;
    int ownerUserId = g_iMinerOwnerUserId[mine];
    float origin[3], targetOrigin[3];
    GetEntPropVector(mine, Prop_Send, "m_vecOrigin", origin);
    SendMinerGroundScorch(mine, origin);
    if (g_iExplosiveBulletSprite > 0)
    {
        TE_SetupExplosion(origin, g_iExplosiveBulletSprite, 1.0, 15, TE_EXPLFLAG_NOSOUND,
            RoundToNearest(RSP_MINER_RADIUS), RoundToNearest(RSP_MINER_DAMAGE));
        TE_SendToAll();
    }
    EmitSoundToAll(RSP_INVENTOR_TURRET_EXPLOSION_SOUND, SOUND_FROM_WORLD, SNDCHAN_AUTO,
        SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, origin);

    int owner = GetClientOfUserId(ownerUserId);
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner)) owner = 0;
    for (int target = 1; target <= MaxClients; target++)
    {
        // The mine is triggered by an enemy, but the blast itself is not team-filtered:
        // owner, teammates and opponents all receive the same distance-scaled explosion.
        if (!IsValidPlayingClient(target) || !IsPlayerAlive(target))
        {
            continue;
        }
        GetClientAbsOrigin(target, targetOrigin);
        float distance = GetVectorDistance(origin, targetOrigin);
        if (distance > RSP_MINER_RADIUS) continue;

        float blastStart[3], targetEye[3];
        blastStart[0] = origin[0];
        blastStart[1] = origin[1];
        blastStart[2] = origin[2] + 12.0;
        GetClientEyePosition(target, targetEye);
        int traceData = mine * RSP_MAX_ENTITIES + target;
        TR_TraceRayFilter(blastStart, targetEye, MASK_SOLID, RayType_EndPoint,
            TraceFilter_MinerBlastLOS, traceData);
        if (TR_StartSolid() || TR_AllSolid() || (TR_DidHit() && TR_GetFraction() < 0.98))
        {
            continue;
        }

        // Linear radial falloff: 100 damage at the mine, approaching zero at the 500-unit blast boundary.
        float damage = RSP_MINER_DAMAGE * (1.0 - (distance / RSP_MINER_RADIUS));
        if (damage < 1.0) continue;

        // Supply a radial blast impulse plus an upward component through the native
        // TakeDamage force vector. CS:S copies this force into its cs_ragdoll so a lethal
        // mine blast launches the corpse rather than using the near-zero knife-like force.
        float pushDirection[3], damageForce[3];
        pushDirection[0] = targetOrigin[0] - origin[0];
        pushDirection[1] = targetOrigin[1] - origin[1];
        pushDirection[2] = targetOrigin[2] - origin[2] + 70.0;
        if (GetVectorLength(pushDirection) < 0.01)
        {
            pushDirection[0] = 0.0;
            pushDirection[1] = 0.0;
            pushDirection[2] = 1.0;
        }
        NormalizeVector(pushDirection, pushDirection);
        float forceMagnitude = damage * 450.0;
        for (int axis = 0; axis < 3; axis++)
        {
            damageForce[axis] = pushDirection[axis] * forceMagnitude;
        }
        SDKHooks_TakeDamage(target, mine, owner, damage, DMG_BLAST, -1, damageForce, origin, false);
    }

    g_iMinerOwnerUserId[mine] = 0;
    g_iMinerTeam[mine] = 0;
    g_iMinerRound[mine] = 0;
    ClearMinerDiscoveryForEntity(mine);
    if (IsValidEntity(mine)) RemoveEntity(mine);
}


void ClearMinerDiscoveryForEntity(int entity)
{
    if (entity <= MaxClients || entity >= RSP_MAX_ENTITIES)
    {
        return;
    }
    for (int viewer = 1; viewer <= MaxClients; viewer++)
    {
        g_bMinerDiscoveredBy[entity][viewer] = false;
    }
}

void ClearAllMinerMines()
{
    if (g_hMinerCheckTimer != null)
    {
        delete g_hMinerCheckTimer;
        g_hMinerCheckTimer = null;
    }
    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iMinerOwnerUserId[entity] != 0)
        {
            g_iMinerOwnerUserId[entity] = 0;
            g_iMinerTeam[entity] = 0;
            g_iMinerRound[entity] = 0;
            g_bMinerDetonating[entity] = false;
            ClearMinerDiscoveryForEntity(entity);
            if (IsValidEntity(entity)) RemoveEntity(entity);
        }
    }
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "cs2_magazine_system", false))
    {
        g_bMagazineSystemDetected = true;
    }
}

public void OnLibraryRemoved(const char[] name)
{
    if (StrEqual(name, "cs2_magazine_system", false))
    {
        g_bMagazineSystemDetected = false;
    }
}

bool IsCS2MagazineSystemLoaded()
{
    // The library flag is initialized at OnPluginStart and kept in sync by
    // OnLibraryAdded/OnLibraryRemoved, avoiding repeated expensive lookups.
    return g_bMagazineSystemDetected;
}

void ApplyLeechAmmoTransfer(int attacker, int victim)
{
    if (attacker < 1 || attacker > MaxClients || victim < 1 || victim > MaxClients || attacker == victim ||
        !IsClientInGame(attacker) || !IsClientInGame(victim) || !IsPlayerAlive(attacker) || !IsPlayerAlive(victim) ||
        !HasEntProp(attacker, Prop_Send, "m_hActiveWeapon") || !HasEntProp(victim, Prop_Send, "m_hActiveWeapon") ||
        !HasEntProp(attacker, Prop_Send, "m_iAmmo") || !HasEntProp(victim, Prop_Send, "m_iAmmo"))
    {
        return;
    }

    int attackerWeapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
    int victimWeapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
    int attackerClip, attackerAmmoType, victimClip, victimAmmoType;
    if (!GetWeaponAmmoState(attackerWeapon, attackerClip, attackerAmmoType) ||
        !GetWeaponAmmoState(victimWeapon, victimClip, victimAmmoType))
    {
        return;
    }

    if (IsCS2MagazineSystemLoaded())
    {
        // Magazine System owns per-weapon reserve state. Transfer one whole magazine
        // atomically instead of editing its mirrored player ammo property.
        if (GetFeatureStatus(FeatureType_Native, "CS2Mag_TransferReserveMagazines") == FeatureStatus_Available)
        {
            CS2Mag_TransferReserveMagazines(victim, victimWeapon, attacker, attackerWeapon, 1);
        }
        // An older companion build does not expose a safe transfer API; fail closed.
        return;
    }

    int victimReserve = GetEntProp(victim, Prop_Send, "m_iAmmo", 4, victimAmmoType);
    if (victimReserve <= 0)
    {
        return;
    }

    int stolen = RoundToCeil(float(victimReserve) * float(RSP_LEECH_RESERVE_TRANSFER_PERCENT) / 100.0);
    if (stolen < 1) stolen = 1;
    if (stolen > victimReserve) stolen = victimReserve;
    int attackerReserve = GetEntProp(attacker, Prop_Send, "m_iAmmo", 4, attackerAmmoType);
    SetEntProp(victim, Prop_Send, "m_iAmmo", victimReserve - stolen, 4, victimAmmoType);
    SetEntProp(attacker, Prop_Send, "m_iAmmo", attackerReserve + stolen, 4, attackerAmmoType);
}

void ActivateEntropy(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) || g_iPower[client] != RSP_Entropy ||
        g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    bool magazineSystem = IsCS2MagazineSystemLoaded();
    if (magazineSystem && GetFeatureStatus(FeatureType_Native, "CS2Mag_RemoveReserveMagazines") != FeatureStatus_Available)
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Entropy wymaga CS2 Magazine System z obsługą usuwania magazynków rezerwowych."
            : "\x04[RSP]\x01 Entropy requires CS2 Magazine System with reserve-removal support.");
        return;
    }

    int targetClients[MAXPLAYERS + 1];
    int targetWeapons[MAXPLAYERS + 1];
    int targetAmmoTypes[MAXPLAYERS + 1];
    int targetCount = 0;
    int myTeam = GetClientTeam(client);
    for (int target = 1; target <= MaxClients; target++)
    {
        if (target == client || !IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
            GetClientTeam(target) == myTeam || !HasEntProp(target, Prop_Send, "m_hActiveWeapon") ||
            !HasEntProp(target, Prop_Send, "m_iAmmo"))
        {
            continue;
        }

        int weapon = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
        int clip, ammoType;
        if (!GetWeaponAmmoState(weapon, clip, ammoType))
        {
            continue; // C4, grenades and weapons without a valid reserve-ammo type are excluded.
        }
        targetClients[targetCount] = target;
        targetWeapons[targetCount] = weapon;
        targetAmmoTypes[targetCount] = ammoType;
        targetCount++;
    }

    if (targetCount <= 0)
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Brak przeciwników trzymających broń palną z amunicją rezerwową."
            : "\x04[RSP]\x01 No enemy is currently holding an eligible firearm.");
        return;
    }

    // Randomize order, then attempt each candidate once. Entropy removes reserve only;
    // it never transfers ammunition to the activator. Empty reserves do not consume cooldown.
    int start = GetRandomInt(0, targetCount - 1);
    for (int step = 0; step < targetCount; step++)
    {
        int slot = (start + step) % targetCount;
        int target = targetClients[slot];
        int sourceWeapon = targetWeapons[slot];
        if (!IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
            GetClientTeam(target) == myTeam || GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon") != sourceWeapon ||
            !IsValidEntity(sourceWeapon))
        {
            continue;
        }

        int removedAmount = 0;
        if (magazineSystem)
        {
            // The companion system changes its authoritative per-weapon count and
            // queues the reserve loss safely if a reload is currently in progress.
            if (CS2Mag_RemoveReserveMagazines(target, sourceWeapon, 2147483647))
            {
                removedAmount = 1; // Success marker; the native reports bool, not a count.
            }
        }
        else
        {
            int sourceClip, sourceAmmoType;
            if (!GetWeaponAmmoState(sourceWeapon, sourceClip, sourceAmmoType))
            {
                continue;
            }
            int sourceReserve = GetEntProp(target, Prop_Send, "m_iAmmo", 4, sourceAmmoType);
            if (sourceReserve <= 0)
            {
                continue;
            }

            // Standard CS:S stores reserve ammo on the player by ammo type. Clear only
            // the selected enemy's reserve pool; the activator receives nothing.
            SetEntProp(target, Prop_Send, "m_iAmmo", 0, 4, sourceAmmoType);
            removedAmount = sourceReserve;
        }

        if (removedAmount <= 0)
        {
            continue;
        }

        StartSkillCooldown(client, RSP_ENTROPY_COOLDOWN);
        bool polish = IsPolishClient(client);
        if (magazineSystem)
        {
            PrintToChat(client, polish
                ? "\x04[RSP]\x01 Entropy usunęło cały zapas rezerwowych magazynków przeciwnika. Odnowienie: 20 s."
                : "\x04[RSP]\x01 Entropy removed all reserve magazines from the enemy's held firearm. Cooldown: 20 s.");
        }
        else
        {
            PrintToChat(client, polish
                ? "\x04[RSP]\x01 Entropy usunęło %d pocisków zapasowych przeciwnika. Odnowienie: 20 s."
                : "\x04[RSP]\x01 Entropy removed %d reserve bullets from the enemy. Cooldown: 20 s.", removedAmount);
        }
        return;
    }

    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Żaden przeciwnik nie ma amunicji rezerwowej do usunięcia. Odnowienie nie zostało zużyte."
        : "\x04[RSP]\x01 No enemy has reserve ammo to remove. Cooldown was not consumed.");
}


void ActivateInventor(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Inventor || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    bool polish = IsPolishClient(client);
    int ownerUserId = GetClientUserId(client);
    if (g_iInventorUsesThisRound[client] >= RSP_INVENTOR_USES_PER_ROUND)
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Wykorzystałeś oba użycia Inventora w tej rundzie."
            : "\x04[RSP]\x01 You have used both Inventor uses this round.");
        return;
    }
    if (CountBuildablesForOwner(ownerUserId, RSP_BUILDABLE_TURRET) >= RSP_INVENTOR_MAX_TURRETS)
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Masz już maksymalną liczbę działek (2). Zniszcz jedno, aby postawić kolejne."
            : "\x04[RSP]\x01 You already have the maximum of 2 turrets. Destroy one to place another.");
        return;
    }
    if (g_iInventorTurretModelIndex <= 0 || !IsModelPrecached(RSP_INVENTOR_TURRET_MODEL))
    {
        PrintToChat(client, polish ? "\x04[RSP]\x01 Model działka jest niedostępny." : "\x04[RSP]\x01 The turret model is unavailable.");
        return;
    }

    float mins[3] = {-28.0, -28.0, 2.0};
    float maxs[3] = {28.0, 28.0, 144.0};
    float destination[3], yaw, teslaGroundSpread;
    if (!FindBuildablePlacementWithGroundSpread(client, RSP_BUILDABLE_TURRET, 64.0,
        mins, maxs, destination, yaw, teslaGroundSpread))
    {
        PrintToChat(client, polish ? "\x04[RSP]\x01 Brak bezpiecznego miejsca przed Tobą na działko."
            : "\x04[RSP]\x01 There is no safe space in front of you for the turret.");
        return;
    }

    float angles[3] = {0.0, 0.0, 0.0};
    angles[1] = yaw;
    int turret = CreateTrackedBuildable(client, RSP_BUILDABLE_TURRET,
        RSP_INVENTOR_TURRET_MODEL, destination, angles, RSP_INVENTOR_TURRET_HEALTH);
    if (turret == -1)
    {
        PrintToChat(client, polish ? "\x04[RSP]\x01 Nie udało się postawić działka."
            : "\x04[RSP]\x01 Could not place the turret.");
        return;
    }
    if (!IsTeslaSpawnVolumeClear(turret, teslaGroundSpread))
    {
        RemoveBuildableEntity(turret);
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Działko nie może nachodzić na ścianę ani obiekt."
            : "\x04[RSP]\x01 The turret cannot overlap a wall or prop.");
        return;
    }

    g_hBuildableTurretTimer[turret] = CreateTimer(RSP_INVENTOR_TURRET_INTERVAL,
        Timer_BuildableTurretFire, EntIndexToEntRef(turret), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    if (g_hBuildableTurretTimer[turret] == null)
    {
        RemoveBuildableEntity(turret);
        PrintToChat(client, polish ? "\x04[RSP]\x01 Nie udało się uruchomić działka. Spróbuj ponownie."
            : "\x04[RSP]\x01 Could not start the turret. Try again.");
        return;
    }

    g_iInventorUsesThisRound[client]++;
    StartSkillCooldown(client, RSP_INVENTOR_COOLDOWN);
    PrintToChat(client, polish
        ? "\x04[RSP]\x01 Działko laserowe ustawione (%d/2)."
        : "\x04[RSP]\x01 Laser turret placed (%d/2).",
        g_iInventorUsesThisRound[client]);
}

bool IsTeslaSpawnVolumeClear(int turret, float groundSpread)
{
    if (turret <= MaxClients || turret >= RSP_MAX_ENTITIES || !IsValidEntity(turret) ||
        g_iBuildableType[turret] != RSP_BUILDABLE_TURRET)
    {
        return false;
    }

    float localMins[3], localMaxs[3], origin[3];
    if (!GetBuildableLocalBounds(turret, localMins, localMaxs))
    {
        // This stock transformer model should always expose VPhysics bounds; fail closed
        // instead of allowing an unchecked placement if those bounds are unavailable.
        return false;
    }
    GetEntPropVector(turret, Prop_Send, "m_vecOrigin", origin);

    float yawAngles[3] = {0.0, 0.0, 0.0};
    yawAngles[1] = g_fBuildableYaw[turret];
    float forwardVec[3], rightVec[3], upVec[3];
    GetAngleVectors(yawAngles, forwardVec, rightVec, upVec);
    float halfX = (FloatAbs(localMins[0]) > FloatAbs(localMaxs[0]))
        ? FloatAbs(localMins[0]) : FloatAbs(localMaxs[0]);
    float halfY = (FloatAbs(localMins[1]) > FloatAbs(localMaxs[1]))
        ? FloatAbs(localMins[1]) : FloatAbs(localMaxs[1]);
    float worldHalfX = FloatAbs(forwardVec[0]) * halfX + FloatAbs(rightVec[0]) * halfY;
    float worldHalfY = FloatAbs(forwardVec[1]) * halfX + FloatAbs(rightVec[1]) * halfY;

    // Do a geometric AABB check against all prop_* entities as well as a physics trace.
    // Some map props are rendered but have no active trace contents, so a trace alone can
    // permit a visible partial overlap. Only prop entities are checked geometrically;
    // world brushes remain covered by the solid hull trace below.
    float propCheckMins[3], propCheckMaxs[3];
    propCheckMins[0] = origin[0] - worldHalfX - RSP_INVENTOR_TURRET_POSTSPAWN_PADDING;
    propCheckMins[1] = origin[1] - worldHalfY - RSP_INVENTOR_TURRET_POSTSPAWN_PADDING;
    // Ignore only the expected ground-contact band, including the small sink and unevenness
    // measured during placement. Prop overlap above the highest support point still fails.
    propCheckMins[2] = origin[2] + localMins[2] +
        RSP_INVENTOR_TURRET_GROUND_SINK + groundSpread - 1.0;
    propCheckMaxs[0] = origin[0] + worldHalfX + RSP_INVENTOR_TURRET_POSTSPAWN_PADDING;
    propCheckMaxs[1] = origin[1] + worldHalfY + RSP_INVENTOR_TURRET_POSTSPAWN_PADDING;
    propCheckMaxs[2] = origin[2] + localMaxs[2] + 1.0;
    if (!IsTeslaPlacementAABBFreeOfProps(turret, propCheckMins, propCheckMaxs))
    {
        return false;
    }

    float mins[3], maxs[3];
    mins[0] = -worldHalfX - RSP_INVENTOR_TURRET_POSTSPAWN_PADDING;
    mins[1] = -worldHalfY - RSP_INVENTOR_TURRET_POSTSPAWN_PADDING;
    mins[2] = localMins[2];
    maxs[0] = worldHalfX + RSP_INVENTOR_TURRET_POSTSPAWN_PADDING;
    maxs[1] = worldHalfY + RSP_INVENTOR_TURRET_POSTSPAWN_PADDING;
    maxs[2] = localMaxs[2];

    // The model is intentionally sunk into its support surface. Start this trace above
    // the highest sampled support point so sloped ground does not cause a false rejection.
    // The AABB check above still checks props/walls above that ground-contact envelope.
    origin[2] += RSP_INVENTOR_TURRET_GROUND_SINK + groundSpread + 2.0;
    TR_TraceHullFilter(origin, origin, mins, maxs,
        MASK_SOLID | CONTENTS_DEBRIS | CONTENTS_HITBOX,
        TraceFilter_TeslaPostSpawnClearance, turret);
    return !TR_StartSolid() && !TR_AllSolid() && (!TR_DidHit() || TR_GetFraction() >= 0.999);
}

bool IsTeslaPlacementAABBFreeOfProps(int turret, const float candidateMins[3], const float candidateMaxs[3])
{
    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (entity == turret || !IsValidEntity(entity))
        {
            continue;
        }

        char classname[64];
        GetEntityClassname(entity, classname, sizeof(classname));
        if (StrContains(classname, "prop_", false) != 0)
        {
            continue;
        }

        float propMins[3], propMaxs[3];
        bool hasAbsoluteBounds = HasEntProp(entity, Prop_Data, "m_vecAbsMins") &&
            HasEntProp(entity, Prop_Data, "m_vecAbsMaxs");
        if (hasAbsoluteBounds)
        {
            GetEntPropVector(entity, Prop_Data, "m_vecAbsMins", propMins);
            GetEntPropVector(entity, Prop_Data, "m_vecAbsMaxs", propMaxs);
        }
        else
        {
            // Some prop classes do not expose absolute bounds through the datamap.
            // Reconstruct a conservative world AABB from their local bounds and origin.
            if (!HasEntProp(entity, Prop_Data, "m_vecMins") ||
                !HasEntProp(entity, Prop_Data, "m_vecMaxs"))
            {
                continue;
            }
            bool hasOrigin = HasEntProp(entity, Prop_Send, "m_vecOrigin");
            if (!hasOrigin && !HasEntProp(entity, Prop_Data, "m_vecOrigin"))
            {
                continue;
            }

            float localMins[3], localMaxs[3], propOrigin[3];
            GetEntPropVector(entity, Prop_Data, "m_vecMins", localMins);
            GetEntPropVector(entity, Prop_Data, "m_vecMaxs", localMaxs);
            if (hasOrigin)
            {
                GetEntPropVector(entity, Prop_Send, "m_vecOrigin", propOrigin);
            }
            else
            {
                GetEntPropVector(entity, Prop_Data, "m_vecOrigin", propOrigin);
            }

            float halfX = FloatAbs(localMins[0]) > FloatAbs(localMaxs[0])
                ? FloatAbs(localMins[0]) : FloatAbs(localMaxs[0]);
            float halfY = FloatAbs(localMins[1]) > FloatAbs(localMaxs[1])
                ? FloatAbs(localMins[1]) : FloatAbs(localMaxs[1]);
            float yawAngles[3] = {0.0, 0.0, 0.0};
            bool hasAngles = HasEntProp(entity, Prop_Send, "m_angRotation");
            if (hasAngles)
            {
                GetEntPropVector(entity, Prop_Send, "m_angRotation", yawAngles);
            }
            else if (HasEntProp(entity, Prop_Data, "m_angRotation"))
            {
                GetEntPropVector(entity, Prop_Data, "m_angRotation", yawAngles);
                hasAngles = true;
            }

            float worldHalfX, worldHalfY;
            if (hasAngles)
            {
                float propForward[3], propRight[3], propUp[3];
                GetAngleVectors(yawAngles, propForward, propRight, propUp);
                worldHalfX = FloatAbs(propForward[0]) * halfX + FloatAbs(propRight[0]) * halfY;
                worldHalfY = FloatAbs(propForward[1]) * halfX + FloatAbs(propRight[1]) * halfY;
            }
            else
            {
                // Without angles, sum the horizontal half-extents so rotation cannot
                // make this fallback under-estimate the prop's occupied area.
                worldHalfX = halfX + halfY;
                worldHalfY = halfX + halfY;
            }

            propMins[0] = propOrigin[0] - worldHalfX;
            propMins[1] = propOrigin[1] - worldHalfY;
            propMins[2] = propOrigin[2] + localMins[2];
            propMaxs[0] = propOrigin[0] + worldHalfX;
            propMaxs[1] = propOrigin[1] + worldHalfY;
            propMaxs[2] = propOrigin[2] + localMaxs[2];
        }

        bool validBounds = true;
        bool overlaps = true;
        for (int axis = 0; axis < 3; axis++)
        {
            if (propMaxs[axis] <= propMins[axis])
            {
                validBounds = false;
                break;
            }
            if (candidateMaxs[axis] <= propMins[axis] || candidateMins[axis] >= propMaxs[axis])
            {
                overlaps = false;
            }
        }
        if (validBounds && overlaps)
        {
            return false;
        }
    }
    return true;
}

public bool TraceFilter_TeslaPostSpawnClearance(int entity, int contentsMask, any data)
{
    int turret = data;
    if (entity == turret)
    {
        return false;
    }
    if (turret > MaxClients && turret < RSP_MAX_ENTITIES && IsValidEntity(turret))
    {
        int owner = GetClientOfUserId(g_iBuildableOwnerUserId[turret]);
        if (entity == owner)
        {
            return false;
        }
    }
    return true;
}

public Action Hook_BuildableOnTakeDamage(int victim, int &attacker, int &inflictor,
    float &damage, int &damagetype)
{
    if (victim <= MaxClients || victim >= RSP_MAX_ENTITIES || !IsValidEntity(victim) ||
        g_iBuildableOwnerUserId[victim] == 0 || g_iBuildableType[victim] == RSP_BUILDABLE_NONE)
    {
        return Plugin_Continue;
    }

    if (g_fBuildableHealth[victim] <= 0.0 || damage <= 0.0)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    int owner = GetClientOfUserId(g_iBuildableOwnerUserId[victim]);
    bool validAttacker = attacker >= 1 && attacker <= MaxClients && IsClientInGame(attacker);
    bool validOwner = owner >= 1 && owner <= MaxClients && IsClientInGame(owner);
    bool allowTurretExplosiveDamage = (g_iBuildableType[victim] == RSP_BUILDABLE_TURRET &&
        IsTurretExplosiveDamageSource(inflictor, damagetype));

    // C4/HE/Death Bomb blast damage must be able to destroy a Tesla regardless of who
    // owns it, which team planted the bomb, or whether its original owner disconnected.
    // Ordinary direct damage retains the existing live-player/team validation.
    if (!allowTurretExplosiveDamage && (!validAttacker || !validOwner))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    int ownerTeam = validOwner ? GetClientTeam(owner) : 0;
    int attackerTeam = validAttacker ? GetClientTeam(attacker) : 0;
    if (!allowTurretExplosiveDamage &&
        ((ownerTeam != CS_TEAM_T && ownerTeam != CS_TEAM_CT) ||
         (attackerTeam != CS_TEAM_T && attackerTeam != CS_TEAM_CT)))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // Direct Tesla damage remains enemy-only. Explosive damage is intentionally allowed
    // through the protection above, including planted C4 and RSP Death Bomb.
    if (!allowTurretExplosiveDamage && g_iBuildableType[victim] == RSP_BUILDABLE_TURRET &&
        (attacker == owner || attackerTeam == ownerTeam))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    g_fBuildableHealth[victim] -= damage;
    if (g_fBuildableHealth[victim] < 0.0)
    {
        g_fBuildableHealth[victim] = 0.0;
    }
    if (HasEntProp(victim, Prop_Data, "m_iHealth"))
    {
        SetEntProp(victim, Prop_Data, "m_iHealth", RoundToCeil(g_fBuildableHealth[victim]));
    }
    if (g_fBuildableHealth[victim] <= 0.0)
    {
        RequestFrame(Frame_RemoveDestroyedBuildable, EntIndexToEntRef(victim));
    }

    // RSP maintains its own breakable HP, avoiding engine-specific prop damage scaling.
    damage = 0.0;
    return Plugin_Handled;
}

bool IsTurretExplosiveDamageSource(int inflictor, int damagetype)
{
    if ((damagetype & DMG_BLAST) != 0)
    {
        return true;
    }
    if (inflictor <= MaxClients || inflictor >= RSP_MAX_ENTITIES || !IsValidEntity(inflictor))
    {
        return false;
    }
    if (g_iRSPDeathExplosionTeam[inflictor] != 0)
    {
        return true;
    }
    char classname[32];
    GetEntityClassname(inflictor, classname, sizeof(classname));
    return StrEqual(classname, "planted_c4", false) || StrEqual(classname, "weapon_c4", false);
}

void CreateTeslaDestructionExplosion(int turret)
{
    if (turret <= MaxClients || turret >= RSP_MAX_ENTITIES || !IsValidEntity(turret) ||
        g_iBuildableType[turret] != RSP_BUILDABLE_TURRET)
    {
        return;
    }

    int ownerUserId = g_iBuildableOwnerUserId[turret];
    int owner = GetClientOfUserId(ownerUserId);
    int ownerTeam = 0;
    if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner))
    {
        ownerTeam = GetClientTeam(owner);
    }

    float explosionOrigin[3], mins[3], maxs[3];
    GetEntPropVector(turret, Prop_Send, "m_vecOrigin", explosionOrigin);
    if (GetBuildableLocalBounds(turret, mins, maxs))
    {
        // Detonate at the model's vertical center, like a grenade exploding beside the prop.
        explosionOrigin[2] += (mins[2] + maxs[2]) * 0.5;
    }

    int explosion = CreateEntityByName("env_explosion");
    if (explosion <= MaxClients || explosion >= RSP_MAX_ENTITIES || !IsValidEntity(explosion))
    {
        return;
    }

    char magnitude[16], radius[16];
    IntToString(RSP_INVENTOR_TURRET_EXPLOSION_MAGNITUDE, magnitude, sizeof(magnitude));
    IntToString(RSP_INVENTOR_TURRET_EXPLOSION_RADIUS, radius, sizeof(radius));
    DispatchKeyValue(explosion, "iMagnitude", magnitude);
    DispatchKeyValue(explosion, "iRadiusOverride", radius);
    // Keep the native fireball, smoke, sparks and scorch decal, but suppress env_explosion's
    // inconsistent particle sound. Emit the stock CS:S HE sound explicitly at the same origin.
    DispatchKeyValue(explosion, "spawnflags", "64");
    if (!DispatchSpawn(explosion) || !IsValidEntity(explosion))
    {
        if (IsValidEntity(explosion))
        {
            RemoveEntity(explosion);
        }
        return;
    }

    TeleportEntity(explosion, explosionOrigin, NULL_VECTOR, NULL_VECTOR);
    if (ownerTeam == CS_TEAM_T || ownerTeam == CS_TEAM_CT)
    {
        g_iRSPDeathExplosionTeam[explosion] = ownerTeam;
    }
    if (owner >= 1 && owner <= MaxClients && IsClientInGame(owner))
    {
        if (HasEntProp(explosion, Prop_Data, "m_hOwnerEntity"))
        {
            SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", owner);
        }
        AcceptEntityInput(explosion, "Explode", owner, owner);
    }
    else
    {
        AcceptEntityInput(explosion, "Explode", turret, turret);
    }
    EmitAmbientSound(RSP_INVENTOR_TURRET_EXPLOSION_SOUND, explosionOrigin, SOUND_FROM_WORLD,
        SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
    // Allow native explosion effects/decals to be emitted before removing the temporary entity.
    CreateTimer(0.50, Timer_RemoveExplosion, EntIndexToEntRef(explosion), TIMER_FLAG_NO_MAPCHANGE);
}

public void Frame_RemoveDestroyedBuildable(any entityRef)
{
    int entity = EntRefToEntIndex(entityRef);
    if (entity > MaxClients && entity < RSP_MAX_ENTITIES && IsValidEntity(entity) &&
        g_iBuildableOwnerUserId[entity] != 0 && g_fBuildableHealth[entity] <= 0.0)
    {
        if (g_iBuildableType[entity] == RSP_BUILDABLE_FENCE)
        {
            SpawnBuilderFenceDebris(entity);
        }
        else if (g_iBuildableType[entity] == RSP_BUILDABLE_TURRET)
        {
            CreateTeslaDestructionExplosion(entity);
        }
        RemoveBuildableEntity(entity);
    }
}

bool FindTeslaVisibleAimPoint(int turret, int target, const float beamStart[3], float aimPoint[3])
{
    float origin[3], eyePosition[3], eyeAngles[3];
    GetClientAbsOrigin(target, origin);
    GetClientEyePosition(target, eyePosition);
    GetClientEyeAngles(target, eyeAngles);
    eyeAngles[0] = 0.0;
    eyeAngles[2] = 0.0;

    float forwardVec[3], right[3], up[3];
    GetAngleVectors(eyeAngles, forwardVec, right, up);
    float points[6][3];

    // Prefer upper torso when visible, then head, shoulders, and lower torso.
    // This lets a Tesla whose antenna peeks over a hill fire at a partially exposed enemy.
    points[0][0] = origin[0];
    points[0][1] = origin[1];
    points[0][2] = origin[2] + 48.0;

    points[1][0] = eyePosition[0];
    points[1][1] = eyePosition[1];
    points[1][2] = eyePosition[2] - 2.0;

    points[2][0] = origin[0] + right[0] * 12.0;
    points[2][1] = origin[1] + right[1] * 12.0;
    points[2][2] = origin[2] + 51.0;

    points[3][0] = origin[0] - right[0] * 12.0;
    points[3][1] = origin[1] - right[1] * 12.0;
    points[3][2] = origin[2] + 51.0;

    points[4][0] = origin[0];
    points[4][1] = origin[1];
    points[4][2] = origin[2] + 58.0;

    points[5][0] = origin[0];
    points[5][1] = origin[1];
    points[5][2] = origin[2] + 36.0;

    for (int pointIndex = 0; pointIndex < sizeof(points); pointIndex++)
    {
        TR_TraceRayFilter(beamStart, points[pointIndex], MASK_SHOT, RayType_EndPoint,
            TraceFilter_BuildableLineOfSight, turret);
        bool visible = !TR_StartSolid() && !TR_AllSolid() &&
            (!TR_DidHit() || TR_GetEntityIndex() == target);
        if (!visible)
        {
            continue;
        }

        for (int axis = 0; axis < 3; axis++)
        {
            aimPoint[axis] = points[pointIndex][axis];
        }
        return true;
    }
    return false;
}

// Every Tesla shot gets its own user sound channel while the spatial origin stays explicit.
// Source identifies playing sounds by (entity, channel); using the world entity as the
// common source therefore requires a rotating channel pool to keep simultaneous Tesla shots
// from replacing one another. SourceMod reserves channels from SNDCHAN_USER_BASE upward.
int NextTeslaShotSoundChannel()
{
    static int nextChannel = SNDCHAN_USER_BASE;
    int channel = nextChannel;

    if (nextChannel >= 255)
    {
        nextChannel = SNDCHAN_USER_BASE;
    }
    else
    {
        nextChannel++;
    }

    return channel;
}

public Action Timer_BuildableTurretFire(Handle timer, any entityRef)
{
    int turret = EntRefToEntIndex(entityRef);
    if (turret <= MaxClients || turret >= RSP_MAX_ENTITIES || !IsValidEntity(turret))
    {
        return Plugin_Stop;
    }
    if (g_hBuildableTurretTimer[turret] != timer ||
        g_iBuildableType[turret] != RSP_BUILDABLE_TURRET || g_iBuildableOwnerUserId[turret] == 0)
    {
        return Plugin_Stop;
    }

    int owner = GetClientOfUserId(g_iBuildableOwnerUserId[turret]);
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner))
    {
        RemoveBuildableEntity(turret, true);
        return Plugin_Stop;
    }
    int ownerTeam = GetClientTeam(owner);
    if (ownerTeam != CS_TEAM_T && ownerTeam != CS_TEAM_CT)
    {
        RemoveBuildableEntity(turret, true);
        return Plugin_Stop;
    }

    EnsureTeslaLoopSound(turret);

    // A listen-host power grant can intentionally run before RSP has seen the current
    // round_start. Existing turrets remain active through the post-round win phase.
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive())
    {
        StopTeslaStormEffects(turret);
        return Plugin_Continue;
    }

    float beamStart[3];
    if (!GetTeslaBeamStartPosition(turret, beamStart))
    {
        StopTeslaStormEffects(turret);
        return Plugin_Continue;
    }

    // Select the closest visible hostile player OR hostile Tesla. Turrets are tracked
    // buildables and use their model center as the endpoint; they never get headshots.
    int selectedTarget = 0;
    float selectedPoint[3];
    float bestDistance = 1.0e30;
    for (int target = 1; target <= MaxClients; target++)
    {
        // A live Ghost is invisible to the Tesla and cannot shield another target.
        if (!IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
            GetClientTeam(target) == ownerTeam || g_iPower[target] == RSP_Ghost)
        {
            continue;
        }

        float targetPoint[3];
        if (!FindTeslaVisibleAimPoint(turret, target, beamStart, targetPoint))
        {
            continue;
        }
        float distance = GetVectorDistance(beamStart, targetPoint);
        if (distance >= bestDistance)
        {
            continue;
        }

        selectedTarget = target;
        bestDistance = distance;
        for (int axis = 0; axis < 3; axis++)
        {
            selectedPoint[axis] = targetPoint[axis];
        }
    }

    // Players always take priority when at least one visible hostile player is available.
    // Only fall back to hostile Tesla entities when there is no eligible player target.
    if (selectedTarget == 0)
    {
        for (int targetTurret = MaxClients + 1; targetTurret < RSP_MAX_ENTITIES; targetTurret++)
        {
            if (targetTurret == turret || !IsValidEntity(targetTurret) ||
                g_iBuildableType[targetTurret] != RSP_BUILDABLE_TURRET ||
                g_iBuildableOwnerUserId[targetTurret] == 0 || g_fBuildableHealth[targetTurret] <= 0.0)
            {
                continue;
            }

            int targetOwner = GetClientOfUserId(g_iBuildableOwnerUserId[targetTurret]);
            if (targetOwner < 1 || targetOwner > MaxClients || !IsClientInGame(targetOwner))
            {
                continue;
            }
            int targetTeam = GetClientTeam(targetOwner);
            if ((targetTeam != CS_TEAM_T && targetTeam != CS_TEAM_CT) || targetTeam == ownerTeam)
            {
                continue;
            }

            float targetOrigin[3], targetPoint[3], boundsMins[3], boundsMaxs[3];
            GetEntPropVector(targetTurret, Prop_Send, "m_vecOrigin", targetOrigin);
            targetPoint[0] = targetOrigin[0];
            targetPoint[1] = targetOrigin[1];
            if (GetBuildableLocalBounds(targetTurret, boundsMins, boundsMaxs))
            {
                targetPoint[2] = targetOrigin[2] + ((boundsMins[2] + boundsMaxs[2]) * 0.5);
            }
            else
            {
                targetPoint[2] = targetOrigin[2] + 50.0;
            }

            float distance = GetVectorDistance(beamStart, targetPoint);
            if (distance >= bestDistance)
            {
                continue;
            }

            TR_TraceRayFilter(beamStart, targetPoint, MASK_SHOT, RayType_EndPoint,
                TraceFilter_BuildableLineOfSight, turret);
            bool visible = !TR_StartSolid() && !TR_AllSolid() &&
                (!TR_DidHit() || TR_GetEntityIndex() == targetTurret);
            if (!visible)
            {
                continue;
            }

            selectedTarget = targetTurret;
            bestDistance = distance;
            for (int axis = 0; axis < 3; axis++)
            {
                selectedPoint[axis] = targetPoint[axis];
            }
        }

    }

    if (selectedTarget == 0)
    {
        // Ghosts remain untargetable and never receive Tesla damage, but a directly
        // visible Ghost makes the antenna arcs spark as if the turret sensed it nearby.
        if (HasVisibleGhostForTesla(turret, ownerTeam, beamStart))
        {
            EnsureTeslaStormEffects(turret, beamStart);
        }
        else
        {
            StopTeslaStormEffects(turret);
        }
        return Plugin_Continue;
    }

    // A real hostile target is in line of sight and this timer tick is about to fire.
    // Enable ambient lightning only for this active attack window; the hum is persistent.
    EnsureTeslaStormEffects(turret, beamStart);

    bool isPlayerTarget = selectedTarget >= 1 && selectedTarget <= MaxClients;
    bool shotIsHeadshot = false;
    if (isPlayerTarget)
    {
        int headshotChance = (g_iPower[selectedTarget] == RSP_Juggernaut &&
            g_iAssignedRound[selectedTarget] == g_iRoundSerial)
            ? RSP_INVENTOR_TURRET_JUGGERNAUT_HEADSHOT_CHANCE
            : RSP_INVENTOR_TURRET_HEADSHOT_CHANCE;
        if (GetRandomInt(1, 100) <= headshotChance)
        {
            float headPoint[3];
            GetClientEyePosition(selectedTarget, headPoint);
            headPoint[2] -= 2.0;
            TR_TraceRayFilter(beamStart, headPoint, MASK_SHOT, RayType_EndPoint,
                TraceFilter_BuildableLineOfSight, turret);
            bool headVisible = !TR_StartSolid() && !TR_AllSolid() &&
                (!TR_DidHit() || TR_GetEntityIndex() == selectedTarget);
            if (headVisible)
            {
                shotIsHeadshot = true;
                for (int axis = 0; axis < 3; axis++)
                {
                    selectedPoint[axis] = headPoint[axis];
                }
            }
        }
    }

    // One straight icy-blue laser uses the physbeam material. The decorative
    // zigzag overlay is intentionally removed to reduce transient-effect traffic.
    if (g_iTeslaMainBeamModelIndex > 0)
    {
        int laserColor[4] = {175, 230, 255, 255};
        TE_SetupBeamPoints(beamStart, selectedPoint, g_iTeslaMainBeamModelIndex, 0, 0, 0,
            RSP_INVENTOR_TURRET_BEAM_LIFE, RSP_INVENTOR_TURRET_BEAM_WIDTH,
            RSP_INVENTOR_TURRET_BEAM_END_WIDTH, 0, 0.0, laserColor, 0);
        TE_SendToAll();
    }

    // Use the world as the shared sound source but assign a rotating Source user channel
    // to every shot. This prevents one Tesla's shot from replacing another on the shared
    // world entity. The explicit origin keeps the sound spatial at the antenna, with natural
    // distance attenuation. The 121-channel pool avoids immediate channel reuse.
    int shotSoundChannel = NextTeslaShotSoundChannel();
    EmitSoundToAll(RSP_INVENTOR_TURRET_SHOT_SOUND, SOUND_FROM_WORLD, shotSoundChannel,
        RSP_INVENTOR_TURRET_SHOT_SOUND_LEVEL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL,
        -1, beamStart, NULL_VECTOR, false);

    float shotDamage = float(GetRandomInt(RSP_INVENTOR_TURRET_DAMAGE_MIN,
        RSP_INVENTOR_TURRET_DAMAGE_MAX));

    if (isPlayerTarget)
    {
        bool juggernaut = g_iPower[selectedTarget] == RSP_Juggernaut &&
            g_iAssignedRound[selectedTarget] == g_iRoundSerial;
        bool steelHead = g_iPower[selectedTarget] == RSP_SteelHead &&
            g_iAssignedRound[selectedTarget] == g_iRoundSerial;

        // Juggernaut rejects body-hit damage; Steel Head rejects the simulated headshot.
        // These two powers keep their intended hit-zone protection against Tesla as well.
        if ((juggernaut && !shotIsHeadshot) || (steelHead && shotIsHeadshot))
        {
            // The hit still needs its impact flash even though the hit-zone blocks damage.
            CreateTeslaImpactSprite(selectedPoint, selectedTarget);
            g_bTeslaHeadshotPending[selectedTarget] = false;
            g_iTeslaHeadshotRound[selectedTarget] = 0;
            g_fTeslaHeadshotTime[selectedTarget] = 0.0;
            return Plugin_Continue;
        }

        if (shotIsHeadshot)
        {
            shotDamage *= RSP_INVENTOR_TURRET_HEADSHOT_MULTIPLIER;
            g_bTeslaHeadshotPending[selectedTarget] = true;
            g_iTeslaHeadshotRound[selectedTarget] = g_iRoundSerial;
            g_fTeslaHeadshotTime[selectedTarget] = GetGameTime();
        }
        else
        {
            g_bTeslaHeadshotPending[selectedTarget] = false;
            g_iTeslaHeadshotRound[selectedTarget] = 0;
            g_fTeslaHeadshotTime[selectedTarget] = 0.0;
        }

        // Prepare the same Tesla death dissolve used previously. The marker is cleared
        // next frame if this shot does not kill the target.
        g_bTeslaDeathDissolvePending[selectedTarget] = true;
        g_iTeslaDeathDissolveRound[selectedTarget] = g_iRoundSerial;
        g_fTeslaDeathDissolveTime[selectedTarget] = GetGameTime();
        g_iTeslaDeathOwnerUserId[selectedTarget] = GetClientUserId(owner);
        StoreTeslaRagdollForceDirection(selectedTarget, beamStart, selectedPoint);
        RequestFrame(Frame_ClearTeslaDeathDissolvePending, GetClientUserId(selectedTarget));

        // Pre-mark only apparently lethal Tesla shots so the shared ragdoll handler can
        // apply the 15x impulse before the first body update. If defensive damage hooks
        // keep the victim alive, Frame_ClearTeslaDeathDissolvePending cancels this marker.
        if (shotDamage >= float(GetClientHealth(selectedTarget)))
        {
            MarkTeslaRagdollForcePending(selectedTarget, owner);
        }

        MarkTeslaHitFeedback(selectedTarget, owner, shotIsHeadshot);
        if (shotIsHeadshot)
        {
            bool hasHelmet = HasEntProp(selectedTarget, Prop_Send, "m_bHasHelmet") &&
                GetEntProp(selectedTarget, Prop_Send, "m_bHasHelmet") != 0;
            // Keep the native sound spatialized from the hit player, like normal CS:S pain audio.
            EmitGameSoundToAll(
                hasHelmet ? "Player.DamageHelmet" : "Player.DamageHeadShot", selectedTarget);
        }


        // Temporarily remove armor only for this synchronous damage application, then
        // restore the original armor value if the player survives. Damage hooks still
        // run, so Thorns and other defensive powers retain their normal behavior.
        int originalArmor = 0;
        bool hadArmorProp = HasEntProp(selectedTarget, Prop_Send, "m_ArmorValue");
        if (hadArmorProp)
        {
            originalArmor = GetEntProp(selectedTarget, Prop_Send, "m_ArmorValue");
            if (originalArmor > 0)
            {
                SetEntProp(selectedTarget, Prop_Send, "m_ArmorValue", 0);
            }
        }

        int teslaCashBefore = -1;
        if (!GetRSPAccountValue(owner, teslaCashBefore))
        {
            teslaCashBefore = -1;
        }
        g_iTeslaDeathCashCandidateOwnerUserId[selectedTarget] = GetClientUserId(owner);
        g_iTeslaDeathCashCandidateRound[selectedTarget] = g_iRoundSerial;
        g_iTeslaDeathCashBefore[selectedTarget] = teslaCashBefore;
        SDKHooks_TakeDamage(selectedTarget, turret, owner, shotDamage,
            DMG_ENERGYBEAM, -1, NULL_VECTOR, selectedPoint, false);
        // player_death consumes the candidate synchronously for lethal Tesla hits.
        g_iTeslaDeathCashCandidateOwnerUserId[selectedTarget] = 0;
        g_iTeslaDeathCashCandidateRound[selectedTarget] = 0;
        g_iTeslaDeathCashBefore[selectedTarget] = -1;

        if (hadArmorProp && originalArmor > 0 && IsClientInGame(selectedTarget) && IsPlayerAlive(selectedTarget))
        {
            int currentArmor = GetEntProp(selectedTarget, Prop_Send, "m_ArmorValue");
            if (currentArmor < originalArmor)
            {
                SetEntProp(selectedTarget, Prop_Send, "m_ArmorValue", originalArmor);
            }
        }

        // Send the temp entity after damage resolution so lethal hits retain their impact flash.
        CreateTeslaImpactSprite(selectedPoint, selectedTarget);
    }
    else
    {
        // Preserve the impact flash before damage because a destroyed buildable can be removed synchronously.
        CreateTeslaImpactSprite(selectedPoint, selectedTarget);
        // Turrets have no head hitbox: they take only normal rolled Tesla damage.
        // Hook_BuildableOnTakeDamage enforces enemy-team ownership and updates their HP.
        SDKHooks_TakeDamage(selectedTarget, turret, owner, shotDamage,
            DMG_ENERGYBEAM, -1, NULL_VECTOR, selectedPoint, false);
    }

    return Plugin_Continue;
}

bool HasVisibleGhostForTesla(int turret, int ownerTeam, const float beamStart[3])
{
    for (int ghost = 1; ghost <= MaxClients; ghost++)
    {
        if (!IsValidPlayingClient(ghost) || !IsPlayerAlive(ghost) ||
            GetClientTeam(ghost) == ownerTeam || g_iPower[ghost] != RSP_Ghost ||
            g_iAssignedRound[ghost] != g_iRoundSerial)
        {
            continue;
        }

        float origin[3], eye[3], points[3][3];
        GetClientAbsOrigin(ghost, origin);
        GetClientEyePosition(ghost, eye);
        points[0][0] = origin[0]; points[0][1] = origin[1]; points[0][2] = origin[2] + 48.0;
        points[1][0] = eye[0];   points[1][1] = eye[1];   points[1][2] = eye[2] - 2.0;
        points[2][0] = origin[0]; points[2][1] = origin[1]; points[2][2] = origin[2] + 30.0;

        for (int point = 0; point < sizeof(points); point++)
        {
            TR_TraceRayFilter(beamStart, points[point], MASK_SHOT, RayType_EndPoint,
                TraceFilter_TeslaGhostSense, turret);
            if (!TR_StartSolid() && !TR_AllSolid() &&
                (!TR_DidHit() || TR_GetEntityIndex() == ghost))
            {
                return true;
            }
        }
    }
    return false;
}

public bool TraceFilter_TeslaGhostSense(int entity, int contentsMask, any data)
{
    int turret = data;
    if (entity == turret)
    {
        return false;
    }
    if (turret > MaxClients && turret < RSP_MAX_ENTITIES && IsValidEntity(turret))
    {
        int owner = GetClientOfUserId(g_iBuildableOwnerUserId[turret]);
        if (entity == owner)
        {
            return false;
        }
    }
    return true;
}

public bool TraceFilter_BuildableLineOfSight(int entity, int contentsMask, any data)
{
    // SourceMod trace filters return false to exclude an entity from the trace.
    // Ignore the Tesla itself and every living Ghost, allowing the ray to continue
    // to a real enemy standing behind a Ghost without damaging the Ghost.
    if (entity == data)
    {
        return false;
    }
    if (entity >= 1 && entity <= MaxClients && IsClientInGame(entity) &&
        IsPlayerAlive(entity) && g_iPower[entity] == RSP_Ghost)
    {
        return false;
    }
    return true;
}

void RestoreHookPlayerControl(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))
    {
        return;
    }

    // A hook must never leave the player in a non-player movement mode or attached
    // to a camera entity. Preserve normal WALK/LADDER movement when it is already set.
    MoveType moveType = GetEntityMoveType(client);
    if (moveType == MOVETYPE_NONE || moveType == MOVETYPE_NOCLIP || moveType == MOVETYPE_OBSERVER)
    {
        SetEntityMoveType(client, MOVETYPE_WALK);
    }

    // Recover the two engine flags which can suppress regular movement or view control.
    // This power never intentionally sets either flag; the ground flag is deliberately
    // left alone so normal Source movement can recategorize ground/air state itself.
    if (HasEntProp(client, Prop_Data, "m_fFlags"))
    {
        int flags = GetEntityFlags(client);
        int restoredFlags = flags & ~(FL_FROZEN | FL_ATCONTROLS);
        if (restoredFlags != flags)
        {
            SetEntProp(client, Prop_Data, "m_fFlags", restoredFlags);
        }
    }

    SetClientViewEntity(client, client);
}

void StopHook(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    // Release all hook-owned state immediately. Do not rewrite ground flags or
    // ground entity here; Source movement recalculates contact on its next tick.
    g_bHookActive[client] = false;
    g_fHookLastDistance[client] = 0.0;
    g_fHookLastProgressTime[client] = 0.0;
    if (g_hHookTimer[client] != null)
    {
        delete g_hHookTimer[client];
        g_hHookTimer[client] = null;
    }

    RestoreHookPlayerControl(client);
}

void FinishHookPull(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    // Called from the timer itself: clear state but do not delete its current handle.
    // Leave ground-state recalculation to normal CS:S player movement.
    g_bHookActive[client] = false;
    g_hHookTimer[client] = null;
    g_fHookLastDistance[client] = 0.0;
    g_fHookLastProgressTime[client] = 0.0;

    RestoreHookPlayerControl(client);
}

void ClearAnomalyHistory(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    g_iAnomalyHistoryWriteIndex[client] = 0;
    g_fAnomalyLastRecordTime[client] = 0.0;
    for (int sample = 0; sample < RSP_ANOMALY_HISTORY_SAMPLES; sample++)
    {
        g_fAnomalyHistoryTime[client][sample] = 0.0;
        for (int axis = 0; axis < 3; axis++)
        {
            g_fAnomalyHistoryOrigin[client][sample][axis] = 0.0;
            g_fAnomalyHistoryAngles[client][sample][axis] = 0.0;
        }
    }
}

void RecordAnomalyPosition(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))
    {
        return;
    }

    float now = GetGameTime();
    if (now - g_fAnomalyLastRecordTime[client] < RSP_ANOMALY_SAMPLE_INTERVAL)
    {
        return;
    }

    int sample = g_iAnomalyHistoryWriteIndex[client];
    GetClientAbsOrigin(client, g_fAnomalyHistoryOrigin[client][sample]);
    GetClientEyeAngles(client, g_fAnomalyHistoryAngles[client][sample]);
    g_fAnomalyHistoryTime[client][sample] = now;
    g_iAnomalyHistoryWriteIndex[client] = (sample + 1) % RSP_ANOMALY_HISTORY_SAMPLES;
    g_fAnomalyLastRecordTime[client] = now;
}

public bool TraceFilter_AnomalyPosition(int entity, int contentsMask, any data)
{
    return entity != data;
}

bool IsAnomalyPositionSafe(int client, const float destination[3])
{
    // TR_PointOutsideWorld requires a mutable float[3]; preserve the const input.
    float worldCheckDestination[3];
    for (int axis = 0; axis < 3; axis++)
    {
        worldCheckDestination[axis] = destination[axis];
    }
    if (TR_PointOutsideWorld(worldCheckDestination))
    {
        return false;
    }

    float probe[3];
    probe[0] = destination[0];
    probe[1] = destination[1];
    probe[2] = destination[2] + 1.0;
    float mins[3] = {-16.0, -16.0, 0.0};
    float maxs[3] = {16.0, 16.0, 72.0};

    TR_TraceHullFilter(probe, probe, mins, maxs, MASK_PLAYERSOLID,
        TraceFilter_AnomalyPosition, client);
    return !TR_StartSolid() && !TR_AllSolid();
}

bool FindAnomalyDestination(int client, float destination[3], float angles[3])
{
    float targetTime = GetGameTime() - RSP_ANOMALY_LOOKBACK;
    if (targetTime <= 0.0)
    {
        return false;
    }

    float bestDifference = 0.55;
    int bestSample = -1;
    for (int sample = 0; sample < RSP_ANOMALY_HISTORY_SAMPLES; sample++)
    {
        float sampleTime = g_fAnomalyHistoryTime[client][sample];
        if (sampleTime <= 0.0)
        {
            continue;
        }

        float difference = FloatAbs(sampleTime - targetTime);
        if (difference > bestDifference)
        {
            continue;
        }
        if (!IsAnomalyPositionSafe(client, g_fAnomalyHistoryOrigin[client][sample]))
        {
            continue;
        }

        bestDifference = difference;
        bestSample = sample;
    }

    if (bestSample == -1)
    {
        return false;
    }

    for (int axis = 0; axis < 3; axis++)
    {
        destination[axis] = g_fAnomalyHistoryOrigin[client][bestSample][axis];
        angles[axis] = g_fAnomalyHistoryAngles[client][bestSample][axis];
    }
    return true;
}

void ActivateAnomaly(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Anomaly || g_iAssignedRound[client] != g_iRoundSerial ||
        !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client))
    {
        return;
    }

    float destination[3], angles[3];
    if (!FindAnomalyDestination(client, destination, angles))
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Brak bezpiecznej zapisanej pozycji sprzed 7 sekund."
            : "\x04[RSP]\x01 No safe position from 7 seconds ago is available.");
        return;
    }

    float stoppedVelocity[3] = {0.0, 0.0, 0.0};
    TeleportEntity(client, destination, angles, stoppedVelocity);
    ClearAnomalyHistory(client);
    StartSkillCooldown(client, RSP_ANOMALY_COOLDOWN);
    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Anomaly: wrócono do pozycji sprzed 7 sekund. Odnowienie: 15 sekund."
        : "\x04[RSP]\x01 Anomaly: returned to your position from 7 seconds ago. Cooldown: 15 seconds.");
}

public bool TraceFilter_HookSurface(int entity, int contentsMask, any data)
{
    // Ignore only the hook owner. Another player should block the ray rather than
    // allowing the hook to pass through that player and attach to a wall behind.
    return entity != data;
}

void ActivateHook(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Hook || g_iAssignedRound[client] != g_iRoundSerial ||
        !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client))
    {
        return;
    }

    float start[3], aimAngles[3];
    GetClientEyePosition(client, start);
    GetClientEyeAngles(client, aimAngles);

    // No arbitrary distance cap: the first solid surface along the view ray is
    // selected regardless of range. Existing surface/player/SKY/NODRAW filters remain.
    TR_TraceRayFilter(start, aimAngles, MASK_SOLID, RayType_Infinite, TraceFilter_HookSurface, client);
    int hitEntity = TR_GetEntityIndex();
    int surfaceFlags = TR_GetSurfaceFlags();
    if (!TR_DidHit() || TR_StartSolid() || TR_AllSolid() ||
        (surfaceFlags & SURF_SKY) != 0 || (surfaceFlags & SURF_NODRAW) != 0 ||
        (hitEntity > 0 && hitEntity <= MaxClients))
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Brak solidnej powierzchni do zaczepienia."
            : "\x04[RSP]\x01 No solid surface to attach the hook to.");
        return;
    }

    float anchor[3];
    TR_GetEndPosition(anchor);
    if (TR_PointOutsideWorld(anchor))
    {
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Brak solidnej powierzchni do zaczepienia."
            : "\x04[RSP]\x01 No solid surface to attach the hook to.");
        return;
    }

    // A valid new attachment replaces any currently active hook.
    StopHook(client);
    for (int axis = 0; axis < 3; axis++)
    {
        g_fHookAnchor[client][axis] = anchor[axis];
    }
    float playerOrigin[3];
    GetClientAbsOrigin(client, playerOrigin);
    playerOrigin[2] += RSP_HOOK_BELT_HEIGHT;
    g_fHookLastDistance[client] = GetVectorDistance(playerOrigin, anchor);
    g_fHookLastProgressTime[client] = GetGameTime();
    g_bHookActive[client] = true;
    g_hHookTimer[client] = CreateTimer(RSP_HOOK_TICK, Timer_HookPull,
        GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    if (g_hHookTimer[client] == null)
    {
        StopHook(client);
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Nie udało się uruchomić liny."
            : "\x04[RSP]\x01 The hook could not be started.");
        return;
    }

    StartSkillCooldown(client, RSP_HOOK_COOLDOWN);
    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Lina zaczepiona."
        : "\x04[RSP]\x01 Hook attached.");
}

public Action Timer_HookPull(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return Plugin_Stop;
    }
    if (g_hHookTimer[client] != timer)
    {
        return Plugin_Stop;
    }
    if (!g_bHookActive[client] || !g_bEnabled || !g_bSupportedMap ||
        !IsRSPPowerRuntimeActiveForClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Hook || g_iAssignedRound[client] != g_iRoundSerial)
    {
        FinishHookPull(client);
        return Plugin_Stop;
    }

    float origin[3], ropeStart[3], direction[3];
    GetClientAbsOrigin(client, origin);
    ropeStart[0] = origin[0];
    ropeStart[1] = origin[1];
    ropeStart[2] = origin[2] + RSP_HOOK_BELT_HEIGHT;
    direction[0] = g_fHookAnchor[client][0] - ropeStart[0];
    direction[1] = g_fHookAnchor[client][1] - ropeStart[1];
    direction[2] = g_fHookAnchor[client][2] - ropeStart[2];
    float distance = GetVectorLength(direction);
    float now = GetGameTime();

    if (g_iHookBeamModel > 0)
    {
        // Keep the proven single-layer beam and restore its clearly visible white color.
        // Only the render color changes here; hook movement and detach behavior are untouched.
        int ropeColor[4] = {255, 255, 255, 255};
        TE_SetupBeamPoints(ropeStart, g_fHookAnchor[client], g_iHookBeamModel, 0, 0, 0,
            0.08, 2.2, 2.2, 0, 0.0, ropeColor, 0);
        TE_SendToAll();
    }

    // Stop near the attachment point and guard against crossing it between timer ticks.
    float priorDistance = g_fHookLastDistance[client];
    float oneTickTravel = RSP_HOOK_PULL_SPEED * RSP_HOOK_TICK;
    bool passedEndpoint = priorDistance > 0.0 &&
        priorDistance <= RSP_HOOK_STOP_DISTANCE + oneTickTravel &&
        distance > priorDistance + 2.0;
    if (distance <= RSP_HOOK_STOP_DISTANCE || passedEndpoint)
    {
        float stoppedVelocity[3] = {0.0, 0.0, 0.0};
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, stoppedVelocity);
        FinishHookPull(client);
        return Plugin_Stop;
    }

    // Record genuine progress. If world collision prevents approach at any distance,
    // release after a short timeout instead of indefinitely suppressing movement input.
    if (distance < g_fHookLastDistance[client] - 2.0)
    {
        g_fHookLastDistance[client] = distance;
        g_fHookLastProgressTime[client] = now;
    }
    else if (now - g_fHookLastProgressTime[client] >= 0.90)
    {
        float stoppedVelocity[3] = {0.0, 0.0, 0.0};
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, stoppedVelocity);
        FinishHookPull(client);
        return Plugin_Stop;
    }

    NormalizeVector(direction, direction);

    // Match the Source SDK grappling-hook approach: pull along the real anchor vector.
    // Do not clamp the rope angle to an artificial upward ratio; vertical lift now
    // follows the actual anchor height and horizontal distance.
    float pullSpeed = RSP_HOOK_PULL_SPEED;
    if (distance < 240.0)
    {
        float approach = (distance - RSP_HOOK_STOP_DISTANCE) /
            (240.0 - RSP_HOOK_STOP_DISTANCE);
        if (approach < 0.0)
        {
            approach = 0.0;
        }
        pullSpeed = 100.0 + ((RSP_HOOK_PULL_SPEED - 100.0) * approach);
    }

    // A rising rope must detach the player from the floor so upward velocity is honored.
    // We leave the vector itself untouched so the player travels at the actual rope angle.
    if (direction[2] > 0.01 && (GetEntityFlags(client) & FL_ONGROUND) != 0)
    {
        if (HasEntProp(client, Prop_Data, "m_hGroundEntity"))
        {
            SetEntPropEnt(client, Prop_Data, "m_hGroundEntity", -1);
        }
        SetEntProp(client, Prop_Data, "m_fFlags", GetEntityFlags(client) & ~FL_ONGROUND);
    }

    ScaleVector(direction, pullSpeed);
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, direction);
    return Plugin_Continue;
}

bool TraceFilter_ReplicaPlacement(int entity, int contentsMask, any data)
{
    // Ignore only the owner: walls, props, and other players must block placement.
    return entity != data;
}

public void Frame_ApplyReplicaIdleAnimation(any entityRef)
{
    int replica = EntRefToEntIndex(entityRef);
    if (replica <= MaxClients || replica >= RSP_MAX_ENTITIES || !IsValidEntity(replica) ||
        g_iReplicaOwnerUserId[replica] == 0 || g_bReplicaPendingRemoval[replica])
    {
        return;
    }

    // Reassert the one known-good CS:S player-model sequence on the next frame.
    SetVariantString("idle_lower");
    AcceptEntityInput(replica, "SetAnimation", replica, replica, 0);

}

public Action Hook_ReplicaOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (victim <= MaxClients || victim >= RSP_MAX_ENTITIES || !IsValidEntity(victim) ||
        g_iReplicaOwnerUserId[victim] == 0)
    {
        return Plugin_Continue;
    }

    if (g_bReplicaPendingRemoval[victim] || g_fReplicaHealth[victim] <= 0.0 || damage <= 0.0)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // Replica protection is team-based, not mp_friendlyfire-based: only an opposing
    // player may damage its hidden HP. The owner, teammates, world, and non-player
    // damage sources cannot destroy it or trigger reflected damage.
    int ownerUserId = g_iReplicaOwnerUserId[victim];
    int owner = GetClientOfUserId(ownerUserId);
    bool validOwner = owner >= 1 && owner <= MaxClients && IsClientInGame(owner);
    bool validAttacker = attacker >= 1 && attacker <= MaxClients && IsClientInGame(attacker);
    if (!validOwner || !validAttacker || GetClientUserId(attacker) == ownerUserId)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    int ownerTeam = GetClientTeam(owner);
    int attackerTeam = GetClientTeam(attacker);
    bool validPlayingTeams = (ownerTeam == CS_TEAM_T || ownerTeam == CS_TEAM_CT) &&
        (attackerTeam == CS_TEAM_T || attackerTeam == CS_TEAM_CT);
    if (!validPlayingTeams || attackerTeam == ownerTeam)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    float hitDamage = damage;
    g_fReplicaHealth[victim] -= hitDamage;
    float healthRemaining = g_fReplicaHealth[victim];
    if (healthRemaining < 0.0) healthRemaining = 0.0;
    if (HasEntProp(victim, Prop_Data, "m_iHealth"))
    {
        SetEntProp(victim, Prop_Data, "m_iHealth", RoundToCeil(healthRemaining));
    }

    // Reflect exactly the accepted enemy hit, even if mp_friendlyfire is disabled.
    // DMG_GENERIC avoids armor changing the reflected amount; damage remains direct.
    SDKHooks_TakeDamage(attacker, victim, attacker, hitDamage, DMG_GENERIC, -1);

    if (healthRemaining <= 0.0)
    {
        g_bReplicaPendingRemoval[victim] = true;
        RequestFrame(Frame_RemoveDestroyedReplica, EntIndexToEntRef(victim));
    }

    // We maintain hidden custom HP, so suppress the prop's native damage processing.
    damage = 0.0;
    return Plugin_Handled;
}

void RemoveReplicaEntity(int replica)
{
    if (replica <= MaxClients || replica >= RSP_MAX_ENTITIES || !IsValidEntity(replica))
    {
        return;
    }

    RemoveEntity(replica);
}

public void Frame_RemoveDestroyedReplica(any entityRef)
{
    int entity = EntRefToEntIndex(entityRef);
    if (entity > MaxClients && entity < RSP_MAX_ENTITIES && IsValidEntity(entity) &&
        g_iReplicaOwnerUserId[entity] != 0 && g_bReplicaPendingRemoval[entity])
    {
        RemoveReplicaEntity(entity);
    }
}

void ClearReplicaEntitiesForOwner(int ownerUserId)
{
    if (ownerUserId <= 0)
    {
        return;
    }

    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iReplicaOwnerUserId[entity] == ownerUserId && IsValidEntity(entity))
        {
            RemoveReplicaEntity(entity);
        }
    }
}

void ClearAllReplicaEntities()
{
    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iReplicaOwnerUserId[entity] == 0)
        {
            continue;
        }

        if (IsValidEntity(entity))
        {
            RemoveReplicaEntity(entity);
        }
        else
        {
            // An entity can disappear before its tracked cleanup frame runs. Clear
            // the orphaned bookkeeping as well, so a reused entity index can't inherit it.
            g_iReplicaOwnerUserId[entity] = 0;
            g_fReplicaHealth[entity] = 0.0;
            g_bReplicaPendingRemoval[entity] = false;
        }
    }
}

void ClearRoundScopedExplosionEntities()
{
    // Explosive Bullets and Explosion on Death create env_explosion entities that
    // normally self-remove after 0.20 seconds. A zero-delay restart can reach
    // round_start before that cleanup timer; kill only entities tagged by RSP.
    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        if (g_iRSPDeathExplosionTeam[entity] == 0)
        {
            continue;
        }

        if (IsValidEntity(entity))
        {
            AcceptEntityInput(entity, "Kill");
        }
        g_iRSPDeathExplosionTeam[entity] = 0;
    }
}

void ActivateExplodingBarrel(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_ExplodingBarrel || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    bool polish = IsPolishClient(client);
    if (g_iExplodingBarrelModelIndex <= 0)
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Model wybuchowej beczki nie jest dostępny."
            : "\x04[RSP]\x01 The explosive barrel model is unavailable.");
        return;
    }

    float start[3], angles[3], direction[3], end[3];
    GetClientEyePosition(client, start);
    GetClientEyeAngles(client, angles);
    GetAngleVectors(angles, direction, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(direction, 4096.0);
    AddVectors(start, direction, end);

    // Match prop_physics_create aim placement: trace from the eye to the target,
    // ignoring player hitboxes but retaining solid world geometry and props.
    TR_TraceRayFilter(start, end, MASK_SOLID, RayType_EndPoint,
        TraceFilter_ExplodingBarrelAim, client);
    if (!TR_DidHit() || TR_StartSolid())
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Wyceluj w powierzchnię, na której można postawić beczkę."
            : "\x04[RSP]\x01 Aim at a surface where the barrel can be placed.");
        return;
    }

    float origin[3], normal[3];
    TR_GetEndPosition(origin);
    TR_GetPlaneNormal(INVALID_HANDLE, normal);
    // A small normal offset keeps the prop from spawning inside the traced surface.
    for (int axis = 0; axis < 3; axis++)
    {
        origin[axis] += normal[axis] * 3.0;
    }

    int barrel = CreateEntityByName("prop_physics");
    if (barrel == -1 || !IsValidEntity(barrel))
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Nie udało się utworzyć beczki. Spróbuj ponownie."
            : "\x04[RSP]\x01 The barrel could not be created. Try again.");
        return;
    }

    char originValue[96];
    Format(originValue, sizeof(originValue), "%.1f %.1f %.1f", origin[0], origin[1], origin[2]);
    DispatchKeyValue(barrel, "model", RSP_EXPLODING_BARREL_MODEL);
    DispatchKeyValue(barrel, "origin", originValue);
    DispatchKeyValue(barrel, "angles", "0 0 0");
    // Use a plain prop_physics with the stock explosive oil-drum model, matching
    // prop_physics_create. Do not override native health or explosion keyvalues: the
    // model/entity's built-in damage behavior must remain under the engine's control.

    if (!DispatchSpawn(barrel) || !IsValidEntity(barrel))
    {
        if (IsValidEntity(barrel))
        {
            RemoveEntity(barrel);
        }
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Nie udało się utworzyć beczki. Spróbuj ponownie."
            : "\x04[RSP]\x01 The barrel could not be created. Try again.");
        return;
    }

    ActivateEntity(barrel);
    AcceptEntityInput(barrel, "Wake");

    // Two successful placements form one cooldown cycle. The 10-second cooldown starts
    // only after the second barrel has actually spawned; failed placements never consume
    // a count. Leaving/reassigning the power resets only the owner's placement cycle,
    // never the already spawned world barrels.
    g_iExplodingBarrelsPlacedTowardCooldown[client]++;
    if (g_iExplodingBarrelsPlacedTowardCooldown[client] >= RSP_EXPLODING_BARRELS_PER_COOLDOWN)
    {
        g_iExplodingBarrelsPlacedTowardCooldown[client] = 0;
        StartSkillCooldown(client, RSP_EXPLODING_BARREL_COOLDOWN);
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Postawiono drugą beczkę. Odnowienie: 10 sekund."
            : "\x04[RSP]\x01 Second barrel placed. Cooldown: 10 seconds.");
    }
    else
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Postawiono pierwszą beczkę. Możesz postawić jeszcze jedną przed odnowieniem."
            : "\x04[RSP]\x01 First barrel placed. You can place one more before cooldown starts.");
    }
}

public bool TraceFilter_ExplodingBarrelAim(int entity, int contentsMask, any data)
{
    if (entity == data)
    {
        return false;
    }
    // Do not place a barrel on a player. Continue the trace to solid geometry.
    if (entity >= 1 && entity <= MaxClients)
    {
        return false;
    }
    return true;
}

void ActivateDamager(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Damager || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    int ownerTeam = GetClientTeam(client);
    int targets[MAXPLAYERS + 1];
    int targetCount = 0;
    for (int target = 1; target <= MaxClients; target++)
    {
        if (target == client || !IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
            GetClientTeam(target) == ownerTeam)
        {
            continue;
        }
        targets[targetCount++] = target;
    }

    if (targetCount == 0)
    {
        switch (GetRSPClientLanguage(client))
        {
            case RSP_LANG_PL: PrintToChat(client, "\x04[RSP]\x01 Brak żywych przeciwników do trafienia.");
            default: PrintToChat(client, "\x04[RSP]\x01 No living enemies to hit.");
        }
        return;
    }

    // Save the account before any native weapon-based kill rewards are generated.
    // A single next-frame correction then applies the fixed reward for every Damager kill.
    g_iDamagerCashOwnerUserId[client] = GetClientUserId(client);
    g_iDamagerCashBefore[client] = -1;
    if (HasEntProp(client, Prop_Send, "m_iAccount"))
    {
        g_iDamagerCashBefore[client] = GetEntProp(client, Prop_Send, "m_iAccount");
    }
    else if (HasEntProp(client, Prop_Data, "m_iAccount"))
    {
        g_iDamagerCashBefore[client] = GetEntProp(client, Prop_Data, "m_iAccount");
    }
    g_iDamagerCashRound[client] = g_iRoundSerial;
    g_iDamagerKillCount[client] = 0;
    g_bDamagerCashCorrectionQueued[client] = false;

    // Snapshot all targets before applying damage: one target's death or retaliation
    // cannot prevent the already-triggered ability from reaching the remaining enemies.
    StartSkillCooldown(client, RSP_DAMAGER_COOLDOWN);
    int affectedCount = 0;
    int ownerUserId = GetClientUserId(client);
    for (int i = 0; i < targetCount; i++)
    {
        int target = targets[i];
        if (!IsClientInGame(target) || !IsPlayerAlive(target) || GetClientTeam(target) == ownerTeam)
        {
            continue;
        }

        // Temporarily remove only native CS:S armor for this damage call. Restore it
        // after nonlethal damage so Damager damages health directly without consuming armor.
        int targetArmor = -1;
        bool hasArmorProp = HasEntProp(target, Prop_Send, "m_ArmorValue");
        if (hasArmorProp)
        {
            targetArmor = GetEntProp(target, Prop_Send, "m_ArmorValue");
            if (targetArmor > 0)
            {
                SetEntProp(target, Prop_Send, "m_ArmorValue", 0);
            }
        }

        // player_death can fire synchronously inside SDKHooks_TakeDamage, so set
        // attribution before applying the damage and clear it if the target survives.
        g_bDamagerDeathPending[target] = true;
        g_iDamagerDeathOwnerUserId[target] = ownerUserId;
        g_iDamagerDeathRound[target] = g_iRoundSerial;
        affectedCount++;
        SDKHooks_TakeDamage(target, client, client, RSP_DAMAGER_DAMAGE, DMG_GENERIC);

        if (IsClientInGame(target) && IsPlayerAlive(target) && hasArmorProp && targetArmor >= 0)
        {
            SetEntProp(target, Prop_Send, "m_ArmorValue", targetArmor);
        }

        if (g_bDamagerDeathPending[target] &&
            g_iDamagerDeathOwnerUserId[target] == ownerUserId &&
            g_iDamagerDeathRound[target] == g_iRoundSerial)
        {
            g_bDamagerDeathPending[target] = false;
            g_iDamagerDeathOwnerUserId[target] = 0;
            g_iDamagerDeathRound[target] = 0;
        }
    }

    if (affectedCount > 0)
    {
        int damage = RoundToNearest(RSP_DAMAGER_DAMAGE);
        switch (GetRSPClientLanguage(client))
        {
            case RSP_LANG_PL:
                PrintToChat(client, "\x04[RSP]\x01 Damager aktywowany: zadałeś %d obrażeń wszystkim żywym przeciwnikom.", damage);
            default:
                PrintToChat(client, "\x04[RSP]\x01 Damager activated: %d damage to all living enemies.", damage);
        }
    }

    // No kill means no delayed correction is needed; never leave stale activation state.
    if (g_iDamagerKillCount[client] == 0 && !g_bDamagerCashCorrectionQueued[client])
    {
        g_iDamagerCashOwnerUserId[client] = 0;
        g_iDamagerCashBefore[client] = -1;
        g_iDamagerCashRound[client] = 0;
    }
}

void ActivateGodMode(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_GodMode || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    g_fGodModeUntil[client] = GetGameTime() + RSP_GODMODE_DURATION;
    StartSkillCooldown(client, RSP_GODMODE_COOLDOWN);
    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 God Mode aktywny przez 3,5 s."
        : "\x04[RSP]\x01 God Mode is active for 3.5 s.");
}

static const char g_sRandomPrimaryWeapons[][] =
{
    "weapon_ak47", "weapon_m4a1", "weapon_aug", "weapon_sg552", "weapon_awp",
    "weapon_scout", "weapon_g3sg1", "weapon_sg550", "weapon_galil", "weapon_famas",
    "weapon_m249", "weapon_p90", "weapon_mp5navy", "weapon_ump45", "weapon_tmp",
    "weapon_mac10", "weapon_m3", "weapon_xm1014"
};

static const char g_sRandomSecondaryWeapons[][] =
{
    "weapon_usp", "weapon_glock", "weapon_p228", "weapon_deagle", "weapon_elite", "weapon_fiveseven"
};

void ActivateRandomWeapon(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_RandomWeapon || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    int slot = GetRandomInt(0, 1);
    char weaponClass[32];
    if (slot == 0)
    {
        int index = GetRandomInt(0, sizeof(g_sRandomPrimaryWeapons) - 1);
        strcopy(weaponClass, sizeof(weaponClass), g_sRandomPrimaryWeapons[index]);
    }
    else
    {
        int index = GetRandomInt(0, sizeof(g_sRandomSecondaryWeapons) - 1);
        strcopy(weaponClass, sizeof(weaponClass), g_sRandomSecondaryWeapons[index]);
    }

    int oldWeapon = GetPlayerWeaponSlot(client, slot);
    bool oldWeaponDetached = false;
    if (oldWeapon > MaxClients && IsValidEntity(oldWeapon))
    {
        if (!RemovePlayerItem(client, oldWeapon))
        {
            PrintToChat(client, IsPolishClient(client)
                ? "\x04[RSP]\x01 Nie udało się wymienić broni. Spróbuj ponownie."
                : "\x04[RSP]\x01 The weapon could not be replaced. Try again.");
            return;
        }
        oldWeaponDetached = true;
    }

    int newWeapon = GivePlayerItem(client, weaponClass);
    if (newWeapon <= MaxClients || !IsValidEntity(newWeapon))
    {
        if (oldWeaponDetached && IsValidEntity(oldWeapon))
        {
            EquipPlayerWeapon(client, oldWeapon);
        }
        PrintToChat(client, IsPolishClient(client)
            ? "\x04[RSP]\x01 Nie udało się przyznać losowej broni. Spróbuj ponownie."
            : "\x04[RSP]\x01 Could not grant a random weapon. Try again.");
        return;
    }

    if (oldWeaponDetached && IsValidEntity(oldWeapon))
    {
        AcceptEntityInput(oldWeapon, "Kill");
    }
    EquipPlayerWeapon(client, newWeapon);
    SetRandomWeaponShotgunReserveAmmo(client, newWeapon);
    StartSkillCooldown(client, RSP_RANDOM_WEAPON_COOLDOWN);
    PrintToChat(client, IsPolishClient(client)
        ? "\x04[RSP]\x01 Otrzymano losową broń."
        : "\x04[RSP]\x01 You received a random weapon.");
}

void SetRandomWeaponShotgunReserveAmmo(int client, int weapon)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) ||
        weapon <= MaxClients || !IsValidEntity(weapon) ||
        !HasEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType") ||
        !HasEntProp(client, Prop_Send, "m_iAmmo"))
    {
        return;
    }

    char classname[64];
    GetEntityClassname(weapon, classname, sizeof(classname));
    if (!StrEqual(classname, "weapon_m3", false) &&
        !StrEqual(classname, "weapon_xm1014", false))
    {
        return;
    }

    int ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if (ammoType < 0 || ammoType >= 32)
    {
        return;
    }

    // CSS's normal reserve for both shotguns is 32 shells. Giving the entity directly
    // does not always populate the player's reserve ammo pool, so set the real ammo slot.
    SetEntProp(client, Prop_Send, "m_iAmmo", 32, 4, ammoType);
}


bool IsRSPStrippableWeapon(int weapon)
{
    if (weapon <= MaxClients || !IsValidEntity(weapon))
    {
        return false;
    }

    char classname[64];
    GetEntityClassname(weapon, classname, sizeof(classname));
    return IsRSPFirearmEventWeapon(classname);
}

bool HasStrippableWeapons(int target)
{
    if (target < 1 || target > MaxClients || !IsClientInGame(target) || !IsPlayerAlive(target))
        return false;
    return IsRSPStrippableWeapon(GetPlayerWeaponSlot(target, 0)) ||
        IsRSPStrippableWeapon(GetPlayerWeaponSlot(target, 1));
}

int StripWeaponsFromPlayer(int target, int owner)
{
    if (target < 1 || target > MaxClients || owner < 1 || owner > MaxClients ||
        !IsClientInGame(target) || !IsClientInGame(owner) ||
        !IsPlayerAlive(target) || !IsPlayerAlive(owner))
        return 0;

    float origin[3], angles[3], forwardVec[3], right[3], up[3];
    float velocity[3] = {0.0, 0.0, 0.0};
    GetClientAbsOrigin(owner, origin);
    GetClientEyeAngles(owner, angles);
    GetAngleVectors(angles, forwardVec, right, up);

    forwardVec[2] = 0.0;
    right[2] = 0.0;
    if (GetVectorLength(forwardVec) < 0.01)
    {
        forwardVec[0] = 1.0;
        forwardVec[1] = 0.0;
    }
    NormalizeVector(forwardVec, forwardVec);
    if (GetVectorLength(right) < 0.01)
    {
        right[0] = -forwardVec[1];
        right[1] = forwardVec[0];
    }
    NormalizeVector(right, right);

    int dropped = 0;
    for (int slot = 0; slot <= 1; slot++)
    {
        int weapon = GetPlayerWeaponSlot(target, slot);
        if (!IsRSPStrippableWeapon(weapon))
            continue;

        float pos[3];
        float lateralOffset = (slot == 0) ? -56.0 : 56.0;
        pos[0] = origin[0] + forwardVec[0] * 24.0 + right[0] * lateralOffset;
        pos[1] = origin[1] + forwardVec[1] * 24.0 + right[1] * lateralOffset;
        pos[2] = origin[2] + 8.0;

        // SDKHooks_DropWeapon returns void. It drops this exact entity; it does not
        // clone it or put it into the activator's inventory.
        SDKHooks_DropWeapon(target, weapon, pos, velocity);
        dropped++;
    }

    if (dropped > 0 && IsClientInGame(target) && IsPlayerAlive(target))
        RequestFrame(Frame_SelectKnifeAfterStrip, GetClientUserId(target));

    return dropped;
}

void Frame_SelectKnifeAfterStrip(any userid)
{
    int client = GetClientOfUserId(userid);
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client))
    {
        return;
    }

    int knife = GetPlayerWeaponSlot(client, 2);
    if (knife <= MaxClients || !IsValidEntity(knife))
    {
        return;
    }

    char classname[32];
    GetEntityClassname(knife, classname, sizeof(classname));
    if (StrEqual(classname, "weapon_knife", false))
    {
        FakeClientCommand(client, "use weapon_knife");
    }
}

void ActivateStripWeapons(int client)
{
    if (!IsValidPlayingClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_StripWeapons || g_iAssignedRound[client] != g_iRoundSerial)
    {
        return;
    }

    int eligible[MAXPLAYERS + 1];
    int count = 0;
    int myTeam = GetClientTeam(client);
    for (int target = 1; target <= MaxClients; target++)
    {
        if (target == client || !IsValidPlayingClient(target) || !IsPlayerAlive(target) ||
            GetClientTeam(target) == myTeam || !HasStrippableWeapons(target))
        {
            continue;
        }
        eligible[count++] = target;
    }

    bool polish = IsPolishClient(client);
    if (count == 0)
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Brak przeciwników z bronią główną lub pistoletem."
            : "\x04[RSP]\x01 No living enemy has a primary weapon or pistol to steal.");
        return;
    }

    int target = eligible[GetRandomInt(0, count - 1)];
    int removed = StripWeaponsFromPlayer(target, client);
    if (removed <= 0)
    {
        PrintToChat(client, polish
            ? "\x04[RSP]\x01 Nie udało się ukraść broni. Spróbuj ponownie."
            : "\x04[RSP]\x01 Weapon theft failed. Try again.");
        return;
    }

    StartSkillCooldown(client, RSP_STRIP_WEAPONS_COOLDOWN);
    PrintToChat(client, polish
        ? "\x04[RSP]\x01 Ukradłeś broń główną i pistolet przeciwnika. Upuszczono je obok Ciebie."
        : "\x04[RSP]\x01 You stole an enemy's primary weapon and pistol. They were dropped beside you.");
}

bool FindSafeSwapPosition(int player, const float desiredOrigin[3], int anchorClient,
    int ignoreA, int ignoreB, int avoidPlayer, const float avoidOrigin[3], float safeOrigin[3])
{
    if (!IsValidPlayingClient(player) || !IsPlayerAlive(player))
    {
        return false;
    }

    float candidate[3];
    for (int axis = 0; axis < 3; axis++)
    {
        candidate[axis] = desiredOrigin[axis];
    }

    if (IsSwapHullPositionClear(player, candidate, ignoreA, ignoreB) &&
        (avoidPlayer == 0 || SwapHullsAreSeparated(player, candidate, avoidPlayer, avoidOrigin)))
    {
        for (int axis = 0; axis < 3; axis++) safeOrigin[axis] = candidate[axis];
        return true;
    }

    // If the exact destination is too tight for the receiving player's hull,
    // search nearby positions in expanding rings while retaining the same height.
    static const float radii[7] = {16.0, 24.0, 32.0, 40.0, 48.0, 56.0, 64.0};
    for (int ring = 0; ring < sizeof(radii); ring++)
    {
        float radius = radii[ring];
        for (int direction = 0; direction < 8; direction++)
        {
            float radians = float(direction) * 0.7853981633974483;
            candidate[0] = desiredOrigin[0] + Cosine(radians) * radius;
            candidate[1] = desiredOrigin[1] + Sine(radians) * radius;
            candidate[2] = desiredOrigin[2];

            if (!IsSwapHullPositionClear(player, candidate, ignoreA, ignoreB))
            {
                continue;
            }

            // If the anchor player was standing on the ground, only accept a
            // fallback offset with nearby support. Exact original positions are
            // tested above and may legitimately be airborne.
            if (anchorClient >= 1 && anchorClient <= MaxClients &&
                IsClientInGame(anchorClient) && IsPlayerAlive(anchorClient) &&
                (GetEntityFlags(anchorClient) & FL_ONGROUND) != 0 &&
                !HasSwapGroundSupport(candidate, ignoreA, ignoreB))
            {
                continue;
            }

            if (avoidPlayer != 0 &&
                !SwapHullsAreSeparated(player, candidate, avoidPlayer, avoidOrigin))
            {
                continue;
            }

            for (int axis = 0; axis < 3; axis++) safeOrigin[axis] = candidate[axis];
            return true;
        }
    }

    return false;
}

bool IsSwapHullPositionClear(int player, const float origin[3], int ignoreA, int ignoreB)
{
    if (!IsValidPlayingClient(player) || !IsPlayerAlive(player))
    {
        return false;
    }

    float point[3];
    for (int axis = 0; axis < 3; axis++) point[axis] = origin[axis];
    if (TR_PointOutsideWorld(point))
    {
        return false;
    }

    float mins[3], maxs[3];
    GetClientMins(player, mins);
    GetClientMaxs(player, maxs);

    // Pack both client indexes into the filter data. The two players being
    // swapped are ignored during collision checks because they will vacate the
    // destination; world geometry, props, and all other players still block it.
    int filterData = (ignoreA << 16) | (ignoreB & 0xFFFF);
    TR_TraceHullFilter(point, point, mins, maxs, MASK_PLAYERSOLID,
        TraceFilter_SwapParticipants, filterData);

    return !TR_StartSolid() && !TR_AllSolid();
}

bool HasSwapGroundSupport(const float origin[3], int ignoreA, int ignoreB)
{
    float start[3], end[3];
    for (int axis = 0; axis < 3; axis++)
    {
        start[axis] = origin[axis];
        end[axis] = origin[axis];
    }
    start[2] += 4.0;
    end[2] -= 10.0;

    int filterData = (ignoreA << 16) | (ignoreB & 0xFFFF);
    TR_TraceRayFilter(start, end, MASK_PLAYERSOLID, RayType_EndPoint,
        TraceFilter_SwapParticipants, filterData);
    return TR_DidHit() && !TR_StartSolid();
}

public bool TraceFilter_SwapParticipants(int entity, int contentsMask, any data)
{
    int ignoreA = (data >> 16) & 0xFFFF;
    int ignoreB = data & 0xFFFF;
    if (entity == ignoreA || entity == ignoreB)
    {
        return false;
    }
    return true;
}

bool SwapHullsAreSeparated(int clientA, const float originA[3], int clientB, const float originB[3])
{
    if (clientA < 1 || clientA > MaxClients || clientB < 1 || clientB > MaxClients ||
        !IsClientInGame(clientA) || !IsClientInGame(clientB))
    {
        return false;
    }

    float minsA[3], maxsA[3], minsB[3], maxsB[3];
    GetClientMins(clientA, minsA);
    GetClientMaxs(clientA, maxsA);
    GetClientMins(clientB, minsB);
    GetClientMaxs(clientB, maxsB);

    for (int axis = 0; axis < 3; axis++)
    {
        float minA = originA[axis] + minsA[axis];
        float maxA = originA[axis] + maxsA[axis];
        float minB = originB[axis] + minsB[axis];
        float maxB = originB[axis] + maxsB[axis];

        if (maxA <= minB || maxB <= minA)
        {
            return true;
        }
    }
    return false;
}

public Action Timer_ReZombieRespawn(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client >= 1 && client <= MaxClients && g_hZombieRespawnTimer[client] == timer)
    {
        g_hZombieRespawnTimer[client] = null;
    }

    if (!g_bEnabled || !g_bSupportedMap || g_bRoundEnding || !IsRSPPowerRuntimeActiveForClient(client) ||
        client < 1 || client > MaxClients || !IsClientInGame(client) ||
        !g_bZombieRespawnPending[client] || g_iZombieRespawnRound[client] != g_iRoundSerial ||
        !IsValidPlayingClient(client))
    {
        if (client >= 1 && client <= MaxClients)
        {
            bool failedCurrentRoundZombie = g_bZombieRespawnPending[client] &&
                g_iZombieRespawnRound[client] == g_iRoundSerial;
            int failedZombieTeam = IsClientInGame(client) ? GetClientTeam(client) : 0;
            g_bZombieRespawnPending[client] = false;
            g_iZombieRespawnRound[client] = 0;
            g_iZombieRespawnAttempts[client] = 0;
            // If this was the last pending respawn, do not leave an already-held
            // elimination win stuck after the Zombie callback abandons the respawn.
            if (failedCurrentRoundZombie)
            {
                EndRoundIfRespawnFailureLeavesTeamEliminated(failedZombieTeam);
            }
        }
        return Plugin_Stop;
    }

    // CS_RespawnPlayer may finish immediately or on a later frame. If the player
    // is already alive when a retry timer runs, finalize the zombie instead of
    // treating the successful respawn as an invalid/dead client.
    if (IsPlayerAlive(client))
    {
        CompleteZombieRespawn(client);
        return Plugin_Stop;
    }

    g_iZombieRespawnAttempts[client]++;
    PreservePlayerRagdollBeforeRespawn(client);
    CS_RespawnPlayer(client);
    if (IsPlayerAlive(client))
    {
        CompleteZombieRespawn(client);
        return Plugin_Stop;
    }

    if (g_iZombieRespawnAttempts[client] < RSP_ZOMBIE_RESPAWN_RETRIES)
    {
        Handle retryTimer = CreateTimer(RSP_ZOMBIE_RETRY_DELAY,
            Timer_ReZombieRespawn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
        if (retryTimer != null)
        {
            g_hZombieRespawnTimer[client] = retryTimer;
            return Plugin_Stop;
        }
        // A retry timer could not be scheduled, so don't leave Zombie pending forever.
    }

    int zombieTeam = GetClientTeam(client);
    g_bZombieRespawnPending[client] = false;
    g_iZombieRespawnRound[client] = 0;
    g_iZombieRespawnAttempts[client] = 0;

    // Failed Zombie respawn must release only this power's pending elimination hold.
    EndRoundIfRespawnFailureLeavesTeamEliminated(zombieTeam);
    return Plugin_Stop;
}

void CompleteZombieRespawn(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) ||
        !g_bZombieRespawnPending[client] || g_iZombieRespawnRound[client] != g_iRoundSerial)
    {
        return;
    }

    g_bZombieRespawnPending[client] = false;
    g_iZombieRespawnRound[client] = 0;
    g_iZombieRespawnAttempts[client] = 0;
    g_iPower[client] = RSP_Zombie;
    g_iAssignedRound[client] = g_iRoundSerial;
    g_iZombieLoadoutRound[client] = g_iRoundSerial;
    RequestFrame(Frame_ApplyZombieLoadout, GetClientUserId(client));
}

bool HasAlivePlayerOnTeam(int team)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsValidPlayingClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == team)
        {
            return true;
        }
    }
    return false;
}

bool HasPendingRespawnOnTeam(int team)
{
    if (team != CS_TEAM_T && team != CS_TEAM_CT)
    {
        return false;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsValidPlayingClient(client) || GetClientTeam(client) != team)
        {
            continue;
        }

        if ((g_bZombieRespawnPending[client] && g_iZombieRespawnRound[client] == g_iRoundSerial) ||
            (g_bPowerRespawnPending[client] && g_iPowerRespawnRound[client] == g_iRoundSerial))
        {
            return true;
        }
    }
    return false;
}

// Detect a player in the lethal-death transition before Event_PlayerDeath has
// installed the actual pending timer. CS_OnTerminateRound can run on that edge
// first, especially for bots; holding on the still-assigned power closes the race.
bool HasEligibleUnqueuedRespawnOnTeam(int team)
{
    if (team != CS_TEAM_T && team != CS_TEAM_CT)
    {
        return false;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsValidPlayingClient(client) || GetClientTeam(client) != team ||
            g_iAssignedRound[client] != g_iRoundSerial)
        {
            continue;
        }

        // Only recognize players already entering a death transition. A live player
        // carrying one of these powers must not delay an unrelated termination.
        if (IsPlayerAlive(client) && GetClientHealth(client) > 0)
        {
            continue;
        }

        if ((g_iPower[client] == RSP_Resurrection && !g_bResurrectionUsedThisRound[client]) ||
            (g_iPower[client] == RSP_Phoenix && !g_bPhoenixUsedThisRound[client]) ||
            (g_iPower[client] == RSP_Zombie && !g_bZombieUsedThisRound[client]))
        {
            return true;
        }
    }

    return false;
}

// Cancels all pending life restorations after the engine has accepted round_end.
// A timer must never spawn a player during the intermission just because the next
// round_start has a long mp_round_restart_delay.
void CancelPendingRespawnsAtRoundEnd()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        CancelPowerRespawn(client);

        if (g_hZombieRespawnTimer[client] != null)
        {
            delete g_hZombieRespawnTimer[client];
            g_hZombieRespawnTimer[client] = null;
        }
        g_bZombieRespawnPending[client] = false;
        g_iZombieRespawnRound[client] = 0;
        g_iZombieRespawnAttempts[client] = 0;
    }
}

bool HasPlantedBombObjective()
{
    int bomb = -1;
    while ((bomb = FindEntityByClassname(bomb, "planted_c4")) != -1)
    {
        if (IsValidEntity(bomb))
        {
            return true;
        }
    }
    return false;
}

float GetRSPRoundRestartDelay()
{
    ConVar restartDelay = FindConVar("mp_round_restart_delay");
    if (restartDelay == null)
    {
        return 5.0;
    }

    float delay = restartDelay.FloatValue;
    return (delay < 0.0) ? 0.0 : delay;
}

void ClearDeferredEliminationState()
{
    g_bDeferredEliminationWin[CS_TEAM_T] = false;
    g_bDeferredEliminationWin[CS_TEAM_CT] = false;
    g_iDeferredEliminationRound[CS_TEAM_T] = 0;
    g_iDeferredEliminationRound[CS_TEAM_CT] = 0;
}

void ScheduleDeferredEliminationChecks()
{
    if (g_bDeferredEliminationWin[CS_TEAM_T])
    {
        RequestFrame(Frame_CheckDeferredElimination, CS_TEAM_T);
    }
    if (g_bDeferredEliminationWin[CS_TEAM_CT])
    {
        RequestFrame(Frame_CheckDeferredElimination, CS_TEAM_CT);
    }
}

public void Frame_CheckDeferredElimination(any teamData)
{
    int team = view_as<int>(teamData);
    if (team != CS_TEAM_T && team != CS_TEAM_CT)
    {
        return;
    }

    if (!g_bDeferredEliminationWin[team] ||
        g_iDeferredEliminationRound[team] != g_iRoundSerial ||
        !g_bEnabled || !g_bSupportedMap || !g_bRoundReady || g_bRoundEnding)
    {
        return;
    }

    // Keep waiting if the eliminated team has any live player, a respawn callback that
    // can still succeed, or a planted-C4 objective whose native result must take priority.
    if (HasAlivePlayerOnTeam(team) || HasPendingRespawnOnTeam(team) ||
        HasEligibleUnqueuedRespawnOnTeam(team) || HasPlantedBombObjective())
    {
        return;
    }

    int opposingTeam = (team == CS_TEAM_T) ? CS_TEAM_CT : CS_TEAM_T;
    if (!HasAlivePlayerOnTeam(opposingTeam))
    {
        // Do not manufacture a winner if both teams have been eliminated.
        return;
    }

    g_bDeferredEliminationWin[team] = false;
    g_iDeferredEliminationRound[team] = 0;
    CSRoundEndReason endReason = (opposingTeam == CS_TEAM_CT)
        ? CSRoundEnd_CTWin : CSRoundEnd_TerroristWin;
    CS_TerminateRound(GetRSPRoundRestartDelay(), endReason, true);
}

void EndRoundIfRespawnFailureLeavesTeamEliminated(int failedTeam)
{
    if (!g_bEnabled || !g_bSupportedMap || !g_bRoundReady || g_bRoundEnding ||
        (failedTeam != CS_TEAM_T && failedTeam != CS_TEAM_CT) ||
        HasPlantedBombObjective() || HasPendingRespawnOnTeam(failedTeam))
    {
        return;
    }

    int opposingTeam = failedTeam == CS_TEAM_T ? CS_TEAM_CT : CS_TEAM_T;
    if (HasAlivePlayerOnTeam(failedTeam) || !HasAlivePlayerOnTeam(opposingTeam))
    {
        return;
    }

    g_bDeferredEliminationWin[failedTeam] = false;
    g_iDeferredEliminationRound[failedTeam] = 0;
    CSRoundEndReason endReason = opposingTeam == CS_TEAM_CT ? CSRoundEnd_CTWin : CSRoundEnd_TerroristWin;
    CS_TerminateRound(GetRSPRoundRestartDelay(), endReason, true);
}

public void Frame_ApplyZombieLoadout(any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    int loadoutRound = g_iZombieLoadoutRound[client];
    g_iZombieLoadoutRound[client] = 0;
    if (loadoutRound == 0 || loadoutRound != g_iRoundSerial ||
        !IsClientInGame(client) || !IsValidEntity(client) ||
        !g_bEnabled || !g_bSupportedMap || g_bRoundEnding ||
        !IsRSPPowerRuntimeActiveForClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Zombie || !g_bZombieUsedThisRound[client])
    {
        return;
    }

    g_bZombieLoadoutApplying[client] = true;
    EnforceZombieInventory(client, true);
    g_bZombieLoadoutApplying[client] = false;

    SaveMoveSpeedState(client);
    if (g_bOldMoveSpeedValid[client])
    {
        SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue",
            g_fOldMoveSpeed[client] * RSP_ZOMBIE_SPEED_MULTIPLIER);
    }
    SetEntityHealth(client, RSP_ZOMBIE_HEALTH);
    if (HasEntProp(client, Prop_Send, "m_ArmorValue"))
    {
        SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
    }

    if (IsPolishClient(client))
    {
        PrintToChat(client, "\x04[RSP]\x01 Zombie: odrodziłeś się z 600 HP, zwiększoną szybkością, nożem i wyposażeniem zadaniowym.");
    }
    else
    {
        PrintToChat(client, "\x04[RSP]\x01 Zombie: respawned with 600 HP, increased speed, a knife and objective equipment.");
    }
}

void EnforceZombieInventory(int client, bool switchToKnife)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsValidEntity(client) ||
        !IsPlayerAlive(client) || g_iPower[client] != RSP_Zombie)
    {
        return;
    }

    bool keptKnife = false;
    int team = GetClientTeam(client);
    bool allowC4 = team == CS_TEAM_T;
    bool allowDefuser = team == CS_TEAM_CT;

    if (HasEntProp(client, Prop_Send, "m_hMyWeapons"))
    {
        int weaponArraySize = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
        for (int index = weaponArraySize - 1; index >= 0; index--)
        {
            int item = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", index);
            if (item <= MaxClients || !IsValidEntity(item))
            {
                continue;
            }

            char classname[32];
            GetEntityClassname(item, classname, sizeof(classname));
            if (StrEqual(classname, "weapon_knife", false))
            {
                if (!keptKnife)
                {
                    keptKnife = true;
                    continue;
                }
                RemovePlayerItem(client, item);
                RemoveEntity(item);
                continue;
            }

            if ((allowC4 && StrEqual(classname, "weapon_c4", false)) ||
                (allowDefuser && (StrEqual(classname, "weapon_defuser", false) ||
                    StrEqual(classname, "item_defuser", false))))
            {
                continue;
            }

            // This is a forbidden Zombie item. Remove it from the inventory and
            // destroy the entity directly; CS_DropWeapon would leave a pickup on the floor.
            RemovePlayerItem(client, item);
            if (IsValidEntity(item))
            {
                RemoveEntity(item);
            }
        }
    }

    int knife = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
    if (knife <= MaxClients || !IsValidEntity(knife))
    {
        knife = GivePlayerItem(client, "weapon_knife");
    }

    if (switchToKnife && knife > MaxClients && IsValidEntity(knife))
    {
        int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
        if (activeWeapon != knife)
        {
            // EquipPlayerWeapon is an engine-side operation and avoids generating
            // repeated client commands while the inventory is being cleaned.
            EquipPlayerWeapon(client, knife);
        }
    }
}

public void Frame_CleanZombieInventory(any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    int cleanupRound = g_iZombieCleanupRound[client];
    g_iZombieCleanupRound[client] = 0;
    g_bZombieCleanupQueued[client] = false;

    if (cleanupRound == 0 || cleanupRound != g_iRoundSerial ||
        !IsClientInGame(client) || !IsValidEntity(client) ||
        !g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) || !IsPlayerAlive(client) ||
        g_iPower[client] != RSP_Zombie || !g_bZombieUsedThisRound[client] || g_bZombieLoadoutApplying[client])
    {
        return;
    }

    g_bZombieLoadoutApplying[client] = true;
    EnforceZombieInventory(client, true);
    g_bZombieLoadoutApplying[client] = false;
}

void StopClientRegenTimer(int client)
{
    if (client < 1 || client > MaxClients)
    {
        return;
    }

    if (g_hRegenTimer[client] != null)
    {
        delete g_hRegenTimer[client];
        g_hRegenTimer[client] = null;
    }
}

public Action Timer_Regeneration(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return Plugin_Stop;
    }
    if (!IsPlayerAlive(client))
    {
        if (g_hRegenTimer[client] == timer) g_hRegenTimer[client] = null;
        return Plugin_Stop;
    }
    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActiveForClient(client) ||
        (g_iPower[client] != RSP_Regeneration && g_iPower[client] != RSP_HealingAngel))
    {
        if (g_hRegenTimer[client] == timer) g_hRegenTimer[client] = null;
        return Plugin_Stop;
    }

    int health = GetClientHealth(client);
    if (g_iPower[client] == RSP_HealingAngel)
    {
        if (health > RSP_HEALING_ANGEL_MAX_HEALTH)
        {
            SetEntityHealth(client, RSP_HEALING_ANGEL_MAX_HEALTH);
        }
        else if (health > 0 && health < RSP_HEALING_ANGEL_MAX_HEALTH)
        {
            int healedHealth = health + RSP_REGENERATION_AMOUNT;
            if (healedHealth > RSP_HEALING_ANGEL_MAX_HEALTH) healedHealth = RSP_HEALING_ANGEL_MAX_HEALTH;
            SetEntityHealth(client, healedHealth);
        }
    }
    else if (health > 0 && health < 2000000000)
    {
        // Existing Regeneration remains uncapped.
        SetEntityHealth(client, health + RSP_REGENERATION_AMOUNT);
    }

    return Plugin_Continue;
}

public void Frame_DisarmVictim(any userid)
{
    int victim = GetClientOfUserId(userid);
    if (victim < 1 || victim > MaxClients)
    {
        return;
    }

    int weapon = EntRefToEntIndex(g_iPendingDropWeaponRef[victim]);
    g_bDisarmPending[victim] = false;
    g_iPendingDropWeaponRef[victim] = 0;

    if (!g_bEnabled || !g_bSupportedMap || !IsRSPPowerRuntimeActive() || !IsClientInGame(victim) ||
        !IsPlayerAlive(victim) || weapon <= MaxClients || !IsValidEntity(weapon))
    {
        return;
    }

    int activeWeapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
    if (weapon != activeWeapon ||
        (weapon != GetPlayerWeaponSlot(victim, 0) && weapon != GetPlayerWeaponSlot(victim, 1)))
    {
        return;
    }

    float eyeAngles[3], vForward[3], dropOrigin[3], velocity[3];
    GetClientEyeAngles(victim, eyeAngles);
    GetAngleVectors(eyeAngles, vForward, NULL_VECTOR, NULL_VECTOR);
    GetClientAbsOrigin(victim, dropOrigin);

    // Move the dropped firearm away from the player to make immediate re-pickup harder.
    dropOrigin[0] += vForward[0] * 72.0;
    dropOrigin[1] += vForward[1] * 72.0;
    dropOrigin[2] += 36.0;
    velocity[0] = vForward[0] * 360.0;
    velocity[1] = vForward[1] * 360.0;
    velocity[2] = 150.0;

    CS_DropWeapon(victim, weapon, true, false);
    if (IsValidEntity(weapon) &&
        GetPlayerWeaponSlot(victim, 0) != weapon &&
        GetPlayerWeaponSlot(victim, 1) != weapon)
    {
        TeleportEntity(weapon, dropOrigin, eyeAngles, velocity);
    }
}

void StartGhostMaintenanceTimer()
{
    if (g_hGhostMaintenanceTimer == null && g_bEnabled && g_bSupportedMap)
    {
        g_hGhostMaintenanceTimer = CreateTimer(RSP_GHOST_MAINTENANCE_INTERVAL, Timer_GhostMaintenance, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    }
}

void StopGhostMaintenanceTimer()
{
    if (g_hGhostMaintenanceTimer != null)
    {
        delete g_hGhostMaintenanceTimer;
        g_hGhostMaintenanceTimer = null;
    }
}

void ClearFlashRecords()
{
    for (int i = 0; i < RSP_FLASH_RECORDS; i++)
    {
        g_iFlashOwnerUserId[i] = 0;
        g_iFlashRound[i] = 0;
        g_fFlashTime[i] = 0.0;
        g_fFlashProDuration[i] = 0.0;
        g_fFlashOrigin[i][0] = 0.0;
        g_fFlashOrigin[i][1] = 0.0;
        g_fFlashOrigin[i][2] = 0.0;
        g_bFlashRecordDeadly[i] = false;
        g_bFlashRecordLong[i] = false;
    }
    g_iFlashWriteIndex = 0;

    for (int entity = MaxClients + 1; entity < RSP_MAX_ENTITIES; entity++)
    {
        g_iFlashProjectileOwnerUserId[entity] = 0;
        g_bFlashProjectileDeadly[entity] = false;
        g_bFlashProjectileLong[entity] = false;
        g_iFlashProjectileRound[entity] = 0;
        g_fFlashProjectileSpawnTime[entity] = 0.0;
        g_iHEProjectileOwnerUserId[entity] = 0;
        g_bHEProjectileDemolition[entity] = false;
        g_iHEProjectileTeam[entity] = 0;
        g_bHEProjectileExecutioner[entity] = false;
        g_bHEProjectileEnder[entity] = false;
        g_iHEProjectileRound[entity] = 0;
        g_fHEProjectileSpawnTime[entity] = 0.0;
        g_iSmokeProjectileOwnerUserId[entity] = 0;
        g_iSmokeProjectileTeam[entity] = 0;
        g_iSmokeProjectileRound[entity] = 0;
        g_iSmokeProjectileType[entity] = 0;
        g_fSmokeProjectileSpawnTime[entity] = 0.0;
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        g_fLastDeadlyFlashThrowTime[client] = 0.0;
        g_iLastDeadlyFlashThrowRound[client] = 0;
        g_bLastFlashWasDeadly[client] = false;
        g_bLastFlashWasLong[client] = false;
        g_fLastLongFlashThrowTime[client] = 0.0;
        g_iLastLongFlashThrowRound[client] = 0;
        g_bHadDeadlyFlashThisRound[client] = false;
        g_bLastHEWasExecutioner[client] = false;
        g_bLastHEWasEnder[client] = false;
        g_fLastHEThrowTime[client] = 0.0;
        g_iLastHERound[client] = 0;
        g_bExecutionerHEKillPending[client] = false;
        g_iExecutionerHEKillOwnerUserId[client] = 0;
        g_bFlashScoreRepairPending[client] = false;
        g_iFlashScoreRepairOwnerUserId[client] = 0;
        g_iFlashScoreRepairVictimTeam[client] = 0;
        StopClientBlindTimer(client);
    }
}

bool IsValidPlayingClient(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        return false;
    }

    int team = GetClientTeam(client);
    return team == CS_TEAM_T || team == CS_TEAM_CT;
}


// [CS:S] Random Super Powers — PaK
// CHANGELOG (newest to oldest)
// 7.9.1: Removes the obsolete Phoenix pre-death loadout snapshot/restore system and its unused state. Phoenix now uses only the deterministic team loadout on respawn.
// 7.9.0: Adds Reclaimer, Concussion, Bloodlust, Spectator and Demolition. God Mode: 3.5 s / 25 s. Crippler retains 4 seconds and 50% slow but reduces outgoing damage by 75%. Heist drops only primary + pistol beside activator; grenades remain. Phoenix respawns with team primary, 100 armor, helmet and HE; CT defuser only on bomb maps.
// 7.8.7: Credits Jesse James, ainnoway, BluMachinima, GhettoSensei and Laps for their ongoing gameplay testing, feedback and ideas. No gameplay or localization behavior changed.
// 7.8.8: Aligns all RSPPower identifiers and related constants with current in-game power names; clarifies the Source roaming-observer constant; removes duplicate Phoenix grenade-count and fixed Flash-Pro min/max definitions. No gameplay behavior, power balance, player-facing text, or reset logic changed.
// 7.8.6: Removes confirmed write-only state and an unused macro without changing gameplay: g_fBlackoutFadeStartTime, g_iLastPower, g_iRagdollForceAttackerUserId, g_iGiantRound, g_iRichBoyCreditedBonus, g_iPendingBlindOwnerUserId, and RSP_COLLISION_GROUP_NONE. Removes the now-redundant ownerUserId parameter from QueueDeadlyFlashKill; its timer already resolves the responsible flash owner from authoritative projectile snapshots.
// 7.8.5: Keeps only Polish and English language support in the source. Removes the other language enum values, detection branches, power-description tables and localized switch branches. Polish and English descriptions and message text are preserved; every non-Polish client now uses English. Reorders the complete historical changelog into one block at the end of the source. No power mechanics, round logic, map support, cooldowns or assignment rules are intentionally changed.
// 7.8.4: Removes the de_*/cs_* map whitelist and surf_*/dm_*/gg_* exclusions. RSP can now be enabled and assign powers on any CS:S map; all power mechanics and assignment rules remain unchanged.
// 7.8.3: Standardizes Freezing Ammo descriptions in all 13 languages. The dynamic assignment description includes the actual rolled chance and the 20–40% range, with consistent 3-second movement/attack-lock wording.
// 7.8.2: Audits language routing and player-facing messages; corrects all power-description values for the 3-second Cryo/Freezing effect and 5% Friendly Fire healing; completes localized Blackout, Healing Angel, Damager and Weapon Swap notices, and localizes global enable/disable announcements; fixes French grammar and regional language-code handling; preserves CS2 Magazine System per-weapon reserve-magazine state during Weapon Swap by avoiding legacy m_iAmmo rewrites when the companion plugin is loaded.
// 7.8: Adds French, Turkish, Romanian, Simplified Chinese, Swedish and Czech localization for the full power-description pool, dynamic rolled descriptions, assignment/target notices, bind prompts and team/spectator rosters. Weapon Swap can now select an inventory firearm from an enemy holding a knife (matching slot first, other firearm slot as fallback).
// 7.7: Freezing Ammo now locks movement and both attacks for 3 seconds. Friendly Fire healing is reduced from 10% to 5%. Weapon Swap now exchanges the currently held firearms even across primary/secondary slots, replacing the corresponding occupied slots safely and preserving clips/reserve pools when isolated. Renames Poison Ammo to Viper, Expensive Ammo to Extortion and Weakening Ammo to Crippler. Removes Bloodhound completely from the power pool, enum, descriptions, runtime hooks and trail entities.
// 7.6: Removes Third Person and Subsonic Ammo completely from the selectable pool, enum, localized power arrays, dispatchers, hooks, and runtime code. Standardizes recipient notices for Grounder and Weapon Swap through the localized [RSP] Player-name format. Clears Grounder, Curser and Expensive Ammo target-side state on the affected player's death, alongside the pre-existing death cleanup for Blackout, Poison Ammo, Hacker, Scientist, Weakening Ammo, Cryo, Disorient and Reverse Controls. Removes Curser's unused write-only round flag.
// 7.5.20: Refines the working native CS:S Third Person camera: observer target now follows the player entity itself (m_hObserverTarget=client) instead of world/null, matching a field-tested CS:S setup; reduces camera FOV from 120 to 96 to avoid an unnecessarily wide, distorted view. Keeps DEATHCAM mode, client-only mp_forcecamera override, full state restoration, and zero per-frame camera hooks. No Subsonic or other power behavior changed.
// 7.5.19: Removes the custom prop_dynamic/SetClientViewEntity camera path and uses the native CS:S observer-camera method used by SourceMod helper libraries: m_hObserverTarget=0, m_iObserverMode=1 (DEATHCAM), m_bDrawViewmodel=0 and m_iFOV=120. Saves/restores the player's exact prior observer/FOV/viewmodel state and a client-only mp_forcecamera override. No camera entity, PostThink camera updater, or client-cvar query is involved. Subsonic Ammo, power pool, descriptions and all other power logic remain unchanged.
// 7.5.18: Thirdperson camera activation is no longer gated by QueryClientConVar. The view anchor is created and assigned immediately when rsp_useskill is pressed; the optional cl_first_person_uses_world_model query runs asynchronously only to save/restore the client setting and reveal the player world model. A missing/blocked cvar response can no longer make the bind appear to do nothing. Subsonic Ammo and all other gameplay logic are unchanged.
// 7.5.17: Replaces point_viewcontrol with a networked prop_dynamic view anchor assigned through SetClientViewEntity and updated from the player's live eye angles with wall tracing. Thirdperson no longer requires a successful second client-cvar query; it saves/restores cl_first_person_uses_world_model when queryable and still activates the camera if the query is unavailable. Subsonic Ammo suppresses the Shotgun Shot temp entity before remote clients process it and blocks the server-routed firearm sound, eliminating delayed SND_STOP truncation. Other powers, descriptions, target-selection filters, Ender Grenade and Poison Ammo behavior are retained.
// 7.5.16: Thirdperson uses point_viewcontrol with a moving info_target, Infinite Hold Time only (no Freeze Player), cl_first_person_uses_world_model saved/restored, and a camera 160 units behind/28 above the player with wall collision. Ender Grenade uses native HE throw force and fuse. Poison Ammo clears victim stacks on death/spawn and its timer refuses to tick on dead players. Subsonic Ammo follows the proven CS:S weapon-ID/game-sound routing: original Shotgun Shot TE remains for visuals, native weapon sound is retained only for the owner, and exact ordered SND_STOP packets are sent to other listeners.
// 7.5.15: Captures victim power and Chameleon owner power at the start of player_death so other death handlers cannot invalidate the first-kill copy. Ender Grenade rejects playerclip/clip/nodraw/sky surfaces and searches 0-350 first, expanding to 1050 only if no safe ground exists in the primary radius. Subsonic Ammo uses the established CS:S Shotgun Shot recipient-stop method plus server sound-recipient filtering, preserving shot visuals and one local shot sound. Third Person uses a networked prop_dynamic view anchor and queries/restores cl_first_person_uses_world_model; it keeps m_bDrawViewmodel enabled so the local world model can render.
// 7.5.14: Chameleon inherits the first enemy killed, including powers with target-selection flows; the original attacker is used before death-event rewrites. Ender Grenade only searches walkable, visible ground (never playerclip/clip/nodraw/sky) and searches radius 0-350 first, then 400-1050 only if the primary area has no safe player hull. Subsonic Ammo suppresses the Shotgun Shot tempent entirely for remote listeners and the server-routed sample for everyone; the shooter keeps only local predicted audio. Third Person replaces server-only info_target with an invisible networked prop_dynamic camera entity so SetClientViewEntity receives a transmitted view entity; movement and observer mode remain untouched.
// 7.5.13: Third Person uses a dedicated info_target as the client's view entity. The camera is positioned behind the live player from their current eye yaw/pitch and collision-traced against world/props; player movement, observer state, view offset, and spectator cvars are not changed. Subsonic Ammo suppresses the server-routed weapon sound for every recipient so the owner hears only the locally predicted shot, while remote tempent audio is stopped. Every new target-power assignment forces its own list to print after the unchanged 0.10 s delay, without changing candidate filters. Ender Grenade remains the only official name and keeps 2x initial projectile velocity.
// 7.5.12: Applies mp_forcecamera=0 only while at least one player uses Third Person, restoring the exact previous server value afterward. Subsonic Ammo routes the Shotgun Shot tempent to remote recipients and suppresses their client-side sound after the event; Ender Grenade retains 2x launch velocity and native fuse. Target-selection eligibility is unchanged; the list is displayed 0.10 s after the assignment message.
// 7.5.11: Applies the AlliedModders-tested CS:S third-person workaround: observer target is the player itself, client-side mp_forcecamera override is 0, and m_vecViewOffset is adjusted/restored. No movetype change. The target-selection candidate/filter code is untouched; only the existing 0.10 s display delay remains. Ender Grenade stays the sole official name.
// 7.5.10: Replaces Third Person point_viewcontrol with the native CS:S observer-camera method; doubles Ender Grenade projectile launch velocity with normal fuse; retains target-selection eligibility and the 0.10 s post-description delay. Subsonic routes the Shotgun Shot tempent to the owner and suppresses the server-side sample for all recipients.
// 7.5.9: Previous point_viewcontrol camera experiment; superseded in 7.5.10 after in-game testing showed it did not provide a usable CS:S player camera.
// 7.5.8: Renames Ender Grenade to Ender Grenade. Extends the actual HE m_flDetonateTime deadline to 3x while leaving the projectile think schedule running, so the grenade keeps bouncing/moving and detonates normally after landing. Sets all immediate target-selection builds to 0.10 s (shared by every targeted power and reassignment path). Slightly reduces Bloodhound trail width.
// 7.5.7: Restores target-selection list delivery after immediate power reassignment, including Thief, Duplicator, Chameleon and Avenger; adds a direct-build fallback if the selection timer cannot be created.
// 7.5.6: Aimbot body hits continue to receive true 4x headshot-equivalent damage; if the victim has no helmet, temporarily bypass vest armor during that hit and restore it afterward, matching CS:S headshot behavior without consuming armor.
// 7.5.4: Subsonic Ammo filters CS:S client-side Shotgun Shot temp entities so only the shooter receives the shot event. Ender Grenade now uses the engine grenade detonation deadline. Bloodhound trail is bright green to match Wallhack visibility.
// 7.5.3: Poison Ammo bypasses armor without consuming it. Blackout targets living human enemies regardless of Ghost/ReZombie or other assigned powers. Adds Subsonic Ammo (suppresses firearm-shot sounds for other listeners) and Ender Grenade (tripled HE fuse, teleport to nearest safe spot at detonation, immunity to the owner's own HE blast). Slightly thins Wallhack outline beams.
// 7.5.2: Tightens Tesla placement using a lower-anchored full-volume test plus a post-spawn actual-model collision check. Tesla ignores Ghost targets but shows ambient arcs when a Ghost is directly visible; Tesla kills normalize to $150 per enemy. Death Bomb adds a projected ground scorch decal. Bloodhound trail is wider, bright green like Wallhack, and lasts 10 seconds. Blackout uses the engine-native 3-second smooth fade.
// 7.5.1: Restores the previous default chat color for numeric values in assignment notices, gift notices, teammate/spectator rosters and target-selection extras. Removes a numeric colorizer that consumed the leading x from multiplier values. Audits suffix formatting for x multipliers, percentages, signed bonuses, HP and cash.
// 7.5: Adds round-scoped targeted Blackout, Healing Angel ally healing and capped regeneration, and toggleable third-person view for human players using a separate camera entity. Third Person camera control does not alter observer mode, so weapon switching and normal player actions remain available.
// 7.5: all bind-powered assignments use the same localized two-line bind instruction, including Entropy and powers awarded by Lootbox; power descriptions and mechanics are unchanged.
// 7.4: Based directly on 7.3.8 (keeps optional CS2 Mag support; does not integrate CS2 Ammo). Death Bomb radius is 700 units with unchanged explosion magnitude; Toxic Smoke bypasses player armor without consuming it; Healing Smoke restores 15 HP per tick; Poison Ammo ticks every 2.5 seconds. Repairs Tesla impact flash delivery on lethal player hits and explicitly emits CS:S head/helmet impact audio for Tesla headshots. Damager now confirms activation, bypasses enemy armor, and uses skull killfeed attribution with a fixed $300 per kill. All powers reset at round start as before.
// 7.3.8: Formats Giant like Dwarf: reports the rolled scale, the x1.10–x1.40 range and the size-based bonus HP. Updates Giant descriptions in all languages only; mechanics remain unchanged.
// 7.3.7: Applies the final Polish descriptions and concise translations for Scientist, Lootbox, Grounder, Bloodhound, Leech, Miner, Avenger, Weakening Ammo, Giant and Entropy. Entropy cooldown is 20 seconds; power mechanics are unchanged.
// 7.3.6: Active Entropy only removes the full reserve from a random enemy's currently held firearm; it never grants ammo to the activator. Uses optional CS2Mag_RemoveReserveMagazines with Magazine System, or clears the enemy's native CS:S reserve ammo. Leech keeps its separate on-hit transfer behavior. C4, grenades and weapons without reserve ammo remain excluded.
// 7.3.3: Corrects the Miner range interpretation: enemy proximity triggers the mine at 40 units, opponents can discover the mine within 60 units (and keep seeing it once discovered), while the explosion damage radius is 500 units with linear distance falloff. Keeps the 5-unit lower placement, 20 Hz trigger polling, 50% Thorns reflection and optional authoritative Magazine System integration for Entropy.
// 7.3.2: Thorns reflects 50% damage. Entropy uses an optional authoritative CS2 Magazine System native instead of editing the mirrored m_iAmmo reserve directly; vanilla CSS retains bullet-reserve reduction.
// 7.3.0: Removes ineffective CS:S cs_ragdoll scale manipulation and its retry/state machinery; keeps live Giant/Dwarf scaling only. Uses a transient GlowSprite temp entity sent in the same shot frame and with the same lifetime as the Tesla beam. Updates Scientist/Giant descriptions in all seven languages; Giant reports extra HP (total scaled health minus the normal 100 HP). Makes rsp_powerslist output stable, unique, alphabetically sorted and consecutively numbered, with no raw format placeholders.
// 7.2.15: Restores native prop_physics behavior for Exploding Barrel by removing manual health/explosion overrides that may interfere with the model/entity defaults. Players can place two barrels per 10-second cooldown cycle; cooldown starts only after the second successfully spawned barrel. Updates the existing Exploding Barrel description in all seven languages.
// 7.2.14: Removes unsupported SetModelScale input calls from cs_ragdoll and uses available model-scale properties; configures native explosive oil drums with explicit damage/health/explosion keyvalues so they remain destructible after the owner changes powers; Lootbox awards from the active pool except Lootbox itself; hidden gift-use debounce is 1.2 seconds; gifts use interactive-debris collision with explicit player/player-movement collision suppression.
// 7.2.13: Gambler excludes only Gambler itself from its three distinct offers. Thief, Duplicator and Chameleon are now eligible offers again; the general power pool and Lootbox pool remain unchanged.
// 7.2.12: Raises Giant maximum health from 300 to 400 HP while preserving the linear scale mapping: x1.10 = 120 HP, x1.40 = 400 HP, rounded to the nearest integer for every intermediate rolled scale. Audits confirm Scientist and Giant are each selectable, Gambler excludes only Gambler/Thief/Duplicator/Chameleon, and Lootbox draws from the full selectable pool.
// 7.2.11: Splits the former targeted Giant power into Scientist (same /1, /2 enemy enlargement) and a new self-Giant power. Self-Giant scales the holder x1.10-x1.40 and sets total/max health linearly from 120 to 300 HP; it uses the same roll through Gambler/Thief/Chameleon paths, scaled collision hull and view offset, and restores health cap/model state on reassignment. The Scientist effect keeps its previous round-scoped target behavior.
// 7.2.9: Adds persistent nearby-mine discovery, mine ground scorch and Lootbox physical pickup improvements.
// 7.2.7: Weakening Ammo now halves the target's composed movement multiplier for five seconds, including Speed Demon rolls; restores the power baseline afterward. Lootbox gifts spawn at torso/belly height (+32 units from player origin). Updates Lootbox, Grounder, Avenger, Miner and Weakening Ammo descriptions in all seven languages.
// 7.2.6: Fixes the Mine ground-scorch trace compile error by explicitly passing INVALID_HANDLE to TR_GetPlaneNormal for the global trace result; no gameplay behavior is intentionally changed.
// 7.2.5: Mines, gifts and Grounder effects are retained through round_end/restart delay and cleared by the single round_start reset. Miner cooldown is 5 seconds; enemy mine visibility is limited to 150 units. Lootbox uses a falling prop_physics_override that does not collide with players, does not expire on a timer, and can only be collected while aimed at and close to the gift. Mine explosions add a ground scorch decal.
// 7.2.4: Grounder blocks a selected target's jump until the end of the round, even if its source changes powers/teams, dies, or disconnects, and even if the target dies/respawns or changes teams.
// 7.2.2: Bloodhound is owner-dependent passive tracking, so its owned trail entities are removed as soon as the owner loses Bloodhound, including normal power reassignment. Effects applied by other powers to targets keep their own lifecycle.
// 7.2.1: Grounder opens its one-use /1, /2 target list at assignment and is not bind-activated. Reassigning a power resets the owner's old power state without erasing completed target effects already imposed on other players; deployed buildables/mines retain their own lifecycle. Lootbox uses the stock cs_gift model. Includes the 7.2.0 Avenger/Gambler/Rapid Fire/Tesla changes.
// 7.0.1: Renames Low Gravity to Astronaut and Death Boom to Death Bomb; Death Bomb radius is 3x while magnitude is unchanged. Adds Avenger (inherits the first dead teammate's power once, preserving supported rolled values) and Weakening Ammo (50% movement-speed multiplier + 30% lower outgoing damage for 5 seconds). Incendiary duration returns to 3 seconds, Freezing Ammo duration becomes 2.5 seconds, and Tesla shot sound level is reduced to 85. Tesla impact sprite visibility checks both visible and shot contents masks.
// 7.0.0: Adds Feather Falling, Weapon Swap, Lootbox, Grounder, Bloodhound, Entropy, and Miner; raises First Aid to three kits; replaces Tesla impact tempentity with a per-viewer, trace-occluded sprite; hardens fresh power reassignment limits and entity cleanup. Weapon Swap preserves weapon clips and moves reserve ammo only when per-player ammo pools are isolated; Leech transfers one reserve magazine on proc when CS2 Magazine System is active; Entropy steals all reserve ammo on activation.
// 6.0.95: Tightens Tesla-only spawn clearance: checks the full rotated footprint plus a 4-unit safety margin using MASK_SOLID, improving rejection of walls and solid props without changing Builder fence placement or ramp-ground sampling.
// 6.0.94: Makes the Tesla impact glow sprite half-size (1.25 -> 0.625) and gives it the exact same lifetime as the main laser (0.18 -> 0.12 s). Keeps its native blue-core material; TE_SetupGlowSprite does not expose a per-effect RGB tint parameter. Removes all custom dissolve fade scaling and the now-dead SpawnPost tracking path, restoring Source engine default timing for Deadly Flash, fatal Incendiary Ammo, and Tesla deaths. Robin Hood now transfers $10 per point of applied damage rounded to the nearest dollar, and validates both resulting account balances after the writes; any failed or mismatched write is rolled back.
// 6.0.93: Emits the brief physcannon_bluecore2b impact flash for every selected Tesla impact: player targets (including Juggernaut/Steel Head protected hit-zones) and hostile Tesla buildable targets. Misses still do not show it. Damage, headshot protections, targeting, sound, storm behavior, and all other powers remain unchanged.
// 6.0.92: Moves the brief physcannon_bluecore2b impact flash before Juggernaut/Steel Head hit-zone damage rejection, so every Tesla shot that reaches a player target shows the visual impact even when that hit zone blocks damage. Misses and hostile Tesla buildable targets still do not show it. Damage, headshot protections, targeting, sound, storm behavior, and all other powers remain unchanged.
// 6.0.91: Adds a brief sprites/physcannon_bluecore2b impact flash at the selected Tesla hit point for player targets only. It is emitted once per accepted player hit after Juggernaut/Steel Head hit-zone protection checks; misses, buildable targets and blocked hit-zones do not produce this flash. The main physbeam, damage, targeting, sound, storm behavior and all other powers remain unchanged.
// 6.0.90: Doubles the Tesla main physbeam laser width (start 12.0 -> 24.0; end 4.25 -> 8.5). This only changes TE_SetupBeamPoints widths; material, color, beam lifetime, damage, targeting, shot audio, lightning, and all other powers remain unchanged.
// 6.0.89: Slightly thickens the Tesla physbeam laser (start width 10.0 -> 12.0; end width 3.5 -> 4.25). Matches Tesla's native dissolve fade timeline to Deadly Flash and Incendiary Ammo (4x -> 2x). Reworks shot audio to use an explicit antenna origin with a rotating pool of Source user sound channels, so shots from multiple turrets do not reuse the same world-entity/channel pair; raises sound level from 75 to 100 and playback gain from 0.75 to 1.0 while retaining positional attenuation and the same WAV. Removes per-shot info_target entities and cleanup timers. Other gameplay is unchanged.
// 6.0.88: Changes Tesla shot playback from SNDCHAN_AUTO to SNDCHAN_STATIC for both the per-shot emitter and its safe fallback. This is intended to stop identical Tesla WAVs from replacing one another while preserving the explicit antenna position and normal distance attenuation. Slightly increases the main physbeam width (8.25 -> 10.0 at the start; 3.0 -> 3.5 at the end). The Hook beam and gameplay mechanics are unchanged.
// 6.0.87: Makes the Tesla main physbeam laser three times thicker by multiplying both beam start/end widths by 3 (2.75 -> 8.25 and 1.0 -> 3.0). This is a visual-only adjustment; beam life, laser material/color, targeting, damage, sound, and other powers are unchanged.
// 6.0.86: Keeps the Tesla electrical loop hum running for the entire lifetime of a built turret, while its ambient point_tesla lightning arcs remain active only when it has a visible hostile target and stop when that target is lost. Restores Zombie respawn health to 600 HP and updates its localized power description and respawn chat notice. The Half-Life 2 NPC model models/zombie/classic.mdl is not applied blindly because its NPC animation setup is not verified as compatible with CS:S player animation sequences.
// 6.0.85: Removes the Tesla's decorative noisy zigzag overlay completely and uses materials/sprites/physbeam.vmt for its single main beam. Tesla's point_tesla lightning and electrical loop sound are created only while it has a visible hostile target and are removed on the next check without a target. This keeps storm effects tied to active attacks and further reduces idle effect traffic. Tesla target selection, damage, headshot logic, shot sound, and all non-Tesla powers are unchanged.
// 6.0.84: Reduces Tesla's per-shot visual traffic from 13 separate beam TempEnts to two (the original icy main laser and one native noisy blue overlay). Reduces ambient point_tesla generation from 6-10 arcs every 0.2-0.8 seconds to 3-5 arcs every 0.45-0.9 seconds. This lowers bursty effect/network load while retaining the blue laser, noisy electric overlay, ambient arcs, Tesla targeting/damage, and sound. Intended to prevent Tesla effects from crowding native CS:S smoke and HE visuals.
// 6.0.83: Gives each Tesla shot its own short-lived positional sound emitter so simultaneous turrets do not share an entity/channel. Uses the same shot sound and the natural distance attenuation established in 6.0.82.
// 6.0.82: Reduces Tesla shot sound level from SNDLEVEL_GUNFIRE (140) to SNDLEVEL_NORMAL (75) and restores the prior 0.75 playback volume. Keeps the same WAV, dedicated per-turret antenna source, explicit muzzle origin, and SNDCHAN_AUTO so each shot remains positional and overlapping turret shots are not deliberately forced onto one fixed channel. This restores ordinary distance attenuation instead of the previous long-range gunfire setting.
// 6.0.81: Restores the originalAttacker declaration required by Tesla death attribution, snapshots the native attacker before RSP event rewrites, and checks attacker validity before resolving its userid. Tesla ragdoll impulse is 15x; Executioner ragdoll force remains removed while its kill behavior is unchanged.
// 6.0.79: Emits each Tesla shot from its own turret entity while preserving the exact antenna origin, avoiding all turrets sharing the world entity's weapon sound channel. Adds a restrained 5x native ragdoll impulse to enemies actually killed by Tesla, using the existing bounded ragdoll-force pipeline; fallback force/velocity are scaled down proportionally from Executioner's 15x profile. Existing Tesla damage, targeting, beam, dissolve timing, and all other power behavior remain unchanged.
// 6.0.78: Reverts the decorative Tesla spiral to the established vertical blue zigzag, restores the original energy-disintegration shot sound and emits it from the antenna muzzle as a positional sound. Fixes power replacement so reassigning a player from Deadly Flash to another power clears the persistent current-round flag for future throws; already-spawned flashbangs retain their captured lethal attribution. Other gameplay remains unchanged.
// 6.0.76: Fixes long-range Tesla spiral timing. Chooses a batch size based on beam length and server tick interval, then varies every segment's lifetime so all spiral segments remain visible together until the full coil has been emitted and a short display hold has elapsed. The straight damage beam, spiral shape/color, shot interval, damage, and all unrelated power behavior are unchanged.
// 6.0.75: Fixes a SourcePawn compile error in FindTeslaVisibleAimPoint by renaming the reserved local identifier `forward` to `forwardVec`. No gameplay behavior changes.
// 6.0.74: Streams Tesla spiral beam segments in small per-tick batches with lifetime scaled to full beam length, avoiding per-frame temp-entity overflow that clipped long spirals. Aims from the antenna across multiple player hit points (head, chest, shoulders, torso), plays the shot sound from the antenna at rocket-launch sound level, and samples the actual rotated buildable footprint on a 5x5 ground grid. Buildables align to the lowest sampled support point; clearance checks are lifted by the ground spread to tolerate ramps without treating the slope itself as a blocking prop.
// 6.0.74: Streams spiral segments in small batches to avoid Source temp-entity burst limits, scales visual lifetime to the number of batches, aims at multiple visible points on partially exposed enemies from the antenna origin, uses a louder shot sound emitted from antenna height, and aligns buildable placement to the lowest sampled point of the full rotated footprint on ramps/uneven ground.
// 6.0.73: Removes the fixed Tesla spiral turn/segment cap. The decorative spiral now spans the full beam length, calculating and sending each segment sequentially without a large temporary point array. Spiral density, radius, beam damage, and target selection remain unchanged.
// 6.0.71: Replaces the decorative straight-line zigzag overlay with a blue helical beam wrapped around the main Tesla laser. The main collision/damage beam, targeting, colors of the main/ambient effects, gameplay, and other powers are unchanged.
// 6.0.70: Recolors the three Tesla visual effects into a coordinated electric-blue palette: icy light-blue main laser, saturated blue spiral laser, and medium-blue ambient lightning. Tesla gameplay, damage, target selection, placement, sound, dissolve, and other powers are unchanged.
// 6.0.69: Restores the previous concise Inventor descriptions across all seven languages (with current 350 HP stats); removes Builder's per-round wall-use and active-wall caps while retaining its 5-second cooldown; increases Tesla shot sound level/range and volume; makes buildable placement more tolerant of ramps and uneven ground without changing Replica placement.
// 6.0.68: Removes the custom Tesla corpse replica/finalization path. Tesla deaths use the same native env_entity_dissolver system as before, with its fade timeline scaled to 4x; other RSP dissolve effects keep their existing 2x timeline. All gameplay/placement changes from 6.0.67 remain.
// 6.0.67: Balances Inventor Tesla to 350 HP and a 15% headshot chance for every player target, including Juggernaut; Steel Head still blocks headshot damage. Visible hostile players take priority over enemy Teslas, which remain fallback targets. Makes buildable placement less restrictive on uneven ground and near nearby objects; sequences round-start notices as owner power, target list after 0.1 s, teammate roster after 0.2 s. Tesla dissolve used a hidden prop_ragdoll fallback to retain a corpse after the native effect.
// 6.0.66: Centers the ambient point_tesla emitter on the exact X/Y antenna firing origin. Tesla dissolves use a longer native electrical effect; this version uses the native fade lifecycle without a custom corpse replica. Other dissolve causes are unchanged.
// 7.9.2: Concussion displays the rolled 15-30% chance and applies a 3-second CS:S flash fade plus distance-tier DSP deafening. Spectator blocks gameplay actions, chat/radio/voice and owned sounds; its 25-second cooldown starts after exit. Freezing Ammo blocks all active inputs before gameplay side effects and suppresses owned sounds/voice. Grounder cancels spammed jump impulses and grounded micro-jitter. Demolition preserves synchronous HE ownership attribution and scales the projectile's engine damage/radius defaults by x1.5/x3 on the next frame. Heist drops the same primary/pistol entities beside the activator; fixes SDKHooks_DropWeapon void usage so successful drops are counted and cooldown is applied.
// 6.0.65: Tesla-caused deaths used a very long native electrical dissolve timeline to try to keep the corpse for the whole round; this approach is replaced in 6.0.66/6.0.67 and 6.0.68 by a finite fade timeline.
// 6.0.64: Improves Inventor Tesla combat: player armor is bypassed, player targets have a 15% headshot chance (50% against Juggernaut) with 4x headshot damage and headshot killfeed, body hits are blocked by Juggernaut, enemy Teslas target and damage one another without headshots, and Thorns reflects Tesla damage onto the attacking turret instead of its owner. Slightly thickens the zigzag beam and centers/raises the ambient Tesla arc.
// 6.0.63: Removes Silenced Ammo and Silenced Steps from the selectable pool, power enum, names/descriptions, sound hooks, weapon-sound precache, and related helpers. No other power mechanics are intentionally changed.
// 6.0.62: Keeps the original Shotgun Shot TE for client-side shot visuals, but resolves the actual CS:S weapon-fire sound script and channel from m_iWeaponID/m_iMode before issuing an ordered per-recipient sound stop. Removes the hard-coded AK-47 sample that was not reliably precached and could not reliably match other weapon scripts.
// 6.0.61: Keeps the original Shotgun Shot TE for full client-side firing visuals, precaches the SND_STOP sample before use, and fixes Silenced Steps to recognize actual stock PM_PlayStepSound families (pl_step, pl_metal, pl_dirt, pl_duct, pl_grate, pl_tile, pl_slosh, pl_wade, jump/land/ladder). Movement sound recipients are filtered instead of depending on broad volume-zero matching.
// 6.0.60: Fixes a freeze regression in Silenced Ammo by no longer rebuilding/re-sending Shotgun Shot or emitting per-client SND_STOP messages synchronously inside its temp-entity hook. The original visual TE now passes unchanged, and non-owner weapon-channel stop messages are queued for a short deferred timer. Silenced Steps behavior is unchanged.
// 6.0.59: Preserves CS:S client-side bullet presentation for Silenced Ammo recipients by forwarding the Shotgun Shot temp entity to all original recipients, then sending an ordered weapon-channel stop to non-owner recipients; switches Silenced Steps to zero-volume sound modification, a known CSS sound-hook pattern, instead of relying only on recipient-list filtering.
// 6.0.58: Adds Silenced Steps, filtering a power owner's server-routed footsteps, jump/landing, and player-origin movement surface sounds to the owner only through the existing sound hook.
// 6.0.57: Hardens Silenced Ammo sound routing using weapon-channel filtering, resilient weapon owner resolution, and a dedicated CS:S Shotgun Shot temp-entity filter. Keeps common reload/draw/knife sounds excluded where identifiable.
// 6.0.56: Removes the failed remote crosshair power and its code/timers; replaces the pool entry with Silenced Ammo using recipient filtering for recognized gunfire sounds.
// 6.0.55: Removes the misplaced yellow muzzle flare; thickens straight and zigzag beams, increases zigzag segments, slightly reduces point_tesla arc size while making arcs recur more often and lowers their source toward the antenna cap. Tesla is set to 470 HP and a 1.2-second firing interval; all seven Inventor descriptions are updated.
// 6.0.54: Balances Tesla to 450 HP, 15-25 random damage per shot, and a 1.3-second firing interval. Updates all seven Inventor descriptions to match the new stats; other behavior is unchanged.
// 6.0.53: Makes the decorative zigzag oscillate mainly vertically for better side visibility; reduces point_tesla arc radius/thickness/lifetime while increasing spark frequency; draws the yellow muzzle glow directly at the exact same sampled beamStart vector, removing the separate Z override that could place it away from the visible laser origin.
// 6.0.52: Derives the Tesla antenna surface Z from the sampled collision surface so the muzzle glow aligns with the visible beam exit; shifts the native point_tesla source slightly above the collision surface to prevent its arcs collapsing into a bright hit-glow on the transformer; triggers an immediate DoSpark; always draws the straight damage beam plus a larger decorative zigzag overlay.
// 6.0.51: Lowers the shared Tesla beam/effect origin by 5 units, replaces env_spark with a yellow point_tesla lightning arc (physbeam texture, radius 100, 6–10 beams), adds a randomly selected segmented zigzag beam variant, and keeps the shot glow aligned to the same antenna point.
// 6.0.49: Derives Tesla beam X/Y origin from the highest point found by sampling the spawned model VPhysics collision from above, instead of guessing left/right offsets. Beam height remains bound to the same model max-Z formula; the previous lateral/forward offsets are retained only as a fallback if surface sampling fails. Other powers and behavior are unchanged.
// 6.0.46: Moves Tesla beam origin back toward the previously closer point by restoring its forward-axis offset to 4.0. Improves Builder/Inventor placement using 3x3 terrain samples and height-spread checks, tries five forward distances, moves the Builder fence closer, and suppresses cooldown-ready chat when a buildable's per-round uses or active buildable limit is exhausted.
// 6.0.45: Moves Tesla beam origin 4 units backward by reducing its forward-axis offset from 4 to 0. Tesla position, antenna height, damage, sound, targeting, team immunity and round behavior remain unchanged.
// 6.0.44: Tesla kills now apply the same native ragdoll dissolve used by Deadly Flash/Incendiary Ammo. The Tesla buildable ignores damage from its owner and same-team players. Tesla firing continues through the post-round win phase and stops only when round_start cleanup removes it.
// 6.0.43: Lowers Tesla placement by 4 units, moves its laser origin 3 units right and 2 forward, increases hum volume/radius, explicitly plays a stock HE explosion sound, and lets test-granted powers fire while round-ready initialization is pending. Tesla pauses at accepted round_end to avoid post-round damage.
// 6.0.41: Tesla deals 20 damage, has louder local hum, adjusted beam start, and native HE-style explosion on destruction. Builder has five per-round uses/fences and player-noncolliding doubled debris.
// 6.0.39: Aligns Builder fence and Inventor turret to their ground surface using spawned model collision bounds with model-specific fallback lifts. Raises the placement-clearance hulls and derives the turret laser origin from model bounds. Build limits, cooldowns, damage, target selection and other powers are unchanged.
// 6.0.37: Adds Builder (destructible wood fence, 10-second cooldown) and Inventor (automated visible-target laser turret, 10-second firing interval, 25-second placement cooldown). Entities use round-boundary/disconnect cleanup and tracked owner/health state.
// 6.0.36: Aligns Robin Hood descriptions in all seven languages with the concise Polish wording. Removes implementation details about rounding and cash transfer from translated descriptions; gameplay is unchanged.
// 6.0.35: Simplifies only the Polish Robin Hood description to "Kradniesz przeciwnikowi $10 za każdy zadany mu punkt obrażeń." Gameplay and cash-transfer logic remain unchanged.
// 6.0.34: Improves No Recoil stabilization and standardizes descriptions for Robin Hood, Assassin, and No Recoil.
// 6.0.33: Adds Robin Hood (transfers half the historical CS:S hostage-damage cash penalty rate: $10 per damage point, rounded to the nearest $50, with strict equal debit/credit and wallet-cap handling), Assassin (2x direct bullet/shotgun/knife damage when the attacker is in the victim's rear 120-degree horizontal arc), and No Recoil (clears the CS:S networked m_vecPunchAngle and m_vecPunchAngleVel during the holder's PostThink; spread is untouched). Adds three passive powers without changing existing power behavior.
// 6.0.32: Fixes the CS:S network-table path for the player-local HUD mask. The client receive table maps the local player data as `localdata.m_iHideHUD`; `m_Local.m_iHideHUD` is the server/datamap member path, not the SendProp path. Read/write helpers now translate the member name to the actual SendProp path, and update both Prop_Send and Prop_Data when available. This targets remote clients' own HUD state rather than relying on the listen-server host's local command behavior. No other power behavior intentionally changed.
// 6.0.31: Improved asynchronous client-cvar callback handling and periodic client-command fallback for the former crosshair effect; this implementation is removed in 6.0.56.
// 6.0.28: Poison Ammo ticks every 5 seconds and plays damage feedback; Executioner handles self-thrown HE grenades; Explosive Ammo projects decals on eligible surfaces.
// 6.0.27: Display-name-only update: Freeze Ammo -> Freezing Ammo; Toxic Ammo -> Poison Ammo. No power logic, timer, damage, reset, or target behavior changed.
// 6.0.26: Toxic Ammo stacks damage every 4 seconds with a 1 HP floor; Zombie health is 500 HP; Explosive Ammo improves decals for world and brush surfaces.
// 6.0.25: Restores the established Aimbot behavior, updates Toxic Ammo and ammo power names, and improves explosive decals. Toxic Smoke applies 15 damage every 1 second for 18 seconds within 180 Source units; Healing Smoke restores 10 HP every 1 second up to 100 HP within the same radius. Incendiary native burn ticks temporarily bypass armor while restoring the saved armor immediately afterward. Cloud ownership and type are snapshotted on each projectile. /
// 6.0.24: Refined Aimbot headpoint validation and preserved existing Hook, cooldown, and round-reset behavior.
// 6.0.22: Restored the pre-range-change Hook implementation, removed only its 5000-unit trace endpoint by switching to RayType_Infinite, and set a strict 5-second successful-cast cooldown. A valid recast after cooldown replaces the old pull timer/rope; invalid traces preserve the current rope and do not consume/reset cooldown.
// 6.0.19: Fixed stale target-HUD cleanup call by replacing the nonexistent timer-stop function with shared SDKHook lifecycle cleanup.
// 6.0.19: Fixed target-HUD enforcement-hook cleanup during client reset/disconnect.
// 6.0.18: Hacker hides the entire CS:S radar panel using the CSS HUD radar bit (1<<4), preserving other HUD flags; radar-contact filtering remains as a secondary safeguard.
// 6.0.18: Hacker hides the entire CS:S radar panel using HUD bit (1<<4), preserving the existing HUD mask. Radar-contact filtering remains as defense in depth; the old fake-flash workaround is removed.
// 6.0.17: Corrected radar handling for CS:S listen/dedicated clients using per-recipient radar filtering.
// 6.0.15: Audited chat-notification dispatch against 6.0.10 and 6.0.12. The source contains one player_death hook and one killer-power notification path, and the round-assignment notification uses one generation-validated deferred callback. Shortened the Aimbot description in every supported language. Repeated messages across both assignment and death-notice paths are consistent with multiple RSP .smx instances loaded simultaneously; see the companion audit.
// 6.0.14: Refined Aimbot head-center selection. Candidate scanning uses the lightweight validated center/sample path; after the target is chosen, a dedicated refinement pass checks the nominal center plus all nearby samples, averages only points whose rays hit the real head hitgroup, and independently validates the centroid. This avoids the old first-successful-sample bias toward an upper/side edge without multiplying full sample traces across every candidate. If the centroid is blocked or not a head hit, the nearest already-validated sample to that centroid is used. No new range limit or unrelated gameplay changes.
// 6.0.13: Fixed Aimbot acquisition failures by tracing through the full head volume (rather than ending the trace one unit past the sampled point), restored the CSS head-center offset, added more head samples for model/crouch variation, and made failed direct body traces fall back to normal visible-head acquisition. Crosshair trace now uses RayType_Infinite (no arbitrary 8192-unit cutoff). Aim steering is smoothed per command and synchronizes the resulting view angle to the player entity, while retaining visible-head hitgroup validation, wall blocking, and hard Ghost exclusion.
// 6.0.12: Reworked Aimbot target selection. An enemy directly under the crosshair is preferred; otherwise it selects the visible head closest to the actual view-center angle, with nearer distance used only as a tie-breaker and short target hysteresis to prevent flicker. Head aiming starts from eye-level center and validates a small head-point sample set, so it no longer aims 2.5 units below the eye point. Aim angles are applied through OnPlayerRunCmd instead of per-tick TeleportEntity, Ghost exclusion is retained, and the acquisition cone is balanced to 15 degrees on both axes.
// 6.0.11: Aimbot target validation explicitly excludes living Ghost power holders before angular selection or visibility tracing. This prevents crosshair tracking from revealing a Ghost's hidden position; all other Aimbot behavior and Ghost spectator visibility remain unchanged.
// 6.0.10: Allows the live Ghost model, tracked inventory entities, and radar contact to be transmitted to every non-alive Spectator-team client, including free-roaming spectators, plus dead T/CT clients currently in roaming mode. Dead T/CT viewers actively following the Ghost in first-/third-person still see it. All living clients remain blocked; no Aimbot, Soldier, ragdoll, respawn, or round-reset behavior is intentionally changed.
// 6.0.9: Corrected Ghost's live entity and tracked weapon transmission. Only non-alive clients actively observing that Ghost in first-/third-person receive its model and carried tracked entities; all living players (both teams) and spectators not targeting it are blocked. Live Ghost radar contacts are filtered for every regular player and only shown to the observer following that Ghost. Existing death-transition reveal and all non-Ghost mechanics are retained.
// 6.0.8: Replaced Aimbot fire-time shot redirection and synthetic body-hit headshot damage/killfeed edits with visible-head tracking on user commands while a firearm is equipped. Headpoint traces use MASK_SHOT and require the enemy head hitgroup to be the first hit; the acquisition cone is 16 degrees yaw / 25 degrees pitch, and knife/grenade/C4 classes are excluded by the firearm whitelist. Soldier now rolls +15–30% damage in all locales and runtime bounds.
// 6.0.7: Preserve each previous cs_ragdoll when an RSP respawn power brings a player back. Detach the current ragdoll handle before CS_RespawnPlayer so CCSPlayer::Spawn cannot remove/reuse that body; track detached ragdolls by entity reference, remove them at the next round_start, and clean them on plugin unload. Applies to Resurrection, Phoenix, Re-Zombie, and Medic/Reviver through their shared respawn paths.
// 6.0.6: Prevent respawn powers from firing after round_end. CS_OnTerminateRound now also recognizes a just-killed, not-yet-processed Resurrection/Phoenix/ReZombie owner so elimination can be held before the power timer is queued; deferred checks wait for the death event to resolve. Accepted round_end cancels all outstanding player/Zombie respawn timers as a final safety boundary.
// 6.0.5: Respawn-triggered round-end holds are team-scoped and tracked. If native elimination was deferred for Resurrection, Phoenix, ReZombie, or Medic and the same team is later eliminated without another eligible respawn, a post-death frame safely completes the round. Planted-C4 objective rounds remain native; forced termination respects mp_round_restart_delay.
// 6.0.4: Ghost transmission was changed to hide from teammates but show to enemies/free spectators. 6.0.9 narrowed the exception too far by requiring a tracked observer target. 6.0.10 allows any non-alive Spectator-team client and any roaming observer to see the live Ghost; dead players following the Ghost still see it, while all living players remain blocked.
// 6.0.3: Replaced competing initial-round roster timers with one per-recipient ordered batch: own power (and activation instructions), optional enemy-selection list, then teammate roster. Removed the global roster pass and late-assignment duplicate roster timer path. Localized Hook readiness/cooldown notices consistently as "Lina" in Polish.
// 6.0.2: Restored the known-good 5.10.3 Explosive Bullets decal implementation: native env_explosion scorch on floors/slopes, projected decal only for steep eligible world walls, and NODECAL deliberately omitted. Round-start cleanup also invalidates stale assignment IDs/last-power snapshots, clears Gambler/Thief staging data, forces dead Disguise model restoration at the round boundary, and removes any still-tracked RSP explosion entities from the previous round.
// 6.0.1: Preserve assigned power behavior and existing power timers through round_end until the authoritative round_start reset; synchronize the power notice, target-selection rows, and teammate roster. Enemy Spawn teleports to a hull-checked opposing-team spawn (20-second cooldown); Retreat teleports to a hull-checked own-team spawn (20-second cooldown); Swapper swaps positions with a random living enemy. God Mode offers 3 seconds of full damage immunity (20-second cooldown); Random Weapon replaces a random primary/secondary firearm (15-second cooldown); Heist removes weapons from a random living enemy (30-second cooldown). Grenadier, Sunshine and Smoker independently replenish HE, flashbang or smoke grenades. Healing Smoke heals the owner's team up to 100 HP. Thorns reflects 75% of actual health lost. NoClip allows free flight through the world while ignoring collisions for 5 seconds, with a 20-second cooldown, momentum preservation, and skybox-area recovery. Phoenix saves and restores the pre-death weapon/equipment loadout except C4. Bind-powered abilities support the direct client bind: bind "x" "rsp_useskill". On a listen server, SourceMod can call a client console command with client index 0; Command_UseSkill maps that case to the detected local host client only. Remote clients keep their normal client index, and dedicated-server calls are not redirected to a player. Reviver is manual only: a valid attempt starts a 20-second cooldown, can be repeated during the round, and reports one result. First Aid is the separate three-charge healing kit and is usable immediately without a cooldown. No valid dead teammate means no cooldown is consumed. One-Shot HE ownership is snapshotted on projectile entities so detonation remains lethal after owner death. Friendly Fire heals the teammate hit by the holder for 5% of the shot damage that would apply to the hitgroup; head hits use the stomach multiplier, each hit is rounded mathematically, no fractions carry over, and healing can exceed normal max HP. Hacker hides the CS:S radar panel. Sapper synchronizes progress bars to objective deadlines and preserves animation behavior where supported. Deadly Flash damage is attributed to the thrower where possible; synchronous native kill cash is normalized to fixed per-kill CS:S values, with fallback score/cash repair for forced-suicide deaths. One-Shot HE stores per-projectile owner attribution and corrects killfeed attribution when the thrower dies before detonation. Zombie keeps normal weapons on the first life and enforces knife/objective-only equipment after respawn. Bunnyhop remains local to the owner: hold jump for auto-bhop; no global speed-cap cvar is modified. Wallhack uses eight parented endpoint anchors and twelve persistent vivid-green env_beam edges around each eligible enemy. Every anchor and edge is filtered per recipient; maintenance runs every 0.30 seconds while parented points follow targets between passes. Swapper is selectable with hull-checked destinations, a 30-second cooldown, and owner-only success feedback. Manual powers have no initial cooldown: their first activation is available after freeze time, and the normal cooldown starts only after successful use. Every blocked attempt during freeze time receives a localized chat notice. Recommended bind: bind "x" "rsp_useskill"; no say command or public chat message is needed. Zombie death-transition and active-Zombie weapon drops are tracked and removed after the engine drop sequence; C4 and defuse kits remain objective equipment. Disarmament, Cryo Rounds, and Disorient each use 20–40%, and Incendiary side effects are applied before head/body immunity returns; power messages are concise and consistently localized. Impostor applies a built-in opposing-team model without changing team, weapons, hitboxes, or collision; it emits no console messages that reveal the power. Incendiary burn ticks retain the last valid incendiary attacker for their short damage window; fatal burn deaths are credited to that owner with the neutral world icon. Impostor model restoration is deferred through the death transition and cleaned at respawn or the unified round-start reset. Ghost death explicitly opens a 1.25-second entity-transmission window so the death model can be shown to opponents. Dwarf compensates the engine's pre-scaled collision bounds so its effective movement hull remains full-sized at reduced visual scales. Knockback vertical recoil requires a steep downward aim (about 45 degrees); small aim corrections do not create an upward launch. Swapper success is private to its owner; cooldown display uses whole seconds and announces readiness once. Soldier rolls x1.15–x1.30 damage and preserves native attacker attribution. Thief steals one selected enemy power through /1, /2, etc.; Curser selects one enemy whose missed firearm shots cost 5 HP until round end. Zombie loadout cleanup removes forbidden entities instead of dropping them and tracks death-dropped weapons for cleanup. Dracula restores 50% of the damage amount dealt, with fractional HP rounding balanced across hits and a 200 HP cap. Toxic Smoke deaths are attributed to the cloud owner with a neutral world icon and normalized to $300 per enemy kill. Live Ghost models and tracked Ghost weapons are hidden from all living players. Non-alive clients on the Spectator team (including free-roaming camera) can see a live Ghost; dead T/CT clients can see it while following that Ghost or while in free-roam observer mode. Radar filtering uses the same viewer rule. A short existing death-transition reveal is retained for the dead model. Added repeatable Air Hop, Flash-Pro, Knockback, Explosion on Death, bind-activated Medic and Phoenix. Incendiary Rounds ignite targets for 5 seconds; no extra scripted health damage is added. 5.0 cleanup removes disabled Radar, Silent Steps, Reserved and Long Knife entries and their dead code. Empty teammate rosters are not displayed. Reviver sends one result per attempt, reports the remaining cooldown on further activations, and notifies the owner once when ready again. Low Gravity stores its rolled multiplier and reasserts it during live player commands if another system overwrites m_flGravity. Power assignment is uniform over the active pool; Gambler offers three distinct powers. Legacy 5.0 additions are retained in the history for reference; inactive entries are not part of the current selectable pool.
// 6.0: Removed the fixed six-second post-round reset. One full round-state cleanup now runs at round_start, before the delayed power assignment, independent of mp_round_restart_delay. It resets every client power/timer, restores target-side effects, and clears replica entities, visual/projectile tracking, smoke clouds, incendiary attribution, and round-scoped state.
// 5.10.3: Target-selection /N lists are printed before teammate rosters. Sapper percentage increases action speed (e.g. 52% speed bonus makes a 10 s defuse take about 6.58 s); plant/defuse deadlines and the defuse bar use the same time factor. Respawn timer creation/retry failures clear pending state and release an elimination win only when a respawn actually failed. Zombie health is 500 HP.
// 5.10.2: hook used one visible white line. Hook pulling, input handling, detachment and cooldown logic are preserved. The former 5000-unit limit was removed in 6.0.22 without altering the trace filters.
// 5.10: Explosive Bullets maximum damage increased to 50. Native env_explosion scorch marks are restored by leaving NODECAL unset; steep world-wall impacts additionally use an oriented Projected Decal. Hook pulls at 750 units/s, uses a visible white line, and has explicit endpoint/overshoot cleanup.
// 5.9: Explosive Bullets accepts at most one bullet_impact event per player per server tick, preventing penetration/pellet impacts from repeatedly triggering explosions at the reconstructed first surface.
// 5.9: An already active Hook may be redirected to a new valid surface while pulling; invalid recast attempts leave the current rope attached. The current 6.0.22 implementation enforces the cooldown from each successful cast, including while a rope is active.
// 5.8.15: Restores a native Source scorch mark for Explosive Bullets on world floors and sends a World Decal at the actual impact point for vertical/steep world surfaces. The NODECAL spawn flag is now selected per impact surface rather than forced unconditionally.
// 5.8.14: Anomaly history samples once per second using a 12-sample rolling buffer; Hook has no fixed lifetime, detaches on reaching its anchor, jump, valid recast, death/reset/disconnect, blocks only WASD movement while pulling, preserves view/attacks, and uses a muted rope-brown beam.
// 5.8.13: Replica returned to the known-good idle_lower pose with native prop behavior; removed optional weapon attachment and custom collision/pushaway overrides. Added Resurrection (one native respawn per round using CS:S's normal spawn loadout), Hook (visible rope, solid-surface trace; its current cooldown is 5 seconds), and Anomaly (safe 7-second position rewind with a rolling live-player history, 15s cooldown).
// 5.8.7: Reworks Replica collision refresh to use SourceMod collision-group setters/rule refresh instead of writing m_CollisionGroup directly; requests a player-sized SOLID_BBOX, refreshes bounds after spawn, tries a pistol-idle animation with idle_lower as spawn fallback, and attaches a team-specific stock Glock/USP world model through bone merge. Corrects the Polish Replica cooldown message.
// 5.8.6: Unifies Executioner deferred guaranteed-kill scheduling across bullet/buckshot, non-trace damage, and both tracked/legacy HE projectile paths. The native hit still uses target-health/armor-based lethal damage; a next-frame enforcement applies fresh lethal damage if the target survives and uses the existing attribution-preserving suicide fallback only if damage still fails. This makes exceptional HP boosts and damage-path differences less likely to bypass Executioner without using a fixed 5k/10k hit on every shot. God Mode, protected hit zones, and server friendly-fire restrictions retain their existing priority.
// 5.8.5: Applies Executioner ragdoll force at cs_ragdoll Spawn/SpawnPost and retains a bounded per-victim PreThink fallback for builds where entity ownership is published late. Stores killer-to-victim direction, supplies a capped directional force for generic zero-force deaths, and caps resultant vectors. Uses dynamic lethal damage (victim health + twice current armor + 10) instead of thousands of overkill damage, and normalizes TraceAttack damage before CS:S applies the native hitgroup multiplier. This may reduce out-of-range stat updates; no direct evidence proves that the separate PlayerStatsUpdate warning is caused by Executioner. No global physics ConVar changes.
// 5.8.4: For deaths directly attributed to an opposing Executioner owner, temporarily hooks the victim PreThink and multiplies that death ragdoll's native m_vecForce and m_vecRagdollVelocity by 15.0 once. The hook is bounded to 0.75 seconds and is removed immediately after application, on timeout, or on disconnect; no global physics ConVar is changed.
// 5.8.3: Toxic Smoke never damages the cloud owner's teammates, regardless of mp_friendlyfire. Replica custom HP can be damaged only by opposing players; its owner and teammates are ignored, and valid enemy hits are reflected back at the same damage value.
// 5.8.2: Improves Replica placement on uneven floors by sampling a 3x3 support grid under the player-sized footprint, snapping to the highest nearby support surface, allowing modest ground-height variation, and using a slightly raised clearance hull to avoid rejecting candidates solely due to floor-contact epsilon. Does not change other powers.
// 5.8.1: Fixes Replica collision runtime errors by setting scalar sendprops without invalid array indices, uses the normal collision group with the existing 32x32x72 SOLID_BBOX and non-standable flag, and attributes lethal Thorns reflection to a neutral skull killfeed icon with a fixed $300 reward.
// 5.8: Reapplies Replica's player-sized SOLID_BBOX collision hull after entity spawn and on the following frame, writes solid type/flags with their proper field sizes, and re-marks collision bounds dirty. Simplifies the successful placement notice, updates Bankrupt's description, uses a consistent mint color for bind instructions, removes the roster-refresh clause from the shared no-enemies notice, and explicitly numbers rsp_powerslist entries by their final sorted display position.
// 5.7.2.5: Shortens Replica placement distance, searches progressively closer valid positions, follows nearby floor-height changes on ramps/steps without placing inside geometry, and enforces a player-sized rectangular collision hull marked not-standable. The Polish Replica description is simplified as requested.
// 5.7.2.3: Adds Replica, a bind-activated player-model prop with the idle_lower animation, 100 custom HP, reflected self-damage to other shooters, repeated placement on a 25-second cooldown, and entity cleanup on disconnect/round reset/map end.
// 5.7.2.2: Adds Knockup, a selectable firearm-hit power with a rolled 20-40% chance to launch a struck enemy vertically at a controlled speed equivalent to roughly two normal jump heights. Includes all-language descriptions, Gambler roll support, and parameter transfer through copy/steal mechanics.
// 5.7.2.1: Based directly on 5.7.2. Uses a native env_explosion/RadiusDamage backend for HE-style distance falloff, world occlusion and Source damage force/physics, while suppressing the native duplicate visuals/audio so the proven 5.7.2 impact effect, spatial sound and scorch decal remain unchanged. Corrects Explosive Bullets and Curser descriptions.
// 5.7.2: Trace the fired path back to its first collision so penetrations do not move the blast behind walls/players; allow the blast to damage its owner; normalize enemy blast kills to $300 and a neutral skull icon; use normal sound attenuation.
// 5.7.1: Explosive Bullets rolls on bullet_impact for player/world impacts, uses an HE-style effect/sound and a scorch decal, with 40 blast damage and a 175-unit radius.
// 5.7: Based directly on 5.6 Stable. Adds victim notices for targeted Curser/Scientist and other selected-target effects with red [RSP] headers and team-colored actor names; bind instructions use a mint [RSP] header; rare Chameleon-on-Chameleon copy exceptions use a pink header. Gambler displays only green power names and excludes Gambler, Thief, Duplicator and Chameleon offers. Target-selection lists rebuild after spawn/death/team/disconnect/power changes using debounced snapshots typed as RSPPower.
// 5.6: Renamed Auto Bunnyhop to Bunny, One-Shot to Executioner, and Reverse Controls to Reverser; Executioner kills with any damage it deals to an enemy. Berserker now grants +50% damage and +40% movement speed at 25 HP or less. Explosive Bullets damage increased to 40; descriptions refreshed in all seven languages; Gambler no longer reveals rolled values before selection; rsp_powerslist compacts valid unique powers, sorts by English name, and numbers the displayed entries consecutively.
// 5.5: NoClip and God Mode cooldowns are 20 seconds; Thorns reflects 75% of actual health damage; Soldier rolls 15–50% bonus damage; Death Boom uses 2x standard HE damage and radius; Friendly Fire heals teammates for 10% of hitgroup-adjusted shot damage with independent mathematical rounding and no normal-HP cap.
// 5.4: Deadly Flash and fatal Incendiary deaths both use dissolver type 1; retained the tested 2.00x native fade timeline modified at SpawnPost. Static audit verifies 65 unique selectable powers, all seven language tables aligned with the 66-slot power enum, no duplicate function definitions or unreferenced internal functions, no runtime dissolve-test ConVars, and no duplicate power IDs. Removed redundant lifecycle/effect cleanup calls and corrected Berserker descriptions to match its x1.30 movement speed (30%).
// 5.0.3.26: Reworked dissolve fade scaling to modify the actual native env_entity_dissolver at SDKHook_SpawnPost, while it is attached to the exact marked cs_ragdoll and before its first scheduled think/network update. Removed the delayed m_hEffectEntity lookup that could silently miss the effect. Kept fixed dissolve styles (Deadly Flash=0, fatal Incendiary=1) and the 2.00x fade timeline.
// 5.0.3.25: Restored strict case-insensitive matching of the full canonical English power name for rsp_getpower, rsp_givepower, and rsp_givepowerall. Partial names no longer grant powers or print a candidate list. Kept rsp_givepowerall and the fixed 2.00x dissolve timeline unchanged.
// 5.0.3.24: Removed the temporary dissolve test ConVars, fixed dissolve styles at Deadly Flash=0 and Incendiary=1, doubled the fade timeline scale to 2.00x, and added host-only rsp_givepowerall for assigning one selectable power to every living player. The attempted prefix-based power-name matching was reverted in 5.0.3.25 because it did not provide native console TAB completion and could grant a power immediately from an incomplete name.
// 5.0.3.23: Dissolve duration experiment scaled the native fade timeline by 1.50x; 5.0.3.24 increases this test to 2.00x. Dissolve styles remain fixed at Deadly Flash=0 and Incendiary=1.
// 5.0.3.22: Removed the temporary dissolve-test ConVars. Deadly Flash now always uses dissolve type 0 (Normal/Core-like lifting ash effect as verified by the owner), and Incendiary fatal burn deaths always use type 1 (Electrical). After the engine creates the attached dissolve entity, its replicated fade timings are extended by approximately 0.20 seconds; all other death types remain unchanged.
// 5.0.3.21: Added a temporary dissolver-style comparison experiment. Those runtime test ConVars are not part of current builds; fixed dissolve styles are selected internally.
// 5.0.3.20: Increased persistent Wallhack edge width from 0.75 to 1.75 without changing its anchors, endpoint handling, refresh interval, or owner-only transmit filtering. Added native env_entity_dissolver effect to the post-death cs_ragdoll for tracked Deadly Flash kills and fatal Incendiary burn ticks; regular deaths and live players are untouched.
// 5.0.3.19: Duplicator reports one localized copy-success message; removed a repeated generic target-selection prompt and audited localized target-effect messages.
// 5.0.3.18: Fixed persistent Wallhack env_beam initialization by assigning unique anchor targetnames and LightningStart/LightningEnd KeyValues before DispatchSpawn; removed fragile post-spawn sendprop endpoint setup. All other 5.0.3.17 gameplay changes retained.
// 5.0.3.16: Wallhack uses a parented vivid-green frame sprite maintained every 0.30 seconds; parent attachment follows targets between maintenance passes. The historical Aimbot implementation redirected firing angles and normalized body-hit metadata; this was replaced by visible-head tracking in 6.0.8. Chameleon sends one copy+description message. Deadly Flash cash normalization enforces a hard $16,000 cap (or lower positive mp_maxmoney) after native death rewards settle.
// 5.0.3.11: Fixed direct `rsp_useskill` on listen-server host consoles by mapping client index 0 to the loopback-detected host. Remote clients and dedicated servers retain normal behavior; no chat trigger is required.
// 5.0.3.10: Used the silent slash trigger to keep the activation command out of public chat.
// 5.0.3.9: Restored the known-working say-trigger bind instruction (`bind "x" "say /sm_rsp_useskill"`) for CS:S clients where the bare custom console command does not reach the server reliably. The bare `rsp_useskill` and `sm_rsp_useskill` commands remain registered and use the same dispatcher. No power logic or cooldown rules changed.
// 5.0.3.8: Fixed Blademaster roster suffix (constant chance is not repeated); shortened Berserker description; Zombie speed is x1.50. Ground Dash adds a stronger vertical launch to reduce immediate ground-friction loss. Ghost is no longer briefly transmitted to enemy killcam observers, and enemy Ghost radar contacts are omitted instead of placed off-map.
// 5.0.3.7: Sapper rolls 20-60%; Friendly Fire lets its owner heal a teammate by shooting them (+1 HP per firearm hit) instead of healing the power holder when shot. rsp_powerslist prints the final number of entries it actually lists.
// 5.0.3.6: Dash is the canonical power name; Reverse Controls now targets a random living enemy for 10 seconds. Steel Head uses the original TraceAttack path without the transient damage fallback, preserves protection against One-Shot, blocks Aimbot firearm body hits normalized to headshot damage, and remains bypassed by knife damage.
// 5.0.3.5: Added Dash and Reverse Controls.
// 5.0.2.8: Thief uses one combined theft/name/description message; Wallhack description shortened; teammate and spectator rosters show rolled values only, without redundant labels or ranges.