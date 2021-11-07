
import boto3
import os
import sagemaker
from sagemaker.tensorflow import TensorFlow
from sagemaker import get_execution_role
import random

import time
from six.moves.urllib.parse import urlparse

def unique_name_from_base(base, max_length=63):
    unique = '%04x' % random.randrange(16**4)  # 4-digit hex
    ts = str(int(time.time()))
    available_length = max_length - 2 - len(ts) - len(unique)
    trimmed = base[:available_length]
    return '{}-{}-{}'.format(trimmed, ts, unique)

def _assert_s3_file_exists(region, s3_url):
    parsed_url = urlparse(s3_url)
    s3 = boto3.resource('s3', region_name=region)
    s3.Object(parsed_url.netloc, parsed_url.path.lstrip('/')).load()


if __name__ == '__main__':
    region = "us-west-2"
    sagemaker_session = sagemaker.Session(boto_session=boto3.Session(region_name=region))

    # role = get_execution_role()
    ecr_image= "348941870272.dkr.ecr.us-west-2.amazonaws.com/oap:2.5.1-cpu-py37-ubuntu18.04-2021-11-05-13-08-06"
    # ecr_image= "763104351884.dkr.ecr.us-west-2.amazonaws.com/tensorflow-training:2.5.0-cpu-py37-ubuntu18.04"
    framework_version="2.5.0"
    instance_type='ml.c4.xlarge'
    resource_path = os.path.join(os.path.dirname(__file__), 'resources')
    script = os.path.join(resource_path, 'mnist', 'mnist.py')
    estimator = TensorFlow(entry_point=script,
                           role='SageMakerRole',
                           instance_type=instance_type,
                           instance_count=1,
                           sagemaker_session=sagemaker_session,
                           image_uri=ecr_image,
                           framework_version=framework_version)


    inputs = estimator.sagemaker_session.upload_data(
        path=os.path.join(resource_path, 'mnist', 'data'),
        key_prefix='scriptmode/mnist')
    estimator.fit(inputs, job_name=unique_name_from_base('test-sagemaker-mnist'))
    _assert_s3_file_exists(sagemaker_session.boto_region_name, estimator.model_data)

