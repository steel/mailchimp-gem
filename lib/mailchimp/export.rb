require 'httparty'
require 'json'
require 'cgi'

module Mailchimp
  class Export < Base
    
    include HTTParty
    format :plain
    default_timeout 30
    
    def initialize(api_key = nil, default_parameters = {})
      super(api_key, {:apikey => api_key}.merge(default_parameters))
    end

    def export_api_url
      "http://#{dc_from_api_key}api.mailchimp.com/export/1.0/"
    end

    def call(method, params = {})
      api_url = export_api_url + method + "/"
      params = @default_params.merge(params)
      timeout = params.delete(:timeout) || @timeout
      response = self.class.post(api_url, :body => params, :timeout => timeout)

      lines = response.body.lines
      if @throws_exceptions
        first_line_object = JSON.parse(lines.first) if lines.first
        raise "Error from MailChimp Export API: #{first_line_object["error"]} (code #{first_line_object["code"]})" if first_line_object.is_a?(Hash) && first_line_object["error"]
      end

      lines  
    end
    
    class << self
      attr_accessor :api_key

      def method_missing(sym, *args, &block)
        new(self.api_key).send(sym, *args, &block)
      end
    end
  end
end

module HTTParty
  module HashConversions
    # @param key<Object> The key for the param.
    # @param value<Object> The value for the param.
    #
    # @return <String> This key value pair as a param
    #
    # @example normalize_param(:name, "Bob Jones") #=> "name=Bob%20Jones&"
    def self.normalize_param(key, value)
      param = ''
      stack = []

      if value.is_a?(Array)
        param << Hash[*(0...value.length).to_a.zip(value).flatten].map {|i,element| normalize_param("#{key}[#{i}]", element)}.join
      elsif value.is_a?(Hash)
        stack << [key,value]
      else
        param << "#{key}=#{URI.encode(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}&"
      end

      stack.each do |parent, hash|
        hash.each do |key, value|
          if value.is_a?(Hash)
            stack << ["#{parent}[#{key}]", value]
          else
            param << normalize_param("#{parent}[#{key}]", value)
          end
        end
      end

      param
    end
  end
end
