-------------------------------------------------------------------------------
--- AUTHOR: Nostrademous
--- CONTRIBUTOR: Code based on work by Platinum_dota2
--- GITHUB REPO: https://github.com/Nostrademous/Dota2-FullOverwrite
-------------------------------------------------------------------------------

_G._savedEnv = getfenv()
module( "retreat_generic", package.seeall )

require( GetScriptDirectory().."/item_usage" )
local utils = require( GetScriptDirectory().."/utility")
local gHeroVar = require( GetScriptDirectory().."/global_hero_data" )

function setHeroVar(var, value)
    local bot = GetBot()
    gHeroVar.SetVar(bot:GetPlayerID(), var, value)
end

function getHeroVar(var)
    local bot = GetBot()
    return gHeroVar.GetVar(bot:GetPlayerID(), var)
end

function OnStart(bot)
    utils.IsInLane()
end

local function Updates(bot)
    if getHeroVar("IsInLane") then
        local retreatPos = utils.PositionAlongLane(bot, getHeroVar("RetreatLane"))
        setHeroVar("RetreatPos", retreatPos)
        --utils.myPrint("RetreatLane: ", getHeroVar("RetreatLane"), " -- RetreatPos: <"..retreatPos..">")
    end
end

function Think(bot, loc)
    if getHeroVar("RetreatLane") == nil then OnStart(bot) end
    
    Updates(bot)

    local nextmove = loc or nil
    
    if nextmove == nil then
        if getHeroVar("IsInLane") then
            nextmove = GetLocationAlongLane(getHeroVar("RetreatLane"), Max(getHeroVar("RetreatPos")-0.03, 0.0))
        else
            nextmove = utils.Fountain(GetTeam())
        end
    end

    local retreatAbility = getHeroVar("HasMovementAbility")
    if retreatAbility ~= nil and retreatAbility[1]:IsFullyCastable() then
        -- same name for bot AM and QoP, "tooltip_range" for "riki_blink_strike"
        local value = retreatAbility[2]
        -- below I test how far in units is a single 0.01 move in terms of GetLocationAlongLane()
        local scale = utils.GetDistance(GetLocationAlongLane(getHeroVar("RetreatLane"), 0.5), GetLocationAlongLane(getHeroVar("RetreatLane"), 0.49))
        value = ((value - 15) / scale)*0.01 -- we subtract 15 to give ourselves a little rounding wiggle room
        nextmove = GetLocationAlongLane(getHeroVar("RetreatLane"), Max(getHeroVar("RetreatPos")-value, 0.0))
        bot:Action_UseAbilityOnLocation(retreatAbility[1], nextmove)
        return
    end

    --utils.myPrint("MyLanePos: ", tostring(bot:GetLocation()), ", RetreatPos: ", tostring(nextmove))
    
    if item_usage.UseMovementItems(nextmove) then return end
    
    bot:Action_MoveToLocation(nextmove)
end

--------
for k,v in pairs( retreat_generic ) do _G._savedEnv[k] = v end