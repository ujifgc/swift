Dir.glob( File.dirname(__FILE__) + '/helpers/*.rb' ).each { |file| require file }

module Swift
  module Helpers
    include Swift::Helpers::Init
    include Swift::Helpers::Defer
    include Swift::Helpers::Template
    include Swift::Helpers::Render
    include Swift::Helpers::Url
    include Swift::Helpers::Error
  end
end
