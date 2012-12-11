Sequel.migration do
  up do    
    create_table(:system_locks) do
      primary_key :id
      Integer :system_id, :null=>false
      TrueClass :active, :null=>false
      String :description, :size=>255
      DateTime :started_at
      DateTime :finished_at
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:system_locks)
  end
end
