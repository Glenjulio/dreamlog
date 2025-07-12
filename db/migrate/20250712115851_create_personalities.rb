class CreatePersonalities < ActiveRecord::Migration[7.1]
  def change
    create_table :personalities do |t|
      t.integer :age
      t.string :job
      t.string :gender
      t.text :description
      t.string :relationship
      t.string :mood
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
