--
-- Created by IntelliJ IDEA.
-- User: stefanofranz
-- Date: 04/02/15
-- Time: 15:18
-- To change this template use File | Settings | File Templates.
--


local IS_IMAGE_WITH_EXTENSION = 0;
local IS_IMAGE_WITHOUT_EXTENSION = 1;
local IS_NOT_IMAGE = 2;

function is_image(child_data)
    local valid_image_formats = { 'gif', 'jpg', 'jpeg', 'png' }
    if (child_data.url ~= nil) then
        local local_case_url = string.lower(child_data.url)
        for format_idx = 1, #valid_image_formats, 1 do
            local format = valid_image_formats[format_idx]
            if (string.ends(local_case_url, format)) then
                return IS_IMAGE_WITH_EXTENSION
            end
        end
    end
    local domain = child_data.domain
    if (domain ~= nil) then
        if (domain == 'imgur.com') then
            return IS_IMAGE_WITHOUT_EXTENSION
        end
    end
    return IS_NOT_IMAGE
end

function get_image_url(children)

    local idx = math.random(#children)
    local attempts = 0;

    while (attempts < #children) do
        local child = children[idx]
        if (child ~= nil) then
            if (child.data ~= nil) then
                local image_result = is_image(child.data)
                if (image_result > IS_IMAGE_WITHOUT_EXTENSION) then
                    --NOT IMAGE
                else
                    local image_url = child.data.url
                    if (image_result > IS_IMAGE_WITH_EXTENSION) then
                        image_url = image_url .. ".png"
                    end
                    return image_url, child.data.title
                end
            end
        end
        idx = (idx + 1) % #children
        attempts = attempts + 1
    end

    return nil
end

function send_found_image(cb_extra, success, result)
    if success then
        send_photo(cb_extra[1], cb_extra[2], ok_cb, false)
    end
end

function do_search(term)
    local api_url = "http://www.reddit.com/r/BlackPeopleTwitter/search.json?restrict_sr=true&sort=top&t=all&q="
    local response = http.request(api_url .. string.url_encode(term))
    local images = json:decode(response).data.children
    local image_url, title = get_image_url(images)
    return image_url, title
end

function do_trending()
    local api_url = "http://www.reddit.com/r/BlackPeopleTwitter/hot.json"
    local response = http.request(api_url)
    local images = json:decode(response).data.children
    local image_url, title = get_image_url(images)
    return image_url, title
end

function run(args)
    local matches = args['matches']
    local msg = args['msg']
    local receiver = get_receiver(msg)

    local image_url,title;
    if (matches[1] == "!bpt")then
        print ("DOING TRENDING")
        image_url, title = do_trending();
        local file_path = download_to_file(image_url)
        send_msg(receiver, title, send_found_image, {receiver, file_path})
    else
        image_url, title = do_search(matches[1])
        local file_path = download_to_file(image_url)
        send_msg(receiver, title, send_found_image, {receiver, file_path})
    end

end

function postponed_run(msg, matches)
    local args = {}
    args['msg'] = msg
    args['matches'] = matches
    postpone(run, args, 0.01)
end

return {
    description = "Black People Twitter LOLS",
    usage = {
        "!bpt <term>",
        "!bpt"
    },
    patterns = {
        "^!bpt (.*)",
        "^!bpt$"
    },
    run = postponed_run
}

