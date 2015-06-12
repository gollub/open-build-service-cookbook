#
# Cookbook Name:: open-build-service
# Recipes:: _backend
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

include_recipe 'open-build-service::_sysconfig-obs-server'

%w{ obs-server }.each do |package_name|
  package package_name do
    action :install
  end
end

template 'bsconfig.' + node['open-build-service']['server_name'] do
  path '/usr/lib/obs/server/bsconfig.' + node['open-build-service']['server_name']
  source "bsconfig.erb"
  owner "root"
  group "root"
  mode "0644"
  helpers(ObsHelper)
end
