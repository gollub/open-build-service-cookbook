#
# Cookbook Name:: open-build-service
# Recipe:: worker
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

include_recipe 'open-build-service::_sysconfig-obs-server'

%w{ obs-worker perl-XML-Structured }.each do |package_name|
  package package_name do
    action :install
  end
end

package 'kvm' do
  action :install
  only_if { node['open-build-service']['worker']['kvm'] == true }
end

package node['open-build-service']['worker']['kernel_package'] do
  action :install
  only_if { !node['open-build-service']['worker']['kernel_package'].empty? }
end

# this is for the initial creation
if node['open-build-service']['worker']['vm_initrd'] != 'none'
  if node['open-build-service']['worker']['generate_initrd'] != 'false'

    file node['open-build-service']['worker']['vm_initrd'] do
       action :create_if_missing
       notifies :run, 'execute[create_vm_initrd]', :delayed
    end
   
    execute "create_vm_initrd" do
      command "mkinitrd -m 'ext4 binfmt_misc virtio_pci virtio_blk' -k vmlinuz -i initrd-obs_worker"
      cwd "/boot"
      action :nothing
    end
  end
end

include_recipe 'open-build-service::_worker_storage'

# set worker hugepages memory
if worker['nr_hugepages'] > 0
  mount '/dev/hugepages' do
    device 'hugetlbfs'
    fstype 'hugetlbfs'
    options 'rw'
    action [:mount, :enable]
  end

  template '/etc/sysctl.d/50-obs.conf' do
    source "sysctl.erb"
    mode 0440
    owner "root"
    group "root"
    notifies :run, 'execute[set_nr_hugepages]', :immediately
    helpers(WorkerHelper)
  end

  execute "set_nr_hugepages" do
    command "sysctl -p /etc/sysctl.d/50-obs.conf"
    action :nothing
  end
end

template '/etc/buildhost.config' do
  source "buildhost.config.erb"
  mode 0440
  owner "root"
  group "root"
  helpers(WorkerHelper)
end

service 'obsworker' do
  service_name 'obsworker'
  supports restart: true, status: true
  action [ :enable, :start ]
end


