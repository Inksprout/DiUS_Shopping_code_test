require "json"
require_relative "inventory_item.rb"

class CartItem
  attr_reader :inventoryItem
  attr_accessor :isBundled

  def initialize(inventoryItem)
      @inventoryItem = inventoryItem
      @isBundled = false
  end
end