import argparse
import json
import os
import sys
import time

import numpy as np
import tensorflow as tf

def print_version():
    from tensorflow.python.util import _pywrap_util_port
    print("tensorflow version: " + tf.__version__)
    print(_pywrap_util_port.IsMklEnabled())
    os.system("pip freeze")

def _parse_args():

    parser = argparse.ArgumentParser()

    # hyperparameters sent by the client are passed as command-line arguments to the script.
    parser.add_argument('--epochs', type=int, default=100)
    # Data, model, and output directories
    parser.add_argument('--model-dir', type=str, default=os.environ['SM_MODEL_DIR'])
    parser.add_argument('--train', type=str, default=os.environ['SM_CHANNEL_TRAINING'])
    parser.add_argument('--hosts', type=list, default=json.loads(os.environ['SM_HOSTS']))
    parser.add_argument('--current-host', type=str, default=os.environ['SM_CURRENT_HOST'])

    return parser.parse_known_args()


def _load_training_data(base_dir):
    x_train = np.load(os.path.join(base_dir, 'train', 'x_train.npy'))
    y_train = np.load(os.path.join(base_dir, 'train', 'y_train.npy'))
    return x_train, y_train


def _load_testing_data(base_dir):
    x_test = np.load(os.path.join(base_dir, 'test', 'x_test.npy'))
    y_test = np.load(os.path.join(base_dir, 'test', 'y_test.npy'))
    return x_test, y_test


args, unknown = _parse_args()
print(args)
model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(512, activation=tf.nn.relu),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10, activation=tf.nn.softmax)
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])
x_train, y_train = _load_training_data(args.train)
x_test, y_test = _load_testing_data(args.train)
print_version()
strat = time.time()
model.fit(x_train, y_train, epochs=args.epochs)
model.evaluate(x_test, y_test)
end = time.time()
print("time cost ",end -strat,"s")
if args.current_host == args.hosts[0]:
    model.save(os.path.join('/opt/ml/model', 'my_model.h5'))
