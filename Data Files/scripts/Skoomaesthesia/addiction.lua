local core = require('openmw.core')
local self = require('openmw.self')
local types = require('openmw.types')
local storage = require('openmw.storage')
local time = require('openmw_aux.time')

local settings = storage.globalSection('SettingsSkoomaesthesia_Addiction')

local attributes = types.Actor.stats.attributes

local function applyWithdrawalChange(player, active)
    local withdrawalIntensity = settings:get('withdrawalIntensity')
    if active then
        withdrawalIntensity = - withdrawalIntensity
    end
    local intelligence = attributes.intelligence(player)
    intelligence.modifier = intelligence.modifier + withdrawalIntensity
    local agility = attributes.agility(player)
    agility.modifier = agility.modifier + withdrawalIntensity
end

local state = {
    lastDoseTime = nil,
    hasWithdrawal = false,
}

local function dose()
    state.lastDoseTime = core.getGameTime()
end

local function update()
    if not state.lastDoseTime then return end
    local now = core.getGameTime()
    local timeSinceDose = now - state.lastDoseTime
    local hoursSinceDose = timeSinceDose / time.hour

    local hoursToWithdrawal = settings:get('hoursToWithdrawal')
    local hoursToRecovery = settings:get('hoursToRecovery')

    local hasWithdrawal = hoursToWithdrawal < hoursSinceDose
        and hoursSinceDose < hoursToRecovery

    if state.hasWithdrawal ~= hasWithdrawal then
        applyWithdrawalChange(self, hasWithdrawal)
        state.hasWithdrawal = hasWithdrawal
    end
end

local function save()
    return state
end

local function load(savedState)
    if not savedState then return end
    state.lastDoseTime = savedState.lastDoseTime
    state.hasWithdrawal = savedState.hasWithdrawal
end

return {
    dose = dose,
    update = update,
    save = save,
    load = load
}