task :load_distribution_xml, [:file] => :environment do |t, args|
  args.with_defaults(:file => '/srv/obs/distribution.xml')
  puts "Reading file: #{args.file}"
  xml = Xmlhash.parse(File.read(args.file)) || {}
  Distribution.parse(xml)
end
