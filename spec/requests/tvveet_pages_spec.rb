require 'spec_helper'

describe "Tvveet pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }

  before { valid_sign_in user }

  describe "tvveet creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.should_not change(Tvveet, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before { fill_in 'tvveet_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.should change(Tvveet, :count).by(1)
      end
    end
  end

  describe "tvveet destruction" do
    before { FactoryGirl.create(:tvveet, user: user) }

    describe "as correct user" do
      before { visit user_path(user) }

      it "should be able to delete a tvveet" do
        expect { click_link 'delete' }.should change(Tvveet, :count).by(-1)
      end
    end
  end

end