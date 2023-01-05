local I = require('openmw.interfaces')
local storage = require('openmw.storage')

I.Settings.registerPage {
    key = 'Skoomaesthesia',
    l10n = 'Skoomaesthesia',
    name = 'pageName',
    description = 'pageDescription',
}

I.Settings.registerGroup {
    key = 'SettingsSkoomaesthesia_Visuals',
    page = 'Skoomaesthesia',
    l10n = 'Skoomaesthesia',
    name = 'visualsGroupName',
    permanentStorage = true,
    settings = {
        {
            key = 'maxIntensity',
            name = 'maxIntensity_name',
            renderer = 'number',
            default = 0.3,
            argument = {
                min = 0,
                max = 1,
            },
        },
        {
            key = 'maxBlur',
            name = 'maxBlur_name',
            renderer = 'number',
            default = 1.0,
            argument = {
                min = 0,
                max = 1,
            },
        },
    }
}

return {
    visuals = storage.playerSection('SettingsSkoomaesthesia_Visuals')
}
