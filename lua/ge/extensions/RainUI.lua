-- RainUI.lua
-- Code by tmaster5000,, chatgpt and snippets from daniel-w's floodmod with permission

local M = {}

local im = ui_imgui
local windowOpen = im.BoolPtr(true)
local groundWetness = im.FloatPtr(0)
local rainFxIntensity = im.FloatPtr(0)

local RainTerrain = require("RainTerrain")
local RainFX = require("RainFX")

local function onUpdate()
  if not windowOpen[0] then return end

  im.Begin("Rain mod", windowOpen, im.WindowFlags_MenuBar)

  if im.SliderFloat("Ground Wetness", groundWetness, 0, 10, "%.1f") then
    RainTerrain.scaleAllGroundModels(groundWetness[0])
  end

  if im.SliderFloat("Rain FX Intensity", rainFxIntensity, 0, 10, "%.1f") then
    RainFX.updateFX(rainFxIntensity[0])
  end

  im.End()
end

local function closeUI()
  windowOpen[0] = false
end

local debugEnabled = true
local function setDebugEnabled(enabled)
  debugEnabled = enabled
  if not enabled then
    windowOpen[0] = false
  end
end

M.onUpdate = onUpdate
M.closeUI = closeUI
M.setDebugEnabled = setDebugEnabled

return M
