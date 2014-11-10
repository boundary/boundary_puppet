#
# Author:: James Turnbull <james@puppetlabs.com>
# Module Name:: boundary
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

class boundary (
    $token,
    $tags = [],
    $release = 'production' ) {

  require boundary::dependencies

  File {
    group  => 'root',
    owner  => 'root',
  }

  package { 'boundary-meter':
    ensure  => latest
  }

  boundary::resource::boundary { '/etc/puppet/boundary.yaml':
    boundary_token => "${token}"
  }

  boundary_meter { $::fqdn:
    ensure  => present,
    token  => $token,
    tags    => $tags,
    require => Package['boundary-meter'],
    notify => Service['boundary-meter'],
  }

  service { 'boundary-meter':
    ensure    => running,
    enable    => true,
    hasstatus => false,
    require   => Boundary_meter[$::fqdn],
  }
}
