-- HttpSpy rewrite for syn v3 (literally untested)

-- Serializer

local type = type;
local string = string;
local match = string.match;
local sub = string.sub;
local byte = string.byte;
local concat = table.concat;
local rep = string.rep;
local format = string.format;
local pairs = pairs;
local tostring = tostring;
local SerializeTable;

do
    local StringReplacements = {
        ["\n"] = "\\n",
        ["\t"] = "\\t",
        ["\""] = "\\\""
    }
    
    local function FormatString(string, isindex) 
        if not match(string, "[^_%a%d]+") then
            return not isindex and format("\"%s\"", string) or string;
        end;
    
        local str = {};
        for i=1, #string do
            local char = sub(string, i, i);
            if StringReplacements[char] then
                str[i] = StringReplacements[char];
            else
                local code = byte(char);
                if code < 32 or code > 126 then
                    str[i] = "\\" .. code;
                else
                    str[i] = char;
                end;
            end;
        end;
    
        return not isindex and format("\"%s\"", concat(str)) or concat(str);
    end;
    
    local function FormatNumber(number, isindex) 
        local r = tostring(number);
        if number == math.huge then
            r = "math.huge";
        elseif number == -math.huge then
            r = "-math.huge";
        end;
        return isindex and "[" .. r .. "]" or r;
    end;
    
    local TypeF = {
        string = FormatString,
        number = FormatNumber,
        boolean = FormatNumber
    }
    
    
    SerializeTable = function(tbl, scope) 
        scope = scope or 0;
    
        local out = {};
        local Tab1 = rep("\t", scope);
        local Tab2 = rep("\t", scope + 1); 
        local Length = 0;
    
        for i,v in tbl do
            local T = type(v);
            local TypeIndex = type(i);
            local FormattedIndex = TypeF[TypeIndex] and TypeF[TypeIndex](i, true);
            if not FormattedIndex then
                FormattedIndex = TypeIndex == "table" and "[" .. SerializeTable(i) .. "]" or tostring(i);
            end;
    
            if TypeF[T] then
                out[#out+1] = format("%s%s = %s,\n", Tab2, FormattedIndex, TypeF[T](v));
            elseif T == "table" then
                out[#out+1] = format("%s%s = %s,\n", Tab2, FormattedIndex, SerializeTable(v, scope + 1))
            end;
            Length = Length + 1;
        end;
    
        local Last = out[#out];
        if Last then
            out[#out] = sub(Last, 0, -2);
        end;
    
        if Length == 0 then
            return "{}";
        end;
    
        if scope < 1 then
            return format("{\n%s}", concat(out));
        else
            return format("{\n%s%s}", concat(out), Tab1);
        end;
    end;
end;

local request;

local function Clone(tbl, cloned) 
    cloned = cloned or {};

    for i,v in pairs(tbl) do
        if type(v) == "table" then
            cloned[i] = Clone(v, cloned);
            continue
        end;
        cloned[i] = v;
    end;

    return cloned;
end; 

request = hookfunction(syn.request, function(data) 
    local Request = Clone(data);
    local Response = request(data);
    print(format("syn.request(%s)\nResponse: %s", SerializeTable(Request), SerializeTable(Response)));
    return Response;
end);
