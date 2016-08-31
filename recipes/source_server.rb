#
# Cookbook Name:: open-build-service
# Recipes:: source_server
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
include_recipe 'open-build-service::_signing'

service 'obssrcserver' do
  service_name 'obssrcserver'
  supports restart: true, status: true
  action [:enable, :start]
end

Chef::Resource::Service.send(:include, ObsHelper)

service 'obssigner' do
  service_name 'obssigner'
  supports restart: true, status: true
  action [:enable, :start]
  only_if { !get_keyfile.to_s.empty? }
end
