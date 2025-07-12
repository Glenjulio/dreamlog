class AddTagsToDreams < ActiveRecord::Migration[7.1]
  def change
    add_column :dreams, :tags, :string
  end
end
