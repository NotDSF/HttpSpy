assert(hookmetamethod, "Unsupported exploit");
assert(syn or http, "Unsupported exploit");

if getgenv().HttpSpy then
  return warn("HTTP(s) Spy already loaded. Run getgenv().HttpSpy:Destroy() to destroy the thread.");
end;

local Serialize = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotDSF/Lua-Serializer/main/Serializer%20Highlighting.lua"))();

local __namecall;
local spyEnabled  = true;
--local gsub        = string.gsub;
local format      = string.format;
local getmethod   = getnamecallmethod;
local externprint = rconsoleprint or print;
local httplib     = syn or http;
local backupSYN   = httplib.request;
local RBXMethods  = {
  ["HttpGet"] = true;
  ["HttpGetAsync"] = true;
  ["GetObjects"] = true;
  ["HttpPost"] = true;
  ["HttpPostAsync"] = true;
}

-- What the fuck script ware
if consolecreate then
  consolecreate();
end;

__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...) 
  local method = getmethod();

  if RBXMethods[method] and spyEnabled then
    externprint(format("game:%s(%s)\n", method, Serialize.serializeArgs({...})))
  end;

  return __namecall(self, ...);
end));

setreadonly(httplib, false);

httplib.request = function(request) 
  local ResponseData = backupSYN(request); -- Emulate an actual syn.request call
  local BackupData = {};

  for i,v in pairs(ResponseData) do
    BackupData[i] = v;
  end;

  if BackupData.Headers["Content-Type"] == "application/json" then
    local body = BackupData.Body;
    local ok, res = pcall(game.HttpService.JSONDecode, game.HttpService, body);

    if ok then
      BackupData.Body = res;
      --BackupData.RawBody = gsub(body, "%s", ""); 
    end;
  end;

  externprint(format("%s.request(%s)\n\nResponse Data: %s\n", syn and "syn" or "http", Serialize(request), Serialize(BackupData)));

  return ResponseData;
end;

local WebsocketLib = syn and syn.websocket or WebSocket;
local BackupWS = WebsocketLib and WebsocketLib.connect;

if WebsocketLib then
  WebsocketLib.connect = function(...) 
    local WebSocket = BackupWS(...);
    local mt = getrawmetatable(WebSocket);

    externprint(format("%s.connect(%s)\n", syn and "syn.websocket" or "WebSocket", Serialize.serializeArgs({...})));
    setreadonly(WebSocket, false);

    local __send = WebSocket.Send;
    local __close = WebSocket.Close;

    mt.__newindex = function(self, idx, val) 
      return rawset(self, idx, val);
    end;

    WebSocket.Send = function(self, message)
      __send(self, message);
      externprint(format("WebSocket:Send(%s)\n", Serialize.serializeArgs({message}))); 
    end;

    WebSocket.Close = function(self) 
      __close(self);
      externprint("WebSocket:Close()\n");
    end;

    WebSocket.OnMessage:Connect(function(message)
      externprint(format("WebSocket Message Received: %s\n", Serialize.serializeArgs({message})));
    end);

    WebSocket.OnClose:Connect(function() 
      externprint("WebSocket Closed");
    end);

    return WebSocket;
  end;
end;

setreadonly(httplib, true);

local HttpSpy = {};
function HttpSpy:Destroy()
  setreadonly(httplib, false);

  getgenv().HttpSpy = nil;
  httplib.request = backupSYN;
  spyEnabled = false;

  if WebsocketLib then
    WebsocketLib.connect = BackupWS;
  end;

  setreadonly(httplib, true);
end;

getgenv().HttpSpy = HttpSpy;

warn("HTTP(s) Spy; Created by dsf");
