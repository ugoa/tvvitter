# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Tvvitter::Application.initialize!

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tvveet', 'tvveets'
end
