local core = require('openmw.core')
local postprocessing = require('openmw.postprocessing')

local addiction = require('scripts.Skoomaesthesia.addiction')

local settings = require('scripts.Skoomaesthesia.settings')
local visualSettings = settings.visuals

local shader = postprocessing.load('skoomaesthesia')

local STAGE = {
    idle = "idle",
    beginning = "beginning",
    active = "active",
    ending = "ending"
}

local NEXT_STAGE = {
    [STAGE.beginning] = STAGE.active,
    [STAGE.active] = STAGE.ending,
    [STAGE.ending] = STAGE.idle,
}

local DURATION = {
    [STAGE.beginning] = 1,
    [STAGE.active] = 58,
    [STAGE.ending] = 1,
}

local function elapsed(timestamp)
    return (core.getGameTime() - timestamp) / core.getGameTimeScale()
end

local HANDLER = {
    [STAGE.idle] = function(_) end,
    [STAGE.beginning] = function(state)
        state.power = elapsed(state.timestamp) / DURATION[STAGE.beginning]
    end,
    [STAGE.active] = function(state)
        state.power = 1
    end,
    [STAGE.ending] = function(state)
        state.ending = 1 - elapsed(state.timestamp) / DURATION[STAGE.ending]
    end,
}

local state = {
    stage = STAGE.idle,
    power = 0,
    timestamp = 0,
}

return {
    engineHandlers = {
        onConsume = function(item)
            if item.recordId ~= 'potion_skooma_01' then return end
            if state.stage == STAGE.idle then
                shader:enable()
            end
            if state.stage == STAGE.idle or state.stage == STAGE.ending then
                state.stage = STAGE.beginning
            end
            state.timestamp = core.getGameTime()
            addiction.dose()
        end,
        onUpdate = function()
            addiction.update()
        end,
        onFrame = function(_)
            if state.stage == STAGE.idle then return end
            if elapsed(state.timestamp) > DURATION[state.stage] then
                state.stage = NEXT_STAGE[state.stage]
                state.timestamp = core.getGameTime()
                state.power = 0
                if state.stage == STAGE.idle then
                    shader:disable()
                end
            end
            HANDLER[state.stage](state)
            local intensity = state.power * visualSettings:get('maxIntensity')
            shader:setFloat('intensity', intensity)
            local blurRadius = state.power * visualSettings:get('maxBlur')
            shader:setFloat('radius', blurRadius)
            local colorCycle = core.getSimulationTime() * 0.1 % 2
            colorCycle = colorCycle < 1 and colorCycle or (1 - (colorCycle - 1))
            shader:setFloat('cycle', colorCycle)
        end,
        onSave = function()
            return {
                visuals = state,
                addiction = addiction.save()
            }
        end,
        onLoad = function(savedState)
            if not savedState then return end
            local visuals = savedState.visuals
            state.stage = visuals.stage
            state.timestamp = visuals.timestamp
            state.power = visuals.power

            addiction.load(savedState.addiction)
        end,
    }
}
