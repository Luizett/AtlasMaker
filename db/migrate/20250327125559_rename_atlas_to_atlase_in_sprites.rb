class RenameAtlasToAtlaseInSprites < ActiveRecord::Migration[8.0]
  def change
    rename_column :sprites, :atlas_id, :atlase_id
  end
end
