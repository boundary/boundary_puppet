#
# Author:: Rhommel Lamas <roml@rhommell.com>
# Module Name:: boundary
# Class:: boundary::resource::boundary
#
# USAGE:
#
#   boundary::resource::boundary { '/etc/puppet/boundary.yaml':
#     boundary_orgid  => "${id}",
#     boundary_apikey => "${apikey}",
#     github_user     => "${gh_user}",
#     github_token    => "${gh_token}"
#   }
#
# Copyright 2011, Puppet Labs
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
define boundary::resource::boundary(
  $ensure          = 'present',
  $boundary_orgid,
  $boundary_apikey,
  $github_user,
  $github_token
  ) {

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

## Shared Variables
  $ensure_real = $ensure ? {
    'absent' => absent,
    default  => file,
  }

  file { "${name}":
    ensure   => $ensure_real,
    content  => template('boundary/boundary.yaml.erb')
  }
}
