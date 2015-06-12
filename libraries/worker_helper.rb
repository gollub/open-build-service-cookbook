#
# Cookbook Name:: open-build-service
# Recipe:: worker_helper
#
# Copyright 2014, Brocade Communications Systems, Inc.
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

module WorkerHelper
  def worker
    node['open-build-service']['worker']
  end

  def get_src_server
    return "" if
      node['open-build-service']['src_server']['server_name'].nil? or
      node['open-build-service']['src_server']['server_name'].empty? or
      node[:fqdn] == node['open-build-service']['src_server']['server_name']

    return "#{node['open-build-service']['src_server']['server_name']}:#{node['open-build-service']['src_server']['port']}"
  end

  def get_repo_servers
    return worker['repo_servers'] if !worker['repo_servers'].empty?

    return "" if
      node['open-build-service']['repo_server']['server_name'].nil? or
      node['open-build-service']['repo_server']['server_name'].empty? or
      node[:fqdn] == node['open-build-service']['repo_server']['server_name']

    return "#{node['open-build-service']['repo_server']['server_name']}:5252"
  end

  def lvm_vg_exists?(name)
    result = `vgs --noheadings #{name} 2>/dev/null`
    if $?.success?
      Chef::Log.debug("LVM volume group \"#{name}\" exists: #{result}")
      true
    else
      Chef::Log.debug("LVM volume group \"#{name}\" doesn't exist: #{result}")
      false
    end
  end
end
