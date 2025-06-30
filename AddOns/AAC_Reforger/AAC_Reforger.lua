local isReforging = false
local isProducing = false
local reforgeTicker
local produceTicker
local scrolls = {}
local nameToSpellID = {}
local itemNameCache = {}

-- GUI
local reforgeButton = CreateFrame("Button", nil, Collections, "UIPanelButtonTemplate")
reforgeButton:SetSize(100, 25)
reforgeButton:SetPoint("TOPLEFT", 60, 30)
reforgeButton:SetText("FastReforge")
local smartButton = CreateFrame("Button", nil, Collections, "UIPanelButtonTemplate")
smartButton:SetSize(100, 25)
smartButton:SetPoint("LEFT", reforgeButton, "RIGHT", 10, 0)
smartButton:SetText("SmartProduce")
local tableButton = CreateFrame("Button", nil, Collections, "UIPanelButtonTemplate")
tableButton:SetSize(100, 25)
tableButton:SetPoint("LEFT", smartButton, "RIGHT", 10, 0)
tableButton:SetText("RE Table")
local backgroundFrame = CreateFrame("Frame", nil, Collections)
backgroundFrame:SetSize(383, 600)
backgroundFrame:SetPoint("TOPLEFT", Collections, "TOPLEFT", -375, -30)
backgroundFrame:Hide()
local backgroundTexture = backgroundFrame:CreateTexture(nil, "BACKGROUND")
backgroundTexture:SetAllPoints(true)
backgroundTexture:SetColorTexture(0, 0, 0, 0.7)
local scrollFrame = CreateFrame("ScrollFrame", nil, backgroundFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(360, 600)
scrollFrame:SetPoint("TOPLEFT", backgroundFrame, "TOPLEFT", 0, 0)
local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(385, 2300)
scrollFrame:SetScrollChild(content)
local rows = {}


local function InitializeDB()
    if not ReforgerDB then
        ReforgerDB = {}
    end
    
    local currentServer = GetRealmName()
    local currentCharacter = UnitName("player")
    
    if not ReforgerDB[currentServer] then
        ReforgerDB[currentServer] = {}
    end
    
    if not ReforgerDB[currentServer][currentCharacter] then
        ReforgerDB[currentServer][currentCharacter] = {
            bags = {},
            auctions = {},
            lastUpdate = 0
        }
    end
end

-- Stock tracking functions
local function UpdateBagCounts()
    local currentServer = GetRealmName()
    local currentCharacter = UnitName("player")
    
    local counts = ReforgerDB[currentServer][currentCharacter].bags
    wipe(counts)
    
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local itemID = GetItemInfoFromHyperlink(link)
                if itemID then
                    local _, count = GetContainerItemInfo(bag, slot)
                    counts[itemID] = (counts[itemID] or 0) + (count or 1)
                end
            end
        end
    end
    
    ReforgerDB[currentServer][currentCharacter].lastUpdate = time()
end

local function UpdateAuctionCounts()
    local currentServer = GetRealmName()
    local currentCharacter = UnitName("player")
    
    local counts = ReforgerDB[currentServer][currentCharacter].auctions
    wipe(counts)
    
    local numAuctions = GetNumAuctionItems("owner")
    for i = 1, numAuctions do
        local name, _, count = GetAuctionItemInfo("owner", i)
        if name then
            local itemID = select(1, GetItemInfoFromHyperlink(GetAuctionItemLink("owner", i)))
            if itemID then
                counts[itemID] = (counts[itemID] or 0) + (count or 1)
            end
        end
    end
    
    ReforgerDB[currentServer][currentCharacter].lastUpdate = time()
end

-- Get total item stock across bags and auctions
local function GetItemStock(itemID)
    local currentServer = GetRealmName()
    local currentCharacter = UnitName("player")
    
    if not ReforgerDB[currentServer] or not ReforgerDB[currentServer][currentCharacter] then
        return 0
    end
    
    local bagCount = ReforgerDB[currentServer][currentCharacter].bags[itemID] or 0
    local auctionCount = ReforgerDB[currentServer][currentCharacter].auctions[itemID] or 0
    
    return bagCount + auctionCount
end

local function RoundToGoldAndSilver(copperValue)
    -- Round to the nearest silver (100 copper)
    local roundedCopper = math.floor(copperValue / 100) * 100
    return roundedCopper
end

local function GetItemNameFromID(itemID)
    local itemName = GetItemInfo(itemID)
    return itemName
end

-- Background Functions
local function BuildSpellMapping()
    wipe(nameToSpellID)
    local enchantList = C_MysticEnchant.QueryEnchants(9999, 1, "", {})
    for _, enchant in pairs(enchantList) do
        if enchant.Known then
            nameToSpellID[enchant.SpellName] = enchant.SpellID
        end
    end
end

local function BuildItemNameCache()
    wipe(itemNameCache)
    local currentServer = GetRealmName()
    
    if SuperScanDB and SuperScanDB[currentServer] and SuperScanDB[currentServer].prices then
        for itemID, itemData in pairs(SuperScanDB[currentServer].prices) do
            local itemName = GetItemInfo(itemID)
            if itemName then
                itemNameCache[itemID] = itemName
            end
        end
    end
end

local function UpdateScrollList()
    if not backgroundFrame:IsVisible() then return end

    scrolls = {}
    local currentServer = GetRealmName()

    -- Get scrolls from SuperScan database
    if SuperScanDB and SuperScanDB[currentServer] and SuperScanDB[currentServer].prices then
        for itemID, itemData in pairs(SuperScanDB[currentServer].prices) do
            -- Verwende den Cache anstatt GetItemNameFromID
            local itemName = itemNameCache[itemID]
            if itemName and string.find(itemName, "Mystic Scroll") then
                table.insert(scrolls, {
                    name = itemName,
                    value = itemData.dbPrice,
                    stock = GetItemStock(itemID) or 0
                })
            end
        end
    end

    -- Sort by value
    table.sort(scrolls, function(a, b) return a.value > b.value end)


    -- Limit to top 100 scrolls
    local ITEM_HEIGHT = 20 
    local PADDING = 3
    
    -- Create or update rows
    for i = 1, 100 do
        local scroll = scrolls[i]
        if not scroll then break end
        
        local yOffset = -(PADDING + (i-1) * (ITEM_HEIGHT + PADDING))
        
        -- Create row if it doesn't exist
        if not rows[i] then
            rows[i] = CreateFrame("Frame", nil, content)
            rows[i]:SetSize(330, ITEM_HEIGHT)
            rows[i]:SetPoint("TOPLEFT", content, "TOPLEFT", PADDING, yOffset)
            
            -- Create text elements once
            rows[i].name = rows[i]:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            rows[i].name:SetPoint("LEFT", rows[i], "LEFT", 0, 0)
            rows[i].name:SetWidth(230)
            rows[i].name:SetJustifyH("LEFT")
            
            rows[i].value = rows[i]:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            rows[i].value:SetPoint("LEFT", rows[i].name, "RIGHT", 10, 0)
            rows[i].value:SetWidth(80)
            rows[i].value:SetJustifyH("RIGHT")
            
            rows[i].stock = rows[i]:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            rows[i].stock:SetPoint("LEFT", rows[i].value, "RIGHT", 10, 0)
            rows[i].stock:SetWidth(20)
            rows[i].stock:SetJustifyH("RIGHT")
        end
        
        -- Just update the text content
        rows[i].name:SetText(scroll.name)
        local roundedValue = RoundToGoldAndSilver(scroll.value)
        rows[i].value:SetText(GetCoinTextureString(roundedValue))
        rows[i].stock:SetText(scroll.stock)
        rows[i]:Show()
    end
    
    -- Hide unused rows
    for i = #scrolls + 1, #rows do
        if rows[i] then
            rows[i]:Hide()
        end
    end
end

local function ToggleScrollList()
    if backgroundFrame:IsVisible() then
        backgroundFrame:Hide()
        tableButton:SetText("RE Table")
    else
        backgroundFrame:Show()
        tableButton:SetText("Hide Table")
        C_Timer.After(0.1, UpdateScrollList)
    end
end
tableButton:SetScript("OnClick", ToggleScrollList)

local function SmartProduce()
    if not isProducing then return end

    if UnitCastingInfo("player") then
        nilCastCounterProduce = 0
        return
    end

    if not Collections:IsShown() and produceTicker then
        produceTicker:Cancel()
        isProducing = false
        smartButton:SetText("SmartProduce")
        print("AAC_Reforger: SmartProduce auto-stopped.")
        return
    end

    -- Check currency
    local currentAmount = GetItemCount(98570)
    if currentAmount <= 500 then
        if produceTicker then produceTicker:Cancel() end
        print("AAC_Reforger: SmartProduce stopped due to low Orbs amount (<500).")
        isProducing = false
        smartButton:SetText("SmartProduce")
        return
    end

    -- Check inventory space
    local freeSlots = 0
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            if not GetContainerItemID(bag, slot) then
                freeSlots = freeSlots + 1
            end
        end
    end

    -- Stop if only 1 slot left
    if freeSlots <= 1 then
        if produceTicker then produceTicker:Cancel() end
        isProducing = false
        smartButton:SetText("SmartProduce")
        return
    end

    -- Find the most valuable enchant we need and craft it
    local currentServer = GetRealmName()
    local bestSpellID = nil
    local bestValue = 0

    if SuperScanDB and SuperScanDB[currentServer] and SuperScanDB[currentServer].prices then
        -- Find the most valuable scroll we need (stock < 5)
        for itemID, itemData in pairs(SuperScanDB[currentServer].prices) do
            -- Verwende den Cache anstatt GetItemNameFromID
            local itemName = itemNameCache[itemID]
            if itemName and string.find(itemName, "Mystic Scroll: ") then
                local stock = GetItemStock(itemID)
                if stock < 5 and itemData.dbPrice > bestValue then
                    local enchantName = itemName:match("Mystic Scroll: (.+)")
                    if enchantName and nameToSpellID[enchantName] then
                        bestSpellID = nameToSpellID[enchantName]
                        bestValue = itemData.dbPrice
                    end
                end
            end
        end
    end

    -- Find blank scroll and craft the best enchant
    if bestSpellID then
        local inventoryList = C_MysticEnchant.GetMysticScrolls()
        for _, scroll in ipairs(inventoryList) do
            if scroll.Entry == 992720 then
                C_MysticEnchant.CollectionReforgeItem(scroll.Guid, bestSpellID)
                return
            end
        end
    end

    -- Buy new scroll if none found
    C_MysticEnchant.PurchaseMysticScroll()
end

local function ToggleProducing()
    if isProducing then
        if produceTicker then produceTicker:Cancel() end
        isProducing = false
        smartButton:SetText("SmartProduce")
    else
        -- Build the spell mapping and item name cache once before starting
        BuildSpellMapping()
        BuildItemNameCache()
        isProducing = true
        nilCastCounterProduce = 0
        smartButton:SetText("Producing...")
        produceTicker = C_Timer.NewTicker(0.1, SmartProduce)
    end
end
smartButton:SetScript("OnClick", ToggleProducing)

local function Reforge()
    if not isRunning then return end
    
    if UnitCastingInfo("player") then
        nilCastCounterReforge = 0
        return
    end
    
    if not Collections:IsShown() and reforgeTicker then 
        reforgeTicker:Cancel()
        isRunning = false
        reforgeButton:SetText("Buy & Reforge")
        print("AAC_Reforger: FastReforge auto-stopped.")
        return
    end

    -- Check currency first
    local currentAmount = GetItemCount(98462)
    if currentAmount <= 0 then
        if reforgeTicker then reforgeTicker:Cancel() end
        isRunning = false
        reforgeButton:SetText("Buy & Reforge")
        return
    end
    
    -- Count free inventory slots first
    local freeSlots = 0
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            if not GetContainerItemID(bag, slot) then
                freeSlots = freeSlots + 1
            end
        end
    end
    
    -- Stop if only 1 slot left
    if freeSlots <= 1 then
        if reforgeTicker then reforgeTicker:Cancel() end
        isRunning = false
        reforgeButton:SetText("Buy & Reforge")
        return
    end
    
    -- Check for scrolls to reforge
    local inventoryList = C_MysticEnchant.GetMysticScrolls()
    for _, scroll in ipairs(inventoryList) do
        if scroll.Entry == 992720 then -- Untarnished Mystic Scroll
            C_MysticEnchant.ReforgeItem(scroll.Guid)
            return
        end
    end
    
    -- If no scrolls found, buy new one
    C_MysticEnchant.PurchaseMysticScroll()
end

local function ToggleReforging()
    if isRunning then
        if reforgeTicker then reforgeTicker:Cancel() end
        isRunning = false
        reforgeButton:SetText("Buy & Reforge")
    else
        isRunning = true
        nilCastCounterReforge = 0
        reforgeButton:SetText("Running...")
        reforgeTicker = C_Timer.NewTicker(0.01, Reforge)
    end

    if backgroundFrame:IsVisible() then
        ToggleScrollList()
    end
end
reforgeButton:SetScript("OnClick", ToggleReforging)

local reforgeFrame = CreateFrame("Frame")
reforgeFrame:RegisterEvent("BAG_UPDATE")
reforgeFrame:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
reforgeFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
reforgeFrame:SetScript("OnEvent", function(self, event)
    if event == "BAG_UPDATE" then
        UpdateBagCounts()
        if scrollFrame and scrollFrame:IsVisible() then
            UpdateScrollList()
        end
    elseif event == "AUCTION_OWNED_LIST_UPDATE" then
        UpdateAuctionCounts()
    elseif event == "PLAYER_ENTERING_WORLD" then
        InitializeDB()
        UpdateBagCounts()
        BuildSpellMapping()
        BuildItemNameCache()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)