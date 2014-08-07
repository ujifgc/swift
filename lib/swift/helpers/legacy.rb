module Swift
  module Helpers
    module Legacy
      LEGACY_FILE = 'config/legacy.yml'
      DEFAULT_LEGACY_URL_BASE = 'legacy/'
      DEFAULT_LEGACY_URL_MAP = '/'

      def process_legacy
        legacy_settings = load_legacy_settings
        url = params[:request_uri].partition(legacy_settings['url_base'] || DEFAULT_LEGACY_URL_BASE).last
        new_url = Option(:legacy_url_map)[url] rescue nil
        new_url ||= legacy_settings['url_map'][url] rescue nil
        redirect new_url || DEFAULT_LEGACY_URL_MAP
      end

      private

      def load_legacy_settings
        file = Padrino.root(LEGACY_FILE)
        return({}) unless File.file?(file)
        @legacy_settings = nil if @last_legacy_update.to_i < File.mtime(file).to_i
        @legacy_settings ||= YAML.load_file(file)
        @last_legacy_update = File.mtime(file)
        @legacy_settings
      end
    end
  end
end
