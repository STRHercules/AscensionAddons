--[[-------------------------------------------------------------------
 GuildRoster Addon – v2.2 for WoW 3.3.5 (WotLK)
 Author: Zachary Kaiser & ChatGPT

 13 Jun 2025  ▸ Hot‑fix build
 • Removes stray unicode/colour code that broke Lua parser (line 204 error).
 • Re‑writes checkbox label logic without _G lookup.
 • Ensures all strings are properly quoted – no more “']' expected near …”.
 • Minor clean‑ups & safer tab build.
---------------------------------------------------------------------]]--

------------------------------------------------------------------------
-- ▶ LOCAL CONSTANTS & STATE
------------------------------------------------------------------------
local ROW_HEIGHT        = 18
local COLUMN_GAP        = 5
local WINDOW_WIDTH      = 800
local WINDOW_HEIGHT     = 600

-- Roster columns
local COLUMNS_STANDARD = {
    { name="Level", width=50,  key="level", align="CENTER" },
    { name="Name",  width=150, key="name",  align="LEFT"   },
    { name="Class", width=100, key="class", align="LEFT"   },
    { name="Zone",  width=150, key="zone",  align="LEFT"   },
    { name="Online",width=60,  key="online",align="CENTER" },
}
local COLUMNS_NOTES = {
    { name="Name",         width=150, key="name",       align="LEFT" },
    { name="Rank",         width=120, key="rank",       align="LEFT" },
    { name="Note",         width=200, key="note",       align="LEFT" },
    { name="Officer Note", width=200, key="officenote", align="LEFT" },
    { name="Last Online",  width=100, key="lastOnlineF",align="LEFT" },
}

-- Session state
local roster           = {}
local rosterMode       = 1     -- 1 = Standard, 2 = Notes
local showOffline      = true
local sortCol          = 2     -- default sort by Name
local sortAsc          = true

------------------------------------------------------------------------
-- ▶ MAIN FRAME
------------------------------------------------------------------------
local GR = CreateFrame("Frame", "GuildRosterFrame", UIParent, "BasicFrameTemplate")
GR:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
GR:SetPoint("CENTER")
GR:SetMovable(true)
GR:EnableMouse(true)
GR:RegisterForDrag("LeftButton")
GR:SetScript("OnDragStart", GR.StartMoving)
GR:SetScript("OnDragStop",  GR.StopMovingOrSizing)
GR.TitleText:SetText("Guild Roster")

------------------------------------------------------------------------
-- ▶ CONTAINERS & SCROLL FRAME
------------------------------------------------------------------------
local rosterContainer = CreateFrame("Frame", nil, GR)
rosterContainer:SetPoint("TOPLEFT", 10, -60)
rosterContainer:SetPoint("BOTTOMRIGHT", -30, 40)

local scroll = CreateFrame("ScrollFrame", "GRScrollFrame", rosterContainer, "FauxScrollFrameTemplate")
scroll:SetAllPoints()

local visibleRows = math.floor((WINDOW_HEIGHT-140)/ROW_HEIGHT)
local rowFrames   = {}
for i=1, visibleRows do
    local row = CreateFrame("Button", nil, rosterContainer)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", rosterContainer, "TOPLEFT", 0, -(i-1)*ROW_HEIGHT)
    row:SetPoint("RIGHT", rosterContainer, "RIGHT", -16, 0)
    row.cols = {}
    rowFrames[i] = row
end

------------------------------------------------------------------------
-- ▶ HEADERS
------------------------------------------------------------------------
local headers = {}
local function BuildHeaders()
    for _,h in ipairs(headers) do h:Hide() end
    wipe(headers)

    local cols = (rosterMode==1) and COLUMNS_STANDARD or COLUMNS_NOTES
    local x = 0
    for idx,col in ipairs(cols) do
        local header = CreateFrame("Button", nil, rosterContainer, "FriendsFrameHeaderTemplate")
        header:SetSize(col.width, 16)
        header:SetPoint("TOPLEFT", rosterContainer, "TOPLEFT", x, 16)
        header:SetText(col.name)
        header.index = idx
        header:SetScript("OnClick", function(self)
            if sortCol == self.index then sortAsc = not sortAsc else sortCol = self.index; sortAsc = true end
            GR:SortAndRefresh()
        end)
        headers[idx] = header
        col.header = header
        x = x + col.width + COLUMN_GAP
    end
end

local function RefreshHeaderArrows()
    local cols = (rosterMode==1) and COLUMNS_STANDARD or COLUMNS_NOTES
    for i,col in ipairs(cols) do
        if col.header then
            local txt = col.name
            if i==sortCol then txt = txt .. (sortAsc and " ▲" or " ▼") end
            col.header:SetText(txt)
        end
    end
end

------------------------------------------------------------------------
-- ▶ DATA
------------------------------------------------------------------------
function GR:FetchGuild()
    GuildRoster() -- request fresh data
    wipe(roster)
    local total = GetNumGuildMembers(true)
    for i=1,total do
        local n, rank, rankIdx, lvl, class, zone, note, oNote, online, status, cFile, _, _, _, last = GetGuildRosterInfo(i)
        if n and (online or showOffline) then
            local lastF = online and "Online" or (not last or last==0) and "Unknown" or string.format("%d day(s)", last)
            table.insert(roster, {
                name=n, rank=rank or "", rankIndex=rankIdx or 0,
                level=lvl or 0, class=class or "", zone=zone or "",
                note=note or "", officenote=oNote or "", online=online and "Yes" or "No",
                status=status, classFileName=cFile, lastOnline=last, lastOnlineF=lastF,
            })
        end
    end
end

-- ▶ NEW ROBUST COMPARATOR
local function MakeComparator(key)
    return function(a,b)
        if not a then return false end        -- push nil/empty to bottom
        if not b then return true  end
        local va, vb = a[key], b[key]
        -- Treat nil as empty string/zero for stable ordering
        if va == nil then va = "" end
        if vb == nil then vb = "" end

        -- If values are identical, keep original order (return false)
        if va == vb then return false end

        -- Numeric comparison when both are numbers
        if type(va)=="number" and type(vb)=="number" then
            return sortAsc and (va < vb) or (va > vb)
        end

        -- Fallback to case‑insensitive string compare
        va, vb = tostring(va):lower(), tostring(vb):lower()
        if sortAsc then
            return va < vb
        else
            return va > vb
        end
    end
end

function GR:SortAndRefresh()
    local cols = (rosterMode==1) and COLUMNS_STANDARD or COLUMNS_NOTES
    local key  = cols[sortCol] and cols[sortCol].key or "name" -- safety fallback
    table.sort(roster, MakeComparator(key))
    RefreshHeaderArrows()
    GR:DrawRows()
end

function GR:DrawRows()
    FauxScrollFrame_Update(scroll, #roster, visibleRows, ROW_HEIGHT)
    local offset = FauxScrollFrame_GetOffset(scroll)
    local cols   = (rosterMode==1) and COLUMNS_STANDARD or COLUMNS_NOTES
    for i=1, visibleRows do
        local data = roster[i+offset]
        local row  = rowFrames[i]
        if data then
            row:Show()
            for cIdx,col in ipairs(cols) do
                local cell = row.cols[cIdx]
                if not cell then
                    cell = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    row.cols[cIdx] = cell
                    if cIdx==1 then
                        cell:SetPoint("LEFT", 2, 0)
                    else
                        cell:SetPoint("LEFT", row.cols[cIdx-1], "RIGHT", COLUMN_GAP, 0)
                    end
                    cell:SetWidth(col.width)
                    cell:SetJustifyH(col.align)
                end
                cell:SetText(data[col.key] or "")
                if col.key=="class" then
                    local c = RAID_CLASS_COLORS[data.classFileName or ""]
                    if c then cell:SetTextColor(c.r,c.g,c.b) else cell:SetTextColor(1,1,1) end
                else
                    cell:SetTextColor(1,1,1)
                end
            end
        else
            row:Hide()
        end
    end
end

scroll:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, function() GR:DrawRows() end)
end)
------------------------------------------------------------------------
-- ▶ CONTROLS
------------------------------------------------------------------------
local offlineChk = CreateFrame("CheckButton", nil, GR, "UICheckButtonTemplate")
offlineChk:SetPoint("TOPLEFT", GR, "TOPLEFT", 20, -40)
offlineChk:SetSize(20,20)
offlineChk:SetChecked(showOffline)
local lbl = offlineChk:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
lbl:SetPoint("LEFT", offlineChk, "RIGHT", 5, 0)
lbl:SetText("Show Offline")
offlineChk:SetScript("OnClick", function(self)
    showOffline = self:GetChecked()
    GR:FetchGuild(); GR:SortAndRefresh(); PlaySound("igMainMenuOption")
end)

local modeBtn = CreateFrame("Button", nil, GR, "UIPanelButtonTemplate")
modeBtn:SetSize(120,22)
modeBtn:SetPoint("LEFT", lbl, "RIGHT", 20, 0)
modeBtn:SetText("View Notes")
modeBtn:SetScript("OnClick", function(self)
    rosterMode = rosterMode==1 and 2 or 1
    self:SetText(rosterMode==1 and "View Notes" or "View Standard")
    BuildHeaders(); GR:SortAndRefresh(); PlaySound("igMainMenuOption")
end)

------------------------------------------------------------------------
-- ▶ TABS (Roster | Guild Control | Info)
------------------------------------------------------------------------
local tabNames = {"Roster", "Guild Control", "Guild Info"}
GR.tabs = {}
for i,name in ipairs(tabNames) do
    local tab = CreateFrame("Button", "GuildRosterFrameTab"..i, GR, "CharacterFrameTabButtonTemplate")
    tab:SetID(i)
    tab:SetText(name)
    PanelTemplates_TabResize(tab, 0)
    if i==1 then
        tab:SetPoint("TOPLEFT", GR, "TOPLEFT", 10, -30)
    else
        tab:SetPoint("LEFT", _G["GuildRosterFrameTab"..(i-1)], "RIGHT", -15, 0)
    end
    tab:SetScript("OnClick", function() end) -- future extras
    GR.tabs[i] = tab
end
PanelTemplates_SetNumTabs(GR, #GR.tabs)
PanelTemplates_SetTab(GR, 1)

------------------------------------------------------------------------
-- ▶ SLASH COMMAND & EVENT HANDLERS
------------------------------------------------------------------------
SLASH_GUILDROSTER1, SLASH_GUILDROSTER2 = "/gr", "/guildroster"
SlashCmdList["GUILDROSTER"] = function()
    if GR:IsShown() then GR:Hide() else GR:Show(); GR:FetchGuild(); GR:SortAndRefresh() end
end

GR:RegisterEvent("GUILD_ROSTER_UPDATE")
GR:SetScript("OnEvent", function(self, evt)
    if evt=="GUILD_ROSTER_UPDATE" and self:IsShown() then
        self:FetchGuild(); self:SortAndRefresh()
    end
end)

-- initial build
BuildHeaders()
GR:Hide()
print("Guild Roster loaded – type |cff00ff00/gr|r to toggle window.")
