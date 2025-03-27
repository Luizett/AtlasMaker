class RenameAtlasToAtlase < ActiveRecord::Migration[8.0]
  def change
    rename_table :atlas, :atlases
  end
end
