#!/usr/bin/env ruby

require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'whirly'

class InventoryChecker
  include Capybara::DSL
  Capybara.register_driver :poltergeist do |app|
    options = { js_errors: false }
    Capybara::Poltergeist::Driver.new(app, options)
  end
  Capybara.default_driver = :poltergeist

  def check
    sagrada
  end

  def sagrada
    bliss_inventory = spin("Querying Board Game Bliss") do
      check_bliss "https://www.boardgamebliss.com/products/sagrada?variant=32022349517"
    end
    amazon_inventory = spin("Querying Amazon") do
      check_amazon "https://www.amazon.ca/Floodgate-Games-FFG-SA01-Sagrada-Board/dp/B01MTG2QY2"
    end
    spin("Reticulating splines") { sleep(1) }
    combine_inventories([bliss_inventory, amazon_inventory])
  end

  private

  def check_bliss(url)
    visit url
    stock = find(".selector-wrapper").text
    price = format_price(find("#price-preview").text)
    { Name: "Boardgame Bliss", Stock: stock, Price: price }
  end

  def check_amazon(url)
    visit url
    stock = find("#availability").text
    price = format_price(find("#priceblock_ourprice").text)
    { Name: "Amazon", Stock: stock, Price: price }
  end

  def combine_inventories(inventories_array)
    inventories_array.reduce("") do |combined_output, inventory|
      inventory.each do |key, value|
        combined_output << "#{key}: #{value}\n"
      end
      combined_output
    end
  end

  def format_price(price)
    price.delete("^0-9.").prepend("$")
  end

  def spin(status)
    Whirly.start position: :below, spinner: "pong", status: status, stop: "Done!" do
      return yield
    end
  end
end

puts InventoryChecker.new.check
