task :setup_admin_password, [:password] => :environment do |t, args|
  args.with_defaults(:password => 'opensuse')

  user = User.find_by_login('Admin')
  user.update_password( args.password )
  user.save!

end


