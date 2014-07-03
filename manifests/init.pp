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
    $id,
    $apikey,
    $collector = 'collector.boundary.com',
    $collector_port = '4740',
    $tags = [],
    $interfaces = [],
    $pcap_stats = 0,
    $pcap_promisc = 0,
    $disable_ntp = 0,
    $enable_stun = 0,
    $release = 'production' ) {

  require boundary::dependencies

  File {
    group  => 'root',
    owner  => 'root',
  }

  package { 'boundary-meter':
    ensure  => latest
  }

  file { '/etc/default/boundary-meter':
    ensure  => present,
    content => template('boundary/boundary-meter.defaults.erb'),
    mode    => '0600',
    notify  => Service['boundary-meter'],
    require => Package['boundary-meter'],
  }

  file { '/etc/boundary/cacert.pem':
    ensure  => present,
    source  => 'puppet:///modules/boundary/cacert.pem',
    mode    => '0600',
    require => Package['boundary-meter'],
  }

  boundary::resource::boundary { '/etc/puppet/boundary.yaml':
    boundary_orgid  => "${id}",
    boundary_apikey => "${apikey}"
  }

  boundary_meter { $::fqdn:
    ensure  => present,
    id      => $id,
    apikey  => $apikey,
    tags    => $tags,
    require => [ Package['boundary-meter'], File['/etc/boundary/cacert.pem'] ],
    notify => Service['boundary-meter'],
  }

  service { 'boundary-meter':
    ensure    => running,
    enable    => true,
    hasstatus => false,
    require   => Boundary_meter[$::fqdn],
  }
}
