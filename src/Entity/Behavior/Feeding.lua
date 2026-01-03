local Object=require("libs.classic")
local Feeding=Object:extend()
function Feeding:new()
    self.eatCooldown = 0
    self.energy = 1
    self.apetite = 0
end

function Feeding:graze(entity,tile,dt)
    local mouthful = dt * 2

    if tile and tile.herb > mouthful and self.apetite > mouthful and self.apetite > 0.75 
    and self.eatCooldown <= 0 then
        tile.herb = math.max(0, tile.herb - mouthful)
        entity.moveCooldown = 0.5
        self.apetite = self.apetite - mouthful * 4
        self.energy = math.min(self.energy + dt*60, 1)
        self.eatCooldown = math.max(self.eatCooldown + dt*60, 0)

        return true
    else
        return false
    end
end
function Feeding:update(dt)
    self.eatCooldown = math.min(self.eatCooldown - dt*60 / 10, 1)
    self.apetite = math.min(self.apetite + dt*(60 / 4), 1)

end
return Feeding