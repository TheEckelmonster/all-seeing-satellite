-- If already defined, return
if _rocket_silo_utils and _rocket_silo_utils.all_seeing_satellite then
  return _rocket_silo_utils
end

local Constants = require("libs.constants.constants")
local Initialization = require("scripts.initialization")
local Log = require("libs.log.log")
local Satellite_Meta_Repository = require("scripts.repositories.satellite-meta-repository")
local Rocket_Silo_Repository = require("scripts.repositories.rocket-silo-repository")
local String_Utils = require("scripts.utils.string-utils")

local rocket_silo_utils = {}

function rocket_silo_utils.mine_rocket_silo(event)
  Log.debug("rocket_silo_utils.mine_rocket_silo")
  Log.info(event)
  local rocket_silo = event.entity

  if (rocket_silo and rocket_silo.valid and rocket_silo.surface) then
    Rocket_Silo_Repository.delete_rocket_silo_data_by_unit_number(rocket_silo.surface.name, rocket_silo.unit_number)
  end
end

function rocket_silo_utils.add_rocket_silo(rocket_silo)
  Log.debug("rocket_silo_utils.add_rocket_silo")
  Log.info(rocket_silo)

  Rocket_Silo_Repository.save_rocket_silo_data(rocket_silo)
end

function rocket_silo_utils.launch_rocket(event)
  Log.debug("rocket_silo_utils.launch_rocket")
  Log.info(event)

  if (not event) then return end
  if (not event.tick or not event.planet or not event.planet.valid) then return end
  if (not event.planet.name) then return end
  local planet = event.planet
  if (not planet) then return end

  local satellite_meta_data = Satellite_Meta_Repository.get_satellite_meta_data(planet.name)

  for _, rocket_silo_data in pairs(satellite_meta_data.rocket_silos) do
    local rocket_silo = nil

    if (rocket_silo_data.entity and rocket_silo_data.entity.valid) then
      rocket_silo = rocket_silo_data.entity
    end

    if (rocket_silo and rocket_silo.valid) then
      local inventory = rocket_silo.get_inventory(defines.inventory.rocket_silo_rocket)
      if (inventory) then
        for _, item in ipairs(inventory.get_contents()) do
          if (item.name == "satellite") then
            local rocket = rocket_silo.rocket

            if (rocket and rocket.valid) then
              local cargo_pod = rocket.attached_cargo_pod

              if (cargo_pod and cargo_pod.valid) then
                cargo_pod.cargo_pod_destination = { type = defines.cargo_destination.orbit }
              end
            end

            if (rocket_silo.launch_rocket()) then
              Log.info("Launched satellite: " .. serpent.block(rocket_silo))
            else
              Log.info("Failed to launch satellite: " .. serpent.block(rocket_silo))
            end
          end
        end
      end
    end
  end
end

rocket_silo_utils.all_seeing_satellite = true

local _rocket_silo_utils = rocket_silo_utils

return rocket_silo_utils