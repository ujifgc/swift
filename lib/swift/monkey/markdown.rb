module Markdown
  MarkdownExtras = {
    :autolink => true,
    :space_after_headers => true,
    :tables => true,
    :strikethrough => true,
    :no_intra_emphasis => true,
    :superscript => true,
  }

  # Makes MixedHTML class which will render markdown inside block-level HTML tags
  class LiteHTML < Redcarpet::Render::HTML
    def paragraph(text)
      text
    end
  end

  class MixedHTML < Redcarpet::Render::HTML
    HTML_TAG_SPLIT = /\A(\<([^>\s]*)(?:\s+[^>]*)*\>)(.*)(\<\/\2(?:\s+[^>]*)?\>\n*)\z/m.freeze
    def block_html(raw_html)
      if data = raw_html.match( HTML_TAG_SPLIT )
        data[1] + LiteParser.render(data[3]) + data[4]
      else
        raw_html
      end
    end
  end  

  LiteParser = Redcarpet::Markdown.new( LiteHTML, MarkdownExtras )
  MixedParser = Redcarpet::Markdown.new( MixedHTML, MarkdownExtras )

  def self.render( text )
    MixedParser.render text
  end
end
