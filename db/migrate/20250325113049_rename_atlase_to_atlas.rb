class RenameAtlaseToAtlas < ActiveRecord::Migration[8.0]
  def change
    rename_table :atlases, :atlas
  end
end
