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
    $gh_user = '',
    $gh_token = '',
    $tags ) {

  require boundary::dependencies

  File {
    group  => 'root',
    owner  => 'root',
  }

  file { '/etc/bprobe/':
    ensure => directory,
    mode   => '0755',
  }

  package { 'bprobe':
    ensure  => latest,
    require => File['/etc/bprobe/'],
  }

  file { '/etc/bprobe/bprobe.defaults':
    ensure  => present,
    content => template('boundary/bprobe.defaults.erb'),
    mode    => '0600',
    notify  => Service['bprobe'],
    require => Package['bprobe'],
  }

  file { '/etc/bprobe/ca.pem':
    ensure  => present,
    source  => 'puppet:///modules/boundary/ca.pem',
    mode    => '0600',
    notify  => Service['bprobe'],
    require => Package['bprobe'],
  }

  file { '/etc/bprobe/cacert.pem':
    ensure  => present,
    source  => 'puppet:///modules/boundary/cacert.pem',
    mode    => '0600',
    notify  => Service['bprobe'],
    require => Package['bprobe'],
  }

  boundary::resource::boundary { '/etc/puppet/boundary.yaml':
    boundary_orgid  => "${id}",
    boundary_apikey => "${apikey}",
    github_user     => "${gh_user}",
    github_token    => "${gh_token}"
  }

  boundary_meter { $::fqdn:
    ensure  => present,
    id      => $id,
    apikey  => $apikey,
    require => [ Package['bprobe'], File['/etc/bprobe/cacert.pem'] ],
    tags    => $tags,
  }

  service { 'bprobe':
    ensure    => running,
    enable    => true,
    hasstatus => false,
    require   => Boundary_meter[$::fqdn],
  }
}
