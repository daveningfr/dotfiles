
-- Define the global variable first
Colors = {}

-- Safely run the file into a local check variable
local ok, wal_cache = pcall(dofile, os.getenv("HOME") .. "/.cache/wal/colors-hyprland.lua")

if ok then
    Colors = wal_cache
else
    -- Fallbacks if Pywal hasn't run yet
    Colors = { color1 = "ffffff", background = "000000" }
end