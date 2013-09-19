#coding:utf-8
module Swift
  module ModelPlugins
    module Recursive
      module ClassMethods
        # Resource is recursive
        # Usable for making resources with paths like URIs
        def recursive!
          send :include, InstanceMethods

          property :path, String, :length => 2000, :index => true

          has n, :children, name, :child_key => :parent_id
          belongs_to :parent, name, :required => false

          before :valid? do
            self.parent = nil  if parent_id.blank?
          end

          before :save do
            self.parent = nil  if id == parent_id
            self.path = parent ? parent.path + '/' + slug : slug
          end
        end
      end

      module InstanceMethods
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
    end
  end
end
