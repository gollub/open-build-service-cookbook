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
#### open-build-service::....

Just include `open-build-service` in your node's `run_list`:

```json
{
  "open-build-service": {
    "signer": {
      "user": "obsrun@build.example.com"
    },
    "signd": {
      "keypairs": {
        "obsrun@build.example.com": {
          "bag": "gpgkeys_data_bag",
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
    },
    "worker": {
      "kvm": true,
      "kernel_package": "kernel-obs-build",
      "vm_type": "kvm",
      "vm_kernel": "/.build.kernel.kvm",
      "vm_initrd": "/.build.initrd.kvm"
    },
    "source_services": ["download_url"],
	"frontend" : {
            "remote_instances": {
               "openSUSE": {
                  "title": "openSUSE.org",
                  "description": "Public OpenSUSE OBS instance",
                  "remoteurl": "https:/api.opensuse.org/public"
                }
            },
            "global_notification": {
               "BuildFail": {
                  "bugowner": 1,
                  "maintainer": 1 
                }
             },
	    "ssl_key": {
		"source": "data-bag",
		"bag": "ssl_data_bag",
		"item": "key",
		"item_key": "content",
		"encrypted": true
	    },
	    "ssl_cert": {
		"source": "data-bag",
		"bag": "ssl_data_bag",
		"item": "cert",
		"item_key": "content",
		"encrypted": true
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
