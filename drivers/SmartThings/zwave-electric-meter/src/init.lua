-- Copyright 2022 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local capabilities = require "st.capabilities"
--- @type st.zwave.defaults
local defaults = require "st.zwave.defaults"
--- @type st.zwave.Driver
local ZwaveDriver = require "st.zwave.driver"
--- @type st.zwave.CommandClass.Configuration
local Configuration = (require "st.zwave.CommandClass.Configuration")({version=1})

local preferencesMap = require "preferences"

local device_added = function (self, device)
  device:refresh()
end

--- Handle preference changes
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param event table
--- @param args
local function info_changed(driver, device, event, args)
  local preferences = preferencesMap.get_device_parameters(device)
  for id, value in pairs(device.preferences) do
    if args.old_st_store.preferences[id] ~= value and preferences and preferences[id] then
      local new_parameter_value = preferencesMap.to_numeric_value(device.preferences[id])
      device:send(Configuration:Set({ parameter_number = preferences[id].parameter_number, size = preferences[id].size, configuration_value = new_parameter_value }))
    end
  end
end

local driver_template = {
  supported_capabilities = {
    capabilities.powerMeter,
    capabilities.energyMeter,
    capabilities.refresh
  },
  lifecycle_handlers = {
    infoChanged = info_changed,
    added = device_added
  },
  sub_drivers = {
    require("qubino-meter"),
    require("aeotec-gen5-meter"),
    require("aeon-meter"),
    require("aeotec-home-energy-meter-gen8")
  }
}

defaults.register_for_default_handlers(driver_template, driver_template.supported_capabilities)
--- @type st.zwave.Driver
local electricMeter = ZwaveDriver("zwave_electric_meter", driver_template)
electricMeter:run()
