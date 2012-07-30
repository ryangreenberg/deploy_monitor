Sequel.migration do
  up do    
    create_table(:systems) do
      primary_key :id
      String :name, :size=>80
    end

    create_table(:deploy_steps) do
      primary_key :id
      Integer :system_id, :null=>false
      String :name, :size=>80
      String :description, :size=>100
      Integer :number
    end

    create_table(:deploys) do
      primary_key :id
      Integer :system_id, :null=>false
      TrueClass :active, :null=>false
      Integer :result, :null=>true
      String :owner, :size=>80
      String :ticket, :size=>80
      String :metadata, :text=>true
      DateTime :created_at
      DateTime :updated_at
    end

    create_table(:steps) do
      primary_key :id
      Integer :deploy_id, :null=>false
      Integer :step_id, :null=>false
      TrueClass :active, :null=>false
      DateTime :started_at
      DateTime :completed_at
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:systems, :deploy_steps, :deploys, :steps)
  end
end
