class CreateTranscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :transcriptions do |t|
      t.references :dream, null: false, foreign_key: true
      t.text :content
      t.string :mood
      t.string :tag
      t.integer :rating

      t.timestamps
    end
  end
end
