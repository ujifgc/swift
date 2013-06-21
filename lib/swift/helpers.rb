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
