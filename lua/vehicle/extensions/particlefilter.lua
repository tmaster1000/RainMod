



local particlefilter = require("vehicle/particlefilter")
local nodeCollisionOrig = particlefilter.nodeCollision
local depthCoef = 0.5 / physicsDt
local materials, materialsMap = particles.getMaterialsParticlesTable()

local perpendicularVelMultiplier = 0

function particlefilter.setPerpendicularVelMultiplier(value)
    perpendicularVelMultiplier = value
end

particlefilter.nodeCollision = function(p)

    local useType15 = false
    if (p.id1 % 10) < perpendicularVelMultiplier then
        useType15 = true
        p.slipVel = p.slipVel + (p.perpendicularVel * (perpendicularVelMultiplier * 0.3))
    end

    if p.perpendicularVel > p.depth * depthCoef then
        local pKey = p.materialID1 * 10000 + p.materialID2
        local mmap = materialsMap[pKey]

        if mmap ~= nil then
            for _, r in pairs(mmap) do
                if r.compareFunc(p) then
                    local chosenType = r.particleType
                    if useType15 then
                        chosenType = 15
                    end
                    obj:addParticleVelWidthTypeCount(p.id1, p.normal, p.nodeVel, r.veloMult, r.width, chosenType, r.count)
                end
            end
        end
    end
end



return particlefilter
