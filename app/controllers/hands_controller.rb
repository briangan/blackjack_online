class HandsController < ::InheritedResources::Base
  
  def hit
    @hand ||= resource
    @next_play_card = @hand.hit!
    check_all_ended_or_else do
      respond_to do|format|
        format.html { redirect_to game_path(id: @hand.game_id, t: Time.now.to_i) }
        format.turbo_stream
      end
    end
  end

  def stand
    @hand ||= resource
    @next_play_card = @hand.stand!
    check_all_ended_or_else do
      respond_to do|format|
        format.html { redirect_to game_path(id: @hand.game_id, t: Time.now.to_i) }
        format.turbo_stream
      end
    end
  end

  def double
    @hand ||= resource
    @next_play_card = @hand.double!
    check_all_ended_or_else do
      respond_to do|format|
        format.html { redirect_to game_path(id: @hand.game_id, t: Time.now.to_i) }
        format.turbo_stream
      end
    end
  end

  def split
    @hand ||= resource
    @next_hand = @hand.split!
    respond_to do|format|
      format.html { redirect_to game_path(id: @hand.game_id, t: Time.now.to_i) }
      format.turbo_stream { render :update_all_hands }
    end
  end

  private

  # If all hand turns ended, would analyze the hands and redirect page.  Else, would yield to block
  def check_all_ended_or_else(&block)
    if resource.game.hands.all?(&:is_turn_ended?)
      resource.game.analyze_hands!
      logger.debug "------------- after analyze_hands"

      respond_to do|format|
        format.html { redirect_to game_path(id: @hand.game_id, t: Time.now.to_i) }
        format.turbo_stream { render :update_all_hands }
      end
      
    else
      logger.debug "------------ not all turns ended"
      yield if block_given?
    end
  end
end