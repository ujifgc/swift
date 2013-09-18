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
          return super(key)  if properties.named? key
          # freeze is a safeguard against `[]<<`
          json[key.to_s].freeze
        end

        # A Setter for amorphous fields
        def []=( key, value )
          return super(key, value)  if properties.named? key
          json[key.to_s] = value
        end

        # Fills amorphous parent with a hash of params, possibly correcting
        # childrens' keys
        # Returns nothing of interest
        def fill_json( params, children_method )
          types = params['type']
          values = Hash[params['value'].map{ |k,v| [k, strip_lines(v)] }]
          requires = Hash[(params['require']||[]).map{ |k,v| [k, v.to_s=='1'] }]
          renames = {}
          params['key'].each do |k,v|
            if types[k].blank? || v.blank?
              json.delete k
            else
              json[k] = [types[k], values[k], requires[k]]
              renames[k] = v  unless k == v
            end
          end
          perform_renaming( renames, children_method )  if renames.any?
        end

        private

        def strip_lines( s )
          s.gsub(/\s*(\r|\n|\r\n)\s*|\s*$/m,'\1')
        end

        def perform_renaming( renames, children_method )
          self.json = rename_json_keys json, renames
          send(children_method).each do |child|
            child.json = rename_json_keys child.json, renames
            child.save!
          end
        end

        def rename_json_keys( hash, renames )
          Hash[hash.map{ |k,v| renames[k] ? [renames[k], v] : [k, v] }]
        end
      end
    end
  end
end
