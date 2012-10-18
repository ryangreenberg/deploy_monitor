module Paths
  extend self

  def for_deploy(deploy)
    "/deploys/#{deploy.id}"
  end

  def for_system(sys)
    "/systems/#{sys.name}"
  end
end