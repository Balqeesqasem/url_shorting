
require "shorturl"
require 'uri'

class Url < ApplicationRecord
  
  #Validations 
  validates :main_url, presence: true, format: { with: URI::regexp, message: "is not a valid URL" }
  validates :short_code, uniqueness: true
  
  #Callbacks
  before_create :generate_short_code

  private

def generate_short_code
  self.short_code = ShortURL.shorten(main_url)
end

end
