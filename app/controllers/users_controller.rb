class UsersController < ApplicationController
	before_action :logged_in_user, only: [:edit, :update, :destroy]
	before_action :correct_user, only: [:edit, :update]
	before_action :admin_user, only: [:destroy]

  def following
  	@title = "Following"
  	@user = User.find(params[:id])
  	@users = @user.following.paginate(page: params[:page])
  	render 'show_follow'
  end

  def followers
  	@title = "Followers"
  	@user = User.find(params[:id])
  	@users = @user.followers.paginate(page: params[:page])
  	render 'show_follow'
  end

  def new
  	@user = User.new
  end

  def destroy
  	User.find(params[:id]).destroy
  	flash[:success] = "User deleted"
  	redirect_to users_path
  end

  def show 
  	@user = User.find(params[:id])
  	@microposts = @user.micropost.paginate(page: params[:page])
    @user_detail = @user.user_detail
    if !@user_detail.country.blank?
      @user_detail.country = ISO3166::Country.find_country_by_alpha2(@user_detail.country).name
    end
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
  		UserMailer.account_activation(@user).deliver_now
  		flash[:info] = "Please check your email to activate the account"
      @user.create_user_detail
  		redirect_to root_url
  	else
  		render 'new'
  	end
  end

  def edit
  	@user = User.find(params[:id])
  end

  def update
  	@user = User.find(params[:id])
  	if @user.update_attributes(user_params)
  		flash[:success] = "Profile updated"
  		redirect_to @user
  	else
  		render 'edit'
  	end
  end

  def index
    if params[:search]
      @users = User.has_name(params[:search]).paginate(page: params[:page])
    else
      @users = User.paginate(page: params[:page])
    end
  @users = @users.has_country(params[:country]) if params[:country].present?
  @users = @users.has_medium(params[:medium]) if params[:medium].present?
  end

  private

  	def user_params
  		params.require(:user).permit(:name, :email, :password,
  									 :password_confirmation)
  	end

  	def correct_user
  		@user = User.find(params[:id])
  		redirect_to(root_path) unless current_user?(@user)
  	end

  	def admin_user
  		redirect_to(root_path) unless current_user.admin?
  	end
end
