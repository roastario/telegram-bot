-- Idea by https://github.com/asdofindia/telegram-bot/
-- See http://api.giphy.com/

function get_random_top()
    local api_key = "dc6zaTOxFJmzC" -- public beta key
    local b = http.request("http://api.giphy.com/v1/gifs/trending?api_key=" .. api_key)
    local images = json:decode(b).data
    math.randomseed(os.time())
    local i = math.random(0, #images)
    return images[i].images.downsized.url
end


function get_image(images)

    local idx = math.random(0, #images)
    local attempts = 0;

    while (attempts < #images) do
        local image = images[idx]
        if (image ~= nil) then
            return image
        end
        idx = (idx + 1) % #images
        attempts = attempts + 1
    end

    return nil
end

function search(text, isMp4)
    local api_key = "dc6zaTOxFJmzC" -- public beta key
    local b = http.request("http://api.giphy.com/v1/gifs/search?q=" .. text .. "&api_key=" .. api_key)
    local images = json:decode(b).data
    math.randomseed(os.time())
    if (#images == 0) then
        print("NO Images Found for term: " .. text)
        return nil
    end

    local image = get_image(images)

    if (image == nil) then
        print("something went wrong")
    end


    if (image.images.original.mp4 and isMp4) then
        return image.images.original.mp4
    else
        return image.images.downsized.url
    end
end

function run(args)
    -- If no search data, a cat gif will be sended
    -- Because everyone loves pussies

    local matches = args.matches
    local msg = args.msg

    if matches[1] == "!gif" or matches[1] == "!giphy" then
        local gif_url = get_random_top()
        local file = download_to_file(gif_url)
        send_document(get_receiver(msg), file, ok_cb, false)
    else
        local gif_url = search(url_encode(matches[1]), string.starts(msg.text, "!mp4"))
        local file = download_to_file(gif_url)

        if (string.ends(gif_url, "mp4")) then
            send_video(get_receiver(msg), file, ok_cb, false)
        else
            send_video(get_receiver(msg), file, ok_cb, false)
        end
    end
end

function postponed_run(msg, matches)
    local args = {}
    args['msg'] = msg
    args['matches'] = matches
    postpone(run, args, 0.1)
end

return {
    description = "GIFs from telegram with Giphy API",
    usage = {
        "!gif (term): Search and sends GIF from Giphy. If no param, sends a trending GIF.",
        "!giphy (term): Search and sends GIF from Giphy. If no param, sends a trending GIF."
    },
    patterns = {
        "^!gif$",
        "^!gif (.*)",
        "^!mp4 (.*)",
        "^!giphy (.*)",
        "^!giphy$"
    },
    run = postponed_run
}