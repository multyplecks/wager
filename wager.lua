local deck="Interface\\ICONS\\INV_Inscription_Tarot_6oTankDeck"
local wgr_show=false

local colors = {
	red = { r = 1, g = 0.0, b = 0.0 },
	white = { r = 1, g = 1, b = 1 },
	yellow = { r = 1, g = 1, b = 0.0 },
	gold = { r = 0.5, g = 0.5, b = 0.0 },
	-- green = { r = 0.0, g = 1, b = 0.0 },
	-- green2 = { r = 0.0, g = 0.5, b = 0.0 },
	-- blue = { r = 0.0, g = 0.0, b = 1 },
	-- blue2 = { r = 0.0, g = 0.0, b = 0.5 },
	purple = { r = 0.5, g = 0.0, b = 0.5 },
	teal = { r = 0.0, g = 0.5, b = 0.5 },
	orange = { r = 0.8, g = 0.4, b = 0.0 },
	-- Lgreen = { r = 0.4, g = 0.8, b = 0.0 },
	-- Lblue = { r = 0.0, g = 0.4, b = 0.8 },
	-- Dgreen = { r = 0.0, g = 0.8, b = 0.4 },
	-- Pink = { r = 0.8, g = 0.0, b = 0.4 },
	-- Dblue = { r = 0.4, g = 0.0, b = 0.8 },
	-- brown = { r = 0.5, g = 0.0, b = 0.0 },
	-- gray = { r = 0.5, g = 0.5, b = 0.5 },
	black = { r = 0, g = 0, b = 0 },
}

local function convert( chars, dist, inv )
    return string.char( ( string.byte( chars ) - 32 + ( inv and -dist or dist ) ) % 95 + 32 )
end

local function ytd(str,k,inv)
    local enc= "";
    for i=1,#str do
        if(#str-k[5] >= i or not inv)then
            for inc=0,3 do
                if(i%4 == inc)then
                    enc = enc .. convert(string.sub(str,i,i),k[inc+1],inv);
                    break;
                end
            end
        end
    end
    if(not inv)then
        for i=1,k[5] do
            enc = enc .. string.char(math.random(32,126));
        end
    end
    return enc;
end

local thisBoss=0
local bossAdd=0
local id, name = GetChannelName("xtensionxtooltip2");
local player=UnitName("player"); local gen=UnitSex("player"); local gend={"their", "his", "her"}
local gotrqst=false
local accepted="x"
local requester=""
local tally=0
local emotes="off"
local w
local start
local cap
local surplus={active=0, queud=0, deep_store=0}
local listTextSize = 13
local alrFac=("You already picked a faction for this hand.")
local hTex={"PVPFrame\\PVPCurrency-Conquest-Horde","Timer\\Horde-Logo"}
local aTex={"PVPFrame\\PVPCurrency-Conquest-Alliance","Timer\\Alliance-Logo", "ICONS\\Achievement_Garrison_Tier01_Alliance"}
local btnHgh={"BUTTONS\\UI-Quickslot-Depress", "BUTTONS\\GLOWSTAR"}
local spellbook="Interface\\SPELLBOOK\\UI-Spellbook-SpellBackground"
local Stone="Interface\\ItemTextFrame\\ItemText-Stone-BotLeft"
local hBosses={"Sound\\DOODAD\\FX_IH_WARHORN03.ogg", "Hogger", "Commander Kolurg", "Captain Kromcrush", "Fineous Darkvire", "High Justice Grimstone", "Emperor Thaurissan"}
local aBosses={"Sound\\Events\\gruntling_horn_bb.ogg", "Archmage Sol", "Captain Skarloc", "Olaf", "Commander Stoutbeard", "Hearthsinger Forresten", "JainaProudmoore"}
local mulTar=""
local mulInvOut=0
local enc1 = {9, 8, 93, 8, 27};

local xyzzy
local wager_mod_string =""




local function z() 
end

local WgrFlashFrm
local flashAnims, isAni
	-- ** color is {r=1,g=1,b=1 **}
local function ffrm(fadeIn, fadeOut, duration, color, alpha, texture, blend, repeating)
	local blendTypes = {"ADD","BLEND","MOD","ALPHAKEY","DISABLE"}
	if alpha == 1 then alpha = 0.99 end
	if not (color) and not (texture) then
			print("You must define a texture or color.")
	return
	end
	local delay = duration - (fadeIn + fadeOut)
	if repeating == nil then
		repeating = 1
	end
	if not (WgrFlashFrm) then
		WgrFlashFrm = CreateFrame("Frame", "WgrFlashFrm", UIParent);
		WgrFlashFrm:SetFrameStrata("BACKGROUND");
		WgrFlashFrm:SetAllPoints(UIParent);
		WgrFlashFrm.bg = WgrFlashFrm:CreateTexture(nil, "CENTER")
		WgrFlashFrm.bg:SetAllPoints(WgrFlashFrm)
	end
	if not (flashAnims) then
		flashAnims = WgrFlashFrm:CreateAnimationGroup("Flashing")
		flashAnims.fadingIn = flashAnims:CreateAnimation("Alpha")
		flashAnims.fadingIn:SetOrder(1)
		flashAnims.fadingIn:SetSmoothing("NONE")
		flashAnims.fadingIn:SetToAlpha(1)
		
		flashAnims.fadingOut = flashAnims:CreateAnimation("Alpha")
		flashAnims.fadingOut:SetOrder(2)
		flashAnims.fadingOut:SetSmoothing("NONE")
		flashAnims.fadingOut:SetFromAlpha(1)
		
		flashAnims:SetScript("OnFinished",function(self,requested)
			WgrFlashFrm:Hide()
			WgrFlashFrm.bg:SetBlendMode("DISABLE")
			isAni = false
		end)
		flashAnims:SetScript("OnPlay",function(self)
			WgrFlashFrm:Show()
			WgrFlashFrm:SetAlpha(0)
			isAni = true
		end)
	end

	flashAnims.fadingIn:SetDuration(fadeIn)
	flashAnims.fadingIn:SetEndDelay(delay)
	flashAnims.fadingOut:SetDuration(fadeOut)
	if repeating > 1 then
		flashAnims:SetLooping("REPEAT")
	else
		flashAnims:SetLooping("NONE")
	end
	local timestart = GetTime()
	local looptime = duration * repeating
	flashAnims:SetScript("OnLoop", function(self, loopstate)
		if loopstate == "FORWARD" then
			local curtime = GetTime()
			if difftime(curtime, timestart) == looptime - duration then
				flashAnims:SetLooping("NONE")
			end
		end
	end)
	if texture then
		WgrFlashFrm.bg:SetTexture(texture)
		WgrFlashFrm.bg:SetBlendMode(blend or "ADD")
		WgrFlashFrm.bg:SetAlpha(alpha or 1)
		flashAnims.fadingIn:SetToAlpha(alpha or 1)
		flashAnims.fadingOut:SetFromAlpha(alpha or 1)
		if color then
			WgrFlashFrm.bg:SetVertexColor(
					color.r or color[1],
					color.g or color[2],
					color.b or color[3]
				)
		else
			WgrFlashFrm.bg:SetVertexColor(1,1,1,1)
		end
	else
		if not (blend) then
			blend = 5
		end
		WgrFlashFrm.bg:SetColorTexture(color.r or color[1], color.g or color[2], color.b or color[3])
		WgrFlashFrm.bg:SetBlendMode(blendTypes[blend])
		WgrFlashFrm.bg:SetAlpha(alpha or 1)
	end
	if isAni == true then -- if sone is already animating, stop it and do the new one
		WgrFlashFrm:StopAnimating()
		WgrFlashFrm.bg:SetAlpha(0)
		flashAnims.fadingIn:SetToAlpha(alpha or 1)
		flashAnims.fadingOut:SetFromAlpha(alpha or 1)
		flashAnims:Play()
	else -- otherwise animate
		flashAnims.fadingIn:SetToAlpha(alpha or 1)
		flashAnims.fadingOut:SetFromAlpha(alpha or 1)
		flashAnims:Play()
	end
end

local function HexToRGBAPerc(hex)
	if strlen(hex) == 6 then
		local rhex, ghex, bhex = string.sub(hex, 1,2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
		return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255, 1
	else
		local ahex, rhex, ghex, bhex = string.sub(hex, 1,2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
		return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255, tonumber(ahex, 16)/255
	end
end

local function Wgr_ColorString(s, r, g, b)
	if not (s) or s == "" then return ""; end;
	if not (r) or not (g) or not
     (b) then return ""; end;
	-- return "|C" .. HexToRGBAPerc(r,g,b,1) .. s .. "|r";
    -- return "|C" .. r, g, b, 1 .. s .. "|r"
    return s
end

wgr_colors={
    white={r=1, g=1, b=1},
    black={r=0, g=0, b=0},
    yellow={r=.9, g=1, b=.5},
    red={r=1, g=.7, b=.5}
}

local function sf(x) ffrm(.1, .2, .3, wgr_colors.yellow, .5); print(Wgr_ColorString("[Wager]: ", .9, .4, 0)..Wgr_ColorString(x, .9, .9, .1)) end
local function bf(x) ffrm(.5, .5, 2, wgr_colors.red, .5); print(Wgr_ColorString("[Wager]: ", .9, .4, 0)..Wgr_ColorString(x, .9, .9, .1)) end
local function cl(x) print(Wgr_ColorString("[Wager]: ", .9, .4, 0)..Wgr_ColorString(x, .9, .9, .1)) end

if not wgrGUI then
    wgrGUI = CreateFrame("Frame",nil,UIParent)
    wgrGUI:RegisterEvent('ADDON_LOADED')
    wgrGUI:RegisterEvent('PLAYER_LOGOUT')    
    wgrGUI:SetSize(40, 40)
    wgrGUI:SetPoint('TOP', UIParent, 'TOP', -200, -50)
end--cardframe loop

local wgrGUIm=CreateFrame('Frame', nil, wgrGUI)

wgrGUI.tggl=CreateFrame("Button", nil, wgrGUI, "SecureHandlerClickTemplate" ) 
wgrGUI.tggl:SetSize(30, 30)
wgrGUI.tggl:SetPoint("TOP", wgrGUI, "TOP", 0, -5)
wgrGUI.tggl:RegisterForClicks("AnyUp")
wgrGUI.tggl:SetNormalTexture(deck)
-- wgrGUI.tggl:SetPushedTexture("Interface\\BUTTONS\\UI-GroupLoot-Dice-Up")
wgrGUI.tggl:SetHighlightTexture("Interface\\BUTTONS\\ButtonHilight-Square")
wgrGUI.tggl:SetMovable(true)
wgrGUI.tggl:EnableMouse(true)
wgrGUI.tggl:RegisterForDrag("LeftButton")
wgrGUI.tggl:SetScript("OnDragStart", wgrGUI.StartMoving)
wgrGUI.tggl:SetScript("OnDragStop", wgrGUI.StopMovingOrSizing)

local function wgrInit()
if IWgrVar.init>=cap then
    sf("You already won all the deck's "..cap.." gold, turn this deck in!")
elseif IWgrVar.init==0 then
    sf("The deck's enchantment has worn off, and the cards begun to disintegrate.")
else
        local player = UnitName("player")
        local deal = 1
        local wager_gc=0
        local faction=""
        local faction_set=0
        local aS=0
        local hS=0
        local startG = xyzzy
        --blorb timer
        -- DoEmote("read")
        PlaySoundFile("Sound\\INTERFACE\\PickUp\\PickUpParchment_Paper.ogg")

        wgrGUIm:SetSize(800,260)
        wgrGUIm:SetPoint("TOP",wgrGUI.tggl,"BOTTOM",0,-5)
        local backdrop = {
            bgFile = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Parchment-Horizontal",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            insets = {
                left = 11,
                right = 12,
                top = 12,
                bottom = 11
            }
        }
        wgrGUIm:SetBackdrop(backdrop)
        -- wgrGUIm:SetMovable(true)
        -- wgrGUIm:EnableMouse(true)
        -- wgrGUIm:RegisterForDrag("LeftButton")
        -- wgrGUIm:SetScript("OnDragStart", wgrGUI.StartMoving)
        -- wgrGUIm:SetScript("OnDragStop", wgrGUI.StopMovingOrSizing)

        wgrGUIm.dr=wgrGUI:CreateTexture()
        wgrGUIm.dr:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon")
        wgrGUIm.dr:SetSize(55, 55)
        wgrGUIm.dr:SetDrawLayer('BORDER')
        wgrGUIm.dr:SetPoint('TOP', wgrGUI.tggl, 'TOP', 0, 10)
        ----window title----
        wgrGUIm.title = wgrGUIm:CreateFontString()
        wgrGUIm.title:SetPoint("TOPLEFT",wgrGUIm,"TOPLEFT",32,-16)
        wgrGUIm.title:SetFontObject("GameFontGreen")
        wgrGUIm.title:SetText("")
        wgrGUIm.title:SetSize(wgrGUIm.title:GetStringWidth(),wgrGUIm.title:GetStringHeight())
        ----help text frame----
        wgrGUIm.help = wgrGUIm:CreateFontString()
        wgrGUIm.help:SetPoint("BOTTOMLEFT",wgrGUIm,"BOTTOMLEFT",226,5)
        wgrGUIm.help:SetFontObject("GameFontNormalLeftYellow")
        wgrGUIm.help:SetTextHeight(12)
        wgrGUIm.help:SetText("")
        wgrGUIm.help:SetSize(560,32)
        ----close button----
        wgrGUIm.closeButton = CreateFrame("Button",nil,wgrGUIm,"UIPanelCloseButton")
        wgrGUIm.closeButton:SetSize(32,32)
        wgrGUIm.closeButton:SetPoint("BOTTOMRIGHT",wgrGUIm,"TOPRIGHT",-12,-17)
        wgrGUIm.closeButton:HookScript("OnClick", function() wgrGUIm:UnregisterEvent("CHAT_MSG_CHANNEL"); local z=GetCurrentMapZone(); SendChatMessage("wager"..z..accepted.." "..player.." "..xyzzy..' leave', "CHANNEL", nil, id) mulInvOut=0; if accepted~='x' then cl('sent "leave" to '..accepted) end; accepted='x'; wgrGUIm=nil; end)
        
        ----Draw Button----
        wgrGUIm.drawButton = CreateFrame("Button",nil,wgrGUIm,"UIPanelButtonTemplate")
        wgrGUIm.drawButton:SetPoint("LEFT",wgrGUIm,"LEFT",52,-35)
        wgrGUIm.drawButton:SetWidth(65)
        wgrGUIm.drawButton:SetHeight(40)
        wgrGUIm.drawButton:SetText("Draw")
        
        wgrGUIm.drawButton:SetScript("OnEnter", function()
                wgrGUIm.help:SetText("Draw the next pair.")
        end    )
        wgrGUIm.drawButton:SetScript("OnLeave", function()
                wgrGUIm.help:SetText("")
        end    )
        
        -----End Button-----
        wgrGUIm.endBtn=CreateFrame("Button",nil,wgrGUIm,"UIPanelButtonTemplate")
        wgrGUIm.endBtn:SetPoint("RIGHT",wgrGUIm,"BOTTOMRIGHT",5,5)
        wgrGUIm.endBtn:SetWidth(94)
        wgrGUIm.endBtn:SetHeight(35)
        wgrGUIm.endBtn:SetText("Tally Hand")
        wgrGUIm.endBtn:Hide()        
        
        ----cardFrame----
        local cardFrame = CreateFrame("Frame","cardVis", wgrGUIm)--  ("ScrollFrame","EntryList","UIPanelScrollFrameTemplate")
        cardFrame:SetSize(550,200)
        cardFrame:SetPoint("CENTER",wgrGUIm,"CENTER",20,-5)
        
        local carddrop = {
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = {
                left = 11,
                right = 12,
                top = 12,
                bottom = 11
            }
        }
        cardFrame:SetBackdrop(carddrop)
        cardFrame:SetMovable(false)
        
        ----Shuffle Button----
        wgrGUIm.shuffleButton = CreateFrame("Button",nil,wgrGUIm,"UIPanelButtonTemplate")
        wgrGUIm.shuffleButton:SetPoint("LEFT",wgrGUIm,"BOTTOMLEFT",-5,5)
        wgrGUIm.shuffleButton:SetWidth(64)
        wgrGUIm.shuffleButton:SetHeight(32)
        wgrGUIm.shuffleButton:SetText("Shuffle")
        wgrGUIm.shuffleButton:SetScript("OnEnter", function()
                wgrGUIm.help:SetText("Shuffle this hand back into the deck.")
        end    )
        wgrGUIm.shuffleButton:SetScript("OnLeave", function()
                wgrGUIm.help:SetText("")
        end    )
        wgrGUIm.shuffleButton:Hide()
        -----cardFrame and texture tables-----
        local cFrame = {}
        local cftex = {}
        local cBack = {}
        local cbT
        local totCards = 12
        local columns = totCards/2
        local cfw = cardFrame:GetWidth()/(columns)
        local cfh = cardFrame:GetHeight()/5
        -----cardframe gen-----
        for i=1, totCards, 1 do
            local fac = {}
            if i<=(columns) then fac[1]=cfh; fac[2]=0 else fac[1]=-cfh; fac[2]=1 end
            --setting frame/ texture for bg
            cBack[i]=CreateFrame("Frame", "back"..i,cardFrame)
            cBack[i]:SetSize(55, 65)
            cBack[i]:SetPoint("LEFT",cardFrame, "LEFT", (((i-1)%columns)*cfw)+23,fac[1])
            cBack[i]:Hide()
            cbT=cBack[i]:CreateTexture("cardbg")
            cbT:SetTexture(spellbook)
            cbT:SetTexCoord(0, .7, 0, .7)
            cbT:SetAllPoints()
            --setting the frame/ texture for class grid to 0,0
            cFrame[i]=CreateFrame("Frame", "cFrame"..i,cBack[i])
            cFrame[i]:SetSize(43, 43)
            cFrame[i]:SetPoint("LEFT", cBack[i], "LEFT", 5, 7)
            cftex[i] = cFrame[i]:CreateTexture("cFrame"..i.."Texture")
            cftex[i]:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
            cftex[i]:SetTexCoord(0,0,0,0)
            cftex[i]:SetAllPoints()
            -- the hopeful buttons
            cFrame[i].btn=CreateFrame("Button", nil, cFrame[i], "SecureHandlerClickTemplate" ) 
            cFrame[i].btn:SetSize(0, 0)
            cFrame[i].btn:SetPoint("LEFT", cBack[i], "LEFT", 5, 7)
            cFrame[i].btn:RegisterForClicks("AnyUp")
            cFrame[i].btn:SetNormalTexture("Interface\\SPELLBOOK\\GuildSpellbooktabIconFrame")
            cFrame[i].btn:SetPushedTexture("Interface\\BUTTONS\\UI-Quickslot-Depress")
            cFrame[i].btn:SetHighlightTexture("Interface\\"..btnHgh[2])
            cFrame[i].btn:SetScript("OnLeave", function() wgrGUIm.help:SetText("") end)
            cFrame[i].btn.class=""
            cFrame[i].btn.once_avlbl=true
            cFrame[i].btn.each_avlbl=false
            cFrame[i].btn.score=0
            
            cFrame[i].text = cFrame[i]:CreateFontString()
            cFrame[i].text:SetParent(cFrame[i])
            cFrame[i].text:SetPoint("BOTTOM",cFrame[i],"BOTTOM",0,-11)
            cFrame[i].text:SetFontObject("GameFontHighlight")--("NumberFontNormalHuge")GameFontDisable
            cFrame[i].text:SetText("")
            cFrame[i].text:SetWidth(cFrame[i]:GetWidth() + 10)
        end
        cFrame[1].boss=cardFrame:CreateTexture("boss")
        cFrame[1].boss:SetSize(128, 64)
        cFrame[1].boss:Hide()
        
        -----wager frame-----
        local wFrm = CreateFrame("Frame","wagers", wgrGUIm)
        wFrm:SetSize(120,50)
        wFrm:SetPoint("TOPLEFT",wgrGUIm,"TOPLEFT",26,-80)
        wFrm:SetScript("OnEnter", function()
                wgrGUIm.help:SetText("Taken from purse, but returned twofold if you win.",1,1,1,true)
        end    )
        wFrm:SetScript("OnLeave", function()
                wgrGUIm.help:SetText("")
        end    )
        local wagedrop = {
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = {
                left = 11,
                right = 12,
                top = 12,
                bottom = 11
            }
        }
        wFrm:SetBackdrop(wagedrop)
        wfParch=wFrm:CreateTexture("wfParchex")
        wfParch:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment")
        wfParch:SetPoint("TOPLEFT", wFrm, "TOPLEFT", 11, -13)
        wfParch:SetSize(98, 26)
        wFrm.cur_gc=wFrm:CreateFontString()
        wFrm.cur_gc:SetParent(wFrm)
        wFrm.cur_gc:SetPoint("TOPLEFT",wFrm,"TOPLEFT",-10,-5)
        wFrm.cur_gc:SetFontObject("NumberFontNormalHuge")
        wFrm.cur_gc:SetText("")
        wFrm.cur_gc:SetWidth(wFrm:GetWidth())
        wFrm.cur_gc:SetHeight(40)
        wFrm.cur_gc.hdr=wFrm:CreateFontString()
        wFrm.cur_gc.hdr:SetParent(wFrm)
        wFrm.cur_gc.hdr:SetPoint("TOPLEFT",wFrm,"TOPLEFT",-10,35)
        wFrm.cur_gc.hdr:SetFontObject("GameFontNormal")
        wFrm.cur_gc.hdr:SetText("Current wager:")
        wFrm.cur_gc.hdr:SetWidth(wFrm:GetWidth())
        wFrm.cur_gc.hdr:SetHeight(30)
        wFrm.p_gc=wFrm:CreateFontString()
        wFrm.p_gc:SetParent(wFrm)
        wFrm.p_gc:SetPoint("BOTTOMLEFT",wFrm,"BOTTOMLEFT",-20,-105)
        wFrm.p_gc:SetFontObject("GameFontNormal")
        wFrm.p_gc:SetText(xyzzy)
        wFrm.p_gc:SetWidth(wFrm:GetWidth())
        wFrm.p_gc:SetHeight(30)
        
        wFrm.gcImg=wFrm:CreateTexture("coin")
        wFrm.gcImg:SetTexture("Interface\\MONEYFRAME\\UI-GoldIcon")
        wFrm.gcImg:SetPoint("CENTER", wFrm, "BOTTOM", -50, -92)
        
        
        Abtn=CreateFrame("Button", nil, wFrm, "SecureHandlerClickTemplate")
        Abtn:SetPoint("TOP", cardFrame, "TOPLEFT", 40, 65)
        Abtn:SetHighlightTexture("Interface\\"..btnHgh[2]) 
        Abtn:RegisterForClicks("AnyUp")
        Abtn:SetNormalTexture("Interface\\"..aTex[2])
        Abtn:SetPushedTexture("Interface\\"..aTex[2])
        Abtn:SetHighlightTexture("Interface\\"..btnHgh[2])
        Abtn:SetSize(100, 100)
        
        AscoreCd=CreateFrame("Frame","scorecard", cardFrame)
        AscoreCd:SetPoint("LEFT", cardFrame, "RIGHT", 0, 50)
        AscoreCd:SetSize(30, 100)
        AscoreCd.score=wgrGUIm:CreateFontString()
        AscoreCd.score:SetParent(AscoreCd)
        AscoreCd.score:SetPoint("LEFT",cardFrame,"RIGHT",-20,50)
        AscoreCd.score:SetFontObject("NumberFontNormalHuge")
        AscoreCd.score:SetText("-")
        AscoreCd.score:SetWidth(Abtn:GetWidth())
        AscoreCd.score:SetHeight(40)
        AscoreCd.img=AscoreCd:CreateTexture("afac")
        AscoreCd.img:SetTexture("Interface\\"..aTex[2])
        AscoreCd.img:SetPoint("LEFT", AscoreCd, "RIGHT", 25, 0)
        AscoreCd.img:SetSize(35, 35)
        
        Hbtn=CreateFrame("Button", nil, wFrm, "SecureHandlerClickTemplate")
        Hbtn:SetPoint("BOTTOM", cardFrame, "BOTTOMLEFT", 40, -65)
        Hbtn:SetHighlightTexture("Interface\\"..btnHgh[2]) 
        Hbtn:RegisterForClicks("AnyUp")
        Hbtn:SetNormalTexture("Interface\\"..hTex[2])
        Hbtn:SetPushedTexture("Interface\\"..hTex[2])
        Hbtn:SetHighlightTexture("Interface\\"..btnHgh[2])
        Hbtn:SetSize(100, 100)
        
        HscoreCd=CreateFrame("Frame","scorecard", cardFrame)
        HscoreCd:SetPoint("LEFT", cardFrame, "RIGHT", 0, -50)
        HscoreCd:SetSize(30, 100)
        HscoreCd.score=wgrGUIm:CreateFontString()
        HscoreCd.score:SetParent(HscoreCd)
        HscoreCd.score:SetPoint("LEFT",cardFrame,"RIGHT",-20,-50)
        HscoreCd.score:SetFontObject("NumberFontNormalHuge")
        HscoreCd.score:SetText("-")
        HscoreCd.score:SetWidth(Abtn:GetWidth())
        HscoreCd.score:SetHeight(40)
        HscoreCd.img=HscoreCd:CreateTexture("hfac")
        HscoreCd.img:SetTexture("Interface\\"..hTex[2])
        HscoreCd.img:SetPoint("LEFT", HscoreCd, "RIGHT", 25, 0)
        HscoreCd.img:SetSize(35, 35)
        
        wFrm.wgrBtn = CreateFrame("Button",nil,wFrm,"UIPanelButtonTemplate")
        wFrm.wgrBtn:SetPoint("BOTTOMRIGHT",wFrm,"TOPRIGHT",0,30)
        wFrm.wgrBtn:SetWidth(64)
        wFrm.wgrBtn:SetHeight(32)
        wFrm.wgrBtn:SetText("Wager")
        wFrm.wgrBtn:SetScript("OnEnter", function()
                wgrGUIm.help:SetText("Wagered immediately into pot.",1,1,1,true)
        end)
        wFrm.wgrBtn:SetScript("OnLeave", function()
                wgrGUIm.help:SetText("")
        end    )
        
        
        wFrm.input_gc = CreateFrame("EditBox","gold",wFrm,"InputBoxTemplate")
        wFrm.input_gc:SetSize(48,32)
        wFrm.input_gc:SetAutoFocus(false)
        wFrm.input_gc:SetNumeric(true)
        wFrm.input_gc:SetPoint("BOTTOMLEFT",wFrm,"TOPLEFT",0,30)
        wFrm.input_gc:SetText("0")
        
        helpBtn = CreateFrame("Button",nil,wgrGUIm,"UIPanelButtonTemplate")
        helpBtn:SetPoint("BOTTOMRIGHT",wgrGUIm,"TOPRIGHT",-42,-17)
        helpBtn:SetWidth(32)
        helpBtn:SetHeight(32)
        helpBtn:SetText("?")
        helpBtn:SetScript("OnClick", function ()
                wgrGUIm.help:SetText("Sorry the help menu has not been converted yet.",1,1,1,true)

                -- dyn.TriggerOutPort("portB")
        end)
        
        
        
        emtBtn = CreateFrame("Button",nil,wgrGUIm,"UIPanelButtonTemplate")
        emtBtn:SetPoint("BOTTOMRIGHT",wgrGUIm,"TOPRIGHT",-72,-17)
        emtBtn:SetWidth(32)
        emtBtn:SetHeight(32)
        emtBtn:SetText(":)")
        emtBtn:SetScript("OnClick", function () if emotes=="on" then emotes="off" emtBtn:SetText(":|") else emotes="on" emtBtn:SetText(":)") end sf(" emotes toggled "..emotes) end)
        emtBtn:SetScript("OnEnter", function() wgrGUIm.help:SetText("toggle public emotes") end )
        emtBtn:SetScript("OnLeave", function() wgrGUIm.help:SetText("") end )
        mulBtn = CreateFrame("Button",nil,wgrGUIm,"UIPanelButtonTemplate")
        mulBtn:SetPoint("BOTTOMRIGHT",wgrGUIm,"TOPRIGHT",-103,-17)
        mulBtn:SetWidth(32)
        mulBtn:SetHeight(32)
        mulBtn:SetText("+")
        mulBtn:SetScript("OnClick", function () 
                mulTar=UnitName("target")
                if mulInvOut==0 and mulTar~=nil then
                    if mulTar==player or UnitIsPlayer("target")==false then
                        sf('Ye can\'t do that, silly')
                    else
                        mulFrm:Show()
                        mulInvOut=1
                        mulBtn:SetText("-"); 
                        mulFrm.txt:SetText("Waiting on accept from: "..mulTar)
                        mulBtn:SetScript("OnEnter", function() 
                                wgrGUIm.help:SetText("Cancel invitation") 
                        end)
                        local z=GetCurrentMapZone()
                        SendChatMessage("wager"..z..mulTar.." "..player.." "..xyzzy.." invite", "CHANNEL", nil, id); cl('sent "invite" to '..mulTar..' (they need Wager open to receive it)')
                    end
                else
                    mulInvOut=0
                    if accepted~='x' then
                        local z=GetCurrentMapZone(); SendChatMessage("wager"..z..accepted.." "..player.." "..xyzzy..' leave', "CHANNEL", nil, id) 
                        cl('sent "leave" to '..accepted)
                    end
                    accepted="x"
                    mulBtn:SetText("+")
                    mulFrm:Hide()
                end
        end)
        mulBtn:SetScript("OnEnter", function() wgrGUIm.help:SetText("Invite your target to compare scores.  (needs own Wager deck open)") end )
        mulBtn:SetScript("OnLeave", function() wgrGUIm.help:SetText("") end )
        mulFrm=CreateFrame("Frame","multifrm", wgrGUIm)
        mulFrm:SetPoint('BOTTOM', wgrGUIm, 'TOP', 0,-20 )
        mulFrm:SetSize(300, 50)
        
        mulFrm.bg=mulFrm:CreateTexture("stonebg")
        mulFrm.bg:SetTexture(Stone)
        mulFrm.bg:SetSize(278,34)
        mulFrm.bg:SetTexCoord(0, 1, 0, 1)
        mulFrm.bg:SetPoint("TOPLEFT", mulFrm, "TOPLEFT", 11, -12)
        local muldrop = {
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = {
                left = 11,
                right = 12,
                top = 12,
                bottom = 11
            }
        }
        mulFrm:SetBackdrop(muldrop)
        mulFrm.txt=mulFrm:CreateFontString()
        mulFrm.txt:SetParent(mulFrm)
        mulFrm.txt:SetFontObject("GameFontNormal")
        mulFrm.txt:SetText("Waiting on: "..mulTar)
        mulFrm.txt:SetPoint('LEFT', mulFrm, 'LEFT', 15, 0)
        mulFrm:Hide()
        mulFrm.yes = CreateFrame("Button",nil,mulFrm,"UIPanelButtonTemplate")
        mulFrm.yes:SetPoint("LEFT",mulFrm,"RIGHT",0,0)
        mulFrm.yes:SetWidth(32)
        mulFrm.yes:SetHeight(32)
        mulFrm.yes:SetText("Y")
        mulFrm.yes:SetScript("OnClick", function () local z=GetCurrentMapZone(); accepted=requester; mulFrm.yes:Hide(); mulFrm.no:Hide(); gotrqst=false; mulFrm.txt:SetText(accepted..": Awaiting first results"); SendChatMessage("wager"..z..requester.." "..player.." "..xyzzy..' accept', "CHANNEL", nil, id) cl('sent "accept" to '..requester) end)
        mulFrm.yes:Hide()
        mulFrm.no = CreateFrame("Button",nil,mulFrm,"UIPanelButtonTemplate")
        mulFrm.no:SetPoint("LEFT",mulFrm,"RIGHT",34,0)
        mulFrm.no:SetWidth(32)
        mulFrm.no:SetHeight(32)
        mulFrm.no:SetText("N")
        mulFrm.no:SetScript("OnClick", function () local z=GetCurrentMapZone(); accepted='x'; mulFrm:Hide(); mulInvOut=0; mulBtn:SetText("+"); SendChatMessage("wager"..z..requester.." "..player.." "..xyzzy..' no', "CHANNEL", nil, id) cl('sent "decline" to '..requester) end)
        mulFrm.no:Hide()
        -- mulFrm.lv = CreateFrame("Button",nil,mulFrm,"UIPanelCloseButton")
        -- mulFrm.lv:SetSize(32,32)
        -- mulFrm.lv:SetPoint("BOTTOMRIGHT",mulFrm,"TOPRIGHT",-0,-10)
        -- mulFrm.lv:HookScript("OnClick", function() local z=GetCurrentMapZone(); SendChatMessage("wager"..z..accepted.." "..player.." "..xyzzy..' leave', "CHANNEL", nil, id) accepted='x'; mulInvOut=0;  wgrGUIm:UnregisterEvent("CHAT_MSG_CHANNEL"); mulFrm:Hide() cl('sent "leave" to '..accepted) end)
        -- mulFrm.lv:Hide()
        ----functions----
        
        local function adjWgr(class) 
            local new_wager_gc = math.floor(wager_gc*wager_mod)
            local diff=new_wager_gc-wager_gc
            if diff > xyzzy then    
                sf(" You don't have the coin for that!")
            elseif new_wager_gc < 0 then
                sf(" That ain't nothin!.")
            else
                xyzzy=xyzzy-diff; --z() 
                wFrm.p_gc:SetText(xyzzy)
                wager_gc = new_wager_gc
                if wager_gc <=0 then
                wager_gc=1 end
                wFrm.cur_gc:SetText(wager_gc)
                if class~=nil and diff>0 then
                    sf(" Your "..class.." increases the wager by "..diff.." coin.")
                elseif class~=nil and diff<0 then
                    sf(" Your "..class.." shrinks the wager by "..math.abs(diff).." coin.")
                else
                    sf(" Your wager adjusted by "..diff.." coin.")
                end
                PlaySoundFile("Sound\\INTERFACE\\LootCoinLarge.ogg", .7)  
            end
        end
        
        local function updateAvlbl()
            for i,v in pairs(cFrame) do
                cFrame[i].btn.once_avlbl=false
                if cFrame[i].btn.each_avlbl == false then 
                    cFrame[i].btn:SetNormalTexture("Interface\\SPELLBOOK\\GuildSpellbooktabIconFrame")
                    cFrame[i].btn:SetPushedTexture("Interface\\BUTTONS\\UI-Quickslot-Depress")
                    cFrame[i].btn:SetSize(43, 43)
                    cFrame[i].btn:SetScale(1)
                    cFrame[i].btn:SetPoint("LEFT", cBack[i], "LEFT", 5, 7)
                    cFrame[i].btn:SetScript("OnClick", function() sf("This card is exhausted.") end)
                end
            end
        end
        
        local function retally()
            aS=0; hS=0
            for i=1, columns, 1 do
                local a=cFrame[i].btn.score
                aS=aS+a
                local h=cFrame[i+columns].btn.score
                hS=hS+h
            end
            if faction=="Alliance" then
                aS=aS+surplus.active; hS=hS+bossAdd
            else
                hS=hS+surplus.active; aS=aS+bossAdd
            end
            if aS>hS then w="Alliance"; aS=math.floor(aS-hS); hS=0; AscoreCd.score:SetText(aS); AscoreCd:Show(); HscoreCd:Hide()--HscoreCd.score:SetText("") 
            elseif hS>aS then w="Horde"; hS=math.floor(hS-aS); aS=0; HscoreCd.score:SetText(hS); HscoreCd:Show(); AscoreCd:Hide()--AscoreCd.score:SetText("") 
            else w=0; aS=0; hS=0; HscoreCd.score:SetText("-"); AscoreCd.score:SetText("-")
            end
        end
        
        local function shuffle()
            for i,v in pairs(cFrame) do
                cFrame[i].text:SetText("")
                cFrame[i].btn.each_avlbl=false
                cFrame[i].btn.once_avlbl=false
                cFrame[i].btn.score=0
                cftex[i]:SetTexCoord(0,0,0,0)
                cBack[i]:Hide()
            end
            local z=GetCurrentMapZone()
            deal = 1
            wFrm.input_gc:SetText("0")
            wFrm.cur_gc:SetText("")
            wFrm.wgrBtn:Show()
            wFrm.input_gc:Show()
            startG=xyzzy
            faction_set=0; faction=""; carddrop["bgFile"]="Interface\\DialogFrame\\UI-DialogBox-Background"; carddrop["tile"]=true; cardFrame:SetBackdrop(carddrop);
            aS=0;hS=0; w=0
            surplus.active=surplus.queud
            surplus.queud=0
            thisBoss=0; bossAdd=0;
            cFrame[1].boss:Hide()
            AscoreCd.score:SetText("-"); HscoreCd.score:SetText("-")
            wgrGUIm.drawButton:SetScript("OnClick",function() sf(" You must pick a wager and a faction.")end)
            tally=tally+1
            if accepted~="x" then
                SendChatMessage("wager"..z..accepted.." "..player.." "..xyzzy..' eoh '..tally, "CHANNEL", nil, id) cl('sent tally to '..accepted);  
            end
            DoEmote("read")
             -- 2 sec delay blorb
            -- DoEmote("read")
            PlaySoundFile("Sound\\INTERFACE\\PickUp\\PickUpParchment_Paper.ogg", 2)
            sf(" The deck has been shuffled.")
        end
        
        local function endHand()
            if faction==w then
                PlaySoundFile("Sound\\INTERFACE\\LootCoinLarge.ogg", 0)
                ffrm(.2, .2, 2, wgr_colors.yellow, .5, nil)--"Interface\\BUTTONS\\GoldGradiant")
                xyzzy=xyzzy+(wager_gc*2);
                sf("You win the wager of "..wager_gc.." twice over, totaling "..(wager_gc*2).." gold")
                if emotes=="on" then
                    if (xyzzy/startG)>1.7 then
                        DoEmote('whistle')
                    elseif (xyzzy/startG)>1.3 then
                        DoEmote('cheer') 
                    else
                        -- DoEmote('')
                        print('[Wager]: You consolidate your winnings and reshuffle.')
                        -- SendChatMessage("nods bruskly and reshuffles "..gend[gen].." deck of cards.", 'EMOTE')
                    end
                end
                ko_msg_text="" 
                if xyzzy >= cap then
                    vic1 = "You have Wagered well!"
                    vic2 = "Return this deck for your gold and a prize."
                    SendChatMessage("cracks a big grin and pockets their deck of cards.", 'EMOTE')
                    dyn.TriggerOutPort("portA")
                end
                -- z()
                wFrm.cur_gc:SetText("")
                wFrm.input_gc:SetText("0")
                wFrm.p_gc:SetText(xyzzy)
                wager_gc=0
            elseif w==0 then
                xyzzy=xyzzy+(wager_gc); --z()
                wFrm.cur_gc:SetText("")
                wFrm.input_gc:SetText("0")
                wFrm.p_gc:SetText(xyzzy)
                ffrm(.2, .2, 2, nil, .5, "Interface\\BUTTONS\\GreyscaleRamp64")
                sf(" A tie!  Your wager has been returned.")
                wager_gc=0
            else
                wFrm.cur_gc:SetText("")
                wFrm.input_gc:SetText("0"); --z()
                PlaySoundFile("Sound\\DOODAD\\OpenChest.ogg", 0)
                ffrm(.2, .2, 2, wgr_colors.black, .8)
                sf(" You lost a wager of "..wager_gc.." gold.")
                if xyzzy==0 then
                    if emotes=="on" then
                        DoEmote('cry')
                    end
                else
                    if emotes=="on" then
                        DoEmote('sigh')
                    else
                        print("[Wager]: You sigh and reshuffle your deck.")
                    end
                end
                wager_gc=0
            end    
            IWgrVar.init=xyzzy
            wgrGUIm.endBtn:Hide()
            shuffle()
        end
        
        local function cStrings(x)
            if x==11 then
                x="Jack"
            elseif x==12 then
                x="Queen"
            elseif x==13 then
                x="King"
            elseif x==1 then
                x="Ace"
            end
            return x
        end
        
        local function mageFunc(a, h)
            local x=cFrame[a].btn.score; 
            local y=cFrame[h].btn.score;
            if faction=="Alliance" then
                cFrame[a].btn.score=y;
                cFrame[a].text:SetText(cFrame[h].text:GetText())
            else
                cFrame[h].btn.score=x;
                cFrame[h].text:SetText(cFrame[a].text:GetText())
            end
            local over=math.abs(x-y)
            sf(' The mage sends '..over.." points through interdimensional portals to next round!")
            surplus.queud=surplus.queud+(over)
        end
        
        local function morPhunc(a, h)
            local x=cFrame[a].btn.score
            local y=cFrame[h].btn.score
            if faction==w then
                wager_mod=1+(.05*math.abs(x-y))
            elseif w~=0 then
                wager_mod=1-(.05*math.abs(x-y))
            else 
                wager_mod=1
                sf("It's tied - can't modify now!")
            end
        end        
        
        local function un_holyFunc( a, h, clicked )
            local diff=math.abs(cFrame[a].btn.score - cFrame[h].btn.score)
            if diff>10 then
                diff=10
            end
            if cFrame[clicked].btn.class=="Paladin" then
                wager_mod=1-(.1*diff)
            else
                wager_mod=1+(.1*diff) 
            end
        end
        
        local function priestFunc(a, h, clicked)
            local heal=0
            local worst=12
            local current=0
            local cS=cFrame[clicked].btn.score
            if faction=="Alliance" then
                local priestAdv=cS-cFrame[h].btn.score
                for i=1, deal, 1 do
                    current = cFrame[i].btn.score-cFrame[i+columns].btn.score
                    if current<0 and current<worst then
                        worst=current
                        heal=i
                    end
                end
                if heal>0 then
                    local new=math.min(priestAdv+cFrame[heal].btn.score, cFrame[heal+columns].btn.score)
                    cFrame[heal].btn.score=new
                    cFrame[heal].text:SetText(cStrings(new))
                    sf("Your "..cFrame[heal].btn.class.." has been healed!")
                else
                    sf("Your priest has gone crazy, there is no one to heal!")
                end
            else
                local priestAdv=cS-cFrame[a].btn.score
                for i=1, deal, 1 do
                    current = cFrame[i+columns].btn.score-cFrame[i].btn.score
                    if current<0 and current<worst then
                        worst=current
                        heal=i+columns
                    end
                end
                if heal>0 then
                    local new=math.min(priestAdv+cFrame[heal].btn.score, cFrame[heal-columns].btn.score)
                    cFrame[heal].btn.score=new
                    cFrame[heal].text:SetText(cStrings(new))
                    sf("Your "..cFrame[heal].btn.class.." has been healed!")
                else
                    sf("Your priest has gone crazy, there is no one to heal!")
                end
            end  
        end
        
        local function warFunc()
            if faction==w then
                wager_mod=1.1;
            elseif
            faction~=0 then
                wager_mod=1.5
            else
                wager_mod=1.4
            end
        end
        
        local function lockFunc(a, h, clicked, opClass)
            local x=cFrame[a].btn.score
            local y=cFrame[h].btn.scorej
            local cpS=cFrame[clicked].btn.score
            local xx=cFrame[a].text:GetText()
            local yy=cFrame[h].text:GetText()
            local op=0
            if clicked<=columns then
                op= clicked+6
            else
                op= clicked-6
            end
            if opClass=="Priest" or opClass=="Paladin" then
                cFrame[clicked].btn.score=cFrame[clicked].btn.score-1
                cFrame[clicked].text:SetText(cStrings(cFrame[clicked].btn.score))
                sf(" Your warlock rages in useless futility against the countermagic!!")
            elseif opClass=="Warlock" then
                local rrCli=(math.random(1,13))
                local rrOpp=(math.random(1,13))
                cFrame[clicked].btn.score=rrCli
                cFrame[op].btn.score=rrOpp
                cFrame[clicked].text:SetText(cStrings(rrCli))
                cFrame[op].text:SetText(cStrings(rrOpp))
                sf(" An explosion of fel magic randomly resets your scores!!")
            else
                if cFrame[op].btn.score>cpS then 
                    cFrame[clicked].btn.score=math.min(math.floor(cpS+(cpS*.25), 13))
                    cFrame[op].btn.score=cFrame[op].btn.score-(math.floor(cpS*.5)) 
                    sf(" Your warlock cackles quietly, \"heheheee...\"")
                elseif cFrame[op].btn.score<cpS then  
                    cFrame[clicked].btn.score=math.min(cpS+math.floor(cFrame[op].btn.score*.25), 13) 
                    cFrame[op].btn.score=math.max(0, math.floor(cFrame[op].btn.score-(cpS*.5))) 
                    sf(" Your warlock mercilessly hammers their opponent with fel magic, yikes.")
                else
                    cFrame[clicked].btn.score=math.min(cpS+math.floor(cFrame[op].btn.score*.25), 13) 
                    cFrame[op].btn.score=0 
                end
            end
            local opS=math.floor(cFrame[op].btn.score)
            cpS=cFrame[clicked].btn.score
            cpS=cStrings(cpS)
            opS=cStrings(opS)
            cFrame[clicked].text:SetText(cpS)
            cFrame[op].text:SetText(opS)
        end
        
        local function rgFunc(a, h, clicked)
            local skill=math.abs(cFrame[a].btn.score-cFrame[h].btn.score)
            if skill>10 then 
                sf(" A true master - they never knew what happened.") 
                endHand() 
            else
                local x=math.random(1,10) 
                if skill>x then  
                    if skill>x+3 then
                        sf("Easy peasy lemon squeasy.  Your rogue is a true pro.")
                    else
                        sf(" Your rogue completes the mission and just escapes with their life!  Profit.") 
                    end
                    endHand()
                elseif skill==x then
                    sf(" You have no idea how close that was - your rogue failed but returned unharmed.")
                else 
                    sf(" Tragedy!  Your rogue has been caught behind enemy lines.") 
                    cFrame[clicked].btn.score=0
                    if faction=="Alliance" then
                        cFrame[a].text:SetText("0")
                    else
                        cFrame[h].text:SetText("0")
                    end
                end
            end
        end
        
        
        
        local classes = {
            x_00={class="Warrior", ranged=false, baseFunc=function(aC, hC, clicked, opCls) warFunc() adjWgr("Warrior"); end, aceFunc=function() end, ba="Increase wager by 20% if winning, 60% if losing, 50% if tied", sound="Sound\\Item\\Weapons\\Sword1H\\m1hSwordHitChain1a.ogg"},
            x_01={class="Hunter", ranged=true, baseFunc=function(aC, hC, clicked, opCls) wager_mod=1.15; adjWgr("Hunter"); end, aceFunc=function() end, ba="Increase wager by 25% at any time", sound="Sound\\Item\\Weapons\\MissSwings\\MissWhoosh1Handed.ogg"},
            x_02={class="Paladin", ranged=false, baseFunc=function(aC, hC, clicked, opCls) un_holyFunc(aC, hC, clicked) adjWgr("Paladin") end, aceFunc=function() end, ba="The paladin decreases the wager 10% for every point of advantage", sound="Sound\\Spells\\Paladin_ShieldofRighteousness1.ogg"},
            x_10={class="Mage", ranged=true, baseFunc=function(aC, hC, clicked, opCls) mageFunc(aC, hC) retally() end, aceFunc=function() end, ba="Mage's advantage is nullified, but saved instead for next hand", sound="Sound\\Spells\\DivineStormDamage2.ogg"},
            x_11={class="Shaman", ranged=false, baseFunc=function(aC, hC, clicked, opCls) morPhunc(aC, hC) adjWgr("Shaman") end, aceFunc=function() end, ba="Nudges the wager up if winning, down if losing.  5% per Shaman advantage", sound="Sound\\Spells\\Shaman_Thunder.ogg"},
            x_12={class="Death Knight", ranged=false, baseFunc=function(aC, hC, clicked, opCls) un_holyFunc(aC, hC, clicked) adjWgr("Death Knight") end, aceFunc=function() end, ba="Every point of advantage allows 10% increase in wager, up to 100%", sound="Sound\\Spells\\DeathKnightBloodtap.ogg"},
            x_20={class="Rogue", ranged=false, baseFunc=function(aC, hC, clicked, opCls) rgFunc(aC, hC, clicked) retally() end, aceFunc=function() end, ba="Rogues advantage points give 10% chance each of ending hand immediately", sound="Sound\\Spells\\Rogue_Dismantle.ogg"},
            x_21={class="Priest", ranged=true, baseFunc=function(aC, hC, clicked, opCls) priestFunc(aC, hC, clicked) retally() end, aceFunc=function() end, ba="The uses their advantage points to heal the worst matchup on their side", sound="Sound\\Spells\\FlashHeal_Low_Base.ogg"},
            x_22={class="Monk", ranged=false, baseFunc=function(aC, hC, clicked, opCls) morPhunc(aC, hC) adjWgr("Monk") end, aceFunc=function() end, ba="Nudges the wager up if winning, down if losing.  5% per Monk advantage", sound="Sound\\Spells\\SPELL_MK_RISINGSUNKICK.OGG"},
            x_30={class="Druid", ranged=false, baseFunc=function(aC, hC, clicked, opCls) morPhunc(aC, hC) adjWgr("Druid") end, aceFunc=function() end, ba="Nudges the wager up if winning, down if losing.  5% per Druid advantage", sound="Sound\\Spells\\SPELL_DRU_Windburst04.OGG"},
            x_31={class="Warlock", ranged=true, baseFunc=function(aC, hC, clicked, opCls) lockFunc(aC, hC, clicked, opCls) retally() end, aceFunc=function() end, ba="Drains life based on score.  OH! Watch out for holy types... also other warlocks", sound="Sound\\Spells\\Warlock_soulshatter_Cast_03.ogg"},
            x_32={class="Demon Hunter", ranged=true, baseFunc=function(aC, hC, clicked, opCls) wager_mod=.75; adjWgr("Demon Hunter") end, aceFunc=function() end, ba="Subtract 25% from wager at any time", sound="Sound\\Item\\Weapons\\Sword2H\\m2hSwordHitMetalWeaponCrit.ogg"}
        }   
        
        
        local function rDraw(x)
            local d = {}
            local rando=(math.random(1,13)) - x
            if rando<1 then rando=1 end
            d[1],d[2]=rando, rando
            if d[1]==11 then
                d[2]="Jack"
            elseif d[1]==12 then
                d[2]="Queen"
            elseif d[1]==13 then
                d[2]="King"
            elseif d[1]==1 then
                d[2]="Ace"
            end
            local rX = math.random(0, 3)
            local rY = math.random(0, 2)
            -- local rX = 1
            -- local rY = 0
            return d[1], d[2], rX, rY
        end
        
        local function draw()
            if deal==1 then
                if surplus.active>0 then
                    sf(' Your mage time warps in, blasting the enemy for '..surplus.active..' points!')
                end
            end
            if faction_set==1 and wager_gc~=nil and wager_gc~=0 then
                updateAvlbl()
                local baseFunc
                ---------------------------------THE ACTUAL DRAW
                local f=0
                local bdiff=aS-hS
                local bossible=false
                if faction==w and thisBoss==0 then 
                    f=math.floor(deal*.75)
                    local x=math.random(1, 100)
                    if bdiff>6 and faction=="Alliance" then x=x-bdiff; bossible=true elseif bdiff<-6 and faction=="Horde" then x=x+bdiff; bossible=true end
                    if x<(deal*6) and thisBoss==0 and bossible==true then
                        thisBoss=math.random(1,6)+1
                        bossAdd=math.floor(math.abs(bdiff)*.8)+thisBoss
                        if faction=="Horde" then
                            bf('The enchanted deck calls a mighty general to rally the Alliance, adding '..math.abs(bossAdd)..' pts!')
                            cFrame[1].boss:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-"..aBosses[thisBoss])
                            cFrame[1].boss:SetPoint("BOTTOM", cFrame[1], "TOP", 50, 25)
                            PlaySoundFile(aBosses[1])
                        else
                            bf('The enchanted deck calls on '..hBosses[thisBoss]..' to rally the Horde, adding '..bossAdd..' pts!')
                            cFrame[1].boss:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-"..hBosses[thisBoss])
                            cFrame[1].boss:SetPoint("BOTTOM", cFrame[1], "BOTTOM", 410, -142)
                            PlaySoundFile(hBosses[1])
                        end
                        cFrame[1].boss:Show()
                    end
                else 
                    f=0 
                end --playFac potentially limited
                local adVal, adStr, arX, arY = rDraw(f); --draw A
                local aKey = "x_"..tostring(arX)..tostring(arY)
                arX=arX*0.25
                arY=arY*0.25
                local x=deal
                local y=deal+columns
                cBack[x]:Show()
                cftex[x]:SetTexCoord(arX, arX + 0.24, arY, arY + 0.25) 
                cFrame[x].text:SetText(adStr)
                local aClass=classes[aKey].class
                cFrame[x].btn.class=aClass
                local ba=classes[aKey].ba
                local argd=classes[aKey].ranged
                if argd==true then cFrame[x].btn.each_avlbl=true end
                local a=adVal
                
                local hdVal, hdStr, hrX, hrY = rDraw(f) --draw H
                local hKey = "x_"..tostring(hrX)..tostring(hrY)
                hrX=hrX*0.25
                hrY=hrY*0.25
                cBack[y]:Show()
                cftex[y]:SetTexCoord(hrX, hrX + 0.24, hrY, hrY + 0.25)
                cFrame[y].text:SetText(hdStr)
                cFrame[y].btn:SetSize(43, 43)
                local bh=classes[hKey].ba
                local hClass=classes[hKey].class
                cFrame[y].btn.class=hClass
                local hrgd=classes[hKey].ranged
                if hrgd==true then cFrame[y].btn.each_avlbl=true end
                local h=hdVal
                
                if faction=="Alliance" then
                    baseFunc=classes[aKey].baseFunc
                    cFrame[x].btn:SetScript("OnEnter", function() wgrGUIm.help:SetText(ba) end)
                    cFrame[y].btn:SetScript("OnClick", function() sf(' Nice try, but the enemy refuses to defect.') end)
                else
                    baseFunc=classes[hKey].baseFunc
                    cFrame[y].btn:SetScript("OnEnter", function() wgrGUIm.help:SetText(bh) end)
                    cFrame[x].btn:SetScript("OnClick", function() sf(' Nice try, but the enemy refuses to defect.') end)
                end
                
                local c = a-h
                cFrame[x].btn.score=a
                cFrame[y].btn.score=h
                retally()
                --z()
                
                --set active cards
                if faction=="Alliance" then
                    if c>0 or aClass=="Warlock" then 
                        if cFrame[x].btn.once_avlbl==true then
                        end
                        local aSound=classes[aKey].sound        
                        cFrame[x].btn.once_avlbl = true
                        cFrame[x].btn:SetNormalTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon")
                        cFrame[x].btn:SetPushedTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon")
                        cFrame[x].btn:SetSize(50, 69)
                        cFrame[x].btn:SetScale(1.5)
                        cFrame[x].btn:SetPoint("LEFT", cBack[x], "LEFT", -10, -2)
                        cFrame[x].btn:SetScript("OnClick", function() 
                                baseFunc(x, y, x, hClass)
                                PlaySoundFile(aSound)
                                cFrame[x].btn:SetNormalTexture("Interface\\SPELLBOOK\\GuildSpellbooktabIconFrame")
                                cFrame[x].btn:SetPushedTexture("Interface\\BUTTONS\\UI-Quickslot-Depress")
                                cFrame[x].btn:SetSize(43, 43)
                                cFrame[x].btn:SetScale(1)
                                cFrame[x].btn:SetPoint("LEFT", cBack[x], "LEFT", 5, 7)
                                cFrame[x].btn:SetScript("OnClick", function() sf("This card is exhausted.") end)
                        end)
                    end
                elseif c<0 or hClass=="Warlock" then
                    local hSound=classes[hKey].sound
                    if faction=="Horde" then
                        cFrame[y].btn.once_avlbl = true
                        cFrame[y].btn:SetNormalTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon")
                        cFrame[y].btn:SetPushedTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon")
                        cFrame[y].btn:SetSize(50, 69)
                        cFrame[y].btn:SetScale(1.5)
                        cFrame[y].btn:SetPoint("LEFT", cBack[y], "LEFT", -10, -2)
                        cFrame[y].btn:SetScript("OnClick", function() 
                                baseFunc(x, y, y, aClass)
                                PlaySoundFile(hSound)
                                cFrame[y].btn:SetNormalTexture("Interface\\SPELLBOOK\\GuildSpellbooktabIconFrame")
                                cFrame[y].btn:SetPushedTexture("Interface\\BUTTONS\\UI-Quickslot-Depress")
                                cFrame[y].btn:SetSize(43, 43)
                                cFrame[y].btn:SetScale(1)
                                cFrame[y].btn:SetPoint("LEFT", cBack[y], "LEFT", 5, 7)
                                cFrame[y].btn:SetScript("OnClick", function() sf("This card is exhausted.") end)
                        end)
                    end
                end
                --CHECK FOR VICTORY/LOSS
                if deal < (columns) then 
                    deal=deal+1
                elseif deal==(columns) then
                    wgrGUIm.endBtn:Show()
                    wgrGUIm.drawButton:SetScript("OnClick",function() sf("Hand is finished")end)
                end
                PlaySoundFile("Sound\\INTERFACE\\PickUp\\PickUpParchment_Paper.ogg")
            else
                sf("You must pick a wager and a faction.")
            end
        end
        
        -----wager coins
        local enterWager = function()
            wager_gc = tonumber(wFrm.input_gc:GetText())
            if wager_gc==nil or wager_gc==0 then
                sf(" You must choose a wager.")
            elseif wager_gc>xyzzy then 
                sf(" You don't have enough coin for that.")
            elseif xyzzy >= cap then
                sf(" You've capped this deck! Turn it in to redeem it.") 
            else
                PlaySoundFile("Sound\\INTERFACE\\LootCoinLarge.ogg", 0)
                wFrm.cur_gc:SetText(wager_gc)
                wFrm.input_gc:SetText("0")
                xyzzy=xyzzy-wager_gc
                wFrm.p_gc:SetText(xyzzy)
                wgrGUIm.drawButton:SetScript("OnClick",draw)
                wFrm.wgrBtn:Hide()
                wFrm.input_gc:Hide()
                wgrGUIm.drawButton:Show()
                wager_mod=1
            end
            --z()
        end
        --arg2, arg3, arg4, arg5, arg6, arg7, arg8
        local function wgrListen_evt(self, event, arg1, ...)
            local id, name = GetChannelName("xtensionxtooltip2");
            if name=='xtensionxtooltip2' then
                local zone=GetCurrentMapZone()
                local inc={}
                for wurd in arg1:gmatch("%S+") do table.insert(inc, wurd) end 
                if inc[1]==('wager'..zone..player) then
                    if inc[2]==accepted then
                        if inc[4]=='eoh' then                            
                            sf(accepted..' has ended a hand with '..inc[3]..' gold remaining.  ('..inc[5]..' hands so far)')
                        end
                        mulFrm.txt:SetText(accepted..": "..inc[3]..'g')
                        mulFrm:Show()
                    elseif inc[4]=='invite' then
                        if gotrqst==false then
                            requester=inc[2]
                            mulFrm.txt:SetText("Accept invite from "..requester.."?")
                            sf("Accept invite from "..requester.."? (click 'Y/N')")
                            PlaySoundFile("Sound\\DOODAD\\G_GongTroll01.ogg")
                            mulFrm:Show()
                            mulFrm.yes:Show()
                            mulFrm.no:Show()
                            mulInvOut=1
                            gotrqst=true
                            cl('got request from '..requester)
                        else
                        end    
                    elseif inc[4]=='accept' then
                        local z=GetCurrentMapZone()
                        accepted=inc[2]
                        sf('got accept from '..inc[2])
                        mulFrm.txt:SetText(accepted..": "..inc[3]..'g')
                        SendChatMessage("wager"..z..accepted.." "..player.." "..xyzzy..' pingb', "CHANNEL", nil, id)
                    elseif inc[4]=='pingb' and inc[2]==accepted then
                        mulFrm.txt:SetText(accepted..": "..inc[3]..'g')
                    elseif inc[4]=='no' then
                        accepted='x'
                        mulFrm:Hide()
                        mulInvOut=0
                        mulBtn:SetText("+")
                        cl('got decline from '..inc[2])
                    elseif inc[4]=='leave'then
                        sf(accepted..' has left the table.')
                        mulFrm:Hide()
                        mulInvOut=0
                        mulBtn:SetText("+")
                        accepted='x'
                        cl('got "leave" from '..inc[2])
                    end
                else
                end
            end
        end
        
        ----button commands ----
        wgrGUIm.drawButton:SetScript("OnClick", draw)
        wgrGUIm.shuffleButton:SetScript("OnClick",shuffle)
        wgrGUIm.endBtn:SetScript("OnClick", endHand)
        wFrm.wgrBtn:SetScript("OnClick", enterWager)
        Abtn:SetScript("OnClick", function() if faction_set==0 then faction_set=1; faction="Alliance"; carddrop["bgFile"]="Interface\\LFGFRAME\\UI-PVP-BACKGROUND-Alliance"; carddrop["tile"]=false; cardFrame:SetBackdrop(carddrop); PlaySoundFile("Sound\\INTERFACE\\UnsheathMetal.ogg", 0) else sf(alrFac) end end)
        Hbtn:SetScript("OnClick", function() if faction_set==0 then faction_set=1; faction="Horde"; carddrop["bgFile"]="Interface\\LFGFRAME\\UI-PVP-BACKGROUND-Horde"; carddrop["tile"]=false; cardFrame:SetBackdrop(carddrop) PlaySoundFile("Sound\\INTERFACE\\UnsheathMetal.ogg",0) else sf(alrFac) end end)
        wgrGUIm:SetScript("OnEvent", wgrListen_evt);
        wgrGUIm:RegisterEvent("CHAT_MSG_CHANNEL");
        wgrGUIm:Hide()
end--victory condition check
end


function wgrGUIonEvent(table_val, event, addon)
    if event=='ADDON_LOADED' and addon=='Wager' then
        start=100
        cap=200
        xyzzy=0
        if IWgrVar==nil then IWgrVar={} end
        if IWgrVar.fac_init==nil then IWgrVar.fac_init=0 end

        if IWgrVar.init==nil or type(IWgrVar.init)=='string' then 
            IWgrVar.init=start 
        else
            -- IWgrVar.init = tonumber(ytd(IWgrVar.init, enc1, true))
        end

        xyzzy=IWgrVar.init 
        
        -- z=function()
            -- local sx=tostring(xyzzy)
            -- local zeta = ytd(sx, enc1)
            -- stack.SetAttribute('a', zeta)
            -- IWgrVar.init=zeta
        -- end
        wgrInit()
    elseif event=='PLAYER_LOGOUT' and addon=='RollPlay' then
        -- z()
    end
end

wgrGUI:SetScript('OnEvent', wgrGUIonEvent)
wgrGUI.tggl:SetScript("OnClick", function() 
    PlaySoundFile("Sound\\INTERFACE\\PickUp\\PickUpParchment_Paper.ogg")
    DoEmote("read");  
    if wgr_show==true then 
        wgrGUIm:Hide(); wgr_show=false 
    else 
        wgr_show=true; wgrGUIm:Show() 
    end 
end)
