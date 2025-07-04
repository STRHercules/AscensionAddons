-- TinyTracker
-- Author: lildirtbag
-- Version: 1.0

---------------------------------------
-- Constants
---------------------------------------
local TRACKER_WIDTH, TRACKER_HEIGHT = 200, 500  -- Tracker dimensions
local LINE_TEXT_WIDTH = TRACKER_WIDTH - 20      -- Text width inside tracker
local QUESTS_TOP_OFFSET_Y = 7                   -- Top padding before first quest title.
local OBJECTIVE_INDENT = 10                     -- Horizontal indent for objectives relative to quest titles.
local TITLE_TO_OBJECTIVE_SPACING = 2            -- Space between title and first objective.
local OBJECTIVES_SPACING = 2                    -- Space between each objective under the same quest.
local QUESTS_SPACING = 7                        -- Space between each quest.

TinyTrackerDB = TinyTrackerDB or {}

---------------------------------------
-- Localized Caches, API, Lua & Libraries
---------------------------------------
local linePool             = {}
local questCache           = {}
local questItemCache       = {}
local questHashCache       = {} 
local objectiveTextCache   = {}
local titleCache           = {}
local itemIconCache        = {}
local lastLayoutHash       = nil
local cachedQuestCount     = 0
local lastLayoutUpdate     = 0
local eventFrame           = CreateFrame("Frame")
local updateScheduled      = false
local updateDelay          = 0.2
local updateTimer          = 0
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestLogSelection = GetQuestLogSelection
local SelectQuestLogEntry = SelectQuestLogEntry
local QuestLog_Update = QuestLog_Update
local ShowUIPanel = ShowUIPanel
local QuestMapFrame_OpenToQuestDetails = QuestMapFrame_OpenToQuestDetails
local QuestLog_OpenToQuest = QuestLog_OpenToQuest
local C_Timer = C_Timer
local GameTooltip = GameTooltip
local GameTooltip_Hide = GameTooltip_Hide
local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetTime = GetTime
local IsShiftKeyDown = IsShiftKeyDown
local UIParent = UIParent
local CreateFrame = CreateFrame
local GetItemIcon = GetItemIcon
local InCombatLockdown = InCombatLockdown
local bit = bit
local bit_bxor = bit and bit.bxor
local table_concat = table.concat
local tostring = tostring
local type = type
local pairs = pairs
local ipairs = ipairs
local next = next
local select = select
local print = print
local wipe = wipe

---------------------------------------
-- Combat-Safe Functions
---------------------------------------
local function SafeShow(frame)
    if not frame or type(frame) ~= "table" or not frame.Show then return end
    C_Timer.After(0, function()
        if frame.IsForbidden and frame:IsForbidden() then return end
        if not frame:IsShown() then pcall(frame.Show, frame) end
    end)
end

local function SafeHide(frame)
    if not frame or type(frame) ~= "table" or not frame.Hide then return end
    C_Timer.After(0, function()
        if frame.IsForbidden and frame:IsForbidden() then return end
        if frame:IsShown() then pcall(frame.Hide, frame) end
    end)
end

local afterCombatQueue = {}

local function RunAfterCombat(func)
    if not InCombatLockdown() then
        func()
    else
        table.insert(afterCombatQueue, func)
    end
end

local function ShowQuestItemButton(btn)
    if not btn then return end
    C_Timer.After(0, function()
        if type(btn.IsForbidden) == "function" and btn:IsForbidden() then return end
        if not btn:IsShown() then btn:Show() end
        btn:SetAlpha(1)
        btn:EnableMouse(true)
        if btn.overlay and not btn.overlay:IsShown() then
            btn.overlay:Show()
        end
        if btn.cooldown then btn.cooldown:SetAlpha(1) end
    end)
end

local function HideQuestItemButton(btn)
    if not btn then return end
    C_Timer.After(0, function()
        if type(btn.IsForbidden) == "function" and btn:IsForbidden() then return end
        if btn:IsShown() then btn:Hide() end
        btn:SetAlpha(0)
        btn:EnableMouse(false)
        if btn.overlay and btn.overlay:IsShown() then
            btn.overlay:Hide()
        end
        if btn.cooldown then btn.cooldown:SetAlpha(0) end
    end)
end

---------------------------------------
-- Tracker Frame
---------------------------------------
local tracker = CreateFrame("Frame", "TinyTrackerFrame", UIParent)
tracker:SetSize(TRACKER_WIDTH, TRACKER_HEIGHT)
tracker:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -300, -200)
tracker:SetScale(0.75)
tracker:SetMovable(true)
tracker:EnableMouse(true)
tracker:SetClampedToScreen(true)
tracker:RegisterForDrag("LeftButton")
tracker:SetScript("OnDragStart", function(self) if IsShiftKeyDown() then self:StartMoving() end end)
tracker:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

---------------------------------------
-- Header
---------------------------------------
local header = CreateFrame("Button", "TinyTracker_Header", tracker)
header:SetSize(TRACKER_WIDTH, 30)
header:SetPoint("TOPLEFT", tracker, "TOPLEFT", 0, 0)
header.collapsed = TinyTrackerDB.collapsed or false

header.bg = header:CreateTexture(nil, "BACKGROUND")
header.bg:SetTexture("Interface\\QuestFrame\\ObjectiveTracker")
header.bg:SetSize(250, 90)

header.text = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
header.text:SetPoint("LEFT", header, "LEFT", 38, 5)
header.text:SetText("Objectives (0)")

header:EnableMouse(true)
header:RegisterForDrag("LeftButton")
header:SetScript("OnDragStart", function() if IsShiftKeyDown() then tracker:StartMoving() end end)
header:SetScript("OnDragStop", function() tracker:StopMovingOrSizing() end)

---------------------------------------
-- Content
---------------------------------------
local content = CreateFrame("Frame", nil, tracker)
content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
content:SetSize(TRACKER_WIDTH, TRACKER_HEIGHT - 70)

---------------------------------------
-- Collapse Logic
---------------------------------------
local function UpdateCollapseState()
    if header.collapsed then
        SafeHide(content)
        header.bg:SetTexCoord(0, 0.43, 0.19, 0.34)
        header.bg:SetPoint("TOPLEFT", header, "TOPLEFT", -50, 9)
    else
        SafeShow(content)
        header.bg:SetTexCoord(0, 0.58, 0, 0.15)
        header.bg:SetPoint("TOPLEFT", header, "TOPLEFT", -35, 20)
    end
end

local function UpdateHeaderTitle(count)
    header.text:SetText("Objectives (" .. (count or 0) .. ")")
end

local function ToggleCollapse()
    header.collapsed = not header.collapsed
    TinyTrackerDB.collapsed = header.collapsed

    UpdateCollapseState()
    ScheduleUpdate()
end

---------------------------------------
-- Line Pooling
---------------------------------------
local function CreateLineFrame()
    local frame = CreateFrame("Button", nil, content)
    frame:SetSize(LINE_TEXT_WIDTH, 16)
    frame:EnableMouse(false)

    local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(true)
    fs:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    fs:SetWidth(LINE_TEXT_WIDTH)

    return {
        frame = frame,
        text = fs,
        isTitle = false,
        isComplete = false,
        questIndex = nil,
        inUse = false,
        hasMouseScripts = false,
        currentFont = nil, -- cache for font optimization
    }
end

local function GetLine()
    for _, line in ipairs(linePool) do
        if not line.inUse then
            line.inUse = true
            SafeShow(line.frame)
            return line
        end
    end
    local newLine = CreateLineFrame()
    newLine.inUse = true
    table.insert(linePool, newLine)
    return newLine
end

local function ClearLines()
    for _, line in ipairs(linePool) do
        line.inUse = false
        SafeHide(line.frame)
        line.frame:EnableMouse(false)
        line.isTitle = false
        line.isComplete = false
        line.questIndex = nil
    end
end

-- Cleanup settings for line pool
local lineCleanupInterval = 10
local lastLineCleanup = 0
local linePoolSizeThreshold = 50

local function CleanupLinePool()
    local currentTime = GetTime()
    if (currentTime - lastLineCleanup) < lineCleanupInterval and #linePool < linePoolSizeThreshold then
        return -- skip cleanup this call
    end

    lastLineCleanup = currentTime

    for i = #linePool, 1, -1 do
        local lineEntry = linePool[i]
        if not lineEntry.inUse then
            SafeHide(lineEntry.frame)
            lineEntry.frame:SetParent(nil)
            table.remove(linePool, i)
        end
    end
end

---------------------------------------
-- Quest Hover Highlight
---------------------------------------
local function SetLineColor(line, hovering)
    local fs = line.text
    local newR, newG, newB

    if line.isTitle then
        newR, newG, newB = hovering and 1 or 0.82, hovering and 0.82 or 0.68, 0
    elseif line.isComplete then
        newR, newG, newB = hovering and 0 or 0, hovering and 1 or 0.9, hovering and 0 or 0
    else
        newR, newG, newB = hovering and 1 or 0.85, hovering and 1 or 0.85, hovering and 1 or 0.85
    end

    if line.lastTextColorR ~= newR or line.lastTextColorG ~= newG or line.lastTextColorB ~= newB then
        fs:SetTextColor(newR, newG, newB)
        line.lastTextColorR = newR
        line.lastTextColorG = newG
        line.lastTextColorB = newB
    end
end

local function SetQuestHover(questIndex, hovering)
    for _, line in ipairs(linePool) do
        if line.questIndex == questIndex then
            SetLineColor(line, hovering)
        end
    end
end

---------------------------------------
-- Click to open Quest Details
---------------------------------------
local function OpenQuestDetails(questIndex)
    local _, _, _, _, _, _, _, questID = GetQuestLogTitle(questIndex)
    ShowUIPanel(QuestMapFrame)
    if questID and QuestMapFrame_OpenToQuestDetails then
        QuestMapFrame_OpenToQuestDetails(questID)
    else
        QuestLog_OpenToQuest(questIndex)
    end
end

---------------------------------------
-- Set Up Lines
---------------------------------------
local function SetupLine(line, text, isTitle, isComplete, questIndex)
    -- Remove leading dash and space added by Blizzard for objective lines.
    local cleanText = text:gsub("^%-%s*", "")
    local needsUpdate = line.cachedText ~= cleanText

    if needsUpdate then
        line.text:SetText(cleanText)
        line.cachedText = cleanText
    end

    line.isTitle = isTitle
    line.isComplete = isComplete
    line.questIndex = questIndex

    -- Font logic
    local desiredFont
    if isTitle then
        desiredFont = "normal"
    elseif isComplete then
        desiredFont = "green"
    else
        desiredFont = "highlight"
    end

    if line.currentFont ~= desiredFont then
        if desiredFont == "normal" then
            line.text:SetFontObject(GameFontNormal)
        elseif desiredFont == "green" then
            line.text:SetFontObject(GameFontGreenSmall)
        elseif desiredFont == "highlight" then
            line.text:SetFontObject(GameFontHighlightSmall)
        end
        line.currentFont = desiredFont
    end

    -- Mouse interactivity for title lines
    if line.frame:IsMouseEnabled() ~= isTitle then
        line.frame:EnableMouse(isTitle)
    end

    if isTitle then
        if not line.hasMouseScripts then
            line.frame:SetScript("OnEnter", function()
                SetQuestHover(line.questIndex, true)
            end)
            line.frame:SetScript("OnLeave", function()
                SetQuestHover(line.questIndex, false)
            end)
            line.frame:SetScript("OnMouseUp", function(_, button)
                if button == "LeftButton" then
                    local currentSelection = GetQuestLogSelection()
                    if currentSelection ~= line.questIndex then
                        SelectQuestLogEntry(line.questIndex)
                        QuestLog_Update()
                        C_Timer.After(0.05, function()
                            if GetQuestLogSelection() == line.questIndex then
                                OpenQuestDetails(line.questIndex)
                            end
                        end)
                    else
                        if not (QuestMapFrame and QuestMapFrame:IsShown()) then
                            OpenQuestDetails(line.questIndex)
                        end
                    end
                end
            end)
            line.hasMouseScripts = true
        end
    elseif line.hasMouseScripts then
        line.frame:SetScript("OnEnter", nil)
        line.frame:SetScript("OnLeave", nil)
        line.frame:SetScript("OnMouseUp", nil)
        line.hasMouseScripts = false
    end

    SetLineColor(line, false)
end

---------------------------------------
-- Layout Lines
---------------------------------------
local function BuildLayoutHash()
    local hashParts = {}
    for _, line in ipairs(linePool) do
        if line.inUse then
            table.insert(hashParts, tostring(line.questIndex or "") .. (line.cachedText or ""))
        end
    end
    return table_concat(hashParts, ":")
end

local function LayoutLines()
    local newLayoutHash = BuildLayoutHash()
    if newLayoutHash == lastLayoutHash then return end
    lastLayoutHash = newLayoutHash

    local yOffset = QUESTS_TOP_OFFSET_Y
    local lastWasTitle = false

    for _, line in ipairs(linePool) do
        if line.inUse then
            local height = line.text:GetHeight()
            if line.frame:GetHeight() ~= height then
                line.frame:SetHeight(height)
            end

            local frame = line.frame
            if line.isTitle and lastWasTitle then
                yOffset = yOffset - QUESTS_SPACING
            elseif not lastWasTitle and line.isTitle then
                yOffset = yOffset - QUESTS_SPACING
            end

            if frame.lastYOffset ~= yOffset then
                frame:ClearAllPoints()
                frame:SetPoint("TOPLEFT", content, "TOPLEFT", line.isTitle and 0 or OBJECTIVE_INDENT, yOffset)
                frame.lastYOffset = yOffset
            end

            if line.isTitle then
                yOffset = yOffset - (height + TITLE_TO_OBJECTIVE_SPACING)
            else
                yOffset = yOffset - (height + OBJECTIVES_SPACING)
            end

            lastWasTitle = line.isTitle
        end
    end
end

local layoutUpdateScheduled = false

local function ScheduleLayoutUpdate(delay)
    if layoutUpdateScheduled then return end
    layoutUpdateScheduled = true

    -- First layout pass immediately
    C_Timer.After(delay or 0, function()
        LayoutLines()

        -- Second layout pass next frame
        C_Timer.After(0, function()
            -- Force refresh of all visible texts to update layout properly
            for _, line in ipairs(linePool) do
                if line.inUse and line.text:IsVisible() then
                    line.text:Hide()
                    line.text:Show()
                end
            end
            LayoutLines()
            layoutUpdateScheduled = false
        end)
    end)
end

---------------------------------------
-- Quest Item Buttons & Cooldown Overlays
---------------------------------------
local function GetItemIDFromLink(link)
    if not link then return nil end
    local itemID = link:match("item:(%d+):")
    return tonumber(itemID)
end

local function FindItemInBags(itemLink)
    local targetID = GetItemIDFromLink(itemLink)
    if not targetID then return nil, nil end

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            local id = GetItemIDFromLink(link)
            if id == targetID then
                return bag, slot
            end
        end
    end
    return nil, nil
end

local function UpdateQuestItemCooldown(btn, itemLink)
    if not btn.cooldown then return end
    C_Timer.After(0.1, function()
        local bag, slot = FindItemInBags(itemLink)
        if bag and slot then
            local start, duration, enable = GetContainerItemCooldown(bag, slot)
            if enable == 1 and duration and duration > 1 then
                btn.cooldown:SetCooldown(start, duration)
                SafeShow(btn.cooldown)
                btn.cooldown:SetAlpha(1)
            else
                SafeHide(btn.cooldown)
            end
        else
            SafeHide(btn.cooldown)
        end
    end)
end

local function StopCooldownUpdater(btn)
    if btn.cooldownUpdater then
        btn.cooldownUpdater:Stop()
        btn.cooldownUpdater = nil
    end
end

local function StartCooldownUpdater(btn, itemLink)
    if btn.cooldownUpdater then return end
    btn.cooldownUpdater = btn:CreateAnimationGroup()
    btn.cooldownUpdater:SetLooping("REPEAT")
    local anim = btn.cooldownUpdater:CreateAnimation()
    anim:SetDuration(0.5)
    anim:SetScript("OnFinished", function()
        UpdateQuestItemCooldown(btn, itemLink)
    end)
    btn.cooldownUpdater:Play()
end

local questItemButtonPool = {}

local function CreateQuestItemButton(parent)
    parent = parent or UIParent
    local btn = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
    btn:SetSize(28, 28)
    btn.icon = btn:CreateTexture(nil, "BACKGROUND")
    btn.icon:SetAllPoints()
    btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    btn.overlay = btn:CreateTexture(nil, "ARTWORK")
    btn.overlay:SetTexture("Interface\\COMMON\\WhiteIconFrame")
    btn.overlay:SetPoint("TOPLEFT", btn, "TOPLEFT", -3, 3)
    btn.overlay:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 3, -3)
    btn.overlay:SetVertexColor(0.2, 0.2, 0.2)
    btn.overlay:SetBlendMode("ADD")

    btn.cooldown = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
    btn.cooldown:SetAllPoints(btn.icon)
    if btn.cooldown and btn.cooldown.SetFrameStrata then
        btn.cooldown:SetFrameStrata("MEDIUM")
    end
    if btn.cooldown and type(btn.cooldown.SetFrameLevel) == "function" then
        btn.cooldown:SetFrameLevel(5)  -- fixed low level for cooldown
    end
    SafeHide(btn.cooldown)

    btn.highlight = CreateFrame("Frame", nil, btn)
    btn.highlight:SetAllPoints(btn)
    btn.highlight:SetFrameStrata("HIGH")
    btn.highlight:SetFrameLevel(10)
    btn.highlight.texture = btn.highlight:CreateTexture(nil, "OVERLAY")
    btn.highlight.texture:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    btn.highlight.texture:SetPoint("TOPLEFT", btn.highlight, "TOPLEFT", -14, 15)
    btn.highlight.texture:SetPoint("BOTTOMRIGHT", btn.highlight, "BOTTOMRIGHT", 15, -13)
    btn.highlight.texture:SetBlendMode("ADD")
    btn.highlight.texture:SetVertexColor(1, 1, 0.8, 0.9)
    btn.highlight:Hide()

    btn:SetScript("OnEnter", function(self)
        self.highlight:Show()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local itemLink = self:GetAttribute("item")
        if itemLink then GameTooltip:SetHyperlink(itemLink) end
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function(self)
        self.highlight:Hide()
        GameTooltip_Hide()
    end)

    HideQuestItemButton(btn)
    btn.inUse = false

    return btn
end

local function GetFreeQuestItemButton()
    for _, btn in ipairs(questItemButtonPool) do
        if not btn.inUse then
            btn.inUse = true
            btn.currentItemLink = nil
            btn.icon:SetTexture(nil)
            btn:SetAttribute("type", nil)
            btn:SetAttribute("item", nil)
            SafeHide(btn.cooldown)
            StopCooldownUpdater(btn)
            ShowQuestItemButton(btn)
            return btn
        end
    end
    local newBtn = CreateQuestItemButton(content)
    newBtn.inUse = true
    table.insert(questItemButtonPool, newBtn)
    return newBtn
end

local function ResetQuestItemButtons()
    for _, btn in ipairs(questItemButtonPool) do
        HideQuestItemButton(btn)
        btn.inUse = false
        btn.currentItemLink = nil
        btn:SetAttribute("type", nil)
        btn:SetAttribute("item", nil)
        btn.icon:SetTexture(nil)
        btn:SetNormalTexture(nil)
        SafeHide(btn.cooldown)
        StopCooldownUpdater(btn)
        btn:ClearAllPoints()
        btn:SetParent(content)
    end
end

-- Cleanup settings for quest item button pool
local questItemCleanupInterval = 10
local lastQuestItemCleanup = 0
local questItemPoolSizeThreshold = 30

local function CleanupQuestItemButtonPool()
    local currentTime = GetTime()
    if (currentTime - lastQuestItemCleanup) < questItemCleanupInterval and #questItemButtonPool < questItemPoolSizeThreshold then
        return
    end

    lastQuestItemCleanup = currentTime

    for i = #questItemButtonPool, 1, -1 do
        local btn = questItemButtonPool[i]
        if not btn.inUse then
            HideQuestItemButton(btn)
            btn:SetParent(nil)
            StopCooldownUpdater(btn)
            table.remove(questItemButtonPool, i)
        end
    end
end

---------------------------------------
-- Quest Data Caching and Comparison
---------------------------------------
local function SimpleHash(str)
    local hash = 0
    for i = 1, #str do
        hash = (hash + str:byte(i)) % 2^32
    end
    return tostring(hash)
end

local function FNV1aHash(str)
    local hash = 2166136261
    for i = 1, #str do
        hash = bit_bxor(hash, str:byte(i))
        hash = (hash * 16777619) % 2^32
    end
    return tostring(hash)
end

local hasBit = (type(bit) == "table" and type(bit_bxor) == "function")
local HashFunction = hasBit and FNV1aHash or SimpleHash

local function ComputeQuestHash(questIndex)
    local titleData = titleCache[questIndex]
    local objCache = objectiveTextCache[questIndex]

    if not titleData then return nil end

    local title, _, _, _, isHeader, _, isComplete = unpack(titleData)
    if isHeader or not title then return nil end

    local hashParts = { title, tostring(isComplete) }

    if objCache and objCache.raw then
        for i = 1, #objCache.raw do
            local rawText = objCache.raw[i]
            if rawText then
                hashParts[#hashParts + 1] = rawText
            end
        end
    end

    return HashFunction(table_concat(hashParts))
end

local function CleanObjectiveText(rawText)
    local cleanText = rawText:gsub("|c%x%x%x%x%x%x%x%x|r", "")
    local base, progress = cleanText:match("^(.-):%s*(%d+/%d+)$")
    return base and progress .. " " .. base or cleanText
end

local function GetQuestData(questIndex, numObjectives, itemLink)
    local cachedTitleData = titleCache[questIndex]
    if not cachedTitleData then return nil end

    local title, _, _, _, isHeader, _, isComplete = unpack(cachedTitleData)
    if isHeader or not title then return nil end

    itemLink = itemLink or GetQuestLogSpecialItemInfo(questIndex)
    numObjectives = numObjectives or GetNumQuestLeaderBoards(questIndex)

    local objectives = {}
    objectiveTextCache[questIndex] = objectiveTextCache[questIndex] or { raw = {}, clean = {} }

    for i = 1, numObjectives do
        local rawText, _, done = GetQuestLogLeaderBoard(i, questIndex)
        if rawText then
            if objectiveTextCache[questIndex].raw[i] ~= rawText then
                objectiveTextCache[questIndex].raw[i] = rawText
                objectiveTextCache[questIndex].clean[i] = CleanObjectiveText(rawText)
            end
            table.insert(objectives, { text = objectiveTextCache[questIndex].clean[i], done = done })
        end
    end

    for i = numObjectives + 1, #(objectiveTextCache[questIndex].raw) do
        objectiveTextCache[questIndex].raw[i] = nil
        objectiveTextCache[questIndex].clean[i] = nil
    end

    return {
        title = title,
        isComplete = isComplete and true or false,
        itemLink = itemLink,
        objectives = objectives,
    }
end

---------------------------------------
-- Update TinyTracker
---------------------------------------
function UpdateTinyTracker()
    if InCombatLockdown() then
        RunAfterCombat(UpdateTinyTracker)
        return
    end

    questCache = questCache or {}
    questHashCache = questHashCache or {}
    questItemCache = questItemCache or {}
    objectiveTextCache = objectiveTextCache or {}

    for _, line in ipairs(linePool or {}) do
        line.usedThisFrame = false
    end

    for _, btn in ipairs(questItemButtonPool or {}) do
        btn.inUse = false
    end

    local numQuests = GetNumQuestLogEntries()
    local questsChanged = false
    titleCache = {}

    local newQuestCache = {}
    local newHashCache = {}

    for i = 1, numQuests do
        if IsQuestWatched(i) then
            local titleData = { GetQuestLogTitle(i) }
            titleCache[i] = titleData

            local numObjectives = GetNumQuestLeaderBoards(i)
            local itemLink = GetQuestLogSpecialItemInfo(i)
            local data = GetQuestData(i, numObjectives, itemLink)
            local hash = ComputeQuestHash(i)
            newHashCache[i] = hash

            if data then
                newQuestCache[i] = data
                if questHashCache[i] ~= hash then
                    questsChanged = true
                end
            end
        end
    end

    for k in pairs(questHashCache) do
        if not newHashCache[k] then
            questsChanged = true
            break
        end
    end

    local cachedQuestCount = 0
    for _, data in pairs(newQuestCache) do
        if data and data.title then
            cachedQuestCount = cachedQuestCount + 1
        end
    end

    if cachedQuestCount == 0 then
        questCache = {}
        questHashCache = {}
        objectiveTextCache = {}
        for _, btn in ipairs(questItemButtonPool or {}) do
            if btn.inUse or btn:IsShown() then
                HideQuestItemButton(btn)
                btn.inUse = false
                btn.currentItemLink = nil
                btn.icon:SetTexture(nil)
                btn:SetAttribute("item", nil)
                SafeHide(btn.cooldown)
                StopCooldownUpdater(btn)
            end
        end
        if InCombatLockdown() then
            trackerPendingShow = false
            RunAfterCombat(function()
                SafeHide(tracker)
            end)
        else
            SafeHide(tracker)
        end
        return
    end

    if not questsChanged and questCache and next(questCache) and layoutInitialized then
        UpdateHeaderTitle(cachedQuestCount)
        if header.collapsed then
            SafeHide(content)
        else
            SafeShow(content)
        end
        return
    end

    questCache = newQuestCache
    questHashCache = newHashCache

    if InCombatLockdown() then
        trackerPendingShow = true
    else
        SafeShow(tracker)
        ScheduleLayoutUpdate(0)
        lastLayoutUpdate = GetTime()
    end

    if not header.collapsed and next(questCache) then
        SafeShow(tracker)
    end

    for i = 1, numQuests do
        local data = questCache[i]
        if data then
            local numObjectives = GetNumQuestLeaderBoards(i)
            objectiveTextCache[i] = objectiveTextCache[i] or { raw = {}, clean = {} }

            for j = 1, numObjectives do
                local rawText = select(1, GetQuestLogLeaderBoard(j, i))
                if rawText and objectiveTextCache[i].raw[j] ~= rawText then
                    objectiveTextCache[i].raw[j] = rawText
                    objectiveTextCache[i].clean[j] = CleanObjectiveText(rawText)
                end
            end

            for j = numObjectives + 1, #(objectiveTextCache[i].raw) do
                objectiveTextCache[i].raw[j] = nil
                objectiveTextCache[i].clean[j] = nil
            end
        end
    end

    UpdateHeaderTitle(cachedQuestCount)

    if header.collapsed then
        SafeHide(content)
    else
        SafeShow(content)
    end

    ClearLines()

    for i = 1, numQuests do
        local data = questCache[i]
        if data then
            local line = GetLine()
            line.usedThisFrame = true
            SetupLine(line, data.title, true, false, i)

            local itemLink = data.itemLink
            if itemLink then
                local itemTexture = itemIconCache[itemLink]
                if not itemTexture then
                    local fetchedTexture = GetItemIcon(itemLink)
                    if fetchedTexture and fetchedTexture ~= "" then
                        itemIconCache[itemLink] = fetchedTexture
                        itemTexture = fetchedTexture
                    end
                end

                if itemTexture then
                    local btn = nil
                    for _, b in ipairs(questItemButtonPool or {}) do
                        if b.currentItemLink == itemLink then
                            btn = b
                            break
                        end
                    end

                    if not btn then
                        btn = GetFreeQuestItemButton()
                    end

                    btn.inUse = true

                    if btn.currentItemLink ~= itemLink then
                        btn.icon:SetTexture(itemTexture)
                        btn:SetAttribute("type", "item")
                        btn:SetAttribute("item", itemLink)
                        btn.currentItemLink = itemLink
                        StartCooldownUpdater(btn, itemLink)
                    end

                    ShowQuestItemButton(btn)
                    btn:SetPoint("RIGHT", line.frame, "LEFT", -10, -13)
                end
            end

            if data.isComplete or #data.objectives == 0 then
                local completeLine = GetLine()
                completeLine.usedThisFrame = true
                SetupLine(completeLine, "Complete", false, true, i)
            else
                for _, obj in ipairs(data.objectives) do
                    local text = obj.text
                    local base, progress = text:match("^(.-):%s*(%d+/%d+)$")
                    if base and progress then
                        text = progress .. " " .. base
                    end
                    local objectiveLine = GetLine()
                    objectiveLine.usedThisFrame = true
                    SetupLine(objectiveLine, text or "???", false, obj.done, i)
                end
            end
        end
    end

    for _, btn in ipairs(questItemButtonPool or {}) do
        if not btn.inUse and btn:IsShown() then
            HideQuestItemButton(btn)
            btn.currentItemLink = nil
            btn.icon:SetTexture(nil)
            btn:SetAttribute("item", nil)
            SafeHide(btn.cooldown)
            StopCooldownUpdater(btn)
        end
    end

    for _, line in ipairs(linePool or {}) do
        if not line.usedThisFrame then
            line.frame:Hide()
        end
    end

    local now = GetTime()
    if now - lastLayoutUpdate > 0.2 then
        ScheduleLayoutUpdate(0)
        lastLayoutUpdate = now
    end

    CleanupLinePool()
    CleanupQuestItemButtonPool()
end

---------------------------------------
-- Debounce Updates
---------------------------------------
local pendingUpdate = false
local lastUpdateTime = 0
local MIN_UPDATE_INTERVAL = 0.1

function ScheduleUpdate()
    local now = GetTime()
    local elapsed = now - lastUpdateTime

    if elapsed >= MIN_UPDATE_INTERVAL then
        lastUpdateTime = now
        UpdateTinyTracker()
    elseif not pendingUpdate then
        pendingUpdate = true
        C_Timer.After(MIN_UPDATE_INTERVAL - elapsed, function()
            pendingUpdate = false
            lastUpdateTime = GetTime()
            UpdateTinyTracker()
        end)
    end
end

header:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then
        header.collapsed = not header.collapsed
        TinyTrackerDB.collapsed = header.collapsed
        UpdateCollapseState()
        if not header.collapsed then
            lastLayoutHash = nil
            questCache = {}
            ScheduleUpdate()
        end
    end
end)

---------------------------------------
-- Addon Loaded Events
---------------------------------------
local cacheInitialized = false

tracker:RegisterEvent("ADDON_LOADED")
tracker:RegisterEvent("PLAYER_LOGIN")
tracker:RegisterEvent("PLAYER_REGEN_ENABLED")

tracker:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "TinyTracker" then
        TinyTrackerDB = TinyTrackerDB or {}

        tracker:Hide()

        local savedScale = TinyTrackerDB.scale or 0.75
        RunAfterCombat(function()
            tracker:SetScale(savedScale)
        end)

        header.collapsed = TinyTrackerDB.collapsed or false
        UpdateCollapseState()

        tracker:RegisterEvent("QUEST_LOG_UPDATE")
        tracker:RegisterEvent("QUEST_ACCEPTED")
        tracker:RegisterEvent("QUEST_TURNED_IN")
        tracker:RegisterEvent("QUEST_REMOVED")
        tracker:RegisterEvent("PLAYER_ENTERING_WORLD")

        if WatchFrame then
            WatchFrame:Hide()
            WatchFrame.Show = function() end
        end

        RunAfterCombat(function()
            tracker:EnableMouse(true)
            tracker:SetMovable(true)
        end)

    elseif event == "PLAYER_LOGIN" then
        -- Delay initial quest data update to let quest log stabilize
        C_Timer.After(0.5, function()
            if not cacheInitialized then
                questCache = {}
                UpdateTinyTracker()
                cacheInitialized = true

                hooksecurefunc("AddQuestWatch", function(questID)
                    if cacheInitialized then
                        ScheduleUpdate()
                    end
                end)

                hooksecurefunc("RemoveQuestWatch", function(questID)
                    if cacheInitialized then
                        ScheduleUpdate()
                    end
                end)
            end
        end)

    elseif event == "QUEST_LOG_UPDATE"
        or event == "QUEST_ACCEPTED"
        or event == "PLAYER_ENTERING_WORLD" then
        if cacheInitialized then
            ScheduleUpdate()
        end

    elseif event == "QUEST_REMOVED"
        or event == "QUEST_TURNED_IN" then
        questCache = nil
        questHashCache = nil
        questItemCache = nil

        if InCombatLockdown() then
            RunAfterCombat(function()
                ScheduleUpdate()
            end)
        else
            ScheduleUpdate()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        for _, func in ipairs(afterCombatQueue) do
            func()
        end
        wipe(afterCombatQueue)

        if trackerPendingShow then
            SafeShow(tracker)
            trackerPendingShow = false
            UpdateTinyTracker()
        end
    end
end)

---------------------------------------
-- Slash Command
---------------------------------------
SLASH_TT1 = "/tt"
SlashCmdList["TT"] = function(msg)
    local cmd, arg = msg:match("^(%S*)%s*(.-)$")
    if cmd == "scale" then
        local scale = tonumber(arg)
        if scale and scale > 0 then
            tracker:SetScale(scale)
            TinyTrackerDB.scale = scale  -- Save it
            print(string.format("Tracker scale set to %.2f", scale))
        else
            print("Invalid scale value. Use /tt scale <number> (e.g. /tt scale 0.85)")
        end
    else
        print("Usage: /tt scale <number> (e.g. /tt scale 1.0)")
    end
end