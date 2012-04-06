require 'puppet'
require 'yaml'
require 'json'
require 'net/http'
require 'net/https'
require 'uri'

unless Puppet.version >= '2.6.5'
  fail "This report processor requires Puppet version 2.6.5 or later"
end

Puppet::Reports.register_report(:boundary) do

  configfile = File.join([File.dirname(Puppet.settings[:config]), "boundary.yaml"])
  raise(Puppet::ParseError, "Boundary report config file #{configfile} not readable") unless File.exist?(configfile)
  @config = YAML.load_file(configfile)
  GH_USER, GH_TOKEN = @config[:github_user], @config[:github_token]
  BOUNDARY_API, BOUNDARY_ORG = @config[:boundary_apikey], @config[:boundary_orgid]

  desc <<-DESC
  Send notification Puppet runs as Boundary annotations.
  DESC

  def process
    return if self.status == 'unchanged'
    if self.status == 'failed'
      tags = ["puppet", "exception", "failure", self.status ]
      type = "Puppet Exception"
    else
      tags = ["puppet", self.status ]
      type = "Puppet"
    end

    output = []
    self.logs.each do |log|
      output << log
    end

    gist_id = gist(self.status,self.host,output)
    annotation_url = create_annotation(gist_id,tags,type,self.host,self.time)
  end

  def gist(status,host,output)
    begin
      timeout(8) do
        res = Net::HTTP.post_form(URI.parse("http://gist.github.com/api/v1/json/new"), {
          "files[#{host}-#{Time.now.to_i.to_s}]" => output.join("\n"),
          "login" => GH_USER,
          "token" => GH_TOKEN,
          "description" => "Puppet run #{status} on #{host} @ #{Time.now.asctime}",
          "public" => false
        })
        gist_id = JSON.parse(res.body)["gists"].first["repo"]
        Puppet.info "Create a GitHub Gist @ https://gist.github.com/#{gist_id}"
        gist_id
      end
    rescue Timeout::Error
      Puppet.error "Timed out while attempting to create a GitHub Gist, retrying ..."
      max_attempts -= 1
      retry if max_attempts > 0
    end
  end

  def create_annotation(gist_id,tags,type,host,time)
    auth = auth_encode("#{BOUNDARY_API}:")
    headers = {"Authorization" => "Basic #{auth}", "Content-Type" => "application/json"}

    annotation = {
      :type => type,
      :subtype => host,
      :start_time => time.to_i,
      :end_time => time.to_i,
      :tags => tags,
      :links => [
        {
         "rel" => "output",
         "href" => "https://gist.github.com/#{gist_id}",
         "note" => "gist"
        }
      ]
    }

    annotation_json = annotation.to_json

    uri = URI("https://api.boundary.com/#{BOUNDARY_ORG}/annotations")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ca_file = "#{File.dirname(__FILE__)}/cacert.pem"
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    begin
      timeout(10) do
        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = annotation_json

        headers.each{|k,v|
          req[k] = v
        }

        res = http.request(req)

        bad_response?(:post, uri.request_uri, res)

        Puppet.info "Created a Boundary Annotation @ #{res["location"]}"
        res["location"]
      end
    rescue Timeout::Error
      Puppet.error "Timed out while attempting to create Boundary Annotation"
    end
  end

  def auth_encode(creds)
    auth = Base64.encode64(creds).strip
    auth.gsub("\n","")
  end

  def bad_response?(method, url, response)
    case response
    when Net::HTTPSuccess
      false
    else
      true
      Puppet.error "Got a #{response.code} for #{method} to #{url}"
    end
  end
end
