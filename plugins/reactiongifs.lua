local loading_function = loadfile('plugins/shared_plugin_code/shared_reddit.lua')()
local loaded_plugin = loading_function('reactiongifs', '^!rg$', '^!rg (.*)')
return loaded_plugin;
