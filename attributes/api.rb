#
# Cookbook Name:: open-build-service
# Attributes:: api
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

# helper for easier configuration
default['open-build-service']['server_name'] = node['fqdn'] || 'localhost'

default['open-build-service']['frontend']['title'] = 'Open Build Service'
default['open-build-service']['frontend']['name'] = 'private'
default['open-build-service']['frontend']['description'] = '&lt;p class=&quot;description&quot;&gt;The Open Build Service &lt;/p&gt;'
default['open-build-service']['frontend']['mysql_service_name'] = 'obs'
default['open-build-service']['frontend']['mysql_port'] = '53306'
default['open-build-service']['frontend']['mysql_password'] = 'opensuse'
default['open-build-service']['frontend']['mysql_timeout'] = '10'
default['open-build-service']['frontend']['mysql_pool'] = '30'
default['open-build-service']['mysqld']['max_connections']= '151'
default['open-build-service']['mysqld']['open_files_limit']= '1024'
default['open-build-service']['frontend']['admin_email'] = "root@#{node['open-build-service']['server_name']}"
default['open-build-service']['frontend']['cleanup_after_days'] = nil
default['open-build-service']['frontend']['initial_admin_pw'] = "opensuse"
default['open-build-service']['frontend']['port'] = '443'
default['open-build-service']['frontend']['listen_address'] = '*'
default['open-build-service']['frontend']['server_name'] = node['open-build-service']['server_name']
default['open-build-service']['frontend']['overview_page_hooks'] = ''

default['open-build-service']['frontend']['external_frontend_host'] = node['open-build-service']['server_name']
default['open-build-service']['frontend']['external_frontend_port'] = '443'

default['open-build-service']['frontend']['passenger']['root_path'] = '/usr/lib64/passenger/5.0.7/'

default['open-build-service']['frontend']['common_name'] = node['open-build-service']['server_name']
default['open-build-service']['frontend']['ssl_cert']['source'] = 'self-signed'
default['open-build-service']['frontend']['ssl_key']['source'] = 'self-signed'
default['open-build-service']['frontend']['ca_cert_path'] = nil
default['open-build-service']['frontend']['ca_key_path'] = nil 
default['open-build-service']['frontend']['global_notification'] = []
default['open-build-service']['frontend']['remote_instances'] = []
default['open-build-service']['frontend']['distributions'] = []

default['open-build-service']['repo_server']['port'] = '82'
default['open-build-service']['repo_server']['listen_address'] = '*'
default['open-build-service']['repo_server']['server_name'] = node['open-build-service']['server_name']
default['open-build-service']['repodownload'] = "http://#{node['open-build-service']['repo_server']['server_name']}:#{node['open-build-service']['repo_server']['port']}"

default['open-build-service']['src_server']['server_name'] = node['open-build-service']['server_name']
default['open-build-service']['src_server']['port'] = '5352'

# moved from api recipe since it is used in other places too
default['passenger']['default_user'] = 'wwwrun'
default['passenger']['default_group'] = 'www'
