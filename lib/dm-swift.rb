#coding:utf-8
module SwiftDatamapper

  module ClassMethods

    # Resource has timestamps
    def timestamps!
      property :created_at, DateTime
      property :updated_at, DateTime
    end

    # Resource has userstamps
    # It fills its creator before creating itself
    def userstamps!
      belongs_to :created_by, 'Account', :required => false
      belongs_to :updated_by, 'Account', :required => false

      before :create do |i|
        i.created_by_id = i.updated_by_id
      end
    end

    # Resource is sluggable
    # It composes a slug by title before save if the slug is not set already
    # It extends its model to be able to find a resource by its slug
    # Slug is a human-readable unique resource identifier
    def sluggable! options = {}
      send :include, SluggableMethods

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

    # Resource is publishable
    # It has publish flag and publish time
    # It fixes the properties before save
    # It extends its model to return all published resources
    def publishable!
      send :include, PublishableMethods

      property :is_published, DataMapper::Property::Boolean, :default => false
      property :publish_at, DateTime

      before :valid? do |i|
        self.is_published = false  if self.is_published.blank?
        self.publish_at = nil  if self.publish_at.blank?
      end

      def self.published
        all( :is_published => true, :conditions => ["IFNULL(publish_at,0) < ?", DateTime.now] )
      end
    end

    # Resource is dateable
    # It has date property and does some fixing before save
    def dateable!
      property :date, DateTime, :required => true

      before :valid? do |i|
        self.date = nil  if self.date.blank?
      end
    end

    # Resource is uploadable
    # It remembers file size and mime type before saving
    def uploadable!
      send :include, UploadableMethods

      property :file_content_type, String, :length => 63
      property :file_size, Integer

      before :save do |o|
        path = o.file.access_path
        if File.exists?(path)
          o.file_content_type = `file -bp --mime-type '#{path}'`.to_s.strip
          o.file_size = File.size path
        else
          o.file_content_type = o.file_size = nil
        end
        o.save!
      end
    end

    # Resource is bondable
    # It can be bound to some parent resource
    def bondable!
      send :include, BondableMethods

      after :destroy do |parent|
        Bond.separate parent
      end
    end

    # Resource is amorphous
    # It has json property to contain any reasonable number of fields
    # and get/set/fill it with Hash params
    def amorphous!
      send :include, AmorphousMethods

      property :json, DataMapper::Property::Json, :default => {}
    end

    # Resource is recursive
    # Usable for making resources with paths like URIs
    def recursive!
      send :include, RecursiveMethods

      property :path,     String, :length => 2000, :index => true

      has n, :children, self.name, :child_key => :parent_id
      belongs_to :parent, self.name, :required => false

      before :valid? do
        self.parent = nil  if parent_id.blank?
      end

      before :save do
        self.parent = nil  if id == parent_id
        self.path = parent ? parent.path + '/' + slug : slug
      end
    end

    def loggable!
      send :include, LoggableMethods
      before :save do
        @original_content = Hash[original_attributes.select do |property, value|
          if Protocol::IGNORED_PROPERTIES.include?(property.name) || value.kind_of?(DataMapper::Resource)
            false
          else
            value != self.attribute_get(property.name)
          end
        end.map{ |property, value| [property.name, value] }]
      end
      after :save do
        Protocol.log( :save => self, :data => @original_content )  if @original_content.any?
      end
      after :destroy do |object|
        Protocol.log :destroy => object
      end
    end

    def metable!
      send :include, MetableMethods

      property :meta, DataMapper::Property::Json, :default => {}
    end

  end

  # Methods for all resourced
  module InstanceMethods
  end

  module MetableMethods
    def meta
      attribute_get(:meta) || {}
    end
  end

  module SluggableMethods

    # Resolves the mystery of parametrizing sluggable resource
    def to_param
      self.respond_to?( :slug ) ? self.slug : self.id
    end

  end

  module PublishableMethods

    # Publishes a publishable resource
    # if it has no publish time, set it
    # if it has it, maybe reset it
    # finally, set the published flag
    def publish!( time = nil )
      if !self.publish_at
        self.publish_at = time || DateTime.now
      elsif time
        self.publish_at = time
      end
      self.is_published = true
      self.save
    end

    # Unsets the published flag, doesnt touch publish time
    def unpublish!
      self.is_published = false
      self.save
    end

    # Guesses if resource is published and not in the future
    def published?
      self.is_published && Time.at(self.publish_at.to_i).to_datetime <= DateTime.now
    end

  end  

  module UploadableMethods
    def info
      "#{title} (#{file.content_type}, #{file.size.as_size})"
    end
  end

  module BondableMethods

    # Guesses if resource is bound to specified parent
    # The parent is specified by model name and id
    def bound?( parent_model, parent_id = nil )
      parent_model = if parent_model.kind_of? Symbol
        parent_model.to_s.singularize.camelize
      elsif parent_model.kind_of? String
        parent_model.singularize.camelize
      elsif parent_model.kind_of? Class
        parent_model.name
      else
        parent_id = parent_model.id
        parent_model.class.name
      end
      return false  unless parent_id
      bond = Bond.first :parent_model => parent_model,
                        :parent_id    => parent_id,
                        :child_model  => self.class.to_s,
                        :child_id     => self.id,
                        :manual       => true,
                        :relation     => 1
      bond ? true : false
    end

    # Returns number of bound children of specified type
    def bond_count( child_model = nil )
      filter = {
        :parent_model => self.class.to_s,
        :parent_id    => self.id,
        :manual       => true,
        :relation     => 1
      }
      filter.merge :child_model => child_model  if child_model
      Bond.count filter
    end

  end

  module AmorphousMethods

    # A getter/initializer for json errors
    def json_errors
      @json_errors ||= {} # !!! FIXME test this, it might fail
    end

    # A getter for amorphous fields
    def []( key )
      return super key  if properties.named? key
      # !!!FIXME freeze is a safeguard for a smartass eager to use something
      # like `<<` instead of `=`, maybe fix it sometime
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
      values = params.delete 'value'
      requires = Hash[(params.delete('require') || []).map{|k,v| [k, v.to_s=='1']}]
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

  module RecursiveMethods

    # Prepares a title for tree view of recursive resource
    def title_tree( connector = '· · ' )
      prepend = ''
      done = { id => true }
      cp = parent_id
      while cp do
        pid = self.class.get(cp).parent_id
        cp = done[pid] ? nil : pid
        prepend += connector
      end
      "#{prepend} #{title} (#{slug})"
    end

    def parents
    end

    # Guesses if the resource has no parents
    def root?
      self.path == '/'
    end

  end

  module LoggableMethods
  end

end
