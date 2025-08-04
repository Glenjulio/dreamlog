class AddDataToAnalyses < ActiveRecord::Migration[7.1]
  def change
    add_column :analyses, :data, :jsonb, default: {}, null: false
  end
end
