#
# Cookbook Name:: open-build-service
# Recipes:: _api_database
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
# This recipe does the initial database provisioning.
#

#
# Installation
#

mysql2_chef_gem_mariadb 'default' do
  action :install
end

#
# Configuration
#

# if we detect an empty service name this means we use the system's service
if node['open-build-service']['frontend']['mysql_service_name'].empty?
  service 'mysql' do
    supports restart: true, status: true
    action [:enable, :start]
  end

  node.set['open-build-service']['frontend']['mysql_socket'] =
    '/var/run/mysqld/mysqld.sock'
else
  node.set['open-build-service']['frontend']['mysql_socket'] =
    '/var/run/mysql-' +
    node['open-build-service']['frontend']['mysql_service_name'] +
    '/mysqld.sock'

  mysql_client node['open-build-service']['frontend']['mysql_service_name'] do
    package_name "mariadb-client"
    action :create
  end

  mysql_service node['open-build-service']['frontend']['mysql_service_name'] do
    package_name "mariadb"
    initial_root_password node['open-build-service']['frontend']['mysql_password']
    bind_address '127.0.0.1'
    socket node['open-build-service']['frontend']['mysql_socket']
    port node['open-build-service']['frontend']['mysql_port']
    action [:create, :start]
  end

  mysql_config "obs-settings" do
    instance node['open-build-service']['frontend']['mysql_service_name']
    source 'mysql-obs-settings.erb'
    notifies :restart, "mysql_service[#{node['open-build-service']['frontend']['mysql_service_name']}]"
    action :create
  end
end

template "database.yml" do
  path "/srv/www/obs/api/config/database.yml"
  source "database.yml.erb"
  owner "root"
  group "www"
  mode "0640"
  notifies :create, 'mysql_database[api_production]', :immediately
end

mysql_connection_info = {
  :socket   => node['open-build-service']['frontend']['mysql_socket'],
  :username => 'root',
  :password => node['open-build-service']['frontend']['mysql_password']
}

mysql_database 'api_production' do
  connection mysql_connection_info
  action :nothing
  notifies :run, 'execute[rake_db_setup]', :immediately
  not_if "/usr/bin/mysql --socket=#{node['open-build-service']['frontend']['mysql_socket']} -u root --password=#{node['open-build-service']['frontend']['mysql_password']} -e 'use api_production; select * from schema_migrations;'"
end

execute 'rake_db_setup' do
  command 'rake db:setup writeconfiguration'
  cwd '/srv/www/obs/api'
  user node['passenger']['default_user']
  group node['passenger']['default_group']
  environment 'RAILS_ENV' => 'production'
  action :nothing
end
