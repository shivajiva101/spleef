# spleef
A Minetest mod for creating spleef arenas by shivajiva101@hotmail.com

This mod is aimed at admins with the server priv for creating spleef arenas, it provides 2 nodes that dig immediately with no return node. A method to select and add the spleef floor to the arena list and a button for resetting the floor using a form to  allow the placer to input the arena it resets.

Commands:

/spleef_pos set/set1/set2/get -- sets/gets the area

/spleef_add <name>  -- adds the arena and saves the schem file

/spleef_remove <name> -- removes <name> from arena list

/spleef_list -- lists arenas

Nodes:

spleef_white

spleef_black

spleef_button

Useage:

Build your arena making sure you only use spleef_black and spleef_white for the floor. use /spleef_pos set to mark the floor area and then use /spleef_add <name> to save the arena. Place a spleef_button to show a form and add the name you used when adding the arena, press save and then punching the button it will reset the arena floor.

Todo:

Add more spleef nodes, add pressure pad to revoke/grant privs
