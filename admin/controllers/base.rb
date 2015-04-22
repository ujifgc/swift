Admin.controllers :base do
  set_access :admin, :designer, :auditor, :editor, :user

  get :index, :map => "/" do
    render "base/index"
  end
end
