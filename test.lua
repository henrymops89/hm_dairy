-- Test welche ox_lib Funktionen verfügbar sind

RegisterCommand('testoxlib', function()
    print('^3========================================^0')
    print('^3OX_LIB FUNCTION CHECK^0')
    print('^3========================================^0')
    
    -- Check if lib table exists
    if lib then
        print('^2✅ lib table exists^0')
        
        -- Check common progress functions
        local functions = {
            'progressBar',
            'progressCircle', 
            'progressActive',
            'progress',
            'showProgress',
            'callback',
            'requestAnimDict',
            'requestModel',
            'notify'
        }
        
        for _, funcName in ipairs(functions) do
            if lib[funcName] then
                print('^2✅ lib.' .. funcName .. ' exists (type: ' .. type(lib[funcName]) .. ')^0')
            else
                print('^1❌ lib.' .. funcName .. ' does NOT exist^0')
            end
        end
        
        -- Try to list all lib functions
        print('^3--- All lib functions: ---^0')
        for key, value in pairs(lib) do
            if type(value) == 'function' then
                print('^3  - lib.' .. key .. '^0')
            end
        end
    else
        print('^1❌ lib table does NOT exist!^0')
    end
    
    print('^3========================================^0')
    
    -- Check exports
    print('^3Checking exports.ox_lib...^0')
    if exports and exports.ox_lib then
        print('^2✅ exports.ox_lib exists^0')
        
        -- Try calling it
        local success, result = pcall(function()
            return exports.ox_lib:progressBar({
                duration = 2000,
                label = 'Test via exports',
                canCancel = true
            })
        end)
        
        print('^3exports.ox_lib:progressBar() test:^0')
        print('^3  success: ' .. tostring(success) .. '^0')
        print('^3  result: ' .. tostring(result) .. '^0')
    else
        print('^1❌ exports.ox_lib does NOT exist^0')
    end
    
    print('^3========================================^0')
end, false)