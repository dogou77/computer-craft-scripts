-- start turtle in bottom left corner
-- inventory slot 1 is for chests
-- inventory slot 2 is for torches

-- constants
local height = 3 -- (y) height of tunnel
local width = 3 -- (x) width of tunnel
local torch_dist = 6 -- distance in blocks between torches
local use_coal = true -- uses coal in inventory as fuel instead of depositing it
local warnings = false -- puts text warnings in chat where applicable
local torch_stop = false -- set to true if you want program to stop when there are no more torches

-- variables
local torch_i = torch_dist

local not_empty = true
while not_empty do -- only stop loop when all chests run out
    if warnings then -- no fuel warning if enabled
        if turtle.getFuelLevel() <= 1 then
            modem.transmit(1, 2, "noFuel")
            exit()
        end
    end 

    -- move to next tunnel layer
    turtle.dig()
    turtle.forward()
    turtle.turnRight()
    
    for y=1,height do
        for x=2,width do
            -- dig each x layer
            turtle.dig()
            turtle.forward()
        end
        
        -- dig up, go to next x layer except last layer
        if y ~= height then -- do unless at last y layer
            turtle.digUp()
            turtle.up()
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end

    -- other position, next z layer
    turtle.turnLeft()
    turtle.dig()
    turtle.forward()
    turtle.turnLeft()

    for y=1,height do
        for x=2,width do
            -- dig each x layer in reverse
            turtle.dig()
            turtle.forward()
        end
        
        if y ~= height then
            turtle.digDown()
            turtle.down()
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end
    
    -- place torch (if enough blocks between last torch)
    if torch_i > (torch_dist / 2) - 2 then
        if warnings then -- no torches warning
            local torches = turtle.getItemDetail(2)
            if torches == nil or torches.name ~= "minecraft:torch" then
                modem.transmit(1, 2, "noTorches")
                if torch_stop then
                    exit()
                end
            end 
        end
        torch_i = 0
        turtle.back()
        turtle.up()
        turtle.up()

        turtle.select(2)
        turtle.place()

        turtle.down()
        turtle.down()
        turtle.forward()
    else
        torch_i = torch_i + 1
    end    
    
    -- only run if inventory is full
    if turtle.getItemCount(15) > 0 then
        turtle.dig()
        turtle.select(1) -- select chest
        turtle.place()
        
        for i=3,16 do -- iterate through inventory and deposit items or consume them for fuel if they are coal
            turtle.select(i)
            local item = turtle.getItemDetail()
            if item ~= nil then
                if item.name == "minecraft:coal" and turtle.getFuelLevel() < 93000 and use_coal then
                    turtle.refuel()
                else
                    turtle.drop()
                end
            end
        end
        turtle.select(3) -- select empty slot
    end
    
    turtle.turnRight()
    
    local chest = turtle.getItemDetail(1)
    if chest ~= nil then -- stop the program if chests run out
        if chest.name ~= "minecraft:chest" then
            not_empty = false
            if warnings then
                modem.transmit(1, 2, "noChests")
            end
        end
    end
end
