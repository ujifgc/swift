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
    content = mk_published( target ) + check_box_tag( name, :checked => false, :id => name )
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
    link_to mk_icon(op) + pat(op), :method => op, :class => 'multiple btn'
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

  def allow role
    if current_account.allowed role
      @allowed = role
      yield
      @allowed = nil
    end
  end

  def page_tree( from, level, prefix )
    pages = Page.all :parent_id => from, :order => [:position, :path]
    return false  unless pages.length > 0

    tree = []
    pages.each do |page|
      tree << { :page => page,
                :child => page_tree(page.id, level + 1, prefix + '/' + page.slug) }
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
