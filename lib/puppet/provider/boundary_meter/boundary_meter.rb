#
# Author:: Jomes Turnbull <james@puppetlabs.com>
# Boundary API and code heavily stolen from Joe Williams (<j@boundary.com>)
# Type Name:: boundary_meter
# Provider:: boundary_meter
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

require "rubygems"
require "excon"
require "json"
require "base64"

module Boundary
  module API

    API_HOST = "api.boundary.com"

    def auth_encode(resource)
      auth = Base64.encode64("#{resource[:apikey]}:").strip
      auth.gsub("\n","")
    end

    def generate_headers(resource)
      auth = auth_encode(resource)
      { "Authorization" => "Basic #{auth}", "Content-Type" => "application/json" }
    end

    def build_url(resource, action)
      case action
      when :create
        "https://#{API_HOST}/#{resource[:id]}/meters"
      when :search
        "https://#{API_HOST}/#{resource[:id]}/meters?name=#{resource[:name]}"
      when :certificates
        meter_id = get_meter_id(resource)
        "https://#{API_HOST}/#{resource[:id]}/meters/#{meter_id}"
      when :tags
        meter_id = get_meter_id(resource)
        "https://#{API_HOST}/#{resource[:id]}/meters/#{meter_id}/tags"
      when :delete
        meter_id = get_meter_id(resource)
        "https://#{API_HOST}/#{resource[:id]}/meters/#{meter_id}"
      end
    end

    def create_meter(resource)
      begin
        url = build_url(resource, :create)
        headers = generate_headers(resource)
        body = {:name => resource[:name]}.to_json

        Puppet.info("Creating meter #{resource[:name]}")
        response = http_post_request(url, headers, body)

        download_certificate_request(resource)
        download_key_request(resource)
        if resource[:tags]
          apply_meter_tags(resource)
        end
      rescue Exception => e
          raise Puppet::Error, "Could not create meter #{resource[:name]}, failed with #{e}"
      end
    end

    def delete_meter(resource)
      begin
        url = build_url(resource, :delete)
        headers = generate_headers(resource)

        Puppet.info("Deleting meter #{resource[:name]}")
        response = http_delete_request(url, headers)
      rescue Exception => e
        raise Puppet::Error, "Could not delete meter #{resource[:name]}, failed with #{e}"
      end
    end

    def meter_exists?(resource)
      begin
        url = build_url(resource, :search)
        headers = generate_headers(resource)

        response = http_get_request(url, headers)

        if response
          body = JSON.parse(response.body)

          if body == []
            false
          else
            true
          end
        else
          raise Puppet::Error, "Could not determine if meter exists (nil response)!"
          nil
        end
      rescue Exception => e
        raise Puppet::Error, "Could not determine if meter exists, failed with #{e}"
        nil
      end
    end

    def get_meter_id(resource)
      begin
        url = build_url(resource, :search)
        headers = generate_headers(resource)

        response = http_get_request(url, headers)

        if response
          body = JSON.parse(response.body)
          if body[0]
            if body[0]["id"]
              body[0]["id"]
            else
              raise Puppet::Error, "Could not get meter id (nil response)!"
            end
          else
            raise Puppet::Error, "Could not get meter id (nil response)!"
          end
        else
          raise Puppet::Error, "Could not get meter id (nil response)!"
        end

      rescue Exception => e
        raise Puppet::Error, "Could not get meter id, failed with #{e}"
        nil
      end
    end

    def download_certificate_request(resource)
      begin
        base_url = build_url(resource, :certificates)
        headers = generate_headers(resource)

        cert_response = http_get_request("#{base_url}/cert.pem", headers)

        if cert_response
          cert_file = '/etc/bprobe/cert.pem'
          File.open(cert_file, 'w') {|f| f.write(cert_response.body) }
          File.chmod(0600, cert_file)
          File.chown(1, 1, cert_file)
        else
          raise Puppet::Error, "Could not download certificate (nil response)!"
        end
      rescue Exception => e
        raise Puppet::Error, "Could not download certificate, failed with #{e}"
      end
    end

    def download_key_request(resource)
      begin
        base_url = build_url(resource, :certificates)
        headers = generate_headers(resource)

        key_response = http_get_request("#{base_url}/key.pem", headers)

        if key_response
          key_file = '/etc/bprobe/key.pem'
          File.open(key_file, 'w') {|f| f.write(key_response.body) }
          File.chmod(0600, key_file)
          File.chown(1, 1, key_file)
        else
          raise Puppet::Error, "Could not download key (nil response)!"
        end
      rescue Exception => e
        raise Puppet::Error, "Could not download key, failed with #{e}"
      end
    end

    def apply_meter_tags(resource)
      tags = resource[:tags]

      begin
        url = build_url(resource, :tags)
        headers = generate_headers(resource)

        Puppet.info("Applying meter tags #{tags.inspect}")

        tags.each do |tag|
          http_put_request("#{url}/#{tag}", headers, "")
        end
      rescue Exception => e
          raise Puppet::Error, "Could not apply meter tag, failed with #{e}"
      end
    end

    def http_get_request(url, headers)
      Puppet.debug("Url: #{url}")
      Puppet.debug("Headers: #{headers}")

      response = Excon.get(url, :headers => headers)

      Puppet.debug("Body: #{response.body}")
      Puppet.debug("Status: #{response.status}")

      if bad_response?(:get, url, response)
        nil
      else
        response
      end
    end

    def http_delete_request(url, headers)
      Puppet.debug("Url: #{url}")
      Puppet.debug("Headers: #{headers}")

      response = Excon.delete(url, :headers => headers)

      Puppet.debug("Body: #{response.body}")
      Puppet.debug("Status: #{response.status}")

      if bad_response?(:delete, url, response)
        nil
      else
        response
      end
    end

    def http_put_request(url, headers, body)
      Puppet.debug("Url: #{url}")
      Puppet.debug("Headers: #{headers}")

      response = Excon.put(url, :headers => headers, :body => body)

      Puppet.debug("Body: #{response.body}")
      Puppet.debug("Status: #{response.status}")

      if bad_response?(:put, url, response)
        nil
      else
        response
      end
    end

    def http_post_request(url, headers, body)
      Puppet.debug("Url: #{url}")
      Puppet.debug("Headers: #{headers}")

      response = Excon.post(url, :headers => headers, :body => body)

      Puppet.debug("Body: #{response.body}")
      Puppet.debug("Status: #{response.status}")

      if bad_response?(:post, url, response)
        nil
      else
        response
      end
    end

    def bad_response?(method, url, response)
      if response.status >= 400
        raise Puppet::Error, "Got a #{response.status} for #{method} to #{url}"
        true
      else
        false
      end
    end
  end
end

Puppet::Type.type(:boundary_meter).provide(:boundary_meter) do

  include Boundary::API

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
    meter_exists?(resource)
  end

  def destroy
    begin
      delete_meter(resource)
    rescue Exception => e
      raise Puppet::Error, "Could not delete meter #{resource[:name]}, failed with #{e}"
    end
  end
end
