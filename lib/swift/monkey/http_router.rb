class HttpRouter::Request
  def initialize(path, rack_request)
    @rack_request = rack_request
    @path = Rack::Utils.unescape(path).split(/\//)
    @path.shift if @path.first == ''
    @path.push('') if path[-1] == ?/
    @extra_env = {}
    @params = []
    @acceptable_methods = Set.new
  end
end
