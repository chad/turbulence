require 'json'

class Turbulence
  class FileNameMangler
    def initialize
      @current_id = 0
      @segment_map = { "" => "", "app" => "app", "controllers" => "controllers", "helpers" => "helpers", "lib" => "lib" }
    end

    def transform(segment)
      @segment_map[segment] ||= (@current_id += 1)
    end

    def mangle_name(filename)
      filename.split('/').map {|seg|transform(seg)}.join('/') + ".rb"
    end
  end
end
