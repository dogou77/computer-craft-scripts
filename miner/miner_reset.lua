-- redstone side definitions
-- x-axis
local x_stop_side = "back"
local x_rev_side = "left"
-- y-axis
local y_stop_side = "front"
local y_rev_side = "right"
-- z-axis
local z_rev_side = "top"
-- modem
NETWORK_SIDE = "bottom"

-- timing delays & coefficients
local main_coef = 1.0 -- 1.0 is waterwheel speed
local x_coef = 1.0 * main_coef
local y_coef = 1.0 * main_coef
local inc_del = 1
INPUT_RATE = 0.5 -- check rate for rednet inputs if the previously received input isn't true
INPUT_TRIES = 10 -- how times to try rednet input before failing

-- maximum bounds
local x_max = 10
local y_max = 10

-- input names
local z_check = "z_check"
-- redstone contact names
local z_contact = "z_contact"

local function await_input (input_message, check_rate, check_tries)
    -- defaults
    check_rate = check_rate or INPUT_RATE
    check_tries = check_tries or INPUT_TRIES

    -- receive messages from other machine whenever an input is detected
    rednet.open(NETWORK_SIDE)
    for i=1,check_tries do -- only check until a certain amount of messages has passed
        -- disregards other messages that arent the desired message
        local id,message = rednet.receive()
        if message == input_message then
            return true
        end
        sleep(check_rate) -- delay next receive attempt
    end
    return false
end

local function reset_axis (side_rev, side_stop, delay, reverse)
    -- uses the two different sides to operate the x and y axis gantries
    -- input message is the redstone contacts
    -- defaults
    reverse = reverse or false

    -- start resetting axis
    redstone.setOutput(side_rev, not reverse) -- default is true
    redstone.setOutput(side_stop, false)
    sleep(delay)
    redstone.setOutput(side_rev, reverse) -- default is false
    redstone.setOutput(side_stop, true)
end

local function reset_z (side_rev, input_message, reverse)
    -- uses the z axis side to reverse the z axis until a contact is detected
    -- defaults
    reverse = reverse or false

    -- start resetting z axis
    redstone.setOutput(side_rev, not reverse) -- default is true
    if await_input(input_message) then
        redstone.setOutput(side_rev, reverse) -- default is false
    else
        -- input not detected within timeout
    end
end

print("Resetting to starting position...")
redstone.setOutput(x_stop_side, true)
redstone.setOutput(y_stop_side, true)
reset_z(z_rev_side, z_contact)
print("Z Axis Reset...")
reset_axis(y_rev_side, y_stop_side, inc_del * y_coef * y_max)
print("Y Axis Reset...")
reset_axis(x_rev_side, x_stop_side, inc_del * x_coef * x_max)
print("X Axis Reset...")
print("All axises reset.")