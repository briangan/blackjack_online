class User < ApplicationRecord

  DEFAULT_BALANCE = 300.0

  before_save :set_defaults

  validates_presence_of :name
  validates_uniqueness_of :name, case_senstive: false


  private

  def set_defaults
    self.balance ||= DEFAULT_BALANCE
    self.type ||= 'Player'
  end
end
