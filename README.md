open-build-service Cookbook
===========================

This cookbook makes your favorite build system a lot easier and maintainable.

Requirements
------------

#### packages
- `apache2`
- `passenger_apache2` Required for the frontend / API / WebUI
- `mysql` (patched to handle openSUSE version of MariaDB)
- `mysql2_chef_gem`
- `database`
- `ssl_certificate`
- `lvm` (for worker)

Attributes
----------

#### open-build-service::worker
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['open-build-service']['worker']['repo_servers']</tt></td>
    <td>Sring</td>
    <td>Repository server instance addresses</td>
    <td><tt>""</tt></td>
  </tr>
</table>

Usage
-----
#### open-build-service

Add open-build-service as cookbook into your Cheffile (or alternative files for
other cookbook management systems).

You need to generate GPG keys for the OBS signer as described on
https://en.opensuse.org/openSUSE:Build_Service_Signer#Set_up_the_GPG_key

And put those keys in an encrypted data-bag.

For testing/demo purposes you can run this:

```bash
$ ./cookbooks/open-build-service/examples/gpg/gpg_keys.sh generate
[...]
I: Next step is to create the obs_gpgkeys databage with following commands:
openssl rand -base64 512 | tr -d '\r\n' > ~/.chef/your_databag_key
echo 'encrypted_data_bag_secret "#{home_dir}/.chef/your_databag_key"' >> .chef/knife.rb
knife data bag create obs_gpgkeys
knife data bag --secret-file ~/.chef/your_databag_key from file obs_gpgkeys cookbooks/open-build-service/examples/gpg/obs_gpg_keys/signd_public_key.json
knife data bag --secret-file ~/.chef/your_databag_key from file obs_gpgkeys cookbooks/open-build-service/examples/gpg/obs_gpg_keys/signd_private_key.json
knife data bag --secret-file ~/.chef/your_databag_key from file obs_gpgkeys cookbooks/open-build-service/examples/gpg/obs_gpg_keys/signd_key_phrase.json

I: Suggesting following initial node declaration:
```


```json
{
  "open-build-service": {
    "signer": {
      "user": "defaultkey@localobs"
    },
    "signd": {
      "keypairs": {
        "defaultkey@localobs": {
          "bag": "obs_gpgkeys",
          "private_key": {
            "item": "signd_private_key"
          },
          "public_key": {
            "item": "signd_public_key"
          },
          "key_phrase": {
            "item": "signd_key_phrase"
          }
        }
      }
    }
  },
  "run_list": [
        "recipe[open-build-service::source_server]",
        "recipe[open-build-service::service_server]",
        "recipe[open-build-service::api_server]",
        "recipe[open-build-service::signd]",
        "recipe[open-build-service::repo_server]",
        "recipe[open-build-service::worker]"
  ]
}
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
- Author:: Daniel Gollub (dgollub@brocade.com)
- Author:: Jan Blunck (jblunck@brocade.com)

```text
Copyright 2014-2015, Brocade Communications Systems, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

```
