# DiUS - Shopping code test

### How to run

This is a `Ruby` code test and `Ruby` will need to be installed to run the code.

This code test does not have a GUI. To run this program navigate to the root directory of the program in the command line and run the commands:

```
bundle install
bundle exec rspec spec\checkout.spec.rb
```
This will run through a comprehensive set of tests, based on the specified pricing rules for the exercise.

### Pricing Rules

The pricing rules can be found in the `pricingRules.json` file. This JSON file contains the pricing items for the store with flags to indicate what discounts the program should apply to them.

|	field				|	definition																					|	required	|
|	----------------	|	----------------------------------------------------------------------------------------	|	--------	|
|	sku					|	unique stock keeping code for the item														|	yes			|
|	price				|	the base item price																			|	yes			|
|	name				|	user facing name of the item																|	no			|
|	bonusItemSku		|	the SKU of an item that is eligible to be bundled for free with purchase of this item		|	no			|
|	threeForTwo			|	a flag that indicates this item is eligible for a 3 for the price of 2 discount				|	no			|
|	bulkDealAmount		|	indicates number of items required for the bulk deal price to be applied					|	no			|
|	bulkDealPrice		|	the item price when purchased in bulk														|	no			|

The program supports one type of discount per item at a time, for example if the Apple TV is eligible for the `threeForTwo` discount then it cannot have a bulk deal or bundled item associated with it.

The sales manager can update `pricingRules.json` with additional items, prices, or different discount rules by editing the file directly or providing a different file when initializing the checkout.
