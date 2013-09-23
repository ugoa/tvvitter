require 'spec_helper'

describe Tvveet do
  let(:user) { FactoryGirl.create(:user) }
  before do
    @tvveet = user.tvveets.build(content: "Lorem ipsum")
  end
  subject { @tvveet }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should == user }

  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        Tvveet.new(user_id: user.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "when user_id is not present" do
    before { @tvveet.user_id = nil }

    it { should_not be_valid }
  end

  describe "with blank content" do
    before { @tvveet.content = " " }

    it { should_not be_valid }
  end

  describe "with content is too long" do
    before { @tvveet.content = 'a' * 141 }

    it { should_not be_valid }
  end
end