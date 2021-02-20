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
      it "outputs an error when the pricing rules file can't be loaded" do
        expect{checkout = Checkout.new("spec/nofile.json")}.to output("something went wrong with loading pricing rules. No such file or directory @ rb_sysopen - spec/nofile.json").to_stderr
      end
      it "validates pricing rules" do
        expect{checkout = Checkout.new("spec/invalidPricing.json")}.to output("something went wrong with loading pricing rules. item with SKU tsi has multiple discounts applied, this is not supported").to_stderr
      end
    end
  end

  describe "#scan" do
    it "adds a new item to the cart based on the item SKU" do
      checkout = Checkout.new("spec/pricingRules.json")
      checkout.scan("atv")
      expect(checkout.cart.length).to eq(1)
      added_item = checkout.cart[0]
      expect(added_item.SKU).to eq("atv")
      expect(added_item.name).to eq("Apple TV")
      expect(added_item.price).to eq(109.50)
      expect(added_item.three_for_two).to eq(true)
    end
  end

  describe "#total" do
    it "correctly applies 2 for 3 discount" do
      checkout = Checkout.new("spec/pricingRules.json")
      checkout.scan("atv")
      checkout.scan("atv")
      checkout.scan("atv")
      checkout.scan("atv")
      checkout.scan("atv")
      checkout.scan("atv")
      checkout.scan("vga")
      expect(checkout.cart.length).to eq(7)
      expect(checkout.total).to eq(468)
    end
    it "correctly applies bulk discount" do
      checkout = Checkout.new("spec/pricingRules.json")
      checkout.scan("atv")
      checkout.scan("ipd")
      checkout.scan("ipd")
      checkout.scan("atv")
      checkout.scan("ipd")
      checkout.scan("ipd")
      checkout.scan("ipd")
      expect(checkout.cart.length).to eq(7)
      expect(checkout.total).to eq(2718.95)
    end
    it "correctly applies bundling1" do
      checkout = Checkout.new("spec/pricingRules.json")
      checkout.scan("vga")
      checkout.scan("mbp")
      checkout.scan("ipd")
      checkout.scan("mbp")
      checkout.scan("mbp")
      expect(checkout.cart.length).to eq(5)
      expect(checkout.total).to eq(4749.96)
    end

    it "correctly applies bundling2" do
      checkout = Checkout.new("spec/pricingRules.json")
      checkout.scan("mbp")
      checkout.scan("vga")
      checkout.scan("vga")
      checkout.scan("vga")
      checkout.scan("ipd")
      expect(checkout.cart.length).to eq(5)
      expect(checkout.total).to eq(2009.98)
    end
  end
end