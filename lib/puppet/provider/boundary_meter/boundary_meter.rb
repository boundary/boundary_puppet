#
# Author:: Zachary Schneider (<schneider@boundary.com>)
# Type Name:: boundary_meter
# Provider:: boundary_meter
#
# Copyright 2014, Boundary
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

#resource[:blah]

require 'json'

module Boundary
  module Meter

    CONF_DIR = '/etc/boundary'

    def create_meter(resource)
      begin
        run_command(build_command(resource, :create))
      rescue Exception => e
        raise Puppet::Error, "Could not create meter #{resource[:name]}, failed with #{e}"
      end
    end

    def delete_meter(resource)
      begin
        run_command(build_command(resource, :delete))
      rescue Exception => e
        raise Puppet::Error, "Could not delete meter #{resource[:name]}, failed with #{e}"
      end
    end

    def get_meter(resource)
      begin
        return JSON.parse(run_command(build_command(resource, :json)))
      rescue Exception => e
        raise Puppet::Error, "Could not get meter #{resource[:name]}, failed with #{e}"
        nil
      end
    end

    def set_meter_tags(resource)
      begin
        # Remove all tags
        run_command(build_command(resource, :delete_tags))
        # Add new tags
        run_command(build_command(resource, nil))
      rescue Exception => e
        raise Puppet::Error, "Could not set meter tags #{resource[:tags]}, failed with #{e}"
        nil
      end
    end

    def get_meter_tags(resource)
      begin
        return run_command(build_command(resource, :tags)).chomp.split(',')
      rescue Exception => e
        raise Puppet::Error, "Could not get meter tags for #{resource[:name]}, failed with #{e}"
        nil
      end
    end

    # Internal Methods

    def build_command(resource, action)
      command = [
        "boundary-meter",
        "-p #{resource[:id]}:#{resource[:apikey]}",
        "-b #{Boundary::Meter::CONF_DIR}",
        "--nodename #{resource[:name]}"
      ]

      command.push "-l #{action.to_s}" unless action == nil

      if action == :create or action == nil
        command.push "--tag #{resource[:tags].join(',')}" unless resource[:tags] == []
      end

      return command.join(' ')
    end

    def run_command(command)
      # For some reason puppet calls create if tags change
      # short circuiting this here for now
      return unless command.include?('-l') || command.include?('--tag')

      result = `#{command}`

      raise Exception.new("Command Failed") unless $?.to_i == 0

      return result
    end
  end
end

Puppet::Type.type(:boundary_meter).provide(:boundary_meter) do

  include Boundary::Meter

  desc "Manage Boundary meters."

  defaultfor :kernel => 'Linux'

  def create
    begin
      create_meter(resource)
    rescue Exception => e
      raise Puppet::Error, "Could not create meter #{resource[:name]}, failed with #{e}"
    end
  end

  def exists?
    meter = get_meter(resource)

    if meter['id'] and meter['connected'] == 'true'
      true
    else
      false
    end
  end

  def destroy
    begin
      delete_meter(resource)
    rescue Exception => e
      raise Puppet::Error, "Could not delete meter #{resource[:name]}, failed with #{e}"
    end
  end

  def tags
    @tags ||= get_meter_tags(resource)
  end

  def tags=(tags)
    set_meter_tags(resource)
  end
end
