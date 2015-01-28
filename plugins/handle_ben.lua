function appendSender(msg)
    local firstName = string.lower(msg.from.first_name == nil and 'NIL' or msg.from.first_name)
    local lastName = string.lower(msg.from.last_name == nil and 'NIL' or msg.from.last_name)

    if (string.find(firstName, "davidson") or string.find(lastName, "davidson")) then
        return "!BD " .. msg.text
    else
        return msg.text
    end
end

function run(msg, matches)



end

function build_run(http)
    local lo_ht = http
    return function(msg, matches)
        return lo_ht.request("http://localhost:8976/think?text="..matches[1])
    end
end

local http = require("socket.http")
return {
    description = "Ben BullShit Handler",
    usage = "!BD [text]",
    patterns = { "^!BD (.*)$" },
    run = build_run(http),
    lex = appendSender
}

