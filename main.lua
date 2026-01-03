-- Simple Ecosystem Simulator
-- Made by Jojopov
-- Licence : GNU GPL v3 - 2025
-- https://www.gnu.org/licenses/gpl-3.0.html
local Tile = require("src.Entity.Tile")
local Sheep = require("src.Entity.Sheep")
local WorldClock = require("src.Environment.WorldClock")
local HUD = require("src.UI.HUD")
local Sheeps = {}
local tiles = {}
local SIZE = 32
local timeAcceleration = 60
local worldClock = WorldClock()
local stats = { deads = 0, speed = 1 }

-- Function called only once at the beginning
function love.load()
    for y = 1, 20 do
        tiles[y] = {}
        for x = 1, 20 do
            local tile = Tile(x * SIZE, y * SIZE, SIZE)
            tile.tx = x
            tile.ty = y
            tiles[y][x] = tile
        end
    end
    for x = 1, 10 do
        local newSheep = Sheep(x, x, tiles, SIZE, worldClock)
        table.insert(Sheeps, newSheep)
    end


    -- Initialization of resources (images, sounds, variables)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1) -- dark grey background
end

-- Function called at each frame, it updates the logic of the game
function love.update(dt)
    -- dt = delta time = time since last frame
    -- Used for fluid movements
    worldClock:update(dt * timeAcceleration)
    for _, line in ipairs(tiles) do
        for _, tile in ipairs(line) do
            local isSelected = (tile.isHabitedBy == HUD.sheep and HUD.sheep ~= nil)
            tile:update(dt * timeAcceleration / 60, isSelected)
        end
    end
    for _, sheep in ipairs(Sheeps) do
        sheep:update(dt * timeAcceleration / 60, tiles, Sheeps, worldClock, stats)
    end
    --to print details from sheep on a tile
    local mx, my = love.mouse.getPosition()
    HUD.updateHoveredSheep(mx, my, tiles, Sheeps)
end

-- Function called after each update to draw on screen
function love.draw()
    -- Everything that needs to be displayed passes here
    love.graphics.setColor(1, 1, 1) -- blanc
    for _, line in ipairs(tiles) do
        for _, tile in ipairs(line) do
            tile:draw()
        end
    end
    for _, sheep in ipairs(Sheeps) do
        sheep:draw(tiles, Sheeps)
    end
    local entities = { Sheeps }

    HUD.draw(entities, worldClock, stats)
    --to print details from sheep on a tile
    if HUD.sheep then
        local sheep=nil
        for _, findedSheep in ipairs(Sheeps)do
            if findedSheep.index==HUD.sheep then
                sheep=findedSheep
                break
            end
        end
        if sheep then
            HUD.printDetail(sheep)
        end
    end
end

function love.mousepressed(mx, my, button)
    for _, line in ipairs(tiles) do
        for _, tile in ipairs(line) do
            tile:mousepressed(mx, my, button, Sheeps, HUD)
        end
    end
end
local function changeSpeed(speed,value)
    value=speed*60
    return value
end
-- Function called at each touch
function love.keypressed(key)
    -- Example: exit the game with Escape
    if key == "escape" then
        love.event.quit()
    end
    if key == "kp+" then
        stats.speed = math.min(stats.speed + 1, 20)
        timeAcceleration=changeSpeed(stats.speed,timeAcceleration)
    end
    if key == "kp-" then
        stats.speed = math.max(1, stats.speed - 1)
        timeAcceleration=changeSpeed(stats.speed,timeAcceleration)

    end
end
