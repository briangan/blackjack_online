require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "User creation" do
    # Uniqueness
    user1 = User.create!(name: 'Owen')
    assert (user1.balance > 0)

    user2 = User.new(name: 'Owen')
    assert !user2.valid?
    assert !user2.errors.messages[:name].nil?
  end
end
