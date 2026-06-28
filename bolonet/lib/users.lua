local usersFuncs = {}
local logger = require("/bolonet/lib/logger")

function usersFuncs.IsAdmin(user)
    local file = fs.open("/bolonet/users/users.db", "r")

    if file == nil then
        logger.Log("ERROR", "Could not open users.db file.")
        error("Users.db could not be opened.", 1)
    end

    local users = textutils.unserialize(file.readAll() or "")

    --Safety check for users
    if users == nil then
        logger.Log("ERROR", "File: 'users.db' is empty")
        error("Users.db is empty.", 1)
    end

    return users[user].admin
end

return usersFuncs