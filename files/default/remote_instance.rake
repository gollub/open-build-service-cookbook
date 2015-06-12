task :setup_remote_instances, [:file] => :environment do |t, args|
  args.with_defaults(:file => '/srv/www/obs/api/config/remote_instances.yml')

  User.current = User.find_by_login('Admin')
  hash = YAML.load_file(args.file)

  hash.each do |project_name, params|
    if Project.exists_by_name project_name
      next
    end

    @project = Project.new(name: project_name)
    @project.title = params['title']
    @project.description = params['description']
    @project.remoteurl = params['remoteurl']
    
    if @project.store
      puts "New remote instance #{project_name} got connected."
    else
      puts "Failed to connect remote instance #{project_name}."
    end
  end

end
