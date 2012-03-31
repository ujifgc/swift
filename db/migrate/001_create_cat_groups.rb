migration 1, :create_cat_groups do
  up do
    create_table :cat_groups do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :cat_groups
  end
end
