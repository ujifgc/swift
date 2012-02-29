Admin.helpers do

  def mk_light( target )
    image_tag target.is_published ? '/images/icons/circle_green_12d.png' : '/images/icons/circle_red_12d.png'
  end

  ICONS = {
    :delete    => 'cross_48.png',
    :unpublish => 'circle_red.png',
    :publish   => 'circle_green.png',
    :list      => 'navigate_48.png',
    :new       => 'paper_48.png',
    :edit      => 'paper_content_pencil_48.png',
  }

  def mk_icon( op )
    file = '/images/icons/' + ICONS[op]
    image_tag file, :class => :op
  end

  def mk_multiple_op( op )
    link_to mk_icon(op) + pat(op), :method => op, :class => :multiple
  end

  def mk_single_op( op, link )
    link_to mk_icon(op) + pat(op), link, :class => :single
  end

  def mk_button_op( op, link )
    op = :delete  if op == :destroy
    link_to mk_icon(op) + pat(op), link, :method => op, :class => 'single button_to', 
  end

  def allow role
    yield  if current_account.allowed role
  end

end
