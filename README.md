# Spiraling Fools

Spiraling fool is the game done during the Boss Rush Jam.


## World
We decided to expand the game wiht a central hub where you can talk and fight with characters.
We are using the solana tileset, that has non-complementary tiles: this means that you have the dirt tiles and the grass tiles in two different set of tiles, and therefore you need to use two map layers, one per ground type, in order to have correct layering.
There is a third layer with objects with collision and even a scen with a house.
The code is in a generic world scene, where all the layers are setup, and then you can create your world instancing this scene.
