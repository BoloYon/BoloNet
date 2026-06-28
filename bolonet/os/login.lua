--This is where Users sign in/up or power off terminal

local G = require("/bolonet/lib/globals")
local w, h = term.getSize()
local isSignedIn = ...



--==Helper Functions==--
local function isUserValid(user, users)
    if user == nil or #user <= 3 then 
        G.ui.CalcCenter("Username must be greater than 3 characters.", 0, 3, print, colors.red)
        G.ui.CalcCenter("Select any key to continue", 0, 5, write, colors.lightBlue)
        os.pullEvent("key")
        return false
    elseif user:match("%W") then
        G.ui.CalcCenter("Username can only be alphanumeric characters.", 0, 3, print, colors.red)
        G.ui.CalcCenter("Select any key to continue", 0, 5, write, colors.lightBlue)
        os.pullEvent("key")
        return false
    elseif users[user] then
        G.ui.CalcCenter("Username already exists.", 0, 3, print, colors.red)
        G.ui.CalcCenter("Select any key to continue", 0, 5, write, colors.lightBlue)
        os.pullEvent("key")
        return false -- user is NOT valid
    end
    return true
end

local function isPassValid(pass)
    if pass == nil or #pass < 5 then
        G.ui.CalcCenter("Password must be greater than 5 characters.", 0, 3, print, colors.red)
        G.ui.CalcCenter("Select any key to continue", 0, 5, write, colors.lightBlue)
        os.pullEvent("key")
        return false
    end
    return true
end

local function login()
    term.clear()
    --Open file for use
    local file = fs.open("/bolonet/users/users.db", "r")

    --Safety check
    if not file then return end

    local content = file.readAll() or ""
    local users = textutils.unserialise(content)

    file.close()

    G.ui.GoBackText()
    G.ui.CalcCenter("Please enter your login information.", 0, -3, write, colors.white)

    G.ui.CalcCenter("Username: ", -10, -1, write, colors.white)

    term.setTextColor(colors.lightGray)
    local user, cancelled = G.ui.Read()
    term.setTextColor(colors.white)

    if cancelled then return end

    --Check if user does not exist
    if not users or not users[user] then 
        G.ui.CalcCenter("User was not found.", 0, 3, write, colors.red) 
        G.ui.CalcCenter("Select any key to continue", 0, 5, write, colors.lightBlue)
        os.pullEvent("key")
        return login()
    end

    --If user DOES exist, ask for password
    local savedPass = users[user].password
    local pass

    repeat
        G.ui.CalcCenter("Password: ", -10, 1, write, colors.white)
        term.setTextColor(colors.lightGray)
        pass, cancelled = G.ui.Read("*")
        term.setTextColor(colors.white)

        if cancelled then return end

        if pass == savedPass then
            term.clear()
            G.logger.Log("AUTH", user.." logged in.")
            G.ui.CalcCenter("Login Successful. Welcome, ".. user.."!", 0, 0, write, colors.green)
            sleep(1.5)
            G.session.SetUser(user)
            shell.run("/bolonet/os/desktop.lua")
        else
            G.logger.Log("AUTH", "Failed login attempt for '"..user.."'.")
            G.ui.CalcCenter("Incorrect Password.", 0, 5, write, colors.red)
            sleep(2)
            G.ui.ClearLine(h/2 + 1)
            G.ui.ClearLine(h/2 + 3)
            G.ui.ClearLine(h/2 + 5)
        end
    until pass == savedPass
end

local function signUp()
    term.clear()
    local user, pass, rePass, cancelled, content, users

    --Open file for username check and storage of user data
    local file = fs.open("/bolonet/users/users.db", "r")
    if file then
        content = file.readAll() or ""
        users = textutils.unserialize(content)
        file.close()
    else
        G.logger.Log("ERROR", "Could not open 'users.db'")
        error("Couldn't open users.db", 1)
    end

    --Get username
    G.ui.GoBackText()
    G.ui.CalcCenter("Enter a username: ", -5, -1, write, colors.white)
    term.setTextColor(colors.lightGray)
    user, cancelled = G.ui.Read()
    if cancelled then return end
    term.setTextColor(colors.white)

    --Username checks
    if not isUserValid(user, users) then
        return signUp()
    end

    if not user or not users then --Safety check to avoid squiggles, should never activate
        return
    end

    local isFirstUser = next(users)
    users[user] = {}

    repeat
        G.ui.CalcCenter("Enter a password: ", -5, 1, write, colors.white)
        term.setTextColor(colors.lightGray)
        pass, cancelled = G.ui.Read("*")
        if cancelled then return end
        term.setTextColor(colors.white)

        if isPassValid(pass) then
            G.ui.CalcCenter("Re-enter password: ", -5, 3, write, colors.white)
            term.setTextColor(colors.lightGray)
            rePass, cancelled = G.ui.Read("*")
            if cancelled then return end
            term.setTextColor(colors.white)

            if pass ~= rePass then
                G.ui.CalcCenter("Passwords do not match.", 0, 5, write, colors.red)
                sleep(2)

                --Clears old passwords from the screen
                G.ui.ClearLine(h/2 + 1) 
                G.ui.ClearLine(h/2 + 3) 
                G.ui.ClearLine(h/2 +5)
            end
        else
            G.ui.ClearLine(h/2 + 3)
            G.ui.ClearLine(h/2 + 5)
            G.ui.ClearLine(h/2 + 1)
        end
    until pass == rePass

    --Check if this is the first account. If so, make them an admin.
    if isFirstUser == nil then
        G.logger.Log("AUTH", "Admin created: "..user)
        users[user].admin = true
    else
        users[user].admin = false
    end


    --Add user to the table
    users[user].password = pass
    file = fs.open("/bolonet/users/users.db", "w")
    if file then
        file.write(textutils.serialize(users))
        file.close()

        term.clear()
        G.ui.CalcCenter("Account successfully created!", 0, 1, write, colors.green)
        G.logger.Log("AUTH", "New account created: "..user)
        sleep(2)
    end
end

local function shutdown()
    term.clear()
    G.ui.CalcCenter("Shutting down in:", 0, -1, write, colors.yellow)

    for i = 3, 1, -1 do
        G.ui.CalcCenter(tostring(i), 0, 1, write, colors.red)
        sleep(1)
    end
    G.logger.Log("SYSTEM", "BoloNet shutdown\n")
    os.shutdown()
    
end

local function signInUser()
    term.clear()

    local user = G.session.GetUser()
    local userPass = G.session.getUserPass()

    --Safety check
    if user == nil or userPass == nil then return end

    G.ui.CalcHCenter("Press 'TAB' to sign out.", 0, h, write, colors.red) --Always on the bottom!
    G.ui.CalcCenter("Please sign back in to continue", 0, -1, write, colors.yellow)
    G.ui.CalcCenter("Username: "..user, 0 , 1, write, colors.white)
    
    local pass, signOut

    repeat
        G.ui.CalcCenter("Password: ", 0  - #user/2, 3, write, colors.white)
        term.setTextColor(colors.lightGray)
        pass, signOut = G.ui.Read("*")
        term.setTextColor(colors.white)

        if signOut then
            G.logger.Log("AUTH", "Logged out '"..user.."'.")
            G.session.ClearUser()
            return
         end

        if pass == userPass then
            term.clear()
            G.logger.Log("AUTH", user.." logged in.")
            G.ui.CalcCenter("Login Successful. Welcome back, ".. user.."!", 0, 0, write, colors.green)
            sleep(1.5)
            shell.run("/bolonet/os/desktop.lua")
        else
            G.logger.Log("AUTH", "Failed login attempt for '"..user.."'.")
            G.ui.CalcCenter("Incorrect Password.", 0, 5, write, colors.red)
            sleep(2)
            G.ui.ClearLine(h/2 + 3)
            G.ui.ClearLine(h/2 + 5)
        end
        
    until pass == userPass


end

local function drawMenu()
    --If a user was signed in
    if isSignedIn == "true" then
        signInUser()
    end

    --If no user was signed in
    local options = {"Sign In", "Sign Up", "Shutdown"}
    local actions = {
    function() login() end,
    function() signUp() end,
    function() shutdown() end}

    G.ui.Navigate(options, actions, "--Login Page--")

end

drawMenu()