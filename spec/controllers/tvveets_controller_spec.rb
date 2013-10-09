require 'spec_helper'

describe TvveetsController do

  describe "POST #create" do
    let(:user) { FactoryGirl.create(:user) }
    before { valid_sign_in user }

    context "with valid content" do
      let(:valid_tvveet) { FactoryGirl.build(:tvveet, user: user) }

      it "saves the new tvveet" do
        expect {
          post :create, tvveet: valid_tvveet.attributes
        }.to change(Tvveet, :count).by(1)
      end
    end

    context "with empty content" do
      let(:empty_tvveet) { FactoryGirl.build(:empty_content, user: user) }

      it "should not save the tvveet" do
        expect {
          post :create, tvveet: empty_tvveet.attributes
        }.not_to change(Tvveet, :count)
      end
    end
  end

end