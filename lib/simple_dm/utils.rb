module SimpleDM
  module Utils
    module_function

    def snake_case(string)
      string.gsub(/::/, '/')
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/,     '\1_\2')
            .tr('-', '_')
            .downcase
    end

    def class_name(klass)
      klass.name.split('::').last
    end
  end
end
