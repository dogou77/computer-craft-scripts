-- iterates through all available redstone sides and disables them
for k,v in pairs(redstone.getSides()) do
    redstone.setOutput(v, false)
end
print("Reset redstone outputs")
