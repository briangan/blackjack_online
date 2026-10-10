class GamesController < ::InheritedResources::Base

  def new_hand
    respond_to do|format|
      format.js
    end
  end

  def create_hand
    params = params.permit(:name)
    @hand = 
    respond_to do|format|
      format.js
    end
  end
end