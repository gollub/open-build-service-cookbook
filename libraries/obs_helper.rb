module ObsHelper
  def url(host, port)
    url = (port == '443') ? "https://" : "http://"
    url += host
    url += %w(80 443).include?(port) ? "" : ":#{port}"
  end

  def get_keyfile
    if node['open-build-service']['keyfile'].respond_to?('attribute?') and
        node['open-build-service']['keyfile'].attribute?('bag')
      if node['open-build-service']['keyfile'].attribute?('item')
        item = node['open-build-service']['keyfile']['item']
      else
        item = 'keyfile'
      end
      keyfile = Chef::EncryptedDataBagItem.load(node['open-build-service']['keyfile']['bag'], item)
      fn =  "/srv/obs/#{keyfile['filename']}"
#     file "#{fn}" do
#       content keyfile['content']
#       owner 'root'
#       group 'root'
#       mode 0600
#     end
      return fn

    else
      return node['open-build-service']['keyfile']
    end
  end
end
