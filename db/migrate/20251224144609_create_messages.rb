# db/migrate/[timestamp]_create_messages.rb
class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.string :role, null: false # 'user' ou 'assistant'
      t.text :content, null: false
      t.jsonb :metadata, default: {} # Pour stocker des infos supplémentaires (tokens, model, etc.)

      t.timestamps
    end

    add_index :messages, [:conversation_id, :created_at]
    add_index :messages, :role
  end
end
