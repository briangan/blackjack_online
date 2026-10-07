module PlayAction
  class PlayAction < ApplicationRecord
    self.table_name = 'play_actions'

    belongs_to :hand, dependent: :destroy

    validates_presence_of :hand_id
  end
end