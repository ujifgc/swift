Admin.helpers do

  ICONS = {
  # operations
    :delete    => 'remove',
    :publish   => 'ok',
    :unpublish => 'ban-circle',
    :list      => 'list',
    :new       => 'plus',
    :edit      => 'edit',
    :bind      => 'magnet',
    :show      => 'eye-open',

  # modules
    :pages     => 'globe',
    :images    => 'picture',
    :assets    => 'file',
    :blocks    => 'list-alt',
    :folders   => 'folder-open',

    :news_articles => 'bookmark',
    :news_rubrics  => 'tasks',
    :news_events   => 'flag',

    :forms_cards   => 'check',
    :forms_stats   => 'signal',
    :forms_results => 'list',

    :cat_cards  => 'inbox',
    :cat_nodes  => 'folder-close',
    :cat_groups => 'tag',

    :fragments => 'th',
    :layouts   => 'cog',
    :elements  => 'cog',

    :accounts  => 'user',
    :codes     => 'font',
    :options   => 'wrench',

    :archives    => 'sr-archives',
    :funds       => 'sr-funds',
    :inventories => 'sr-inventories',
    :units       => 'sr-units',

    :uploads     => 'upload',
    :utilities   => 'refresh',
  }

  def mk_edit( target )
    link_to( target.title, url(target.class.storage_name.to_sym, :edit, :id => target.id), :class => :edit )
  end

  def mk_checkbox( target, sorter = nil )
    name = :"check_#{target.class.name.underscore}[#{target.id}]"
    content = check_box_tag( name, :checked => false, :id => name ) + mk_published( target )
    content_tag :label, content, :for => name, :class => :checkbox, :'data-sorter' => (sorter || target.id)
  end

  def mk_published( target )
    return ''.html_safe  unless target.respond_to? :is_published
    content_tag( :i, '', :class => 'icon-'+(target.is_published ? 'ok' : 'ban-circle') ) + ' '
  end

  def mk_icon( op, white = nil )
    content_tag( :i, '', :class => 'icon-'+(ICONS[op]||'warning-sign')+(white ? ' icon-white' : '') ) + ' '
  end

  def mk_glyph( s, opt = {} )
    s = s.to_s
    s += ' icon-white'  if opt.delete( :white )
    content_tag( :i, '', { :class => 'icon-'+s }.merge(opt) )
  end

  def mk_glyphs( *ss )
    ss.inject(''.html_safe) do |all, s|
      all << content_tag( :i, '', :class => 'icon-'+s )
    end
  end

  def mk_multiple_op( op )
    if op == :delete || op == :destroy
      link_to mk_icon(op) + pat(op), :method => op, :class => 'multiple btn', 'data-prompt' => pat('confirm.multiple_delete')
    else
      link_to mk_icon(op) + pat(op), :method => op, :class => 'multiple btn'
    end
  end

  def mk_single_op( op, link )
    link_to mk_icon(op) + pat(op), link, :class => :single
  end

  def mk_dialog_op( op, link, opts={} )
    name = content_tag(:u, mk_icon(op) + pat(op) + (opts.delete(:add)||''))
    link_to name, link, opts.merge(:class => 'single dialog', :'data-toggle' => :modal)
  end

  def mk_button_op( op, link )
    op = :delete  if op == :destroy
    link_to mk_icon(op) + pat(op), link, :method => op, :class => 'single button_to'
  end

  BADGE_COLOR = {
    :created_at => 'badge-success',
    :updated_at => 'badge-info',
  }.freeze
  def mk_timestamps( obj )
    timestamps = [ :updated_at, :created_at ].inject(''.html_safe) do |html, tag|
      next html  unless obj.respond_to? tag
      date = obj.send(tag)
      user_method = tag.to_s.sub('_at','_by').to_sym
      user = obj.respond_to?( user_method ) ? obj.send( user_method ) : nil
      tags = content_tag( :span, mat(:object,tag) + ':', :class => 'legend' )
      tags << content_tag( :span, date.as_date, :class => "badge #{BADGE_COLOR[tag]}" )
      if user
        title = user.role_title.html_safe + ' '.html_safe
        title << mk_glyph( :user, :white => true ) + ' '.html_safe
        title << link_to( user.name, url(:accounts, :show, :id => user.id, :object_id => obj.id, :object_type => obj.class.name).html_safe, :class => 'white' )
        tags << content_tag( :span, title, :class => "badge #{BADGE_COLOR[tag]}" )
      end
      html << content_tag( :div, tags, :class => 'partition' )
    end
    content_tag( :div, timestamps, :class => 'timestamps' )
  end

  def allow role
    if current_account.allowed role
      @allowed = role
      yield
      @allowed = nil
    end
  end

  def page_tree( from, level, prefix, published = nil )
    pages = if published
      Page.published.all :parent_id => from, :order => [:position, :path]
    else
      Page.all :parent_id => from, :order => [:position, :path]
    end
    return false  unless pages.length > 0

    tree = []
    pages.each do |page|
      tree << { :page => page,
                :child => page_tree(page.id, level + 1, prefix + '/' + page.slug, published) }
    end
    return tree
  end

  def tree_flat( tree )
    ret = []
    (tree||[]).each do |leaf|
      ret << leaf[:page]
      ret += tree_flat(leaf[:child])
    end
    ret.compact
  end

  def url_after_save
    if params[:apply]
      url(@models, :edit, @object.id)
    else
      url(@models, :index)
    end
  end

end
