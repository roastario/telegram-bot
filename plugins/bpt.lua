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
                    return image_url
                end
            end
        end
        idx = (idx + 1) % #children
        attempts = attempts + 1
    end

    return nil
end

function run(args)
    local api_url = "http://www.reddit.com/r/BlackPeopleTwitter/search.json?restrict_sr=true&sort=top&t=week&q="
    local msg = args['msg']
    local matches = args['matches']
    local response = http.request(api_url .. matches[1])
    local images = json:decode(response).data.children
    local image_url = get_image_url(images)
    local file = download_to_file(image_url)
    send_document(get_receiver(msg), file, ok_cb, false)
end

function postponed_run(msg, matches)
    local args = {}
    args['msg'] = msg
    args['matches'] = matches
    postpone(run, args, 0.1)
end

return {
    description = "Black People Twitter LOLS",
    usage = {
        "!bpt <term>",
        "!bpt"
    },
    patterns = {
        "^!bpt (.*)",
    },
    run = postponed_run
}

