#
# Cookbook Name:: arcgis-server
# Recipe:: system
#
# Copyright 2015 Esri
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

chef_gem 'multipart-post' do
  ignore_failure true
  compile_time true
end

if platform?('windows')
  user node['arcgis']['run_as_user'] do
    comment 'ArcGIS user account'
    supports :manage_home => true
    password node['arcgis']['run_as_password']
    not_if { node['arcgis']['run_as_user'].include? '\\' } # do not try to create domain accounts
    action :create
  end
else
  user node['arcgis']['run_as_user'] do
    comment 'ArcGIS user account'
    supports :manage_home => true
    home '/home/' + node['arcgis']['run_as_user']
    shell '/bin/bash'
    action :create
  end

  ['hard', 'soft'].each do |t|
    set_limit node['arcgis']['run_as_user'] do
      type t
      item 'nofile'
      value 65535
    end

    set_limit node['arcgis']['run_as_user'] do
      type t
      item 'nproc'
      value 25059
    end
  end
end

include_recipe 'arcgis-server::hosts'
