local enabled_file = './data/subreddit_control.lua'




local function read_enabled_file()
    local f = io.open(enabled_file, "r+")
    -- If file doesn't exists
    if f == nil then
        -- Create a new empty table
        print('Created new sub_reddit control file ' .. enabled_file)
        serialize_to_file({}, enabled_file)
    else
        print('Sub reddit control file loaded: ' .. enabled_file)
        f:close()
    end
    return loadfile(enabled_file)()
end

local function update_enabled_file(enabled_state, chat, subreddit, enabled)
    if (enabled_state[chat] == nil) then
        enabled_state[chat] = {}
    end
    enabled_state[chat][subreddit] = enabled;
    serialize_to_file(enabled_state, enabled_file)
end


local function run(msg, matches)
    local subreddit = matches[1]
    local chat_id = tostring(msg.to.id)
    local enabled = string.starts("1", matches[2]);
    local enabled_state = read_enabled_file()
    local controlling_user = tostring(msg.from.id)
    update_enabled_file(enabled_state, chat_id, subreddit, enabled);
    local text;
    if (enabled) then
        text = "PARTY!!! " .. controlling_user .. " HAS ENABLED " .. subreddit;
    else
        text = "BOOOOOO " .. controlling_user .. " HAS DISABLED " .. subreddit;
    end
    return text

end

return {
    description = "Reddit Control",
    usage = "!rc subreddit enable/disable",
    patterns = { "^!rc ([%a_]+) (.+)$" },
    run = run
}