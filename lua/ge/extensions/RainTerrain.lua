-- RainTerrain.lua
-- Code by tmaster5000,, chatgpt and snippets from daniel-w's floodmod with permission

local M = {}

local groundModels = {}

local referenceDry = {
  roughnessCoefficient        = 0.00,
  slidingFrictionCoefficient  = 0.70,
  staticFrictionCoefficient   = 0.98,
  stribeckVelocity            = 4.50
}

local referenceWet = {
  roughnessCoefficient        = 0.20,
  slidingFrictionCoefficient  = 0.55,
  staticFrictionCoefficient   = 0.92,
  stribeckVelocity            = 5.00
}

-- Utility functions
local function clamp(value, minValue, maxValue)
  return math.max(minValue, math.min(maxValue, value))
end

local function lerp(a, b, t)
  return a + (b - a) * t
end

local function unifiedScaledValue(originalValue, dryRef, wetRef, wetness)
  local t = wetness / 10
  if dryRef == 0 then
    return originalValue + (wetRef * t)
  else
    local ratio = wetRef / dryRef
    return originalValue * lerp(1.0, ratio, t)
  end
end

local function setValue(name, gm, property, val)
  gm.data[property] = val
  be:setGroundModel(name, gm.data)
  if #groundModels[name].aliases > 0 then
    for _, alias in pairs(groundModels[name].aliases) do
      be:setGroundModel(alias, gm.data)
      print("set this shit")
    end
  end
end

local function getBasePropertyValue(gm, property)
  if gm and gm.cdata and gm.cdata[property] then
    return gm.cdata[property]
  end
  return 0
end

-- Scales all ground models based on the current wetness value.
local function scaleAllGroundModels(wetness)

  for name, gm in pairs(groundModels) do
    local baseRoughness = getBasePropertyValue(gm, "roughnessCoefficient")
    local baseSliding   = getBasePropertyValue(gm, "slidingFrictionCoefficient")
    local baseStatic    = getBasePropertyValue(gm, "staticFrictionCoefficient")
    local baseStribeck  = getBasePropertyValue(gm, "stribeckVelocity")

    local newRoughness = unifiedScaledValue(
      baseRoughness,
      referenceDry.roughnessCoefficient,
      referenceWet.roughnessCoefficient,
      wetness
    )
    local newSliding = unifiedScaledValue(
      baseSliding,
      referenceDry.slidingFrictionCoefficient,
      referenceWet.slidingFrictionCoefficient,
      wetness
    )
    local newStatic = unifiedScaledValue(
      baseStatic,
      referenceDry.staticFrictionCoefficient,
      referenceWet.staticFrictionCoefficient,
      wetness
    )
    local newStribeck = unifiedScaledValue(
      baseStribeck,
      referenceDry.stribeckVelocity,
      referenceWet.stribeckVelocity,
      wetness
    )

    setValue(name, gm, "roughnessCoefficient",       newRoughness)
    setValue(name, gm, "slidingFrictionCoefficient", newSliding)
    setValue(name, gm, "staticFrictionCoefficient",  newStatic)
    setValue(name, gm, "stribeckVelocity",           newStribeck)
  end
end

-- Sets up the ground models from the core_environment.
local function setup()
  local gms = tableKeys(core_environment.groundModels)
  table.sort(gms)

  local total = #gms
  local i = 1
  for _, k in ipairs(gms) do
    local v = core_environment.groundModels[k]
    groundModels[k] = {
      data    = v.cdata,
      isAlias = v.isAlias,
      parent  = v.parent,
      aliases = {},
      active  = true,
      color   = rainbowColor(total, i, 1),
    }
    groundModels[k].cdata = {
      roughnessCoefficient       = v.cdata.roughnessCoefficient or 0,
      slidingFrictionCoefficient = v.cdata.slidingFrictionCoefficient or 0,
      staticFrictionCoefficient  = v.cdata.staticFrictionCoefficient or 0,
      stribeckVelocity           = v.cdata.stribeckVelocity or 0
    }
    i = i + 1
  end

  -- Fill in aliases
  for _, k in ipairs(gms) do
    local gm = groundModels[k]
    if gm.isAlias == true then
      table.insert(groundModels[gm.parent].aliases, k)
    end
  end
end

-- Returns the scaled properties for a given ground model at the provided wetness.
local function getScaledProperties(gm, wetness)
  local baseRoughness = getBasePropertyValue(gm, "roughnessCoefficient")
  local baseSliding   = getBasePropertyValue(gm, "slidingFrictionCoefficient")
  local baseStatic    = getBasePropertyValue(gm, "staticFrictionCoefficient")
  local baseStribeck  = getBasePropertyValue(gm, "stribeckVelocity")

  return {
    roughnessCoefficient       = unifiedScaledValue(
      baseRoughness,
      referenceDry.roughnessCoefficient,
      referenceWet.roughnessCoefficient,
      wetness
    ),
    slidingFrictionCoefficient = unifiedScaledValue(
      baseSliding,
      referenceDry.slidingFrictionCoefficient,
      referenceWet.slidingFrictionCoefficient,
      wetness
    ),
    staticFrictionCoefficient  = unifiedScaledValue(
      baseStatic,
      referenceDry.staticFrictionCoefficient,
      referenceWet.staticFrictionCoefficient,
      wetness
    ),
    stribeckVelocity           = unifiedScaledValue(
      baseStribeck,
      referenceDry.stribeckVelocity,
      referenceWet.stribeckVelocity,
      wetness
    )
  }
end

local function getGroundModels()
  return groundModels
end

local function onExtensionLoaded()
  setup()
end

M.setup = setup
M.scaleAllGroundModels = scaleAllGroundModels
M.getScaledProperties = getScaledProperties
M.getGroundModels = getGroundModels
M.onExtensionLoaded = onExtensionLoaded

return M
