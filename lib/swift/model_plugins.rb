Dir.glob( File.dirname(__FILE__) + '/model_plugins/*.rb' ).each { |file| require file }

module Swift
  module ModelPlugins
    module ClassMethods
      include Swift::ModelPlugins::Amorphous::ClassMethods
      include Swift::ModelPlugins::Bondable::ClassMethods
      include Swift::ModelPlugins::Dateable::ClassMethods
      include Swift::ModelPlugins::Loggable::ClassMethods
      include Swift::ModelPlugins::Metable::ClassMethods
      include Swift::ModelPlugins::Publishable::ClassMethods
      include Swift::ModelPlugins::Recursive::ClassMethods
      include Swift::ModelPlugins::Sluggable::ClassMethods
      include Swift::ModelPlugins::Stamps::ClassMethods
      include Swift::ModelPlugins::Datatables::ClassMethods
    end
  end
end
