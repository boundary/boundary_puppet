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

  $repo_mod = $boundary::release ? {
    production  => '',
    staging     => '-staging',
    default     => '',
  }

  case $::osfamily {
    'RedHat', 'CentOS', 'Scientific': {
      $baseurl = "http://yum${repo_mod}.boundary.com/centos/os/${::operatingsystemrelease}/${::architecture}/"
    }
    'Fedora': {
      $baseurl = "http://yum${repo_mod}.boundary.com/centos/os/6.4/${::architecture}/"
    }
    'Amazon': {
      $baseurl = "http://yum${repo_mod}.boundary.com/centos/os/6.4/${::architecture}/"
    }
    default: {
      #default to RHEL
      $baseurl = "http://yum${repo_mod}.boundary.com/centos/os/${::operatingsystemrelease}/${::architecture}/"
    }
  }

  case $::osfamily {
    'RedHat', 'redhat', 'CentOS', 'centos', 'Amazon', 'Fedora': {

      yumrepo { 'boundary':
        descr    => "Boundary ${::operatingsystemrelease} ${::architecture} Repository ",
        enabled  => 1,
        baseurl  => $baseurl,
        gpgcheck => 1,
        gpgkey   => "http://yum${repo_mod}.boundary.com/RPM-GPG-KEY-Boundary",
      }
    }

    'Debian', 'Ubuntu': {

      include ::apt

      $repo = $::osfamily ? {
        debian    => 'main',
        ubuntu    => 'universe',
        default   => undef,
      }

      apt::source { 'boundary':
        location   => inline_template('<%= "http://apt#{@repo_mod}.boundary.com/#{@osfamily.downcase}" %>'),
        repos      => $repo,
        key        => '6532CC20',
        key_source => "http://apt${repo_mod}.boundary.com/APT-GPG-KEY-Boundary"
      }
    }

    default: {
      fail('Platform not supported by Boundary module. Patches welcomed.')
    }
  }
}
