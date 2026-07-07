--This is where Users sign in/up or power off terminal

local G, isSignedIn= ...
local w, h = term.getSize()




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

local function initDesktopDB(user, isAdmin)
    --Open, read/ save contents, and close file
    local tbl = G.files.getTable("/bolonet/system/desktop.db")

    tbl[user] = {}
    tbl[user].icons = {
        Apps = {x = 2, y = 2},
        Settings = {x = 10, y = 2},
        Logout =  {x = 18, y = 2},
        Shutdown = {x = 26, y = 2}
    }
    if isAdmin then
        tbl[user].icons["Admin Menu"] = {x = 34, y = 2}
    end

    G.files.setTable("/bolonet/system/desktop.db", tbl)
end


--Main Functions

--Initializes all things the user needs
local function initUser(user, isAdmin)
    initDesktopDB(user, isAdmin)
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

            G.files.runScript("/bolonet/os/desktop.lua", G)
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
    local users = G.files.getTable("/bolonet/users/users.db")

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
        initUser(user, users[user].admin)
        sleep(2)
    end
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

        --Run the window that prompts the user if they are sure
        if signOut then
            G.files.runScript("/bolonet/os/logout.lua", G)
         end

        --If signOut is true at this point, then signout was cancelled
        if signOut then
            term.setBackgroundColor(colors.black)
            return signInUser()
        end
        
        --Password checker
        if pass == userPass then
            term.clear()
            G.logger.Log("AUTH", user.." logged in.")
            G.ui.CalcCenter("Login Successful. Welcome back, ".. user.."!", 0, 0, write, colors.green)
            sleep(1.5)
            G.files.runScript("/bolonet/os/desktop.lua", G)
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
    function() G.files.runScript("/bolonet/os/shutdown.lua", G) end}

    G.ui.Navigate(options, actions, "--Login Page--")

end

drawMenu()