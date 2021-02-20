require "json"
require_relative "inventory_item.rb"

class Checkout
  attr_reader :pricing_rules
  attr_reader :cart

  def initialize(pricing_rules)
    @cart = []
    begin

      file = File.open pricing_rules
      @pricing_rules = JSON.load file
      validate_pricing_rules(@pricing_rules)
      rescue StandardError => e
        $stderr.print "something went wrong with loading pricing rules. #{e}"
    end

  end
  
  def scan(item_SKU)
    item_data = pricing_rules.find { |item| item["SKU"] == item_SKU}
    scanned_item = InventoryItem.new(item_data)
    @cart.push(scanned_item)
  end

  def total
    total = 0
    discounted_items = []
    @cart.each { |item|
      unless discounted_items.include?(item.SKU)
        if item.three_for_two
          total += calculate_three_for_two(@cart.select {|matchingItem| matchingItem.SKU == item.SKU})
          discounted_items.push(item.SKU)
        elsif item.bulk_deal_amount && item.bulk_deal_price
          total += calculate_bulk_buy(@cart.select {|matchingItem| matchingItem.SKU == item.SKU})
          discounted_items.push(item.SKU)
        elsif item.bonus_item_SKU
          total += apply_bundling(item)
        else
          total += item.price
        end
      end
    }
    return total
  end

  def calculate_three_for_two(items)
    total_price = items[0].price * items.length
    discount = (items.length / 3) * items[0].price
    new_total = total_price - discount
    return new_total
  end

  def calculate_bulk_buy(items)
    discount_price = items[0].bulk_deal_price
    min_quantity = items[0].bulk_deal_amount
    if items.length > min_quantity
      return items.length * discount_price
    else
      return items.length * items[0].price
    end
  end

  def apply_bundling(item)
    total = item.price
    bundled_item = @cart.detect{|matchingItem| matchingItem.SKU == item.bonus_item_SKU && matchingItem.bundled == false}
    if bundled_item
      total -= bundled_item.price
      bundled_item.bundled = true
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
      raise "item with SKU #{item["SKU"]} has multiple discounts applied, this is not supported"
    end
  }
  return true
end