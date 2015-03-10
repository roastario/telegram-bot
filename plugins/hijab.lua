function googlethat()
    local api = "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&"
    local start = math.random(1024)
    local parameters = "q=" .. (URL.escape("hijab") or "") .. "&" .. "start=" .. start

    -- Do the request
    local res, code = https.request(api .. parameters)
    if code ~= 200 then return nil end
    local data = json:decode(res)
    local results = data.responseData.results


    if (#results == 0) then
        return nil
    end
    local result = results[1]
    
    return result.url

end

local function send_found_image(cb_extra, success, result)
    if success then

        print(cb_extra[3])
        if (cb_extra[3] and string.ends(string.lower(cb_extra[3]), "gif")) then
            send_document(cb_extra[1], cb_extra[2], ok_cb, false)
        else
            send_photo(cb_extra[1], cb_extra[2], ok_cb, false)
        end
    end
end

function run(msg, matches)
    local receiver = get_receiver(msg)
    local url = googlethat()
    local file_path = download_to_file(url)
    send_found_image({ receiver, file_path, url}, true)
end

return {
    description = "Searches Google and send results",
    usage = "!hj",
    patterns = {
        "^!hj.*$",
    },
    run = run
}
