--[[
    name - get-game-hash
    description - get hashes of all loaded scripts and hashing result
    notes - can be useful for check hash for prevent detection, etc.
    author - sylo
--]]

local client = game.Players.LocalPlayer;
local ins = table.insert;
local sort = table.sort;
local concat = table.concat;
local find = table.find;
local descendantof = game.IsDescendantOf;

return function(hashConfig)
    local gameHash = {};
    local blacklistedCount = 0;
    
    local config = shared.hashConfig or hashConfig or {
        debug = false,
        blacklisted = {},
        maxscripts = math.huge,
        scriptslimit = false
    };

    local blacklisted = config.blacklisted;
    local debug = config.debug;
    local scriptslimit = config.scriptslimit;
    local maxscripts = config.maxscripts; 
    
    if debug then
        rconsoleclear();
    end;

    local blacklisted = {'BubbleChat', 'Animate', 'RbxCharacterSounds', 'FreecamScript', 'ChatScript'};
    table.move(config.blacklisted, 0, 1, #blacklisted + 1, blacklisted); -- rewrite?

    local scripts = getscripts();
    
    sort(scripts, function(A, B)
        return #A.Name > #B.Name;
    end);
    
    for i = 1, #scripts do
        if (scriptslimit and i >= maxscripts) then break end;
        local script = scripts[i];
        
        if pcall(function() return script.Disabled end) then -- filters roblox scripts
            local hash = getscripthash(script);
            if (not hash) then continue end;
            
            if (#blacklisted ~= blacklistedCount) then
                if (descendantof(script, client.PlayerGui) or descendantof(script, client.PlayerScripts) or descendantof(script, client.Character)) then
                    if (find(blacklisted, script.Name)) then
                        blacklistedCount = blacklistedCount + 1;
                        continue;
                    end;
                end;
            end;
            
            if debug then
                rconsolewarn(('%s (%s)'):format(script:GetFullName(), hash));
            end;
            
            ins(gameHash, hash);
        end;
    end;
    
    assert(gameHash[1] ~= nil, '[get-game-hash] scripts equals to nil');
    
    return syn.crypto.custom.hash('sha256', concat(gameHash));
end;


--[[
    -- usage
    local getGameHash = loadstring(game:HttpGet('https://raw.githubusercontent.com/sylo-rblx/scripts/main/get-game-hash.lua'))();
    
    rconsolewarn(getGameHash({
        debug = true, -- debug scripts info
        blacklisted = {}, -- can be added blacklisted scripts names,
        maxscripts = 1000, -- you can set limit for fetching scripts for result,
        scriptslimit = true -- you can set use limit
    }));
    
    rconsolewarn(getGameHash());
    
--]]
