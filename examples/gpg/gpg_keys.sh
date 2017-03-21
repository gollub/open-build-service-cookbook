#!/bin/bash

set -e

PATH=../:../../:$PATH
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
RESULTS="$DIR/obs_gpg_keys"


[ -z "$KEY_ID" ] && KEY_ID="defaultkey@localobs"
# FIXME: add key phrase support
#[ -z "$KEY_PHRASE" ] && KEY_PHRASE="" 

usage() {
	echo "usage: $0 <generate|clean>"
	exit 1
}


generate() {

	WDIR=`mktemp -d`
	trap "rm -rf $WDIR" EXIT

	mkdir -p $RESULTS
	pushd $RESULTS > /dev/null

	cat > $WDIR/batch << EOF
Key-Type: RSA
Key-Length: 2048
Subkey-Type: RSA
Subkey-Length: 2048
Name-Real: OBS
Name-Comment: OBS key generate by open-build-service-cookbook example scripts 
Name-Email: $KEY_ID 
Expire-Date: 0
%pubring $WDIR/pubring.gpg
%secring $WDIR/secring.gpg
%commit
EOF
	gpg --homedir $WDIR --batch --gen-key $WDIR/batch > /dev/null
	gpg --homedir $WDIR --export -a > public.asc
	gpg --homedir $WDIR --export-secret-keys -a > private.asc

	# without passprhase = empty phrase file
	echo -n "$KEY_PHRASE" > phrase

	create_data_bag_item public.asc signd_public_key
	create_data_bag_item private.asc signd_private_key
	create_data_bag_item phrase signd_key_phrase

	popd > /dev/null


	echo ""
	echo "I: Next step is to create the obs_gpgkeys databage with following commands:"
	cat << EOF
openssl rand -base64 512 | tr -d '\r\n' > ~/.chef/your_databag_key
knife data bag create obs_gpgkeys
knife data bag --secret-file ~/.chef/your_databag_key from file obs_gpgkeys $RESULTS/signd_public_key.json
knife data bag --secret-file ~/.chef/your_databag_key from file obs_gpgkeys $RESULTS/signd_private_key.json
knife data bag --secret-file ~/.chef/your_databag_key from file obs_gpgkeys $RESULTS/signd_key_phrase.json
EOF

	echo ""
	echo "I: Suggesting following initial node declaration:"
	cat << EOF
{
  "open-build-service": {
    "signer": {
      "user": "$KEY_ID"
    },
    "signd": {
      "keypairs": {
        "$KEY_ID": {
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
EOF



}

clean() {
	rm -rf $RESULTS
}


if [ "$1" = "generate" ]; then
	echo "Generating databag with GPG keys for OBS ..."
	generate
elif [ "$1" = "clean" ]; then
	echo "Cleaning GPG keys ..."
	clean
else
	usage
fi
