local Sleep={}

function Sleep.shouldSleep(entity,worldClock)
local h = worldClock.hourTime
    if entity.circadian == "Nocturnal" then
        return h >= 8 or h <= 20 -- sleep at day
    elseif entity.circadian == "Diurnal" then
        return h >= 22 or h <= 6 -- sleep at night
    else
        return false
    end
end

function Sleep.sleep(entity, worldClock)
    if not entity.sleep and Sleep.shouldSleep(entity,worldClock) then
        entity.sleep=true
    elseif entity.sleep and not Sleep.shouldSleep(entity,worldClock) then
        entity.sleep=false
    end
end
return Sleep