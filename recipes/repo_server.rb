#
# Cookbook Name:: open-build-service
# Recipes:: repo_server
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

#
# Based on the following statement from /usr/lib/obs/server/BSConfig.pm:
#
# "There is still just one source server, but there can be multiple servers
#  which run each repserver, schedulers, dispatcher, warden and publisher."
#

include_recipe 'open-build-service::_backend'

if node['open-build-service']['keyfile'].respond_to?('attribute?') and node['open-build-service']['keyfile'].attribute?('bag')
  keyfile = Chef::EncryptedDataBagItem.load(node['open-build-service']['keyfile']['bag'], 'keyfile')

  file "/srv/obs/#{keyfile['filename']}" do
    content keyfile['content']
    owner 'root'
    group 'root'
    mode 0644
  end
else
  puts 'No keyfile configured'
end

directory '/srv/obs/repos' do
  owner "obsrun"
  group "obsrun"
end

web_app 'obsrepserver' do
  template 'repos.conf.erb'
  server_name node['open-build-service']['repo_server']['server_name']
  notifies :reload, 'service[apache2]'
end

service 'obsrepserver' do
  service_name 'obsrepserver'
  supports restart: true, status: true
  action [:enable, :start]
end

service 'obsscheduler' do
  service_name 'obsscheduler'
  supports restart: true, status: true
  action [:enable, :start]
end

service 'obsdispatcher' do
  service_name 'obsdispatcher'
  supports restart: true, status: true
  action [:enable, :start]
end

service 'obswarden' do
  service_name 'obswarden'
  supports restart: true, status: true
  action [:enable, :start]
end

service 'obspublisher' do
  service_name 'obspublisher'
  supports restart: true, status: true
  action [:enable, :start]
end
