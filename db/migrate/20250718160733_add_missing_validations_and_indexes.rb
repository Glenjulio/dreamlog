# db/migrate/YYYYMMDDHHMMSS_add_missing_validations_and_indexes.rb
class AddMissingValidationsAndIndexes < ActiveRecord::Migration[7.1]
  def change
    add_index :dreams, :private
    add_index :dreams, :created_at
    add_index :transcriptions, :created_at

    change_column_null :dreams, :title, false
    change_column_null :transcriptions, :content, false
  end
end
