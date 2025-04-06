-- RainFX.lua
-- Code by tmaster1000, chatgpt and snippets from daniel-w's floodmod with permission

local M = {}

local originalSunScale = nil
local wetness = 0
local function clamp(value, minValue, maxValue)
  return math.max(minValue, math.min(maxValue, value))
end

local function extractNumber(val)
  if type(val) == "number" then
    return val
  elseif type(val) == "table" then
    return val.value or val[1]
  end
  return nil
end

local function findObject(objectName, className)
  local obj = scenetree.findObject(objectName)
  if obj then return obj end
  if not className then return nil end

  local objects = scenetree.findClassObjects(className)
  for _, name in pairs(objects) do
    local object = scenetree.findObject(name)
    if string.find(name, objectName) then return object end
  end
  return nil
end

-- Called when the world is ready to initialize sun scale.
local function onWorldReadyState()
  local scatterSkyObj = scenetree.findObject("sunsky")
  if not scatterSkyObj then
    return
  end

  if not originalSunScale then
    local currentScale = scatterSkyObj.sunScale
    local x, y, z, w
    if currentScale.x then
      x = extractNumber(currentScale.x)
      y = extractNumber(currentScale.y)
      z = extractNumber(currentScale.z)
      w = extractNumber(currentScale.w)
    else
      x = extractNumber(currentScale[1])
      y = extractNumber(currentScale[2])
      z = extractNumber(currentScale[3])
      w = extractNumber(currentScale[4])
    end

    if not (x and y and z and w) then
      return
    end

    originalSunScale = { x = x, y = y, z = z, w = w }
  end
end

-- Updates the precipitation effect based on the wetness.
local function setPrecipitation(wetness)
  local rainDrops = wetness * 100
  local rainObj = findObject("rain_coverage", "Precipitation")
  if rainObj then
    rainObj.numDrops = rainDrops
  else
    local rainObjNew = createObject("Precipitation")
    rainObjNew.dataBlock = scenetree.findObject("rain_drop")
    rainObjNew.numDrops = rainDrops
    rainObjNew:registerObject("rain_coverage")
  end
end

-- Adjusts the sun scale based on the wetness.
local function setSunScale(wetness)
  local scatterSkyObj = scenetree.findObject("sunsky")
  if not scatterSkyObj or not originalSunScale then
    return
  end

  local wetValue = clamp(wetness, 0, 10)
  local factor = 1.0 - (wetValue / 10.0)
  local newSunScale = Point4F(
    originalSunScale.x * factor,
    originalSunScale.y * factor,
    originalSunScale.z * factor,
    originalSunScale.w
  )

  scatterSkyObj.sunScale = newSunScale
  scatterSkyObj:postApply()
end

-- Updates all visual effects for the rain based on the current wetness.
local function updateFX(wetness)
  setPrecipitation(wetness)
  setSunScale(wetness)
  be:queueAllObjectLua("particlefilter.setPerpendicularVelMultiplier(" .. wetness .. ")")
end

local function getPerpendicularVelMultiplier()
    return wetness
end

M.onWorldReadyState = onWorldReadyState
M.setPrecipitation = setPrecipitation
M.setSunScale = setSunScale
M.updateFX = updateFX

return M
