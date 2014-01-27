Admin.helpers do
  def do_auth(request)
    account = Account.create_with_omniauth(request.env["omniauth.auth"])
    save_credentials(account)
    if account.saved?
      restore_location
    else
      error = ''.html_safe
      error << content_tag(:code, "#{account.email}") << ': ' \
            << account.errors.to_a.flatten.join(', ') << ': ' << tag(:br) \
            << content_tag(:code, "#{account.provider}: #{account.uid}")
      flash[:error] = error
      redirect url(:login, :new)
    end
  end
end

Admin.controllers :login do
  layout 'login'

  get :new, :map => '/login' do
    render 'new'
  end

  post :create, :map => '/login' do
    if authenticate
      restore_location
    else
      params.delete 'password'
      flash.now[:error] = pat('login.wrong_password')
      render 'new'
    end
  end

  route_verbs [:get, :delete], :destroy do
    save_credentials(nil)
    redirect url(:login, :new)
  end

  route_verbs [:get, :post], :reset do
    account = Account.first :email => params[:email]
    if account
      code = Digest::SHA2.hexdigest(Digest::SHA1.hexdigest(account.inspect) + 'herjovFas8' + Date.today.to_s)[6..11]
      host = env['SERVER_NAME']
      if params[:reset]
        if code == params[:reset]
          pwd = `apg -qd -c#{rand(0..9)} -m8 -x8 -n1`  rescue Digest::SHA2.hexdigest(DateTime.now.to_s+rand(0..9).to_s).gsub(/[^\d]/,'')[0..5]
          account.password = account.password_confirmation = pwd
          account.crypted_password = Digest::SHA2.hexdigest(pwd)[0..5]  # dummy action to make account dirty
          if account.save
            mail_subject = I18n.t('padrino.admin.account.mail.reset_account_title', :host => host)
            email do
              @host = host
              @pwd = pwd
              @login = account.email
              @address = absolute_url('')

              content_type 'text/html; charset=UTF-8'
              from     "noreply@#{@host}"
              to        account.email
              subject  mail_subject
              body render 'reset_account_done'
            end
            set_current_account account
            flash[:notice] = pat('account.reset_account_done')
            redirect url(:base, :index)
          else
            flash.now[:error] = pat('account.save_failed')
            render 'reset', :layout => 'login'
          end
        else
          flash.now[:error] = pat('account.code_wrong')
          render 'reset', :layout => 'login'
        end              
      else
        mail_subject = I18n.t('padrino.admin.account.mail.reset_account_title', :host => host)
        email do
          @code = code
          @host = host
          @login = account.email

          content_type 'text/html; charset=UTF-8'
          from    "noreply@#{@host}"
          to       account.email
          subject mail_subject
          body render 'reset_account'
        end
        flash.now[:notice] = pat('account.reset_initiated').html_safe
        render 'reset', :layout => 'login'
      end
    else
      flash.now[:notice] = pat('account.doesnt_exist')  if @email = params.delete('email')
      render 'reset', :layout => 'login'
    end
  end

  route_verbs [:get, :post], :auth, :with => [:provider, :callback] do
    do_auth request
  end

  get :auth, :with => :provider do; end

  get :failure do
    flash[:error] = I18n.t('login.error.' + params[:message].html_safe)
    redirect url(:login, :new)
  end
end
