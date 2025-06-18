-- variables
local length = 16 -- (x) distance turtle goes forward initially 
local width = 16 -- (y)
local use_coal = false

-- +--------+ < = width
-- |        | ^ = length
-- |        | 
-- |        ^
-- +--------X < turtle starting position (facing upwards (forwards in game) according to diagram)

local not_empty = true
while not_empty do -- only stop loop when all chests run out
    for y=1,width do
        for x=1,length do
            -- go forward until turtle mines the length specified
            turtle.dig()
            turtle.forward()
        end
        -- alternate between turning left and right at the end of lengths
        if y ~= width then
            -- only run if not on last loop
            if y % 2 == 1 then
                -- odd (initially)
                -- turn around to mine the other end
                turtle.turnLeft()
                turtle.dig()
                turtle.forward()
                turtle.turnLeft()
            else
                -- even
                turtle.turnRight()
                turtle.dig()
                turtle.forward()
                turtle.turnRight()
            end
        end

        if turtle.getItemCount(15) > 0 then
            -- if turtle is full, then place a chest
            turtle.select(1) -- select chest
            turtle.placeUp()
            
            -- iterate through each inventory item besides the chest and coal (if coal, then refill)
            for i=2,16 do
                turtle.select(i)
                local item = turtle.getItemDetail()
                if item ~= nil then
                    if item.name == "minecraft:coal" and turtle.getFuelLevel() < 93000 and use_coal then
                        -- if the item selected is coal, then use it to refuel (but only if the fuel isn't maxed already)
                        turtle.refuel()
                    else
                        turtle.dropUp()
                    end
                end
            end
            
            turtle.select(1)
        end
    end

    -- go back to initial x & y position
    if width % 2 == 1 then
        turtle.turnLeft()
        turtle.turnLeft()
        for x=1,length do
            -- go forward to reset position
            turtle.forward()
        end
        turtle.turnLeft()
        for y=1,width-1 do
            -- go forward to reset position
            turtle.forward()
        end
        turtle.turnLeft()
    else
        turtle.turnLeft()
        for y=1,width-1 do
            turtle.forward()
        end
        turtle.turnLeft()
    end

    turtle.digDown()
    turtle.down()

    if turtle.getItemDetail(1) ~= nil then
        if turtle.getItemDetail(1).name ~= "minecraft:chest" then -- if true, then that means no more chests to place
            not_empty = false
        end
    end
end