Admin.controllers :forms_stats do

  get :index do
    filter = {
      :kind => 'inquiry'
    }
    @objects = FormsCard.all filter
    render 'forms_stats/index'
  end

end
