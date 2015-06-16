#
# Cookbook Name:: open-build-service
# Recipes:: api_server
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
# This is a combination of obs-api provisioning and dist/obsapisetup. It later
# runs dist/obsapidelayed as well.
#

#
# Install
#

%w{ obs-api apache2 apache2-mod_xforward rubygem-passenger-apache2 memcached }.each do |package_name|
  package package_name do
    action :install
  end
end

template "options.yml" do
  path "/srv/www/obs/api/config/options.yml"
  source "options.yml.erb"
  owner "root"
  group "www"
  mode "0640"
end

template "overview.html" do
  path "/srv/www/obs/overview/index.html"
  source "overview.html.erb"
  owner "root"
  group "root"
  mode "0644"
  helpers(ObsHelper)
end

cookbook_file 'apache2.conf' do
  path '/usr/lib/tmpfiles.d/apache2.conf'
  mode '0644'
  owner 'root'
  group 'root'
  action :create_if_missing
  notifies :run, 'execute[create_apache_tmpfiles]', :immediately
end

execute 'create_apache_tmpfiles' do
  command 'systemd-tmpfiles --create /usr/lib/tmpfiles.d/apache2.conf'
  action :nothing
end

template 'configuration.xml' do
  path '/srv/www/obs/api/config/configuration.xml'
  source "configuration.xml.erb"
  owner "obsrun"
  group "obsrun"
  mode "0644"
  notifies :run, 'execute[rake_load_configuration_xml]'
end

cookbook_file 'configuration.rake' do
  path '/srv/www/obs/api/lib/tasks/configuration.rake'
  mode '0644'
  owner 'root'
  group 'root'
  action :create_if_missing
end

cookbook_file 'configuration_global_notification.rake' do
  path '/srv/www/obs/api/lib/tasks/configuration_global_notification.rake'
  mode '0644'
  owner 'root'
  group 'root'
  action :create_if_missing
end

template 'global_notification.yml' do
  path '/srv/www/obs/api/config/global_notification.yml'
  source "global_notification.yml.erb"
  owner "obsrun"
  group "obsrun"
  mode "0644"
  notifies :run, 'execute[rake_setup_global_notification]'
  only_if { node['open-build-service']['frontend']['global_notification'].any? }
end

cookbook_file 'remote_instance.rake' do
  path '/srv/www/obs/api/lib/tasks/remote_instance.rake'
  mode '0644'
  owner 'root'
  group 'root'
  action :create_if_missing
end

template 'remote_instances.yml' do
  path '/srv/www/obs/api/config/remote_instances.yml'
  source "remote_instances.yml.erb"
  owner "obsrun"
  group "obsrun"
  mode "0644"
  notifies :run, 'execute[rake_setup_remote_instances]'
end

cookbook_file 'admin_password.rake' do
  path '/srv/www/obs/api/lib/tasks/admin_password.rake'
  mode '0644'
  owner 'root'
  group 'root'
  action :create_if_missing
end

#
# Configure
#

include_recipe 'open-build-service::_api_database'

cert = ssl_certificate 'obs' do
  namespace node['open-build-service']['frontend']
  notifies :restart, 'service[apache2]'
end

node.set['apache']['default_site_enabled'] = false

%w{ alias expires rewrite proxy proxy_http xforward headers socache_shmcb ssl }.each do |n|
  apache_module n
end

apache_module 'mpm_prefork' do
  enable false
end
apache_module 'unixd' do
  enable false
end


# set required defaults for passenger
node.set['passenger']['install_method'] = 'package'
node.set['passenger']['package']['name'] = 'rubygem-passenger-apache2'
node.set['passenger']['ruby_bin'] = '/usr/bin/ruby'
node.set['passenger']['module_path'] = '/usr/lib64/apache2/mod_passenger.so'
node.set['passenger']['root_path'] = '/usr/lib64/passenger/5.0.6/'

include_recipe "passenger_apache2"
include_recipe 'passenger_apache2::mod_rails'

# node['passenger']['temp_dir'] ???
directory '/var/run/passenger' do
  owner node['passenger']['default_user']
  group node['passenger']['default_group']
end

%w{/srv/www/obs/api/log /srv/www/obs/api/tmp}.each do |path|
  directory path do
    owner node['passenger']['default_user']
    group node['passenger']['default_group']
    recursive true
  end
end

service 'apache2' do
  supports restart: true, status: true
  action [:enable, :start]
end

web_app 'obsapi' do
  template 'frontend.conf.erb'
  server_name node['open-build-service']['frontend']['server_name']
  admin_email node['open-build-service']['frontend']['admin_email']
  ssl_key cert.key_path
  ssl_cert cert.cert_path
  ssl_chain cert.chain_path
  notifies :reload, 'service[apache2]'
end

service 'memcached' do
  service_name 'memcached'
  supports restart: true, status: true
  action [:enable, :start]
end

service 'obsapidelayed' do
  service_name 'obsapidelayed'
  supports restart: true, status: true
  action [:enable, :start]
end

#
# update configuration.xml
#
execute 'rake_load_configuration_xml' do
  command 'rake load_configuration_xml[/srv/www/obs/api/config/configuration.xml]'
  cwd '/srv/www/obs/api'
  user node['passenger']['default_user']
  group node['passenger']['default_group']
  environment 'RAILS_ENV' => 'production'
  action :nothing
end

#
# update global notification settings
# $obs_url/configuration/notifications
#
execute 'rake_setup_global_notification' do
  command 'rake setup_global_notification[/srv/www/obs/api/config/global_notification.yml]'
  cwd '/srv/www/obs/api'
  user node['passenger']['default_user']
  group node['passenger']['default_group']
  environment 'RAILS_ENV' => 'production'
  action :nothing
end

#
# update remote instances settings
# $obs_url/configuration/connect_instance
#
execute 'rake_setup_remote_instances' do
  command 'rake setup_remote_instances[/srv/www/obs/api/config/remote_instances.yml]'
  cwd '/srv/www/obs/api'
  user node['passenger']['default_user']
  group node['passenger']['default_group']
  environment 'RAILS_ENV' => 'production'
  action :nothing
end

#
# update remote instances settings
# $obs_url/configuration/connect_instance
#

file '/srv/obs/.chef_inital_admin_pw.lock' do
  action :create_if_missing
  notifies :run, 'execute[setup_admin_password]', :immediately
end

execute 'setup_admin_password' do
  command "rake setup_admin_password[#{node['open-build-service']['frontend']['initial_admin_pw']}]"
  cwd '/srv/www/obs/api'
  user node['passenger']['default_user']
  group node['passenger']['default_group']
  environment 'RAILS_ENV' => 'production'
  action :nothing
end

#
# Hide openSUSE instructions in notification mails
#
cookbook_file 'build_fail.text.erb' do
  path '/srv/www/obs/api/app/views/event_mailer/build_fail.text.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
end
