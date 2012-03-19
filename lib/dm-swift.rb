#coding:utf-8
module SwiftDatamapper
  module ClassMethods

    def timestamps!
      property :created_at, DateTime
      property :updated_at, DateTime
    end

    def userstamps!
      belongs_to :created_by, 'Account', :required => false
      belongs_to :updated_by, 'Account', :required => false

      before :create do |i|
        i.created_by_id = i.updated_by_id
      end
    end

    def sluggable! options = {}
      send :include, PublishableMethods

      property :slug, String, { :unique_index => true }.merge(options)
      validates_uniqueness_of :slug  if options[:unique_index]

      before :valid? do |i|
        if self.slug.blank?
          slug = (self.title || self.id).to_s.gsub(/[^0-9a-zA-Zа-яёА-ЯЁ]+/, ' ')
          slug.strip!
          slug.gsub!(/\ +/, '-')
          slug.gsub!(/^-+|-+$/, '')
          self.slug = Russian.translit(slug).downcase
        end
      end

      def self.by_slug( slug )
        get( slug ) || first( :slug => slug )
      end

    end

    def publishable!
      send :include, PublishableMethods

      property :is_published, DataMapper::Property::Boolean, :default => false
      property :publish_at, DateTime

      before :valid? do |i|
        self.is_published = false  if self.is_published.blank?
        self.publish_at = nil  if self.publish_at.blank?
      end

      def self.published
        all( :is_published => true )
      end
    end

    def uploadable! uploader, options={}
      send :include, UploadableMethods

      mount_uploader :file, uploader
      property :file_content_type, String, :length => 63
      property :file_size, Integer

      before :save do
        path = Padrino.public + self.file.url
        if File.exists?(path)
          self.file_content_type = `file -bp --mime-type #{path}`.to_s.strip
          self.file_size = File.size path
        else
          self.file_content_type = self.file_size = nil
        end
      end
    end

  end


  module SluggableMethods
    def to_param
      self.respond_to?( :slug ) ? self.slug : self.id
    end
  end

  module PublishableMethods

    def publish!( time = nil )
      if !self.publish_at
        self.publish_at = time || DateTime.now
      elsif time
        self.publish_at = time
      end
      self.is_published = true
      self.save
    end

    def unpublish!
      self.is_published = false
      self.save
    end

    def published?
      self.is_published == true && self.publish_at <= DateTime.now
    end

  end  

  module UploadableMethods
  end

  module InstanceMethods
  end

end
