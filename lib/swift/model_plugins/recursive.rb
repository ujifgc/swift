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

          validates_with_block :parent_id do 
            if parent && parent.has_parent?( self )
              [false, "Нельзя подчинить объект своему потомку"]
            else
              true
            end
          end
          before :valid? do
            self.parent = nil  if parent_id.blank?
          end

          before :save do
            self.parent = nil  if id == parent_id
            old_path = self.path
            self.path = parent ? parent.path + '/' + slug : slug
            self.children.each {|ch| ch.change_path! self.path }  if old_path != self.path
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
        
        def change_path!( parent_path )
          self.path = parent_path + '/' + slug
          save!
          children.each{ |ch| ch.change_path! path }
        end
        
        def has_parent?( object )
          return false  if object.nil?
          oid = object.kind_of?( Numeric ) ? object : object.id
          return true  if oid == id
          has_parent = false
          page = self
          while page.parent_id
            has_parent ||= page.parent_id == oid
            page = page.parent
          end
          has_parent
        end
      end
    end
  end
end
