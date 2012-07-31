Sequel.migration do
  up do    
    create_table(:systems) do
      primary_key :id
      String :name, :size=>80
    end

    create_table(:steps) do
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
      String :metadata, :text=>true
      DateTime :started_at
      DateTime :finished_at
      DateTime :created_at
      DateTime :updated_at
    end

    create_table(:progresses) do
      primary_key :id
      Integer :deploy_id, :null=>false
      Integer :step_id, :null=>false
      TrueClass :active, :null=>false
      Integer :result, :null=>true
      DateTime :started_at
      DateTime :finished_at
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:systems, :steps, :deploys, :progresses)
  end
end
