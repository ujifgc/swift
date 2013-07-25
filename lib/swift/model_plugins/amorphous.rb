module Swift
  module ModelPlugins
    module Amorphous
      module ClassMethods
        # Resource is amorphous
        # It has json property to contain any reasonable number of fields
        # and get/set/fill it with Hash params
        def amorphous!
          send :include, InstanceMethods
          property :json, DataMapper::Property::Json, :default => {}, :lazy => false
        end
      end

      module InstanceMethods
        # A getter/initializer for json errors
        def json_errors
          @json_errors ||= {}
        end

        # A getter for amorphous fields
        def []( key )
          return super key  if properties.named? key
          # freeze is a safeguard against `[]<<`
          self.json[key.to_s].freeze
        end

        # A Setter for amorphous fields
        def []=( key, value )
          return super( key, value )  if properties.named? key
          self.json[key.to_s] = value
        end

        # Fills amorphous parent with a hash of params, possibly correcting
        # childrens' keys
        # Returns nothing of interest
        def fill_json( params, children_method )
          keys = params.delete 'key'
          types = params.delete 'type'
          values = Hash[params.delete('value').map{|k,v| [k,v.gsub(/ *(\r|\n|\r\n) *| *$/m,'\1')]}]
          requires = Hash[(params.delete('require') || []).map{ |k,v| [k, v.to_s=='1']}]
          renames = {}
          keys.each do |k,v,r|
            if types[k] == "" || v.blank?
              self.json.delete k
              next
            end
            if k.match(/json_new-\d+/)
              self.json[keys[k]] = [types[k], values[k], requires[k]]
              next
            end
            if k != v
              renames.merge! k => v
              next
            end
            self.json[keys[k]] = [types[k], values[k], requires[k]]
          end
          if renames.any?
            self.json = Hash[self.json.map{ |k,v| renames[k] ? [renames[k], [types[k], values[k], requires[k]]] : [k, v] }]
            self.send(children_method).each do |child|
              child.json = Hash[child.json.map{ |k,v| renames[k] ? [renames[k], v] : [k, v] }]
              child.save
            end
          end
        end
      end
    end
  end
end
