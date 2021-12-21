1. Due to fucking synapse

FOR SOME REASON IF YOU HOOKFUNCTION/NEWCCLOSURE SYN.REQUEST AND CALL THE BACKUP OF SYN.REQUEST IT ENDS THE EXECUTION OF THAT FUNCTION

EXAMPLE
```lua
backup = hookfunction(syn.request, newcclosure(function(...) 
    local res = backup(...);
    print(res);
    return res;
end));
```
THEN EXECUTE
```lua
syn.request({
    Url = "https://httpbin.org/get"
})
```
WILL PRINT NOTHING BECAUSE `backup(...)` SOMEHOW IS LIKE RETURN 

SO FOR ME TO BE ABLE TO GET THE RESPONSE I NEED TO COMPLETELY REPLACE THE CLOSURE
