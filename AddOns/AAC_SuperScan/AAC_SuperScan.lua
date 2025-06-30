SuperScan = CreateFrame("Frame")
isSellAllActive = false
currentPage = nil
tempScanData = {}
scanTimer = nil
currentServer = GetRealmName()
currentCharacter = UnitName("player")
scanTimeTracker = {}
scanStartTime = nil
timerText = nil

-- Settings Stuff
local GRID_ROWS = 2
local GRID_COLS = 15
local NUM_GRID_SLOTS = GRID_ROWS * GRID_COLS
local SLOT_SIZE = 30
local SLOT_SPACING = 1
SuperScan.blockedItemSlots = {}

--Enchant stuff
-- GREEN WEAPONS - Higher shard chance, lower essence chance

local DISENCHANT_GREEN_WEAPONS = {
    green_1_15 = {
        { 10940, 1, 2, 0.20 }, -- Strange Dust
        { 10938, 1, 2, 0.80 },  -- Lesser Magic Essence
    },
    green_16_20 = {
        { 10978, 1, 1, 0.05 }, -- Small Glimmering Shard
        { 10940, 2, 3, 0.20 }, -- Strange Dust
        { 10939, 1, 2, 0.75 },  -- Greater Magic Essence
    },
    green_21_25 = {
        { 10998, 1, 2, 0.75 },  -- Lesser Astral Essence
        { 10940, 4, 6, 0.15 }, -- Strange Dust
        { 10978, 1, 1, 0.10 },  -- Small Glimmering Shard
    },
    green_26_30 = {
        { 11083, 1, 2, 0.20 }, -- Soul Dust
        { 11082, 1, 2, 0.75 }, -- Greater Astral Essence
        { 11084, 1, 1, 0.05 }, -- Large Glimmering Shard
    },
    green_31_35 = {
        { 11083, 2, 5, 0.20 }, -- Soul Dust
        { 11134, 1, 2, 0.75 },  -- Lesser Mystic Essence
        { 11138, 1, 1, 0.05 }, -- Small Glowing Shard
    },
    green_36_40 = {
        { 11137, 1, 2, 0.20 }, -- Vision Dust
        { 11135, 1, 2, 0.75 }, -- Greater Mystic Essence
        { 11139, 1, 1, 0.05 }, -- Large Glowing Shard
    },
    green_41_45 = {
        { 11137, 2, 5, 0.20 }, -- Vision Dust
        { 11174, 1, 2, 0.75 },  -- Lesser Nether Essence
        { 11177, 1, 1, 0.05 }, -- Small Radiant Shard
    },
    green_46_50 = {
        { 11176, 1, 2, 0.20 }, -- Dream Dust
        { 11175, 1, 2, 0.75 }, -- Greater Nether Essence
        { 11178, 1, 1, 0.05 }, -- Large Radiant Shard
    },
    green_51_55 = {
        { 11176, 2, 5, 0.22 }, -- Dream Dust
        { 16202, 1, 2, 0.75 }, -- Lesser Eternal Essence
        { 14343, 1, 1, 0.03 }, -- Small Brilliant Shard
    },
    green_56_60 = {
        { 16204, 1, 2, 0.22 }, -- Illusion Dust
        { 16202, 1, 2, 0.75 }, -- Greater Eternal Essence
        { 14344, 1, 1, 0.03 }, -- Large Brilliant Shard
    },
    green_61_70 = {
        { 16204, 2, 5, 0.22 }, -- Illusion Dust
        { 16202, 2, 3, 0.75 }, -- Greater Eternal Essence
        { 14344, 1, 1, 0.03 }, -- Large Brilliant Shard
    },
    green_71_100 = {
        { 22445, 2, 3, 0.22 }, -- Arcane Dust
        { 22447, 2, 3, 0.75 }, -- Lesser Planar Essence
        { 22448, 1, 1, 0.03 }, -- Small Prismatic Shard
    },
    green_101_120 = {
        { 22445, 2, 5, 0.22 }, -- Arcane Dust
        { 22446, 1, 2, 0.75 }, -- Greater Planar Essence
        { 22449, 1, 1, 0.03 }, -- Large Prismatic Shard
    },
}

-- GREEN ARMOR - Lower shard chance, higher essence chance
local DISENCHANT_GREEN_ARMOR = {
    green_1_15 = {
        { 10940, 1, 2, 0.80 }, -- Strange Dust
        { 10938, 1, 2, 0.20 }, -- Lesser Magic Essence
    },
    green_16_20 = {
        { 10978, 1, 1, 0.05 },  -- Small Glimmering Shard
        { 10940, 2, 3, 0.75 }, -- Strange Dust
        { 10939, 1, 2, 0.20 }, -- Greater Magic Essence
    },
    green_21_25 = {
        { 10998, 1, 2, 0.15 }, -- Lesser Astral Essence
        { 10940, 4, 6, 0.75 }, -- Strange Dust
        { 10978, 1, 1, 0.10 }, -- Small Glimmering Shard
    },
    green_26_30 = {
        { 11083, 1, 2, 0.75 }, -- Soul Dust
        { 11082, 1, 2, 0.20 }, -- Greater Astral Essence
        { 11084, 1, 1, 0.05 }, -- Large Glimmering Shard
    },
    green_31_35 = {
        { 11083, 2, 5, 0.75 }, -- Soul Dust
        { 11134, 1, 2, 0.20 }, -- Lesser Mystic Essence
        { 11138, 1, 1, 0.05 }, -- Small Glowing Shard
    },
    green_36_40 = {
        { 11137, 1, 2, 0.75 }, -- Vision Dust
        { 11135, 1, 2, 0.20 }, -- Greater Mystic Essence
        { 11139, 1, 1, 0.05 }, -- Large Glowing Shard
    },
    green_41_45 = {
        { 11137, 2, 5, 0.75 }, -- Vision Dust
        { 11174, 1, 2, 0.20 }, -- Lesser Nether Essence
        { 11177, 1, 1, 0.05 }, -- Small Radiant Shard
    },
    green_46_50 = {
        { 11176, 1, 2, 0.75 }, -- Dream Dust
        { 11175, 1, 2, 0.20 }, -- Greater Nether Essence
        { 11178, 1, 1, 0.05 }, -- Large Radiant Shard
    },
    green_51_55 = {
        { 11176, 2, 5, 0.75 }, -- Dream Dust
        { 16202, 1, 2, 0.22 }, -- Lesser Eternal Essence
        { 14343, 1, 1, 0.05 }, -- Small Brilliant Shard
    },
    green_56_60 = {
        { 16204, 1, 2, 0.75 }, -- Illusion Dust
        { 16202, 1, 2, 0.20 }, -- Greater Eternal Essence
        { 14344, 1, 1, 0.05 }, -- Large Brilliant Shard
    },
    green_61_70 = {
        { 16204, 2, 5, 0.75 }, -- Illusion Dust
        { 16202, 2, 3, 0.20 }, -- Greater Eternal Essence
        { 14344, 1, 1, 0.05 }, -- Large Brilliant Shard
    },
    green_71_100 = {
        { 22445, 2, 3, 0.75 }, -- Arcane Dust
        { 22447, 2, 3, 0.22 }, -- Lesser Planar Essence
        { 22448, 1, 1, 0.03 }, -- Small Prismatic Shard
    },
    green_101_120 = {
        { 22445, 2, 5, 0.75 }, -- Arcane Dust
        { 22446, 1, 2, 0.22 }, -- Greater Planar Essence
        { 22449, 1, 1, 0.03 }, -- Large Prismatic Shard
    },
}

-- BLUE ITEMS (Weapons and Armor combined - mostly shards)
local DISENCHANT_BLUE_ITEMS = {
    blue_1_25 = {
        { 10978, 1, 1, 1.0 } -- Small Glimmering Shard
    },
    blue_26_30 = {
        { 11084, 1, 1, 1.0 } -- Large Glimmering Shard
    },
    blue_31_35 = {
        { 11138, 1, 1, 1.0 } -- Small Glowing Shard
    },
    blue_36_40 = {
        { 11139, 1, 1, 1.0 } -- Large Glowing Shard
    },
    blue_41_45 = {
        { 11177, 1, 1, 1.0 } -- Small Radiant Shard
    },
    blue_46_50 = {
        { 11178, 1, 1, 1.0 } -- Large Radiant Shard
    },
    blue_51_55 = {
        { 14343, 1, 1, 1.0 } -- Small Brilliant Shard
    },
    blue_56_60 = {
        { 14344, 1, 1, 0.95 }, -- Large Brilliant Shard
        { 20725, 1, 1, 0.05 } -- Nexus Crystal
    },
    blue_61_100 = {
        { 22448, 1, 1, 0.95 }, -- Small Prismatic Shard
        { 20725, 1, 1, 0.05 }  -- Nexus Crystal
    },
    blue_101_120 = {
        { 22449, 1, 1, 0.95 }, -- Large Prismatic Shard
        { 22450, 1, 1, 0.05 }  -- Void Crystal
    },
}

-- EPIC ITEMS (Weapons and Armor combined - crystals only)
local DISENCHANT_EPIC_ITEMS = {
    epic_01_50 = {
        { 11177, 2, 4, 1.0 } -- Small Radiant Shard
    },
    epic_51_55 = {
        { 14343, 2, 4, 1.0 } -- Small Brilliant Shard
    },
    epic_56_100 = {
        { 20725, 1, 1, 1.0 } -- Nexus Crystal
    },
    epic_101_199 = {
        { 22450, 1, 1, 1.0 } -- Void Crystal
    },
}

-- Settings Frame
function SuperScan:SaveSettings()
    local currentServer = GetRealmName()
    if not SuperScanDB[currentServer] then SuperScan:InitializeDatabase() end
    local goldThreshold = tonumber(SuperScan.SettingsFrame.InstantListGoldEditBox:GetText())
    if goldThreshold and goldThreshold >= 0 then
        SuperScanDB[currentServer].settings.instantListGoldThreshold = goldThreshold
        print("SuperScan: Instant list threshold saved as " .. goldThreshold .. "g.")
    else
        SuperScan.SettingsFrame.InstantListGoldEditBox:SetText(SuperScanDB[currentServer].settings.instantListGoldThreshold or 5)
        print("SuperScan: Invalid gold threshold. Must be a number >= 0.")
    end
    print("SuperScan: Minimum list percentage saved as " .. SuperScanDB[currentServer].settings.minListPercentage .. "%.")
end

function SuperScan:UpdateBlockedItemsGridDisplay()
    local currentServer = GetRealmName()
    if not SuperScanDB[currentServer] or not SuperScanDB[currentServer].blockedItemsGrid then
        SuperScan:InitializeDatabase() -- Ensure DB is initialized
    end

    for i = 1, NUM_GRID_SLOTS do
        local slotButton = SuperScan.blockedItemSlots[i]
        if slotButton then
            local itemID = SuperScanDB[currentServer].blockedItemsGrid[i]
            local itemTexture = nil
            if itemID and SuperScanDB[currentServer].blockedItems[itemID] then
                itemTexture = select(10, GetItemInfo(itemID)) -- Get item texture by ID
            else
                -- If item is in grid but not in master block list, or itemID is nil, clear it
                SuperScanDB[currentServer].blockedItemsGrid[i] = nil
            end

            if itemTexture then
                slotButton.icon:SetTexture(itemTexture)
                slotButton.icon:Show()
            else
                slotButton.icon:Hide()
            end
        end
    end
end

function SuperScan:CreateSettingsFrame()
    if SuperScan.SettingsFrame then
        return
    end

    local currentServer = GetRealmName()

    -- Main Frame
    local settingsFrame = CreateFrame("Frame", "SuperScanSettingsPanel", AuctionFrame, "BackdropTemplate")
    settingsFrame:SetPoint("BOTTOMLEFT", AuctionFrame, "TOPLEFT", 5, -20)
    settingsFrame:SetSize(AuctionFrame:GetWidth() + 200, 130) 
    settingsFrame:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    settingsFrame:SetBackdropColor(0, 0, 0, 1)
    SuperScan.SettingsFrame = settingsFrame

    -- Title
    local title = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", settingsFrame, "TOP", -50, -13)
    title:SetText("SuperScan Settings")

    -- Left Panel (Settings)
    local settingsPanel = CreateFrame("Frame", nil, settingsFrame)
    settingsPanel:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 20, 5)
    settingsPanel:SetSize(240, settingsFrame:GetHeight())

    -- Instant List Gold Threshold
    local goldLabel = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    goldLabel:SetPoint("TOPLEFT", settingsPanel, "TOPLEFT", 0, -20)
    goldLabel:SetText("Instant Insert Threshold (Gold):")

    local goldEditBox = CreateFrame("EditBox", nil, settingsPanel, "InputBoxTemplate")
    goldEditBox:SetPoint("TOPLEFT", goldLabel, "BOTTOMLEFT", 10, -3)
    goldEditBox:SetSize(100, 20)
    goldEditBox:SetNumeric(true)
    goldEditBox:SetAutoFocus(false)
    goldEditBox:SetText(SuperScanDB[currentServer].settings.instantListGoldThreshold or 5)
    goldEditBox:SetScript("OnEnterPressed", function(self)
        SuperScan:SaveSettings()
        self:ClearFocus()
    end)
    goldEditBox:SetScript("OnEscapePressed", function(self)
        self:SetText(SuperScanDB[currentServer].settings.instantListGoldThreshold or 5)
        self:ClearFocus()
    end)
    settingsFrame.InstantListGoldEditBox = goldEditBox

    -- Min List Percentage Slider
    local percentLabel = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    percentLabel:SetPoint("TOPLEFT", goldEditBox, "BOTTOMLEFT", 0, -15)
    percentLabel:SetText("Minimum List Price (%):")

    -- Create the value text BEFORE the slider
    local percentValueText = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    percentValueText:SetPoint("TOPRIGHT", percentLabel, "BOTTOMRIGHT", 30, 8)
    percentValueText:SetText(SuperScanDB[currentServer].settings.minListPercentage or 80)

    -- Now create the slider
    local percentSlider = CreateFrame("Slider", nil, settingsPanel, "OptionsSliderTemplate")
    percentSlider:SetPoint("TOPLEFT", percentLabel, "BOTTOMLEFT", 10, -15)
    percentSlider:SetWidth(180)
    percentSlider:SetMinMaxValues(30, 100)
    percentSlider:SetValueStep(1)
    percentSlider:SetScript("OnValueChanged", function(self, value)
        -- Round to nearest integer without using floor+0.5 method
        local roundedValue = math.floor(value)
        if (value - roundedValue) >= 0.5 then
            roundedValue = roundedValue + 1
        end
        percentValueText:SetText(roundedValue)
        SuperScanDB[currentServer].settings.minListPercentage = roundedValue
    end)
    percentSlider:SetValue(SuperScanDB[currentServer].settings.minListPercentage or 80) 
    
    -- Add min/max labels
    percentSlider.Low:SetText("30")
    percentSlider.High:SetText("100") 

    settingsFrame.MinPercentageSlider = percentSlider

    -- Right Panel (Blocked Items Grid)
    local gridPanel = CreateFrame("Frame", nil, settingsFrame)
    gridPanel:SetPoint("LEFT", settingsPanel, "RIGHT", 20, 0)
    gridPanel:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", -20, -40)
    gridPanel:SetHeight(settingsFrame:GetHeight() - 50)
    
    local gridTitle = gridPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    gridTitle:SetPoint("TOP", 100, 20)
    gridTitle:SetText("Blocked Items (Drag & Drop, Right-Click to Remove)")

    -- Disenchant Value Checkbox - moved to far right panel
    local rightPanel = CreateFrame("Frame", nil, settingsFrame)
    rightPanel:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", -20, -40)
    rightPanel:SetSize(160, settingsFrame:GetHeight() - 50)

    local disenchantCheckbox = CreateFrame("CheckButton", nil, rightPanel, "UICheckButtonTemplate")
    disenchantCheckbox:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 0, -20)
    disenchantCheckbox:SetSize(20, 20)

    local disenchantLabel = rightPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    disenchantLabel:SetPoint("LEFT", disenchantCheckbox, "RIGHT", 5, 0)
    disenchantLabel:SetText("Show Disenchant\nValues in Tooltip")

    disenchantCheckbox:SetScript("OnClick", function(self)
        SuperScanDB[currentServer].settings.showDisenchantValue = self:GetChecked()
        if self:GetChecked() then
            print("SuperScan: Disenchant values will now show in tooltips")
        else
            print("SuperScan: Disenchant values hidden from tooltips")
        end
    end)

    settingsFrame.DisenchantCheckbox = disenchantCheckbox


    for r = 1, GRID_ROWS do
        for c = 1, GRID_COLS do
            local slotIndex = (r - 1) * GRID_COLS + c
            local slotButton = CreateFrame("Button", "SuperScanBlockedItemSlot" .. slotIndex, gridPanel)
            slotButton:SetSize(SLOT_SIZE, SLOT_SIZE)
            slotButton:SetPoint("TOPLEFT",
                (c - 1) * (SLOT_SIZE + SLOT_SPACING),
                -(r - 1) * (SLOT_SIZE + SLOT_SPACING) - 10) -- -XX for title spacing

            slotButton:SetNormalTexture("Interface/Buttons/UI-Quickslot2") -- Basic background
            
            local icon = slotButton:CreateTexture(nil, "OVERLAY")
            icon:SetAllPoints(slotButton)
            icon:Hide()
            slotButton.icon = icon
            
            slotButton.slotID = slotIndex

            slotButton:RegisterForDrag("LeftButton")
            slotButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

            slotButton:SetScript("OnReceiveDrag", function(self)
                local itemType, itemID, itemLink = GetCursorInfo()
                if itemType == "item" then
                    local itemName = GetItemInfo(itemID)
                    if itemName and itemID then
                        -- Find the actual item in bags to check its real state
                        local sourceBag, sourceSlot = nil, nil
                        for bag = 0, 4 do
                            for slot = 1, GetContainerNumSlots(bag) do
                                local bagItemLink = GetContainerItemLink(bag, slot)
                                if bagItemLink and bagItemLink == itemLink then
                                    sourceBag, sourceSlot = bag, slot
                                    break
                                end
                            end
                            if sourceBag then break end
                        end
            
                        if sourceBag and sourceSlot then
                            -- Check the actual item state using SetBagItem
                            local tooltip = CreateFrame("GameTooltip", "SuperScanTooltipCheck", nil, "GameTooltipTemplate")
                            tooltip:SetOwner(UIParent, "ANCHOR_NONE")
                            tooltip:SetBagItem(sourceBag, sourceSlot)
            
                            local isSoulbound = false
                            for i = 1, tooltip:NumLines() do
                                local text = _G["SuperScanTooltipCheckTextLeft" .. i]:GetText() or ""
                                if text:find("Soulbound") or text:find("Realm Bound") or text:find("Binds when picked up") or text:find("Binds to realm") then
                                    isSoulbound = true
                                    break
                                end
                            end
                            tooltip:Hide()
            
                            if isSoulbound then
                                print("Cannot add soulbound or realmbound Items to the blocked list.")
                                ClearCursor()
                                return
                            end
                        else
                            print("Could not find item in bags to check binding status.")
                            ClearCursor()
                            return
                        end
            
                        -- Check if there's already an item in this slot
                        local previousItemID = SuperScanDB[currentServer].blockedItemsGrid[self.slotID]
                        if previousItemID and previousItemID ~= itemID then
                            -- Remove the previous item from blockedItems if it's not used in any other slot
                            local isUsedElsewhere = false
                            for i = 1, NUM_GRID_SLOTS do
                                if i ~= self.slotID and SuperScanDB[currentServer].blockedItemsGrid[i] == previousItemID then
                                    isUsedElsewhere = true
                                    break
                                end
                            end

                            if not isUsedElsewhere then
                                SuperScanDB[currentServer].blockedItems[previousItemID] = nil
                                local previousItemName = GetItemInfo(previousItemID)
                                print("Unblocked: " .. (previousItemName or "Unknown Item"))
                            end
                        end

                        -- Add the new item
                        SuperScanDB[currentServer].blockedItems[itemID] = true
                        SuperScanDB[currentServer].blockedItemsGrid[self.slotID] = itemID
                        SuperScan:UpdateBlockedItemsGridDisplay()
                        print("Blocked: " .. itemName)
                    end
                end
                ClearCursor()
            end)

            slotButton:SetScript("OnClick", function(self, button)
                if button == "LeftButton" then
                    -- Check if we have an item on cursor
                    local itemType, itemID, itemLink = GetCursorInfo()
                    if itemType == "item" then
                        local itemName = GetItemInfo(itemID)
                        if itemName and itemID then
                            -- Find the actual item in bags to check its real state
                            local sourceBag, sourceSlot = nil, nil
                            for bag = 0, 4 do
                                for slot = 1, GetContainerNumSlots(bag) do
                                    local bagItemLink = GetContainerItemLink(bag, slot)
                                    if bagItemLink and bagItemLink == itemLink then
                                        sourceBag, sourceSlot = bag, slot
                                        break
                                    end
                                end
                                if sourceBag then break end
                            end
            
                            if sourceBag and sourceSlot then
                                -- Check the actual item state using SetBagItem
                                local tooltip = CreateFrame("GameTooltip", "SuperScanTooltipCheck", nil, "GameTooltipTemplate")
                                tooltip:SetOwner(UIParent, "ANCHOR_NONE")
                                tooltip:SetBagItem(sourceBag, sourceSlot)
            
                                local isSoulbound = false
                                for i = 1, tooltip:NumLines() do
                                    local text = _G["SuperScanTooltipCheckTextLeft" .. i]:GetText() or ""
                                    if text:find("Soulbound") or text:find("Realm Bound") or text:find("Binds when picked up") or text:find("Binds to realm") then
                                        isSoulbound = true
                                        break
                                    end
                                end
                                tooltip:Hide()
            
                                if isSoulbound then
                                    print("Cannot add soulbound or realmbound Items to the blocked list.")
                                    ClearCursor()
                                    return
                                end
                            else
                                print("Could not find item in bags to check binding status.")
                                ClearCursor()
                                return
                            end
            
                            -- Check if there's already an item in this slot
                            local previousItemID = SuperScanDB[currentServer].blockedItemsGrid[self.slotID]
                            if previousItemID and previousItemID ~= itemID then
                                -- Remove the previous item from blockedItems if it's not used in any other slot
                                local isUsedElsewhere = false
                                for i = 1, NUM_GRID_SLOTS do
                                    if i ~= self.slotID and SuperScanDB[currentServer].blockedItemsGrid[i] == previousItemID then
                                        isUsedElsewhere = true
                                        break
                                    end
                                end
            
                                if not isUsedElsewhere then
                                    SuperScanDB[currentServer].blockedItems[previousItemID] = nil
                                    local previousItemName = GetItemInfo(previousItemID)
                                    print("Unblocked: " .. (previousItemName or "Unknown Item"))
                                end
                            end
            
                            -- Add the new item
                            SuperScanDB[currentServer].blockedItems[itemID] = true
                            SuperScanDB[currentServer].blockedItemsGrid[self.slotID] = itemID
                            SuperScan:UpdateBlockedItemsGridDisplay()
                            print("Blocked: " .. itemName)
                            ClearCursor()
                        end
                    end
                elseif button == "RightButton" then
                    local itemID = SuperScanDB[currentServer].blockedItemsGrid[self.slotID]
                    if itemID then
                        SuperScanDB[currentServer].blockedItems[itemID] = nil
                        SuperScanDB[currentServer].blockedItemsGrid[self.slotID] = nil
                        SuperScan:UpdateBlockedItemsGridDisplay()
                        local itemName = GetItemInfo(itemID)
                        print("Unblocked: " .. (itemName or "Unknown Item"))
                    end
                end
            end)
            SuperScan.blockedItemSlots[slotIndex] = slotButton
        end
    end
    settingsFrame:Hide() -- Initially hidden
end

function SuperScan:ShowSettingsFrame()
    if not SuperScan.SettingsFrame then
        SuperScan:CreateSettingsFrame()
    end
    local currentServer = GetRealmName()
    -- Load current settings into edit boxes and sliders
    SuperScan.SettingsFrame.InstantListGoldEditBox:SetText(SuperScanDB[currentServer].settings.instantListGoldThreshold or
    1)

    -- Set slider values
    SuperScan.SettingsFrame.MinPercentageSlider:SetValue(SuperScanDB[currentServer].settings.minListPercentage or 70)

    -- Set checkbox state
    SuperScan.SettingsFrame.DisenchantCheckbox:SetChecked(SuperScanDB[currentServer].settings.showDisenchantValue)

    SuperScan:UpdateBlockedItemsGridDisplay()
    SuperScan.SettingsFrame:Show()

    -- Save state to database
    SuperScanDB[currentServer].settings.settingsFrameVisible = true
end

function SuperScan:HideSettingsFrame()
    if SuperScan.SettingsFrame then
        SuperScan.SettingsFrame:Hide()
    end

    -- Save state to database
    local currentServer = GetRealmName()
    SuperScanDB[currentServer].settings.settingsFrameVisible = false
end

-- Button Functions
function SuperScan:StopScan()
    PlaySound("AuctionWindowClose", "Master")
    getAllButton:Enable()
    sellAllButton:Enable()
    if scanTimer then 
        scanTimer:Cancel()
        scanTimer = nil
    end
    print("Scan stopped at page " .. currentPage)
    if timerText then
        timerText:SetText("")
    end
    scanTimeTracker = {}
    scanStartTime = nil
end

function SuperScan:StartGetAllScan()
    local canQuery, canQueryAll = CanSendAuctionQuery()
    if not canQueryAll then
        print("GetAll not ready yet")
        return
    end
    local frame = CreateFrame("Frame")

    getAllButton:Disable()
    sellAllButton:Disable()
    scanTimeTracker = {}
    scanStartTime = GetTime()

    -- Initialize scan statistics
    self.scanStats = {
        totalItemsInDB = 0,
        itemsScanned = 0,
        newItemsAdded = 0,
        existingItemsUpdated = 0,
        pricesIncreased = 0,
        pricesDecreased = 0,
        skippedItems = 0,
        totalPagesScanned = 0,
    }

    -- Count existing items in database
    if SuperScanDB and SuperScanDB[currentServer] and SuperScanDB[currentServer].prices then
        for _ in pairs(SuperScanDB[currentServer].prices) do
            self.scanStats.totalItemsInDB = self.scanStats.totalItemsInDB + 1
        end
    end

    local function ProcessAuctions()
        local numAuctionsPerPage = GetNumAuctionItems("list")
        for i = 1, numAuctionsPerPage do
            local name, texture, amount, quality, _, _, _, _, buyoutPrice, _, _, owner = GetAuctionItemInfo("list", i)
            local itemLink = GetAuctionItemLink("list", i)
            if name and buyoutPrice > 0 and quality >= 1 and itemLink then
                local itemID = SuperScan:GetItemIDFromLink(itemLink)
                if itemID then
                    local pricePerItem = buyoutPrice / amount
                    if not tempScanData[itemID] or pricePerItem < tempScanData[itemID].price then
                        tempScanData[itemID] = {
                            price = pricePerItem,
                            owner = owner
                        }
                    end
                end
            end
        end
        return numAuctionsPerPage
    end

    local function ScanNextPage()
        if CanSendAuctionQuery() then
            local currentTime = GetTime()
            if #scanTimeTracker > 0 then
                local lastPageStartTime = scanTimeTracker[#scanTimeTracker].startTime
                scanTimeTracker[#scanTimeTracker].duration = currentTime - lastPageStartTime
            end
            local numAuctionsPerPage = ProcessAuctions()
            if numAuctionsPerPage == 0 then
                SuperScan:StopScan()
                SuperScan:ProcessScanData()
            else
                currentPage = currentPage + 1
                self.scanStats.totalPagesScanned = currentPage
                table.insert(scanTimeTracker, {
                    pageNum = currentPage,
                    startTime = currentTime,
                    duration = nil
                })
                SuperScan:UpdateTimerDisplay()
                QueryAuctionItems("", 0, 60, 1000, 1000, 1000, currentPage)
            end
        end
    end

    local function OnInitialAuctionUpdate(frame, event)
        if event == "AUCTION_ITEM_LIST_UPDATE" then
            frame:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
            ProcessAuctions()
            currentPage = math.ceil(select(1, GetNumAuctionItems("list")) / 50)
            print("Trying to scan the following page now:" .. currentPage)
            -- Initialize the timer display if it doesn't exist
            if not timerText then
                timerText = AuctionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                timerText:SetPoint("LEFT", sellAllButton, "RIGHT", 10, 0)
                timerText:SetText("Calculating...")
            else
                timerText:SetText("Calculating...")
            end

            -- Add initial page timing data
            table.insert(scanTimeTracker, {
                pageNum = currentPage,
                startTime = GetTime(),
                duration = nil
            })
            QueryAuctionItems("", 0, 60, 1000, 1000, 1000, currentPage)
            scanTimer = C_Timer.NewTicker(0.1, ScanNextPage)
        end
    end

    frame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
    frame:SetScript("OnEvent", OnInitialAuctionUpdate)

    QueryAuctionItems("", 0, 60, 0, 0, 0, 0, false, nil, true) -- GetAll Query
end

function SuperScan:UpdateTimerDisplay()
    if not timerText then return end
    
    local _, totalAuctions = GetNumAuctionItems("list")
    local totalPages = math.floor(totalAuctions / 50)
    
    -- Ensure we don't divide by zero
    if totalPages == 0 then
        timerText:SetText("00:00 (100%)")
        return
    end
    
    -- Limit current page to total pages
    local displayPage = math.min(currentPage, totalPages)
    local remainingPages = math.max(0, totalPages - displayPage)
    
    -- Calculate progress percentage
    local progress = math.min(99, math.floor((displayPage / totalPages) * 100))
    
    -- If scan is complete or nearly complete
    if remainingPages <= 0 or progress >= 99 then
        timerText:SetText("Almost done.")
        return
    end
    
    -- Get completed pages with duration data
    local completedPages = {}
    for i, pageData in ipairs(scanTimeTracker) do
        if pageData.duration then
            table.insert(completedPages, pageData)
        end
    end
    
    -- Calculate average using a weighted approach to smooth out fluctuations
    local avgTimePerPage = 0
    if #completedPages > 0 then
        -- Use more recent pages with higher weight
        local totalWeight = 0
        local weightedSum = 0
        
        for i = 1, #completedPages do
            local weight = i  -- More recent pages get higher weight
            weightedSum = weightedSum + (completedPages[i].duration * weight)
            totalWeight = totalWeight + weight
        end
        
        avgTimePerPage = weightedSum / totalWeight
        
        -- Apply a smoothing factor to prevent jumpy estimates
        local prevAvg = avgTimePerPage
        if self.prevEstimate then
            avgTimePerPage = (self.prevEstimate * 0.7) + (avgTimePerPage * 0.3)
        end
        self.prevEstimate = avgTimePerPage
    else
        -- Default estimate if no data yet
        avgTimePerPage = 0.8
    end
    
    -- Calculate estimated remaining time (with a minimum of 1 second)
    local remainingSeconds = math.max(1, remainingPages * avgTimePerPage)
    
    -- Apply a ceiling to very large estimates to avoid unrealistic times
    remainingSeconds = math.min(remainingSeconds, 1800)  -- Cap at 30 minutes
    
    -- Format as MM:SS
    local minutes = math.floor(remainingSeconds / 60)
    local seconds = math.floor(remainingSeconds % 60)
    local timeString = string.format("%02d:%02d", minutes, seconds)
    
    -- Update the display
    timerText:SetText(timeString .. " (" .. progress .. "%)")
end

function SuperScan:PrintTopMysticScrolls()
    local scrolls = {}

    -- Check if database exists and has data
    if not SuperScanDB or not SuperScanDB[currentServer] or not SuperScanDB[currentServer].prices then
        print("No scan data available. Please run a GetAll Scan first.")
        return
    end

    for itemID, itemData in pairs(SuperScanDB[currentServer].prices) do
        local itemName = GetItemInfo(itemID)
        if itemName and string.find(itemName, "Mystic Scroll") then
            table.insert(scrolls, {
                name = itemName,
                value = itemData.dbPrice,
            })
        end
    end

    if #scrolls == 0 then
        print("No Mystic Scrolls found in database. Please run a GetAll Scan first.")
        return
    end

    -- Sort by value (highest first)
    table.sort(scrolls, function(a, b) return a.value > b.value end)

    print("\n=== Top 50 Most Valuable Mystic Scrolls ===")
    print("Name                                    Value")
    print("--------------------------------------------------")

    for i = 1, math.min(50, #scrolls) do
        local scroll = scrolls[i]
        local nameStr = scroll.name .. string.rep(" ", 50 - string.len(scroll.name))
        local valueStr = GetCoinTextureString(scroll.value)
        print(string.format("%s%s", nameStr, valueStr))
    end
    print("--------------------------------------------------")
end

function SuperScan:StartSellAll()
    if self.isSellAllActive then
        print("SellAll process is already active.")
        return
    end
    self.isSellAllActive = true
    self.itemQueue = {}
    self.currentIndex = 1
    local cheapItems = {}
    local mysticScrolls = {}
    local currentServer = GetRealmName()

    -- Load settings
    local instantListThresholdCopper = (SuperScanDB[currentServer].settings.instantListGoldThreshold or 5) * 10000
    local minListFactor = (SuperScanDB[currentServer].settings.minListPercentage or 80) / 100

    -- First scan all items in inventory and separate them
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, slot)
            if itemLink then
                local itemID = SuperScan:GetItemIDFromLink(itemLink)
                local itemName, _, quality = GetItemInfo(itemID)
                if itemName and itemID and not SuperScanDB[currentServer].blockedItems[itemID] then
                    -- Check if the item is soulbound or realm bound using the improved method
                    local tooltip = CreateFrame("GameTooltip", "SuperScanSellAllTooltipCheck", nil, "GameTooltipTemplate")
                    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
                    tooltip:SetBagItem(bag, slot)

                    local isSoulbound = false
                    for i = 1, tooltip:NumLines() do
                        local text = _G["SuperScanSellAllTooltipCheckTextLeft" .. i]:GetText() or ""
                        if text:find("Soulbound") or text:find("Realm Bound") or text:find("Binds when picked up") or text:find("Binds to realm") then
                            isSoulbound = true
                            break
                        end
                    end
                    tooltip:Hide()

                    if string.find(itemName, "Portable Call Board") or string.find(itemName, "Mystic Enchanting Altar") then
                        print("Skipping special item: " .. itemName)
                    elseif isSoulbound then
                        print("Skipping soulbound item: " .. itemName)
                    else
                        local _, itemCount = GetContainerItemInfo(bag, slot)
                        local dbPrice = SuperScan:GetDBPrice(itemID)

                        if string.find(itemName, "Mystic Scroll") then
                            table.insert(mysticScrolls, {
                                name = itemName,
                                itemID = itemID,
                                bag = bag,
                                slot = slot,
                                count = itemCount,
                                quality = quality,
                                noDBPrice = (dbPrice == 0)
                            })
                        elseif dbPrice > 0 and dbPrice < instantListThresholdCopper then
                            table.insert(cheapItems, {
                                name = itemName,
                                itemID = itemID,
                                bag = bag,
                                slot = slot,
                                count = itemCount,
                                quality = quality,
                                noDBPrice = (dbPrice == 0)
                            })
                        else
                            table.insert(self.itemQueue, {
                                name = itemName,
                                itemID = itemID,
                                bag = bag,
                                slot = slot,
                                count = itemCount
                            })
                        end
                    end
                else
                    if itemName then -- Only print if itemName is valid
                        print("Skipping blocked item: " .. itemName)
                    end
                end
            end
        end
    end

    -- Phase 0: Post all Mystic Scrolls first, always as individual items at 100% dbValue
    if #mysticScrolls > 0 then
        print("Starting Phase 0: Posting " .. #mysticScrolls .. " Mystic Scrolls as individual items...")

        for _, scroll in ipairs(mysticScrolls) do
            local originalCount = select(2, GetContainerItemInfo(scroll.bag, scroll.slot))
            local price = SuperScan:GetDBPrice(scroll.itemID)

            if price == 0 then
                price = 500000 -- Default 50g for unknown scrolls
            end

            -- Always post scrolls individually
            for i = 1, originalCount do
                ClearCursor()
                PickupContainerItem(scroll.bag, scroll.slot)

                -- If we need to split the stack
                if originalCount > 1 then
                    SplitContainerItem(scroll.bag, scroll.slot, 1)
                end

                ClickAuctionSellItemButton()
                StartAuction(price, price, 3, 1, 1)
                print("Posted " .. scroll.name .. " x1 for " .. GetCoinTextureString(price) .. " each")
            end
        end
    end

    UIErrorsFrame:Clear()

    -- Phase 1: Post all cheap items immediately at 100% dbValue
    for _, item in ipairs(cheapItems) do
        local stackSize = select(2, GetContainerItemInfo(item.bag, item.slot))
        local price
        if (item.quality == 1 or item.quality == 2 or item.quality == 3) and item.noDBPrice then
            price = 90000 -- 9g in copper for unknown
        else
            price = SuperScan:GetDBPrice(item.itemID)
        end

        ClearCursor()
        PickupContainerItem(item.bag, item.slot)
        ClickAuctionSellItemButton()
        StartAuction(price * stackSize, price * stackSize, 3, stackSize, 1)
        print("Posted " .. item.name .. " x" .. stackSize .. " for " .. GetCoinTextureString(price) .. " each")
    end

    UIErrorsFrame:Clear()

    -- Phase 2: Process remaining valuable items (>5g) with market checking
    if #self.itemQueue > 0 then
        print("Starting market check process for " .. #self.itemQueue .. " valuable items.")
        local currentItem = self.itemQueue[self.currentIndex]
        QueryAuctionItems(currentItem.name)

        scanTimer = C_Timer.NewTicker(0.1, function()
            if CanSendAuctionQuery() then
                -- First check if the last posted item was successful
                if self.lastPostedItem then
                    local newCount = select(2, GetContainerItemInfo(self.lastPostedItem.bag, self.lastPostedItem.slot))
                    if newCount and newCount > self.lastPostedItem.expectedCount then
                        print("|cFFFFFF00Warning: Failed to post " ..
                        self.lastPostedItem.name .. " - Item may be soulbound.|r")
                    end
                    self.lastPostedItem = nil
                end
                local numAuctions = GetNumAuctionItems("list")
                local dbPrice = SuperScan:GetDBPrice(currentItem.itemID)
                local shouldPost = true
                local currentMinPrice = nil

                -- First determine the minimum price
                local name, count, buyoutPrice, owner
                if numAuctions > 0 then
                    for i = 1, numAuctions do
                        name, _, count, _, _, _, _, _, buyoutPrice, _, _, owner = GetAuctionItemInfo("list", i)
                        local itemPrice = buyoutPrice / count
                        if name == currentItem.name and buyoutPrice > 0 then
                            if not currentMinPrice or itemPrice < currentMinPrice then
                                currentMinPrice = itemPrice
                            end
                        end
                    end
                    for i = 1, numAuctions do -- Now check if I am the owner of the auction with the lowest price for items over 10g
                        name, _, count, _, _, _, _, _, buyoutPrice, _, _, owner = GetAuctionItemInfo("list", i)
                        local itemPrice = buyoutPrice / count
                        if owner == currentCharacter and itemPrice == currentMinPrice and dbPrice > 50000 then
                            print("Skipped " .. currentItem.name .. " because the cheapest on AH is already yours.")
                            shouldPost = false
                            break
                        end
                    end
                    if currentMinPrice and dbPrice > 0 and currentMinPrice <= dbPrice * minListFactor and dbPrice >= instantListThresholdCopper then
                        print("Skipped " ..
                        currentItem.name ..
                        " due to low market price (below " ..
                        (minListFactor * 100) ..
                        "% of DB value " ..
                        GetCoinTextureString(dbPrice) .. ", current: " .. GetCoinTextureString(currentMinPrice) .. ").")
                        shouldPost = false
                    end
                else -- No other auctions present
                    print("No exact match found for " .. currentItem.name .. ". Using DB price.")
                end

                if shouldPost then
                    local function postAuction(itemCount)
                        ClearCursor()
                        PickupContainerItem(currentItem.bag, currentItem.slot)
                        local stackSize = select(2, GetContainerItemInfo(currentItem.bag, currentItem.slot))
                        if itemCount < stackSize then
                            SplitContainerItem(currentItem.bag, currentItem.slot, itemCount)
                        end
                        ClickAuctionSellItemButton()
                        local insertPrice = dbPrice or 0
                        local link = GetContainerItemLink(currentItem.bag, currentItem.slot)
                        local itemID = SuperScan:GetItemIDFromLink(link)
                        local _, _, quality = GetItemInfo(itemID)

                        -- Check if we have no DB price and no market price
                        if (not dbPrice or dbPrice == 0) and not currentMinPrice then
                            -- Only post green items with default price, skip blue+ items
                            if quality == 2 then
                                insertPrice = 50000 -- 5g for green items
                                print("Posted " ..
                                currentItem.name ..
                                " x" ..
                                itemCount ..
                                " for " ..
                                GetCoinTextureString(insertPrice) .. " each (default green price - no DB value)")
                            else
                                print("Skipped " ..
                                currentItem.name .. " - No database value and no auctions found on AH")
                                ClearCursor()
                                return
                            end
                        elseif not dbPrice or dbPrice == 0 then
                            -- We have market price but no DB price
                            if quality == 2 then
                                insertPrice = 50000 -- Default 5g for green items
                                print("Posted " ..
                                currentItem.name ..
                                " x" ..
                                itemCount ..
                                " for " ..
                                GetCoinTextureString(insertPrice) .. " each (default green price - no DB value)")
                            else
                                -- Use market price for blue+ items when no DB price
                                insertPrice = currentMinPrice * 0.99
                                print("Posted " ..
                                currentItem.name ..
                                " x" ..
                                itemCount ..
                                " for " .. GetCoinTextureString(insertPrice) .. " each (market price - no DB value)")
                            end
                        else
                            -- We have DB price - use original pricing logic
                            if currentMinPrice and dbPrice < 50000 then
                                insertPrice = math.max(currentMinPrice - 1, dbPrice * 0.90)
                            elseif currentMinPrice then
                                insertPrice = currentMinPrice * 0.99
                            else
                                insertPrice = dbPrice
                            end
                            print("Posted " ..
                            currentItem.name ..
                            " x" ..
                            itemCount ..
                            " for " ..
                            GetCoinTextureString(insertPrice) ..
                            " each (" .. math.floor((insertPrice / dbPrice) * 100) .. "%)")
                        end

                        StartAuction(insertPrice * itemCount, insertPrice * itemCount, 3, itemCount, 1)

                        self.lastPostedItem = {
                            bag = currentItem.bag,
                            slot = currentItem.slot,
                            count = itemCount,
                            name = currentItem.name,
                            expectedCount = select(2, GetContainerItemInfo(currentItem.bag, currentItem.slot)) -
                                itemCount
                        }
                    end

                    -- Modified posting decision
                    if currentItem.count > 3 and dbPrice < 5000 then
                        postAuction(currentItem.count)
                    else
                        for i = 1, currentItem.count do
                            postAuction(1)
                        end
                    end
                end

                if self.currentIndex < #self.itemQueue then
                    self.currentIndex = self.currentIndex + 1
                    currentItem = self.itemQueue[self.currentIndex]
                    QueryAuctionItems(currentItem.name)
                else
                    print("SellAll process completed.")
                    self.isSellAllActive = false
                    scanTimer:Cancel()
                    return
                end
            end
        end)
    end
end

-- Background Functions
function SuperScan:GetItemIDFromLink(itemLink)
    if not itemLink then return nil end
    local itemID = tonumber(itemLink:match("item:(%d+)"))
    return itemID
end

function SuperScan:InitializeDatabase()
    SuperScanDB = SuperScanDB or {}
    -- Server initialization
    local currentServer = GetRealmName()
    SuperScanDB[currentServer] = SuperScanDB[currentServer] or {
        prices = {},
        blockedItems = {},
    }
    if SuperScanDB[currentServer].blockedItems == nil then
        SuperScanDB[currentServer].blockedItems = {}
    end

    -- Initialize settings if they don't exist
    SuperScanDB[currentServer].settings = SuperScanDB[currentServer].settings or {
        instantListGoldThreshold = 5, -- Default: 5 gold
        minListPercentage = 80,       -- Default: 80%
        showDisenchantValue = false,  -- Default: disabled
        settingsFrameVisible = false, -- Default: hidden
    }
    -- Ensure default values if keys are missing
    if SuperScanDB[currentServer].settings.instantListGoldThreshold == nil then
        SuperScanDB[currentServer].settings.instantListGoldThreshold = 5
    end
    if SuperScanDB[currentServer].settings.minListPercentage == nil then
        SuperScanDB[currentServer].settings.minListPercentage = 80
    end
    if SuperScanDB[currentServer].settings.showDisenchantValue == nil then
        SuperScanDB[currentServer].settings.showDisenchantValue = false
    end
    if SuperScanDB[currentServer].settings.settingsFrameVisible == nil then
        SuperScanDB[currentServer].settings.settingsFrameVisible = false
    end

    -- Initialize blocked items grid (32 slots: 4 rows, 8 columns)
    SuperScanDB[currentServer].blockedItemsGrid = SuperScanDB[currentServer].blockedItemsGrid or {}
    for i = 1, 32 do
        SuperScanDB[currentServer].blockedItemsGrid[i] = SuperScanDB[currentServer].blockedItemsGrid[i] or nil
    end
end

function SuperScan:GetTodayDate()
    return date("%Y-%m-%d")
end

function SuperScan:ProcessScanData()
    local today = SuperScan:GetTodayDate()
    local startTime = GetTime()

    -- Reset counters for this processing session
    self.scanStats.itemsScanned = 0
    self.scanStats.newItemsAdded = 0
    self.scanStats.existingItemsUpdated = 0
    self.scanStats.pricesIncreased = 0
    self.scanStats.pricesDecreased = 0
    self.scanStats.skippedItems = 0

    for itemID, itemData in pairs(tempScanData) do
        self.scanStats.itemsScanned = self.scanStats.itemsScanned + 1

        -- Check if item doesn't exist in database
        if not SuperScanDB[currentServer].prices[itemID] then
            SuperScanDB[currentServer].prices[itemID] = {
                dbPrice = itemData.price,
                lastScanDate = today
            }
            self.scanStats.newItemsAdded = self.scanStats.newItemsAdded + 1
        else
            local dbItemData = SuperScanDB[currentServer].prices[itemID]
            local currentdbPrice = dbItemData.dbPrice

            -- Only process if last scan was not today
            if dbItemData.lastScanDate ~= today then
                self.scanStats.existingItemsUpdated = self.scanStats.existingItemsUpdated + 1
                local oldPrice = currentdbPrice

                -- Check if lowest price is from player's auction
                local isMyAuction = itemData.owner == currentCharacter

                if itemData.price <= currentdbPrice then
                    -- Price lower than DB value
                    if currentdbPrice <= 500000 then               -- 50g or less
                        dbItemData.dbPrice = currentdbPrice * 0.95 -- Decrease by 5%
                    else
                        dbItemData.dbPrice = currentdbPrice * 0.97 -- Decrease by 3%
                    end
                else
                    -- Price higher than DB value
                    if not isMyAuction then
                        dbItemData.dbPrice = currentdbPrice * 1.02 -- Increase by 2%
                    end
                end

                -- Track price changes AFTER the price adjustments
                if dbItemData.dbPrice > oldPrice then
                    self.scanStats.pricesIncreased = self.scanStats.pricesIncreased + 1
                elseif dbItemData.dbPrice < oldPrice then
                    self.scanStats.pricesDecreased = self.scanStats.pricesDecreased + 1
                end

                dbItemData.lastScanDate = today -- Update last scan date
            else
                self.scanStats.skippedItems = self.scanStats.skippedItems + 1
            end
        end
    end

    -- Calculate final statistics
    local newTotalItems = 0
    if SuperScanDB and SuperScanDB[currentServer] and SuperScanDB[currentServer].prices then
        for _ in pairs(SuperScanDB[currentServer].prices) do
            newTotalItems = newTotalItems + 1
        end
    end
    self.scanStats.totalItemsInDB = newTotalItems

    -- Print comprehensive statistics
    print("\n|cFF00FF00=== SuperScan Statistics ===|r")
    print(string.format("|cFFFFFFFFTotal items in database:|r |cFF00FFFF%d|r", self.scanStats.totalItemsInDB))
    print(string.format("|cFFFFFFFFItems scanned this session:|r |cFF00FFFF%d|r", self.scanStats.itemsScanned))
    print(string.format("|cFFFFFFFFNew items added:|r |cFF00FF00%d|r", self.scanStats.newItemsAdded))
    print(string.format("|cFFFFFFFFExisting items updated:|r |cFFFFFF00%d|r", self.scanStats.existingItemsUpdated))
    print(string.format("|cFFFFFFFFPrices increased:|r |cFFFF8000%d|r", self.scanStats.pricesIncreased))
    print(string.format("|cFFFFFFFFPrices decreased:|r |cFFFF0000%d|r", self.scanStats.pricesDecreased))
    print(string.format("|cFFFFFFFFItems skipped (already scanned today):|r |cFF808080%d|r", self.scanStats.skippedItems))
    print(string.format("|cFFFFFFFFTotal pages scanned:|r |cFFFFFFFF%d|r", self.scanStats.totalPagesScanned))
    print("|cFF00FF00========================|r")

    print("Scan data processed. Database updated.")
end

function SuperScan:GetDBPrice(itemID)
    return SuperScanDB and SuperScanDB[currentServer] and SuperScanDB[currentServer].prices and
    SuperScanDB[currentServer].prices[itemID] and SuperScanDB[currentServer].prices[itemID].dbPrice or 0
end

function SuperScan:AddOrUpdateItemInDB(itemID, priceGold)
    if not SuperScanDB[currentServer] then SuperScanDB[currentServer] = { prices = {} } end
    if not SuperScanDB[currentServer].prices then SuperScanDB[currentServer].prices = {} end

    local priceCopper = priceGold * 10000 -- Convert gold to copper
    SuperScanDB[currentServer].prices[itemID] = {
        dbPrice = priceCopper,
        lastScanDate = date("%Y-%m-%d"),
    }
    local itemName = GetItemInfo(itemID)
    print(string.format("Item '%s' was added or updated with a value of %d gold.",
    itemName or "Unknown Item", priceGold))
end

function SuperScan:PrintHelp()
    print("\n|cFF00FFFF=== SuperScan Help ===|r")

    -- Slash commands section
    print("|cFFFFFF00Slash Commands:|r")
    print("/ss add <ItemLink> <GoldPrice> - Add or update an item's price in the database")
    print("/ss remove <ItemLink> - Remove an item from the price database")
    print("/ss block <ItemLink> - Add an item to the blocked list (skipped by SellAll)")
    print("/ss block - Display all currently blocked items")
    print("/ss unblock <ItemLink> - Remove an item from the blocked list")
    print("/ss money - Calculate and display your current inventory value")

    -- Buttons explanation section
    print("\n|cFFFFFF00Buttons:|r")
    print("|cFF00FF00Help|r - Shows this help message")
    print("|cFF00FF00Top Scrolls|r - Displays the top 50 most valuable Mystic Scrolls in your database")
    print("|cFF00FF00GetAll Scan|r - Performs a complete auction house scan to update your price database")
    print("|cFF00FF00SellAll|r - Automatically posts all items in your bags with smart pricing rules:")
    print("  • Items worth less than configurable threshold are posted immediately at full price")
    print("  • Items worth more than threshold are checked against current market prices")
    print("  • Items on your blocked list are skipped entirely")
    print("  • Mystic Scrolls are always posted individually at DB price")

    -- Settings and configuration
    print("\n|cFFFFFF00Settings Panel:|r")
    print("• |cFF00FF00Instant List Threshold|r - Items below this gold value are posted immediately")
    print("• |cFF00FF00Minimum List Percentage|r - Won't post if market price is below this % of DB value")
    print("• |cFF00FF00Blocked Items Grid|r - Visual grid to manage blocked items via drag & drop")
    print("  - Drag items from bags to block them")
    print("  - Right-click grid slots to unblock items")
    print("  - Soulbound and realmbound items cannot be blocked")

    -- Stack size information
    print("\n|cFFFFFF00Stack Size Logic:|r")
    print("• Items with value less than 1g and stack size > 3 are posted as full stacks")
    print("• Higher value items are posted as individual items to maximize profits")
    print("• Mystic Scrolls are always posted individually regardless of stack size")
    print("• Items without a DB price use default pricing based on quality")

    -- Database info section
    print("\n|cFFFFFF00Database:|r")
    print("• Item prices are tracked per server and updated daily")
    print("• Prices adjust automatically based on market trends")
    print("• Hover over items to see their stored value in tooltips")
    print("• Settings are saved per server")

    print("\n|cFF00FFFF=== End of Help ===|r")
end

function SuperScan:CanDisenchant(itemLink)
    if not itemLink then return false end
    local itemID = SuperScan:GetItemIDFromLink(itemLink)
    local _, _, quality, itemLevel, _, _, _, _, equipSlot = GetItemInfo(itemID)

    -- Add nil checks for the values we need
    if not quality or not itemLevel or not equipSlot then 
        return false 
    end

    -- Only green, blue, purple items can be disenchanted
    if quality < 2 or quality > 4 then return false end

    -- Only equipment can be disenchanted (not consumables, trade goods, etc.)
    local validSlots = {
        "INVTYPE_HEAD", "INVTYPE_NECK", "INVTYPE_SHOULDER", "INVTYPE_BODY", "INVTYPE_CHEST",
        "INVTYPE_WAIST", "INVTYPE_LEGS", "INVTYPE_FEET", "INVTYPE_WRIST", "INVTYPE_HAND",
        "INVTYPE_FINGER", "INVTYPE_TRINKET", "INVTYPE_WEAPON", "INVTYPE_SHIELD",
        "INVTYPE_RANGED", "INVTYPE_CLOAK", "INVTYPE_2HWEAPON", "INVTYPE_WEAPONMAINHAND",
        "INVTYPE_WEAPONOFFHAND", "INVTYPE_HOLDABLE", "INVTYPE_THROWN", "INVTYPE_RANGEDRIGHT",
        "INVTYPE_RELIC"
    }

    for _, slot in ipairs(validSlots) do
        if equipSlot == slot then return true end
    end

    return false
end

function SuperScan:IsWeapon(equipSlot)
    local weaponSlots = {
        "INVTYPE_WEAPON", "INVTYPE_2HWEAPON", "INVTYPE_WEAPONMAINHAND",
        "INVTYPE_WEAPONOFFHAND", "INVTYPE_RANGED", "INVTYPE_RANGEDRIGHT",
        "INVTYPE_THROWN", "INVTYPE_RELIC"
    }

    for _, slot in ipairs(weaponSlots) do
        if equipSlot == slot then return true end
    end
    return false
end

function SuperScan:GetDisenchantValue(itemLink)
    if not self:CanDisenchant(itemLink) then return 0 end

    local itemID = SuperScan:GetItemIDFromLink(itemLink)
    local _, _, quality, itemLevel, _, _, _, _, equipSlot = GetItemInfo(itemID)
    local totalValue = 0
    local disenchantResults = {}

    -- Determine what this item disenchants into based on quality, level, and item type
    if quality == 2 then -- Green items
        local isWeapon = self:IsWeapon(equipSlot)
        local sourceTable = isWeapon and DISENCHANT_GREEN_WEAPONS or DISENCHANT_GREEN_ARMOR

        local resultTable
        if itemLevel <= 15 then
            resultTable = sourceTable.green_1_15
        elseif itemLevel <= 20 then
            resultTable = sourceTable.green_16_20
        elseif itemLevel <= 25 then
            resultTable = sourceTable.green_21_25
        elseif itemLevel <= 30 then
            resultTable = sourceTable.green_26_30
        elseif itemLevel <= 35 then
            resultTable = sourceTable.green_31_35
        elseif itemLevel <= 40 then
            resultTable = sourceTable.green_36_40
        elseif itemLevel <= 45 then
            resultTable = sourceTable.green_41_45
        elseif itemLevel <= 50 then
            resultTable = sourceTable.green_46_50
        elseif itemLevel <= 55 then
            resultTable = sourceTable.green_51_55
        elseif itemLevel <= 60 then
            resultTable = sourceTable.green_56_60
        elseif itemLevel <= 70 then
            resultTable = sourceTable.green_61_70
        elseif itemLevel <= 100 then
            resultTable = sourceTable.green_71_100
        elseif itemLevel <= 120 then
            resultTable = sourceTable.green_101_120
        end

        if resultTable then
            for _, result in ipairs(resultTable) do
                table.insert(disenchantResults, result)
            end
        end
    elseif quality == 3 then -- Blue items
        local resultTable
        if itemLevel <= 25 then
            resultTable = DISENCHANT_BLUE_ITEMS.blue_1_25
        elseif itemLevel <= 30 then
            resultTable = DISENCHANT_BLUE_ITEMS.blue_26_30
        elseif itemLevel <= 35 then
            resultTable = DISENCHANT_BLUE_ITEMS.blue_31_35
        elseif itemLevel <= 40 then
            resultTable = DISENCHANT_BLUE_ITEMS.blue_36_40
        elseif itemLevel <= 45 then
            resultTable = DISENCHANT_BLUE_ITEMS.blue_41_45
        elseif itemLevel <= 50 then
            resultTable = DISENCHANT_BLUE_ITEMS.blue_46_50
        elseif itemLevel <= 55 then
            resultTable = DISENCHANT_BLUE_ITEMS.blue_51_55
        elseif itemLevel <= 60 then
            resultTable = DISENCHANT_BLUE_ITEMS.blue_56_60
        elseif itemLevel <= 100 then
            resultTable = DISENCHANT_BLUE_ITEMS.blue_61_100
        elseif itemLevel <= 120 then
            resultTable = DISENCHANT_BLUE_ITEMS.blue_101_120
        end

        if resultTable then
            for _, result in ipairs(resultTable) do
                table.insert(disenchantResults, result)
            end
        end
    elseif quality == 4 then -- Epic items
        local resultTable
        if itemLevel <= 50 then
            resultTable = DISENCHANT_EPIC_ITEMS.epic_01_50
        elseif itemLevel <= 55 then
            resultTable = DISENCHANT_EPIC_ITEMS.epic_51_55
        elseif itemLevel <= 100 then
            resultTable = DISENCHANT_EPIC_ITEMS.epic_56_100
        elseif itemLevel <= 199 then
            resultTable = DISENCHANT_EPIC_ITEMS.epic_101_199
        end

        if resultTable then
            for _, result in ipairs(resultTable) do
                table.insert(disenchantResults, result)
            end
        end
    end

    -- Calculate expected value
    for _, result in ipairs(disenchantResults) do
        local itemID, minAmount, maxAmount, probability = unpack(result)
        local avgAmount = (minAmount + maxAmount) / 2
        local materialPrice = SuperScan:GetDBPrice(itemID)

        if materialPrice > 0 then
            totalValue = totalValue + (materialPrice * avgAmount * probability)
        end
    end

    return totalValue
end

-- Tooltip
GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
    local name, itemLink = tooltip:GetItem()
    if name and itemLink then
        local itemID = SuperScan:GetItemIDFromLink(itemLink)
        local currentServer = GetRealmName()

        -- Show regular DB price if available
        if itemID and SuperScanDB and SuperScanDB[currentServer] and SuperScanDB[currentServer].prices and SuperScanDB[currentServer].prices[itemID] then
            tooltip:AddLine("Auctioning: " .. GetCoinTextureString(SuperScan:GetDBPrice(itemID)))
        end

        -- Show disenchant value if enabled and item can be disenchanted
        if SuperScanDB and SuperScanDB[currentServer] and SuperScanDB[currentServer].settings.showDisenchantValue then
            local disenchantValue = SuperScan:GetDisenchantValue(itemLink)
            if disenchantValue > 0 then
                tooltip:AddLine("Disenchant: " .. GetCoinTextureString(disenchantValue), 0.5, 1, 0.5)
            end
        end
    end
end)

-- Slash commands
SLASH_SUPERSCAN1 = "/ss"
SlashCmdList["SUPERSCAN"] = function(msg)
    local args = {}
    for arg in msg:gmatch("%S+") do
        table.insert(args, arg)
    end

    if args[1] == "add" then
        local itemLink, priceGold

        -- Check if we have an item link (starting with |c)
        if args[2] and args[2]:match("^|c") then
            -- Find the end of the item link by looking for |r
            local linkEnd = 2
            for i = 2, #args do
                if args[i]:match("|r$") then
                    linkEnd = i
                    break
                end
            end

            -- Combine the item link parts
            itemLink = table.concat(args, " ", 2, linkEnd)
            priceGold = tonumber(args[linkEnd + 1])
        end

        if itemLink and priceGold then
            local itemID = SuperScan:GetItemIDFromLink(itemLink)
            if itemID then
                -- Add to regular price database
                SuperScan:AddOrUpdateItemInDB(itemID, priceGold)
            else
                print("Invalid item. Please use an item link or correct item name.")
            end
        else
            print("Usage:")
            print("/ss add <ItemLink> <GoldPrice>")
            print("Example: /ss add [Copper Ore] 50")
        end
    elseif args[1] == "remove" then
        -- Check if we have an item argument
        if not args[2] then
            print("Usage: /ss remove <ItemLink>")
            return
        end

        local itemLink = table.concat(args, " ", 2)        -- Combine all arguments after "remove"
        local itemID = SuperScan:GetItemIDFromLink(itemLink)
        local itemName = GetItemInfo(itemID)  -- Get item name from link

        -- Check regular price database
        if itemID and SuperScanDB[currentServer].prices[itemID] then
            SuperScanDB[currentServer].prices[itemID] = nil
            print(string.format("Removed '%s' from price database.", itemName))
        end

        -- If item wasn't found in database
        if not itemID or not SuperScanDB[currentServer].prices[itemID] then
            print(string.format("Item '%s' not found in database.", itemName))
        end
    elseif args[1] == "block" then
        local currentServer = GetRealmName()

        -- If no item specified, display the blocked items list
        if not args[2] then
            print("=== Blocked Items List ===")
            local hasItems = false
            for itemID, _ in pairs(SuperScanDB[currentServer].blockedItems) do
                local itemName = GetItemInfo(itemID)
                print("- " .. (itemName or "Unknown Item (ID: " .. itemID .. ")"))
                hasItems = true
            end
            if not hasItems then
                print("No items are currently blocked.")
            end
            return
        end

        -- Process item link
        local itemLink = table.concat(args, " ", 2) -- Combine all arguments after "block"
        local itemID = SuperScan:GetItemIDFromLink(itemLink)
        local itemName = GetItemInfo(itemID)

        if not itemID then
            print("Invalid item. Please use an item link.")
            return
        end

        SuperScanDB[currentServer].blockedItems[itemID] = true
        print("Added " .. (itemName or "Unknown Item") .. " to blocked items list. This item will be ignored by SellAll.")
    elseif args[1] == "unblock" then
        local currentServer = GetRealmName()

        if not args[2] then
            print("Usage: /ss unblock <ItemLink>")
            return
        end

        local itemLink = table.concat(args, " ", 2) -- Combine all arguments after "unblock"
        local itemID = SuperScan:GetItemIDFromLink(itemLink)
        local itemName = GetItemInfo(itemID)

        if not itemID then
            print("Invalid item. Please use an item link.")
            return
        end

        if SuperScanDB[currentServer].blockedItems[itemID] then
            SuperScanDB[currentServer].blockedItems[itemID] = nil
            print("Removed " .. (itemName or "Unknown Item") .. " from blocked items list.")
        else
            print((itemName or "Unknown Item") .. " was not in the blocked items list.")
        end
    elseif args[1] == "money" then
        -- Calculate and display inventory value
        local totalValue = 0
        local valuableItems = {}

        -- Scan all bags
        for bag = 0, 4 do
            for slot = 1, GetContainerNumSlots(bag) do
                local itemLink = GetContainerItemLink(bag, slot)
                if itemLink then
                    local itemID = SuperScan:GetItemIDFromLink(itemLink)
                    local itemName = GetItemInfo(itemID)
                    if itemName and itemID then
                        local _, itemCount = GetContainerItemInfo(bag, slot)
                        local dbPrice = SuperScan:GetDBPrice(itemID)
                        if dbPrice and dbPrice > 0 then
                            local itemValue = dbPrice * (itemCount or 1)
                            totalValue = totalValue + itemValue

                            -- Keep track of the most valuable items
                            table.insert(valuableItems, {
                                name = itemName,
                                count = itemCount or 1,
                                totalValue = itemValue,
                                unitValue = dbPrice
                            })
                        end
                    end
                end
            end
        end

        -- Sort by total value (highest first)
        table.sort(valuableItems, function(a, b) return a.totalValue > b.totalValue end)

        -- Display results
        print("|cFF00FFFF=== Inventory Value Summary ===|r")
        print("Total inventory value: " .. GetCoinTextureString(totalValue))

        if #valuableItems > 0 then
            print("\n|cFFFFFF00Top 10 Most Valuable Items:|r")
            for i = 1, math.min(10, #valuableItems) do
                local item = valuableItems[i]
                print(string.format("%s x%d = %s (%s each)",
                    item.name,
                    item.count,
                    GetCoinTextureString(item.totalValue),
                    GetCoinTextureString(item.unitValue)))
            end
        end
    else
        -- Display help
        print("=== SuperScan Slash Commands ===")
        print("/ss add <ItemLink> <GoldPrice> - Add or update an item's price in the database")
        print("/ss remove <ItemLink> - Remove an item from the price database")
        print("/ss block <ItemLink> - Add an item to the blocked list (skipped by SellAll)")
        print("/ss block - Display all currently blocked items")
        print("/ss unblock <ItemLink> - Remove an item from the blocked list")
        print("/ss money - Calculate and display your current inventory value")
    end
end


SuperScan:RegisterEvent("AUCTION_HOUSE_SHOW")
SuperScan:RegisterEvent("AUCTION_HOUSE_CLOSED")
SuperScan:RegisterEvent("ADDON_LOADED")
SuperScan:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "AAC_SuperScan" then
        SuperScan:InitializeDatabase()
        print("SuperScan loaded.")
    elseif event == "AUCTION_HOUSE_SHOW" then
        dealsList = {}
        currentPage = 0

        -- Create settings frame but don't show it initially
        if not SuperScan.SettingsFrame then
            SuperScan:CreateSettingsFrame()
        end

        local currentServer = GetRealmName()

        -- Restore settings frame visibility based on saved state
        if SuperScanDB[currentServer].settings.settingsFrameVisible then
            SuperScan:ShowSettingsFrame()
        else
            SuperScan:HideSettingsFrame()
        end

        -- Add Help button first (new)
        helpButton = CreateFrame("Button", "SuperScanHelpButton", AuctionFrame, "UIPanelButtonTemplate")
        helpButton:SetSize(50, 22)
        helpButton:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 90, -13)
        helpButton:SetText("Help")
        helpButton:SetScript("OnClick", function() SuperScan:PrintHelp() end)

        -- Top Scrolls button (adjusted position to be after Help)
        topScrollsButton = CreateFrame("Button", "SuperScanTopScrollsButton", AuctionFrame, "UIPanelButtonTemplate")
        topScrollsButton:SetSize(100, 22)
        topScrollsButton:SetPoint("LEFT", helpButton, "RIGHT", 10, 0)
        topScrollsButton:SetText("Top Scrolls")
        topScrollsButton:SetScript("OnClick", function() SuperScan:PrintTopMysticScrolls() end)

        -- Settings Toggle button (new)
        if not SuperScan.SettingsToggleButton then
            SuperScan.SettingsToggleButton = CreateFrame("Button", "SuperScanSettingsToggleButton", AuctionFrame,
                "UIPanelButtonTemplate")
            SuperScan.SettingsToggleButton:SetSize(100, 22)
            SuperScan.SettingsToggleButton:SetPoint("LEFT", topScrollsButton, "RIGHT", 10, 0)
            SuperScan.SettingsToggleButton:SetScript("OnClick", function()
                if SuperScan.SettingsFrame:IsShown() then
                    SuperScan:HideSettingsFrame()
                    SuperScan.SettingsToggleButton:SetText("Show Settings")
                else
                    SuperScan:ShowSettingsFrame()
                    SuperScan.SettingsToggleButton:SetText("Hide Settings")
                end
            end)
        end

        -- Update button text based on current state
        if SuperScan.SettingsFrame:IsShown() then
            SuperScan.SettingsToggleButton:SetText("Hide Settings")
        else
            SuperScan.SettingsToggleButton:SetText("Show Settings")
        end

        -- GetAll button (adjusted position)
        getAllButton = CreateFrame("Button", "SuperScanGetAllButton", AuctionFrame, "UIPanelButtonTemplate")
        getAllButton:SetSize(100, 22)
        getAllButton:SetPoint("LEFT", SuperScan.SettingsToggleButton, "RIGHT", 10, 0)
        getAllButton:SetText("GetAll Scan")
        getAllButton:SetScript("OnClick", function() SuperScan:StartGetAllScan() end)

        -- SellAll button (keeping same relative position)
        sellAllButton = CreateFrame("Button", "SuperScanSellAllButton", AuctionFrame, "UIPanelButtonTemplate")
        sellAllButton:SetSize(100, 22)
        sellAllButton:SetPoint("LEFT", getAllButton, "RIGHT", 10, 0)
        sellAllButton:SetText("SellAll")
        sellAllButton:SetScript("OnClick", function() SuperScan:StartSellAll() end)
    elseif event == "AUCTION_HOUSE_CLOSED" then
        SuperScan:HideSettingsFrame()
        if scanTimer then
            scanTimer:Cancel()
        end
        self.isSellAllActive = false
    end
end)
