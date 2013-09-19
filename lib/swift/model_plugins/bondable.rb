module Swift
  module ModelPlugins
    module Bondable
      module ClassMethods
        # Resource is bondable
        # It can be bound to some parent resource
        def bondable!
          send :include, InstanceMethods
          after :destroy do |object|
            Bond.separate object
          end
        end
      end

      module InstanceMethods
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
                            :child_id     => id,
                            :manual       => true,
                            :relation     => 1
          bond ? true : false
        end

        # Returns number of bound children of specified type
        def bond_count( child_model = nil )
          filter = {
            :parent_model => self.class.to_s,
            :parent_id    => id,
            :manual       => true,
            :relation     => 1
          }
          filter.merge :child_model => child_model  if child_model
          Bond.count filter
        end
      end
    end
  end
end
