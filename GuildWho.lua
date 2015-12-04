﻿GuildWho_Saved = {}
GuildWho_Stats = {}
GuildWho_Kicked = {}

function GUILDWHO_OnLoad()
  gwhobuild = "v0.0.6";
  this:RegisterEvent("CHAT_MSG_SYSTEM")
	--arg1    The content of the chat message.
  this:RegisterEvent("CHAT_MSG_GUILD")
	--arg1    Message that was sent 
	--arg2    Author 
	--arg3    Language that the message was sent in 
	--arg11   Chat lineID 
	--arg12   Sender GUID       
	this:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
	--arg1    The full body of the achievement broadcast message. 
	--arg2, arg5    Guildmember Name 
	--arg11    Chat lineID 
	--arg12    Sender GUID 			
	--slash commands
	SlashCmdList["GWHO"] = GUILDWHO_Command;
	SLASH_GWHO1 = "/guildwho";
	SLASH_GWHO2 = "/gwho";
	print("|cffffcc00GuildWho", gwhobuild,"loaded!");
end

local function tContains(table, item)
       local index = 1;
       while table[index] do
               if ( item == table[index] ) then
                       if (msgsys == true) then
                       	sysindex = index;
                       	--print("|cffffcc00GuildWho", gwhobuild,"Debug: System Index Updated,", sysindex);
                       elseif (msgguild == true) then
                       	guildindex = index;
                       	--print("|cffffcc00GuildWho", gwhobuild,"Debug: Guild Index Updated,", guildindex);
                       elseif (msgguildach == true) then
                       	guildachindex = index;
                       	--print("|cffffcc00GuildWho", gwhobuild,"Debug: GuildAch Index Updated,", guildachindex);
                       elseif (msglocal == true) then
                       	localindex = index;
                       	--print("|cffffcc00GuildWho", gwhobuild,"Debug: Local Index Updated,", localindex);
                       end
                       return 1;
               end
               index = index + 1;
       end
       return nil;
end

function GUILDWHO_GetCmd(msg)
if msg then
	local a=(msg); --contiguous string of non-space characters
	if a then
		return msg
	else	
		return "";
	end
end
end

function GUILDWHO_ShowHelp()
print("|cffffcc00GuildWho", gwhobuild,"usage:");
print("|cffffcc00'/guildwho {guild_member}' or '/gwho {guild_member}'");
print("|cffffcc00'/guildwho stats' or '/gwho stats'");
print("|cffffcc00'/guildwho stats {guild_member}' or '/gwho stats {guild_member}'");
print("|cffffcc00Manual Database submission:");
print("|cffffcc00'/guildwho m {guild_member} mm/dd/yy mm/dd/yy' or '/gwho m {guild_member} mm/dd/yy mm/dd/yy'");
end

function GUILDWHO_Command(msg)
   local Cmd, SubCmd = GUILDWHO_GetCmd(msg);
   if (Cmd == "")then
      GUILDWHO_ShowHelp();
   elseif (strsub(Cmd,1,2) == "m ")then
      --print("|cffffcc00'(m)anual trigger!");
      local n=0;
      for token in string.gmatch(Cmd, "[^%s]+") do
         -- print(token)
         n=n + 1;
         if (n == 2)then
            PlayerName = token;
         elseif (n == 3)then
            JoinDate = token;
         elseif (n == 4)then
            RankDate = token;
         end
      end
      if (tContains(GuildWho_Saved,PlayerName) == 1) then
      print("|cffffcc00GuildWho", gwhobuild," Player Name:", PlayerName,"is already in the database.");
      else
      print("|cffffcc00GuildWho", gwhobuild," Player Name:", PlayerName,"Join Date: ", JoinDate, "Rank Changed: ", RankDate);
			tinsert(GuildWho_Saved,getn(GuildWho_Saved),PlayerName) -- character name
			tinsert(GuildWho_Saved,getn(GuildWho_Saved),JoinDate)   -- join date
			tinsert(GuildWho_Saved,getn(GuildWho_Saved),RankDate)   -- rank change date      
			print("|cffffcc00GuildWho", gwhobuild,"Data stored. use /rl or logout/quit/camp to commit to disk.");
			end
   elseif (strsub(Cmd,1,6) == "stats ")then
      gsPlayerName = strsub(Cmd,7,strlen(Cmd))
      --print("|cffffcc00'stats trigger!", gsPlayerName);
      GUILDWHO_CheckStats(gsPlayerName)
   else
   GUILDWHO_Lookup(Cmd);
   end
end

function GUILDWHO_OnEvent(event)
    if(event == "CHAT_MSG_SYSTEM") then
    	msgsys = true
    	if(string.find(arg1,"has joined the guild."))then
	    	GUILDWHO_Joined();
	    elseif(string.find(arg1,"has promoted"))then
	    	GUILDWHO_RankChange();
	    elseif(string.find(arg1,"has demoted"))then
	    	GUILDWHO_RankChange();
	    elseif(string.find(arg1,"has been kicked out of the guild by"))then
	    	GUILDWHO_RankChange();
		else
			--print("|cffffcc00GuildWho", gwhobuild,"Debug: (System Msg)", arg1);
		end
	end
	msgsys = false
    if(event == "CHAT_MSG_GUILD") then
		  local guild, realm = (GetGuildInfo("player")), GetRealmName()
    	msgguild = true
			if (GuildWho_Stats[realm] == nil) then
			GuildWho_Stats[realm] = {}
			end
			if (GuildWho_Stats[realm][guild] == nil) then
			GuildWho_Stats[realm][guild] = {}
			end
			if(GuildWho_Stats[realm][guild][arg2] == nil) then
			GuildWho_Stats[realm][guild][arg2] = {}
			end
			if(GuildWho_Stats[realm][guild][arg2]["Chat Lines"] == nil) then
			GuildWho_Stats[realm][guild][arg2]["Chat Lines"] = {}
			end
			if(GuildWho_Stats[realm][guild][arg2]["Achievements"] == nil) then
			GuildWho_Stats[realm][guild][arg2]["Achievements"] = {}
			end
			if(GuildWho_Stats[realm][guild][arg2]["Chat Lines"]["value"] == nil) then
			GuildWho_Stats[realm][guild][arg2]["Chat Lines"]["value"] = {}
			end
			if(GuildWho_Stats[realm][guild][arg2]["Achievements"]["value"] == nil) then
			GuildWho_Stats[realm][guild][arg2]["Achievements"]["value"] = {}
			end
    	--print("|cffffcc00GuildWho", gwhobuild,"Debug: (Guild Msg)", arg2, arg1);
      if (GuildWho_Stats[realm][guild][arg2]["Chat Lines"]["value"]) then
	      --print("|cffffcc00GuildWho", gwhobuild,"Debug: (Guild Msg, Database Found): Player Name:", arg2, GuildWho_Stats[realm][guild][arg2]["Chat Lines"]["value"]);
	      local gchatlines = GuildWho_Stats[realm][guild][arg2]["Chat Lines"]["value"];
				if (gchatlines == nil or type(gchatlines) == "table") then
					print("gchatlines is nil or table")
					gchatlines = 0
				end
	      local gchatlines = gchatlines + 1
				GuildWho_Stats[realm][guild][arg2]["Chat Lines"]["value"] = gchatlines
				--print("|cffffcc00GuildWho", gwhobuild,"Debug: (Guild Msg, just after gchatline increment)", arg2,GuildWho_Stats[realm][guild][arg2],"Chat Lines:",GuildWho_Stats[realm][guild][arg2]["Chat Lines"]["value"]);
	      --print("|cffffcc00GuildWho", gwhobuild,"Debug: Guild Member: ", arg2, "Chat lines: ", GuildWho_Stats[realm][guild][arg2]["Chat Lines"]["value"], "Achievements seen: ", GuildWho_Stats[realm][guild][arg2]["Achievements"]["value"]);
      else
	      GuildWho_Stats[realm][guild][arg2]["Chat Lines"]["value"] = 0
	      --print("|cffffcc00GuildWho", gwhobuild,"Debug (Guild Msg, Not Found):", arg2, GuildWho_Stats[realm][guild][arg2]);
				GuildWho_Stats[realm][guild][arg2]["Chat Lines"]["value"] = 1 -- New entry, 1 chat lines
				--print("|cffffcc00GuildWho", gwhobuild,"Debug (Guild Msg, New chat entry. Line 1):", arg2,GuildWho_Stats[realm][guild][arg2]["Chat Lines"]["value"]);
				GuildWho_Stats[realm][guild][arg2]["Achievements"]["value"] = 0 -- New entry, 0 achievements
				--print("|cffffcc00GuildWho", gwhobuild,"Debug (Guild Msg, New chat entry. Achievement stub, 0)::", arg2,GuildWho_Stats[realm][guild][arg2]["Achievements"]["value"]);
				--print("|cffffcc00GuildWho", gwhobuild,"Data stored. use /rl or logout/quit/camp to commit to disk.");    	
    	end
    	msgguild = false
    end
    if(event == "CHAT_MSG_GUILD_ACHIEVEMENT") then
    	msgguildach = true
			local gPlayerName = arg2
		  local guild, realm = (GetGuildInfo("player")), GetRealmName()
			if (GuildWho_Stats[realm] == nil) then
			GuildWho_Stats[realm] = {}
			end
			if (GuildWho_Stats[realm][guild] == nil) then
			GuildWho_Stats[realm][guild] = {}
			end
			if(GuildWho_Stats[realm][guild][gPlayerName] == nil) then
			GuildWho_Stats[realm][guild][gPlayerName] = {}
			end
			if(GuildWho_Stats[realm][guild][gPlayerName]["Chat Lines"] == nil) then
			GuildWho_Stats[realm][guild][gPlayerName]["Chat Lines"] = {}
			end
			if(GuildWho_Stats[realm][guild][gPlayerName]["Achievements"] == nil) then
			GuildWho_Stats[realm][guild][gPlayerName]["Achievements"] = {}
			end
			if(GuildWho_Stats[realm][guild][gPlayerName]["Chat Lines"]["value"] == nil) then
			GuildWho_Stats[realm][guild][gPlayerName]["Chat Lines"]["value"] = {}
			end
			if(GuildWho_Stats[realm][guild][gPlayerName]["Achievements"]["value"] == nil)then
			GuildWho_Stats[realm][guild][gPlayerName]["Achievements"]["value"] = {}
			end
    	--print("|cffffcc00GuildWho", gwhobuild,"Debug: (Guild Ach)", arg2, gPlayerName);
      if (GuildWho_Stats[realm][guild][gPlayerName]["Achievements"]) then
	      --print("|cffffcc00GuildWho", gwhobuild,"Debug: (Guild Ach, Database Found): Player Name:", arg2, GuildWho_Stats[realm][guild][arg2]);      
	      local gachievements = GuildWho_Stats[realm][guild][gPlayerName]["Achievements"]["value"]
	      if (gachievements == nil or type(gachievements) == "table") then
	      	--print("gachievements is definately nil or a table")
	      	gachievements = 0
	      end
	      local gachievements = gachievements + 1
				GuildWho_Stats[realm][guild][gPlayerName]["Achievements"]["value"] = gachievements
	      --print("|cffffcc00GuildWho", gwhobuild,"Debug: (Guild Ach, just after gchatline increment)", arg2,GuildWho_Stats[realm][guild][gPlayerName],"Chat Lines:",GuildWho_Stats[realm][guild][gPlayerName]["Chat Lines"]["value"]);
	      --print("|cffffcc00GuildWho", gwhobuild,"Debug: Guild Member: ", gPlayerName, "Chat lines: ", GuildWho_Stats[realm][guild][gPlayerName]["Chat Lines"]["value"], "Achievements seen: ", GuildWho_Stats[realm][guild][gPlayerName]["Achievements"]["value"]);
      else
	      GuildWho_Stats[realm][guild][gPlayerName]["Achievements"]["value"] = 0
	      --print("|cffffcc00GuildWho", gwhobuild,"Debug (Guild Msg, Not Found):", gPlayerName, GuildWho_Stats[realm][guild][gPlayerName]);
				GuildWho_Stats[realm][guild][gPlayerName]["Chat Lines"]["value"] = 0 -- New entry, 0 chat lines
				--print("|cffffcc00GuildWho", gwhobuild,"Debug (Guild Ach, New Achievement. 0 Chat Lines):", arg2,GuildWho_Stats[realm][guild][gPlayerName]["Chat Lines"]["value"]);
				GuildWho_Stats[realm][guild][gPlayerName]["Achievements"]["value"] = 1 -- New entry, 1 achievements
				--print("|cffffcc00GuildWho", gwhobuild,"Debug (Guild Ach, New Achievement, 1):", arg2,GuildWho_Stats[realm][guild][gPlayerName]["Achievements"]["value"]);
    	end
    msgguildach = false
    end
end

function GUILDWHO_Joined()
   if(string.find(arg1,"has joined the guild.")) then
		--print(strsub(arg1,1,strlen(arg1)-22),date("%m/%d/%y"),date("%m/%d/%y"))
		derp = (strsub(arg1,1,strlen(arg1)-22))
		if (tContains(GuildWho_Saved,derp) == 1) then
			print("|cffffcc00GuildWho", gwhobuild," ", derp, " is already in the database.")
		else
		local JIndex = table.getn(GuildWho_Saved)
		tinsert(GuildWho_Saved,JIndex,derp)             -- character name
		tinsert(GuildWho_Saved,JIndex + 1,date("%m/%d/%y")) -- join date
		tinsert(GuildWho_Saved,JIndex + 2,date("%m/%d/%y")) -- rank change date
		end
	end
end

function GUILDWHO_Lookup(PlayerName)
	--print("GuildWho", gwhobuild,"Debug: Lookup fired!");
	msglocal = true
	if (tContains(GuildWho_Saved,PlayerName) == 1) then
		JDIndex = localindex + 1
		RDIndex = localindex + 2
		print("|cffffcc00GuildWho", gwhobuild);
		print("|cffffcc00Guild Member:  ", PlayerName);
		print("|cffffcc00Joined:              ", GuildWho_Saved[JDIndex]);
		print("|cffffcc00Rank Changed: ", GuildWho_Saved[RDIndex]);
	else
		print("|cffffcc00GuildWho", gwhobuild," ", PlayerName, " is not in the database.");
	end
	--print("|cffffcc00GuildWho", gwhobuild,"Debug: GuildWho_Kicked checking...");
	if (tContains(GuildWho_Kicked,PlayerName) == 1) then
	--print("|cffffcc00GuildWho", gwhobuild,"Debug: GuildWho_Kicked[index-1] = ", GuildWho_Kicked[localindex - 1])
   if (string.find(GuildWho_Kicked[localindex - 1],"/"))then
   	local d=d; -- do something that is not nothing, but has no purpose :)
   else
   	print("|cffff0000Kicked by", GuildWho_Kicked[localindex + 2],"on",GuildWho_Kicked[localindex + 1]);
	 end
	end
	msglocal = false
end

function GUILDWHO_RankChange()
	msgsys = true
	-- arg1="Datmage has promoted Rodd to Senior Member.";
	if(string.find(arg1," has promoted ")) then
   sp,ep = string.find(arg1," has promoted ");
   if(string.find(arg1," to ")) then
      st,et = string.find(arg1," to ");
      gPlayerName = strsub(arg1,sp+14,st-1);
   end
	end
		-- arg1="Datmage has demoted Rodd to Senior Member.";
	if(string.find(arg1," has demoted ")) then
   sp,ep = string.find(arg1," has demoted ");
   if(string.find(arg1," to ")) then
      st,et = string.find(arg1," to ");
      gPlayerName = strsub(arg1,sp+13,st-1);
   end
	end

	--arg1="Proteius has been kicked out of the guild by Datmage.";
	if(string.find(arg1," has been kicked out of the guild by "))then
	   local sp,ep = string.find(arg1," has been kicked out of the guild by ");
	   gPlayerName = strsub(arg1,1,sp - 1)
	   gKickedBy   = strsub(strsub(arg1,ep,strlen(arg1)),2,strlen(strsub(arg1,ep,strlen(arg1)))-1)
		 if (tContains(GuildWho_Kicked,gPlayerName) ~= 1) then
			 print("|cffffcc00GuildWho", gwhobuild,": ", gPlayerName, " is not in the GuildWho_Kicked database. Adding new entry");
			 tinsert(GuildWho_Kicked,getn(GuildWho_Kicked),gPlayerName)             -- character name
			 tinsert(GuildWho_Kicked,getn(GuildWho_Kicked),date("%m/%d/%y")) -- kick date
			 tinsert(GuildWho_Kicked,getn(GuildWho_Kicked),gKickedBy) -- Kicked by
			 print("|cffffcc00GuildWho", gwhobuild,": ", gPlayerName, " added to the GuildWho_Kicked database!");
		 end
	end
	
	if (tContains(GuildWho_Saved,gPlayerName) == 1) then
		JDIndex = sysindex + 1
		RDIndex = sysindex + 2
		tinsert(GuildWho_Saved,RDIndex,date("%m/%d/%y"))
	else
		print("|cffffcc00GuildWho", gwhobuild,": ", gPlayerName, " is not in the database. Adding new entry");
		tinsert(GuildWho_Saved,getn(GuildWho_Saved),gPlayerName)             -- character name
		tinsert(GuildWho_Saved,getn(GuildWho_Saved),date("%m/%d/%y")) -- join date
		tinsert(GuildWho_Saved,getn(GuildWho_Saved),date("%m/%d/%y")) -- rank change date		
	end
	msgsys = false
end

function GUILDWHO_CheckStats(gsPlayerName)
	local guild, realm = (GetGuildInfo("player")), GetRealmName()
	--print("GuildWho", gwhobuild,"Debug: Lookup fired!");
	msglocal = true
	if(GuildWho_Stats[realm][guild][gsPlayerName] == nil) then
		print("|cffffcc00GuildWho", gwhobuild," ", gsPlayerName,"is not in the GuildWho_Stats Database.");
	else		
		print("|cffffcc00GuildWho", gwhobuild);
		print("|cffffcc00Guild Member:  ", gsPlayerName);
		if(type(GuildWho_Stats[realm][guild][gsPlayerName]["Chat Lines"]["value"]) == "table") then
			print("|cffffcc00Chat Lines:              0");
		else
			print("|cffffcc00Chat Lines:              ", GuildWho_Stats[realm][guild][gsPlayerName]["Chat Lines"]["value"]);
		end
		if(type(GuildWho_Stats[realm][guild][gsPlayerName]["Achievements"]["value"]) == "table") then
		print("|cffffcc00Achievements: 0");
		else
		print("|cffffcc00Achievements: ", GuildWho_Stats[realm][guild][gsPlayerName]["Achievements"]["value"]);
		end
	end
	--print("|cffffcc00GuildWho", gwhobuild,"Debug: GuildWho_Kicked checking...");
	if (tContains(GuildWho_Kicked,gsPlayerName) == 1) then
	--print("|cffffcc00GuildWho", gwhobuild,"Debug: GuildWho_Kicked[index-1] = ", GuildWho_Kicked[localindex - 1])
   if (string.find(GuildWho_Kicked[localindex - 1],"/"))then
   	local d=d; -- do something that is not nothing, but has no purpose :)
   else
   	print("|cffff0000Kicked by", GuildWho_Kicked[localindex + 2],"on",GuildWho_Kicked[localindex + 1]);
	 end
	end
	msglocal = false
end