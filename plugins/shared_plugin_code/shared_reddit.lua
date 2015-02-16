return function(subreddit, trending_pattern, search_pattern)

    local captured_subreddit = subreddit;
    local captured_patterns = { trending_pattern, search_pattern };
    local IS_IMAGE_WITH_EXTENSION = 0;
    local IS_IMAGE_WITHOUT_EXTENSION = 1;
    local IS_NOT_IMAGE = 2;

    local enabled_file = './data/subreddit_control.lua'

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
        return IS_NOT_IMAGE
    end

    local function get_image_url(children)
        if (#children == 0) then
            return nil
        end

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
        local api_url = "http://www.reddit.com/r/" .. string.url_encode(captured_subreddit) .. "/search.json?restrict_sr=true&sort=top&t=all&q="
        local response = http.request(api_url .. string.url_encode(term))
        local images = json:decode(response).data.children
        local image_url, title = get_image_url(images)
        return image_url, title
    end

    local function do_trending()
        local api_url = "http://www.reddit.com/r/" .. string.url_encode(captured_subreddit) .. "/hot.json"
        local response = http.request(api_url)
        local images = json:decode(response).data.children
        local image_url, title = get_image_url(images)
        return image_url, title
    end

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

    local function isEnabled(chat)
        local enabled_file = read_enabled_file()
        local chat_table = enabled_file[chat];
        if (chat_table == nil) then
            return true
        end
        if (chat_table[captured_subreddit] ~= nil) then
            return chat_table[captured_subreddit] == true
        end
        return true

    end

    local function run(args)
        local matches = args['matches']
        local msg = args['msg']
        local receiver = get_receiver(msg)

        local image_url, title, file_path
        if (string.match(matches[1], trending_pattern)) then
            image_url, title = do_trending();

        else
            image_url, title = do_search(matches[1])
        end

        if (image_url == nil) then
            print("Term: " .. matches[1] .. ' not found')
            send_found_image({ receiver, 'plugins/shared_plugin_code/not_found.jpg', 'www.not.com/file.jpg' }, true)
        else
            file_path = download_to_file(image_url)
            send_found_image({ receiver, file_path, image_url }, true)
        end
    end

    local function postponed_run(msg, matches)
        local args = {}
        args['msg'] = msg
        args['matches'] = matches

        local chat_id = tostring(msg.to.id)

        if (isEnabled(chat_id)) then
            postpone(run, args, 0.01)
        else
        end
    end



    return {
        description = captured_subreddit .. " LOLS",
        usage = {
            "!sr <term>",
            "!sr"
        },
        patterns = captured_patterns,
        run = postponed_run
    }
end