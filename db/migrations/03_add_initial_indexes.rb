Sequel.migration do
  up do    
    alter_table(:deploys) do
      add_index :system_id
      add_index :started_at
      add_index :finished_at
    end

    alter_table(:progresses) do
      add_index :step_id
      add_index :deploy_id
    end

    alter_table(:steps) do
      add_index :system_id
    end
  end
end
