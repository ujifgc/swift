Admin.controllers :dialogs do

  post :pages do
    render "dialogs/pages", :layout => :ajax
  end

  post :images do
    @objects = Image.all
    render "dialogs/images", :layout => :ajax
  end

  post :assets do
    render "dialogs/assets", :layout => :ajax
  end

end
