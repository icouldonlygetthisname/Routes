-- Routes
-- enUS and enGB Localization file

local L = LibStub("AceLocale-3.0"):NewLocale("Routes", "enUS", true)


L["Routes"] = true
L["routes"] = true -- slash command

-- Options Config
L["Options"] = true
L["Update distance"] = true
L["Yards to move before triggering a minimap update"] = true

-- Map drawing
L["Map Drawing"] = true
L["Toggle drawing on each of the maps."] = true
L["Worldmap"] = true
L["Worldmap drawing"] = true
L["Minimap"] = true
L["Minimap drawing"] = true
L["Zone Map"] = true
L["Zone Map drawing"] = true
L["Minimap when indoors"] = true
L["Draw on minimap when indoors"] = true
L["Set the width of lines on each of the maps."] = true
L["Normal lines"] = true
L["Width of the line in the Worldmap"] = true
L["Width of the line in the Minimap"] = true
L["Width of the line in the Zone Map"] = true
L["Color of lines"] = true
L["Default route"] = true
L["Change default route color"] = true
L["Hidden route"] = true
L["Change default hidden route color"] = true
L["Show hidden routes"] = true
L["Show hidden routes?"] = true
L["Line gaps"] = true
L["Draw line gaps"] = true
L["Shorten the lines drawn on the minimap slightly so that they do not overlap the icons and minimap tracking blips."] = true
L["Skip clustered node points"] = true
L["Do not draw gaps for clustered node points in routes."] = true

-- Auto show/hide
L["Auto show/hide"] = true
L["Auto show and hide routes based on your professions"] = true
L["Use Auto Show/Hide"] = true
L["Auto Show/Hide per route type"] = true
L["Auto Show/Hide settings"] = true
L["Routes with Fish"] = true
L["Routes with Gas"] = true
L["Routes with Herbs"] = true
L["Routes with Ore"] = true
L["Routes with Treasure"] = true
L["Routes with Archaeology"] = true
L["Routes with Notes"] = true
L["Routes with Timber"] = true
L["Always show"] = true
L["Only with profession"] = true
L["Only while tracking"] = true
L["Never show"] = true

-- TomTom
L["Waypoints (TomTom)"] = true
L["Integrated support options for TomTom"] = true
L["This section implements TomTom support for Routes. Click Start to find the nearest node in a visible route in the current zone.\n"] = true
L["Start using TomTom"] = true
L["Start using TomTom by finding the closest visible route/node in the current zone and using that as the waypoint"] = true
L["Stop using TomTom"] = true
L["Stop using TomTom by clearing the last queued node"] = true
L["TomTom is missing or disabled"] = true
L["Start using Waypoints (TomTom)"] = true
L["Stop using Waypoints (TomTom)"] = true
L["Change direction (TomTom)"] = true
L["An updated copy of TomTom is required for TomTom integration to work"] = true
L["Waypoint hit distance"] = true
L["This is the distance in yards away from a waypoint to consider as having reached it so that the next node in the route can be added as the waypoint"] = true
L["Change direction"] = true
L["Change the direction of the nodes in the route being added as the next waypoint"] = true

-- Add Route Config
L["Add"] = true
L["Routes in %s"] = true
L["Name of Route"] = true
L["Name of the route to add"] = true
L["No name given for new route"] = true
L["Select Zone"] = true
L["Zone to create route in"] = true
L["Select sources of data"] = true
L[" Data"] = true
L["Select data to use"] = true
L["Select data to use in the route creation"] = true
L["No data found"] = true
L["Create Route"] = true
L["No data selected for new route"] = true
L["A route with that name already exists. Overwrite?"] = true
L["Create Route from Data Sources"] = true
L["Create Bare Route"] = true
L["CREATE_BARE_ROUTE_DESC"] = "This will create a route with just 3 initial points in it, and does not use any data from any source. You may then manually edit this route to insert and move nodes."
L["Recreate Route"] = true
L["Recreate this route with the same creation settings. NOTE: This only works for data from GatherMate2 and Gatherer."] = true
L["Are you sure you want to recreate this route? This will delete all customized settings for this route."] = true

-- DB prefixes
L["GatherMate2Herb Gathering"] = "Herbalism"
L["GatherMate2Mining"] = "Mining"
L["GatherMate2Fishing"] = "Fishing"
L["GatherMate2Extract Gas"] = "Extract Gas"
L["GatherMate2Treasure"] = "Treasure"
L["GatherMate2Archaeology"] = "Archaeology"
L["GatherMate2Logging"] = "Logging"
L["GathererMINE"] = "Mining"
L["GathererHERB"] = "Herbalism"
L["GathererOPEN"] = "Treasure"

-- Node types
L["Herbalism"] = true
L["Mining"] = true
L["Fishing"] = true
L["Treasure"] = true
L["ExtractGas"] = "Gas"
L["Archaeology"] = true
L["Note"] = true
L["Logging"] = true

-- Route Config
L["When the following data sources add or delete node data, update my routes automatically by inserting or removing the same node in the relevant routes."] = true
L[" Gatherer/HandyNotes currently does not support callbacks, so this is impossible for Gatherer/HandyNotes."] = true
L["You have |cffffd200%d|r route(s) in |cffffd200%s|r."] = true
L["Information"] = true
L["This route has |cffffd200%d|r nodes and is |cffffd200%d|r yards long."] = true
L["This route has nodes that belong to the following categories:"] = true
L["This route contains the following nodes:"] = true
L["This route is not a clustered route."] = true
L["This route is a clustered route, down from the original |cffffd200%d|r nodes."] = true
L["|cffffd200     %d|r node(s) are between |cffffd200%d|r-|cffffd200%d|r yards of a cluster point"] = true
L["|cffffd200     %d|r node(s) are at |cffffd2000|r yards of a cluster point"] = true
L["The cluster radius of this route is |cffffd200%d|r yards."] = true

L["Line Settings"] = true
L["These settings control the visibility and look of the drawn route."] = true
L["Width (Map)"] = true
L["Width of the line in the map"] = true
L["Width (Minimap)"] = true
L["Width of the line in the Minimap"] = true
L["Width (Zone Map)"] = true
L["Width of the line in the Zone Map"] = true
L["Line Color"] = true
L["Change the line color"] = true
L["Hide Route"] = true
L["Hide the route from being shown on the maps"] = true
L["Delete"] = true
L["Permanently delete a route"] = true
L["Are you sure you want to delete this route?"] = true
L["You may not delete a route that is being optimized in the background."] = true
L["Reset"] = true
L["Reset the line settings to defaults"] = true

L["Optimize Route"] = true
L["Route Optimizing"] = true
L["Extra optimization"] = true
L["ExtraOptDesc"] = "Turning on this option will make optimizing the route take approximately 40% longer, but will generate -slightly- better routes. Recommended setting is OFF."
L["Foreground"] = true
L["Foreground Disclaimer"] = "Generate close to optimal path for the set of nodes in this route. Please keep in mind that doing this will 'hang' your client for some time. Depending on the amount of nodes (more cause near exponential increase in time) and CPU speed you might even get a disconnect if it takes too long."
L["Background"] = true
L["Background Disclaimer"] = "This will perform the TSP route generation in the background much more slowly without locking up WoW. Please note that your WoW will still take a noticable performance hit."
L["Path with %d nodes found with length %.2f yards after %d iterations in %.2f seconds."] = true
L["Now running TSP in the background..."] = true
L["There is already a TSP running in background. Wait for it to complete first."] = true
L["The following error occured in the background path generation coroutine, please report to Grum or Xinhuan:"] = true
L["The following error occured in the background clustering coroutine, please report to Grum or Xinhuan:"] = true
L["TOO_MANY_NODES_ERROR"] = "This route has more than 724 nodes. Please reduce it by removing some nodes or by clustering otherwise memory allocation errors will occur."
L["Pass %d: %d%% - %d yards"] = true
L["Pass %d: %d%%"] = true

L["Route Clustering"] = true
L["CLUSTER_DESC"] = "Clustering a route makes Routes take all the nodes that are near each other and combine then into a single node as a travel point. This process takes a while, but is reasonably fast."
L["Cluster Radius"] = true
L["CLUSTER_RADIUS_DESC"] = "The maximum distance a node will be away from its cluster node point. The default is 60 yards because the detection radius of tracking skills is 80 yards."
L["Cluster"] = true
L["Cluster (in Background)"] = true
L["Cluster this route"] = true
L["Cluster this route in the background"] = true
L["Background Route Clustering completed."] = true
L["Now running route clustering in the background..."] = true
L["Uncluster"] = true
L["Uncluster this route"] = true

L["Edit Route Manually"] = true
L["Edit route"] = true
L["Edit this route on the world map"] = true
L["Save route edit"] = true
L["Stop editing this route on the world map and save the edits"] = true
L["Cancel route edit"] = true
L["Stop editing this route on the world map and abandon changes made"] = true
L["ROUTE_EDIT_DESC"] = [[
To edit a route, click on the |cffffd200Edit|r button. The route will be drawn on the World Map. Drag the nodes to position them, left click on an in-between vertex to add nodes, right click on them to delete. After editing, you may click the |cffffd200Save|r button to save your changes, or the |cffffd200Cancel|r button to discard your changes.

Please note that you cannot edit a route when it is being optimized in the background or if the route is a clustered route.
]]

-- Profession Names in the skills tab in the character frame
-- Doing these 4 localizations specifically to avoid using Babble-Spell
L["Skill-Fishing"] = "Fishing"
L["Skill-Herbalism"] = "Herbalism"
L["Skill-Mining"] = "Mining"
L["Skill-Engineering"] = "Engineering"

-- Cartographer_Waypoints support
L["Cartographer_Waypoints module is missing or disabled"] = true
L["%s - Node %d"] = true
L["Direction changed"] = true

-- Taboo stuff
L["Routes Node Menu"] = true
L["Delete node"] = true
L["Add node before (red)"] = true
L["Add node after (green)"] = true
L["You may not delete a taboo that is being edited."] = true
L["TABOO_EDIT_DESC"] = "To edit a taboo region, click on the |cffffd200Edit|r button. The taboo region will be drawn on the World Map. Drag the vertexes to position them. Right click on the vertexes to add or delete vertexes. After editing, you may click the |cffffd200Save|r button to save your changes, or the |cffffd200Cancel|r button to discard your changes."
L["Edit taboo region"] = true
L["Edit this taboo region on the world map"] = true
L["Save taboo edit"] = true
L["Stop editing this taboo region on the world map and save the edits"] = true
L["Cancel taboo edit"] = true
L["Stop editing this taboo region on the world map and abandon changes made"] = true
L["Delete Taboo"] = true
L["Delete this taboo region permanently. This will also remove it from all routes that use it."] = true
L["Are you sure you want to delete this taboo? This action will also remove the taboo from all routes that use it."] = true
L["TABOO_DESC"] = "Taboo regions are areas which you can define to exclude nodes. Once you have created a taboo region, you can attach the taboo region to an existing route, and all nodes inside this region will be removed and no new ones will be added to it."
L["Name of Taboo"] = true
L["Name of taboo region to add"] = true
L["No name given for new taboo region"] = true
L["Zone to create taboo in"] = true
L["Create Taboo"] = true
L["Taboos in %s"] = true
L["A taboo with that name already exists. Overwrite?"] = true
L["This route has the following taboo regions:"] = true
L["This route has no taboo regions."] = true
L["This route contains |cffffd200%d|r nodes that have been tabooed."] = true
L["TABOO_DESC2"] = "Taboo regions are areas you specify for a route to ignore. Nodes in these taboo regions are ignored and not included in a route. Additionally when optimizing a route, the generated route will attempt to avoid crossing any taboo regions if possible."
L["Taboos"] = true
L["Select taboo regions to apply:"] = true
L["You have |cffffd200%d|r taboo region(s) in |cffffd200%s|r."] = true

-- FAQ
L["Help File"] = true
L["Overview"] = true
L["Creating a route"] = true
L["Optimizing a route"] = true
L["Customizing route display"] = true
L["Creating a taboo region"] = true
L["Waypoints Integration"] = true
L["Automatic route updating"] = true
L["FAQ"] = true
L["Frequently Asked Questions"] = true
L["FAQ_TEXT"] = [[
|cffffd200
When I try to create a route, it says no data is found. What am I doing wrong?
|r
Routes can only use nodes your data source addon knows about in that zone. Make sure the addon (|cffffff78GatherMate2|r, |cffffff78GatherLite|r, |cffffff78Gatherer|r or |cffffff78HandyNotes|r) is enabled, that it is ticked under |cffffff78Select sources of data|r on the |cffffff78Add|r page, and that it has nodes in the selected zone. For GatherMate2 you can import the WoWHead data from |cffffff78GatherMate2_Data|r in GatherMate2's own options.

|cffffd200
I gathered new nodes, why don't they show up on the Add page?
|r
They do: the list of node types is refreshed every time it is shown, no reload is needed. If you have routes in that zone, new nodes are also added to them automatically, see |cffffff78Automatic route updating|r.

|cffffd200
I made a route with only some node types, but it contains other nodes as well.
|r
A route is made of every node of each node type that is ticked. GatherMate2 also stores some variants of a node under one name (for example all the different kinds of Azeroot are stored as Azeroot), so they show up as one entry. Node type selections are cleared after each route is created, so earlier selections are not carried over.

|cffffd200
How do I know how far a background optimization has got?
|r
While it runs, the status bar at the bottom of the Routes window shows the current pass, how far it is through that pass and the length of the best route found so far. It is not possible to say up front how many passes it needs: each pass improves on the previous one, and it stops once a pass no longer finds a shorter route.

|cffffd200
How does Routes optimize a route?
|r
For routes with up to 724 nodes, Routes uses |cffffff78Ant Colony Optimization|r (ACO), a probabilistic method based on how real ants find short paths, combined with |cffffff782-opt|r. It finds near-optimal solutions to the |cffffff78Traveling Salesman Problem|r (TSP).

ACO needs a table with an entry for every pair of nodes, which WoW cannot hold for more than 724 nodes. Larger routes are optimized with a nearest neighbour tour improved by 2-opt instead. It is much faster and usually within a few percent of ACO. The same fast method gives new routes their initial order.

|cffffd200
What does the "Extra optimization" option do?
|r
By default, ACO is combined with the |cffffff782-opt|r algorithm, which swaps pairs of edges (A-B and C-D become A-C and B-D) whenever that makes the route shorter. Extra optimization also uses 2.5-opt, which moves single nodes to a better place in the route. It takes about 40% longer for slightly better routes.

|cffffd200
What algorithm does node clustering use?
|r
Hierarchical agglomerative clustering with a greedy approach: the two closest points within twice the cluster radius are repeatedly merged, as long as every original node stays within the cluster radius of the merged point. The result is always the same for the same route.

|cffffd200
I created a taboo region, attached it to a route, and optimized it. My route still goes through the taboo region. Why?
|r
It is not always possible, or sensible, to find a route that avoids a taboo region. Taboo regions could split the map into parts that can't be reached, so the optimization is only biased against crossing them.

|cffffd200
I've found a bug! Where do I report it?
|r
Report bugs and suggestions on the GitHub issue tracker at |cffffff78https://github.com/Nevcairiel/Routes/issues|r

Include the |cffffff78steps to reproduce the bug|r, any |cffffff78error messages|r with stack traces (BugSack makes this easy), the |cffffff78version|r of Routes and whether you are using an |cffffff78English client or otherwise|r.

|cffffd200
Who wrote this cool addon?
|r
|cffffff78Xaros|r on EU Doomhammer Alliance & |cffffff78Xinhuan|r on US Blackrock Alliance wrote it, and it is maintained by |cffffff78Nevcairiel|r.
]]
L["OVERVIEW_TEXT"] = [[
|cffffff78Routes|r is an addon designed to make gathering things more efficient. It does this by generating efficient farming routes based on what you want to farm, using the node data from your |cffffff78GatherMate2|r, |cffffff78GatherLite|r, |cffffff78Gatherer|r or |cffffff78HandyNotes|r addons. These routes are then drawn on your world map, zone map and minimap so you can follow them easily and quickly.

The |cffffff78Travelling Salesman Problem|r (TSP) is a traditional problem where given N cities and the distances between any pair of cities, find the shortest tour that visits all of the cities exactly once and return to the starting city. The same problem is applied to the gathering nodes in World of Warcraft to find the shortest possible route to visit every known spawn point in a circuit.
]]
L["CREATE_ROUTE_TEXT"] = [[
To create a route, go to the |cffffff78Add|r section on the left side.

|cffffff781.|r Type a name in |cffffff78Name of Route|r and press |cffffff78ENTER|r or click |cffffff78Okay|r.

|cffffff782.|r Choose the zone in |cffffff78Select Zone|r. It starts out as the zone currently shown on your world map.

|cffffff783.|r Under |cffffff78Create Route from Data Sources|r, tick the addons to use in |cffffff78Select sources of data|r.

|cffffff784.|r Tick the node types you want in the route in the list for each source, for example |cffffff78GatherMate2 Data|r. The number after each node type is how many of those nodes are known in the zone.

|cffffff785.|r Click |cffffff78Create Route|r.


|cffffd200Notes:|r

* The name only counts once you press |cffffff78ENTER|r or click |cffffff78Okay|r, the |cffffff78Create Route|r buttons stay disabled until then. Using an existing name asks whether to overwrite that route.

* The new route is drawn on your maps right away, and shows up under |cffffff78Routes|r on the left side, grouped by zone. It is given a quick initial order so it is usable straight away, but optimizing it gives a shorter route. See |cffffff78Optimizing a route|r.

* |cffffff78Create Bare Route|r creates a route with just 3 points that doesn't use any data. You can then place the nodes yourself with the route's |cffffff78Edit Route Manually|r tab.

* |cffffff78Recreate Route|r on a route's page builds the route again from the same node types, picking up any nodes found since.
]]
L["OPTIMIZING_ROUTE_TEXT"] = [[
New routes start out with a quick initial order. To make them shorter, go to your route under |cffffff78Routes|r on the left side and open the |cffffff78Optimize Route|r tab.

Route optimization has 2 parts. The first is Route Clustering, the second is Route Optimizing.

|cffffff781.|r Optionally set the |cffffff78Cluster Radius|r and click |cffffff78Cluster|r or |cffffff78Cluster (in Background)|r.

|cffffff782.|r Click |cffffff78Foreground|r or |cffffff78Background|r under |cffffff78Route Optimizing|r and wait.


|cffffd200Notes:|r

* Route clustering is optional. It combines nodes that are close to each other into a single travel point, so you visit them together. Clustering can be undone with |cffffff78Uncluster|r, no node data is lost. Clustered routes can't be edited manually.

* Foreground and background optimization give the same results. Foreground freezes WoW until it is done, background runs while you keep playing at a lower frame rate, and shows its progress in the status bar at the bottom of the Routes window.

* Use foreground for small routes (less than about 100 nodes) and background for bigger ones. A long foreground optimization can make WoW stop the script or even disconnect you.

* Routes with up to 724 nodes are optimized with |cffffff78Ant Colony Optimization|r, which uses random numbers to simulate ants. Optimizing the same route again can give a different, possibly shorter, result. Routes keeps the shorter of the old and new route.

* Routes with more than 724 nodes use a faster method instead, see the |cffffff78FAQ|r. Clustering first reduces the number of nodes.

* |cffffff78Extra optimization|r takes about 40% longer for slightly shorter routes. It only applies to routes with up to 724 nodes.

* If the optimized route still crosses itself somewhere, optimize it again.
]]
L["CUSTOMIZING_ROUTE_TEXT"] = [[
You can customize how your routes are drawn. The |cffffff78Options|r section on the left contains settings that apply to all routes, and the |cffffff78Line Settings|r tab of each route overrides them for that route.

|cffffff78Options|r > |cffffff78Map Drawing|r sets which maps routes are drawn on (|cffffff78Worldmap|r, |cffffff78Minimap|r, |cffffff78Zone Map|r and |cffffff78Minimap when indoors|r), the width of the lines on each map and the color of normal and hidden routes. |cffffff78Draw line gaps|r leaves gaps in the minimap lines around nodes, so they don't cover the yellow tracking blips and the icons of your gathering addons.

In a route's |cffffff78Line Settings|r tab you can set its |cffffff78Line Color|r and widths, or tick |cffffff78Hide Route|r to stop drawing a route you don't want to use but don't want to delete either. |cffffff78Reset|r goes back to the global settings. The |cffffff78Show hidden routes|r option on the |cffffff78Map Drawing|r page draws hidden routes anyway, in the hidden route color.

|cffffff78Options|r > |cffffff78Auto show/hide|r shows or hides routes based on the types of nodes in them. For each type (herbs, ore, fish, gas, treasure, archaeology, timber and notes) you can choose to always show the routes, only show them when you have the profession, only while the matching tracking ability is active, or never (not every choice exists for every type). A route with several node types is shown when any of its types should be shown.
]]
L["CREATE_TABOOS_TEXT"] = [[
|cffffff78Taboo regions|r are areas (2D polygons) on the world map that you want Routes to stay out of. Nodes inside a taboo region are left out of routes that use it, and optimizing tries to keep the route from crossing it. This is very useful for places that are out of the way, such as floating islands, caves, tall mountains, enemy towns and so on.

Taboo regions are created using the following steps:

|cffffff781.|r Go to the |cffffff78Taboos|r section on the left side.

|cffffff782.|r Type a name in |cffffff78Name of Taboo|r and press |cffffff78ENTER|r or click |cffffff78Okay|r.

|cffffff783.|r Choose the zone in |cffffff78Select Zone|r.

|cffffff784.|r Click |cffffff78Create Taboo|r.

|cffffff785.|r Select the new taboo region under |cffffff78Taboos|r on the left side.

|cffffff786.|r Click |cffffff78Edit taboo region|r.

|cffffff787.|r Open the world map and go to the taboo region's zone if needed.

|cffffff788.|r You will see a triangular shaded region on the map. Change its shape by
a) |cffffff78Dragging|r the points of the polygon;
b) |cffffff78Left-clicking|r a point in between two points to add it to the polygon;
c) |cffffff78Right-clicking|r a point to remove it.

|cffffff789.|r Click |cffffff78Save taboo edit|r to save your changes, or |cffffff78Cancel taboo edit|r to throw them away.

Taboo regions can cross over themselves and have as many points as you like, so you can make them as detailed as you want.


|cffffd200Notes:|r

* To use a taboo region, tick it in the |cffffff78Taboos|r tab of a route. Optimize the route again after adding or removing taboo regions.

* Editing a taboo region affects all routes that use it, and deleting a taboo region removes it from all routes that use it.
]]
L["WAYPOINTS_INTEGRATION_TEXT"] = [[
Routes can use |cffffff78TomTom|r's waypoint arrow to guide you along your routes, so you don't get lost among the lines.

Go to a zone with a visible route, open |cffffff78Options|r > |cffffff78Waypoints (TomTom)|r and click |cffffff78Start using TomTom|r. Routes finds the closest node of the visible routes in your zone and sets it as a TomTom waypoint. TomTom's arrow then shows the direction and distance to it.

When you get within the |cffffff78Waypoint hit distance|r of the node, Routes sets the next node in the route as the waypoint, and so on. Click |cffffff78Stop using TomTom|r to remove the waypoint, and |cffffff78Change direction|r to go through the route the other way.

You can set keybinds for start, stop and change direction on the same page, or in the game's Key Bindings under |cffffff78Routes|r.


|cffffd200Notes:|r

* The |cffffff78Waypoints (TomTom)|r options are disabled when TomTom isn't loaded.

* TomTom 4.2.6 to 4.2.11 never told Routes when a waypoint was reached, so the next node wasn't set. Update TomTom if the arrow stops at the first node.
]]
L["AUTOMATIC_UPDATE_TEXT"] = [[
Routes can keep your routes up to date with your data source addon. When |cffffff78GatherMate2|r finds a new node, Routes adds it to the routes in that zone that contain that node type, at the best place in the route. When a node is deleted in GatherMate2, Routes removes it from those routes too. |cffffff78GatherLite|r only reports new nodes, and |cffffff78Gatherer|r and |cffffff78HandyNotes|r can't be updated automatically.

Moving a node is handled as deleting it and adding it again in its new place, which is also how GatherMate2 does it.

To turn automatic updating on or off:

|cffffff781.|r Click |cffffff78Routes|r on the left side of the Routes window.

|cffffff782.|r Tick or untick each data source.
]]
-- vim: ts=4 noexpandtab
