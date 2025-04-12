local satellite_mode = data.raw["god-controller"]["default"]
satellite_mode.item_pickup_distance = 0
satellite_mode.loot_pickup_distance = 0
satellite_mode.mining_speed = 0.0000001 -- somhow ghosts can be mined, but nothing else
satellite_mode.movement_speed = 1