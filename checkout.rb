require "json"
require_relative "inventory_item.rb"
require_relative "cartItem.rb"

class Checkout
  attr_reader :pricing_rules
  attr_reader :cart

  protected :cart

  def initialize(pricing_rules)
    # list of cartItem
      @cart = []
      file = File.open pricing_rules
      @pricing_rules = JSON.load file
      validate_pricing_rules(@pricing_rules)
  end

  def get_cart
    cart.map { |item| item.inventoryItem }
  end
  
  def scan(item_sku)
    item_data = pricing_rules.find { |item| item["sku"] == item_sku}
    if item_data.nil?
      raise "error: no item with the SKU #{item_sku}"
    end
    scanned_item = InventoryItem.new(item_data)
    scanned_item.freeze
    @cart.push( CartItem.new(scanned_item))
  end

  def total
    total = 0
    discounted_items = []
    @cart.each { |item|
      inventoryItem = item.inventoryItem
      unless discounted_items.include?(inventoryItem.sku)
        if inventoryItem.three_for_two
          total += calculate_three_for_two(@cart.select {|matchingItem| matchingItem.inventoryItem.sku == inventoryItem.sku})
          discounted_items.push(inventoryItem.sku)
        elsif inventoryItem.bulk_deal_amount && inventoryItem.bulk_deal_price
          total += calculate_bulk_buy(@cart.select {|matchingItem| matchingItem.inventoryItem.sku == inventoryItem.sku})
          discounted_items.push(inventoryItem.sku)
        elsif inventoryItem.bonus_item_sku
          total += apply_bundling(item)
        else
          total += inventoryItem.price
        end
      end
    }
    return total
  end

  def calculate_three_for_two(items)
    total_price = items[0].inventoryItem.price * items.length
    discount = (items.length / 3) * items[0].inventoryItem.price
    new_total = total_price - discount
    return new_total
  end

  def calculate_bulk_buy(items)
    discount_price = items[0].inventoryItem.bulk_deal_price
    min_quantity = items[0].inventoryItem.bulk_deal_amount
    if items.length > min_quantity
      return items.length * discount_price
    else
      return items.length * items[0].inventoryItem.price
    end
  end

  def apply_bundling(item)
    total = item.inventoryItem.price
    bundled_item = @cart.detect{|matchingItem| matchingItem.inventoryItem.sku == item.inventoryItem.bonus_item_sku && matchingItem.isBundled == false}
    if bundled_item
      total -= bundled_item.inventoryItem.price      
      bundled_item.isBundled = true
    end
    return total
  end
end

def validate_pricing_rules(pricing_rules)
  pricing_rules.select {|item|
    rule_count = 0
    if item["bulkDealAmount"]
      rule_count +=1
    end
    if item["bonusItemSku"]
      rule_count +=1
    end
    if item["threeForTwo"]
      rule_count +=1
    end
    if rule_count > 1
      raise "item with SKU #{item["sku"]} has multiple discounts applied, this is not supported"
    end
  }
  return true
end