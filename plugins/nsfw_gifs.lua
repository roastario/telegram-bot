local loading_function = loadfile('plugins/shared_plugin_code/shared_reddit.lua')()
local loaded_plugin = loading_function('nsfw_gif', "^!bpt$", "^!bpt (.*)")
return loaded_plugin;
