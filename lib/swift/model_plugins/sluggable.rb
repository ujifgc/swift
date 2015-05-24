module Swift
  module ModelPlugins
    module Sluggable
      module ClassMethods
        # Resource is sluggable
        # It composes a slug by title before save if the slug is not set already
        # It extends its model to be able to find a resource by its slug
        # Slug is a human-readable unique resource identifier
        def sluggable!(*args)
          send :include, InstanceMethods

          options = args.extract_options!
          @slug_field = args.first || :title
          @slug_limit = options.delete(:limit).to_i
          @slug_limit = 250 unless (1..250).include?(@slug_limit.to_i)

          property :slug, String, { :unique_index => true }.merge(options)
          validates_uniqueness_of :slug  if options[:unique_index]

          before :valid? do
            self.slug = (send(self.class.slug_field) || id).to_s.as_slug  if slug.blank?
            self.slug = slug.strip[0..self.class.slug_limit]
            filter = { :id.not => id }
            filter[:parent] = parent  if respond_to? :parent
            while self.class.first( filter.merge(:slug => slug) )
              slug.match(/\-\d+$/) ? self.slug.succ! : (self.slug += '-1')
            end
          end

          def self.slug_field
            @slug_field
          end

          def self.slug_limit
            @slug_limit
          end

          def self.by_slug( slug )
            get( slug ) || first( :slug => slug )
          end
        end
      end

      module InstanceMethods
        # Resolves the mystery of parametrizing sluggable resource
        def to_param
          respond_to?( :slug ) ? slug : id
        end
      end
    end
  end
end

module Sequel::Plugins::Sluggable
  module ClassMethods
    def by_slug(slug)
      with_pk(slug) || first_where(:slug => slug)
    end
  end
end
