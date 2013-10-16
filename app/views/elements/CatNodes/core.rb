unless @nodes
  @nodes = CatNode.all :cat_card_id => @card_ids
  @group ||= @root_group
  @nodes = @nodes.filter_by(@group)  if @group
end
