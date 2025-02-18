local mod = RegisterMod('Pill Manager', 1)
local json = require('json')
local game = Game()

mod.showUnidentifiedPills = false
mod.pillEffectToAddToPool = PillEffect.PILLEFFECT_NULL + 1
mod.forcedPillPoolColor = PillColor.PILL_NULL
mod.forcedPillPoolTime = 0
mod.rng = RNG()
mod.rngShiftIndex = 35

mod.spriteStdIdle = Sprite()
mod.spriteStdHUD = Sprite()
if REPENTANCE or REPENTANCE_PLUS then
  mod.spriteHorseIdle = Sprite()
  mod.spriteHorseHUD = Sprite()
else
  mod.anm2CardsPills = 'gfx/ui/ui_cardspills.anm2'
end

-- there's no standard api for adding pill colors
mod.pillColors = {
                   [PillColor.PILL_BLUE_BLUE]        = { -- 1
                                                         name      = 'Blue-Blue',
                                                         anm2Std   = 'gfx/005.071_pill blue-blue.anm2',
                                                         anm2Horse = 'gfx/005.071_horse pill blue-blue.anm2'
                                                       },
                   [PillColor.PILL_WHITE_BLUE]       = { -- 2
                                                         name      = 'White-Blue',
                                                         anm2Std   = 'gfx/005.072_pill white-blue.anm2',
                                                         anm2Horse = 'gfx/005.072_horse pill white-blue.anm2'
                                                       },
                   [PillColor.PILL_ORANGE_ORANGE]    = { -- 3
                                                         name      = 'Orange-Orange',
                                                         anm2Std   = 'gfx/005.073_pill orange-orange.anm2',
                                                         anm2Horse = 'gfx/005.073_horse pill orange-orange.anm2'
                                                       },
                   [PillColor.PILL_WHITE_WHITE]      = { -- 4
                                                         name      = 'White-White',
                                                         anm2Std   = 'gfx/005.074_pill white-white.anm2',
                                                         anm2Horse = 'gfx/005.074_horse pill white-white.anm2'
                                                       },
                   [PillColor.PILL_REDDOTS_RED]      = { -- 5
                                                         name      = 'Dots-Red',
                                                         anm2Std   = 'gfx/005.075_pill dots-red.anm2',
                                                         anm2Horse = 'gfx/005.075_horse pill dots-red.anm2'
                                                       },
                   [PillColor.PILL_PINK_RED]         = { -- 6
                                                         name      = 'Pink-Red',
                                                         anm2Std   = 'gfx/005.076_pill pink-red.anm2',
                                                         anm2Horse = 'gfx/005.076_horse pill pink-red.anm2'
                                                       },
                   [PillColor.PILL_BLUE_CADETBLUE]   = { -- 7
                                                         name      = 'Blue-Cadetblue',
                                                         anm2Std   = 'gfx/005.077_pill blue-cadetblue.anm2',
                                                         anm2Horse = 'gfx/005.077_horse pill blue-cadetblue.anm2'
                                                       },
                   [PillColor.PILL_YELLOW_ORANGE]    = { -- 8
                                                         name      = 'Yellow-Orange',
                                                         anm2Std   = 'gfx/005.078_pill yellow-orange.anm2',
                                                         anm2Horse = 'gfx/005.078_horse pill yellow-orange.anm2'
                                                       },
                   [PillColor.PILL_ORANGEDOTS_WHITE] = { -- 9
                                                         name      = 'Dots-White',
                                                         anm2Std   = 'gfx/005.079_pill dots-white.anm2',
                                                         anm2Horse = 'gfx/005.079_horse pill dots-white.anm2'
                                                       },
                   [PillColor.PILL_WHITE_AZURE]      = { -- 10
                                                         name      = 'White-Azure',
                                                         anm2Std   = 'gfx/005.080_pill white-azure.anm2',
                                                         anm2Horse = 'gfx/005.080_horse pill white-azure.anm2'
                                                       },
                   [PillColor.PILL_BLACK_YELLOW]     = { -- 11
                                                         name      = 'Black-Yellow',
                                                         anm2Std   = 'gfx/005.081_pill black-yellow.anm2',
                                                         anm2Horse = 'gfx/005.081_horse pill black-yellow.anm2'
                                                       },
                   [PillColor.PILL_WHITE_BLACK]      = { -- 12
                                                         name      = 'White-Black',
                                                         anm2Std   = 'gfx/005.082_pill white-black.anm2',
                                                         anm2Horse = 'gfx/005.082_horse pill white-black.anm2'
                                                       },
                   [PillColor.PILL_WHITE_YELLOW]     = { -- 13
                                                         name      = 'White-Yellow',
                                                         anm2Std   = 'gfx/005.083_pill white-yellow.anm2',
                                                         anm2Horse = 'gfx/005.083_horse pill white-yellow.anm2'
                                                       }
                 }
if REPENTANCE or REPENTANCE_PLUS then
  mod.pillColors[PillColor.PILL_GOLD] = { -- 14
                                          name      = 'Gold-Gold',
                                          anm2Std   = 'gfx/005.084_pill gold-gold.anm2',
                                          anm2Horse = 'gfx/005.084_horse pill gold-gold.anm2'
                                        }
end

mod.pillEffects = {
                    [PillEffect.PILLEFFECT_NULL] = 'Not overriden' -- -1
                  }
mod.pillEffectsMax = PillEffect.PILLEFFECT_NULL

-- the api returns labels instead of names due to multi-language support which isn't properly exposed in the api
mod.pillEffectLabels = {
                         ['#BAD_GAS_NAME']                           = 'Bad Gas',                              -- 0
                         ['#BAD_TRIP_NAME']                          = 'Bad Trip',                             -- 1
                         ['#BALLS_OF_STEEL_NAME']                    = 'Balls of Steel',                       -- 2
                         ['#BOMBS_ARE_KEY_NAME']                     = 'Bombs are Key',                        -- 3
                         ['#EXPLOSIVE_DIARRHEA_NAME']                = 'Explosive Diarrhea',                   -- 4
                         ['#FULL_HEALTH_NAME']                       = 'Full Health',                          -- 5
                         ['#HEALTH_DOWN_NAME']                       = 'Health Down',                          -- 6
                         ['#HEALTH_UP_NAME']                         = 'Health Up',                            -- 7
                         ['#I_FOUND_PILLS_NAME']                     = 'I Found Pills',                        -- 8
                         ['#PUBERTY_NAME']                           = 'Puberty',                              -- 9
                         ['#PRETTY_FLY_NAME']                        = 'Pretty Fly',                           -- 10
                         ['#RANGE_DOWN_NAME']                        = 'Range Down',                           -- 11
                         ['#RANGE_UP_NAME']                          = 'Range Up',                             -- 12
                         ['#SPEED_DOWN_NAME']                        = 'Speed Down',                           -- 13
                         ['#SPEED_UP_NAME']                          = 'Speed Up',                             -- 14
                         ['#TEARS_DOWN_NAME']                        = 'Tears Down',                           -- 15
                         ['#TEARS_UP_NAME']                          = 'Tears Up',                             -- 16
                         ['#LUCK_DOWN_NAME']                         = 'Luck Down',                            -- 17
                         ['#LUCK_UP_NAME']                           = 'Luck Up',                              -- 18
                         ['#TELEPILLS_NAME']                         = 'Telepills',                            -- 19
                         ['#48_HOUR_ENERGY_NAME']                    = '48 Hour Energy',                       -- 20
                         ['#HEMATEMESIS_NAME']                       = 'Hematemesis',                          -- 21
                         ['#PARALYSIS_NAME']                         = 'Paralysis',                            -- 22
                         ['#I_CAN_SEE_FOREVER_NAME']                 = 'I can see forever!',                   -- 23
                         ['#PHEROMONES_NAME']                        = 'Pheromones',                           -- 24
                         ['#AMNESIA_NAME']                           = 'Amnesia',                              -- 25
                         ['#LEMON_PARTY_NAME']                       = 'Lemon Party',                          -- 26
                         ['#R_U_A_WIZARD_NAME']                      = 'R U A Wizard?',                        -- 27
                         ['#PERCS_NAME']                             = 'Percs!',                               -- 28
                         ['#ADDICTED_NAME']                          = 'Addicted!',                            -- 29
                         ['#RELAX_NAME']                             = 'Re-Lax',                               -- 30
                         ['#QUESTION_MARKS_NAME']                    = '???',                                  -- 31
                         ['#ONE_MAKES_YOU_LARGER_NAME']              = 'One makes you larger',                 -- 32
                         ['#ONE_MAKES_YOU_SMALL_NAME']               = 'One makes you small',                  -- 33
                         ['#INFESTED_NAME_1']                        = 'Infested!',                            -- 34
                         ['#INFESTED_NAME_2']                        = 'Infested?',                            -- 35
                         ['#POWER_PILL_NAME']                        = 'Power Pill!',                          -- 36
                         ['#RETRO_VISION_NAME']                      = 'Retro Vision',                         -- 37
                         ['#FRIENDS_TILL_THE_END_NAME']              = 'Friends Till The End!',                -- 38
                         ['#XLAX_NAME']                              = 'X-Lax',                                -- 39
                         ['#SOMETHINGS_WRONG_NAME']                  = 'Something\'s wrong...',                -- 40
                         ['#IM_DROWSY_NAME']                         = 'I\'m Drowsy...',                       -- 41
                         ['#IM_EXCITED_NAME']                        = 'I\'m Excited!!!',                      -- 42
                         ['#GULP_NAME']                              = 'Gulp!',                                -- 43
                         ['#HORF_NAME']                              = 'Horf!',                                -- 44
                         ['#FEELS_LIKE_IM_WALKING_ON_SUNSHINE_NAME'] = 'Feels like I\'m walking on sunshine!', -- 45
                         ['#VURP_NAME']                              = 'Vurp!',                                -- 46
                         ['#SHOT_SPEED_DOWN_NAME']                   = 'Shot Speed Down',                      -- 47
                         ['#SHOT_SPEED_UP_NAME']                     = 'Shot Speed Up',                        -- 48
                         ['#EXPERIMENTAL_PILL_NAME']                 = 'Experimental Pill'                     -- 49
                       }

-- phd / lucky foot / virgo
mod.badToGoodPillEffects = {
                             [PillEffect.PILLEFFECT_HEALTH_DOWN]  = PillEffect.PILLEFFECT_HEALTH_UP,
                             [PillEffect.PILLEFFECT_RANGE_DOWN]   = PillEffect.PILLEFFECT_RANGE_UP,
                             [PillEffect.PILLEFFECT_SPEED_DOWN]   = PillEffect.PILLEFFECT_SPEED_UP,
                             [PillEffect.PILLEFFECT_TEARS_DOWN]   = PillEffect.PILLEFFECT_TEARS_UP,
                             [PillEffect.PILLEFFECT_LUCK_DOWN]    = PillEffect.PILLEFFECT_LUCK_UP,
                             [PillEffect.PILLEFFECT_AMNESIA]      = PillEffect.PILLEFFECT_SEE_FOREVER,
                             [PillEffect.PILLEFFECT_QUESTIONMARK] = PillEffect.PILLEFFECT_TELEPILLS,
                             [PillEffect.PILLEFFECT_ADDICTED]     = PillEffect.PILLEFFECT_PERCS,
                             [PillEffect.PILLEFFECT_IM_EXCITED]   = PillEffect.PILLEFFECT_IM_DROWSY,
                             [PillEffect.PILLEFFECT_PARALYSIS]    = PillEffect.PILLEFFECT_PHEROMONES,
                             [PillEffect.PILLEFFECT_RETRO_VISION] = PillEffect.PILLEFFECT_SEE_FOREVER,
                             [PillEffect.PILLEFFECT_WIZARD]       = PillEffect.PILLEFFECT_POWER,
                             [PillEffect.PILLEFFECT_X_LAX]        = PillEffect.PILLEFFECT_SOMETHINGS_WRONG,
                             [PillEffect.PILLEFFECT_BAD_TRIP]     = PillEffect.PILLEFFECT_FULL_HEALTH
                           }
if REPENTANCE or REPENTANCE_PLUS then
  mod.badToGoodPillEffects[PillEffect.PILLEFFECT_BAD_TRIP]        = PillEffect.PILLEFFECT_BALLS_OF_STEEL
  mod.badToGoodPillEffects[PillEffect.PILLEFFECT_SHOT_SPEED_DOWN] = PillEffect.PILLEFFECT_SHOT_SPEED_UP
end

-- false phd
mod.goodToBadPillEffects = {}
if REPENTANCE or REPENTANCE_PLUS then
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_HEALTH_UP]            = PillEffect.PILLEFFECT_HEALTH_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_RANGE_UP]             = PillEffect.PILLEFFECT_RANGE_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_SPEED_UP]             = PillEffect.PILLEFFECT_SPEED_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_TEARS_UP]             = PillEffect.PILLEFFECT_TEARS_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_LUCK_UP]              = PillEffect.PILLEFFECT_LUCK_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_SHOT_SPEED_UP]        = PillEffect.PILLEFFECT_SHOT_SPEED_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_BAD_GAS]              = PillEffect.PILLEFFECT_HEALTH_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_FRIENDS_TILL_THE_END] = PillEffect.PILLEFFECT_HEALTH_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_SEE_FOREVER]          = PillEffect.PILLEFFECT_AMNESIA
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_LEMON_PARTY]          = PillEffect.PILLEFFECT_AMNESIA
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_EXPLOSIVE_DIARRHEA]   = PillEffect.PILLEFFECT_RANGE_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_LARGER]               = PillEffect.PILLEFFECT_RANGE_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_BOMBS_ARE_KEYS]       = PillEffect.PILLEFFECT_TEARS_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_INFESTED_EXCLAMATION] = PillEffect.PILLEFFECT_TEARS_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_48HOUR_ENERGY]        = PillEffect.PILLEFFECT_SPEED_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_SMALLER]              = PillEffect.PILLEFFECT_SPEED_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_PRETTY_FLY]           = PillEffect.PILLEFFECT_LUCK_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_INFESTED_QUESTION]    = PillEffect.PILLEFFECT_LUCK_DOWN
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_BALLS_OF_STEEL]       = PillEffect.PILLEFFECT_BAD_TRIP
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_FULL_HEALTH]          = PillEffect.PILLEFFECT_BAD_TRIP
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_HEMATEMESIS]          = PillEffect.PILLEFFECT_BAD_TRIP
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_PHEROMONES]           = PillEffect.PILLEFFECT_PARALYSIS
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_TELEPILLS]            = PillEffect.PILLEFFECT_QUESTIONMARK
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_IM_DROWSY]            = PillEffect.PILLEFFECT_IM_EXCITED
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_PERCS]                = PillEffect.PILLEFFECT_ADDICTED
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_SUNSHINE]             = PillEffect.PILLEFFECT_RETRO_VISION
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_POWER]                = PillEffect.PILLEFFECT_WIZARD
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_SOMETHINGS_WRONG]     = PillEffect.PILLEFFECT_X_LAX
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_GULP]                 = PillEffect.PILLEFFECT_HORF
  mod.goodToBadPillEffects[PillEffect.PILLEFFECT_VURP]                 = PillEffect.PILLEFFECT_HORF
end

mod.state = {}
mod.state.isGoldPillIdentified = false
mod.state.identifyPills = false
mod.state.identifyGoldPills = false
mod.state.enableItemIntegration = false
mod.state.shuffledAndHidden = false
mod.state.startupEffects = {
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL,
                             PillEffect.PILLEFFECT_NULL
                           }
mod.state.pillColors = {
                         [tostring(PillColor.PILL_BLUE_BLUE)]        = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_WHITE_BLUE)]       = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_ORANGE_ORANGE)]    = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_WHITE_WHITE)]      = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_REDDOTS_RED)]      = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_PINK_RED)]         = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_BLUE_CADETBLUE)]   = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_YELLOW_ORANGE)]    = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_ORANGEDOTS_WHITE)] = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_WHITE_AZURE)]      = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_BLACK_YELLOW)]     = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_WHITE_BLACK)]      = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         [tostring(PillColor.PILL_WHITE_YELLOW)]     = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 }
                       }
if REPENTANCE or REPENTANCE_PLUS then
  mod.state.pillColors[tostring(PillColor.PILL_GOLD)] = { effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 }
end
mod.state.pillEffects = { -- tostring because table to json is ambiguous (array/object)
                          [tostring(PillEffect.PILLEFFECT_BAD_GAS)]              = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_BAD_TRIP)]             = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_BALLS_OF_STEEL)]       = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_BOMBS_ARE_KEYS)]       = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_EXPLOSIVE_DIARRHEA)]   = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_FULL_HEALTH)]          = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_HEALTH_DOWN)]          = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_HEALTH_UP)]            = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_I_FOUND_PILLS)]        = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_PUBERTY)]              = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_PRETTY_FLY)]           = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_RANGE_DOWN)]           = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_RANGE_UP)]             = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_SPEED_DOWN)]           = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_SPEED_UP)]             = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_TEARS_DOWN)]           = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_TEARS_UP)]             = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_LUCK_DOWN)]            = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_LUCK_UP)]              = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_TELEPILLS)]            = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_48HOUR_ENERGY)]        = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_HEMATEMESIS)]          = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_PARALYSIS)]            = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_SEE_FOREVER)]          = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_PHEROMONES)]           = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_AMNESIA)]              = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_LEMON_PARTY)]          = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_WIZARD)]               = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_PERCS)]                = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_ADDICTED)]             = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_RELAX)]                = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_QUESTIONMARK)]         = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_LARGER)]               = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_SMALLER)]              = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_INFESTED_EXCLAMATION)] = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_INFESTED_QUESTION)]    = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_POWER)]                = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_RETRO_VISION)]         = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_FRIENDS_TILL_THE_END)] = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_X_LAX)]                = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_SOMETHINGS_WRONG)]     = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_IM_DROWSY)]            = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_IM_EXCITED)]           = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_GULP)]                 = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_HORF)]                 = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_SUNSHINE)]             = PillEffect.PILLEFFECT_NULL,
                          [tostring(PillEffect.PILLEFFECT_VURP)]                 = PillEffect.PILLEFFECT_NULL
                        }
if REPENTANCE or REPENTANCE_PLUS then
  mod.state.pillEffects[tostring(PillEffect.PILLEFFECT_SHOT_SPEED_DOWN)] = PillEffect.PILLEFFECT_NULL
  mod.state.pillEffects[tostring(PillEffect.PILLEFFECT_SHOT_SPEED_UP)]   = PillEffect.PILLEFFECT_NULL
  mod.state.pillEffects[tostring(PillEffect.PILLEFFECT_EXPERIMENTAL)]    = PillEffect.PILLEFFECT_NULL
end

function mod:onGameStart(isContinue)
  mod:fillPillEffects()
  mod:setupModConfigMenu()
  
  if mod:HasData() then
    local _, state = pcall(json.decode, mod:LoadData())
    
    if type(state) == 'table' then
      if isContinue then
        if type(state.isGoldPillIdentified) == 'boolean' then
          mod.state.isGoldPillIdentified = state.isGoldPillIdentified
        end
      end
      if type(state.identifyPills) == 'boolean' then
        mod.state.identifyPills = state.identifyPills
      end
      if type(state.identifyGoldPills) == 'boolean' then
        mod.state.identifyGoldPills = state.identifyGoldPills
      end
      if type(state.enableItemIntegration) == 'boolean' then
        mod.state.enableItemIntegration = state.enableItemIntegration
      end
      if type(state.shuffledAndHidden) == 'boolean' then
        mod.state.shuffledAndHidden = state.shuffledAndHidden
      end
      if type(state.startupEffects) == 'table' then
        for i, v in ipairs(state.startupEffects) do
          if i >= 1 and i <= #mod.state.startupEffects and math.type(v) == 'integer' and v >= PillEffect.PILLEFFECT_NULL and v <= mod.pillEffectsMax then
            mod.state.startupEffects[i] = v
          end
        end
      end
      if type(state.pillColors) == 'table' then
        for k, v in pairs(state.pillColors) do
          if mod.state.pillColors[k] and type(v) == 'table' then
            if math.type(v.effect) == 'integer' and v.effect >= PillEffect.PILLEFFECT_NULL and v.effect <= mod.pillEffectsMax then
              mod.state.pillColors[k].effect = v.effect
            end
            if math.type(v.weightStd) == 'integer' and v.weightStd >= 0 and v.weightStd <= 11 then
              mod.state.pillColors[k].weightStd = v.weightStd
            end
            if math.type(v.weightHorse) == 'integer' and v.weightHorse >= 0 and v.weightHorse <= 11 then
              mod.state.pillColors[k].weightHorse = v.weightHorse
            end
          end
        end
      end
      if type(state.pillEffects) == 'table' then
        for k, v in pairs(state.pillEffects) do
          if mod.state.pillEffects[k] and math.type(v) == 'integer' and v >= PillEffect.PILLEFFECT_NULL and v <= mod.pillEffectsMax then
            mod.state.pillEffects[k] = v
          end
        end
      end
    end
  end
  
  if not isContinue then
    mod:setStartupEffects()
    
    if mod.state.identifyPills then
      mod:identifyPills()
    end
  end
end

function mod:onGameExit(shouldSave)
  if shouldSave then
    mod:save()
    mod.state.isGoldPillIdentified = false
  else
    mod.state.isGoldPillIdentified = false
    mod:save()
  end
  
  mod:seedRng()
  mod.showUnidentifiedPills = false
  mod.forcedPillPoolColor = PillColor.PILL_NULL
  mod.forcedPillPoolTime = 0
end

function mod:save(settingsOnly)
  if settingsOnly then
    local _, state
    if mod:HasData() then
      _, state = pcall(json.decode, mod:LoadData())
    end
    if type(state) ~= 'table' then
      state = {}
    end
    
    state.identifyPills = mod.state.identifyPills
    state.identifyGoldPills = mod.state.identifyGoldPills
    state.enableItemIntegration = mod.state.enableItemIntegration
    state.shuffledAndHidden = mod.state.shuffledAndHidden
    state.startupEffects = mod.state.startupEffects
    state.pillColors = mod.state.pillColors
    state.pillEffects = mod.state.pillEffects
    
    mod:SaveData(json.encode(state))
  else
    mod:SaveData(json.encode(mod.state))
  end
end

function mod:onUpdate()
  -- if gold pill was ever identified
  if (REPENTANCE or REPENTANCE_PLUS) and not mod.state.isGoldPillIdentified then
    mod.state.isGoldPillIdentified = mod:isPillIdentified(PillColor.PILL_GOLD)
  end
end

-- doesn't pass pill color, assume gold pill
function mod:onUsePill()
  if (REPENTANCE or REPENTANCE_PLUS) and mod.state.identifyGoldPills then
    mod:identifyGoldPillsAgain()
  end
end

function mod:getPillColor(seed)
  local function sortColors(a, b)
    return a.color < b.color
  end
  
  local weightedColors = {}
  local totalWeight = 0
  for k, v in pairs(mod.state.pillColors) do
    if v.weightStd > 0 then
      table.insert(weightedColors, { color = tonumber(k), weight = v.weightStd })
      totalWeight = totalWeight + v.weightStd
    end
    if (REPENTANCE or REPENTANCE_PLUS) and v.weightHorse > 0 then
      table.insert(weightedColors, { color = PillColor.PILL_GIANT_FLAG + tonumber(k), weight = v.weightHorse })
      totalWeight = totalWeight + v.weightHorse
    end
  end
  
  table.sort(weightedColors, sortColors)
  
  if totalWeight > 0 then
    local rng = RNG()
    rng:SetSeed(seed, mod.rngShiftIndex)
    local rand = rng:RandomInt(totalWeight) + 1
    for _, v in ipairs(weightedColors) do
      rand = rand - v.weight
      if rand <= 0 then
        return v.color
      end
    end
  end
  
  return nil
end

-- pillColor never includes PILL_GIANT_FLAG so you can't tell if it's a horse pill
function mod:getPillEffect(pillEffect, pillColor)
  local colorOverride = mod:getPillColorOverride(pillColor)
  if colorOverride ~= PillEffect.PILLEFFECT_NULL then
    if mod.state.enableItemIntegration then
      colorOverride = mod:doItemIntegration(colorOverride)
    end
    
    return colorOverride
  end
  
  local effectOverride = mod:getPillEffectOverride(pillEffect)
  if effectOverride ~= PillEffect.PILLEFFECT_NULL then
    if mod.state.enableItemIntegration then
      effectOverride = mod:doItemIntegration(effectOverride)
    end
    
    return effectOverride
  end
  
  return nil
end

function mod:renderPillColor(pillColor)
  if ScreenHelper == nil then
    return
  end
  
  local pos = ScreenHelper.GetScreenCenter() + Vector(68, -18) -- copied from mcm
  
  if REPENTANCE or REPENTANCE_PLUS then
    local anm2Std = mod.pillColors[pillColor].anm2Std
    local anm2Horse = mod.pillColors[pillColor].anm2Horse
    
    anm2Std, anm2Horse = mod:getFiendFolioAnm2(pillColor, anm2Std, anm2Horse)
    
    if mod.spriteStdIdle:GetFilename() ~= anm2Std then
      mod.spriteStdIdle:Load(anm2Std, true)
      mod.spriteStdIdle:Play('Idle', true)
    end
    if mod.spriteStdHUD:GetFilename() ~= anm2Std then
      mod.spriteStdHUD:Load(anm2Std, true)
      mod.spriteStdHUD:Play('HUD', true)
    end
    if mod.spriteHorseIdle:GetFilename() ~= anm2Horse then
      mod.spriteHorseIdle:Load(anm2Horse, true)
      mod.spriteHorseIdle:Play('Idle', true)
    end
    if mod.spriteHorseHUD:GetFilename() ~= anm2Horse then
      mod.spriteHorseHUD:Load(anm2Horse, true)
      mod.spriteHorseHUD:Play('HUD', true)
    end
    
    mod.spriteStdIdle:Render(pos + Vector(-108, -28), Vector.Zero, Vector.Zero)
    mod.spriteStdHUD:Render(pos + Vector(-108, -3), Vector.Zero, Vector.Zero)
    mod.spriteHorseIdle:Render(pos + Vector(-83, -28), Vector.Zero, Vector.Zero)
    mod.spriteHorseHUD:Render(pos + Vector(-83, -3), Vector.Zero, Vector.Zero)
    
    if Isaac.GetFrameCount() % 2 == 0 then -- 60fps -> 30fps
      mod.spriteStdIdle:Update()
      mod.spriteStdHUD:Update()
      mod.spriteHorseIdle:Update()
      mod.spriteHorseHUD:Update()
    end
  else
    local anm2Std = mod.pillColors[pillColor].anm2Std
    
    if mod.spriteStdIdle:GetFilename() ~= anm2Std then
      mod.spriteStdIdle:Load(anm2Std, true)
      mod.spriteStdIdle:Play('Idle', true)
    end
    if mod.spriteStdHUD:GetFilename() ~= mod.anm2CardsPills then
      mod.spriteStdHUD:Load(mod.anm2CardsPills, true)
      mod.spriteStdHUD:SetFrame('Pills', pillColor - 1)
    elseif mod.spriteStdHUD:GetFrame() ~= pillColor - 1 then
      mod.spriteStdHUD:SetFrame('Pills', pillColor - 1)
    end
    
    mod.spriteStdIdle:Render(pos + Vector(-98, -28), Vector(0,0), Vector(0,0))
    mod.spriteStdHUD:Render(pos + Vector(-98, -3), Vector(0,0), Vector(0,0))
    
    if Isaac.GetFrameCount() % 2 == 0 then
      mod.spriteStdIdle:Update()
    end
  end
end

function mod:getFiendFolioAnm2(pillColor, anm2Std, anm2Horse)
  if not (REPENTANCE or REPENTANCE_PLUS) or not StageAPI or not StageAPI.Loaded or not FiendFolio then
    return anm2Std, anm2Horse
  end
  
  local ffPillColor = FiendFolio.savedata.run.PillBeingReplaced[tostring(pillColor)]
  
  if ffPillColor then
    local configStd = StageAPI.GetEntityConfig(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, ffPillColor)
    if configStd and configStd.Anm2 then
      anm2Std = 'gfx/' .. configStd.Anm2
    end
    local configHorse = StageAPI.GetEntityConfig(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, ffPillColor + PillColor.PILL_GIANT_FLAG)
    if configHorse and configHorse.Anm2 then
      anm2Horse = 'gfx/' .. configHorse.Anm2
    end
  end
  
  return anm2Std, anm2Horse
end

function mod:getFiendFolioName(pillColor)
  if not (REPENTANCE or REPENTANCE_PLUS) or not StageAPI or not StageAPI.Loaded or not FiendFolio or not FiendFolio.savedata or not FiendFolio.savedata.run then
    return nil
  end
  
  local ffPillColor = FiendFolio.savedata.run.PillBeingReplaced[tostring(pillColor)]
  
  if ffPillColor then
    local config = StageAPI.GetEntityConfig(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, ffPillColor)
    if config and config.Name then
      local name = config.Name -- Pill Black-Purple
      if string.len(name) >= 6 and string.sub(name, 1, 5) == 'Pill ' then
        return string.sub(name, 6) -- Black-Purple
      end
    end
  end
  
  return nil
end

-- 0-49 are defined in repentance
-- 50 and beyond can be created by mods, it doesn't appear that you can set IDs via the xml so everything should be sequential
function mod:fillPillEffects()
  for k, _ in pairs(mod.pillEffects) do
    if k ~= PillEffect.PILLEFFECT_NULL then
      mod.pillEffects[k] = nil
    end
  end
  mod.pillEffectsMax = PillEffect.PILLEFFECT_NULL
  
  local itemConfig = Isaac.GetItemConfig()
  local size = #itemConfig:GetPillEffects() -- unfortunately Get() returns unusable data, but we can assume that the size corresponds to IDs - 1
  for i = 0, size - 1 do
    local pillEffect = itemConfig:GetPillEffect(i)
    if pillEffect then
      if i < PillEffect.NUM_PILL_EFFECTS then
        -- it doesn't appear that you can remove pills from the XML (w/o crashing the game), but the names could be altered
        mod.pillEffects[pillEffect.ID] = (REPENTANCE or REPENTANCE_PLUS) and mod:lookupPillEffectName(pillEffect.Name) or pillEffect.Name
      else
        mod.pillEffects[pillEffect.ID] = '(M) ' .. pillEffect.Name
      end
      mod.pillEffectsMax = pillEffect.ID
    end
  end
end

function mod:getPillColorName(color, origOnly)
  local tbl = mod.pillColors[color]
  if tbl and origOnly then
    return tbl.name
  end
  
  if not origOnly then
    local ffName = mod:getFiendFolioName(color)
    if ffName then
      return ffName
    end
  end
  
  if tbl then
    return tbl.name
  end
  
  return tostring(color)
end

function mod:getPillEffectName(effect)
  local name = mod.pillEffects[effect]
  if name then
    return name
  end
  
  return tostring(effect)
end

function mod:lookupPillEffectName(label)
  local name = mod.pillEffectLabels[label]
  if name then
    return name
  end
  
  return label
end

function mod:getPillColorOverride(color)
  local override = mod.state.pillColors[tostring(color)]
  if override then
    return override.effect
  end
  
  return PillEffect.PILLEFFECT_NULL
end

function mod:getPillEffectOverride(effect)
  local override = mod.state.pillEffects[tostring(effect)]
  if override then
    return override
  end
  
  return PillEffect.PILLEFFECT_NULL
end

function mod:doItemIntegration(effect)
  -- this excludes multiplayer (including jacob & esau)
  local player = mod:getSinglePlayer()
  
  if player then
    local tempEffect = nil
    
    local hasPHD = player:HasCollectible(CollectibleType.COLLECTIBLE_PHD, false)
    local hasLuckyFoot = false
    if REPENTANCE or REPENTANCE_PLUS then
      hasLuckyFoot = player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT, false)
    end
    local hasVirgo = player:HasCollectible(CollectibleType.COLLECTIBLE_VIRGO, false)
    local hasFalsePHD = false
    if REPENTANCE or REPENTANCE_PLUS then
      hasFalsePHD = player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD, false)
    end
    
    if hasFalsePHD then
      if not (hasPHD or hasLuckyFoot or hasVirgo) then
        tempEffect = mod.goodToBadPillEffects[effect]
      end
    elseif hasPHD or hasLuckyFoot or hasVirgo then
      tempEffect = mod.badToGoodPillEffects[effect]
    end
    
    if tempEffect == nil and (effect == PillEffect.PILLEFFECT_BAD_TRIP or effect == PillEffect.PILLEFFECT_HEALTH_DOWN) then
      local playerType = player:GetPlayerType()
      local maxHearts = player:GetMaxHearts() / 2
      local hearts = (player:GetHearts() / 2) + (player:GetSoulHearts() / 2)
      if REPENTANCE or REPENTANCE_PLUS then
        hearts = hearts + player:GetBoneHearts()
      end
      
      local isSoulHeartPlayerType
      if REPENTANCE or REPENTANCE_PLUS then
        isSoulHeartPlayerType = playerType == PlayerType.PLAYER_BLUEBABY   or playerType == PlayerType.PLAYER_THESOUL or
                                playerType == PlayerType.PLAYER_BLUEBABY_B or playerType == PlayerType.PLAYER_THEFORGOTTEN_B
      else
        isSoulHeartPlayerType = playerType == PlayerType.PLAYER_XXX        or playerType == PlayerType.PLAYER_THESOUL
      end
      
      if isSoulHeartPlayerType then
        maxHearts = player:GetSoulHearts() / 2
      end
      
      if effect == PillEffect.PILLEFFECT_BAD_TRIP and hearts <= 1 then
        tempEffect = (hasFalsePHD and not (hasPHD or hasLuckyFoot or hasVirgo)) and PillEffect.PILLEFFECT_I_FOUND_PILLS or PillEffect.PILLEFFECT_FULL_HEALTH
      elseif effect == PillEffect.PILLEFFECT_HEALTH_DOWN and maxHearts <= 1 then
        tempEffect = (hasFalsePHD and not (hasPHD or hasLuckyFoot or hasVirgo)) and PillEffect.PILLEFFECT_I_FOUND_PILLS or PillEffect.PILLEFFECT_HEALTH_UP
      end
    end
    
    if tempEffect then
      effect = tempEffect
    end
  end
  
  return effect
end

-- exclude babies, co-op ghosts, children (strawman, book of illusions, etc)
-- deal with tainted forgotten/soul
function mod:getSinglePlayer()
  local players = {}
  for i = 0, game:GetNumPlayers() - 1 do
    local player = game:GetPlayer(i)
    local isBaby = player:GetBabySkin() ~= BabySubType.BABY_UNASSIGNED
    local isCoopGhost = false
    if REPENTANCE or REPENTANCE_PLUS then
      isCoopGhost = player:IsCoopGhost()
    end
    local isChild = player.Parent ~= nil
    if not isBaby and not isCoopGhost and not isChild then
      table.insert(players, player)
    end
  end
  
  local playersCount = #players
  if playersCount == 1 or (playersCount == 2 and mod:isTaintedForgotten(players[1])) then
    return players[1] -- tainted forgotten (rather than soul)
  end
  
  return nil
end

function mod:isTaintedForgotten(player)
  if (REPENTANCE or REPENTANCE_PLUS) and player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
    local twin = player:GetOtherTwin()
    if twin and twin:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
      return true
    end
  end
  
  return false
end

function mod:setStartupEffects()
  local startupEffects = {}
  for _, v in ipairs(mod.state.startupEffects) do
    if v ~= PillEffect.PILLEFFECT_NULL and not mod:tableHasValue(startupEffects, v) then
      table.insert(startupEffects, v)
    end
  end
  
  local itemPool = game:GetItemPool()
  repeat
    local done = true
    local startupColors = {}
    for _, v in ipairs(startupEffects) do
      local color = itemPool:ForceAddPillEffect(v)
      
      if mod:tableHasValue(startupColors, color) then
        done = false
      else
        table.insert(startupColors, color)
      end
    end
  until(done)
end

function mod:isPillIdentified(pillColor)
  local itemPool = game:GetItemPool()
  if itemPool:IsPillIdentified(pillColor) then
    return true
  end
  
  if (REPENTANCE or REPENTANCE_PLUS) and FiendFolio then
    local ffPillColor = FiendFolio.savedata.run.PillBeingReplaced[tostring(pillColor)]
    if ffPillColor then
      return FiendFolio.savedata.run.IdentifiedRunPills[tostring(ffPillColor)] or false
    end
  end
  
  return false
end

function mod:identifyPills()
  local itemPool = game:GetItemPool()
  for color, _ in pairs(mod.pillColors) do
    itemPool:IdentifyPill(color)
  end
end

function mod:identifyGoldPillsAgain()
  if mod.state.isGoldPillIdentified then
    local itemPool = game:GetItemPool()
    itemPool:IdentifyPill(PillColor.PILL_GOLD)
  end
end

function mod:spawnPill(color, isHorse)
  local player = game:GetPlayer(0)
  local pill = (color ~= PillColor.PILL_NULL and isHorse) and PillColor.PILL_GIANT_FLAG + color or color
  Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pill, Isaac.GetFreeNearPosition(player.Position, 3), Vector(0,0), nil)
end

function mod:tableHasValue(tbl, val)
  for _, v in ipairs(tbl) do
    if v == val then
      return true
    end
  end
  
  return false
end

function mod:seedRng()
  repeat
    local rand = Random()  -- 0 to 2^32
    if rand > 0 then       -- if this is 0, it causes a crash later on
      mod.rng:SetSeed(rand, mod.rngShiftIndex)
    end
  until(rand > 0)
end

-- start ModConfigMenu --
function mod:setupModConfigMenu()
  if ModConfigMenu == nil then
    return
  end
  
  for _, v in ipairs({ 'General', 'Startup', 'Colors', 'Effects 1', 'Effects 2', 'Spawn', 'Info' }) do
    ModConfigMenu.RemoveSubcategory(mod.Name, v)
  end
  ModConfigMenu.AddSetting(
    mod.Name,
    'General',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return mod.state.identifyPills
      end,
      Display = function()
        return (mod.state.identifyPills and 'Identify' or 'Do not identify') .. ' pills before use'
      end,
      OnChange = function(b)
        mod.state.identifyPills = b
        if b then
          mod:identifyPills()
        end
        mod:save(true)
      end,
      Info = { 'Note: you can\'t de-identify pills', 'during the current run' }
    }
  )
  if REPENTANCE or REPENTANCE_PLUS then
    ModConfigMenu.AddSetting(
      mod.Name,
      'General',
      {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
          return mod.state.identifyGoldPills
        end,
        Display = function()
          return (mod.state.identifyGoldPills and 'Identify all gold pill effects' or 'Identify 1st gold pill effect')
        end,
        OnChange = function(b)
          mod.state.identifyGoldPills = b
          if b then
            mod:identifyGoldPillsAgain()
          end
          mod:save(true)
        end,
        Info = { 'If gold pills are identified:', 'Show the first pill effect only (default)', '-or- Show all pill effects' }
      }
    )
  end
  ModConfigMenu.AddSetting(
    mod.Name,
    'General',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return mod.state.enableItemIntegration
      end,
      Display = function()
        return (mod.state.enableItemIntegration and 'Enable' or 'Disable') .. ' item integration'
      end,
      OnChange = function(b)
        mod.state.enableItemIntegration = b
        mod:save(true)
      end,
      Info = { 'Single player only / For overriden effects', 'Items: ' .. ((REPENTANCE or REPENTANCE_PLUS) and 'phd, lucky foot, virgo, false phd' or 'phd, virgo'), '(+low health)' }
    }
  )
  ModConfigMenu.AddSpace(mod.Name, 'General')
  ModConfigMenu.AddTitle(mod.Name, 'General', 'Pill Pool')
  ModConfigMenu.AddSetting(
    mod.Name,
    'General',
    {
      Type = ModConfigMenu.OptionType.NUMBER,
      CurrentSetting = function()
        return mod.pillEffectToAddToPool
      end,
      Minimum = PillEffect.PILLEFFECT_NULL + 1,
      Maximum = mod.pillEffectsMax,
      Display = function()
        return '< ' .. mod:getPillEffectName(mod.pillEffectToAddToPool) .. ' >'
      end,
      OnChange = function(n)
        mod.pillEffectToAddToPool = n
      end,
      Info = { 'Select a pill effect to force into the pool' }
    }
  )
  ModConfigMenu.AddSetting(
    mod.Name,
    'General',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Add to pool!'
      end,
      OnChange = function(b)
        local itemPool = game:GetItemPool()
        mod.forcedPillPoolColor = itemPool:ForceAddPillEffect(mod.pillEffectToAddToPool) -- Isaac.AddPillEffectToPool
        mod.forcedPillPoolTime = game:GetFrameCount()
      end,
      Info = { 'Force a pill effect into the pool' }
    }
  )
  ModConfigMenu.AddText(mod.Name, 'General', function()
    if game:GetFrameCount() >= mod.forcedPillPoolTime + 45 then
      mod.forcedPillPoolColor = PillColor.PILL_NULL
      mod.forcedPillPoolTime = 0
    end
    
    local forcedPillPoolText = ''
    if mod.forcedPillPoolColor ~= PillColor.PILL_NULL then
      forcedPillPoolText = 'Assigned to: ' .. ((mod.showUnidentifiedPills or mod:isPillIdentified(mod.forcedPillPoolColor)) and mod:getPillColorName(mod.forcedPillPoolColor, true) or 'unidentified')
    end
    
    return forcedPillPoolText
  end)
  ModConfigMenu.AddSetting(
    mod.Name,
    'Startup',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Reset'
      end,
      OnChange = function(b)
        for i = 1, #mod.state.startupEffects do
          mod.state.startupEffects[i] = PillEffect.PILLEFFECT_NULL
        end
        mod:save(true)
      end,
      Info = { 'Reset all startup effects' }
    }
  )
  ModConfigMenu.AddSetting(
    mod.Name,
    'Startup',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Randomize'
      end,
      OnChange = function(b)
        for i = 1, #mod.state.startupEffects do
          mod.state.startupEffects[i] = mod.rng:RandomInt(mod.pillEffectsMax + 1)
        end
        mod:save(true)
      end,
      Info = { 'Randomize all startup effects' }
    }
  )
  ModConfigMenu.AddSpace(mod.Name, 'Startup')
  for i = 1, #mod.state.startupEffects do
    ModConfigMenu.AddSetting(
      mod.Name,
      'Startup',
      {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
          return mod.state.startupEffects[i]
        end,
        Minimum = PillEffect.PILLEFFECT_NULL,
        Maximum = mod.pillEffectsMax,
        Display = function()
          return '< ' .. ((mod.state.startupEffects[i] ~= PillEffect.PILLEFFECT_NULL) and mod:getPillEffectName(mod.state.startupEffects[i]) or 'None') .. ' >'
        end,
        OnChange = function(n)
          mod.state.startupEffects[i] = n
          mod:save(true)
        end,
        Info = { 'Select a startup pill effect' }
      }
    )
  end
  ModConfigMenu.AddSpace(mod.Name, 'Startup')
  ModConfigMenu.AddSetting(
    mod.Name,
    'Startup',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Apply to pool!'
      end,
      OnChange = function(b)
        mod:setStartupEffects()
      end,
      Info = { 'Force the pill effects above into the pool' }
    }
  )
  ModConfigMenu.AddSetting(
    mod.Name,
    'Colors',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Reset'
      end,
      OnChange = function(b)
        for _, v in pairs(mod.state.pillColors) do
          v.weightStd = 0
          if REPENTANCE or REPENTANCE_PLUS then
            v.weightHorse = 0
          end
          mod:save(true)
        end
      end,
      Info = { 'Reset all colors to zero' }
    }
  )
  ModConfigMenu.AddSetting(
    mod.Name,
    'Colors',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Randomize'
      end,
      OnChange = function(b)
        for _, v in pairs(mod.state.pillColors) do
          v.weightStd = mod.rng:RandomInt(11)
          if REPENTANCE or REPENTANCE_PLUS then
            v.weightHorse = mod.rng:RandomInt(11)
          end
          mod:save(true)
        end
      end,
      Info = { 'Randomize all colors' }
    }
  )
  for i = PillColor.PILL_NULL + 1, PillColor.NUM_PILLS - 1 do
    ModConfigMenu.AddSpace(mod.Name, 'Colors')
    local pillColorName = mod:getPillColorName(i)
    local pillColorNameOrig = mod:getPillColorName(i, true)
    ModConfigMenu.AddTitle(mod.Name, 'Colors', pillColorNameOrig)
    if pillColorName ~= pillColorNameOrig then
      ModConfigMenu.AddText(mod.Name, 'Colors', '(' .. pillColorName .. ')')
    end
    ModConfigMenu.AddSetting(
      mod.Name,
      'Colors',
      {
        Type = ModConfigMenu.OptionType.SCROLL,
        CurrentSetting = function()
          return mod.state.pillColors[tostring(i)].weightStd
        end,
        Display = function()
          return 'Standard: $scroll' .. mod.state.pillColors[tostring(i)].weightStd
        end,
        OnChange = function(n)
          mod.state.pillColors[tostring(i)].weightStd = n
          mod:save(true)
        end,
        Info = function()
          mod:renderPillColor(i)
          return { 'Choose relative weights for random pills' }
        end
      }
    )
    if REPENTANCE or REPENTANCE_PLUS then
      ModConfigMenu.AddSetting(
        mod.Name,
        'Colors',
        {
          Type = ModConfigMenu.OptionType.SCROLL,
          CurrentSetting = function()
            return mod.state.pillColors[tostring(i)].weightHorse
          end,
          Display = function()
            return 'Horse: $scroll' .. mod.state.pillColors[tostring(i)].weightHorse
          end,
          OnChange = function(n)
            mod.state.pillColors[tostring(i)].weightHorse = n
            mod:save(true)
          end,
          Info = function()
            mod:renderPillColor(i)
            return { 'Choose relative weights for random pills' }
          end
        }
      )
    end
  end
  ModConfigMenu.AddSetting(
    mod.Name,
    'Effects 1',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Reset'
      end,
      OnChange = function(b)
        if not mod.state.shuffledAndHidden then
          for _, v in pairs(mod.state.pillColors) do
            v.effect = PillEffect.PILLEFFECT_NULL
          end
          mod:save(true)
        end
      end,
      Info = { 'Reset all effect overrides' }
    }
  )
  ModConfigMenu.AddSetting(
    mod.Name,
    'Effects 1',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Randomize'
      end,
      OnChange = function(b)
        if not mod.state.shuffledAndHidden then
          for _, v in pairs(mod.state.pillColors) do
            v.effect = mod.rng:RandomInt(mod.pillEffectsMax + 1)
          end
          mod:save(true)
        end
      end,
      Info = { 'Randomize all effect overrides' }
    }
  )
  ModConfigMenu.AddSetting(
    mod.Name,
    'Effects 1',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return mod.state.shuffledAndHidden
      end,
      Display = function()
        return mod.state.shuffledAndHidden and 'Shuffled & Hidden' or 'Shuffle & Hide'
      end,
      OnChange = function(b)
        mod.state.shuffledAndHidden = b
        
        if b then
          local tbl = {}
          for _, v in pairs(mod.state.pillColors) do
            if v.effect ~= PillEffect.PILLEFFECT_NULL then
              table.insert(tbl, v.effect)
            end
          end
          for _, v in pairs(mod.state.pillColors) do
            if v.effect ~= PillEffect.PILLEFFECT_NULL then
              v.effect = table.remove(tbl, mod.rng:RandomInt(#tbl) + 1)
            end
          end
        end
        
        mod:save(true)
      end,
      Info = { 'Shuffle all overriden effects', '& hide the results' }
    }
  )
  for i = PillColor.PILL_NULL + 1, PillColor.NUM_PILLS - 1 do
    ModConfigMenu.AddSpace(mod.Name, 'Effects 1')
    local pillColorName = mod:getPillColorName(i)
    local pillColorNameOrig = mod:getPillColorName(i, true)
    ModConfigMenu.AddTitle(mod.Name, 'Effects 1', pillColorNameOrig)
    if pillColorName ~= pillColorNameOrig then
      ModConfigMenu.AddText(mod.Name, 'Effects 1', '(' .. pillColorName .. ')')
    end
    ModConfigMenu.AddSetting(
      mod.Name,
      'Effects 1',
      {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
          return mod.state.pillColors[tostring(i)].effect
        end,
        Minimum = PillEffect.PILLEFFECT_NULL,
        Maximum = mod.pillEffectsMax,
        Display = function()
          return mod.state.shuffledAndHidden and 'Hidden' or mod:getPillEffectName(mod.state.pillColors[tostring(i)].effect)
        end,
        OnChange = function(n)
          if not mod.state.shuffledAndHidden then
            mod.state.pillColors[tostring(i)].effect = n
            mod:save(true)
          end
        end,
        Info = function()
          mod:renderPillColor(i)
          return { 'Select a pill effect override' }
        end
      }
    )
  end
  ModConfigMenu.AddSetting(
    mod.Name,
    'Effects 2',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Reset'
      end,
      OnChange = function(b)
        for k, _ in pairs(mod.state.pillEffects) do
          mod.state.pillEffects[k] = PillEffect.PILLEFFECT_NULL
        end
        mod:save(true)
      end,
      Info = { 'Reset all effect overrides' }
    }
  )
  ModConfigMenu.AddSetting(
    mod.Name,
    'Effects 2',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Randomize'
      end,
      OnChange = function(b)
        for k, _ in pairs(mod.state.pillEffects) do
          mod.state.pillEffects[k] = mod.rng:RandomInt(mod.pillEffectsMax + 1)
        end
        mod:save(true)
      end,
      Info = { 'Randomize all effect overrides' }
    }
  )
  for i = PillEffect.PILLEFFECT_NULL + 1, PillEffect.NUM_PILL_EFFECTS - 1 do
    ModConfigMenu.AddSpace(mod.Name, 'Effects 2')
    ModConfigMenu.AddTitle(mod.Name, 'Effects 2', mod:getPillEffectName(i))
    ModConfigMenu.AddSetting(
      mod.Name,
      'Effects 2',
      {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
          return mod.state.pillEffects[tostring(i)]
        end,
        Minimum = PillEffect.PILLEFFECT_NULL,
        Maximum = mod.pillEffectsMax,
        Display = function()
          return mod:getPillEffectName(mod.state.pillEffects[tostring(i)])
        end,
        OnChange = function(n)
          mod.state.pillEffects[tostring(i)] = n
          mod:save(true)
        end,
        Info = { 'Select a pill effect override' }
      }
    )
  end
  ModConfigMenu.AddTitle(mod.Name, 'Spawn', 'Random')
  ModConfigMenu.AddSetting(
    mod.Name,
    'Spawn',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return false
      end,
      Display = function()
        return 'Pill'
      end,
      OnChange = function(b)
        mod:spawnPill(PillColor.PILL_NULL, false)
      end,
      Info = { 'Spawn a random pill' }
    }
  )
  for i = PillColor.PILL_NULL + 1, PillColor.NUM_PILLS - 1 do
    ModConfigMenu.AddSpace(mod.Name, 'Spawn')
    local pillColorName = mod:getPillColorName(i)
    local pillColorNameOrig = mod:getPillColorName(i, true)
    ModConfigMenu.AddTitle(mod.Name, 'Spawn', pillColorNameOrig)
    if pillColorName ~= pillColorNameOrig then
      ModConfigMenu.AddText(mod.Name, 'Spawn', '(' .. pillColorName .. ')')
    end
    ModConfigMenu.AddSetting(
      mod.Name,
      'Spawn',
      {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
          return false
        end,
        Display = function()
          return 'Standard'
        end,
        OnChange = function(b)
          mod:spawnPill(i, false)
        end,
        Info = function()
          mod:renderPillColor(i)
          return { 'Spawn a standard pill' }
        end
      }
    )
    if REPENTANCE or REPENTANCE_PLUS then
      ModConfigMenu.AddSetting(
        mod.Name,
        'Spawn',
        {
          Type = ModConfigMenu.OptionType.BOOLEAN,
          CurrentSetting = function()
            return false
          end,
          Display = function()
            return 'Horse'
          end,
          OnChange = function(b)
            mod:spawnPill(i, true)
          end,
          Info = function()
            mod:renderPillColor(i)
            return { 'Spawn a horse pill' }
          end
        }
      )
    end
  end
  ModConfigMenu.AddSetting(
    mod.Name,
    'Info',
    {
      Type = ModConfigMenu.OptionType.BOOLEAN,
      CurrentSetting = function()
        return mod.showUnidentifiedPills
      end,
      Display = function()
        return (mod.showUnidentifiedPills and 'Show' or 'Hide') .. ' unidentified pills'
      end,
      OnChange = function(b)
        mod.showUnidentifiedPills = b
      end,
      Info = { 'Show or hide unidentified pills below' }
    }
  )
  for i = PillColor.PILL_NULL + 1, PillColor.NUM_PILLS - 1 do
    ModConfigMenu.AddSpace(mod.Name, 'Info')
    local pillColorName = mod:getPillColorName(i)
    local pillColorNameOrig = mod:getPillColorName(i, true)
    ModConfigMenu.AddTitle(mod.Name, 'Info', pillColorNameOrig)
    if pillColorName ~= pillColorNameOrig then
      ModConfigMenu.AddText(mod.Name, 'Info', '(' .. pillColorName .. ')')
    end
    ModConfigMenu.AddSetting(
      mod.Name,
      'Info',
      {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
          return false
        end,
        Display = function()
          local itemPool = game:GetItemPool()
          if mod.showUnidentifiedPills or mod:isPillIdentified(i) then
            return mod:getPillEffectName(itemPool:GetPillEffect(i, nil))
          end
          
          return 'Not identified'
        end,
        OnChange = function(b)
          -- nothing to do
        end,
        Info = function()
          mod:renderPillColor(i)
          return { 'Pill as it appears in the pill pool', '(including any overrides)' }
        end
      }
    )
  end
end
-- end ModConfigMenu --

mod:seedRng()
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.onGameStart)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.onGameExit)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdate)
mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.onUsePill)
mod:AddCallback(ModCallbacks.MC_GET_PILL_COLOR, mod.getPillColor)
mod:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, mod.getPillEffect)

if ModConfigMenu then
  mod:setupModConfigMenu()
end