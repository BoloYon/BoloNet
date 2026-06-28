
local session = {}

local currentUser = nil
local currentUserPass = nil


--When a user logs in, store them as currUser
function session.SetUser(user)
    currentUser = user
    --Now we can save the user for our getter functions
    local file = fs.open("/bolonet/system/session.db", "w")

    --Safety check
    if file == nil then error("Could not acces session.db.", 1) end

    --Store user into session.db
    file.write(currentUser)
    file.close()

end

--Use when a funnction needs user
function session.GetUser()
    --Avoid unneeded opening of files
    if currentUser == nil then
        local file = fs.open("/bolonet/system/session.db", "r")
        if file then
            currentUser = file.readLine()
            file.close()
        else
            error("session.db could not be opened.", 1)
        end
    end

    return currentUser
end

function session.getUserPass()
    --Avoid unneeded opening of files
    if currentUserPass == nil then
        --Open up users.db for password
        local file = fs.open("/bolonet/users/users.db", "r")
        if file == nil then error("Could not access users.db", 1) end

        local content = file.readAll()
        local users = textutils.unserialize(content or "")

        if users then 
            currentUserPass = users[session.GetUser()].password
        else
            error("Users table was not found.", 1)
        end
    end

    return currentUserPass
end

--When a user logs out
function session.ClearUser()
    currentUser = nil
    currentUserPass = nil

    local file = fs.open("/bolonet/system/session.db", "w")
    if file then 
        file.write("") 
        file.close()
    else 
        error("session.db could not be opened", 1)
    end
end

return session