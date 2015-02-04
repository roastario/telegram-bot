return function(subreddit, patterns, should_send_title)
    local IS_IMAGE_WITH_EXTENSION = 0;
    local IS_IMAGE_WITHOUT_EXTENSION = 1;
    local IS_NOT_IMAGE = 2;

    local function is_image(child_data)
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

    local function get_image_url(children)

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
                            image_url = image_url .. ".gif"
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

    local function do_search(term)
        local api_url = "http://www.reddit.com/r/" .. string.url_encode(subreddit) .. "/search.json?restrict_sr=true&sort=top&t=all&q="
        local response = http.request(api_url .. string.url_encode(term))
        local images = json:decode(response).data.children
        local image_url, title = get_image_url(images)
        return image_url, title
    end

    local function do_trending()
        local api_url = "http://www.reddit.com/r/" .. string.url_encode(subreddit) .. "/hot.json"
        local response = http.request(api_url)
        local images = json:decode(response).data.children
        local image_url, title = get_image_url(images)
        return image_url, title
    end

    local function run(args)
        local matches = args['matches']
        local msg = args['msg']
        local receiver = get_receiver(msg)

        local image_url, title, file_path
        if (matches[1] == "!bpt") then
            image_url, title = do_trending();
            file_path = download_to_file(image_url)
        else
            image_url, title = do_search(matches[1])
            file_path = download_to_file(image_url)
        end


        if (should_send_title) then
            send_msg(receiver, title, send_found_image, { receiver, file_path, image_url })
        else
            send_found_image({ receiver, file_path, image_url })
        end

        local function postponed_run(msg, matches)
            local args = {}
            args['msg'] = msg
            args['matches'] = matches
            postpone(run, args, 0.01)
        end

        return {
            description = subreddit .. " LOLS",
            usage = {
                "!sr <term>",
                "!sr"
            },
            patterns = patterns,
            run = postponed_run
        }
    end
end



