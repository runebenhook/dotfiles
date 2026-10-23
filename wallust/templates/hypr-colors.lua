local function rgba(hex, alpha)
    return "rgba(" .. hex:gsub("#", "") .. alpha .. ")"
end

local accent1 = "{{color12}}"
local accent2 = "{{color13}}"
local inactive = "{{color0}}"

return {
    active1 = rgba(accent1, "ee"),
    active2 = rgba(accent2, "ee"),
    inactive = rgba(inactive, "88"),
}
