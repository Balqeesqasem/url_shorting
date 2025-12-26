class UrlsController < ApplicationController
  # POST /urls/encode
def encode
  url = Url.find_by(main_url: params[:main_url])

  if url
    render json: { short_url: "#{url.short_code}" }, status: :ok
  else
    url = Url.new(main_url: params[:main_url])
    if url.save
      render json: { short_url: "#{url.short_code}" }, status: :created
    else
      render json: { errors: url.errors.full_messages }, status: :unprocessable_entity
    end
  end
end



  # POST /urls/decode
  def decode
    url = Url.find_by(short_code: params[:short_code])
    
    if url
      render json: { original_url: url.main_url }, status: :ok
    else
      render json: { error: 'Short URL not found' }, status: :not_found
    end
  end

  private

  def url_params
    params.require(:url).permit(:main_url)
  end
end
