local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ERB = E:NewModule('ElvUI_EnergyRageBars', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0'); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2
local UF = E:GetModule("UnitFrames");
local format, split, find = string.format, string.split, string.find
ERB.MainFrame = CreateFrame("Frame","MainFrame",UIParent,nil)
local mainFrame = ERB.MainFrame
local moduleCallbacks = {}

--Default options
P["ElvUI_EnergyRageBars"] = {
	["attachBarsToPlayerFrame"] = false,
	["height"] = 10,
	["width"] = 270,
	["energyBarFirst"] = false,
	["combatFade"] = false,
	["barTexture"] = "NORMAL",
	["energyBarShowResourceValue"] = true,
	["energyBarColor"] = { r = 1, g = 1, b = 0 },
	["rageBarShowResourceValue"] = true,
	["rageBarColor"] = { r = 1, g = 0, b = 0 },
	["debug"] = false
}

function ERB:debug(key, ...)
	if ViragDevTool_AddData and E.db.ElvUI_EnergyRageBars.debug then 
        ViragDevTool_AddData({...}, "Ascension energy/rage: "..key) 
    end
end

function ERB:RegisterModule(name, loadFunc, updateSettingsFunc)
	if moduleCallbacks[name] then
		--Don't allow a registered module name to be overwritten
		error("Invalid argument #1 to ERB:RegisterModule (module name:", name, "is already registered, please use a unique name)")
		return
	end
	moduleCallbacks[name] = {
		loadFunc = loadFunc,
		updateSettingsFunc = updateSettingsFunc
	}
end

function ERB:PositionFrame()
	local frame = _G["ElvUF_Player"]
	local attachBarsToPlayerFrame = E.db.ElvUI_EnergyRageBars.attachBarsToPlayerFrame
	if frame == nil and attachBarsToPlayerFrame then
		attachBarsToPlayerFrame = false
	elseif frame ~= nil and frame.ClassBar == nil and attachBarsToPlayerFrame then
		attachBarsToPlayerFrame = false
	end

	if attachBarsToPlayerFrame then
		ERB:debug("Frame:", frame)
		ERB:debug("ClassBar", frame.ClassBar)
		frame = frame[frame.ClassBar].origParent or frame[frame.ClassBar]:GetParent()

		local db = frame.db
		if not db then return end
		local POWERBAR_WIDTH = frame.POWERBAR_WIDTH
		local POWERBAR_HEIGHT = frame.POWERBAR_HEIGHT
		local POWERBAR_SPACER = POWERBAR_HEIGHT

		if POWERBAR_WIDTH == 0 or POWERBAR_HEIGHT == 0 then
			POWERBAR_WIDTH = frame.UNIT_WIDTH
			POWERBAR_HEIGHT = frame.UNIT_HEIGHT or 16
			POWERBAR_SPACER = 0
		end

		local CLASSBAR_YOFFSET = frame.CLASSBAR_YOFFSET
		local BOTTOM_OFFSET = frame.BOTTOM_OFFSET

		mainFrame:SetParent(frame)
		--mainFrame:SetSize(POWERBAR_WIDTH, POWERBAR_HEIGHT * 2)
		mainFrame:ClearAllPoints()

		-- Set the width/height for rage and energy
		E.db.ElvUI_EnergyRageBars.width = POWERBAR_WIDTH
		E.db.ElvUI_EnergyRageBars.height = POWERBAR_HEIGHT

		ERB:UpdateSettings()
		--if not E:HasMoverBeenMoved("AscensionEnergyRageMover") then
		mainFrame:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", frame.BORDER, (-frame.SPACING*3) - POWERBAR_SPACER)
		if AscensionEnergyRageMover then
			AscensionEnergyRageMover:ClearAllPoints()
			AscensionEnergyRageMover:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", frame.BORDER, (-frame.SPACING*3) - POWERBAR_SPACER)
			--E:SaveMoverDefaultPosition("AscensionEnergyRageMover")
		end
		--end
	else
		local name = "AscensionEnergyRageMover"
		local f = _G[name]
		local point, anchor, secondaryPoint, x, y
		
		if E.db["movers"] and E.db["movers"][name] and type(E.db["movers"][name]) == "string" then
			local delim
			local anchorString = E.db["movers"][name]
			if(find(anchorString, "\031")) then
				delim = "\031"
			elseif(find(anchorString, ",")) then
				delim = ","
			end
			point, anchor, secondaryPoint, x, y = split(delim, anchorString)
			mainFrame:ClearAllPoints()
			mainFrame:SetPoint(point, anchor, secondaryPoint, x, y)			
		elseif f then
			point, anchor, secondaryPoint, x, y = split(",", E.CreatedMovers[name]["point"])
			mainFrame:ClearAllPoints()
			mainFrame:SetPoint(point, anchor, secondaryPoint, x, y)			
		end

		ERB:UpdateSettings()
	end
end

function ERB:UpdateSettings()
	local width = E.db.ElvUI_EnergyRageBars.width
	local height = E.db.ElvUI_EnergyRageBars.height	
	mainFrame:SetSize(width, height * 2 + 1)

	-- Update settings for modules
	for _,v in pairs(moduleCallbacks) do
		if v.updateSettingsFunc then v.updateSettingsFunc() end
	end
end

function ERB:HideBars()
	ERB.IsBarsShown = false
	UIFrameFadeOut(mainFrame, 0.2, mainFrame:GetAlpha(), 0)
end

function ERB:ShowBars()
	ERB.IsBarsShown = true
	UIFrameFadeIn(mainFrame, 0.2, mainFrame:GetAlpha(), 1)
end

local function handleVisibilityResourceBar(event, arg1)
	if not E.db.ElvUI_EnergyRageBars.combatFade or E.ConfigurationMode then return end
	local frame = _G["ElvUF_Player"]
	if frame then
		local db = frame.db	
		if db.enable and frame:IsShown() then ERB:ShowBars() end
	end

	if((event == "UNIT_SPELLCAST_START"
	or event == "UNIT_SPELLCAST_STOP"
	or event == "UNIT_SPELLCAST_CHANNEL_START"
	or event == "UNIT_SPELLCAST_CHANNEL_STOP"
	or event == "UNIT_HEALTH") and arg1 ~= "player") then return; end
	
	local cur, max = UnitHealth("player"), UnitHealthMax("player")
	local cast, channel = UnitCastingInfo("player"), UnitChannelInfo("player")
	local target, focus = UnitExists("target"), UnitExists("focus")
	local combat = UnitAffectingCombat("player")
	if (cast or channel) or (cur ~= max) or (target or focus) or combat then
		ERB:ShowBars()
	else
		ERB:HideBars()
	end	
end

-- This function will handle initialization of the addon
function ERB:Initialize()
	mainFrame:SetSize(100,41)
	mainFrame:SetPoint("CENTER")
	mainFrame:SetMovable(true)
	mainFrame:EnableMouse(true)
	mainFrame:SetUserPlaced(true)

	local mainFrameTexture = mainFrame:CreateTexture()
	mainFrameTexture:SetAllPoints(mainFrame)
	mainFrameTexture:SetTexture(.1,.1,.1,1)
	mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
	mainFrame:SetScript("OnHide", mainFrame.StopMovingOrSizing)
	mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
	mainFrame:Show()

	ERB.IsBarsShown = true

	-- initialize modules
	for _,v in pairs(moduleCallbacks) do
		if v.loadFunc then v.loadFunc() end
	end

	ERB:UpdateSettings()
	ERB:PositionFrame()	
	ERB:debug("Options", E.db.ElvUI_EnergyRageBars)

	-- register events
	ERB:RegisterEvent("PLAYER_REGEN_DISABLED", handleVisibilityResourceBar)
	ERB:RegisterEvent("PLAYER_REGEN_ENABLED", handleVisibilityResourceBar)
	ERB:RegisterEvent("PLAYER_TARGET_CHANGED", handleVisibilityResourceBar)
	ERB:RegisterEvent("UNIT_SPELLCAST_START", handleVisibilityResourceBar)
	ERB:RegisterEvent("UNIT_SPELLCAST_STOP", handleVisibilityResourceBar)
	ERB:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", handleVisibilityResourceBar)
	ERB:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", handleVisibilityResourceBar)
	ERB:RegisterEvent("UNIT_HEALTH", handleVisibilityResourceBar)
	ERB:RegisterEvent("PLAYER_FOCUS_CHANGED", handleVisibilityResourceBar)
	handleVisibilityResourceBar()
end

--This function will get called by ElvUI automatically when it is ready to initialize modules
local function CallbackInitialize()
	ERB:Initialize()
end

--Register module with callback so it gets initialized when ready
E:RegisterModule("ElvUI_EnergyRageBars", CallbackInitialize)