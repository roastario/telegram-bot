--
-- Created by IntelliJ IDEA.
-- User: stefanofranz
-- Date: 04/02/15
-- Time: 17:54
-- To change this template use File | Settings | File Templates.
--

local loading_function = loadfile('plugins/shared_plugin_code/shared_reddit.lua')()
local loaded_plugin = loading_function('BlackPeopleTwitter', {'^!bpt (.*)', '^!bpt$'})
return loaded_plugin;

