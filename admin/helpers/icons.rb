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
    :news_events   => 'flag',

    :forms_cards   => 'inbox',
    :forms_results => 'folder-close',
    :forms_stats   => 'check',

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

  def mk_icon( op, white = nil )
    content_tag( :i, '', :class => 'icon-'+(ICONS[op]||'warning-sign')+(white ? ' icon-white' : '') ) + ' '
  end
