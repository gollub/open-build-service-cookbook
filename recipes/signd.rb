#
# Cookbook Name:: open-build-service
# Recipes:: signd
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


%w{ obs-signd haveged }.each do |package_name|
  package package_name do
    action :install
  end
end

include_recipe 'open-build-service::_signing'

service 'haveged' do
  service_name 'haveged'
  supports restart: true, status: true
  action [:enable, :start]
end

service 'obssignd' do
  service_name 'obssignd'
  supports restart: true, status: true
  action [:enable, :start]
end

directory node['open-build-service']['signd']['phrases_dir'] do
  owner "root" 
  group "root"
end

if !node['open-build-service']['signd']['keypairs'].empty?
  node['open-build-service']['signd']['keypairs'].each do |keyid, param|

    keyfile = Chef::EncryptedDataBagItem.load(param['bag'], param['private_key']['item'])

    file "/root/#{keyfile['filename']}" do
      content keyfile['content']
      owner 'root'
      group 'root'
      mode 0600
      notifies :run, 'execute[signd_import_private_key]'
    end

    execute 'signd_import_private_key' do
      command "gpg --import /root/#{keyfile['filename']}"
      user "root"
      group "root"
      action :nothing
    end

    keyfile = Chef::EncryptedDataBagItem.load(param['bag'], param['public_key']['item'])

    file "/root/#{keyfile['filename']}" do
      content keyfile['content']
      owner 'root'
      group 'root'
      mode 0600
      notifies :run, 'execute[signd_import_public_key]'
    end

    execute 'signd_import_public_key' do
      command "gpg --import /root/#{keyfile['filename']}"
      user "root"
      group "root"
      action :nothing
    end

    phrasefile = Chef::EncryptedDataBagItem.load(param['bag'], param['key_phrase']['item'])
    file "#{node['open-build-service']['signd']['phrases_dir']}/#{keyid}" do
      content phrasefile['content']
      owner 'root'
      group 'root'
      mode 0600
    end

  end
end
