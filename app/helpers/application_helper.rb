# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

def gravatar_url(email,gravatar_options={})

  # Default highest rating.
  # Rating can be one of G, PG, R X.
  # If set to nil, the Gravatar default of X will be used.
  gravatar_options[:rating] ||= nil

  # Default size of the image.
  # If set to nil, the Gravatar default size of 80px will be used.
  gravatar_options[:size] ||= nil 

  # Default image url to be used when no gravatar is found
  # or when an image exceeds the rating parameter.
  gravatar_options[:default] = "http://localhost:3000/images/gravatar.jpg"

  # Build the Gravatar url.
  grav_url = 'http://www.gravatar.com/avatar.php?'
  grav_url << "gravatar_id=#{Digest::MD5.new.update(email)}" 
  grav_url << "&rating=#{gravatar_options[:rating]}" if gravatar_options[:rating]
  grav_url << "&size=#{gravatar_options[:size]}" if gravatar_options[:size]
  grav_url << "&default=#{gravatar_options[:default]}" if gravatar_options[:default]
  return grav_url
end

# Returns a Gravatar image tag associated with the email parameter.
def gravatar(email,gravatar_options={})

  # Set the img alt text.
  alt_text = 'Gravatar'

  # Sets the image sixe based on the gravatar_options.
  img_size = gravatar_options.include?(:size) ? gravatar_options[:size] : '80'

  "<img src=\"#{gravatar_url(email, gravatar_options)}\" alt=\"#{alt_text}\" height=\"#{img_size}\" width=\"#{img_size}\" />" 

end

end
