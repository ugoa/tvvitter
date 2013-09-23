RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :return_page_of do |topic|
  match do |page|
    page.should have_selector('title', text: topic)
  end
end

def full_title(page_title)
  base_title = "Tvvitter, a mock Twitter but better"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

def valid_sign_in(user)
  visit signin_path

  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"

  cookies[:remember_token] = user.remember_token
end
