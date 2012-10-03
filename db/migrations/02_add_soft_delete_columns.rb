Sequel.migration do
  up do    
    alter_table(:systems) do
      add_column :deleted, TrueClass, :null => false, :default => false
    end

    alter_table(:deploys) do
      add_column :deleted, TrueClass, :null => false, :default => false
    end

    alter_table(:steps) do
      add_column :deleted, TrueClass, :null => false, :default => false
    end
  end
end
