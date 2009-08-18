# Copyright (c) 2007 Matt Biddulph
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# -----------
# EXAMPLE USE
#
# d = Dopplr.new
#
# # get URL for user to approve token (pass in the URL we want to be called back on)
# puts d.login_url("http://example.com/path")
#
# # supply token returned from login URL
# d.set_token(token)
#
# # upgrade token to a reusable session. you should store this somewhere for future use.
# session = d.upgrade_to_session
# d.set_token(session)
#
# # calls /api/traveller_info/mattb
# pp d.traveller_info(:id => 'mattb')['traveller']

require 'rubygems'
require 'open-uri'
require 'net/https'
require 'xmlsimple'
require 'json'
require 'cgi'

class Dopplr
    def initialize(host="www.dopplr.com",port=443)
        @host = host
        @port = port
    end

    def login_url(callback)
        if @port == 443
            return "https://#{@host}/api/AuthSubRequest?next=" + CGI.escape(callback) + "&scope=http%3A%2F%2Fwww.dopplr.com%2F&session=1"
        else
            return "http://#{@host}/api/AuthSubRequest?next=" + CGI.escape(callback) + "&scope=http%3A%2F%2Fwww.dopplr.com%2F&session=1"
        end
    end

    def set_token(token)
        @token = token
    end

    def upgrade_to_session
        response = get_url('/api/AuthSubSessionToken')
        if response.match("Token=(.*)\n")
            self.set_token($1)
            return $1
        end
        return "Wrong token"
    end

    def get_url(path)
        http = Net::HTTP.new(@host, @port)
        if @port == 443
            http.use_ssl = true
        end

        http.start do |http|
            req = Net::HTTP::Get.new(path, { 'Authorization' => 'AuthSub token='+@token })
            response = http.request(req)
            return response.body
        end
    end

    def method_missing(symbol, *args)
        path = "/api/" + symbol.id2name
        opts = {}
        opts['format'] = 'js'
        if args.size == 1 and args[0].is_a? Hash
            if args[0].has_key?(:id)
                path += "/" + args[0][:id].to_s
                args[0].delete(:id)
            end
            opts.merge!(args[0])
        end
        qs = opts.keys.map { |key|
            key.to_s + "=" + CGI.escape(opts[key].to_s)
        }.join("&")
        if qs != ""
            path += "?" + qs
        end
        puts path
        data = self.get_url(path)
        begin
            if opts['format'] == 'js'
                return JSON.parse(data)
            else
                return XmlSimple.xml_in(data)
            end
        rescue
            return data
        end
    end
end
