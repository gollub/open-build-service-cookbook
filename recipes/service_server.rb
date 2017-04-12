#
# Cookbook Name:: open-build-service
# Recipes:: service_server
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

include_recipe 'open-build-service::_backend'

if !node['open-build-service']['source_service']['workdir']['tmpfs']['size'].nil?

  directory node['open-build-service']['source_service']['workdir']['path'] do
    owner 'obsrun'
    group 'obsrun'
    mode '0700'
  end

  mount node['open-build-service']['source_service']['workdir']['path'] do
    pass     0
    fstype   "tmpfs"
    device   "chef-obs-tmpfs"
    options  "mode=700,size=#{node['open-build-service']['source_service']['workdir']['tmpfs']['size']}"
    action   [:mount, :enable]
  end

end

%w{ obs-source_service build }.each do |package_name|
  package package_name do
    action :upgrade
  end
end

service 'obsservice' do
  service_name 'obsservice'
  supports restart: true, status: true
  action [:enable, :start]
end

node['open-build-service']['source_services'].each do |name|
  package "obs-service-#{name}" do
    action :upgrade
    notifies :restart, 'service[obsservice]'
  end
end
