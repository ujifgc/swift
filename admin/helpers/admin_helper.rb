Admin.helpers do

  def mk_checkbox( target )
    name = :"check_#{target.class.name.underscore}[#{target.id}]"
    content = mk_light( target ) + check_box_tag( name, :checked => false, :id => name )
    content_tag :label, content, :for => name
  end

  def mk_light( target )
    return ''  unless target.respond_to? :is_published
    content_tag( :i, '', :class => 'icon-'+(target.is_published ? 'eye-open' : 'eye-close') ) + ' '
  end

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
    :pages     => 'book',
    :images    => 'picture',
    :assets    => 'file',
    :blocks    => 'list-alt',
    :folders   => 'folder-open',
    :news_articles => 'bookmark',
    :news_rubrics  => 'th-large',
    :fragments => 'th',
    :layouts   => 'cog',
  }

  def mk_icon( op )
    content_tag( :i, '', :class => 'icon-'+ICONS[op] ) + ' '  rescue throw op
  end

  def mk_multiple_op( op )
    link_to mk_icon(op) + pat(op), :method => op, :class => :multiple
  end

  def mk_single_op( op, link )
    link_to mk_icon(op) + pat(op), link, :class => :single
  end

  def mk_dialog_op( op, link, opts={} )
    link_to content_tag(:u, mk_icon(op) + pat(op)), link, opts.merge(:class => 'single dialog')
  end

  def mk_button_op( op, link )
    op = :delete  if op == :destroy
    link_to mk_icon(op) + pat(op), link, :method => op, :class => 'single button_to', 
  end

  def allow role
    yield  if current_account.allowed role
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

end
