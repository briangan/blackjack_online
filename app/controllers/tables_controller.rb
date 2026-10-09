class TablesController < ::InheritedResources::Base
  def create
    super do|format|
      format.html { redirect_to @table.valid? ? table_path(@table) : tables_path(i: Time.now.to_i) }
    end
  end

  def add_user
    params.permit(:name)
    @user = resource.add_user!(params[:name])
  end

  # /tables/:id/delete_user/:table_user_id
  def delete_user
    params.permit(:table_user_id)
    resource.table_users.where(id: params[:table_user_id]).delete_all
    respond_to do|format|
      format.html { redirect_to table_path(resource) }
      format.turbo_stream { render :add_user } # same reload of players
    end
  end

  def create_game
    params.permit! # simplify multiple params
    bet_amounts_h = {} # user_id => amount
    params.each_pair do|k,v|
      if k.to_s =~ /^bet_amount_of_user_(\d+)/
        bet_amounts_h[$1.to_i] = v&.to_f
      end
    end
    @game = resource.create_game!(bet_amounts_h)

    respond_to do|format|
      format.html { redirect_to game_path(@game) }
    end
  end
end