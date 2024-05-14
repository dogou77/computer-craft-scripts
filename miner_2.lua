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
local network_side = "bottom"

-- input names
local z_check = "z_check"
-- redstone contact names
local z_contact = "z_contact"
--local x_contact = "x_contact"
--local y_contact = "y_contact"

-- timing coefficients
local main_coef = 1.0
local x_coef = 1.0 * main_coef
local y_coef = 1.0 * main_coef
local z_coef = 1.0 * main_coef

-- rates and delays
local inc_del = 0.5 -- adjust coefficients before adjusting
local store_del = 10
INPUT_RATE = 0.5 -- check rate for rednet inputs if the previously received input isn't true
INPUT_TRIES = 10 -- how times to try rednet input before failing

-- maximum bounds
local x_max = 10
local y_max = 10

function await_input (input_message, check_rate, check_tries)
    -- defaults
    check_rate = check_rate or INPUT_RATE
    check_tries = check_tries or INPUT_TRIES

    -- receive messages from other machine whenever an input is detected
    rednet.open(network_side)
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

function reset_axis (side_rev, side_stop, delay, reverse)
    -- uses the two different sides to operate the x and y axis gantries
    -- input message is the redstone contacts
    -- defaults
    reverse = reverse or false

    -- start resetting axis
    redstone.setOutput(side_rev, !reverse) -- default is false
    redstone.setOutput(side_stop, false)
    sleep(delay)
    redstone.setOutput(side_rev, reverse) -- default is true
    redstone.setOutput(side_stop, true)
end

function reset_z (side_rev, input_message, reverse)
    -- uses the z axis side to reverse the z axis until a contact is detected
    -- defaults
    reverse = reverse or false

    -- start resetting z axis
    redstone.setOutput(side_rev, !reverse) -- default is true
    if await_input(input_message) then
        redstone.setOutput(side_rev, reverse) -- default is false
    else
        -- input not detected within timeout
    end
end

function inc_axis (side_stop, delay, coef)
    -- increments specified axis by 1 block by delays
    redstone.setOutput(side_stop, false)
    sleep(delay * coef)
    redstone.setOutput(side_stop, true)
end

function dig (side_rev, contact_input_name, check_input_name, reverse)
    -- start by digging downwards
    -- defaults
    reverse = reverse or false

    -- set to dig then wait for check input
    redstone.setOutput(side_rev, reverse) -- default is false
    await_input(check_input_name) -- wait until drill has become stuck or reached bottom
    redstone.setOutput(side_rev, !reverse) -- default is true
    await_input(contact_input_name)
    -- done digging, move to next axis
end

function read_axis_input ()
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
print("Resetting to starting position...")
reset_axis(y_rev_side, x_stop_side, inc_del * y_coef * y_max)
reset_axis(x_rev_side, x_stop_side, inc_del * x_coef * x_max)

-- increment axis based on information
print("Incrementing to: X:" .. x_start .. " Y: " .. y_start)
for i=1,x_start do
    for j=1,y_start do
        inc_axis(y_stop_side, inc_del, y_coef)
    end
    inc_axis(x_stop_side, inc_del, x_coef)
end

-- start mining
print("Started mining: X:" .. x_start .. " Y: " .. y_start)

for i=x_start,x_max do
    for j=y_start,y_max do
        -- dig
        dig(z_rev_side, z_contact, z_check)
        sleep(store_del) -- allow time to retrieve storage items
        -- increment y by one
        inc_axis(y_stop_side, inc_del, y_coef)
        
        print("Y incremented: " .. j)
    end
    print("Y maximum reached, resetting...")
    -- do every time the y axis reaches it's max
    reset_axis(y_rev_side, x_stop_side, inc_del * y_coef * y_max)
    print("X incremented: " .. i)
    inc_axis(x_stop_side, inc_del, x_coef)
end
print("Mining complete!")