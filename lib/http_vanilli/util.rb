require 'uri'

module HttpVanilli
  class Util
    def self.decode_userinfo_from_header(header)
      header.sub(/^Basic /, "").unpack("m").first
    end

    def self.encode_unsafe_chars_in_userinfo(userinfo)
      unsafe_in_userinfo = /[^#{URI::REGEXP::PATTERN::UNRESERVED};&=+$,]|^(#{URI::REGEXP::PATTERN::ESCAPED})/
      userinfo.split(":").map { |part| uri_escape(part, unsafe_in_userinfo) }.join(":")
    end

    def self.strip_default_port_from_uri(uri)
      case uri
      when %r{^http://}  then uri.sub(%r{:80(/|$)}, '\1')
      when %r{^https://} then uri.sub(%r{:443(/|$)}, '\1')
      else uri
      end
    end

    # Wrapper for URI escaping that switches between URI::Parser#escape and
    # URI.escape for 1.9-compatibility
    def self.uri_escape(*args)
      if URI.const_defined?(:Parser)
        URI::Parser.new.escape(*args)
      else
        URI.escape(*args)
      end
    end
  end
end
