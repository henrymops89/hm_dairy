-- client/blip.lua
-- Map-Blip für die Milchfarm (Verbesserte Version)

if Config.Blip.Enabled then
    CreateThread(function()
        -- Warte bis Spieler vollständig geladen ist
        while not NetworkIsPlayerActive(PlayerId()) do
            Wait(100)
        end
        
        -- Extra Wartezeit für Map-Loading
        Wait(2000)
        
        -- Blip erstellen
        local blip = AddBlipForCoord(Config.Blip.Coords.x, Config.Blip.Coords.y, Config.Blip.Coords.z)
        
        SetBlipSprite(blip, Config.Blip.Sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.Blip.Scale)
        SetBlipColour(blip, Config.Blip.Color)
        SetBlipAsShortRange(blip, true)
        
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(Config.Blip.Name)
        EndTextCommandSetBlipName(blip)
        
        print('[HM Dairy Blip] Farm-Blip erstellt bei: ' .. Config.Blip.Coords)
        print('[HM Dairy Blip] Sprite: ' .. Config.Blip.Sprite .. ', Color: ' .. Config.Blip.Color)
    end)
else
    print('[HM Dairy Blip] Blip ist deaktiviert in Config')
end