require_relative '../checkout'

describe Checkout do
  describe "#initialize" do
    context "when the pricing rules json is valid" do
      it "loads the pricing rules" do
        checkout = Checkout.new("spec/pricingRules.json")
        expect(checkout.pricing_rules.length).to eq(4)
      end
    end
    context "when the pricing rules json is invalid" do
      it "raises an error when the pricing rules file can't be loaded" do
        expect{checkout = Checkout.new("spec/nofile.json")}.to raise_error("No such file or directory @ rb_sysopen - spec/nofile.json")
      end
      it "raises an error when more than one type of discount is applied to an item" do
        expect{checkout = Checkout.new("spec/invalidPricing.json")}.to raise_error("item with SKU tsi has multiple discounts applied, this is not supported")
      end
    end
  end

  describe "#scan" do
    checkout = Checkout.new("spec/pricingRules.json")
    it "adds a new item to the cart based on the item SKU" do
      checkout.scan("atv")
      expect(checkout.get_cart.length).to eq(1)
      added_item = checkout.get_cart[0]
      expect(added_item.sku).to eq("atv")
      expect(added_item.name).to eq("Apple TV")
      expect(added_item.price).to eq(109.50)
      expect(added_item.three_for_two).to eq(true)
    end
    it "outputs an error when invalid SKU is scanned" do
      expect{checkout.scan("pop")}.to raise_error("error: no item with the SKU pop")
    end
  end

  describe "#total" do
    it "correctly totals SKUs Scanned: mbp, vga, ipd" do
      checkout = Checkout.new("spec/pricingRules.json")
      checkout.scan("mbp")
      checkout.scan("vga")
      checkout.scan("ipd")
      expect(checkout.get_cart.length).to eq(3)
      expect(checkout.total).to eq(1949.98)
    end
    context "when there is a 2 for the price of 3 discount" do
      it "applies the 2 for 3 discount to the applicable items, plus other items" do
        checkout = Checkout.new("spec/pricingRules.json")
        checkout.scan("atv")
        checkout.scan("atv")
        checkout.scan("atv")
        checkout.scan("vga")
        expect(checkout.get_cart.length).to eq(4)
        expect(checkout.total).to eq(249)
      end
      it "applies the discount for multiple sets of 3" do
        checkout = Checkout.new("spec/pricingRules.json")
        checkout.scan("atv")
        checkout.scan("atv")
        checkout.scan("atv")
        checkout.scan("atv")
        checkout.scan("atv")
        checkout.scan("atv")
        checkout.scan("vga")
        expect(checkout.get_cart.length).to eq(7)
        expect(checkout.total).to eq(468)
      end
      it "applies the discount correctly when the number of items is not a multiple of 3" do
        checkout = Checkout.new("spec/pricingRules.json")
        checkout.scan("atv")
        checkout.scan("atv")
        checkout.scan("atv")
        checkout.scan("atv")
        checkout.scan("vga")
        expect(checkout.get_cart.length).to eq(5)
        expect(checkout.total).to eq(358.5)
      end
      it "does not apply the discount if there are fewer than 3 od the discount items" do
        checkout = Checkout.new("spec/pricingRules.json")
        checkout.scan("atv")
        checkout.scan("atv")
        checkout.scan("vga")
        expect(checkout.get_cart.length).to eq(3)
        expect(checkout.total).to eq(249)
      end
    end
    context "when there is a bulk discount available" do
      it "correctly applies bulk discount when the required number of eligible items are scanned" do
        checkout = Checkout.new("spec/pricingRules.json")
        checkout.scan("atv")
        checkout.scan("ipd")
        checkout.scan("ipd")
        checkout.scan("atv")
        checkout.scan("ipd")
        checkout.scan("ipd")
        checkout.scan("ipd")
        expect(checkout.get_cart.length).to eq(7)
        expect(checkout.total).to eq(2718.95)
      end
      it "does not apply bulk discount when minimum number of eligible items is not met" do
        checkout = Checkout.new("spec/pricingRules.json")
        checkout.scan("atv")
        checkout.scan("ipd")
        expect(checkout.get_cart.length).to eq(2)
        expect(checkout.total).to eq(659.49)
      end
    end
    context "when an item can be bundled for free with another item" do
      it "does not apply additional discounts for optional bundled items that haven't been scanned" do
        checkout = Checkout.new("spec/pricingRules.json")
        checkout.scan("vga")
        checkout.scan("mbp")
        checkout.scan("ipd")
        checkout.scan("mbp")
        checkout.scan("mbp")
        expect(checkout.get_cart.length).to eq(5)
        expect(checkout.total).to eq(4749.96)
      end
  
      it "does not apply the bundle discount for additional items that aren't bundled with the main item" do
        checkout = Checkout.new("spec/pricingRules.json")
        checkout.scan("mbp")
        checkout.scan("vga")
        checkout.scan("vga")
        checkout.scan("vga")
        checkout.scan("ipd")
        expect(checkout.get_cart.length).to eq(5)
        expect(checkout.total).to eq(2009.98)
      end
    end
  end
end