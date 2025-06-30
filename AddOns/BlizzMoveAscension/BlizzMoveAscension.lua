-- ╔══════════════════════════╦═════════════════════════════════════════════════════════════════════════════[─]═[□]═[×]═╗
-- ║ General                  ║ Database                                                                                ║
-- ╚══════════════════════════╩═════════════════════════════════════════════════════════════════════════════════════════╝

-- Database
db = nil
local frame = CreateFrame("Frame")
local optionPanel = nil
local debugEnabled = false -- Toggle for diagnostics 
local LFG_FRAME_NAME = "AscensionLFGFrame" 
local PVP_FRAME_NAME = "PVPFrame" 
local INSPECT_FRAME_NAME = "InspectFrame" 

-- Database Config
local defaultDB = {
	AchievementFrame = {save = true}, CalendarFrame = {save = true}, AuctionFrame = {save = true},
	GuildBankFrame = {save = true}, AscensionLFGFrame = {save = true}, WorldMapFrame = {save = true},
	PVPFrame = {save = true}, WorldStateScoreFrame = {save = true}, PetStableFrame = {save = true},
    AscensionCharacterFrame = {save = true}, AscensionSpellbookFrame = {save = true}, QuestLogFrame = {save = true},
    InspectFrame = {save = true} 
}

-- ╔══════════════════════════╦═════════════════════════════════════════════════════════════════════════════[─]═[□]═[×]═╗
-- ║ General                  ║ Message Output                                                                          ║
-- ╚══════════════════════════╩═════════════════════════════════════════════════════════════════════════════════════════╝

local function Print(...)
	if debugEnabled then
		local s = "|cFF33FF99BlizzMove:|r"
		for i=1,select("#", ...) do local x = select(i, ...); s = strjoin(" ", s, tostring(x)) end
		DEFAULT_CHAT_FRAME:AddMessage(s)
	end
end

-- ╔══════════════════════════╦═════════════════════════════════════════════════════════════════════════════[─]═[□]═[×]═╗
-- ║ General                  ║ Window Positioning                                                                      ║
-- ╚════════════════==========╩═════════════════════════════════════════════════════════════════════════════════════════╝

local function ApplyPosition(self) 
    local frameName = self and self:GetName() or "UnknownFrame"
    if InCombatLockdown() then Print("ApplyPosition: In combat, skipping for", frameName); return end
	if not self or not self.settings then Print("ApplyPosition: Invalid frame/settings for", frameName); return end
	local s = self.settings
    local targetPoint = s.point
    local targetX = s.xOfs or 0
    local targetY = s.yOfs or 0
    local targetScale = s.scale or 1
    local targetRelativePoint = s.relativePoint or targetPoint 
	if not targetPoint then Print("ApplyPosition: No targetPoint for", frameName, ". Skipping."); return end
	if s.save then 
		local cP,cA,cRP,cX,cY=self:GetPoint(); local cS=self:GetScale()
        local nPU = (cP~=targetPoint) or (cRP ~= targetRelativePoint) or (math.abs(cX-targetX)>0.01) or (math.abs(cY-targetY)>0.01)
		local nSU = math.abs(cS-targetScale)>0.01 
		if nPU or nSU then
			Print("ApplyPosition: Setting point for",frameName,"-> Target:",targetPoint,"RelP:",targetRelativePoint,"X:",targetX,"Y:",targetY,"S:",targetScale)
			self:ClearAllPoints(); local rT=_G["UIParent"]; 
			self:SetPoint(targetPoint,rT,targetRelativePoint,targetX,targetY)
            if s.scale then self:SetScale(targetScale) end 
			Print("ApplyPosition: SetPoint executed for",frameName)
		else Print("ApplyPosition: No change for",frameName,"(already at target)") end
	else Print("ApplyPosition: Skipped for",frameName,"- not s.save (s.save is false)") end
end

local function OnShow(self, ...)
    local frameName = self:GetName()
	if self.isApplyingPosition then Print(frameName, ":OnShow - Already applying, skipping."); return end
	Print(frameName, ":OnShow - Triggered. Setting isApplyingPosition = true."); self.isApplyingPosition = true; 
    ApplyPosition(self) 
	if frameName == LFG_FRAME_NAME then
		C_Timer.After(0.03, function() 
			if self:IsShown() and not self.isMoving then if self.isApplyingDelayedShowPositionLFG then Print(frameName,":OnShow LFG Delayed-AlreadyInProgress.");return end;self.isApplyingDelayedShowPositionLFG=true;Print("Enforced position for",frameName,"after 0.03s delay(OnShow)");ApplyPosition(self);self.isApplyingDelayedShowPositionLFG=nil else Print(frameName,":OnShow LFG Delayed-Skipped")end end)
	end
	self.isApplyingPosition = nil; Print(frameName, ":OnShow - Finished.")
end

-- Scaling Function
local function OnMouseWheel(self, value, ...) if IsControlKeyDown() then local fTM=self.frameToMove; if not fTM then return end; local s=fTM:GetScale()or 1; if value==1 then s=math.min(1.5,s+0.1)else s=math.max(0.5,s-0.1)end; fTM:SetScale(s); if fTM.settings then fTM.settings.scale=s;Print("Scale for",fTM:GetName(),"to",s)else Print("OnMouseWheel: fTM",fTM:GetName(),"no .settings")end elseif fTM and fTM.HandleMouseWheel then fTM:HandleMouseWheel(value)end end

-- Drag Functions
local function OnDragStart(self) Print("!!!!!!!!!! GLOBAL OnDragStart by:",self:GetName(),"!!!!!!!!!!");local fTM=self.frameToMove or self;if not fTM then Print("OnDragStart:fTM nil H",self:GetName());return end;if InCombatLockdown()then Print("OnDragStart:CombatLock",fTM:GetName());DEFAULT_CHAT_FRAME:AddMessage("BlizzMove:Drag disabled in combat.");return end;Print("DragStart",fTM:GetName());local s=fTM.settings;if s and not s.default then s.default={};local d=s.default;d.p,d.rT,d.rP,d.x,d.y=fTM:GetPoint();if d.rT then d.rT=d.rT:GetName()end end;fTM:StartMoving();fTM.isMoving=true;if self~=fTM then self:EnableMouse(true)end end
local function OnDragStop(self)local fTM=self.frameToMove or self;if not fTM then Print("OnDragStop:fTM nil H",self:GetName());return end;if not fTM.isMoving then Print("OnDragStop:DragNotLegit",fTM:GetName());if fTM.StopMovingOrSizing then fTM:StopMovingOrSizing()end;return end;Print("DragStop",fTM:GetName());fTM:StopMovingOrSizing();fTM.isMoving=false;local s=fTM.settings;if not s then if type(db)~="table"then Print("OnDragStop:DB NIL for",fTM:GetName());return end;db[fTM:GetName()]={save=true};s=db[fTM:GetName()];fTM.settings=s end;s.save=true;local point, _, relativePoint, xOfs, yOfs=fTM:GetPoint();if point and xOfs and yOfs then s.point,s.relativeTo,s.relativePoint,s.xOfs,s.yOfs=point,"UIParent",point,xOfs,yOfs; Print("Saved for",fTM:GetName(),"P:",point,"RelP:",s.relativePoint,"X:",xOfs,"Y:",yOfs)else Print("Failed save for",fTM:GetName())end;if self~=fTM then self:EnableMouse(false)end end
local function OnMouseUp(self,button,...)local fTM=self.frameToMove or self;if not fTM then return end;Print("MouseUp H",self:GetName(),"for",fTM:GetName(),"btn",button);if not fTM.isMoving then local c=GetMouseFocus();if c and c~=self and c:IsMouseEnabled()and c:GetScript("OnMouseUp")then Print("PassClick H->C",c:GetName());c:GetScript("OnMouseUp")(c,button,...)elseif self~=fTM and fTM:IsMouseEnabled()and fTM:GetScript("OnMouseUp")then Print("PassClick H->FTM",fTM:GetName());fTM:GetScript("OnMouseUp")(fTM,button,...)end end end

-- HookProblematicButton
local function HookProblematicButton(pFO,tCN,bRN)if not pFO then Print("HookPB:pFO nil tCN:",tCN);return false end;local pFN=pFO:GetName();Print(pFN,":Attempt hook childByName:",bRN,"(targetN:",tCN,")");local bTH=nil;if pFO.GetChildren then Print(pFN,":IterateChildrenFor'",tCN,"'");for i=1,pFO:GetNumChildren()do local c=select(i,pFO:GetChildren());if c and c:GetName()==tCN then bTH=c;Print(pFN,":FoundChild'",tCN,"'byIter.Obj:",tostring(bTH));break end end else Print(pFN,":ParentNoGetChildrenFor",tCN);return false end;if not bTH then Print(pFN,": ",bRN,"BtnGetName()='",tCN,"'NOT FOUND.");return false end;Print(pFN,": ",tCN," FOUND.T:",type(bTH),"OT:",bTH:GetObjectType());local oOC=bTH:GetScript("OnClick");if oOC then Print(pFN,": ",tCN," PreExistOnClick:",tostring(oOC))else Print(pFN,": ",tCN," NOPreExistOnClick.")end;local nOCH=function(sB,...)Print("!!!!!!!!!! ",pFN,": ",bTH:GetName()or tCN,"BM OnClickHOOKFIRED! !!!!!!!!!!");if type(oOC)=="function"then Print(pFN,": ",bTH:GetName()or tCN,"CallOrigOnClick.");oOC(sB,...)end;if pFO and pFO:IsShown()and pFO.settings and pFO.settings.point and not pFO.isMoving then Print(pFN,": ",bTH:GetName()or tCN,"BM Cmet-ImmApplyPos.");ApplyPosition(pFO);C_Timer.After(0.02,function()if pFO and pFO:IsShown()and not pFO.isMoving and pFO.settings and pFO.settings.point then Print(pFN,": ",bTH:GetName()or tCN,"BM Cmet-FollowUp(0.02s)ApplyPos.");ApplyPosition(pFO)else Print(pFN,": ",bTH:GetName()or tCN,"BM Cmet-FollowUpSKIP.")end end)else Print(pFN,": ",bTH:GetName()or tCN,"BM CNOTmet forApplyPos.")end end;bTH:SetScript("OnClick",nOCH);local cOC=bTH:GetScript("OnClick");if cOC==nOCH then Print(pFN,": ",bTH:GetName()or tCN,"OnClickScriptSUCCESS SETtoBM.");bTH.blizzMoveSpecificHooked=true;return true else Print(pFN,": ",bTH:GetName()or tCN,"OnClickScriptFAILEDset/isTable.Cur:",tostring(cOC));if cOC then bTH.blizzMoveSpecificHooked=true;return true end;return false end end

-- SetMoveHandler
local function SetMoveHandler(frameToMove,handler)if not frameToMove then Print("SMH:fTM nil");return end;local fN=frameToMove:GetName();if not fN then Print("SMH:fTM noName");return end;if not handler then handler=frameToMove end;local hN=handler:GetName();if not hN then Print("SMH:H noName for",fN);return end;if type(db)~="table"then Print("SMH:DB NIL for",fN);return end;Print("SMH:Setup",fN,"with H",hN);local s=db[fN];if not s then s={save=true};for k,vP in pairs(defaultDB[fN]or{})do if k~="save"then s[k]=vP end end;db[fN]=s;Print("SMH:Init DB for",fN)else if s.save==nil then s.save=true end end;frameToMove.settings=s;handler.frameToMove=frameToMove;frameToMove.blizzMoveHandler=handler;if not frameToMove.EnableMouse then Print("SMH:NoEnMse for",fN);return end;frameToMove:EnableMouse(true);frameToMove:SetMovable(true);handler:EnableMouse(true);Print("SMH:",hN,"RgstrDrag LBtn for",fN);handler:RegisterForDrag("LeftButton");if not frameToMove._BlizzMoveHooked then Print("SMH:HookSetMvb/EnMse for",fN,"H:",hN);local function reDrg(hF,dH)Print("ReAppDrgH:",dH:GetName(),"dueToHookOn",hF:GetName());dH:RegisterForDrag("LeftButton");if dH:GetScript("OnDragStart")~=OnDragStart then dH:SetScript("OnDragStart",OnDragStart);dH:SetScript("OnDragStop",OnDragStop);Print("RestoredScr H",dH:GetName())end end;hooksecurefunc(frameToMove,"SetMovable",function(slf,m)if not m and not slf.isMoving then Print("PrvSetMvb(F)",slf:GetName());slf:EnableMouse(true);slf:SetMovable(true);reDrg(slf,slf.blizzMoveHandler or slf)end end);hooksecurefunc(frameToMove,"EnableMouse",function(slf,e)if not e and not slf.isMoving then Print("PrvEnMse(F)",slf:GetName());slf:EnableMouse(true);reDrg(slf,slf.blizzMoveHandler or slf)end end);if handler~=frameToMove then hooksecurefunc(handler,"EnableMouse",function(slf,e)if not e and not(slf.frameToMove and slf.frameToMove.isMoving)then Print("PrvEnMse(F)H",slf:GetName());slf:EnableMouse(true);reDrg(slf.frameToMove or slf,slf)end end)end;frameToMove._BlizzMoveHooked=true end;handler:SetScript("OnDragStart",OnDragStart);handler:SetScript("OnDragStop",OnDragStop);frameToMove:HookScript("OnShow",OnShow);if fN==LFG_FRAME_NAME then hooksecurefunc(frameToMove,"Show",function(slf)Print(slf:GetName(),":ShowH");if slf.isApplyingShowHookPositionLFG or slf.isApplyingPosition then Print(slf:GetName(),":ShowH-skip");return end;slf.isApplyingShowHookPositionLFG=true;Print(slf:GetName(),":ShowH-apply");ApplyPosition(slf);slf.isApplyingShowHookPositionLFG=nil;Print(slf:GetName(),":ShowH-done")end)end;handler:HookScript("OnMouseUp",OnMouseUp);handler:EnableMouseWheel(true);handler:HookScript("OnMouseWheel",OnMouseWheel);
    local lMC=0; frameToMove:SetScript("OnUpdate",function(slf,ela)lMC=lMC+ela; if lMC>=7 then local hdl=slf.blizzMoveHandler or slf;local chg=false; if not slf:IsMovable()then Print("OnUpd:ReSetMvb",slf:GetName());slf:SetMovable(true);chg=true end; if not slf:IsMouseEnabled()then Print("OnUpd:ReEnMse S",slf:GetName());slf:EnableMouse(true);chg=true end; if hdl~=slf and not hdl:IsMouseEnabled()then if not string.find(hdl:GetName()or"","BlizzMoveDrag_")or(slf.isMoving)then Print("OnUpd:ReEnMse H",hdl:GetName());hdl:EnableMouse(true);chg=true end end; if chg then Print("OnUpd:PropsChg",slf:GetName(),",reVer H",hdl:GetName());hdl:RegisterForDrag("LeftButton");if hdl:GetScript("OnDragStart")~=OnDragStart then Print("OnUpd:DragScrMiss H",hdl:GetName(),",reApp.");hdl:SetScript("OnDragStart",OnDragStart);hdl:SetScript("OnDragStop",OnDragStop)end end; lMC=0 end end)
	
    if fN=="AchievementFrame"or fN==LFG_FRAME_NAME or fN=="WorldMapFrame"or fN==PVP_FRAME_NAME or fN=="WorldStateScoreFrame"or fN=="PetStableFrame" or fN==INSPECT_FRAME_NAME then 
        local dFN="BlizzMoveDrag_"..fN;local dF=_G[dFN]or CreateFrame("Frame",dFN,frameToMove);dF:SetAllPoints(frameToMove);dF:SetFrameStrata("MEDIUM");dF:EnableMouse(false);dF:SetMovable(true);dF:RegisterForDrag("LeftButton");dF.frameToMove=frameToMove;dF:SetScript("OnDragStart",OnDragStart);dF:SetScript("OnDragStop",OnDragStop);dF:SetScript("OnMouseUp",OnMouseUp);dF:SetScript("OnMouseWheel",OnMouseWheel);frameToMove.blizzMoveHandler=dF;Print("Created/Assign dragfrm",dFN,"as H for",fN);local cB=_G[fN.."CloseButton"];if cB then cB:SetFrameStrata("HIGH");Print("Raised close strata for",fN)end;
    end
	
    if fN==LFG_FRAME_NAME then Print(fN,":Setup StdTabOnClicks.");for i=1,5 do local tN=LFG_FRAME_NAME.."Tab"..i;local tab=_G[tN];if tab then Print("SMH:Setup StdTab:",tN);hooksecurefunc(tab,"EnableMouse",function(slf,e)if not e and not frameToMove.isMoving then slf:EnableMouse(true);slf:RegisterForDrag("LeftButton");Print("PreventEnMse(F)for",tN)end end);if not tab:GetScript("OnDragStart")then tab:SetScript("OnDragStart",function(slf)Print(tN,"TabDragStart->mainLFG");OnDragStart(frameToMove)end);tab:SetScript("OnDragStop",function(slf)Print(tN,"TabDragStop->mainLFG");OnDragStop(frameToMove)end);tab:RegisterForDrag("LeftButton");Print("Applied drag scripts to",tN)end;tab:HookScript("OnClick",function(tC)local tId=LFG_FRAME_NAME..":Tab"..i;Print(tId,"OnClick.Vis:",tostring(frameToMove and frameToMove:IsShown()),"Mov:",tostring(frameToMove and frameToMove.isMoving));if frameToMove and frameToMove:IsShown()and frameToMove.settings and frameToMove.settings.point and not frameToMove.isMoving then Print(tId,"OnClick-ImmApplyPos.");ApplyPosition(frameToMove);C_Timer.After(0.01,function()if frameToMove and frameToMove:IsShown()and not frameToMove.isMoving and frameToMove.settings and frameToMove.settings.point then Print(tId,"OnClick-FollowUp(0.01s)ApplyPos.");ApplyPosition(frameToMove)else Print(tId,"OnClick-FollowUpSKIP.")end end)else Print(tId,"OnClick-CondNOTmet.")end end)else Print("SMH:StdTabNF-",tN)end end end
	if fN==PVP_FRAME_NAME then for i=1,4 do HookProblematicButton(frameToMove,"PVPFrameTypeButton"..i,"PvP Type"..i)end end
	if fN==PVP_FRAME_NAME then C_Timer.After(0.5,function()local pF=_G[fN];if not pF then Print("DelayedHook:Parent",fN,"NF.");return end;Print(fN,":Attempt DELAYED hook TypeBtns.");for i=1,4 do local bTN="PVPFrameTypeButton"..i;local aH=false;local cB=nil;if pF.GetChildren then for k=1,pF:GetNumChildren()do local c=select(k,pF:GetChildren());if c and c:GetName()==bTN then cB=c;if c.blizzMoveSpecificHooked then aH=true end;break end end end;if cB and not aH then HookProblematicButton(pF,bTN,"PvP Type"..i.."(Delayed)")elseif not cB then Print(fN,":DELAYED-PvPTypeBtn",bTN,"STILL NF.")elseif aH then Print(fN,":DELAYED-PvPTypeBtn",bTN,"already hooked.")end end end)end
end

-- DB Reset
local function resetDB() Print("Resetting positions."); if type(db)~="table"then Print("resetDB: DB NIL"); return end; for k,v_s in pairs(db)do local f=_G[k]; if f and f.settings then f.settings.save=false;local d=f.settings.default;if d and d.p and d.rT and d.rP and d.xOfs and d.yOfs then f:ClearAllPoints();local rTF=_G[d.rT]or UIParent;f:SetPoint(d.p,rTF,d.rP,d.xOfs,d.yOfs);Print("Reset",k,"to def.");if d.scale then f:SetScale(d.scale)end else f:ClearAllPoints();if f.SetUserPlaced then f:SetUserPlaced(false)end;Print("Cleared anchor",k)end;db[k]={save=false}end end; BlizzMoveAscensionDB=db;Print("DB reset complete.");end
-- Options Panel
local function createOptionPanel() optionPanel=CreateFrame("Frame","BlizzMovePanel",UIParent);optionPanel:SetSize(400,150);optionPanel:SetBackdrop({bgFile="Interface/DialogFrame/UI-DialogBox-Background",edgeFile="Interface/DialogFrame/UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=32,insets={left=11,right=12,top=12,bottom=11}});optionPanel:SetPoint("CENTER");optionPanel:Hide();local ti=optionPanel:CreateFontString(nil,"ARTWORK","GameFontNormalLarge");ti:SetPoint("TOPLEFT",16,-16);local v=GetAddOnMetadata("BlizzMoveAscension","Version")or GetAddOnMetadata("BlizzMove","Version")or"vNext";ti:SetText("BlizzMove Ascension "..v);local st=optionPanel:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");st:SetHeight(35);st:SetPoint("TOPLEFT",ti,"BOTTOMLEFT",0,-8);st:SetPoint("RIGHT",optionPanel,-32,0);st:SetNonSpaceWrap(true);st:SetJustifyH("LEFT");st:SetJustifyV("TOP");st:SetText("Reset all window positions.");local rBtn=CreateFrame("Button",nil,optionPanel,"UIPanelButtonTemplate");rBtn:SetSize(120,25);rBtn:SetScript("OnClick",function()StaticPopup_Show("BLIZZMOVE_RESET_CONFIRM_ASC")end);rBtn:SetText("Reset Positions");rBtn:SetPoint("TOPLEFT",st,"BOTTOMLEFT",0,-15);local dEnToggle=CreateFrame("CheckButton","BlizzMoveDebugToggle",optionPanel,"UICheckButtonTemplate");dEnToggle:SetPoint("TOPLEFT",rBtn,"BOTTOMLEFT",0,-10);dEnToggle.text=dEnToggle:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");dEnToggle.text:SetPoint("LEFT",dEnToggle,"RIGHT",2,0);dEnToggle.text:SetText("Enable Debug Logging");dEnToggle:SetChecked(debugEnabled);dEnToggle:SetScript("OnClick",function(s)debugEnabled=s:GetChecked();Print("Debug logging",debugEnabled and"ENABLED"or"DISABLED")end);optionPanel.name="BlizzMove Ascension";InterfaceOptions_AddCategory(optionPanel);Print("Options Panel created.");StaticPopupDialogs["BLIZZMOVE_RESET_CONFIRM_ASC"]={text="Reset all BlizzMove positions?",button1="Yes",button2="Cancel",OnAccept=function()resetDB()end,timeout=0,whileDead=1,hideOnEscape=1,preferredIndex=3}end

-- ╔══════════════════════════╦═════════════════════════════════════════════════════════════════════════════[─]═[□]═[×]═╗
-- ║ General                  ║ Frame Setup                                                                             ║
-- ╚══════════════════════════╩═════════════════════════════════════════════════════════════════════════════════════════╝

local function InitialSetupFrames() Print("InitialSetupFrames: Scheduling frame setups..."); if type(db)~="table"then Print("InitialSetupFrames: DB NIL! Abort.");return end; local frameSetups={}; 
    -- INSPECT_FRAME_NAME is now included in baseFramesToHandle for initial setup attempt
    local baseFramesToHandle={"AscensionCharacterFrame","AscensionSpellbookFrame",LFG_FRAME_NAME,"QuestLogFrame","FriendsFrame","LFGParentFrame","GameMenuFrame","GossipFrame","DressUpFrame","QuestFrame","MerchantFrame","HelpFrame","PlayerTalentFrame","ClassTrainerFrame","MailFrame","BankFrame","VideoOptionsFrame","InterfaceOptionsFrame","LootFrame","LFDParentFrame","LFRParentFrame","TradeFrame",PVP_FRAME_NAME,"WorldStateScoreFrame","PetStableFrame","RaidParentFrame",INSPECT_FRAME_NAME}; 
    for _,fN in ipairs(baseFramesToHandle)do table.insert(frameSetups,{name=fN,handlerName=nil})end; 
    if _G.WorldMapFrame and _G.WorldMapTitleButton then table.insert(frameSetups,{name="WorldMapFrame",handlerName="WorldMapTitleButton"})else Print("InitialSetup: WorldMap/TitleButton NF for sched.")end; 
    local delay=0; for i,sI in ipairs(frameSetups)do C_Timer.After(delay,function()local fTM=_G[sI.name];local hdl=nil;if sI.handlerName then hdl=_G[sI.handlerName]end;if fTM then Print("InitialSetupFrames: Processing",sI.name,"delay",string.format("%.2f",delay));SetMoveHandler(fTM,hdl)else Print("InitialSetupFrames: Frame",sI.name,"NF for delayed setup.")end end);delay=delay+0.02 end;
    Print("InitialSetupFrames: All frame setups scheduled.")
end

local inspectFrameSetupAttempted = false 

local function AttemptInspectFrameSetup(fromEvent)
    fromEvent = fromEvent or "UnknownSource"
    local currentInspectFrame = _G[INSPECT_FRAME_NAME] -- Get current reference
    if currentInspectFrame and currentInspectFrame.blizzMoveSetOnce then
        Print("AttemptInspectFrameSetup from", fromEvent, ": InspectFrame already successfully processed by BlizzMove earlier.")
        return 
    end
    -- Do not set inspectFrameSetupAttempted to true here, allow timers to re-evaluate if needed,
    -- the .blizzMoveSetOnce on the frame itself will prevent re-processing if successful.

    Print("AttemptInspectFrameSetup from", fromEvent, ": Trying to set up InspectFrame.")
    if currentInspectFrame then
        Print("AttemptInspectFrameSetup from", fromEvent, ": InspectFrame FOUND. Calling SetMoveHandler.")
        SetMoveHandler(currentInspectFrame)
        currentInspectFrame.blizzMoveSetOnce = true 
    else
        Print("AttemptInspectFrameSetup from", fromEvent, ": InspectFrame STILL NOT FOUND this attempt.")
    end
end

local function OnEvent(self,event,arg1,arg2)
	if event=="VARIABLES_LOADED"then Print("Event:VARIABLES_LOADED");db=BlizzMoveAscensionDB; if type(db)~="table"then Print("DB NIL, init defaults.");db={};for k,vT in pairs(defaultDB)do if type(vT)=="table"then db[k]={};for iK,iV in pairs(vT)do db[k][iK]=iV end else db[k]=vT end end else Print("DB loaded. Verify defaults.");for fK,fVT in pairs(defaultDB)do if type(fVT)=="table"then if type(db[fK])~="table"then Print("Re-init frameDB",fK);db[fK]={};for iK,iV in pairs(fVT)do db[fK][iK]=iV end else for sK,sV in pairs(fVT)do if db[fK][sK]==nil then db[fK][sK]=sV;Print("Added subK",sK,"for",fK)end end end elseif db[fK]==nil then Print("Added global setting",fK);db[fK]=fVT end end end; BlizzMoveAscensionDB=db;InitialSetupFrames();if not optionPanel then createOptionPanel()end;InterfaceOptionsFrame:HookScript("OnShow",function()if not optionPanel then createOptionPanel()end end);frame:UnregisterEvent("VARIABLES_LOADED");Print("VARIABLES_LOADED done.")
	elseif event=="PLAYER_LOGIN"then Print("Event:PLAYER_LOGIN (DB on VAR_LOAD)");if type(db)~="table"then Print("PLAYER_LOGIN: DB still NIL!")end;frame:RegisterEvent("ADDON_LOADED");frame:UnregisterEvent("PLAYER_LOGIN")
	elseif event=="ADDON_LOADED"then Print("Event:ADDON_LOADED - Addon Name:",arg1);if type(db)~="table"then Print("ADDON_LOADED: DB NIL, skip",arg1);return end; 
        if arg1=="Ascension_Manastorm"then Print("!!!!!!!!!! ADDON_LOADED Proc: Ascension_Manastorm block !!!!!!!!!!");local lfgF=_G[LFG_FRAME_NAME];if lfgF then Print("ADDON_LOADED(Ascension_Manastorm):Found LFG F:",lfgF:GetName(),".Hook CatBtns by iter children.");HookProblematicButton(lfgF,"AscensionLFGFrameButton1","LFG DF Btn(Child,ManastormLoad)");HookProblematicButton(lfgF,"AscensionLFGFrameButton2","LFG Manastorm Btn(Child,ManastormLoad)")else Print("ADDON_LOADED(Ascension_Manastorm):",LFG_FRAME_NAME,"NF when Manastorm loaded.")end 
        elseif arg1 == "Ascension_InspectUI" then -- Changed from Blizzard_InspectUI
            Print("!!!!!!!!!! ADDON_LOADED Processing: Ascension_InspectUI specific block entered !!!!!!!!!!") 
            if not inspectFrameSetupAttempted then 
                 AttemptInspectFrameSetup("Ascension_InspectUI immediate") 
                 C_Timer.After(1.0, function() AttemptInspectFrameSetup("Ascension_InspectUI 1s_Timer") end)
                 C_Timer.After(3.0, function() AttemptInspectFrameSetup("Ascension_InspectUI 3s_Timer") end)
                 C_Timer.After(5.0, function() AttemptInspectFrameSetup("Ascension_InspectUI 5s_Timer") end)
                 inspectFrameSetupAttempted = true -- Set flag after timers are scheduled to prevent re-scheduling them
            else
                Print("Ascension_InspectUI loaded, but setup attempts already made/scheduled from a previous trigger.")
                AttemptInspectFrameSetup("Ascension_InspectUI re-check") 
            end
        end; 
        local fHSL={Blizzard_GuildBankUI="GuildBankFrame",Blizzard_TradeSkillUI="TradeSkillFrame",Blizzard_ItemSocketingUI="ItemSocketingFrame",Blizzard_BarbershopUI="BarberShopFrame",Blizzard_MacroUI="MacroFrame",Blizzard_TalentUI="PlayerTalentFrame",Blizzard_Calendar="CalendarFrame",Blizzard_TrainerUI="ClassTrainerFrame",Blizzard_BindingUI="KeyBindingFrame",Blizzard_AuctionUI="AuctionFrame",Blizzard_GuildUI="GuildFrame",Blizzard_LookingForGuildUI="LookingForGuildFrame",Blizzard_VoidStorageUI="VoidStorageFrame",Blizzard_ItemAlterationUI="TransmogrifyFrame",Blizzard_EncounterJournal="EncounterJournal",Blizzard_ArchaeologyUI="ArchaeologyFrame"}
		if fHSL[arg1]then local fTL_Name=fHSL[arg1]; local fTL=_G[fTL_Name];if fTL then SetMoveHandler(fTL)else Print("ADDON_LOADED:F",fTL_Name,"NF for",arg1)end 
        elseif arg1=="Blizzard_GlyphUI" and _G.SpellBookFrame and _G.GlyphFrame then SetMoveHandler(_G.SpellBookFrame,_G.GlyphFrame)
        elseif arg1=="Blizzard_AchievementUI" and _G.AchievementFrame and _G.AchievementFrameHeader then SetMoveHandler(_G.AchievementFrame,_G.AchievementFrameHeader)
        elseif arg1=="Blizzard_ReforgingUI" and _G.ReforgingFrame and _G.ReforgingFrameInvisibleButton then SetMoveHandler(_G.ReforgingFrame,_G.ReforgingFrameInvisibleButton)
		elseif arg1=="ElvUI"then Print("ElvUI loaded.Re-apply keyH.");if _G.AchievementFrame and _G.AchievementFrameHeader then SetMoveHandler(_G.AchievementFrame,_G.AchievementFrameHeader)end;if _G.AscensionLFGFrame then SetMoveHandler(_G.AscensionLFGFrame)end;if _G.WorldMapFrame and _G.WorldMapTitleButton then SetMoveHandler(_G.WorldMapFrame,_G.WorldMapTitleButton)end;if _G.PVPFrame then SetMoveHandler(_G.PVPFrame)end;if _G.WorldStateScoreFrame then SetMoveHandler(_G.WorldStateScoreFrame)end;if _G.PetStableFrame then SetMoveHandler(_G.PetStableFrame)end;if _G[INSPECT_FRAME_NAME] then AttemptInspectFrameSetup("ElvUI Load") end 
        end
	end
end
frame:SetScript("OnEvent",OnEvent);frame:RegisterEvent("VARIABLES_LOADED");frame:RegisterEvent("PLAYER_LOGIN")

-- Toggle and Debug Functions
BlizzMove={};function BlizzMove:Toggle(hO)local h=hO or GetMouseFocus();if not h or h:GetName()=="WorldFrame"then Print("BMToggle:Invalid");return end;local fTM=h;local i=0;local lP=h;while lP and lP~=UIParent and i<100 do fTM=lP;lP=lP:GetParent();i=i+1 end;if h and fTM then if h:GetScript("OnDragStart")==OnDragStart then h:SetScript("OnDragStart",nil);h:SetScript("OnDragStop",nil);Print("F:",fTM:GetName(),"UNLOCKED by BM (H:",h:GetName(),")")else Print("F:",fTM:GetName(),"to move by BM H:",h:GetName());SetMoveHandler(fTM,h)end else Print("BMToggle:Err parent NF")end end
function BlizzMove:ToggleDebug()debugEnabled=not debugEnabled;Print("Debug",debugEnabled and "ENABLED"or"DISABLED");if _G.BlizzMoveDebugToggle then _G.BlizzMoveDebugToggle:SetChecked(debugEnabled)end;if _G.BlizzMoveAntiDriftToggle and type(db)=="table"then _G.BlizzMoveAntiDriftToggle:SetChecked(db.enableAntiDrift or false)end end
SLASH_BLIZZMOVE1="/blizzmove";SLASH_BLIZZMOVE2="/bmove";SlashCmdList["BLIZZMOVE"]=function(m)local c=m and string.lower(string.trim(m))or"";if c=="debug"then BlizzMove:ToggleDebug()elseif c=="reset"then StaticPopup_Show("BLIZZMOVE_RESET_CONFIRM_ASC")elseif c=="toggle"then BlizzMove:Toggle()else Print("Use: /bmove [debug|reset|toggle]")end end
BINDING_HEADER_BLIZZMOVE="BlizzMove Ascension";BINDING_NAME_MOVEFRAME="Move/Lock a Frame (BlizzMove)"

-- ╔══════════════════════════╦═════════════════════════════════════════════════════════════════════════════ Change Log
-- ║ Changelog                ║ Changelog                                                                               ║
-- ╚══════════════════════════╩═════════════════════════════════════════════════════════════════════════════════════════╝
-- v1.0.42 (User Modifications based on AI suggestions - Full Code Base)
-- - InspectFrame Handling:
--   - Re-added INSPECT_FRAME_NAME to InitialSetupFrames' baseFramesToHandle for an early setup attempt.
--   - ADDON_LOADED handler for "Ascension_InspectUI" (corrected from "Blizzard_InspectUI") now triggers AttemptInspectFrameSetup.
--   - AttemptInspectFrameSetup uses timed retries (1s, 3s, 5s) if InspectFrame is not found immediately.
--   - Logic for 'inspectFrameSetupAttempted' and 'inspectFrame.blizzMoveSetOnce' flags refined to allow timers 
--     on first relevant ADDON_LOADED event, and re-checks on subsequent related events (like ElvUI load).
-- - All other v1.0.38 improvements maintained.
--
-- v1.0.40, v1.0.38 ... (Older changelogs preserved)