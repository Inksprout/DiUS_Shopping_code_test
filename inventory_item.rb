require 'json'

class InventoryItem
  attr_accessor :bundled
  attr_reader :name
  attr_reader :sku
  attr_accessor :price
  attr_reader :bulk_deal_amount
  attr_reader :bulk_deal_price
  attr_reader :bonus_item_sku
  attr_reader :three_for_two

  def initialize(item_data)
    @bundled = false
    # These variables should always be present in the pricing rules
    @sku = item_data["sku"]
    @price = item_data["price"]

    # These are optional pricing rules
    @name = item_data["name"]
    @bulk_deal_amount ||= item_data["bulkDealAmount"]
    @bulk_deal_price ||= item_data["bulkDealPrice"]
    @bonus_item_sku ||=  item_data["bonusItemSku"]
    @three_for_two ||=  item_data["threeForTwo"]
  end
end
