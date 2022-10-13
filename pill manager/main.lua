local mod = RegisterMod('Pill Manager', 1)
local json = require('json')
local game = Game()

mod.showUnidentifiedPills = false
mod.pillEffectToAddToPool = PillEffect.PILLEFFECT_NULL + 1
mod.forcedPillPoolColor = PillColor.PILL_NULL
mod.forcedPillPoolTime = 0
mod.rng = RNG()

-- there's no standard api for adding pill colors
mod.pillColors = {
                   [PillColor.PILL_BLUE_BLUE] = 'Blue-Blue',           -- 1
                   [PillColor.PILL_WHITE_BLUE] = 'White-Blue',         -- 2
                   [PillColor.PILL_ORANGE_ORANGE] = 'Orange-Orange',   -- 3
                   [PillColor.PILL_WHITE_WHITE] = 'White-White',       -- 4
                   [PillColor.PILL_REDDOTS_RED] = 'Dots-Red',          -- 5
                   [PillColor.PILL_PINK_RED] = 'Pink-Red',             -- 6
                   [PillColor.PILL_BLUE_CADETBLUE] = 'Blue-Cadetblue', -- 7
                   [PillColor.PILL_YELLOW_ORANGE] = 'Yellow-Orange',   -- 8
                   [PillColor.PILL_ORANGEDOTS_WHITE] = 'Dots-White',   -- 9
                   [PillColor.PILL_WHITE_AZURE] = 'White-Azure',       -- 10
                   [PillColor.PILL_BLACK_YELLOW] = 'Black-Yellow',     -- 11
                   [PillColor.PILL_WHITE_BLACK] = 'White-Black',       -- 12
                   [PillColor.PILL_WHITE_YELLOW] = 'White-Yellow',     -- 13
                   [PillColor.PILL_GOLD] = 'Gold-Gold'                 -- 14
                 }

mod.pillEffects = {
                    [PillEffect.PILLEFFECT_NULL] = 'Not overriden' -- -1
                  }
mod.pillEffectsMax = PillEffect.PILLEFFECT_NULL

-- the api returns labels instead of names due to multi-language support which isn't properly exposed in the api
mod.pillEffectLabels = {
                         ['#BAD_GAS_NAME'] = 'Bad Gas',                                                        -- 0
                         ['#BAD_TRIP_NAME'] = 'Bad Trip',                                                      -- 1
                         ['#BALLS_OF_STEEL_NAME'] = 'Balls of Steel',                                          -- 2
                         ['#BOMBS_ARE_KEY_NAME'] = 'Bombs are Key',                                            -- 3
                         ['#EXPLOSIVE_DIARRHEA_NAME'] = 'Explosive Diarrhea',                                  -- 4
                         ['#FULL_HEALTH_NAME'] = 'Full Health',                                                -- 5
                         ['#HEALTH_DOWN_NAME'] = 'Health Down',                                                -- 6
                         ['#HEALTH_UP_NAME'] = 'Health Up',                                                    -- 7
                         ['#I_FOUND_PILLS_NAME'] = 'I Found Pills',                                            -- 8
                         ['#PUBERTY_NAME'] = 'Puberty',                                                        -- 9
                         ['#PRETTY_FLY_NAME'] = 'Pretty Fly',                                                  -- 10
                         ['#RANGE_DOWN_NAME'] = 'Range Down',                                                  -- 11
                         ['#RANGE_UP_NAME'] = 'Range Up',                                                      -- 12
                         ['#SPEED_DOWN_NAME'] = 'Speed Down',                                                  -- 13
                         ['#SPEED_UP_NAME'] = 'Speed Up',                                                      -- 14
                         ['#TEARS_DOWN_NAME'] = 'Tears Down',                                                  -- 15
                         ['#TEARS_UP_NAME'] = 'Tears Up',                                                      -- 16
                         ['#LUCK_DOWN_NAME'] = 'Luck Down',                                                    -- 17
                         ['#LUCK_UP_NAME'] = 'Luck Up',                                                        -- 18
                         ['#TELEPILLS_NAME'] = 'Telepills',                                                    -- 19
                         ['#48_HOUR_ENERGY_NAME'] = '48 Hour Energy',                                          -- 20
                         ['#HEMATEMESIS_NAME'] = 'Hematemesis',                                                -- 21
                         ['#PARALYSIS_NAME'] = 'Paralysis',                                                    -- 22
                         ['#I_CAN_SEE_FOREVER_NAME'] = 'I can see forever!',                                   -- 23
                         ['#PHEROMONES_NAME'] = 'Pheromones',                                                  -- 24
                         ['#AMNESIA_NAME'] = 'Amnesia',                                                        -- 25
                         ['#LEMON_PARTY_NAME'] = 'Lemon Party',                                                -- 26
                         ['#R_U_A_WIZARD_NAME'] = 'R U A Wizard?',                                             -- 27
                         ['#PERCS_NAME'] = 'Percs!',                                                           -- 28
                         ['#ADDICTED_NAME'] = 'Addicted!',                                                     -- 29
                         ['#RELAX_NAME'] = 'Re-Lax',                                                           -- 30
                         ['#QUESTION_MARKS_NAME'] = '???',                                                     -- 31
                         ['#ONE_MAKES_YOU_LARGER_NAME'] = 'One makes you larger',                              -- 32
                         ['#ONE_MAKES_YOU_SMALL_NAME'] = 'One makes you small',                                -- 33
                         ['#INFESTED_NAME_1'] = 'Infested!',                                                   -- 34
                         ['#INFESTED_NAME_2'] = 'Infested?',                                                   -- 35
                         ['#POWER_PILL_NAME'] = 'Power Pill!',                                                 -- 36
                         ['#RETRO_VISION_NAME'] = 'Retro Vision',                                              -- 37
                         ['#FRIENDS_TILL_THE_END_NAME'] = 'Friends Till The End!',                             -- 38
                         ['#XLAX_NAME'] = 'X-Lax',                                                             -- 39
                         ['#SOMETHINGS_WRONG_NAME'] = 'Something\'s wrong...',                                 -- 40
                         ['#IM_DROWSY_NAME'] = 'I\'m Drowsy...',                                               -- 41
                         ['#IM_EXCITED_NAME'] = 'I\'m Excited!!!',                                             -- 42
                         ['#GULP_NAME'] = 'Gulp!',                                                             -- 43
                         ['#HORF_NAME'] = 'Horf!',                                                             -- 44
                         ['#FEELS_LIKE_IM_WALKING_ON_SUNSHINE_NAME'] = 'Feels like I\'m walking on sunshine!', -- 45
                         ['#VURP_NAME'] = 'Vurp!',                                                             -- 46
                         ['#SHOT_SPEED_DOWN_NAME'] = 'Shot Speed Down',                                        -- 47
                         ['#SHOT_SPEED_UP_NAME'] = 'Shot Speed Up',                                            -- 48
                         ['#EXPERIMENTAL_PILL_NAME'] = 'Experimental Pill'                                     -- 49
                       }

mod.state = {}
mod.state.identifyPills = false
mod.state.shuffledAndHidden = false
mod.state.pillColors = {
                         { color = PillColor.PILL_BLUE_BLUE,        effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_WHITE_BLUE,       effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_ORANGE_ORANGE,    effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_WHITE_WHITE,      effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_REDDOTS_RED,      effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_PINK_RED,         effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_BLUE_CADETBLUE,   effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_YELLOW_ORANGE,    effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_ORANGEDOTS_WHITE, effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_WHITE_AZURE,      effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_BLACK_YELLOW,     effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_WHITE_BLACK,      effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_WHITE_YELLOW,     effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 },
                         { color = PillColor.PILL_GOLD,             effect = PillEffect.PILLEFFECT_NULL, weightStd = 0, weightHorse = 0 }
                       }
mod.state.pillEffects = {
                          { effect = PillEffect.PILLEFFECT_BAD_GAS,              override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_BAD_TRIP,             override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_BALLS_OF_STEEL,       override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_BOMBS_ARE_KEYS,       override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_EXPLOSIVE_DIARRHEA,   override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_FULL_HEALTH,          override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_HEALTH_DOWN,          override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_HEALTH_UP,            override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_I_FOUND_PILLS,        override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_PUBERTY,              override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_PRETTY_FLY,           override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_RANGE_DOWN,           override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_RANGE_UP,             override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_SPEED_DOWN,           override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_SPEED_UP,             override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_TEARS_DOWN,           override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_TEARS_UP,             override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_LUCK_DOWN,            override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_LUCK_UP,              override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_TELEPILLS,            override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_48HOUR_ENERGY,        override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_HEMATEMESIS,          override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_PARALYSIS,            override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_SEE_FOREVER,          override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_PHEROMONES,           override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_AMNESIA,              override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_LEMON_PARTY,          override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_WIZARD,               override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_PERCS,                override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_ADDICTED,             override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_RELAX,                override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_QUESTIONMARK,         override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_LARGER,               override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_SMALLER,              override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_INFESTED_EXCLAMATION, override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_INFESTED_QUESTION,    override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_POWER,                override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_RETRO_VISION,         override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_FRIENDS_TILL_THE_END, override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_X_LAX,                override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_SOMETHINGS_WRONG,     override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_IM_DROWSY,            override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_IM_EXCITED,           override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_GULP,                 override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_HORF,                 override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_SUNSHINE,             override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_VURP,                 override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_SHOT_SPEED_DOWN,      override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_SHOT_SPEED_UP,        override = PillEffect.PILLEFFECT_NULL },
                          { effect = PillEffect.PILLEFFECT_EXPERIMENTAL,         override = PillEffect.PILLEFFECT_NULL }
                        }

function mod:onGameStart(isContinue)
  mod:fillPillEffects()
  mod:setupModConfigMenu()
  
  if mod:HasData() then
    local _, state = pcall(json.decode, mod:LoadData())
    
    if type(state) == 'table' then
      if type(state.identifyPills) == 'boolean' then
        mod.state.identifyPills = state.identifyPills
      end
      if type(state.shuffledAndHidden) == 'boolean' then
        mod.state.shuffledAndHidden = state.shuffledAndHidden
      end
      if type(state.pillColors) == 'table' then
        for _, v in ipairs(state.pillColors) do
          if math.type(v.color) == 'integer' and v.color >= PillColor.PILL_BLUE_BLUE and v.color <= PillColor.PILL_GOLD then
            for _, w in ipairs(mod.state.pillColors) do
              if v.color == w.color then
                if math.type(v.effect) == 'integer' and v.effect >= PillEffect.PILLEFFECT_NULL and v.effect <= mod.pillEffectsMax then
                  w.effect = v.effect
                end
                if math.type(v.weightStd) == 'integer' and v.weightStd >= 0 and v.weightStd <= 11 then
                  w.weightStd = v.weightStd
                end
                if math.type(v.weightHorse) == 'integer' and v.weightHorse >= 0 and v.weightHorse <= 11 then
                  w.weightHorse = v.weightHorse
                end
                break
              end
            end
          end
        end
      end
      if type(state.pillEffects) == 'table' then
        for _, v in ipairs(state.pillEffects) do
          if math.type(v.effect) == 'integer' and v.effect >= PillEffect.PILLEFFECT_BAD_GAS and v.effect <= PillEffect.PILLEFFECT_EXPERIMENTAL then
            for _, w in ipairs(mod.state.pillEffects) do
              if v.effect == w.effect then
                if math.type(v.override) == 'integer' and v.override >= PillEffect.PILLEFFECT_NULL and v.override <= mod.pillEffectsMax then
                  w.override = v.override
                end
                break
              end
            end
          end
        end
      end
    end
  end
  
  for _, v in ipairs(mod.state.pillColors) do
    if v.effect < PillEffect.PILLEFFECT_NULL or v.effect > mod.pillEffectsMax then
      v.effect = PillEffect.PILLEFFECT_NULL
    end
  end
  for _, v in ipairs(mod.state.pillEffects) do
    if v.override < PillEffect.PILLEFFECT_NULL or v.override > mod.pillEffectsMax then
      v.override = PillEffect.PILLEFFECT_NULL
    end
  end
  
  if not isContinue and mod.state.identifyPills then
    mod:identifyPills()
  end
end

function mod:onGameExit()
  mod:SaveData(json.encode(mod.state))
  mod:seedRng()
  
  mod.showUnidentifiedPills = false
  mod.forcedPillPoolColor = PillColor.PILL_NULL
  mod.forcedPillPoolTime = 0
end

function mod:getPillColor(seed)
  local weightedColors = {}
  for _, v in ipairs(mod.state.pillColors) do
    for i = 1, v.weightStd do
      table.insert(weightedColors, v.color)
    end
    for i = 1, v.weightHorse do
      table.insert(weightedColors, PillColor.PILL_GIANT_FLAG + v.color)
    end
  end
  
  local weightedColorsCount = #weightedColors
  if weightedColorsCount > 0 then
    local rng = RNG()
    rng:SetSeed(seed, 1)
    return weightedColors[rng:RandomInt(weightedColorsCount) + 1]
  end
  
  return nil
end

function mod:getPillEffect(pillEffect, pillColor)
  local colorOverride = mod:getPillColorOverride(pillColor)
  if colorOverride ~= PillEffect.PILLEFFECT_NULL then
    return colorOverride
  end
  
  local effectOverride = mod:getPillEffectOverride(pillEffect)
  if effectOverride ~= PillEffect.PILLEFFECT_NULL then
    return effectOverride
  end
  
  return pillEffect
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
      if i <= 49 then
        -- it doesn't appear that you can remove pills from the XML (w/o crashing the game), but the names could be altered
        mod.pillEffects[pillEffect.ID] = mod:lookupPillEffectName(pillEffect.Name)
      else
        mod.pillEffects[pillEffect.ID] = '(M) ' .. pillEffect.Name
      end
      mod.pillEffectsMax = pillEffect.ID
    end
  end
end

function mod:getPillColorName(color)
  local name = mod.pillColors[color]
  if name then
    return name
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
  for _, v in ipairs(mod.state.pillColors) do
    if v.color == color then
      return v.effect
    end
  end
  
  return PillEffect.PILLEFFECT_NULL
end

function mod:getPillEffectOverride(effect)
  for _, v in ipairs(mod.state.pillEffects) do
    if v.effect == effect then
      return v.override
    end
  end
  
  return PillEffect.PILLEFFECT_NULL
end

function mod:identifyPills()
  local itemPool = game:GetItemPool()
  for color, _ in pairs(mod.pillColors) do
    itemPool:IdentifyPill(color)
  end
end

function mod:spawnPill(color, isHorse)
  local player = game:GetPlayer(0)
  local pill = (color ~= PillColor.PILL_NULL and isHorse) and PillColor.PILL_GIANT_FLAG + color or color
  Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pill, Isaac.GetFreeNearPosition(player.Position, 3), Vector(0,0), nil)
end

function mod:seedRng()
  repeat
    local rand = Random()  -- 0 to 2^32
    if rand > 0 then       -- if this is 0, it causes a crash later on
      mod.rng:SetSeed(rand, 1)
    end
  until(rand > 0)
end

-- start ModConfigMenu --
function mod:setupModConfigMenu()
  if ModConfigMenu == nil then
    return
  end
  
  for _, v in ipairs({ 'General', 'Colors', 'Effects 1', 'Effects 2', 'Spawn', 'Info' }) do
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
      end,
      Info = { 'Note: you can\'t de-identify pills', 'during the current run' }
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
        mod.forcedPillPoolColor = itemPool:ForceAddPillEffect(mod.pillEffectToAddToPool)
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
      local itemPool = game:GetItemPool()
      forcedPillPoolText = 'Assigned to: ' .. ((mod.showUnidentifiedPills or itemPool:IsPillIdentified(mod.forcedPillPoolColor)) and mod:getPillColorName(mod.forcedPillPoolColor) or 'unidentified')
    end
    
    return forcedPillPoolText
  end)
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
        for _, v in ipairs(mod.state.pillColors) do
          v.weightStd = 0
          v.weightHorse = 0
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
        for _, v in ipairs(mod.state.pillColors) do
          v.weightStd = mod.rng:RandomInt(11)
          v.weightHorse = mod.rng:RandomInt(11)
        end
      end,
      Info = { 'Randomize all colors' }
    }
  )
  for _, v in ipairs(mod.state.pillColors) do
    ModConfigMenu.AddSpace(mod.Name, 'Colors')
    ModConfigMenu.AddTitle(mod.Name, 'Colors', mod:getPillColorName(v.color))
    ModConfigMenu.AddSetting(
      mod.Name,
      'Colors',
      {
        Type = ModConfigMenu.OptionType.SCROLL,
        CurrentSetting = function()
          return v.weightStd
        end,
        Display = function()
          return 'Standard: $scroll' .. v.weightStd
        end,
        OnChange = function(n)
          v.weightStd = n
        end,
        Info = { 'Choose relative weights for random pills' }
      }
    )
    ModConfigMenu.AddSetting(
      mod.Name,
      'Colors',
      {
        Type = ModConfigMenu.OptionType.SCROLL,
        CurrentSetting = function()
          return v.weightHorse
        end,
        Display = function()
          return 'Horse: $scroll' .. v.weightHorse
        end,
        OnChange = function(n)
          v.weightHorse = n
        end,
        Info = { 'Choose relative weights for random pills' }
      }
    )
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
          for _, v in ipairs(mod.state.pillColors) do
            v.effect = PillEffect.PILLEFFECT_NULL
          end
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
          for _, v in ipairs(mod.state.pillColors) do
            v.effect = mod.rng:RandomInt(mod.pillEffectsMax + 1)
          end
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
          for _, v in ipairs(mod.state.pillColors) do
            if v.effect ~= PillEffect.PILLEFFECT_NULL then
              table.insert(tbl, v.effect)
            end
          end
          for _, v in ipairs(mod.state.pillColors) do
            if v.effect ~= PillEffect.PILLEFFECT_NULL then
              v.effect = table.remove(tbl, mod.rng:RandomInt(#tbl) + 1)
            end
          end
        end
      end,
      Info = { 'Shuffle all overriden effects', '& hide the results' }
    }
  )
  for _, v in ipairs(mod.state.pillColors) do
    ModConfigMenu.AddSpace(mod.Name, 'Effects 1')
    ModConfigMenu.AddTitle(mod.Name, 'Effects 1', mod:getPillColorName(v.color))
    ModConfigMenu.AddSetting(
      mod.Name,
      'Effects 1',
      {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
          return v.effect
        end,
        Minimum = PillEffect.PILLEFFECT_NULL,
        Maximum = mod.pillEffectsMax,
        Display = function()
          return mod.state.shuffledAndHidden and 'Hidden' or mod:getPillEffectName(v.effect)
        end,
        OnChange = function(n)
          if not mod.state.shuffledAndHidden then
            v.effect = n
          end
        end,
        Info = { 'Select a pill effect override' }
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
        for _, v in ipairs(mod.state.pillEffects) do
          v.override = PillEffect.PILLEFFECT_NULL
        end
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
        for _, v in ipairs(mod.state.pillEffects) do
          v.override = mod.rng:RandomInt(mod.pillEffectsMax + 1)
        end
      end,
      Info = { 'Randomize all effect overrides' }
    }
  )
  for _, v in ipairs(mod.state.pillEffects) do
    ModConfigMenu.AddSpace(mod.Name, 'Effects 2')
    ModConfigMenu.AddTitle(mod.Name, 'Effects 2', mod:getPillEffectName(v.effect))
    ModConfigMenu.AddSetting(
      mod.Name,
      'Effects 2',
      {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
          return v.override
        end,
        Minimum = PillEffect.PILLEFFECT_NULL,
        Maximum = mod.pillEffectsMax,
        Display = function()
          return mod:getPillEffectName(v.override)
        end,
        OnChange = function(n)
          v.override = n
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
  for _, v in ipairs(mod.state.pillColors) do
    ModConfigMenu.AddSpace(mod.Name, 'Spawn')
    ModConfigMenu.AddTitle(mod.Name, 'Spawn', mod:getPillColorName(v.color))
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
          mod:spawnPill(v.color, false)
        end,
        Info = { 'Spawn a standard pill' }
      }
    )
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
          mod:spawnPill(v.color, true)
        end,
        Info = { 'Spawn a horse pill' }
      }
    )
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
  for _, v in ipairs(mod.state.pillColors) do
    ModConfigMenu.AddSpace(mod.Name, 'Info')
    ModConfigMenu.AddTitle(mod.Name, 'Info', mod:getPillColorName(v.color))
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
          if mod.showUnidentifiedPills or itemPool:IsPillIdentified(v.color) then
            return mod:getPillEffectName(itemPool:GetPillEffect(v.color, nil))
          end
          
          return 'Not identified'
        end,
        OnChange = function(b)
          -- nothing to do
        end,
        Info = { 'Pill as it appears in the pill pool', '(including any overrides)' }
      }
    )
  end
end
-- end ModConfigMenu --

mod:seedRng()
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.onGameStart)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.onGameExit)
mod:AddCallback(ModCallbacks.MC_GET_PILL_COLOR, mod.getPillColor)
mod:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, mod.getPillEffect)

mod:setupModConfigMenu()