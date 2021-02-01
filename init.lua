assert(is_synapse_function, "Unsupported exploit!");

warn("HTTP Spy made by https://github.com/NotDSF");

local mt = getrawmetatable(game);
local backup_syn = syn.request;
local backup_namecall = mt.__namecall;

setreadonly(mt, false);
setreadonly(syn, false);

local function SaveRequest(arg1) 
  if not isfile("httplogs.txt") then writefile("httplogs.txt", "") end;
  appendfile("httplogs.txt", ("[%s]: %s\n"):format(os.date("%X"), arg1));
end;

local function TableString(arg1) 
  local Reconstructed = "";
  for i,v in pairs(arg1) do
    Reconstructed = Reconstructed .. ("[%s] = %s, "):format((type(i) == "string") and ("\"%s\""):format(i) or tostring(i),(type(v) == "string") and ("\"%s\""):format(v) or tostring(v));
  end;
  Reconstructed = Reconstructed:sub(0,-3);
  return ("{%s}"):format(Reconstructed);
end;

syn.request = function(req)
  local Response = backup_syn(req);
  local Reconstructed = "";
  for i,v in pairs(req) do
    if type(v) ~= "table" then
      Reconstructed = Reconstructed .. ("\t%s = %s,\n"):format(i,(type(v) == "string") and ("\"%s\""):format(v) or tostring(v));
    else
      Reconstructed = Reconstructed .. ("\t%s = %s,\n"):format(i,TableString(v));
    end;
  end;
  Reconstructed = Reconstructed:sub(0,-3);
  SaveRequest(("\nsyn.request({\n%s\n})\nResponse Body: %s\n"):format(Reconstructed, Response.Body));
  rconsoleinfo(("\nsyn.request({\n%s\n})\nResponse Body: %s\n"):format(Reconstructed, Response.Body));
  return Response;
end;

mt.__namecall = newcclosure(function(self, ...) 
  local args = {...};
  local method = getnamecallmethod();

  if method == "HttpGet" or method == "HttpGetAsync" or method == "GetObjects" or method == "HttpPost" or method == "HttpPostAsync" then
    SaveRequest(("\ngame:%s(\"%s\")"):format(method,args[1]));
    rconsoleinfo(("\ngame:%s(\"%s\")"):format(method,args[1]));
  end;

  return backup_namecall(self, ...);
end);

setreadonly(mt, true);
setreadonly(syn, true);
