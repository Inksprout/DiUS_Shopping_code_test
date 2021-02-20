require 'json'

class InventoryItem
  attr_accessor :bundled
  attr_reader :name
  attr_reader :SKU
  attr_accessor :price
  attr_reader :bulk_deal_amount
  attr_reader :bulk_deal_price
  attr_reader :bonus_item_SKU
  attr_reader :three_for_two

  def initialize(item_data)
    @bundled = false
    # These variables should always be present in the pricing rules
    @SKU = item_data["SKU"]
    @price = item_data["price"]

    # These are optional pricing rules
    @name = item_data["name"]
    @bulk_deal_amount ||= item_data["bulkDealAmount"]
    @bulk_deal_price ||= item_data["bulkDealPrice"]
    @bonus_item_SKU ||=  item_data["bonusItemSKU"]
    @three_for_two ||=  item_data["threeForTwo"]
  end
end
