-- input side definitions
-- contacts
--local x_contact_side = "left"
--local y_contact_side = "back"
local z_contact_side = "back"
-- observers
local z_check_side = "right"
-- network
local network_side = "top"

-- input message definitions
--local x_contact = "x_contact"
--local y_contact = "y_contact"
local z_contact = "z_contact"
local z_check = "z_check"

local poll_delay = 0.5 -- redstone input polling rate


rednet.open(network_side)

while true do
    if redstone.getInput(z_contact_side) then
        print("Z Contact On")
        rednet.broadcast(z_contact)
    elseif redstone.getInput(z_check_side) then
        print("Z Observer On")
        rednet.broadcast(z_check)
    end
    sleep(poll_delay) -- wait before checking input again
end