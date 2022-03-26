--[[
    HttpSpy v1.0.9
]]

assert(syn, "Unsupported exploit");

local options = ({...})[1] or { AutoDecode = true, Highlighting = true, SaveLogs = true, CLICommands = true };
local version = "v1.0.9";
local logname = string.format("%s-log.txt", string.gsub(syn.crypt.base64.encode(syn.crypt.random(5)), "%p", ""));

if not isfile(logname) and options.SaveLogs then 
    writefile(logname, string.format("Http Logs from %s\n\n", os.date("%d/%m/%y"))) 
end;

local Serializer = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/leopard/main/rbx/leopard-syn.lua"))();
local clonef = clonefunction;
local pconsole = clonef(rconsoleprint);
local pinput = clonef(rconsoleinput);
local format = clonef(string.format);
local gsub = clonef(string.gsub);
local match = clonef(string.match);
local gmatch = clonef(string.gmatch);
local append = clonef(appendfile);
local Unpack = clonef(unpack);
local Type = clonef(type);
local crunning = clonef(coroutine.running);
local cwrap = clonef(coroutine.wrap);
local cresume = clonef(coroutine.resume);
local cyield = clonef(coroutine.yield);
local Pcall = clonef(pcall);
local Pairs = clonef(pairs);
local Error = clonef(error);
local blocked = {};
local enabled = true;
local methods = {
    HttpGet = true,
    HttpGetAsync = true,
    GetObjects = true,
    HttpPost = true,
    HttpPostAsync = true
}

Serializer.UpdateConfig({ highlighting = options.Highlighting });

local function printf(...) 
    if options.SaveLogs then
        append(logname, gsub(format(...), "%\27%[%d+m", ""));
    end;
    return pconsole(format(...));
end;

local function DeepClone(tbl, cloned)
    cloned = cloned or {};

    for i,v in Pairs(tbl) do
        if Type(v) == "table" then
            cloned[i] = DeepClone(v, cloned);
            continue;
        end;
        cloned[i] = v;
    end;

    return cloned;
end;

local __namecall, __request;
__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod();

    if methods[method] then
        printf("game:%s(%s)\n", method, Serializer.FormatArguments(...));
    end;

    return __namecall(self, ...);
end));

__request = hookfunction(syn.request, newcclosure(function(req) 
    if Type(req) ~= "table" then return __request(req); end;

    local RequestData = DeepClone(req);
    if not enabled then
        return __request(req);
    end;

    local t = crunning();
    cwrap(function() 
        if RequestData.Url and blocked[RequestData.Url] then
            printf("syn.request(%s) -- blocked url\n\n", Serializer.Serialize(RequestData));
            return cresume(t, {});
        end;

        local ok, ResponseData = Pcall(__request, RequestData); -- I know of a detection with this
        if not ok then
            Error(ResponseData, 0);
        end;

        local BackupData = {};

        for i,v in Pairs(ResponseData) do
            BackupData[i] = v;
        end;

        if match(BackupData.Headers["Content-Type"], "application/json") and options.AutoDecode then
            local body = BackupData.Body;
            local ok, res = Pcall(game.HttpService.JSONDecode, game.HttpService, body);
            
            if ok then
                BackupData.Body = res;
            end;
        end;

        printf("syn.request(%s)\n\nResponse Data: %s\n", Serializer.Serialize(RequestData), Serializer.Serialize(BackupData));
        cresume(t, ResponseData);
    end)();
    return cyield();
end));


-- I'll make this better later
local WsConnect, WsBackup = debug.getupvalue(syn.websocket.connect, 1);
WsBackup = hookfunction(WsConnect, function(url, ...) 
    printf("syn.websocket.connect(\"%s\")", url);
    return WsBackup(url, ...);
end);

local RecentCommit = game.HttpService:JSONDecode(game.HttpGet(game, "https://api.github.com/repos/NotDSF/HttpSpy/commits?per_page=1&path=init.lua"))[1].commit.message;

for method in Pairs(methods) do
    local b;
    b = hookfunction(game[method], newcclosure(function(self, ...) 
        printf("game.%s(game, %s)\n", method, Serializer.FormatArguments(...));
        return b(self, ...);
    end));
end;

pconsole(format("HttpSpy %s (Creator: https://github.com/NotDSF)\nMake sure you are using the loadstring for live updates @ https://github.com/NotDSF/HttpSpy\nChange Logs:\n\t%s\nLogs are automatically being saved to: %s\nType \"cmds\" to view a list of commands\n\n", version, RecentCommit, options.SaveLogs and logname or "(You aren't saving logs, enable SaveLogs if you want to save logs)"));

if not options.CLICommands then return end;

local Commands = {};
local function RegisterCommand(name, argsr, func) 
    Commands[name] = {
        ArgsRequired = argsr,
        Command = func
    }
end;

RegisterCommand("cmds", 0, function() pconsole("List of commands:\n\tblock[=url]: will block any request with the specified url (the request will still be shown on the spy)\n\tunblock[=url]: will unblock the specified url\n\tenable: will enable the spy\n\tdisable: will disable the spy\n\tcls: will clear the console\n\n"); end);
RegisterCommand("enable", 0, function() enabled = true; pconsole("The spy is now enabled!\n\n"); end);
RegisterCommand("disable", 0, function() enabled = false; pconsole("The spy is now disabled!\n\n"); end);
RegisterCommand("cls", 0, rconsoleclear);

RegisterCommand("block", 1, function(url) 
    blocked[url] = true;
    pconsole(format("Blocked url: '%s'\n\n", url));
end);

RegisterCommand("unblock", 1, function(url) 
    if not blocked[url] then
        pconsole(format("This url isn't blocked\n\n"));
    end;
    blocked[url] = false;
    pconsole(format("Unblocked url: '%s'\n\n", url));
end);

while true do 
    local Input, Args, Command = pinput(), {};

    for i in gmatch(Input, "[^%s]+") do
        if not Command then 
            Command = i;
            continue;
        end;
        Args[#Args+1] = i;
    end;

    if not Command then continue end;

    local CommandInfo = Commands[Command];
    if not CommandInfo then
        pconsole(format("'%s' is not a command, type \"cmds\" to view the commands\n\n", Command));
        continue;
    end;

    if CommandInfo.ArgsRequired > #Args then
        pconsole(format("'%s' requires %d arguments but you provided %d\n\n", Command, CommandInfo.ArgsRequired, #Args));
        continue;
    end;

    CommandInfo.Command(Unpack(Args));
end;
