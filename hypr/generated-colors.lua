local function rgba(hex, alpha)
    return "rgba(" .. hex:gsub("#", "") .. alpha .. ")"
end

local accent1 = "#B3977F"
local accent2 = "#56E6CA"
local inactive = "#000204"

return {
    active1 = rgba(accent1, "ee"),
    active2 = rgba(accent2, "ee"),
    inactive = rgba(inactive, "88"),
}
