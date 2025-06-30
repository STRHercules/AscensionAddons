TransmogScanner = CreateFrame("Frame")
TransmogScanner.transmogList = {}
TransmogScanner.scanTimer = nil
TransmogScanner.ITEMS_PER_PAGE = 27
TransmogScanner.currentTransmogPage = 1
TransmogScanner.oldSearch = nil
TransmogScanner.rightClickBuys = true

-- Scan phases: 1 for Weapons, 2 for Armor using AH category filters
TransmogScanner.scanPhases = {
    -- Weapon categories
    { name = "1H Axes", invType = 1, subClass = 1, enabled = false, category = "Weapons" },
    { name = "2H Axes", invType = 1, subClass = 2, enabled = false, category = "Weapons" },
    { name = "Bows", invType = 1, subClass = 3, enabled = false, category = "Weapons" },
    { name = "Guns", invType = 1, subClass = 4, enabled = false, category = "Weapons" },
    { name = "1H Maces", invType = 1, subClass = 5, enabled = false, category = "Weapons" },
    { name = "2H Maces", invType = 1, subClass = 6, enabled = false, category = "Weapons" },
    { name = "Polearms", invType = 1, subClass = 7, enabled = false, category = "Weapons" },
    { name = "1H Swords", invType = 1, subClass = 8, enabled = false, category = "Weapons" },
    { name = "2H Swords", invType = 1, subClass = 9, enabled = false, category = "Weapons" },
    { name = "Staves", invType = 1, subClass = 10, enabled = false, category = "Weapons" },
    { name = "Fist Weapons", invType = 1, subClass = 11, enabled = false, category = "Weapons" },
    { name = "Daggers", invType = 1, subClass = 13, enabled = false, category = "Weapons" },
    { name = "Thrown", invType = 1, subClass = 14, enabled = false, category = "Weapons" },
    { name = "Crossbows", invType = 1, subClass = 15, enabled = false, category = "Weapons" },
    { name = "Wands", invType = 1, subClass = 16, enabled = false, category = "Weapons" },
    { name = "Fishing Rods", invType = 1, subClass = 17, enabled = false, category = "Weapons" },
    
    -- Armor categories
    { name = "Head", invType = 2, subClass = 1, enabled = false, category = "Armor" },
    { name = "Shoulders", invType = 2, subClass = 3, enabled = false, category = "Armor" },
    { name = "Shirt", invType = 2, subClass = 4, enabled = false, category = "Armor" },
    { name = "Chest", invType = 2, subClass = 5, enabled = false, category = "Armor" },
    { name = "Waist", invType = 2, subClass = 6, enabled = false, category = "Armor" },
    { name = "Legs", invType = 2, subClass = 7, enabled = false, category = "Armor" },
    { name = "Feet", invType = 2, subClass = 8, enabled = false, category = "Armor" },
    { name = "Wrists", invType = 2, subClass = 9, enabled = false, category = "Armor" },
    { name = "Hands", invType = 2, subClass = 10, enabled = false, category = "Armor" },
    { name = "Cloak", invType = 2, subClass = 13, enabled = false, category = "Armor" },
    { name = "Off-hand", invType = 2, subClass = 14, enabled = false, category = "Armor" },

    
    -- Special category
    { name = "Armor Caches", invType = 11, subType = 0, enabled = false, category = "Special" }
}
TransmogScanner.currentScanPhaseIndex = 0
TransmogScanner.currentPageInPhase = 0

print("AAC_TransmogScanner loaded.")

-- Tooltip usage helper
local function GetTooltipData(listType, auctionIndex)
    GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    GameTooltip:SetAuctionItem(listType, auctionIndex)

    local hasCtrlHint = false
    local isBindable = false
    local hasCosmeticSet = false
    local ownsVanityItem = false

    for i = 1, GameTooltip:NumLines() do
        local lineText = _G["GameTooltipTextLeft" .. i]:GetText() or ""
        if string.find(lineText, "You haven't collected") then -- Indicates appearance can be learned
            hasCtrlHint = true
        end
        if string.find(lineText, "Binds when equipped") then
            isBindable = true
        end
        if string.find(lineText, "A Cosmetic set") then
            hasCosmeticSet = true
        end
        if string.find(lineText, "You own this vanity item") then
            ownsVanityItem = true
        end
    end
    GameTooltip:Hide()
    return isBindable, hasCtrlHint, hasCosmeticSet, ownsVanityItem
end

local function GetFormattedItemType(invType, itemLink)
    -- Get item class and subclass info
    local _, _, _, _, _, itemClass, itemSubClass = GetItemInfo(itemLink)
    
    -- If we have item class info, use it for weapons and armor
    if itemClass and itemSubClass then
        -- For weapons (class 2), show specific weapon types
        if itemClass == "Weapon" then
            return itemSubClass -- This will show "One-Handed Swords", "Two-Handed Maces", etc.
        end
    end
    
    -- Fallback to invType mapping for other items
    local types = {
        INVTYPE_HEAD = "Head",
        INVTYPE_NECK = "Neck",
        INVTYPE_SHOULDER = "Shoulders",
        INVTYPE_CHEST = "Chest",
        INVTYPE_WAIST = "Waist",
        INVTYPE_LEGS = "Legs",
        INVTYPE_FEET = "Feet",
        INVTYPE_WRIST = "Wrist",
        INVTYPE_HAND = "Hands",
        INVTYPE_FINGER = "Finger",
        INVTYPE_TRINKET = "Trinket",
        INVTYPE_WEAPON = "1H Weapon",
        INVTYPE_2HWEAPON = "2H Weapon",
        INVTYPE_WEAPONMAINHAND = "1H Weapon",
        INVTYPE_WEAPONOFFHAND = "1H Weapon",
        INVTYPE_HOLDABLE = "Off-hand",
        INVTYPE_RANGED = "Bow",
        INVTYPE_RANGEDRIGHT = "Gun",
        INVTYPE_SHIELD = "Shield",
        INVTYPE_RELIC = "Relic",
        INVTYPE_THROWN = "Throw Weapon",
        INVTYPE_CLOAK = "Cloak",
        INVTYPE_BODY = "Shirt",
        INVTYPE_ROBE = "Chest - Robe",
        INVTYPE_TABARD = "Tabard",
    }
    return types[invType] or invType or "Unknown"
end

-- Button Functions
function TransmogScanner:StartTransmogScan()
    if TransmogScanner.scanTimer then
        print("TransmogScanner: Scan already in progress.")
        return
    end

    if TransmogScanner.transmogScanButton then
        TransmogScanner.transmogScanButton:Disable()
    end

    TransmogScanner:ShowTransmogList()
    TransmogScanner.transmogList = {} -- Clear previous results

    -- Find first enabled phase
    local enabledPhases = {}
    for i, phase in ipairs(TransmogScanner.scanPhases) do
        if phase.enabled then
            table.insert(enabledPhases, i)
        end
    end

    if #enabledPhases == 0 then
        print("TransmogScanner: No scan phases selected!")
        TransmogScanner:StopScan()
        return
    end

    local currentPhaseIndex = 1
    local currentPhase = enabledPhases[currentPhaseIndex]
    local currentPage = 0 -- Start at 0, will be incremented to 1 before first query

    print("TransmogScanner: Starting " .. TransmogScanner.scanPhases[currentPhase].name .. " scan")

    TransmogScanner.scanTimer = C_Timer.NewTicker(0.35, function(timer)
        if CanSendAuctionQuery() then
            local numItems = GetNumAuctionItems("list")
            
            -- Process current page results if we have items
            if numItems > 0 and currentPage > 0 then
                for i = 1, numItems do
                    local name, texture, amount, quality, _, _, _, _, buyoutPrice = GetAuctionItemInfo("list", i)
                    if name and buyoutPrice > 0 then
                        local phase = TransmogScanner.scanPhases[currentPhase]
                        TransmogScanner:CheckForTransmog(name, texture, "list", i, phase.invType)
                    end
                end
            end
            
            -- Check if we should move to next page or next phase
            if numItems == 0 or numItems < 50 then -- No more items on this page (50 is max per page)
                -- Move to next enabled phase
                currentPhaseIndex = currentPhaseIndex + 1
                if currentPhaseIndex <= #enabledPhases then
                    currentPhase = enabledPhases[currentPhaseIndex]
                    currentPage = 0
                    print("TransmogScanner: Starting " .. TransmogScanner.scanPhases[currentPhase].name .. " scan")
                else
                    -- All enabled phases complete
                    timer:Cancel()
                    TransmogScanner.scanTimer = nil
                    TransmogScanner:StopScan()
                    return
                end
            end
            
            -- Increment page and query next page
            currentPage = currentPage + 1
            local phase = TransmogScanner.scanPhases[currentPhase]
            
            if phase.subType then
                QueryAuctionItems("", nil, nil, nil, phase.invType, phase.subType, currentPage, nil, 6)
            elseif phase.subClass and phase.invType == 1 then
                QueryAuctionItems("", nil, nil, nil, phase.invType, phase.subClass, currentPage)
            else
                QueryAuctionItems("", nil, nil, phase.subClass, phase.invType, nil, currentPage)
            end
        end
    end)
    
    -- Start the first query
    local phase = TransmogScanner.scanPhases[currentPhase]
    currentPage = 1
    if phase.subType then
        QueryAuctionItems("", nil, nil, nil, phase.invType, phase.subType, currentPage, nil, 6)
    elseif phase.subClass and phase.invType == 1 then
        QueryAuctionItems("", nil, nil, nil, phase.invType, phase.subClass, currentPage)
    else
        QueryAuctionItems("", nil, nil, phase.subClass, phase.invType, nil, currentPage)
    end
end

function TransmogScanner:StopScan()
    if TransmogScanner.scanTimer then
        TransmogScanner.scanTimer:Cancel()
        TransmogScanner.scanTimer = nil
    end
    
    if TransmogScanner.transmogScanButton then 
        TransmogScanner.transmogScanButton:Enable() 
    end
    
    print("TransmogScanner: Scan completed")
    TransmogScanner:UpdateTransmogList()
end

function TransmogScanner:ShowTransmogList()
    if not self.transmogFrame then
        self.transmogFrame = CreateFrame("Frame", "TransmogScannerFrame", UIParent)
        -- Set width to 1/3 of screen width
        local frameWidth = math.floor(GetScreenWidth() / 3)
        -- Set height to nearly full screen height (with small margins)
        local frameHeight = GetScreenHeight()
        
        self.transmogFrame:SetSize(frameWidth, frameHeight)
        self.transmogFrame:SetPoint("TOPRIGHT") -- Changed position to match deals list
        self.transmogFrame:SetMovable(true)
        self.transmogFrame:EnableMouse(true)
        self.transmogFrame:SetClampedToScreen(true)
        self.transmogFrame:RegisterForDrag("LeftButton")
        self.transmogFrame:SetScript("OnDragStart", self.transmogFrame.StartMoving)
        self.transmogFrame:SetScript("OnDragStop", self.transmogFrame.StopMovingOrSizing)

        self.transmogFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        self.transmogFrame:SetFrameLevel(100)

        self.transmogFrame.bg = self.transmogFrame:CreateTexture(nil, "BACKGROUND")
        self.transmogFrame.bg:SetAllPoints(true)
        self.transmogFrame.bg:SetTexture(0, 0, 0, 0.8)

        self.transmogFrame.title = self.transmogFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        self.transmogFrame.title:SetPoint("TOP", self.transmogFrame, "TOP", 0, -5)
        self.transmogFrame.title:SetText("Missing Transmogs")

        self.transmogFrame.headers = self.transmogFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.transmogFrame.headers:SetPoint("TOPLEFT", self.transmogFrame, "TOPLEFT", 10, -22)
        -- Dynamic header text based on frame width
        local headerText = "         Name"
        for i = 1, math.floor(frameWidth / 9) do
            headerText = headerText .. " "
        end
        headerText = headerText .. "Type"
        for i = 1, math.floor(frameWidth / 9) do
            headerText = headerText .. " "
        end
        headerText = headerText .. "Price"
        self.transmogFrame.headers:SetText(headerText)

        self.transmogFrame.closeButton = CreateFrame("Button", nil, self.transmogFrame, "UIPanelCloseButton")
        self.transmogFrame.closeButton:SetPoint("TOPRIGHT", self.transmogFrame, "TOPRIGHT", 4, 4)

        -- Dynamic content sizing
        local contentWidth = frameWidth - 10
        local contentHeight = frameHeight - 45
        
        self.content = CreateFrame("Frame", nil, self.transmogFrame)
        self.content:SetSize(contentWidth, contentHeight)
        self.content:SetPoint("TOPLEFT", self.transmogFrame, "TOPLEFT", 5, -40)

        self.content.buttons = {}
        TransmogScanner.ITEMS_PER_PAGE = 27
        
        local itemHeight = math.floor(contentHeight / TransmogScanner.ITEMS_PER_PAGE)

        self.transmogFrame:EnableMouseWheel(true)
        self.transmogFrame:SetScript("OnMouseWheel", function(_, delta)
            if delta > 0 and TransmogScanner.currentTransmogPage > 1 then
                TransmogScanner.currentTransmogPage = TransmogScanner.currentTransmogPage - 1
                TransmogScanner:UpdateTransmogList()
            elseif delta < 0 and TransmogScanner.currentTransmogPage * TransmogScanner.ITEMS_PER_PAGE < #TransmogScanner.transmogList then
                TransmogScanner.currentTransmogPage = TransmogScanner.currentTransmogPage + 1
                TransmogScanner:UpdateTransmogList()
            end
        end)
    end

    self.transmogFrame:Show()
    TransmogScanner.currentTransmogPage = 1 
    TransmogScanner:UpdateTransmogList()
end

function TransmogScanner:CheckForTransmog(name, texture, listType, auctionIndex, searchtype)
    local isBindable, hasCtrlHint, hasCosmeticSet, ownsVanityItem = GetTooltipData(listType, auctionIndex)
    local _, _, _, quality, _, _, _, _, buyoutPrice = GetAuctionItemInfo(listType, auctionIndex)
    local itemLink = GetAuctionItemLink(listType, auctionIndex)
    local _, _, _, _, _, _, _, _, invType = GetItemInfo(itemLink)

    -- Check if this is a transmog item we want
    local isDesiredItem = false

    if hasCtrlHint and searchtype ~= 11 then
        -- Regular transmog items (weapons/armor)
        isDesiredItem = true
    elseif hasCosmeticSet and not ownsVanityItem then
        -- Armor caches with cosmetic sets we don't own
        isDesiredItem = true
    end

    if isDesiredItem then
        for _, item in ipairs(TransmogScanner.transmogList) do
            if item.name == name then
                return -- Already in list
            end
        end

        local itemType = GetFormattedItemType(invType, itemLink)
        if hasCosmeticSet then
            itemType = "Cosmetic Set"
        end
        if not itemType or itemType == "Unknown" or itemType == "" then
            return -- Don't add items without valid itemType
        end
        table.insert(TransmogScanner.transmogList, {
            name = name,
            texture = texture,
            buyoutPrice = buyoutPrice or 0,
            quality = quality,
            itemLink = itemLink,
            itemType = itemType
        })
        TransmogScanner:UpdateTransmogList()
    end
end

function TransmogScanner:UpdateTransmogList()
    if not self.transmogFrame or not self.transmogFrame:IsVisible() then return end

    table.sort(TransmogScanner.transmogList, function(a, b)
        if a.itemType == b.itemType then
            if a.buyoutPrice == b.buyoutPrice then
                return a.name < b.name -- If same price, sort by name
            end
            return a.buyoutPrice < b.buyoutPrice -- If same type, sort by price
        end
        return a.itemType < b.itemType -- Sort by type first
    end)

    local startIndex = (TransmogScanner.currentTransmogPage - 1) * TransmogScanner.ITEMS_PER_PAGE + 1
    local endIndex = math.min(TransmogScanner.currentTransmogPage * TransmogScanner.ITEMS_PER_PAGE, #TransmogScanner.transmogList)
    
    local totalPages = math.max(1, math.ceil(#TransmogScanner.transmogList / TransmogScanner.ITEMS_PER_PAGE))
    self.transmogFrame.title:SetText(string.format("Missing Transmogs (Page %d of %d)", TransmogScanner.currentTransmogPage, totalPages))

    -- Get dynamic dimensions
    local frameWidth = self.transmogFrame:GetWidth()
    local buttonWidth = frameWidth - 15
    
    -- Calculate dynamic column widths
    local nameWidth = math.floor(frameWidth * 0.5) -- 50% for name
    local typeWidth = math.floor(frameWidth * 0.25) -- 25% for type
    local priceWidth = math.floor(frameWidth * 0.2) -- 20% for price

    local itemHeight = 30
    for i = 1, TransmogScanner.ITEMS_PER_PAGE do
        local dataIndex = startIndex + i - 1
        local button = self.content.buttons[i]
        if not button then
            button = CreateFrame("Button", nil, self.content)
            button:SetSize(buttonWidth, itemHeight)

            local icon = button:CreateTexture(nil, "ARTWORK")
            icon:SetSize(24, 24)
            icon:SetPoint("LEFT", 5, 0)

            local nameText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            nameText:SetPoint("LEFT", icon, "RIGHT", 5, 0)
            nameText:SetWidth(nameWidth - 40) -- Account for icon
            nameText:SetJustifyH("LEFT")

            local typeText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            typeText:SetPoint("LEFT", nameText, "RIGHT", 5, 0)
            typeText:SetWidth(typeWidth)
            typeText:SetJustifyH("LEFT")

            local priceText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            priceText:SetPoint("RIGHT", button, "RIGHT", -5, 0)
            priceText:SetWidth(priceWidth)
            priceText:SetJustifyH("RIGHT")
            
            button.icon = icon
            button.nameText = nameText
            button.typeText = typeText
            button.priceText = priceText
            self.content.buttons[i] = button
        end

        -- Update button width for dynamic sizing
        button:SetWidth(buttonWidth)
        button:SetPoint("TOPLEFT", 0, -itemHeight * (i - 1))

        if dataIndex <= #TransmogScanner.transmogList and dataIndex <= endIndex then
            local itemData = TransmogScanner.transmogList[dataIndex]
            button.icon:SetTexture(itemData.texture)
            
            -- Set name color based on quality
            local r, g, b = GetItemQualityColor(itemData.quality)
            button.nameText:SetText(itemData.name)
            button.nameText:SetTextColor(r, g, b)
            
            button.typeText:SetText(itemData.itemType)
            button.priceText:SetText(GetCoinTextureString(math.ceil(itemData.buyoutPrice / 10000) * 10000))
            button.itemData = itemData
            
            button:SetScript("OnClick", function(self, mouseButton)
                if CanSendAuctionQuery() then
                    local itemData = self.itemData

                    -- Check if items are already loaded
                    local itemsAlreadyLoaded = false
                    local numAuctions = GetNumAuctionItems("list")
                    for j = 1, numAuctions do
                        local name = GetAuctionItemInfo("list", j)
                        if name == itemData.name then
                            itemsAlreadyLoaded = true
                            break
                        end
                    end

                    if mouseButton == "RightButton" and TransmogScanner.rightClickBuys then
                        -- Right-click: Buy the cheapest item with this name
                        if itemData.name == TransmogScanner.oldSearch then
                            -- Items should be loaded, find the cheapest one
                            local cheapestIndex = nil
                            local cheapestPrice = nil
                            local numAuctions = GetNumAuctionItems("list")
                    
                            for j = 1, numAuctions do
                                local name, _, _, _, _, _, _, _, buyoutPrice = GetAuctionItemInfo("list", j)
                                if name == itemData.name and buyoutPrice and buyoutPrice > 0 then
                                    if not cheapestPrice or buyoutPrice < cheapestPrice then
                                        cheapestPrice = buyoutPrice
                                        cheapestIndex = j
                                    end
                                end
                            end
                    
                            if cheapestIndex then
                                PlaceAuctionBid("list", cheapestIndex, cheapestPrice)
                                print("Bought " .. itemData.name .. " for " .. GetCoinTextureString(cheapestPrice))
                    
                                -- Remove item from transmog list
                                for i, item in ipairs(TransmogScanner.transmogList) do
                                    if item.name == itemData.name then
                                        table.remove(TransmogScanner.transmogList, i)
                                        break
                                    end
                                end
                    
                                TransmogScanner:UpdateTransmogList()
                            else
                                print("Could not find " .. itemData.name .. " with valid buyout price")
                            end
                        else
                            -- Search first, then we can buy on next right-click
                            print("Searching for: " .. itemData.name)
                            QueryAuctionItems(itemData.name)
                            TransmogScanner.oldSearch = itemData.name
                        end
                    elseif mouseButton == "LeftButton" then
                        -- Left-click behavior
                        if itemData.name ~= TransmogScanner.oldSearch then
                            -- First click - Search for the item
                            print("Searching for: " .. itemData.name)
                            QueryAuctionItems(itemData.name)
                            TransmogScanner.oldSearch = itemData.name
                        else
                            -- Second click - Try on the item
                            local itemFound = false
                            local numAuctions = GetNumAuctionItems("list")

                            for j = 1, numAuctions do
                                local name = GetAuctionItemInfo("list", j)
                                if name == itemData.name then
                                    itemFound = true
                                    -- Try on the item (show in dressing room)
                                    if DressUpFrame then
                                        local itemLink = GetAuctionItemLink("list", j)
                                        if itemLink then
                                            DressUpItemLink(itemLink)
                                            print("Trying on: " .. itemData.name)
                                        end
                                    end
                                    break
                                end
                            end

                            if not itemFound then
                                print("Could not find " .. itemData.name .. " to try on")
                            end
                        end
                    end
                else
                    print("Cannot send auction query now.")
                end
            end)
            button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            button:Show()
        else
            button:Hide()
        end
    end
end

function TransmogScanner:CreatePhaseSelectionDropdown()
    if not self.phaseDropdown then
        -- Main dropdown button
        self.phaseDropdown = CreateFrame("Button", "TransmogScannerPhaseDropdown", AuctionFrame, "UIPanelButtonTemplate")
        self.phaseDropdown:SetSize(22, 22)
        self.phaseDropdown:SetPoint("LEFT", TransmogScanner.showListButton, "RIGHT", 5, 0)
        self.phaseDropdown:SetFrameStrata("HIGH")
        self.phaseDropdown:SetFrameLevel(100)
        self.phaseDropdown:SetText("▼")

        -- Dropdown menu frame
        self.phaseDropdownMenu = CreateFrame("Frame", nil, self.phaseDropdown)
        self.phaseDropdownMenu:SetSize(400, 305)
        self.phaseDropdownMenu:SetPoint("TOPLEFT", self.phaseDropdown, "BOTTOMLEFT", 0, -2)
        self.phaseDropdownMenu:SetFrameStrata("FULLSCREEN_DIALOG")
        self.phaseDropdownMenu:SetFrameLevel(200)
        self.phaseDropdownMenu:Hide()

        -- Background for dropdown menu
        self.phaseDropdownMenu.bg = self.phaseDropdownMenu:CreateTexture(nil, "BACKGROUND")
        self.phaseDropdownMenu.bg:SetAllPoints(true)
        self.phaseDropdownMenu.bg:SetTexture(0.1, 0.1, 0.1, 0.95)

        -- Create borders
        local borders = {"TOP", "BOTTOM", "LEFT", "RIGHT"}
        for _, side in ipairs(borders) do
            local border = self.phaseDropdownMenu:CreateTexture(nil, "OVERLAY")
            border:SetTexture(0.6, 0.6, 0.6, 1)
            if side == "TOP" then
                border:SetHeight(2)
                border:SetPoint("TOPLEFT", self.phaseDropdownMenu, "TOPLEFT", 0, 0)
                border:SetPoint("TOPRIGHT", self.phaseDropdownMenu, "TOPRIGHT", 0, 0)
            elseif side == "BOTTOM" then
                border:SetHeight(2)
                border:SetPoint("BOTTOMLEFT", self.phaseDropdownMenu, "BOTTOMLEFT", 0, 0)
                border:SetPoint("BOTTOMRIGHT", self.phaseDropdownMenu, "BOTTOMRIGHT", 0, 0)
            elseif side == "LEFT" then
                border:SetWidth(2)
                border:SetPoint("TOPLEFT", self.phaseDropdownMenu, "TOPLEFT", 0, 0)
                border:SetPoint("BOTTOMLEFT", self.phaseDropdownMenu, "BOTTOMLEFT", 0, 0)
            else -- RIGHT
                border:SetWidth(2)
                border:SetPoint("TOPRIGHT", self.phaseDropdownMenu, "TOPRIGHT", 0, 0)
                border:SetPoint("BOTTOMRIGHT", self.phaseDropdownMenu, "BOTTOMRIGHT", 0, 0)
            end
        end

        -- Create content frame directly (no scroll frame)
        local content = CreateFrame("Frame", nil, self.phaseDropdownMenu)
        content:SetAllPoints(self.phaseDropdownMenu)

        -- Group phases by category
        local categories = {}
        for i, phase in ipairs(TransmogScanner.scanPhases) do
            local category = phase.category or "Other"
            if not categories[category] then
                categories[category] = {}
            end
            table.insert(categories[category], {phase = phase, index = i})
        end

        -- Create category sections
        local yOffset = -9
        local columnWidth = 125
        local leftColumn = 10
        local middleColumn = leftColumn + columnWidth + 10
        local rightColumn = middleColumn + columnWidth + 10

        -- Store checkboxes for later reference
        self.phaseDropdownMenu.checkboxes = {}

        -- Weapons category (left column)
        if categories["Weapons"] then
            local categoryHeader = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
            categoryHeader:SetPoint("TOPLEFT", content, "TOPLEFT", leftColumn, yOffset)
            categoryHeader:SetText("Weapons")
            categoryHeader:SetTextColor(1, 0.8, 0.2) -- Gold color
            yOffset = yOffset - 23

            -- Add "Select All Weapons" button
            local selectAllWeapons = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
            selectAllWeapons:SetSize(110, 18)
            selectAllWeapons:SetPoint("TOPLEFT", content, "TOPLEFT", leftColumn, yOffset)
            selectAllWeapons:SetText("Select All")
            selectAllWeapons:SetScript("OnClick", function()
                for _, item in ipairs(categories["Weapons"]) do
                    TransmogScanner.scanPhases[item.index].enabled = true
                    if self.phaseDropdownMenu.checkboxes[item.index] then
                        self.phaseDropdownMenu.checkboxes[item.index]:SetChecked(true)
                    end
                end
            end)
            yOffset = yOffset - 23

            for _, item in ipairs(categories["Weapons"]) do
                local checkbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
                checkbox:SetSize(16, 16)
                checkbox:SetPoint("TOPLEFT", content, "TOPLEFT", leftColumn, yOffset)
                checkbox:SetChecked(item.phase.enabled)

                local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
                label:SetText(item.phase.name)
                label:SetWidth(100)
                label:SetJustifyH("LEFT")

                checkbox:SetScript("OnClick", function(self)
                    TransmogScanner.scanPhases[item.index].enabled = self:GetChecked()
                end)

                self.phaseDropdownMenu.checkboxes[item.index] = checkbox
                yOffset = yOffset - 15
            end
        end

        -- Reset yOffset for middle column (Armor)
        yOffset = -9

        -- Armor category (middle column)
        if categories["Armor"] then
            local categoryHeader = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
            categoryHeader:SetPoint("TOPLEFT", content, "TOPLEFT", middleColumn, yOffset)
            categoryHeader:SetText("Armor")
            categoryHeader:SetTextColor(0.2, 0.8, 1) -- Blue color
            yOffset = yOffset - 23

            -- Add "Select All Armor" button
            local selectAllArmor = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
            selectAllArmor:SetSize(110, 18)
            selectAllArmor:SetPoint("TOPLEFT", content, "TOPLEFT", middleColumn, yOffset)
            selectAllArmor:SetText("Select All")
            selectAllArmor:SetScript("OnClick", function()
                for _, item in ipairs(categories["Armor"]) do
                    TransmogScanner.scanPhases[item.index].enabled = true
                    if self.phaseDropdownMenu.checkboxes[item.index] then
                        self.phaseDropdownMenu.checkboxes[item.index]:SetChecked(true)
                    end
                end
            end)
            yOffset = yOffset - 23

            for _, item in ipairs(categories["Armor"]) do
                local checkbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
                checkbox:SetSize(16, 16)
                checkbox:SetPoint("TOPLEFT", content, "TOPLEFT", middleColumn, yOffset)
                checkbox:SetChecked(item.phase.enabled)

                local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
                label:SetText(item.phase.name)
                label:SetWidth(100)
                label:SetJustifyH("LEFT")

                checkbox:SetScript("OnClick", function(self)
                    TransmogScanner.scanPhases[item.index].enabled = self:GetChecked()
                end)

                self.phaseDropdownMenu.checkboxes[item.index] = checkbox
                yOffset = yOffset - 15
            end
        end

        -- Reset yOffset for right column (Special)
        yOffset = -9

        -- Special category (right column)
        if categories["Special"] then
            local categoryHeader = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
            categoryHeader:SetPoint("TOPLEFT", content, "TOPLEFT", rightColumn, yOffset)
            categoryHeader:SetText("Special")
            categoryHeader:SetTextColor(0.8, 0.2, 0.8) -- Purple color
            yOffset = yOffset - 23

            -- Add "Clear All" and "Select Defaults" buttons at the bottom (spanning all columns)
            local clearAllButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
            clearAllButton:SetSize(80, 20)
            clearAllButton:SetPoint("TOPLEFT", content, "TOPLEFT", rightColumn, yOffset)
            clearAllButton:SetText("Clear All")
            clearAllButton:SetScript("OnClick", function()
                for i, phase in ipairs(TransmogScanner.scanPhases) do
                    TransmogScanner.scanPhases[i].enabled = false
                    if self.phaseDropdownMenu.checkboxes[i] then
                        self.phaseDropdownMenu.checkboxes[i]:SetChecked(false)
                    end
                end
            end)
            yOffset = yOffset - 23

            for _, item in ipairs(categories["Special"]) do
                local checkbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
                checkbox:SetSize(16, 16)
                checkbox:SetPoint("TOPLEFT", content, "TOPLEFT", rightColumn, yOffset)
                checkbox:SetChecked(item.phase.enabled)

                local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
                label:SetText(item.phase.name)

                checkbox:SetScript("OnClick", function(self)
                    TransmogScanner.scanPhases[item.index].enabled = self:GetChecked()
                end)

                self.phaseDropdownMenu.checkboxes[item.index] = checkbox
                yOffset = yOffset - 15
            end

            -- Add "Rightclick Buys" option in Special column
            local rightClickCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
            rightClickCheckbox:SetSize(16, 16)
            rightClickCheckbox:SetPoint("TOPLEFT", content, "TOPLEFT", rightColumn, yOffset)

            local rightClickLabel = rightClickCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            rightClickLabel:SetPoint("LEFT", rightClickCheckbox, "RIGHT", 5, 0)
            rightClickLabel:SetText("Rightclick Buys")
            rightClickLabel:SetTextColor(0.8, 0.8, 1) -- Light blue color

            rightClickCheckbox:SetScript("OnClick", function(self)
                TransmogScanner.rightClickBuys = self:GetChecked()
                if TransmogScanner.rightClickBuys then
                    print("TransmogScanner: Right-click buying enabled")
                else
                    print("TransmogScanner: Right-click buying disabled")
                end
            end)

            self.phaseDropdownMenu.rightClickCheckbox = rightClickCheckbox
        end

        -- Click handler for dropdown button
        self.phaseDropdown:SetScript("OnClick", function()
            if self.phaseDropdownMenu:IsVisible() then
                self.phaseDropdownMenu:Hide()
            else
                self.phaseDropdownMenu:Show()
            end
        end)

        -- Hide dropdown when clicking elsewhere
        self.phaseDropdownMenu:EnableMouse(true)
        self.phaseDropdownMenu:SetScript("OnHide", function()
            -- Update checkbox states when hiding
            for i, phase in ipairs(TransmogScanner.scanPhases) do
                if self.phaseDropdownMenu.checkboxes[i] then
                    self.phaseDropdownMenu.checkboxes[i]:SetChecked(phase.enabled)
                end
            end
            if self.phaseDropdownMenu.rightClickCheckbox then
                self.phaseDropdownMenu.rightClickCheckbox:SetChecked(TransmogScanner.rightClickBuys)
            end
        end)

        -- Click outside to close
        local function HideDropdownOnClick()
            if self.phaseDropdownMenu:IsVisible() then
                self.phaseDropdownMenu:Hide()
            end
        end

        -- Register global click handler
        local clickFrame = CreateFrame("Frame", nil, UIParent)
        clickFrame:SetAllPoints(UIParent)
        clickFrame:SetFrameStrata("BACKGROUND")
        clickFrame:EnableMouse(true)
        clickFrame:SetScript("OnMouseDown", HideDropdownOnClick)
        clickFrame:Hide()

        -- Show/hide click handler frame with dropdown
        self.phaseDropdownMenu:SetScript("OnShow", function() clickFrame:Show() end)
        self.phaseDropdownMenu:SetScript("OnHide", function() clickFrame:Hide() end)
    end
end

-- Event Handling
TransmogScanner:RegisterEvent("AUCTION_HOUSE_SHOW")
TransmogScanner:RegisterEvent("AUCTION_HOUSE_CLOSED")
TransmogScanner:SetScript("OnEvent", function(self, event, ...)
    if event == "AUCTION_HOUSE_SHOW" then
        -- Create the main scan button
        if not TransmogScanner.transmogScanButton then
            TransmogScanner.transmogScanButton = CreateFrame("Button", "TransmogScannerScanButton", AuctionFrame,
                "UIPanelButtonTemplate")
            TransmogScanner.transmogScanButton:SetSize(120, 22)
            TransmogScanner.transmogScanButton:SetPoint("BOTTOMLEFT", BrowseBidPriceGold, "BOTTOMLEFT", -30, -1)
            TransmogScanner.transmogScanButton:SetFrameStrata("HIGH")
            TransmogScanner.transmogScanButton:SetFrameLevel(100)
            TransmogScanner.transmogScanButton:SetText("Transmog Scan")
            TransmogScanner.transmogScanButton:SetScript("OnClick", function() TransmogScanner:StartTransmogScan() end)
        end
        TransmogScanner.transmogScanButton:Show()
        TransmogScanner.transmogScanButton:Enable()

        -- Create Show/Hide List button
        if not TransmogScanner.showListButton then
            TransmogScanner.showListButton = CreateFrame("Button", "TransmogScannerShowListButton", AuctionFrame,
                "UIPanelButtonTemplate")
            TransmogScanner.showListButton:SetSize(100, 22)
            TransmogScanner.showListButton:SetPoint("LEFT", TransmogScanner.transmogScanButton, "RIGHT", 0, 0)
            TransmogScanner.showListButton:SetFrameStrata("HIGH")
            TransmogScanner.showListButton:SetFrameLevel(100)
            TransmogScanner.showListButton:SetText("Show List")
            TransmogScanner.showListButton:SetScript("OnClick", function()
                if self.transmogFrame and self.transmogFrame:IsVisible() then
                    self.transmogFrame:Hide()
                    TransmogScanner.showListButton:SetText("Show List")
                else
                    TransmogScanner:ShowTransmogList()
                    TransmogScanner.showListButton:SetText("Hide List")
                end
            end)
        end
        TransmogScanner.showListButton:Show()
        if self.transmogFrame and self.transmogFrame:IsVisible() then
            TransmogScanner.showListButton:SetText("Hide List")
        else
            TransmogScanner.showListButton:SetText("Show List")
        end

        -- Create phase selection dropdown
        TransmogScanner:CreatePhaseSelectionDropdown()
        TransmogScanner.phaseDropdown:Show()

        -- Position and size the background frame after all buttons are created
        if TransmogScanner.buttonBackground then
            TransmogScanner.buttonBackground:SetSize(400, 22)
            TransmogScanner.buttonBackground:SetPoint("BOTTOMLEFT", BrowseBidPriceGold, "BOTTOMLEFT", -134, -1)
            TransmogScanner.buttonBackground:Show()
        end
    elseif event == "AUCTION_HOUSE_CLOSED" then
        if self.transmogFrame then
            self.transmogFrame:Hide()
            if TransmogScanner.showListButton then TransmogScanner.showListButton:SetText("Show List") end
        end
        if self.phaseDropdownMenu and self.phaseDropdownMenu:IsVisible() then
            self.phaseDropdownMenu:Hide()
        end
        if TransmogScanner.scanTimer then
            TransmogScanner:StopScan() -- false for interrupted
        end
        if TransmogScanner.transmogScanButton then TransmogScanner.transmogScanButton:Hide() end
        if TransmogScanner.showListButton then TransmogScanner.showListButton:Hide() end
        if TransmogScanner.phaseDropdown then TransmogScanner.phaseDropdown:Hide() end
    end
end)
