Swift.controllers :core do

  get :index, :map => "/" do
    #go lurk the sitemap
    not_found

    #to add some special behavior put some rendering code here and comment `not found`
  end
  
end