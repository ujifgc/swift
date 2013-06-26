module Swift
  module ModelPlugins
    module Publishable
      module ClassMethods
        # Resource is publishable
        # It has publish flag and publish time
        # It fixes the properties before save
        # It extends its model to return all published resources
        def publishable!
          send :include, InstanceMethods

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
      end

      module InstanceMethods
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
    end
  end
end
