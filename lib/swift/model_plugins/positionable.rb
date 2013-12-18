module Swift
  module ModelPlugins
    module Positionable
      module ClassMethods
        POSITION_STEP = 5

        # !!! FIXME positionable now must be resursive. It should not have to.
        def positionable!
          send :include, InstanceMethods
          property :position, Integer

          before :valid? do
            if position.blank? || self.class.first( :parent_id => parent_id, :position => position, :id.not => id )
              max = self.class.all( :parent_id => parent_id ).published.max(:position)
              self.position = max.to_i + POSITION_STEP
            end
          end

          def self.reposition_all!
            position = 0
            all( :order => [ :parent_id, :position, :id ] ).to_a.each do |object|
              position += POSITION_STEP
              object.position = position
              object.save!
            end
          end
        end
      end

      module InstanceMethods
        def reposition!( direction )
          sibling = find_sibling( direction ) || return
          if position == sibling.position
            self.class.reposition_all!
          else
            switch_positions sibling
          end
        end

        private

        def find_sibling( direction )
          case direction.downcase.to_sym
          when :up
            self.class.first :position.lte => position, :id.not => id, :parent_id => parent_id, :order => [:position.desc]
          when :down
            self.class.first :position.gte => position, :id.not => id, :parent_id => parent_id, :order => [:position]
          else
            fail ArgumentError, 'direction must be :up or :down'
          end
        end

        def switch_positions( sibling )
          old_position = position
          self.position = sibling.position
          save!
          sibling.position = old_position
          sibling.save!
        end
      end
    end
  end
end
