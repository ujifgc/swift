Swift.controllers :images do

  get :show, :map => '/images/cache/:id/:salt.:size.:format' do
    error 404  unless params[:salt].salt? "#{params[:id]}.#{params[:size]}.#{params[:format]}"
    error 404  unless img = Image.get(params[:id])
    error 501  unless $config[:formats].include? params[:size]

    filename = Padrino.public + image_url(img, {:size => params[:size]})
    FileUtils.makedirs filename.rpartition('/')[0]

    dimg = $dragonfly.fetch_file(Padrino.public + img.file).thumb(params[:size]).encode(params[:format])
    dimg.to_file filename
    dimg.to_response(env)
  end
  
end