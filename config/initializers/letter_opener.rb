# Configure Letter Opener for WSL environment
if Rails.env.development?
  LetterOpener.configure do |config|
    # Save emails to files in this location
    config.location = Rails.root.join('tmp', 'letter_opener')
    
    # Use light template for email rendering
    config.message_template = :light
    
    # Set the WSL-specific file URI scheme so emails can be opened in Windows browser
    # This assumes Debian WSL - modify path as needed for your specific WSL distribution
    config.file_uri_scheme = 'file://///wsl$/debian'
  end
end 