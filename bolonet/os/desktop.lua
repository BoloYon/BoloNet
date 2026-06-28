local G = require("/bolonet/lib/globals")
local user = G.session.GetUser()

local function adminDashboard()

end

local function openApps()

end

local function openSettings()

end

local function logout()
    G.logger.Log("Signed out '"..user.."'.")
    G.session.ClearUser()
    shell.run("/bolonet/os/login.lua")
end

local function shutdown()

end





local function drawDesktop()
    local options = {"Apps", "Settings", "Logout", "Shutdown"}
    local actions = {
        function() openApps() end,
        function() openSettings() end,
        function() logout() end,
        function() shutdown() end
    }

    if G.userF.IsAdmin(user) then
        table.insert(options, 1, "Admin Menu")
        table.insert(actions, 1, function() adminDashboard() end )
    end

    G.ui.Navigate(options, actions, "--DESKTOP PAGE--")
end

drawDesktop()