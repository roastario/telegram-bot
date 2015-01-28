--
-- Created by IntelliJ IDEA.
-- User: stefanofranz
-- Date: 28/01/15
-- Time: 10:50
-- To change this template use File | Settings | File Templates.
--

function appendSender(msg)
    local firstName = string.lower(msg.from.first_name == nil and 'NIL' or msg.from.first_name)
    local lastName = string.lower(msg.from.last_name)

    if (string.find(firstName, "davidson") or string.find(lastName, "davidson")) then
        return "!BD " .. msg.text
    else
        return msg.text
    end

end

function run(msg, matches)
    print ("I WOULDA PROCESSED THE SHIT OUT OF THIS: " .. matches[1])
end

return {
    description = "search image with Google API and sends it",
    usage = "!BD [text]",
    patterns = {"^!BD (.*)$"},
    run = run
}

