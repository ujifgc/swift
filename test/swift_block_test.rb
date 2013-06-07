require 'minitest_helper'

describe Swift do

  include RenderMethod
  include Padrino::Helpers::RenderHelpers
  include Padrino::Helpers::EngineHelpers

  before do
    @temp_text = Block.create :text => "Hello world!", :title => "text", :type => 0
    @temp_html = Block.create :text => "<a><img src=\"hi\"></a>", :title => "html", :type => 1
    @temp_tabl = Block.create :text => "<table><tr><td>Yes</td></tr></table>", :title => "table", :type => 2
  end

  it "should provide @text" do
    element("Block", @temp_html.id)
    @text.must_equal "<a><img src=\"hi\"></a>"
  end

  it "should be added pharragraph open tag before text and pharragraph close tag with line feed after text" do
    el = element("Block", @temp_text.id).strip
    el.must_equal "<p>Hello world!</p>"
  end

  it "should be save html-code" do
    el = element("Block", @temp_html.id).strip
    el.must_equal "<a><img src=\"hi\"></a>"
  end
  
  it "should be added the table caption with block title" do
    el = element("Block", @temp_tabl.id).strip
    el.must_equal '<table><caption>table</caption><tr><td>Yes</td></tr></table>'
  end
  
  it "should throw error" do
    el = element("Block", -1)
    el.must_equal "[Block #-1 missing]"
  end
  
  after do
    @temp_html.destroy
    @temp_text.destroy
    @temp_tabl.destroy
  end

end
