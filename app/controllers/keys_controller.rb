class KeysController < ApplicationController
  before_action :find_key, except: [:index, :new, :create]

  respond_to :html, :json

  def index
    @keys = Key.all
    respond_with @keys
  end

  def show
    respond_with @key
  end


  protected

  def find_key
    @key = Key[params[:id]]
  end
end
