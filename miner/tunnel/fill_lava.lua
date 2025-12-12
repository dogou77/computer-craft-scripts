-- this script refuels a turtle by having a source of lava in front of it that refills
-- a bucket is supposed to be in inventory slot 1
local is_advanced = true
local fuel_limit = 17500

if is_advanced then -- use lower fuel limit if the turtle is not advanced
    fuel_limit = 95000
end

turtle.select(1)

while turtle.getFuelLevel() < fuel_limit do -- refuel using lava bucket until at max fuel
    turtle.place()
    turtle.refuel()
    -- TODO: put wait here
end