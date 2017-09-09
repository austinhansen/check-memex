#!/usr/bin/env ruby

require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

class InventoryChecker
  include Capybara::DSL
  Capybara.default_driver = :poltergeist

  def check
    page.driver.set_cookie('Inventory_Region', 'Edmonton', domain: 'www.memoryexpress.com')
    visit "http://www.memoryexpress.com/Products/MX64875"

    inventory = all('.c-capr-inventory-store').map do |store|
      name = store.find('[data-role="store"]').text
      stock = store.find('.InventoryState_InStock').text

      { name: name, stock: stock }
    end

    inventory
      .reject { |i| i[:name].downcase.include?('online') }
      .map { |i| i[:stock].to_i }
      .inject(:+)
  end
end

puts InventoryChecker.new.check
