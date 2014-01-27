Admin.controllers :forms_stats do
  set_access :admin, :designer, :auditor

  get :index do
    filter = {
      :kind => 'inquiry'
    }
    @objects = FormsCard.all filter
    render 'forms_stats/index'
  end
end
