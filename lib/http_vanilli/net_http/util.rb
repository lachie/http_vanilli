module HttpVanilli
  module NetHttp
    def self.puts_warning_for_net_http_around_advice_libs_if_needed
      libs = {"Samuel" => defined?(Samuel)}
      warnings = libs.select { |_, loaded| loaded }.map do |name, _|
        <<-TEXT.gsub(/ {10}/, '')
          \e[1mWarning: FakeWeb was loaded after #{name}\e[0m
          * #{name}'s code is being ignored when a request is handled by HttpVanilli::NetHttp,
            because both libraries work by patching Net::HTTP.
          * To fix this, just reorder your requires so that FakeWeb is before #{name}.
        TEXT
      end
      $stderr.puts "\n" + warnings.join("\n") + "\n" if warnings.any?
    end

    def self.record_loaded_net_http_replacement_libs
      libs = {"RightHttpConnection" => defined?(RightHttpConnection)}
      @loaded_net_http_replacement_libs = libs.map { |name, loaded| name if loaded }.compact
    end

    def self.puts_warning_for_net_http_replacement_libs_if_needed
      libs = {"RightHttpConnection" => defined?(RightHttpConnection)}
      warnings = libs.select { |_, loaded| loaded }.
                    reject { |name, _| @loaded_net_http_replacement_libs.include?(name) }.
                    map do |name, _|
        <<-TEXT.gsub(/ {10}/, '')
          \e[1mWarning: #{name} was loaded after HttpVanilli::NetHttp\e[0m
          * FakeWeb's code is being ignored, because #{name} replaces parts of
            Net::HTTP without deferring to other libraries. This will break Net::HTTP requests.
          * To fix this, just reorder your requires so that #{name} is before FakeWeb.
        TEXT
      end
      $stderr.puts "\n" + warnings.join("\n") + "\n" if warnings.any?
    end
  end
end
