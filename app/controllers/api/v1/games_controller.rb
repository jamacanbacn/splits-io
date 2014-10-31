class Api::V1::GamesController < ApiController
  before_action :set_game, only: [:show]

  SAFE_PARAMS = [:name, :shortname]

  def index
    if search_params.empty?
      render status: 400, json: {
        status: 400,
        error: "You must supply one of the following parameters: #{SAFE_PARAMS.join(", ")}"
      }
      return
    end
    @games = Game.where search_params
    render json: @games
  end

  def show
    render json: @game
  end

  private

  def set_game
    @game = Game.find params[:id]
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: {
      status: 404,
      error: "Game with id '#{params[:id]}' not found. If '#{params[:id]}' isn't a numeric id, first use GET #{api_v1_games_url}"
    }
  end

  def search_params
    params.permit SAFE_PARAMS
  end
end
