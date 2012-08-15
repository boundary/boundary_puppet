#
# Author:: James Turnbull <james@puppetlabs.com>
# Module Name:: boundary
# Class:: boundary::params
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

class boundary::params {

  if $::boundary_apikey { $apikey = $::boundary_apikey }
  else { $apikey = 'apikey' }

  if $::boundary_id { $id = $::boundary_id }
  else { $id = 'OrganisationID' }

  if $::boundary_collector { $collector = $::boundary_collector }
  else { $collector = 'collector.boundary.com' }

  if $::boundary_collector_port { $collector_port = $::boundary_collector_port }
  else { $collector_port = 4740 }

  if $::boundary_tags { $tags = split($::boundary_tags, ',\s+') }
}
