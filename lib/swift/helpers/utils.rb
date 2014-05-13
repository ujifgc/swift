module Swift
  module Helpers
    module Utils
      def show_asset(asset, options={})
        @file = asset
        @opts = options
        element_view 'File/view'
      end

      def icon_for(filename)
        iconfile = 'images/extname/16/file_extension_'+File.extname(filename)[1..-1]+'.png'
        iconpath = Padrino.root('public', iconfile)
        if File.file?(iconpath)
          image_tag '/'+iconfile
        else
          image_tag '/images/extname/16/file_extension_bin.png'
        end
      end
    end
  end
end
