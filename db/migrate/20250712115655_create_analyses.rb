class CreateAnalyses < ActiveRecord::Migration[7.1]
  def change
    create_table :analyses do |t|
      t.references :transcription, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
