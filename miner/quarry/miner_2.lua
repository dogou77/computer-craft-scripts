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

-- input names
local z_check = "z_check"
local z_contact = "z_contact"

-- timing coefficients
local main_coef = 1.0 -- 1.0 is waterwheel speed
local x_coef = 1.0 * main_coef
local x_init_coef = 1.0 -- timing coef for initial x movement
local y_coef = 1.0 * main_coef
local y_init_coef = 1.0 -- timing coef for initial y movement
local z_coef = 1.0 * main_coef

-- rates and delays
local inc_del = 1
local inc_del_init = 2 -- delay for initial x & y movements
INPUT_RATE = 0.5 -- check rate for rednet inputs if the previously received input isn't true
INPUT_TRIES = 10 -- how times to try rednet input before failing

-- maximum bounds
local x_max = 10
local y_max = 10

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

local function inc_axis (side_stop, delay, coef)
    -- increments specified axis by 1 block by delays
    redstone.setOutput(side_stop, false)
    sleep(delay * coef)
    redstone.setOutput(side_stop, true)
end

local function dig (side_rev, contact_input_name, check_input_name, reverse)
    -- start by digging downwards
    -- defaults
    reverse = reverse or false

    -- set to dig then wait for check input
    redstone.setOutput(side_rev, reverse) -- default is false
    await_input(check_input_name) -- wait until drill has become stuck or reached bottom
    redstone.setOutput(side_rev, not reverse) -- default is true
    await_input(contact_input_name)
    -- done digging, move to next axis
end

local function read_axis_input ()
    -- meant for reading axis number inputs at start of program
    local axis = tonumber(read())
    -- if number cannot be converted and is lower than 0 use the defaults
    if axis == nil or axis < 0 then
        axis = 0
    end
    return axis -- return adjusted axis value
end

-- start by asking user what x and y coordinate they want to go to
print("Enter X position (default is 0):")
local x_start = read_axis_input()

print("Enter Y position (default is 0):")
local y_start = read_axis_input()

-- reset machine
-- iterates through all available redstone sides and disables them
for k,v in pairs(redstone.getSides()) do
    redstone.setOutput(v, false)
end

-- reset axises
print("Resetting to starting position...")
redstone.setOutput(x_stop_side, true)
redstone.setOutput(y_stop_side, true)
reset_z(z_rev_side, z_contact)
print("Z Axis Reset...")
reset_axis(y_rev_side, y_stop_side, inc_del * y_coef * y_max)
print("Y Axis Reset...")
reset_axis(x_rev_side, x_stop_side, inc_del * x_coef * x_max)
print("X Axis Reset...")

-- increment axis based on information
print("Incrementing to: X:" .. x_start .. " Y: " .. y_start)
-- x
for i=1,x_start do
    inc_axis(x_stop_side, inc_del, x_init_coef)
    sleep(inc_del_init)
end
-- y
for i=1,y_start do
    inc_axis(y_stop_side, inc_del, y_init_coef)
    sleep(inc_del_init)
end



-- start mining
print("Started mining: X:" .. x_start .. " Y: " .. y_start)

for i=x_start,x_max do
    for j=y_start,y_max do
        -- dig
        dig(z_rev_side, z_contact, z_check)
        print("Digging done...")
        -- increment y by one
        inc_axis(y_stop_side, inc_del, y_coef)
        print("Y incremented: " .. j)
    end
    print("Y maximum reached, resetting...")
    -- do every time the y axis reaches it's max
    y_start= 0
    reset_axis(y_rev_side, y_stop_side, inc_del * y_coef * y_max)
    print("X incremented: " .. i)
    inc_axis(x_stop_side, inc_del, x_coef)
end
print("Mining complete!")