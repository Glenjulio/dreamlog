class CreateDreams < ActiveRecord::Migration[7.1]
  def change
    create_table :dreams do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :audio_file
      t.string :status

      t.timestamps
    end
  end
end
