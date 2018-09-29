local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ERB = E:GetModule("ElvUI_EnergyRageBars");
local format, split, find = string.format, string.split, string.find
local current_rage,max_rage,current_rage_percent = 0
local rageFrame,rageStatusBar,rageFont

local function OnUpdateSettings()
    ERB:debug("rageBar->updateSettings()")
    local width = E.db.ElvUI_EnergyRageBars.width
    local height = E.db.ElvUI_EnergyRageBars.height
    
    if E.db.ElvUI_EnergyRageBars.barTexture == "NORMAL" then
		rageStatusBar:SetStatusBarTexture("Interface\\AddOns\\AscensionElvUI\\textures\\normTex.tga")
	elseif E.db.ElvUI_EnergyRageBars.barTexture == "MINIMALIST" then
		rageStatusBar:SetStatusBarTexture("Interface\\AddOns\\AscensionElvUI\\textures\\Minimalist.tga")
    end
    
    local c = E.db.ElvUI_EnergyRageBars.rageBarColor
    rageStatusBar:SetStatusBarColor(c.r, c.g, c.b)
    
    rageFrame:SetSize(width,height)
    rageStatusBar:SetHeight(height)
    
    rageFrame:ClearAllPoints() -- We need this to make the toggle top/bottom work
    if E.db.ElvUI_EnergyRageBars.energyBarFirst then
        ERB:debug("Rage Last setting ragebar to BOTTOM")
		rageFrame:SetPoint("BOTTOM")
    else
        ERB:debug("Rage First setting ragebar to TOP")
		rageFrame:SetPoint("TOP")
	end
end

function RageFrame_onUpdate(sinceLastUpdate)
    self.sinceLastUpdate = (self.sinceLastUpdate or 0) + sinceLastUpdate;
    if (self.sinceLastUpdate >= .1) then -- in seconds
        RageFrame_eventHandler()
		self.sinceLastUpdate = 0;
	end
end

function RageFrame_eventHandler(self, event, ...)
    current_rage = UnitPower("player",1)
	max_rage = UnitPowerMax("player",1)	
	current_rage_percent = current_rage / max_rage * 100
	
	if current_rage == 0 then
		current_rage_percent = 1
	end
	
	rageStatusBar:SetValue(current_rage_percent)
	if E.db.ElvUI_EnergyRageBars.rageBarShowResourceValue then
		rageFont:SetText(current_rage.."/"..max_rage)
	else
		rageFont:SetText("")
	end
end

local function OnInitialize()
    ERB.RageFrame = CreateFrame("Frame","EnergyFrame",ERB.MainFrame,nil) rageFrame = ERB.RageFrame
    current_rage = UnitPower("player",1)
	max_rage = UnitPowerMax("player",1)
	rageFrame:SetSize(100,20)
	
	
	rageStatusBar = CreateFrame("StatusBar", nil, rageFrame)
	rageStatusBar:SetPoint("BOTTOMLEFT")
	rageStatusBar:SetPoint("BOTTOMRIGHT",0,0)
	rageStatusBar:SetMinMaxValues(0, 100)
	rageStatusBar:SetStatusBarColor(1,0,0)
	
	rageFont = rageStatusBar:CreateFontString("RageF")
	rageFont:SetFont("Fonts\\FRIZQT__.TTF", 11)
	rageFont:SetShadowOffset(1, -1)
	rageFont:SetPoint("CENTER")
	
	rageFrame:RegisterEvent("UNIT_RAGE")
	rageFrame:RegisterEvent("PLAYER_ENTERING_WORLD")	
	rageFrame:SetScript("OnUpdate", function(self, sinceLastUpdate) RageFrame_onUpdate(sinceLastUpdate); end);
	rageFrame:SetScript("OnEvent", RageFrame_eventHandler)
end

ERB:RegisterModule("ERB Rage Bar", OnInitialize, OnUpdateSettings)