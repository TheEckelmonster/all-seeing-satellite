-- If already defined, return
if _planet_service and _planet_service.all_seeing_satellite then
    return _planet_service
end

local Constants = require("libs.constants.constants")
local Log = require("libs.log.log")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")

local planet_service = {}

function planet_service.on_surface_created(event)
    Log.debug("planet_service.on_surface_created")
    Log.info(event)

    if (not game) then return end
    if (not event) then return end
    if (not event.surface_index or event.surface_index < 1) then return end

    local surface = game.get_surface(event.surface_index)
    if (not surface or not surface.valid) then return end

    local planets = Constants.get_planets(true)
    Log.info(planets)
    local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(surface.name)
    Log.info(satellite_meta_data)
    if (not satellite_meta_data.valid) then
        Satellite_Meta_Repository.save_satellite_meta_data(surface.name)
    end
end

planet_service.all_seeing_satellite = true

local _planet_service = planet_service

return planet_service