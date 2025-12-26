class UrlsController < ApplicationController
  # POST /urls/encode
  def encode
    url = Url.find_or_initialize_by(main_url: params[:main_url])

    if url.persisted? || url.save
      render json: { short_url: url.short_code }, status: :ok
    else
      render json: { errors: url.errors.full_messages }, status: :bad_request
    end
  end

  # POST /urls/decode
  def decode
    cache_key = decode_cache_key(params[:short_code])

    main_url = Rails.cache.fetch(cache_key, expires_in: 90.minutes) do
      url = Url.find_by(short_code: params[:short_code])
      return render json: { error: 'Short URL not found' }, status: :not_found unless url

      url.main_url
    end

    render json: { original_url: main_url }, status: :ok
  end

  private

  def decode_cache_key(short_code)
    "url:decode:#{short_code}"
  end
end
