class Dealer < User

  # Maybe the future there will be different dealers
  def self.default_dealer
    Dealer.find_or_create_by(name:'Default Dealer')
  end
end