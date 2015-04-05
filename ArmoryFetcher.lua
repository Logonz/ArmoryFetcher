
function ArmoryFetcher_OnLoad()

	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_TARGET_CHANGED");
	this:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PLAYER_LOGOUT");

	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("ArmoryFetcher v".."0.1".." loaded");
	end
	SlashCmdList["ARMORYFETCHER"] = AF_SlashHandler;
	SLASH_ARMORYFETCHER1 = "/armoryfetcher"; -- Fixed by Aingnale@WorldOfWar
	SLASH_ARMORYFETCHER2 = "/af";
end

function ArmoryFetcher_OnEvent()
	if(event == "VARIABLES_LOADED") then
		AF_Print("Loaded");
	elseif(event =="ADDON_LOADED" and arg1 == "ArmoryFetcher") then
		if(ArmoryFetcherPlayers == nil) then
			ArmoryFetcherPlayers = {};
			AF_Print("First runtime");
		end
	elseif(event =="PLAYER_LOGOUT") then
	
	elseif(event == "PLAYER_TARGET_CHANGED") then
		AF_Print("Target Changed");
		DumpInspect("target");
	elseif(event == "UPDATE_MOUSEOVER_UNIT") then
		AF_Print("twoo");
		--DumpInspect("mouseover");
	end
end

function DumpInspect(unitid)
	if(CheckInteractDistance(unitid, 1) == 1) then
	faction = UnitFactionGroup(unitid);
	name = UnitName(unitid);
	level = UnitLevel(unitid);
	realm = GetCVar("realmName");
	AF_Print("Faction:"..faction.." Name:"..name.." level: "..level.." Realm: "..realm);
	if(faction ~= nil) then
		if(ArmoryFetcherPlayers[realm] == nil) then
			realm = GetCVar("realmName");
			ArmoryFetcherPlayers[realm] = {};
		end
		if(ArmoryFetcherPlayers[realm][faction] == nil) then
			faction = UnitFactionGroup("player");
			ArmoryFetcherPlayers[realm][faction] = {};
		end
		ArmoryFetcherPlayers[realm][faction][name] = {};
		ArmoryFetcherPlayers[realm][faction][name]["level"] = level;
		ArmoryFetcherPlayers[realm][faction][name]["name"] = name;
		
		for Id, Type in pairs(ItemSlots) do
			local Item = GetInventoryItemLink(unitid, Id);
			ArmoryFetcherPlayers[realm][faction][name][Id] = nil;
			if(Item ~= nil) then
				ArmoryFetcherPlayers[realm][faction][name][Id] = Item;
			else
				ArmoryFetcherPlayers[realm][faction][name][Id] = "empty";
			end
		end
	end
	end
end

function AF_SlashHandler(msg)
	if (msg=="show" or msg=="hide") then msg = ""; end
	if (not msg or msg=="") then
		--Base command
		btm_Print("SlashCommand Used");
	end
	if(msg=="s") then
		DumpInspect("mouseover");
		TargetNearestFriend();
	end
	if(msg =="t") then
		realm = GetCVar("realmName");
		faction = UnitFactionGroup("player");
		for k, v in pairs(ArmoryFetcherPlayers[realm][faction]) do
			for k1, v1 in pairs(ArmoryFetcherPlayers[realm][faction][k]) do
				AF_Print(k.." "..tostring(v1));
			end
		end
	end
end

function AF_Print(message)
		DEFAULT_CHAT_FRAME:AddMessage("[ArmoryFetcher]: "..message);
end