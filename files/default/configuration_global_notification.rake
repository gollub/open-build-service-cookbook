task :setup_global_notification, [:file] => :environment do |t, args|
  args.with_defaults(:file => '/srv/www/obs/api/config/global_notification.yml')

  hash = YAML.load_file(args.file)

  hash.each do |key, value|
    puts "k: #{key} v: #{value}\n"
    EventSubscription.update_subscription(value['eventtype'], value['receiver_role'], nil, value['receive'])
  end

end
