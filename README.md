# spleef
A Minetest mod for creating spleef arenas by shivajiva101@hotmail.com

This mod is aimed at admins with the server priv for creating spleef arenas, it provides 15 nodes that dig immediately with no return node. A method to select and add the spleef floor to the arena list and a button for resetting the floor using a form to  allow the placer to input the arena it resets.

Commands:

/spleef_pos set/set1/set2/get -- sets/gets the area

/spleef_add <name>  -- adds the arena and saves the schem file

/spleef_remove <name> -- removes <name> from arena list

/spleef_list -- lists arenas

Nodes:

spleef_[colour] -- white,grey,black,red,yellow,orange,mahenta,cyan,blue,green,violet,pink,dark_grey,dark_green

spleef_button

Useage:

Build your arena with spleef_[colour] nodes for the floor. use /spleef_pos set to mark the floor area and then use /spleef_add <name> to save the arena. Place a spleef_button and right click to show it's form and add the same name used when adding the arena, press Proceed, once set punching the button resets the arena floor.

Note: The button code is copied from mesecons wall button, position setting is copied from Areas mod which is copied from WorldEdit. The concept of a user resetable arena floor tied to a button isn't new either...ENJOY!

Todo: Add more spleef nodes, add pressure pad to revoke/grant privs

All textures in this project are licensed under the CC-BY-SA 3.0

Button textures and button sounds by jeija

Wool textures by Cisoun

Position marker textures from WorldEdit mod by Uberi
