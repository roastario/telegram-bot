local loading_function = loadfile('plugins/shared_plugin_code/shared_reddit.lua')()
local loaded_plugin = loading_function('BlackPeopleTwitter', {'^!bpt (.*)', '^!bpt$'}, true)
return loaded_plugin;

