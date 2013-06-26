module Swift
  module ModelPlugins
    module Sluggable
      module ClassMethods
        # Resource is sluggable
        # It composes a slug by title before save if the slug is not set already
        # It extends its model to be able to find a resource by its slug
        # Slug is a human-readable unique resource identifier
        def sluggable! options = {}
          send :include, InstanceMethods

          property :slug, String, { :unique_index => true }.merge(options)
          validates_uniqueness_of :slug  if options[:unique_index]

          before :valid? do
            self.slug = (title || id).to_s.as_slug  if slug.blank?
            self.slug = slug.strip
            filter = { :id.not => id }
            filter[:parent] = parent  if self.respond_to? :parent
            while self.class.first( filter.merge(:slug => slug) )
              if slug.match(/\-\d+$/)
                self.slug = slug.gsub(/\-(\d+)$/){ "-#{$1.to_i+1}" }
              else
                self.slug = slug + '-1'
              end
            end
          end

          def self.by_slug( slug )
            get( slug ) || first( :slug => slug )
          end

        end
      end

      module InstanceMethods
        # Resolves the mystery of parametrizing sluggable resource
        def to_param
          self.respond_to?( :slug ) ? self.slug : self.id
        end
      end
    end
  end
end
