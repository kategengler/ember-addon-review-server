class PackagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    @packages = Package.all
    render json: @packages
  end

  def show
    @package = Package.find(params[:id])
    render json: @package
  end

  #TODO: Secure this for admin only
  def update
    package = Package.find(params[:id])
    package.update({category_ids: params[:package][:categories]})
    render json: package
  end

  private

  def package_params
    params.require(:package).permit(:categories)
  end
end
