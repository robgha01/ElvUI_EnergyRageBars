local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ERB = E:GetModule("ElvUI_EnergyRageBars");
local format, split, find = string.format, string.split, string.find
local current_energy,max_energy,current_energy_percent = 0
local energyFrame,energyStatusBar,energyFont

local function OnUpdateSettings()
    ERB:debug("energyBar->updateSettings()")
    local width = E.db.ElvUI_EnergyRageBars.width
	local height = E.db.ElvUI_EnergyRageBars.height

    if E.db.ElvUI_EnergyRageBars.barTexture == "NORMAL" then
		energyStatusBar:SetStatusBarTexture("Interface\\AddOns\\ElvUI_EnergyRageBars\\textures\\normTex.tga")		
	elseif E.db.ElvUI_EnergyRageBars.barTexture == "MINIMALIST" then
		energyStatusBar:SetStatusBarTexture("Interface\\AddOns\\ElvUI_EnergyRageBars\\textures\\Minimalist.tga")		
    end
    
    local c = E.db.ElvUI_EnergyRageBars.energyBarColor
    energyStatusBar:SetStatusBarColor(c.r, c.g, c.b)
    
    energyFrame:SetSize(width,height) 
    energyStatusBar:SetHeight(height)
    
    energyFrame:ClearAllPoints() -- We need this to make the toggle top/bottom work
    if E.db.ElvUI_EnergyRageBars.energyBarFirst then
        energyFrame:SetPoint("TOP")
    else
        energyFrame:SetPoint("BOTTOM")		
	end
end

function EnergyFrame_onUpdate(sinceLastUpdate)
    self.sinceLastUpdate = (self.sinceLastUpdate or 0) + sinceLastUpdate;
    if(self.sinceLastUpdate >= .1) then -- in seconds
        EnergyFrame_eventHandler()
		self.sinceLastUpdate = 0;
	end
end

function EnergyFrame_eventHandler(self, event, ...)
    current_energy = UnitPower("player",3)
	max_energy = UnitPowerMax("player",3)
	
	if current_energy == 0 then
		current_energy_percent = 1
	end
	
	current_energy_percent = current_energy / max_energy * 100
	
	energyStatusBar:SetValue(current_energy_percent)
	if E.db.ElvUI_EnergyRageBars.energyBarShowResourceValue then
		energyFont:SetText(current_energy.."/"..max_energy)
	else
		energyFont:SetText("")
	end	
end

local function OnInitialize()
    ERB.EnergyFrame = CreateFrame("Frame","EnergyFrame",ERB.MainFrame,nil) energyFrame = ERB.EnergyFrame
    current_energy = UnitPower("player", 3)
	max_energy = UnitPowerMax("player", 3)

	energyFrame:SetSize(100,20)
	energyStatusBar = CreateFrame("StatusBar", nil, energyFrame)
	energyStatusBar:SetPoint("TOPLEFT")
	energyStatusBar:SetPoint("TOPRIGHT",0,0)
	energyStatusBar:SetMinMaxValues(0, 100)

	energyFont = energyStatusBar:CreateFontString("EnergyF")
	energyFont:SetFont("Fonts\\FRIZQT__.TTF", 11)
	energyFont:SetShadowOffset(1, -1)
	energyFont:SetPoint("CENTER")
	energyFont:SetText(current_energy.."/"..max_energy)

	energyFrame:RegisterEvent("UNIT_ENERGY")
	energyFrame:RegisterEvent("UNIT_RAGE") -- do we really need this ??
	energyFrame:RegisterEvent("UNIT_MANA")
	energyFrame:RegisterEvent("UNIT_HEALTH")
	energyFrame:RegisterEvent("UNIT_POWER")
	energyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	energyFrame:SetScript("OnUpdate", function(self, sinceLastUpdate) EnergyFrame_onUpdate(sinceLastUpdate); end);
	energyFrame:SetScript("OnEvent", EnergyFrame_eventHandler)
end

ERB:RegisterModule("ERB Energy Bar", OnInitialize, OnUpdateSettings)