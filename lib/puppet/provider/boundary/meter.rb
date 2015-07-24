#
# Author:: Zachary Schneider (<schneider@boundary.com>)
# Type Name:: meter
# Provider:: boundary
#
# Copyright 2014, BoundaryMeter
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
# ))

Puppet::Type.type(:meter).provide(:boundary) do
  @doc = 'Manages the creation of boundary meters'

  conf_dir = '/etc/boundary',

      initvars
  defaultfor :kernel => 'Linux'

  def create
    begin
      self.create_meter(resource)
    rescue Exception => e
      raise Puppet::Error, "Could not create meter, failed with #{e}"
    end
  end

  def exists?
    meter = self.get_meter(resource)
    (meter['id'] and meter['connected'] == 'true') or (meter['premium'] and meter['premium']['projectId'])
  end

  def destroy
    begin
      self.delete_meter(resource)
    rescue Exception => e
      raise Puppet::Error, "Could not delete meter, failed with #{e}"
    end
  end

  def tags
    @tags ||= get_meter_tags(resource)
  end

  def tags=(tags)
    self.set_meter_tags(resource)
  end

  def self.create_meter(resource)
    begin
      self.run_command(build_command(resource, :create, conf_dir))
    rescue Exception => e
      raise Puppet::Error, "Could not create meter, failed with #{e}"
    end
  end

  def self.delete_meter(resource)
    begin
      self.run_command(build_command(resource, :delete, conf_dir))
    rescue Exception => e
      raise Puppet::Error, "Could not delete meter, failed with #{e}"
    end
  end

  def self.get_meter(resource)
    begin
      return JSON.parse(run_command(build_command(resource, :json)))
    rescue Exception => e
      raise Puppet::Error, "Could not get meter, failed with #{e}"
    end
  end

  def  self.set_meter_tags(resource)
    begin
      # Remove all tags
      run_command(build_command(resource, :delete_tags, conf_dir))
      # Add new tags
      run_command(build_command(resource, nil, conf_dir))
    rescue Exception => e
      raise Puppet::Error, "Could not set meter tags, failed with #{e}"
      nil
    end
  end

  def  self.get_meter_tags(resource)
    begin
      return run_command(build_command(resource, :tags)).chomp.split(',')
    rescue Exception => e
      raise Puppet::Error, "Could not get meter tags, failed with #{e}"
    end
  end

  # Internal Methods

  def self.build_command(resource, action, conf_dir)
    command = [
        'boundary-meter',
        "-p #{resource[:token]}",
        "-b  #{conf_dir}",
    ]

    command.push "-l #{action.to_s}" unless action == nil
    command.push "--nodename #{resource[:name]}" unless resource[:name] == 'undef'

    if action == :create or action == nil
      command.push "--tag #{resource[:tags].join(',')}" unless resource[:tags] == []
    end

    return command.join(' ')
  end

  def self.run_command(command)
    # For some reason puppet calls create if tags change
    # short circuiting this here for now
    return unless command.include?('-l') || command.include?('--tag')

    result = `#{command}`

    raise Exception.new("command '#{command}' failed") unless $?.to_i == 0

    return result
  end
end
