-- Compatibility helpers for Wrath of the Lich King (3.3.5)

-- Simple timer replacement if C_Timer.After is unavailable
if not C_Timer then
    C_Timer = {}
end
if not C_Timer.After then
    local frame = CreateFrame("Frame")
    local timers = {}
    frame:SetScript("OnUpdate", function(self, elapsed)
        for i=#timers,1,-1 do
            local t = timers[i]
            t.delay = t.delay - elapsed
            if t.delay <= 0 then
                t.func()
                table.remove(timers, i)
            end
        end
    end)
    function C_Timer.After(delay, func)
        table.insert(timers, {delay = delay, func = func})
    end
end

-- Maximum player level helper for pre-Shadowlands clients
if not GetMaxPlayerLevel then
    function GetMaxPlayerLevel()
        return MAX_PLAYER_LEVEL or 80
    end
end

-- Chat API backports
if not C_ChatInfo then
    C_ChatInfo = {}
end
if not C_ChatInfo.RegisterAddonMessagePrefix and RegisterAddonMessagePrefix then
    function C_ChatInfo.RegisterAddonMessagePrefix(prefix)
        RegisterAddonMessagePrefix(prefix)
    end
end
if not C_ChatInfo.SendAddonMessage and SendAddonMessage then
    function C_ChatInfo.SendAddonMessage(prefix, msg, type, target)
        if target then
            SendAddonMessage(prefix, msg, type, target)
        else
            SendAddonMessage(prefix, msg, type)
        end
    end
end

-- Group size helper
if not GetNumGroupMembers then
    function GetNumGroupMembers()
        if UnitInRaid("player") then
            return GetNumRaidMembers()
        else
            return GetNumPartyMembers()
        end
    end
end
