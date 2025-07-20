class RenameAnalyzesToAnalyses < ActiveRecord::Migration[7.1]
  def change
    rename_table :analyzes, :analyses
  end
end
