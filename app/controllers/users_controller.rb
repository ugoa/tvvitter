class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :administrator, only: :destroy
  before_filter :signedin_user_limit, only: [:new, :create]

  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end

  def show
    @user = User.find(params[:id])
    @tvveets = @user.tvveets.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Dream Land!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    # @user got set in the #correct_user(a before filter). Neat!
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @target_user.destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page], per_page: 10)
    render 'follows_list'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page], per_page: 10)
    render 'follows_list'
  end

  private

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def administrator
    @target_user = User.find(params[:id])
    unless current_user.admin? && @target_user && current_user != @target_user
      redirect_to(root_path)
    end
  end

  def signedin_user_limit
    if signed_in?
      flash[:error] = "Invalid operation: cannot create new role when signed in."
      redirect_to @current_user
    end
  end
end
