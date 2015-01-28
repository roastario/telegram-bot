function appendSender(msg)
    local firstName = string.lower(msg.from.first_name == nil and 'NIL' or msg.from.first_name)
    local lastName = string.lower(msg.from.last_name == nil and 'NIL' or msg.from.last_name)

    if (string.find(firstName, "franz") or string.find(lastName, "franz")) then
        return "!BD " .. msg.text
    else
        return msg.text
    end
end

function run(msg, matches)
        return http.request("http://localhost:8976/think?text="..matches[1])
end

return {
    description = "Ben BullShit Handler",
    usage = "!BD [text]",
    patterns = { "^!BD (.*)$" },
    run = run,
    lex = appendSender
}

