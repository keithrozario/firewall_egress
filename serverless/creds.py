import sys
import json
import getpass
import os
from configparser import ConfigParser


creds_file_path=f"/Users/{getpass.getuser()}/.aws/credentials"

def write_creds_file(config: dict, replace: bool = True):

    """
    Writes out data in config to credentials file
    Args:
      config: ConfigParser to write out too
    """

    creds = ConfigParser()

    if not replace:
        creds.read(filenames=[creds_file_path], encoding="utf-8")

    creds.read_dict(config)

    with open(creds_file_path, "w") as creds_file:
        creds.write(creds_file)

    return


creds = json.load(sys.stdin)
profile = os.getenv('AWS_PROFILE')

output = {
    f'{profile}' : {
        'aws_access_key_id': creds['AccessKeyId'],
        'aws_secret_access_key': creds['SecretAccessKey'],
        'aws_session_token': creds['SessionToken']
    }
}

write_creds_file(output)