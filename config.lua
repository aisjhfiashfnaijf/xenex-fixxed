shared.Xanax = {
    ['Settings'] = {
        ['Target Aim'] = true,
        ['Knock Check'] = true,
        ['Visible Check'] = false,
    },
    ['Keybinds'] = {
        ['Target Lock'] = { ['Key'] = 'E', ['Mode'] = 'Toggle' },
        ['Trigger Bot'] = { ['Key'] = 'T', ['Mode'] = 'Toggle' },
        ['Speed'] = 'Q',
        ['ESP'] = 'Y',
        ['Super Jump'] = 'V',
        ['Camera Lock'] = 'C',
    },

    ['UI'] = {
        ['Enabled'] = false,           -- false = hide the status text
    },

    -- Silent Aim FOV (circle)
    ['Silent Aim FOV'] = {
        ['Enabled'] = true,          -- restrict silent aim to FOV?
        ['Visible'] = true,           -- draw the circle?
        ['Radius'] = 100,             -- screen-pixel radius of the circle
        ['Thickness'] = 2,
        ['Color'] = Color3.fromRGB(255, 0, 255),
    },

    -- Camlock FOV (circle)
    ['Camera Lock FOV'] = {
        ['Enabled'] = false,
        ['Visible'] = true,
        ['Radius'] = 100,
        ['Thickness'] = 2,
        ['Color'] = Color3.fromRGB(255, 255, 0),
    },

    ['Silent Aim'] = {
        ['Enabled'] = true,
        ['Hit Part'] = 'Head',
        ['Use Prediction'] = false,
        ['Prediction'] = { X = 0, Y = 0, Z = 0 },
    },
    ['Camera Lock'] = {
        ['Enabled'] = true,            -- master switch
        ['Smoothing'] = 40,
        ['Use Prediction'] = true,
        ['Prediction'] = 0.133,
    },
    ['Trigger Bot'] = {
        ['Enabled'] = true,
        ['Delay'] = 0.01,
        ['Specific Weapons'] = {
            ['Enabled'] = false,
            ['Weapons'] = { '[Double-Barrel SG]', '[Revolver]', '[TacticalShotgun]' },
        },
    },
    ['Spread'] = {
        ['Enabled'] = true,
        ['Amount'] = 23,
        ['Specific Weapons'] = {
            ['Enabled'] = true,
            ['Weapons'] = { '[Double-Barrel SG]', '[TacticalShotgun]' },
        },
    },
    ['Speed'] = {
        ['Enabled'] = true,
        ['Multiplier'] = 240,
        ['Anti Fling'] = false,
    },
    ['Hitbox Expander'] = {
        ['Enabled'] = true,
        ['Size'] = 3,
        ['Visualize'] = false,
    },
    ['Spiderman'] = {
        ['Enabled'] = false,
    },
    ['Visual Awareness'] = {
        ['Enabled'] = true,
        ['Color'] = Color3.fromRGB(255, 255, 255),
        ['Target Color'] = Color3.fromRGB(102, 178, 255),
    },
    ['Super Jump'] = {
        ['Enabled'] = true,
        ['Power'] = 365,
        ['Cooldown'] = 0.1,
    },
    ['Infinite Range'] = {
        ['Enabled'] = true,
        ['Key'] = 'N',
        ['Max Range'] = 77777,
    },
    ['Snapline'] = {
        ['Enabled'] = true,
        ['Color'] = Color3.fromRGB(255, 255, 255),
        ['Thickness'] = 2,
        ['MouseOffsetY'] = 58,
        ['TargetPart'] = 'Head'
    },
    ['Rapid Fire'] = {
        ['Enabled'] = false,
        ['Delay'] = 0.1,
        ['Specific Weapons'] = {
            ['Enabled'] = false,
            ['Weapons'] = {}
        }
    }
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/aisjhfiashfnaijf/xenex-fixxed/main/xenex.lua"))()
