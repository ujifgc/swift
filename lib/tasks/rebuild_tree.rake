#coding:utf-8
namespace :se do
  def rebuild_tree(root)
    root.path = nil
    root.save
    root.children.each{ |c| rebuild_tree(c) }
  end
  
  desc "rebuild page tree"
  task :retree => :environment do
    rebuild_tree Page.first( :parent => nil )
  end
end
