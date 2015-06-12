#
# Cookbook Name:: open-build-service
# Recipe:: _worker_storage
#
# Copyright 2014-2015, Brocade Communications Systems, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Recipe.send(:include, WorkerHelper)

return if worker['storage_autosetup'] == 'true'

include_recipe 'lvm'

::Chef::Resource::LvmVolumeGroup.send(:include, WorkerHelper)
::Chef::Resource::LvmLogicalVolume.send(:include, WorkerHelper)

service 'obsstoragesetup' do
  action [ :disable, :stop ]
end

lvm_volume_group worker['lvm']['vg'] do
  physical_volumes worker['lvm']['vg_devices']
  only_if { worker['lvm'].attribute?('vg_devices') }
end

# create worker cache
package 'xfsprogs'

lvm_logical_volume 'cache' do
  group worker['lvm']['vg']
  size '100%FREE'
  filesystem 'xfs'
  mount_point '/var/cache/obs/worker'
  only_if { lvm_vg_exists?(worker['lvm']['vg']) }
end

