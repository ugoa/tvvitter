require 'spec_helper'

describe "StaticPages" do

  #describe "GET /static_pages" do
  #  it "works! (now write some real specs)" do
  #    # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
  #    get static_pages_index_path
  #    response.status.should be(200)
  #  end
  #end

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end

  describe "Home page" do
    before(:each) { visit root_path }

    let(:heading) { 'Tvvitter' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:tvveet, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:tvveet, user: user, content: "Dolor sit amet")
        valid_sign_in user
        visit root_path
      end

      it "should render user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          user.follow!(other_user)
          visit root_path
        end

        it { should have_link("1 following", href: following_user_path(user)) }
        it { should have_link("1 follower", href: followers_user_path(user)) }
      end
    end
  end

  describe "Help page" do
    before(:each) { visit help_path }

    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before(:each) { visit about_path }

    let(:heading) { 'About' }
    let(:page_title) { 'About' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    it "should have a Contact page" do
      get contact_path
      response.status.should be(200)
    end

    it "should have the title 'Contact'" do
      visit contact_path
      page.should have_selector('title',
                                :text => full_title('Contact'))
    end
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    page.should have_selector 'title', text: full_title('')
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "tvvitter"
    page.should have_selector 'title', text: full_title('')
  end

end