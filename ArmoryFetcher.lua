
DEBUG_LEVEL = 2;--0 Low info --1 Medium info --2 very spammy

function ArmoryFetcher_OnLoad()

	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PLAYER_LOGOUT");
	this:RegisterEvent("UNIT_COMBAT");
	this:RegisterEvent("TRADE_SKILL_SHOW");

	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("ArmoryFetcher v".."0.1".." loaded");
	end
	SlashCmdList["ARMORYFETCHER"] = AF_SlashHandler;
	SLASH_ARMORYFETCHER1 = "/armoryfetcher"; -- Fixed by Aingnale@WorldOfWar
	SLASH_ARMORYFETCHER2 = "/af";
end

LAST_SCAN = GetTime();
LAST_TOGGLE = GetTime();
AUTO_TOGGLE = false;

function ArmoryFetcher_OnUpdate()
	--AF_Print("Time is:"..date("%Y-%m-%d", time()));
	if(GetTime() - LAST_TOGGLE > 1 and AUTO_TOGGLE == true) then
		local _, _, script, _ = GetMacroInfo( 2 );
		RunScript(script);
		--AF_Debug("Auto Toggle");
		--TargetNearestFriend();
		LAST_TOGGLE = GetTime();
	end
	
	if(GetTime() - LAST_SCAN > 2) then
		--AF_Debug("Scanning Party/Raid", 2);
		for i=1, 40, 1 do
			local unitid = "raid"..i;
			if(CheckInteractDistance(unitid, 1) == 1) then
				DumpInspect(unitid);
				AF_Debug("Found from raid", 2);
			end
		end
		
		for i=1, 4, 1 do
			local unitid = "party"..i;
			if(CheckInteractDistance(unitid, 1) == 1) then
				DumpInspect(unitid);
				AF_Debug("Found from party", 2);
			end
		end
		LAST_SCAN = GetTime();
	end
end

FirstRun = true;
function ArmoryFetcher_OnEvent(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
	if(event == "VARIABLES_LOADED") then
		AF_Print("Loaded");
	elseif(event =="ADDON_LOADED" and arg1 == "ArmoryFetcher") then
		if(ArmoryFetcherPlayers == nil) then
			ArmoryFetcherPlayers = {};
			AF_Print("First runtime");
		end

	elseif(event =="PLAYER_LOGOUT") then
	
	elseif(event == "TRADE_SKILL_SHOW") then
	
	elseif(event == "PLAYER_TARGET_CHANGED") then
		DumpInspect("target");
	elseif(event == "UPDATE_MOUSEOVER_UNIT") then
		DumpInspect("mouseover");
	end
end

function HonorDump(unitid)
	PVP = {};
	todayHK, todayDK, yesterdayHK, yesterdayDK, thisweekHK, thisweekHonor, lastweekHK, lastweekHonor, lastweekStanding, lifetimeHK, lifetimeDK, lifetimeHighestRank = GetInspectHonorData();
	PVP.todayHK = todayHK;
	PVP.todayDK = todayDK;
	PVP.yesterdayHK = yesterdayHK;
	PVP.yesterdayDK = yesterdayDK;
	PVP.thisweekHK = thisweekHK;
	PVP.thisweekHonor = thisweekHonor;
	PVP.lastweekHK = lastweekHK;
	PVP.lastweekHonor = lastweekHonor;
	PVP.lastweekStanding = lastweekStanding;
	PVP.lifetimeHK = lifetimeHK;
	PVP.lifetimeDK = lifetimeDK;
	PVP.lifetimeHighestRank = lifetimeHighestRank;
	return PVP;
end

function GuildDump(unitid)
	guildName, guildRankName, guildRankIndex = GetGuildInfo(unitid);
	guild = {};
	guild.guildName = "";
	guild.guildRankName = "";
	guild.guildRankIndex = -1;
	if(guildName ~= nil) then
		guild.guildName = guildName;
		guild.guildRankName = guildRankName;
		guild.guildRankIndex = guildRankIndex;
	end
	return guild;
end

function DumpInspect(unitid)
	if(CheckInteractDistance(unitid, 1) == 1) then
	faction = UnitFactionGroup(unitid);
	PlayerFaction = UnitFactionGroup("player");
	if(faction ~= nil and faction == PlayerFaction and UnitIsPlayer(unitid) ~= nil) then
		NotifyInspect(unitid);
		AF_Debug("Recorded Name:"..name.." level: "..level, 2);
		name = UnitName(unitid);
		level = UnitLevel(unitid);
		realm = GetCVar("realmName");
		if(ArmoryFetcherPlayers[realm] == nil) then
			realm = GetCVar("realmName");
			ArmoryFetcherPlayers[realm] = {};
		end
		if(ArmoryFetcherPlayers[realm][faction] == nil) then
			faction = UnitFactionGroup("player");
			ArmoryFetcherPlayers[realm][faction] = {};
		end
		ArmoryFetcherPlayers[realm][faction][name] = {};
		ArmoryFetcherPlayers[realm][faction][name]["Guild"] = GuildDump(unitid);
		ArmoryFetcherPlayers[realm][faction][name]["PVP"] = HonorDump(unitid);
		ArmoryFetcherPlayers[realm][faction][name]["lastscan"] = time();
		ArmoryFetcherPlayers[realm][faction][name]["level"] = level;
		--ArmoryFetcherPlayers[realm][faction][name]["name"] = name;
		
		for Id, Type in pairs(ItemSlots) do
			local Item = GetInventoryItemLink(unitid, Id);
			ArmoryFetcherPlayers[realm][faction][name][Id] = nil;
			if(Item ~= nil) then
				ArmoryFetcherPlayers[realm][faction][name][Id] = Item;
			else
				ArmoryFetcherPlayers[realm][faction][name][Id] = "";
			end
		end
	end
	end
end

function tprint (tbl, indent)
	indent = 0 or indent;
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      AF_Print(formatting)
      tprint(v, indent+1)
	elseif(type(v) == "userdata") then
		AF_Print(formatting..tostring(v));
    else
      AF_Print(formatting .. v)
    end
  end
end

function AF_SlashHandler(msg)
	if (msg=="show" or msg=="hide") then msg = ""; end
	if (not msg or msg=="") then
		--Base command
		AF_Print("SlashCommand Used");
		
	end
	if(msg == "auto") then
		if(AUTO_TOGGLE == false) then
			AUTO_TOGGLE = true;
			AF_Print("Auto toggle activated");
		else
			AUTO_TOGGLE = false;
			AF_Print("Auto toggle deactivated");
		end
	end
	if(msg == "get") then
		--AF_Print(getglobal("TradeSkillSkillName"):GetText());
		AF_Print(GetMouseFocus():GetName());
		AF_Print(GetMouseFocus():GetParent());
		AF_Print(GetMouseFocus():GetText());
	end
	
	if(msg == "dump") then
		local kids = GetMouseFocus():GetChildren();
		for k, v in pairs(kids) do
			--for v1 in v do
			--	AF_Print(v1);
			--end
			local t = getmetatable(v);
			for k, v in pairs(t) do
				AF_Print(k);
			end
		end
	end
	
	
	
	if(msg=="s") then
		DumpInspect("mouseover");
		TargetNearestFriend();
	end
	
	if(msg == "clear") then
		ArmoryFetcherPlayers = {};
		AF_Print("Cleared Unit cache");
	end
	
	if(msg == "test") then
		--guildName, guildRankName, guildRankIndex = GetGuildInfo("target");
		--AF_Print(string.format("GN: %s GR: %s GRI: %s",guildName,guildRankName,guildRankIndex));
		PVP = HonorDump("target");
		for k, v in pairs(PVP) do
			AF_Print(k.." "..tostring(v));
		end
	end
	
	if(msg =="t") then
		realm = GetCVar("realmName");
		faction = UnitFactionGroup("player");
		for k, v in pairs(ArmoryFetcherPlayers[realm][faction]) do
			for k1, v1 in pairs(ArmoryFetcherPlayers[realm][faction][k]) do
			local slot = "";
			if(ItemSlots[k1] ~= nil) then
				slot = ItemSlots[k1];
			end
				AF_Print(k.." - "..slot.." - "..tostring(v1));
			end
		end
	end
end

function AF_Debug(message, level)--0 Low info --1 Medium info --2 very spammy
	level = 2 or level;
	if(DEBUG_LEVEL >= level) then
		DEFAULT_CHAT_FRAME:AddMessage("[AF-D]: "..message);
	end
end

function AF_Print(message)
		DEFAULT_CHAT_FRAME:AddMessage("[AF]: "..message);
end