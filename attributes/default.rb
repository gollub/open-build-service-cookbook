#
# Cookbook Name:: open-build-service
# Attributes:: default
#
# Copyright 2015, Brocade Communications Systems, Inc.
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


default['open-build-service']['gpg_standard_key'] = ""
default['open-build-service']['repodownload'] = ""
default['open-build-service']['notification_plugin'] = ""
default['open-build-service']['signer']['path'] = "/usr/bin/sign"
default['open-build-service']['signer']['signd_host'] = "127.0.0.1"
default['open-build-service']['signer']['user'] = "obsrun@#{node['open-build-service']['server_name']}"
default['open-build-service']['signer']['allowuser'] = "obsrun"
default['open-build-service']['signd']['allow'] = "127.0.0.1"
default['open-build-service']['signd']['phrases_dir'] = "/root/.phrases"
default['open-build-service']['signd']['keypairs'] = []
default['open-build-service']['keyfile'] = ""
default['open-build-service']['source_services'] = [] # ["tar_scm", "download_url"]
default['open-build-service']['source_service']['maxchild'] = nil
default['open-build-service']['source_service']['workdir']['path'] = "/var/tmp/obs_service"
default['open-build-service']['source_service']['workdir']['tmpfs']['size'] = nil
default['open-build-service']['source_service']['servicedir'] = nil
default['open-build-service']['source_service']['serviceroot'] = nil

default['open-build-service']['worker']['repo_servers'] = ""
default['open-build-service']['worker']['cache_size'] = ""
default['open-build-service']['worker']['instances'] = "0"
default['open-build-service']['worker']['jobs'] = "1"
default['open-build-service']['worker']['lvm']['vg'] = 'OBS'
default['open-build-service']['worker']['lvm']['vg_devices'] = []
default['open-build-service']['worker']['nr_hugepages'] = 0
default['open-build-service']['worker']['storage_autosetup'] = 'false'
default['open-build-service']['worker']['use_tmpfs'] = 'false'
default['open-build-service']['worker']['instance_memory'] = '512'
default['open-build-service']['worker']['vm_type'] = 'auto'
default['open-build-service']['worker']['vm_initrd'] = 'none'
default['open-build-service']['worker']['vm_kernel'] = 'none'
default['open-build-service']['worker']['vm_disk_root_filesize'] = '4096'
default['open-build-service']['worker']['vm_disk_swap_filesize'] = '1024'
default['open-build-service']['worker']['kernel_package'] = ''
default['open-build-service']['worker']['generate_initrd'] = 'false'
default['open-build-service']['worker']['kvm'] = 'false'
default['open-build-service']['worker']['use_slp'] = 'true'
default['open-build-service']['worker']['directory'] = ""

default['open-build-service']['publisher']['publishedhook_use_regex'] = 'false'
default['open-build-service']['publisher']['publishedhook'] = nil
default['open-build-service']['publisher']['stageserver'] = []
