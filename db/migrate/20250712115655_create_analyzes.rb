class CreateAnalyzes < ActiveRecord::Migration[7.1]
  def change
    create_table :analyzes do |t|
      t.references :transcription, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
