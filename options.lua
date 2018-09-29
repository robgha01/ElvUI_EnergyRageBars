local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ERB = E:GetModule("ElvUI_EnergyRageBars");
local format, split, find = string.format, string.split, string.find

local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addon, ns = ...
local Version = GetAddOnMetadata(addon, "Version")

function colorizeSettingName(settingName)
	return format("|cff1784d1%s|r", settingName)
end

local function InsertOptions()
	E.Options.args.ElvUI_EnergyRageBars = {
		order = 1,
		type = "group",
		name = colorizeSettingName("Ascension Energy Rage"),
		get = function(info) return E.db.ElvUI_EnergyRageBars[info[#info]] end,
		set = function(info, value) E.db.ElvUI_EnergyRageBars[info[#info]] = value ERB:PositionFrame() end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = "Ascension Energy Rage"
			},
			height = {
				order = 2,
				type = "range",
				name = "Height",
				min = 10, max = 500, step = 1
			},
			width = {
				order = 3,
				type = "range",
				name = "Width",
				min = 10, max = 500, step = 1
			},
			attachBarsToPlayerFrame = {
				order = 4,
				type = "toggle",
				name = "Attach bars to player frame classbar",
				disabled = function()
					local frame = _G["ElvUF_Player"]
					return frame == nil or frame.ClassBar == nil
				end,
			},
			energyBarFirst = {
				order = 5,
				type = "toggle",
				name = "Show energy bar first",
			},
			combatFade = {
				order = 6,
				type = "toggle",
				name = "Hide out of combat/no target",
			},
			barTexture = {
				order = 7,
				type = "select",
				name = "Bar Texture",
				values = {
					["NORMAL"] = "Normal",
					["MINIMALIST"] = "Minimalist",
				},
			},
			headerEnergyBar = {
				order = 9,
				type = "header",
				name = "Energy Bar"
			},
			energyBar = {
				order = 10,
				type = "group",
				name = " ",
				guiInline = true,
				args = {
					energyBarShowResourceValue = {
						order = 1,
						type = "toggle",
						name = "Show text over resource",
					},
					energyBarColor = {
						order = 1,
						type = "color",
						name = "Color",
						desc = "Color of the energy bar",
						get = function(info)
							local t = E.db.ElvUI_EnergyRageBars[info[#info]]
							return t.r, t.g, t.b
						end,
						set = function(info, r, g, b)
							local t = E.db.ElvUI_EnergyRageBars[info[#info]]
							t.r, t.g, t.b = r, g, b
							ERB:PositionFrame()
						end,
					}
				}
			},
			headerRageBar = {
				order = 11,
				type = "header",
				name = "Rage Bar"
			},
			rageBar = {
				order = 12,
				type = "group",
				name = " ",
				guiInline = true,
				args = {
					rageBarShowResourceValue = {
						order = 1,
						type = "toggle",
						name = "Show text over resource",
					},
					rageBarColor = {
						order = 1,
						type = "color",
						name = "Color",
						desc = "Color of the rage bar",
						get = function(info)
							local t = E.db.ElvUI_EnergyRageBars[info[#info]]
							return t.r, t.g, t.b
						end,
						set = function(info, r, g, b)
							local t = E.db.ElvUI_EnergyRageBars[info[#info]]
							t.r, t.g, t.b = r, g, b
							ERB:PositionFrame()
						end
					}
				}
			},
			headerDev = {
				order = 100,
				type = "header",
				name = "Development"
			},
			dev = {
				order = 101,
				type = "group",
				name = " ",
				guiInline = true,
				args = {
					debug = {
						order = 1,
						type = "toggle",
						name = "Enable debug mode",
					}
				}
			}
		}
	}

	-- Mover
	E:CreateMover(ERB.MainFrame, "AscensionEnergyRageMover", "Ascension Energy Rage")
end

local function OnInitialize()
    --Insert our options table when ElvUI config is loaded
	EP:RegisterPlugin(addon, InsertOptions)
end

ERB:RegisterModule("ERB Options", OnInitialize)