--[[
  dsf's http spy v1.0.1

  PLEASE IGNORE THE SYNTAX ERROR! (Compound operators are supported by SynX.)
]]

assert(is_synapse_function, "Unsupported exploit!");

warn("HTTP Spy made by https://github.com/NotDSF");

local mt = getrawmetatable(game);
local synBackup = syn.request;
local backup_namecall = mt.__namecall;
local methods = {
  ["HttpGet"] = true;
  ["HttpGetAsync"] = true;
  ["GetObjects"] = true;
  ["HttpPost"] = true;
  ["HttpPostAsync"] = true;
};

setreadonly(mt, false);
setreadonly(syn, false);

local Serialize;

local function formatIndex(idx, scope)
  local indexType = type(idx);
  local finishedFormat = "";
  if indexType == "string" then
    finishedFormat = finishedFormat .. ("\"%s\""):format(idx);
  elseif indexType == "number" then
    finishedFormat = finishedFormat .. idx;
  elseif indexType == "table" then
    scope++; -- PLEASE IGNORE THE SYNTAX ERROR! (Compound operators are supported by SynX.)
    finishedFormat = finishedFormat .. Serialize(idx, scope);
  end;
  return ("[%s]"):format(finishedFormat);
end;

Serialize = function(tbl, scope) 
  local Serialized = "";
  local scopeTab = ("\t"):rep(scope);
  local scopeTab2 = ("\t"):rep(scope+1);
  local output = "";

  for i,v in pairs(tbl) do
    local formattedIndex = formatIndex(i, scope);
    local valueType = type(v);
    if valueType == "string" then -- Could of made it inline but its better to manage types this way.
      Serialized ..= ("%s%s = \"%s\";\n"):format(scopeTab2, formattedIndex, v);
    elseif valueType == "number" or valueType == "boolean" then
      Serialized ..= ("%s%s = %s;\n"):format(scopeTab2, formattedIndex, tostring(v));
    elseif valueType == "table" then
      Serialized ..= ("%s%s = %s;\n"):format(scopeTab2, formattedIndex, Serialize(v, scope+1));
    end;
  end;

  if scope == 0 then
    return ("{\n%s}"):format(Serialized);  
  else
    return ("{\n%s%s}"):format(Serialized, scopeTab);
  end;
end;

local function saveRequest(req) 
  if not isfile("httplogs.txt") then writefile("httplogs.txt", "") end;
  appendfile("httplogs.txt", ("[%s]: %s\n"):format(os.date("%X"), req));
end;

syn.request = function(req) 
  local Response = synBackup(req);
  local serializedReq = ("syn.request(%s);"):format(Serialize(req, 0));
  local serializedResponse = Serialize(Response, 0);

  saveRequest(("\n%s\nResponse: %s\n"):format(serializedReq, serializedResponse));
  rconsoleinfo(("\n%s\nResponse: %s\n"):format(serializedReq, serializedResponse));

  return Response;
end;

mt.__namecall = newcclosure(function(self, ...) 
  local args = {...};
  local method = getnamecallmethod();

  if methods[method] then
    saveRequest(("\ngame:%s(\"%s\");"):format(method, args[1]));
    rconsoleinfo(("\ngame:%s(\"%s\");"):format(method, args[1]));
  end;

  return backup_namecall(self, unpack(args));
end);

setreadonly(mt, true);
setreadonly(syn, true);
