class AddDreamTypeToTranscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :transcriptions, :dream_type, :string
  end
end
