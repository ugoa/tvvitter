# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe User do
  before do
    @user = User.new(name: 'david',
                     email: "david@example.com",
                     password: "foobar",
                     password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:tvveets) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:follow!) }
  it { should respond_to(:following?) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attibute set to 'true'" do
    before do
      @user.save
      @user.toggle!(:admin)
    end
    it { should be_admin }
  end

  describe "unaccessible attributes" do
    it 'should not allow access to :admin' do
      expect do
        User.new(amdin: true)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "tvveets associations" do
    before { @user.save }

    # #let only spring into existence when referenced, so we use #let! to
    # make the tvveet exist immediately.
    let!(:older_tvveet) do
      Factory.create(:tvveet, user: @user, created_at: 1.day.ago)
    end

    let!(:newer_tvveet) do
      Factory.create(:tvveet, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right tvveets in right order" do
      @user.tvveets.should == [newer_tvveet, older_tvveet]
    end

    it "should delete associated tvveets" do
      tvveets = @user.tvveets
      @user.destroy
      tvveets.each do |tvveet|
        Tvveet.find_by_id(tvveet.id).should be_nil
      end
    end

    describe "status" do
      let(:unfollowed_tvveet) do
        FactoryGirl.create(:tvveet, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.tvveets.create!(content: "Hello world") }
      end

      its(:feed) {should include(newer_tvveet) }
      its(:feed) {should include(older_tvveet) }
      its(:feed) {should_not include(unfollowed_tvveet) }
      its(:feed) do
        followed_user.tvveets.each do |tvveet|
          should include(tvveet)
        end
      end
    end


  end

  describe "when name is not present" do
    before { @user.name = "  " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = "  " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = 'a' * 51 }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.foo@bar baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end

  describe "when email address already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should be_valid }

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }

    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }

    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }

    it { should_not be_valid }
  end

  it { should respond_to(:authenticate) }

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end

    describe "with a password that's too short" do
      before { @user.password = @user.password_confirmation = "a" * 5 }

      it { should_not be_valid }
    end
  end

  describe "remember token" do
    before { @user.save }

    its(:remember_token) { should_not be_blank }
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }

      describe "unfollowed user" do
        subject { other_user }
        its(:followers) { should_not include(@user) }
      end
    end
  end
end
