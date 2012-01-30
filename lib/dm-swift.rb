#coding:utf-8
module SwiftDatamapper
  module ClassMethods

    def sluggable!

      property :slug, String

      before :valid? do |i|
        if self.slug.blank?
          slug = (self.title || self.id).to_s.gsub(/[^0-9a-zA-Zа-яёА-ЯЁ]+/, ' ')
          slug.strip!
          slug.gsub!(/\ +/, '-')
          slug.gsub!(/^-+|-+$/, '')
          self.slug = Russian.translit(slug).downcase!
        end
      end

      def self.by_slug( slug )
        get( slug ) || first( :slug => slug )
      end

    end

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

    def publishable!
      property :is_published, DataMapper::Property::Boolean, :default => true
      property :publish_at, DateTime

      before :valid? do |i|
        self.is_published = false  if self.is_published.blank?
        self.publish_at = nil  if self.publish_at.blank?
      end

      def self.published
        all( :is_published => true )
      end
   end

  end

  module InstanceMethods

    def to_param
      self.respond_to?( :slug ) ? self.slug : self.id
    end

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

end
