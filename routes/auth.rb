# frozen_string_literal: true

get '/auth/login' do
  slim view_name('login'), layout: view_name('layout')
end

post '/auth/login' do
  admin_pass = setting('ADMIN_PASSWORD')
  if params['email'] == setting('ADMIN_EMAIL') &&
     params['password'].crypt(admin_pass) == admin_pass
    session[:login] = true
    redirect '/admin/'
  else
    session.delete(:login)
    redirect '/auth/login'
  end
end

get '/auth/logout' do
  session.delete(:login)
  redirect '/'
end
