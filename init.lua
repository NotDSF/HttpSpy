--[[
    HttpSpy v1.0.8
]]

assert(syn, "Unsupported exploit");

local options = ({...})[1] or {};
local version = "v1.0.8";
local logname = string.format("%s-log.txt", string.gsub(syn.crypt.base64.encode(syn.crypt.random(5)), "%p", ""));

if not isfile(logname) then writefile(logname, string.format("Http Logs from %s\n\n", os.date("%d/%m/%y"))) end;

local Serializer = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/leopard/main/rbx/leopard-syn.lua"))()
local pconsole = rconsoleprint;
local format = string.format;
local gsub = string.gsub;
local match = string.match;
local append = appendfile;
local Unpack = unpack;
local Type = type;
local Rawget = rawget;
local blocked = {};
local enabled = true;
local methods = {
    HttpGet = true,
    HttpGetAsync = true,
    GetObjects = true,
    HttpPost = true,
    HttpPostAsync = true
}

Serializer.UpdateConfig({ highlighting = true });

local function printf(...) 
    append(logname, gsub(format(...), "%\27%[%d+m", ""));
    return pconsole(format(...));
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
    if not enabled then
        return __request(req);
    end;

    local BE = Instance.new("BindableEvent");
    coroutine.wrap(function() 
        if Type(req) == "table" and Rawget(req, "Url") and blocked[req.Url] then
            printf("syn.request(%s) -- blocked url\n\n", Serializer.Serialize(req));
            return BE.Fire(BE, {});
        end;

        local ResponseData = __request(req);
        local BackupData, IsJSON = {};

        for i,v in pairs(ResponseData) do
            BackupData[i] = v;
        end;

        if match(BackupData.Headers["Content-Type"], "application/json") then
            local body = BackupData.Body;
            local ok, res = pcall(game.HttpService.JSONDecode, game.HttpService, body);
            
            if ok then
                BackupData.Body = res;
            end;

            IsJSON = true;
        end;

        printf("syn.request(%s)\n\nResponse Data: %s\n", Serializer.Serialize(req), Serializer.Serialize(BackupData));

        if IsJSON then
            append(logname, format("\nRaw Body: %s\n", ResponseData.Body));
        end;

        BE.Fire(BE, ResponseData);
    end)();
    return BE.Event:Wait();
end));

-- This can be easily detected!!!
if options.WebsocketSpy then
    local id = 1;
    __websocket = hookfunction(syn.websocket.connect, function(url) 
        if not enabled then
            return __websocket(url);
        end;

        local BE = Instance.new("BindableEvent");
        coroutine.wrap(function() 
            local WebsocketId = "WS_" .. id;
            local WebSocket = __websocket(url);
            local mt = getrawmetatable(WebSocket);
            local __send, __close = WebSocket.Send, WebSocket.Close;

            printf("local %s = syn.websocket.connect(%s)\n", WebsocketId, Serializer.FormatArguments(url));
            
            mt.__newindex = function(self, ...) 
                return rawset(self, ...);
            end;

            WebSocket.Send = function(self, message) 
                __send(self, message);
                printf("%s:Send(%s)\n", WebsocketId, Serializer.FormatArguments(message));
            end;

            WebSocket.Close = function(self) 
                __close(self);
                printf("%s:Close()\n", WebsocketId);
            end;

            WebSocket.OnMessage:Connect(function(message) 
                printf("%s recieved message: %s\n", WebsocketId, Serializer.FormatArguments(message));
            end);

            WebSocket.OnClose:Connect(function()
                printf("%s closed!\n", WebsocketId);
            end);

            BE.Fire(BE, WebSocket);
        end)();
        id = id + 1;
        return BE.Event:Wait();
    end);
end;

local RecentCommit = game.HttpService:JSONDecode(game.HttpGet(game, "https://api.github.com/repos/NotDSF/HttpSpy/commits?per_page=1&path=init.lua"))[1].commit.message;

for method in pairs(methods) do
    local b;
    b = hookfunction(game[method], newcclosure(function(self, ...) 
        printf("game.%s(game, %s)\n", method, Serializer.FormatArguments(...));
        return b(self, ...);
    end));
end;

pconsole(format("HttpSpy %s (Creator: https://github.com/NotDSF)\nMake sure you are using the loadstring for live updates @ https://github.com/NotDSF/HttpSpy\nChange Logs:\n\t%s\nLogs are automatically being saved to: %s\nType \"cmds\" to view a list of commands\n\n", version, RecentCommit, logname));

local Commands = {};
local function RegisterCommand(name, argsr, func) 
    Commands[name] = {
        ArgsRequired = argsr,
        Command = func
    }
end;

RegisterCommand("cmds", 0, function() pconsole("List of commands:\n\tblock[=url]: will block any request with the specified url (the request will still be shown on the spy)\n\tunblock[=url]: will unblock the specified url\n\tenable: will enable the spy\n\tdisable: will disable the spy\n\tcls: will clear the console\n\n"); end);
RegisterCommand("enable", 0, function() enabled = true; pconsole("The spy is now enabled!\n\n"); end);
RegisterCommand("disable", 0, function() enabled = false; pconsole("The spy is now disabled!\n\n") ;end);
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
    local Input, Args, Command = rconsoleinput(), {};

    for i in string.gmatch(Input, "[^%s]+") do
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
