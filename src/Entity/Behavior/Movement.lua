local Movement = {}

function Movement.moveToBestHerb(tiles, entity)
    local neighbors = entity.adjacentTiles
    if #neighbors > 0 then
        table.sort(neighbors, function(a, b)
            return a.herb > b.herb
        end)
        local bestHerb = neighbors[1].herb
        local bestTiles = {}
        for _, neighbor in ipairs(neighbors) do
            if neighbor.herb >= bestHerb and not neighbor.isHabitedBy then
                table.insert(bestTiles, neighbor)
            end
        end
        if #bestTiles > 0 then
            Movement.setTile(tiles, bestTiles[love.math.random(1, #bestTiles)], entity)
            entity.feeding.energy = math.max(0, entity.feeding.energy - 0.25)
        end
    end
end

function Movement.getGridDistance(ax, ay, bx, by)
    local dx = bx - ax
    local dy = by - ay
    local currentDist = math.max(math.abs(dx), math.abs(dy)) --Chebyshev distance

    return currentDist
end

function Movement.moveToTarget(entity, tx, ty, tiles)
    local currentDist = Movement.getGridDistance(entity.tx, entity.ty, tx, ty)
    local bestTile = nil

    for _, tile in ipairs(entity.adjacentTiles) do
        local dist = Movement.getGridDistance(tile.tx, tile.ty, tx, ty)
        if dist < currentDist and not tile.isHabitedBy then
            bestTile = tile
            currentDist = dist
        end
    end
    if not bestTile then
        --print("🐑 Entity #" .. entity.index .. " can't move closer to target.")
        entity.targetTx = tx
        entity.targetTy = ty
    else
        Movement.setTile(tiles, bestTile, entity)
        entity.targetTx = nil
        entity.targetTy = nil
    end
end

function Movement.getTile(tiles, entity)
    return tiles[entity.ty] and tiles[entity.ty][entity.tx]
end

function Movement.setTile(tiles, tile, entity)
    for y, line in ipairs(tiles) do
        for x, row in ipairs(line) do
            if tile.tx == row.tx and tile.ty == row.ty and tile.isHabitedBy == nil then
                local oldTile = Movement.getTile(tiles, entity)
                if oldTile then
                    oldTile.isHabitedBy = nil
                end
                entity.tx = tile.tx
                entity.ty = tile.ty
                tile.isHabitedBy = entity.index
                break
            end
        end
    end
end

function Movement.getAdjacentTiles(tx, ty, entity, tiles)
    local neighbors = {}
    for diffY = -1, 1 do
        for diffX = -1, 1 do
            if not (diffX == 0 and diffY == 0) then
                local x, y = tx + diffX, ty + diffY
                local tile = tiles[y] and tiles[y][x]
                if tile then
                    table.insert(neighbors, tile)
                end
            end
        end
    end
    entity.adjacentTiles = neighbors
end

return Movement
