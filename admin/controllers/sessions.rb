Admin.controllers :sessions do

  get :new do
    render "/sessions/new", nil, :layout => false
  end

  post :create do
    if account = Account.authenticate(params[:email], params[:password])
      set_current_account(account)
      redirect_back_or_default url(:base, :index)
    elsif Padrino.env == :development && params[:bypass]
      account = Account.first :name => params[:bypass], :surname => 'group'
      set_current_account(account)
      redirect_back_or_default url(:base, :index)
    else
      params[:email], params[:password] = h(params[:email]), h(params[:password])
      flash[:warning] = "Login or password wrong."
      redirect url(:sessions, :new)
    end
  end

  delete :destroy do
    set_current_account(nil)
    redirect url(:sessions, :new)
  end

end
