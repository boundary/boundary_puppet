require 'puppet'
require 'yaml'
require 'net/http'
require 'net/https'
require 'uri'


unless Puppet.version >= '2.6.5'
  fail "This report processor requires Puppet version 2.6.5 or later"
end

Puppet::Reports.register_report(:boundary) do

  desc <<-DESC
  Send notification Puppet runs as Boundary annotations.
  DESC

  @configfile = File.join([File.dirname(Puppet.settings[:config]), "boundary.yaml"])
  if File.exists?(@configfile)
    @config = YAML.load_file(@configfile)
    BOUNDARY_API, BOUNDARY_ORG = @config[:boundary_apikey], @config[:boundary_orgid]

    def process
      return if self.status == 'unchanged'
      if self.status == 'failed'
        tags = ["puppet", "exception", "failure", self.status ]
        title = "Puppet Exception"
        status = "OPEN"
        severity = "ERROR"
      else
        tags = ["puppet", self.status ]
        title = "Puppet"
        status = "OK"
        severity = "INFO"
      end

      create_event(title, tags,status, severity ,self.host,self.time)
    end
  else
    Puppet.debug "Boundary annotations disabled"
    def process
      Puppet.info "Boundary annotations disabled: report config file #{@configfile} not readable"
    end
  end

  def create_event( title, tags, status, severity, host,time)
    auth = auth_encode("#{BOUNDARY_API}:")
    headers = {"Authorization" => "Basic #{auth}", "Content-Type" => "application/json"}
    fingerprints=["@title"]
    source = {"ref" => host, "type" => "meter" }
    event = {
	 :source => source,
      :severity => severity,
      :status => status,
      :fingerprintFields => fingerprints,
      :tags => tags,
      :title => title ,
      :message => host,
      :createdAt => time.to_i

    }

    event_pson = event.to_pson
    uri = URI("https://api.boundary.com/#{BOUNDARY_ORG}/events")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ca_file = "#{File.dirname(__FILE__)}/cacert.pem"
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    begin
      timeout(10) do
        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = event_pson

        headers.each{|k,v| 
          req[k] = v 
        }

        res = http.request(req)

        bad_response?(:post, uri.request_uri, res)

        Puppet.info "Created a Boundary Annotation @ #{res["location"]}"
       
        res["location"]
      end
    rescue Timeout::Error
      Puppet.error "Timed out while attempting to create Boundary Event"
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
      Puppet.error "Got a #{response.code} for #{method} to #{url}"
      true
    end
  end
end
