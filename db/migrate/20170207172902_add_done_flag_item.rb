class AddDoneFlagItem < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :done, :boolean, default: false
  end
end
