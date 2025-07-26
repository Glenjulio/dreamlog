class AddKeywordsToTranscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :transcriptions, :keywords, :text
  end
end
