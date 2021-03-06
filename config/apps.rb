Padrino.configure_apps do
  set :session_secret, 'fd3a32d61be75844ffaf63deaeff410cd4d686f0de3154f4497a3cab0d493289'

  `which /usr/sbin/exim`
  if $?.success?
    set :delivery_method, :smtp
  else
    set :delivery_method, :sendmail
  end
end

Padrino.mount("Admin").to("/admin")
Padrino.mount("Swift::Application").to('/')
