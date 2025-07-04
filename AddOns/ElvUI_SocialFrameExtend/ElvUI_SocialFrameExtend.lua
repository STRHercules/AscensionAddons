local Addon = CreateFrame('Frame')
Addon:RegisterEvent('PLAYER_LOGIN')

local EXTRA_ROWS = 10
local EXTRA_WIDTH = 120

local function CreateGuildButtons(startIndex, endIndex)
    for i = startIndex, endIndex do
        local prev = _G["GuildFrameButton"..(i-1)]
        if not prev then break end
        local button = CreateFrame("Button", "GuildFrameButton"..i, GuildFrame, "FriendsFrameGuildPlayerStatusButtonTemplate")
        button:SetID(i)
        button:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
        local statusPrev = _G["GuildFrameGuildStatusButton"..(i-1)]
        local statusButton = CreateFrame("Button", "GuildFrameGuildStatusButton"..i, GuildFrame, "FriendsFrameGuildStatusButtonTemplate")
        statusButton:SetID(i)
        statusButton:SetPoint("TOPLEFT", statusPrev, "BOTTOMLEFT", 0, 0)
    end
end

local function ResizeSocial()
    local rowHeight = FRIENDS_FRAME_GUILD_HEIGHT or 14
    local oldHeight = FriendsFrame:GetHeight()
    local oldWidth = FriendsFrame:GetWidth()
    local heightIncrease = EXTRA_ROWS * rowHeight

    FriendsFrame:SetHeight(oldHeight + heightIncrease)
    FriendsFrame:SetWidth(oldWidth + EXTRA_WIDTH)

    GuildListScrollFrame:SetHeight(GuildListScrollFrame:GetHeight() + heightIncrease)
    GuildListScrollFrame:SetWidth(GuildListScrollFrame:GetWidth() + EXTRA_WIDTH)
    GuildStatusScrollFrame:SetHeight(GuildStatusScrollFrame:GetHeight() + heightIncrease)
    GuildStatusScrollFrame:SetWidth(GuildStatusScrollFrame:GetWidth() + EXTRA_WIDTH)

    FriendsFrameFriendsScrollFrame:SetHeight(FriendsFrameFriendsScrollFrame:GetHeight() + heightIncrease)
    FriendsFrameFriendsScrollFrame:SetWidth(FriendsFrameFriendsScrollFrame:GetWidth() + EXTRA_WIDTH)
    FriendsFrameIgnoreScrollFrame:SetHeight(FriendsFrameIgnoreScrollFrame:GetHeight() + heightIncrease)
    FriendsFrameIgnoreScrollFrame:SetWidth(FriendsFrameIgnoreScrollFrame:GetWidth() + EXTRA_WIDTH)

    local start = GUILDMEMBERS_TO_DISPLAY + 1
    GUILDMEMBERS_TO_DISPLAY = GUILDMEMBERS_TO_DISPLAY + EXTRA_ROWS
    CreateGuildButtons(start, GUILDMEMBERS_TO_DISPLAY)

    FRIENDS_TO_DISPLAY = FRIENDS_TO_DISPLAY + EXTRA_ROWS
    IGNORES_TO_DISPLAY = IGNORES_TO_DISPLAY + EXTRA_ROWS
    FRIENDS_FRIENDS_TO_DISPLAY = FRIENDS_FRIENDS_TO_DISPLAY + EXTRA_ROWS
    WHOS_TO_DISPLAY = WHOS_TO_DISPLAY + EXTRA_ROWS
end

Addon:SetScript('OnEvent', function()
    ResizeSocial()
end)

