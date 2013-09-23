require 'spec_helper'

describe Relationship do

  let(:follower) { FactoryGirl.create(:user)}
  let(:followed) { FactoryGirl.create(:user)}
  let(:relationship) { follower.relationships.build(followed_id: followed.id) }

  subject { relationship }

  it { should be_valid }

  describe "follower methods" do
    it { should respond_to(:follower) }
    it { should respond_to(:followed) }
    its(:follower) { should == follower }
    its(:followed) { should == followed }
  end

  describe "accessible attributes" do
    it "should not allow access to follower's id" do
      expect do
        Relationship.new(follower_id: follower.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "destroy dependency" do

    # the next twe examples use different ideas.
    describe "destroy follower" do
      it "should be destroyed when follower was being deleted" do
        connections = follower.relationships
        follower.destroy
        connections.each do |relationship|
          Relationship.find_by_follower_id(relationship.follower_id).should be_nil
        end
      end
    end

    describe "destroy followed user" do
      before { followed.destroy }
      it "should be destroyed when followed user was being deleted" do
        Relationship.find_by_followed_id(relationship.followed_id).should be_nil
      end
    end

  end

  describe "when followed id is not present" do
    before { relationship.followed_id = nil }
    it { should_not be_valid}
  end

  describe "when followe id is not present" do
    before { relationship.follower_id = nil }
    it { should_not be_valid}
  end
end
