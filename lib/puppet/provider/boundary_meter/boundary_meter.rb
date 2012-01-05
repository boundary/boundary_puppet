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
require "uri"
require "net/https"
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
        "https://#{API_HOST}/#{resource[:id]}/meters/#{@meter_id}"
      when :tags
        "https://#{API_HOST}/#{resource[:id]}/meters/#{@meter_id}/tags"
      when :delete
        "https://#{API_HOST}/#{resource[:id]}/meters/#{@meter_id}"
      end
    end

    def create_meter(resource)
      begin
        url = build_url(resource, :create)
        headers = generate_headers(resource)
        body = {:name => resource[:name]}.to_json

        Puppet.info("Creating meter #{resource[:name]}")
        response = http_request(:post, url, headers, body)

        body = JSON.parse(response.body)
        @meter_id = body["id"]
        @tags = body["tags"]
        download_request("key", resource)
        download_request("cert", resource)
        if resource[:tags]
          set_meter_tags(resource)
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
        response = http_request(:delete, url, headers)
      rescue Exception => e
        raise Puppet::Error, "Could not delete meter #{resource[:name]}, failed with #{e}"
      end
    end

    def get_meter(data, resource)
      begin
        url = build_url(resource, :search)
        headers = generate_headers(resource)

        response = http_request(:get, url, headers)

        if response
          body = JSON.parse(response.body)
          if body[0]
            if body[0]["#{data}"]
              body[0]["#{data}"]
            else
              raise Puppet::Error, "Could not get meter #{data} (nil response)!"
            end
          else
            return false
          end
        else
          raise Puppet::Error, "Could not get meter (nil response)!"
        end

      rescue Exception => e
        raise Puppet::Error, "Could not get meter #{data}, failed with #{e}"
        nil
      end
    end

    def download_request(type, resource)
      begin
        base_url = build_url(resource, :certificates)
        headers = generate_headers(resource)

        response = http_request(:get, "#{base_url}/#{type}.pem", headers)

        if response
          file = "/etc/bprobe/#{type}.pem"
          File.open(file, 'w') {|f| f.write(response.body) }
          File.chmod(0600, file)
          File.chown(1, 1, file)
        else
          raise Puppet::Error, "Could not download #{type} (nil response)!"
        end
      rescue Exception => e
        raise Puppet::Error, "Could not download #{type}, failed with #{e}"
      end
    end

    def set_meter_tags(resource)
      meter_tags = @tags || get_meter("tags", resource)
      new_tags = resource[:tags]
      new_tags.each do |t|
        unless meter_tags.include?(t)
          add_meter_tag(t)
        end
      end
      old_tags = meter_tags - new_tags
      old_tags.each do |t|
        remove_meter_tag(t)
      end
    end

    def add_meter_tag(tag)
      begin
        url = build_url(resource, :tags)
        headers = generate_headers(resource)

        http_request(:put, "#{url}/#{tag}", headers, "")
      rescue Exception => e
        raise Puppet::Error, "Could not add meter tag: #{tag}, failed with #{e}"
      end
    end

    def remove_meter_tag(tag)
      begin
        url = build_url(resource, :tags)
        headers = generate_headers(resource)

        http_request(:delete, "#{url}/#{tag}", headers, "")
      rescue Exception => e
          raise Puppet::Error, "Could not remove meter tag: #{tag}, failed with #{e}"
      end
    end

    def http_request(method, url, headers, body=nil)
      Puppet.debug("Url: #{url}")
      Puppet.debug("Headers: #{headers.to_hash.inspect}")
      Puppet.debug("Body: #{body}")

      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.ca_file = "/etc/bprobe/cacert.pem"
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER

      case method
      when :get
        req = Net::HTTP::Get.new(uri.request_uri)
      when :post
        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = body
      when :put
        req = Net::HTTP::Put.new(uri.request_uri)
        req.body = body
      when :delete
        req = Net::HTTP::Delete.new(uri.request_uri)
      else
        raise Puppet::Error, "Unsupported http method (nil response)!"
        nil
      end

      headers.each{|k,v|
        req[k] = v
      }
      response = http.request(req)

      Puppet.debug("Response Body: #{response.body}")
      Puppet.debug("Status: #{response.code}")

      if bad_response?(method, url, response)
        nil
      else
        response
      end
    end

    def bad_response?(method, url, response)
      case response
      when Net::HTTPSuccess
        false
      else
        true
        raise Puppet::Error, "Got a #{response.code} for #{method} to #{url}"
        true
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
    @meter_id = get_meter("id", resource)
    if @meter_id
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
    @tags = get_meter("tags", resource)
    @tags
  end

  def tags=(tags)
    set_meter_tags(resource)
  end
end
