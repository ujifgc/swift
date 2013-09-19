require 'swift/monkey/datamapper/dirty_minder'
require 'swift/monkey/datamapper/json'

# Allows amorphous resources to fill its' json with any attributes
module DataMapper
  module Resource
    def attributes=(attributes)
      model = self.model
      attributes.each do |name, value|
        case name
        when String, Symbol
          if model.allowed_writer_methods.include?(setter = "#{name}=")
            __send__(setter, value)
          else
            if self.respond_to? :json
              self.json[name] = value
            else
              raise ArgumentError, "The attribute '#{name}' is not accessible in #{model}"
            end
          end
        when Associations::Relationship, Property
          self.persistence_state = persistence_state.set(name, value)
        end
      end
    end
  end
end
