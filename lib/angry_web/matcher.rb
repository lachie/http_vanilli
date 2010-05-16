require 'addressable/uri'
require 'rack'
require 'pp'

class Object
  def tapp(tag=nil)
    print "#{tag}=" if tag
    pp self
    self
  end
end

class AngryWeb
  class ValueMatcher
    attr_reader :mismatch_reason
    def initialize(value)
      @mismatch_reason = "<no reason>"
      @value = value
    end
  end

  class HashSubsetMatcher < ValueMatcher
    def match?(params)
      @value.keys.all? do |k|
        match = @value[k]
        param = params[k.to_s]

        case match
        when Regexp
          !! param[match]
        else
          match == param
        end
      end
    end
  end

  class REMatcher < ValueMatcher
    def match?(other)
      other.to_s.match(@value)
    end
  end

  class EqlMatcher < ValueMatcher
    def match?(other)
      @value == other
    end
  end

  class Matcher
    attr_reader :mismatches

    def initialize(&blk)
      @parts = {}
      yield self
    end

    def match?(uri)
      uri = Addressable::URI.heuristic_parse(uri)
      uri_hash = uri.to_hash

      @mismatches = []

      @parts.each {|k,v|
        unless v.match?(__transform_value_from_uri(uri_hash,k))
          @mismatches << v.mismatch_reason
        end
      }

      @mismatches.empty?
    end

    def hash_subset(spec)
      HashSubsetMatcher.new(spec)
    end

    def method_missing(meth,*args,&block)
      if args.size == 1
        @parts[meth] = __convert_value(args.first)
      else
        super
      end
    end

    def __convert_value(value)
      case value
      when ValueMatcher
        value
      when Regexp
        REMatcher.new(value)
      else
        EqlMatcher.new(value)
      end
    end

    def __transform_value_from_uri(uri,key)
      case key
      when :params
        Rack::Utils.parse_query(uri[:query])
      else
        uri[key]
      end
    end
  end
end
