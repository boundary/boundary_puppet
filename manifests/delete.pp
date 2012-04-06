#
# Author:: James Turnbull <james@lovedthanlost.net>
# Module Name:: boundary
# Class:: bprobe::delete
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

class boundary::delete {

  require boundary::params

  $id             = $bprobe::params::id
  $apikey         = $bprobe::params::apikey

  boundary_meter { $fqdn:
    ensure   => absent,
    id       => $id,
    apikey   => $apikey,
  }

  file { '/etc/bprobe/':
    ensure  => absent,
    recurse => true,
    force   => true,
  }

  service { 'bprobe':
    ensure => stopped,
    enable => false,
  }

  package { 'bprobe':
    ensure => absent,
    notify => [ File['/etc/bprobe'], Service['bprobe'] ],
  }
}
