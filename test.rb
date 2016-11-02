require 'bundler'
Bundler.require

NoBrainer.configure do |c|
  c.app_name = "nobrainer_carrierwave_issue"
  c.environment = "test"
  c.logger = Logger.new(STDERR).tap { |l| l.level = Logger::DEBUG }
end

I18n.load_path = ['en.yml']

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :file
  def filename
    if original_filename 
      @name ||= "image.jpg"
    end
  end

  def store_dir
    "uploads/"
  end

  def default_url
    ""
  end

  def extension_whitelist
    %w(jpg jpeg png)
  end
end

class User
  include NoBrainer::Document
  extend CarrierWave::Mount
  mount_uploader :avatar, AvatarUploader

  field :avatar, type: String
end

# Error shows
user = User.create(avatar: File.open("test.txt"))
puts "\n\n\nError messages on save"
puts user.errors.full_messages
puts "\n\n\n"

user = User.create(avatar: File.open("image.jpg"))
# no errors here
# can't call url here some weird carrierwave stuff without rails
puts "\n\n\nAny errors?"
puts user.errors.any?

saved = user.update(avatar: File.open("test.txt"))
# Continues saving
puts "\n\n\nsaved == #{saved}"
puts "Error Messages: #{ user.errors.full_messages || nil }"
