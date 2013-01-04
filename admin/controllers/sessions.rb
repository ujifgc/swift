Admin.controllers :sessions do
  layout 'login'

  get :new do
    render "/sessions/new", nil
  end

  get :create do
    redirect url(:sessions, :new)
  end

  post :create do
    account = Account.authenticate(params[:email], params[:password])
    if Padrino.env == :development && params[:bypass]
      account ||= Account.first :name => params[:bypass], :surname => 'group'
    end
    if account
      set_current_account(account)
      redirect_back_or_default url(:base, :index)
    else
      params.delete 'password'
      flash.now[:error] = pat('login.wrong_password')
      render 'sessions/new'
    end
  end

  delete :destroy do
    set_current_account(nil)
    redirect url(:sessions, :new)
  end

end
