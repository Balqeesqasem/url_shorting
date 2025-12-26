require 'rails_helper'

RSpec.describe "Urls API", type: :request do
  let(:valid_url) { "https://example.com" }
  let(:invalid_url) { "invalid_url" }

  describe "POST /urls/encode" do
    it "encodes a valid URL" do
      post "/urls/encode", params: { main_url: valid_url }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["short_url"]).not_to be_nil
    end

    it "returns error for invalid URL" do
      post "/urls/encode", params: { main_url: invalid_url }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Main url is not a valid URL")
    end
  end

  describe "POST /urls/decode" do
    it "decodes an existing short URL" do
      url = Url.create!(main_url: valid_url)
      post "/urls/decode", params: { short_code: url.short_code }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["original_url"]).to eq(valid_url)
    end

    it "returns error for non-existent short URL" do
      post "/urls/decode", params: { short_code: "nonexist" }
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Short URL not found")
    end
  end
end
