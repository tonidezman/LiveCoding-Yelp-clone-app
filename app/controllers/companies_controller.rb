class CompaniesController < ApplicationController
  before_action :require_owner_or_admin?, except: [:show, :search]
  before_action :require_same_user,       except: [:show, :search]
  before_action :require_user,            only:   [:show]

  def index
    @user      = User.find(current_user.id)
    @companies = @user.companies.order(name: :asc)
  end

  def show
    @company      = Company.find(params[:id])
    @reviews      = @company.reviews
    @current_city = @company.city

    @hash = Gmaps4rails.build_markers(@current_city) do |city, marker|
      marker.lat city.latitude
      marker.lng city.longitude
      marker.infowindow "#{@company.name}, City: #{@current_city.name}, Country: #{@current_city.country}"
      marker.title @current_city.name
    end
  end

  def new
    @user    = User.find(current_user.id)
    @company = Company.new
  end

  def create
    @user    = User.find(current_user.id)
    @company = @user.companies.build(company_params)
    if @company.save
      flash[:success] = "You've just created new company!"
      redirect_to user_companies_path(@user)
    else
      render :new
    end
  end

  def edit
    @user    = User.find(params[:user_id])
    @company = Company.find(params[:id])
  end

  def update
    @user    = User.find(params[:user_id])
    @company = Company.find(params[:id])

    if @company.update(company_params)
      flash[:success] = 'The Company was successfully updated!'
      redirect_to user_companies_path(@user)
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    Company.find(params[:id]).destroy
    redirect_to user_companies_path(@user)
  end

  def search
    @companies = Company.search(params[:name], params[:city][:city_id], params[:category][:category_ids])
  end

  private

  def company_params
    params.require(:company).permit(:name, :city_id, :price_range, category_ids: [])
  end

end
