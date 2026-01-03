local Object = require("libs.classic")
local Tile = Object:extend()
local Draws = require("libs.Draws")

function Tile:new(x, y, size)
    self.x = x
    self.y = y
    self.tx = 0
    self.ty = 0
    self.herb = 0.5
    self.size = size
    self.color = { 0, 255, 0 }
    self.isHabitedBy = nil
    self.borderColor = { 255, 0, 0 }
end

function Tile:draw()
    local r, g, b = self.color[1], self.color[2], self.color[3]
    love.graphics.setColor(r / 255, g / 255, b / 255)
    love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
    r, g, b = self.borderColor[1], self.borderColor[2], self.borderColor[3]
    love.graphics.setColor(r / 255, g / 255, b / 255)
    love.graphics.rectangle("line", self.x, self.y, self.size, self.size)
    love.graphics.setColor(1, 1, 1)
    --local float=math.floor(self.herb*100)/100
    --love.graphics.print(tostring(float),self.x+2/2,self.y+2/2)
end

function Tile:update(dt, isSelected)
    self.herb = math.max(0, math.min(1, self.herb + dt / 50))
    if isSelected == true then
        self.color = Draws.getRetroColor(6)
    else
        --[[                local greenVariants={17,21,16,22,18,23,19,24,16,20}
        local variant=greenVariants[math.floor(self.herb*10)]
        if variant and Draws.getRetroColor(variant) then
            self.color=Draws.getRetroColor(variant)
        end]]
        local green = self.herb * 255
        self.color = { 0, green, 0 }
    end
end

function Tile:mouseIsHover(mx, my)
    local isHover = false
    if mx >= self.x and mx <= self.x + self.size and my >= self.y and my <= self.y + self.size then
        isHover = true
    end
    return isHover
end

function Tile:mousepressed(mx, my, button)
    if button == 1 and self:mouseIsHover(mx, my) then
        self.herb = math.max(0, self.herb - 0.1)
    end
end

return Tile
