#
# Author:: James Turnbull <james@lovedthanlost.net>
# Module Name:: boundary
# Class:: boundary::dependencies
#
# Copyright 2011, Puppet Labs
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class boundary::dependencies {

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin',
  }

  case $::operatingsystem {
    'redhat', 'centos', 'Amazon': {

      $rpmkey = '/etc/pki/rpm-gpg/RPM-GPG-KEY-Boundary'

      file { $rpmkey:
        ensure => present,
        source => 'puppet:///modules/boundary/RPM-GPG-KEY-Boundary',
      }

      exec { 'import_key':
        command     => "/bin/rpm --import $rpmkey",
        subscribe   => File[$rpmkey],
        refreshonly => true,
      }

      yumrepo { 'boundary':
        descr    => "Boundary $::operatingsystemrelease $::architecture Repository ",
        enabled  => 1,
        baseurl  => $::operatingsystem ? {
          /(redhat|centos)/ =>  "https://yum.boundary.com/centos/os/$::operatingsystemrelease/$::architecture/",
          'Amazon'          =>  "https://yum.boundary.com/centos/os/6.3/$::architecture/",
        },
        gpgcheck => 1,
        gpgkey   => 'https://yum.boundary.com/RPM-GPG-KEY-Boundary',
      }
    }

    'debian', 'ubuntu': {

      package { 'apt-transport-https':
        ensure => latest,
      }

      file { '/etc/apt/trusted.gpg.d/boundary.gpg':
        source => 'puppet:///modules/boundary/boundary.gpg',
        notify => Exec['add-boundary-apt-key'],
      }

      exec { 'add-boundary-apt-key':
        command     => 'apt-key add /etc/apt/trusted.gpg.d/boundary.gpg',
        refreshonly => true,
      }

      file { '/etc/apt/sources.list.d/boundary.list':
        ensure  => present,
        content => template('boundary/apt_source.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [Package['apt-transport-https'],
                    File['/etc/apt/trusted.gpg.d/boundary.gpg']],
        notify  => Exec['apt-update']
      }

      exec { 'apt-update':
        command     => '/usr/bin/apt-get update',
        refreshonly => true,
      }
    }

    default: {
      fail('Platform not supported by Boundary module. Patches welcomed.')
    }
  }
}
