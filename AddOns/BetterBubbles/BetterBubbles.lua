-- BetterBubbles


-- [RAID ICONS] Mapping for {skull}, {rt1}, etc.
local raidIconMap = {
	skull = 8,
	cross = 7,
	x = 7,
	square = 6,
	moon = 5,
	triangle = 4,
	diamond = 3,
	circle = 2,
	star = 1,
	rt1 = 1,
	rt2 = 2,
	rt3 = 3,
	rt4 = 4,
	rt5 = 5,
	rt6 = 6,
	rt7 = 7,
	rt8 = 8,
}

-----------------------------
-- Default Configuration
-----------------------------
local defaultSettings = {
	bg = {
		texture = "Interface\\AddOns\\BetterBubbles\\textures\\background",
		color = {0.11, 0.11, 0.12, 0.9},
		tile = false,
	},
	bd = {
		texture = "Interface\\ChatFrame\\ChatFrameBackground",
		size = 1,
		color = {0.11, 0.11, 0.12, 0.9},
		inset = 4,
	},
	tail = {
		bgTexture = "Interface\\AddOns\\BetterBubbles\\textures\\tailbg",
		bdTexture = "Interface\\AddOns\\BetterBubbles\\textures\\tailbd",
		visible = true,
		scale = 0.8,
	},
	fontText = {"Interface\\AddOns\\BetterBubbles\\Accidental Presidency.ttf", 10},
	fontSender = {"Interface\\AddOns\\BetterBubbles\\Accidental Presidency.ttf", 10, "OUTLINE"},
	showSender = true,
	padding = {
		textToLeftEdge = 4,
		textToRightEdge = 4,
		textToBottomEdge = 4,
		senderToTopEdge = 1,
	},
	maxWidth = 150,
	raidIconSize = 14,
}

-----------------------------
-- Utility Functions
-----------------------------
local function deepCopy(orig)
    local orig_type = type(orig)
    if orig_type ~= 'table' then
        return orig
    end
    local copy = {}
    for orig_key, orig_value in next, orig, nil do
        copy[deepCopy(orig_key)] = deepCopy(orig_value)
    end
    return copy
end

local settings = deepCopy(defaultSettings)

-- [RAID ICONS] Function to replace {icon} syntax with actual icon textures
local function ReplaceRaidIcons(text)
	if not text then return "" end
	return text:gsub("{(.-)}", function(token)
		local key = token:lower()
		local iconIndex = raidIconMap[key]
		if iconIndex then
		return "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. iconIndex .. ":" .. (settings.raidIconSize or 10) .. "|t"

		else
			return "{" .. token .. "}"
		end
	end)
end

local events = {
	CHAT_MSG_SAY = "chatBubbles", CHAT_MSG_YELL = "chatBubbles",
	CHAT_MSG_PARTY = "chatBubblesParty", CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
	CHAT_MSG_MONSTER_SAY = "chatBubbles", CHAT_MSG_MONSTER_YELL = "chatBubbles", CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
}

-----------------------------
-- Helper Math Functions
-----------------------------
local function FixedScale(len)
	return GetScreenHeight() * len / 768
end

local function RotateCoordPair(x, y, ox, oy, a, asp)
	y = y / asp
	oy = oy / asp
	return ox + (x - ox) * math.cos(a) - (y - oy) * math.sin(a),
		(oy + (y - oy) * math.cos(a) + (x - ox) * math.sin(a)) * asp
end

local function SetRotatedTexCoords(tex, left, right, top, bottom, width, height, angle, originx, originy)
	local ratio, angle, originx, originy = width / height, math.rad(angle), originx or 0.5, originy or 1
	local LRx, LRy = RotateCoordPair(left, top, originx, originy, angle, ratio)
	local LLx, LLy = RotateCoordPair(left, bottom, originx, originy, angle, ratio)
	local ULx, ULy = RotateCoordPair(right, top, originx, originy, angle, ratio)
	local URx, URy = RotateCoordPair(right, bottom, originx, originy, angle, ratio)
	tex:SetTexCoord(LRx, LRy, LLx, LLy, ULx, ULy, URx, URy)
end

-----------------------------
-- Frame Skinning
-----------------------------
local function SkinFrame(frame)
	-- Remove only background textures, keep the tail intact
	for i = 1, select("#", frame:GetRegions()) do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			if region:GetTexture() ~= "Interface\\Tooltips\\ChatBubble-Tail" then
				region:SetTexture(nil)
			end
		end
	end

	-- Find or assign the main text FontString
	for i = 1, select("#", frame:GetRegions()) do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "FontString" then
			frame.text = region
			break
		end
	end

	frame.text:SetFont(unpack(settings.fontText))
	frame.text:SetJustifyH("LEFT")

	-- Setup or clear sender FontString
	if not frame.sender then
		frame.sender = frame:CreateFontString(nil, "OVERLAY")
		frame.sender:SetFont(unpack(settings.fontSender))
		frame.sender:SetJustifyH("LEFT")
	else
		frame.sender:ClearAllPoints()
	end
	frame.sender:SetPoint("BOTTOMLEFT", frame.text, "TOPLEFT", 0, settings.padding.senderToTopEdge)

	if settings.showSender then
		frame.sender:Show()
	else
		frame.sender:Hide()
	end

	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", frame.text, -settings.padding.textToLeftEdge, settings.padding.senderToTopEdge + (settings.showSender and frame.sender:GetHeight() or 0))
	frame:SetPoint("BOTTOMRIGHT", frame.text, settings.padding.textToRightEdge, -settings.padding.textToBottomEdge)

	-- Apply backdrop with 1px border
	frame:SetBackdrop({
		bgFile = settings.bg.texture,
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeSize = 1,
		insets = { left = 1, right = 1, top = 1, bottom = 1 },
	})
	frame:SetBackdropColor(unpack(settings.bg.color))
	frame:SetBackdropBorderColor(unpack(settings.bd.color))

	-- Handle tail textures
	local tail = nil
	for i = 1, select("#", frame:GetRegions()) do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\Tooltips\\ChatBubble-Tail" then
			tail = region
			break
		end
	end

	if tail then
		frame.tail = tail

		if not frame.tailBd then
			frame.tailBd = frame:CreateTexture(nil, "BACKGROUND")
		end

		frame.tailBd:SetAllPoints(tail)
		frame.tailBd:SetTexture(settings.tail.bdTexture)
		frame.tailBd:SetVertexColor(unpack(settings.bd.color))

		local tailScale = settings.tail.scale or 1.0

		tail:SetSize(FixedScale(16 * tailScale), FixedScale(16 * tailScale))
		tail:ClearAllPoints()
		tail:SetPoint("TOP", frame, "BOTTOM", 0, 0)

		frame.tailBd:SetSize(FixedScale(16 * tailScale), FixedScale(16 * tailScale))
		frame.tailBd:ClearAllPoints()
		frame.tailBd:SetPoint("TOP", frame, "BOTTOM", 0, 0)

		if settings.tail.visible then
			tail:Show()
			frame.tailBd:Show()
			tail:SetTexture(settings.tail.bgTexture)
			tail:SetVertexColor(unpack(settings.bg.color))
		else
			tail:Hide()
			frame.tailBd:Hide()
		end
	end

	frame:HookScript("OnHide", function() frame.inUse = false end)
end

-----------------------------
-- Frame Update
-----------------------------
local function UpdateFrame(frame, guid, name)
	if not frame.text then
		SkinFrame(frame)
	end

	frame.inUse = true

	if frame.text then
    	frame.text:SetFont(unpack(settings.fontText))
	end
	if frame.sender then
    	frame.sender:SetFont(unpack(settings.fontSender))
	end

	if frame.sender then
	    frame.sender:ClearAllPoints()
	    frame.sender:SetPoint("BOTTOMLEFT", frame.text, "TOPLEFT", 0, settings.padding.senderToTopEdge)

	    if settings.showSender then
	        frame.sender:Show()
	        if name then
	            local class
	            if guid and guid ~= "" then
	                _, class = GetPlayerInfoByGUID(guid)
	            end
	            local color = RAID_CLASS_COLORS[class] or {r = 1, g = 0.82, b = 0}
	            local hex = ("|cFF%02x%02x%02x"):format(color.r * 255, color.g * 255, color.b * 255)
	            frame.sender:SetText(hex .. name .. "|r")
	        end
	    else
	        frame.sender:Hide()
	    end
	end

	if frame.tail and frame.tailBd then
		local tailScale = settings.tail.scale or 1.0
		frame.tail:SetSize(FixedScale(16 * tailScale), FixedScale(16 * tailScale))
		frame.tailBd:SetSize(FixedScale(16 * tailScale), FixedScale(16 * tailScale))

		frame.tail:ClearAllPoints()
		frame.tail:SetPoint("TOP", frame, "BOTTOM", 0, 0)
		frame.tailBd:ClearAllPoints()
		frame.tailBd:SetPoint("TOP", frame, "BOTTOM", 0, 0)

		if settings.tail.visible then
			frame.tail:Show()
			frame.tailBd:Show()
			frame.tail:SetTexture(settings.tail.bgTexture)
			frame.tail:SetVertexColor(unpack(settings.bg.color))
			frame.tailBd:SetTexture(settings.tail.bdTexture)
			frame.tailBd:SetVertexColor(unpack(settings.bd.color))
		else
			frame.tail:Hide()
			frame.tailBd:Hide()
		end
	end

	if frame.text and frame.text:GetText() then
		local original = frame.text:GetText()
		local replaced = ReplaceRaidIcons(original)
		frame.text:SetText(replaced)

		frame.text:SetWidth(1000)
		local textWidth = frame.text:GetStringWidth() or 0


		local senderWidth = 0
		if settings.showSender and frame.sender and frame.sender:GetText() then
			frame.sender:SetWidth(1000)
			senderWidth = frame.sender:GetStringWidth() or 0
		end

		local finalWidth = math.min(math.max(textWidth, senderWidth), settings.maxWidth)
		frame.text:SetWidth(finalWidth)
		if frame.sender then
			frame.sender:SetWidth(finalWidth)
		end
	end
end

-----------------------------
-- Frame Finder
-----------------------------
local function FindFrame(msg)
	for i = 1, WorldFrame:GetNumChildren() do
		local frame = select(i, WorldFrame:GetChildren())
		if not frame:GetName() and not frame.inUse then
			for j = 1, select("#", frame:GetRegions()) do
				local region = select(j, frame:GetRegions())
				if region:GetObjectType() == "FontString" and region:GetText() == msg then
					return frame
				end
			end
		end
	end
end

-----------------------------
-- Refresh All Bubbles
-----------------------------
local function RefreshAllBubbles()
	for i = 1, WorldFrame:GetNumChildren() do
		local frame = select(i, WorldFrame:GetChildren())
		if not frame:GetName() and frame.inUse then
			UpdateFrame(frame)
		end
	end
end

-----------------------------
-- Event Handler
-----------------------------
local f = CreateFrame("Frame")
local nameCache = {}

for event in pairs(events) do
    f:RegisterEvent(event)
end
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(self, event, arg1, sender, _, _, _, _, _, _, _, _, guid)
	if event == "ADDON_LOADED" and arg1 == "BetterBubbles" then
		if type(BetterBubblesDB) ~= "table" then
			BetterBubblesDB = deepCopy(defaultSettings)
		end
		settings = deepCopy(BetterBubblesDB)
		print("BetterBubbles loaded - Type /bb options for commands.")
		return
	end

	if events[event] and GetCVarBool(events[event]) then
		-- Cache the latest name info
		nameCache[arg1] = { guid = guid, sender = sender }

		self.elapsed = 0
		self:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = self.elapsed + elapsed
			local frame = FindFrame(arg1)
			if frame or self.elapsed > 0.3 then
				self:SetScript("OnUpdate", nil)
				if frame then UpdateFrame(frame, guid, sender) end
			end
		end)
	end
end)

C_Timer.After(2, function()
	for i = 1, WorldFrame:GetNumChildren() do
		local frame = select(i, WorldFrame:GetChildren())
		if not frame:GetName() then
			for j = 1, select("#", frame:GetRegions()) do
				local region = select(j, frame:GetRegions())
				if region:GetObjectType() == "FontString" then
					local text = region:GetText()
					if text and nameCache[text] then
						local entry = nameCache[text]
						UpdateFrame(frame, entry.guid, entry.sender)
					else
						UpdateFrame(frame) -- fallback
					end
					break
				end
			end
		end
	end
end)


-----------------------------
-- Slash Commands
-----------------------------
SLASH_BETTERBUBBLES1 = "/bb"

SlashCmdList["BETTERBUBBLES"] = function(msg)
	local cmd, param = msg:match("^(%S*)%s*(.*)$")
	cmd = cmd and cmd:lower() or ""

	if cmd == "options" or cmd == "" then
		print("|cFFEA03FFBetterBubbles Commands:|r")
		print("|cFF00FF00/bb name|r  |cFFFFFFFFtoggles name.|r")
		print("|cFF00FF00/bb tail|r  |cFFFFFFFFtoggles tail.|r")
		print("|cFF00FF00/bb width #|r  |cFFFFFFFFsets max bubble width.|r")
		print("|cFF00FF00/bb chatsize #|r  |cFFFFFFFFsets chat font size.|r")
		print("|cFF00FF00/bb namesize #|r  |cFFFFFFFFsets name font size.|r")
		print("|cFF00FF00/bb tailsize #|r  |cFFFFFFFFscales tail size - e.g. 1.2.|r")
		print("|cFF00FF00/bb iconsize #|r  |cFFFFFFFFsets raid icon size.|r")
		print("|cFF00FF00/bb status|r  |cFFFFFFFFshows current settings.|r")
		print("|cFF00FF00/bb reset|r  |cFFFFFFFFresets all settings to defaults.|r")

	elseif cmd == "name" then
		settings.showSender = not settings.showSender
		BetterBubblesDB = deepCopy(settings)
		print("Sender visibility is now:", settings.showSender and "ON" or "OFF")
		RefreshAllBubbles()

	elseif cmd == "tail" then
		settings.tail.visible = not settings.tail.visible
		BetterBubblesDB = deepCopy(settings)
		print("Tail visibility is now:", settings.tail.visible and "ON" or "OFF")
		RefreshAllBubbles()

	elseif cmd == "width" then
		local width = tonumber(param)
		if width and width > 20 then
			settings.maxWidth = width
			BetterBubblesDB = deepCopy(settings)
			print("Max bubble width set to:", settings.maxWidth)
			RefreshAllBubbles()
		else
			print("Invalid maxwidth value. Please specify a number greater than 20.")
		end

	elseif cmd == "chatsize" then
		local size = tonumber(param)
		if size and size >= 6 and size <= 40 then
			settings.fontText[2] = size
			BetterBubblesDB = deepCopy(settings)
			print("Chat font size set to:", size)
			RefreshAllBubbles()
		else
			print("Invalid chat font size. Use number between 6 and 40.")
		end

	elseif cmd == "namesize" then
		local size = tonumber(param)
		if size and size >= 6 and size <= 40 then
			settings.fontSender[2] = size
			BetterBubblesDB = deepCopy(settings)
			print("Name font size set to:", size)
			RefreshAllBubbles()
		else
			print("Invalid name font size. Use number between 6 and 40.")
		end

	elseif cmd == "tailsize" then
		local scale = tonumber(param)
		if scale and scale > 0 then
			settings.tail.scale = scale
			BetterBubblesDB = deepCopy(settings)
			print("Tail scale set to:", scale)
			RefreshAllBubbles()
		else
			print("Invalid tail scale. Use a positive number like 1.0, 1.5, etc.")
		end

	elseif cmd == "iconsize" then
		local size = tonumber(param)
		if size and size > 0 and size <= 64 then
			settings.raidIconSize = size
			BetterBubblesDB = deepCopy(settings)
			print("Raid icon size set to:", size)
			RefreshAllBubbles()
		else
			print("Invalid icon size. Use a number between 1 and 64.")
		end

	elseif cmd == "status" then
		print("|cFFEA03FFBetterBubbles Current Settings:|r")
		print("Name:", settings.showSender and "ON" or "OFF")
		print("Tail:", settings.tail.visible and "ON" or "OFF")
		print("Max Width:", settings.maxWidth)
		print("Chat font size:", settings.fontText[2])
		print("Name font size:", settings.fontSender[2])
		print("Tail scale:", settings.tail.scale or 1.0)
		print("Raid icon size:", settings.iconSize or 14)

	elseif cmd == "reset" then
		settings = deepCopy(defaultSettings)
		BetterBubblesDB = deepCopy(settings)
		print("Settings reset to defaults.")
		RefreshAllBubbles()

	else
		print("Unknown command. Type /bb or /bb options for commands.")
	end
end
