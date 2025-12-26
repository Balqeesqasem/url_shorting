require 'rails_helper'

RSpec.describe Url, type: :model do
  subject { described_class.new(main_url: "https://example.com") }

  describe "Validations" do
    it "is valid with a proper URL" do
      expect(subject).to be_valid
    end

    it "is invalid without a main_url" do
      subject.main_url = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:main_url]).to include("can't be blank")
    end

    it "is invalid with an incorrect URL format" do
      subject.main_url = "invalid_url"
      expect(subject).not_to be_valid
      expect(subject.errors[:main_url]).to include("is not a valid URL")
    end
  end

  describe "Callbacks" do
    it "generates a short_code before creation" do
      subject.save
      expect(subject.short_code).not_to be_nil
    end
  end
end
