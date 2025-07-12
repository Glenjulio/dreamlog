class AddPrivateToDreams < ActiveRecord::Migration[7.1]
  def change
    add_column :dreams, :private, :boolean
  end
end
