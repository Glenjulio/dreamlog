class RemoveTranscriptionColumnFromDreams < ActiveRecord::Migration[7.1]
  def change
    remove_column :dreams, :transcription, :text if column_exists?(:dreams, :transcription)
  end
end
