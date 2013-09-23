require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should return_page_of('Sign in') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before do
        visit signin_path
        click_button "Sign in"
      end

      it { should return_page_of('Sign in') }
      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }

        it { should_not have_error_message('Invalid') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }

      before { valid_sign_in user }

      it { should have_selector('title', text: user.name) }
      it { should have_link('Users', href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not return_page_of('Sign in') }

      describe "try to sign in again" do
        before { visit signin_path }

        it { should have_error_message("You already signed in") }
      end

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign up now') }
      end
    end
  end

  describe "authorization" do
    describe "for non-signed-in user" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the editing page" do
          before { visit edit_user_path(user) }
          it { should return_page_of('Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) } # #put is not a Capybara but a Rspec feature.
          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should return_page_of('Sign in') }
        end

        describe "visiting the following page" do
          before { visit followers_user_path(user) }
          it { should return_page_of('Sign in') }
        end
      end

      describe "in the Tvveets controller" do
        describe "submitting to the create action" do
          before { post tvveets_path }

          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before do
            tvveet = FactoryGirl.create(:tvveet)
            delete tvveet_path(tvveet)
          end

          specify { response.should redirect_to(signin_path) }
        end
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@gmail.com") }

      before { valid_sign_in user }

      describe "visiting User#edit page" do
        before { visit edit_user_path(wrong_user) }

        it { should have_no_selector('title', text: full_title('Edit user')) }
      end

      describe "submitting a PUT request to User#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    # Friendly forwarding section 9.2.3
    describe "for not-signed-in user" do
      let(:user) { FactoryGirl.create(:user) }

      describe "while attemping visiting a protected page" do
        before do
          visit edit_user_path(user)
          valid_sign_in user
        end

        describe do
          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Edit user')
          end
        end
      end

      describe "in the Users controller" do
        describe "visiting the user index" do
          before { visit users_path }
          it { should return_page_of('Sign in') }
        end
      end

      describe "in the RelationShips controller" do
        describe "summit to the #create action" do
          before { post relationships_path }
          specify {response.should redirect_to(signin_path)}
        end

        describe "summit to the #destroy action" do
          before { delete relationship_path(1) }
          specify {response.should redirect_to(signin_path)}
        end
      end
    end
  end
end