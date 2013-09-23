require 'spec_helper'

describe "User Pages" do
  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1', :text => 'Sign up') }
    it { should have_selector('title', :text => full_title('Sign up')) }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:t1) { FactoryGirl.create(:tvveet, user: user, content: 'Foo') }
    let!(:t2) { FactoryGirl.create(:tvveet, user: user, content: 'Bar') }
    before do
      valid_sign_in user
      visit user_path(user)
    end

    it { should return_page_of(user.name) }

    describe "tvveets" do
      it { should have_content(t1.content) }
      it { should have_content(t2.content) }
      it { should have_content(user.tvveets.count) }
    end

    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end
        it "should increment the other user's followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_selector('input', value: 'Unfollow') }
        end
      end

      describe "unfollowing a user" do
        before {
          user.follow!(other_user)
          visit user_path(other_user)
        }

        it "should decrement the followed user count" do
          expect do
            click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end
        it "should decrement the other user's followers count" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end
        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_selector('input', value: 'Follow') }
        end
      end
    end
  end

  describe "#signup" do
    before { visit signup_path }
    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_selector('title', text: 'Sign up') }
        it { should have_error_message('error') }
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name", with: "Example user"
        fill_in "Email", with: "user@example.com"
        fill_in "Password", with: "111111"
        fill_in "Confirmation", with: "111111"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }
        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        it { should have_link('Sign out') }
      end
    end
  end

  describe "#edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      valid_sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_selector('h1', text: "Update your profile") }
      it { should have_selector('title', text: "Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_error_message('error') }
    end

    describe "with valid information" do
      let(:new_name) { "New name" }
      let(:new_email) { "new@example.com" }

      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirmation", with: user.password

        click_button "Save changes"
      end

      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

  describe "#index" do

    let(:user) { FactoryGirl.create(:user) }

    before(:all) { 30.times { FactoryGirl.create(:user) } }
    after(:all) { User.delete_all }

    before do
      valid_sign_in(user)
      visit users_path
    end

    it { should return_page_of('All users') }

    describe "pagination" do
      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1, per_page: 10).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end
  end

  describe "delete links" do
    it { should_not have_link('delete') }

    describe "as an admin user" do
      let(:admin) { FactoryGirl.create(:admin) }

      before do
        valid_sign_in admin
        visit users_path
      end

      it "should be able to delete another user" do
        expect { click_link('delete').to change(User.count).by(-1) }
      end

      it { should return_page_of('All users') }
      it { should_not have_link('delete', href: user_path(admin)) }

      describe "deleting himself...pfft.." do
        before { delete user_path(admin) }

        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as an non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { valid_sign_in non_admin }

      describe "submitting a DELETE request to the User#destroy action" do
        before { delete user_path(user) }

        specify { response.should redirect_to(root_path) }
      end
    end
  end

  describe "#sign_in" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      valid_sign_in(user)
    end

    describe "signed-in user visit signup page" do
      before { visit signup_path }

      it { should have_error_message("Invalid") }

      pending "sending post request to user_path " do
        let(:new_user) { FactoryGirl.build(:user) }

        before do
          post :create, user: @new_user
        end

        it { should have_error_message("Invalid") }
      end
    end
  end

  describe "following/followers" do
    let(:user) {FactoryGirl.create(:user)}
    let(:other_user) {FactoryGirl.create(:user)}
    before{ user.follow!(other_user) }

    describe "followed users" do
      before do
        valid_sign_in user
        visit following_user_path(user)
      end

      it { should return_page_of('Following') }
      it { should have_link(other_user.name, href: user_path(other_user))}
    end

    describe "followers" do
      before do
        valid_sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should return_page_of('Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end

end
