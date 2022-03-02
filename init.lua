--[[
    HttpSpy v1.0.7
]]

assert(syn, "Unsupported exploit");

local options = ({...})[1] or {};
local version = "v1.0.7";
local logname = string.format("%s-log.txt", string.gsub(syn.crypt.base64.encode(syn.crypt.random(5)), "%p", ""));

if not isfile(logname) then writefile(logname, string.format("Http Logs from %s\n\n", os.date("%d/%m/%y"))) end;

local Serializer = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/leopard/main/rbx/leopard-syn.lua"))()
local pconsole = rconsoleprint;
local format = string.format;
local gsub = string.gsub;
local match = string.match;
local append = appendfile;
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
    local BE = Instance.new("BindableEvent");
    coroutine.wrap(function() 
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

pconsole(format("HttpSpy %s\nCreated by https://github.com/NotDSF\nChange Logs:\n\t%s\nLogs are automatically being saved to: %s\n\n", version, RecentCommit, logname))
