# IBM Code Model Asset Exchange: Name Generator

This repository contains code to train and score a Name Generator on [IBM Watson Machine Learning](https://www.ibm.com/cloud/machine-learning). This model is part of the [IBM Code Model Asset Exchange](https://developer.ibm.com/code/exchanges/models/).

It uses a [recurrent neural network (RNN)](https://www.tensorflow.org/versions/r0.8/tutorials/recurrent/index.html#recurrent-neural-networks) model to recognize and generate names using the [Kaggle Baby Name Database](https://www.kaggle.com/kaggle/us-baby-names). This model can also be trained on a database of other names from other countries. Once a model is trained, it will be able to tell if a given name is "unusual" based on the set of names it was trained on. It will also be able to suggest names based on the initial set of names.

## Model Metadata
| Domain | Application | Industry  | Framework | Training Data | Input Data Format |
| ------------- | --------  | -------- | --------- | --------- | -------------- |
| Text | Text Generation | General | TensorFlow | [Kaggle Baby Name Database](https://www.kaggle.com/kaggle/us-baby-names) | Text |

## References
* [Namignizer TensorFlow GitHub Repository](https://github.com/tensorflow/models/tree/master/research/namignizer)

## Licenses

| Component | License | Link  |
| ------------- | --------  | -------- |
| This repository | [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) | [LICENSE](LICENSE) |
| Model Code (3rd party) | [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) | [TensorFlow Models](https://github.com/tensorflow/models/blob/master/LICENSE)|
|Data|[CC0: Public Domain](https://creativecommons.org/publicdomain/zero/1.0/)|[US Baby Names](https://www.kaggle.com/kaggle/us-baby-names)|

# Quickstart

## Prerequisites

* This experiment requires a provisioned instance of IBM Watson Machine Learning service. If you don't have an instance yet, go to [Watson Machine Learning in the IBM Cloud Catalog](https://console.bluemix.net/catalog/services/machine-learning) to create one.

### Setup an IBM Cloud Object Storage (COS) account
- Create an IBM Cloud Object Storage account if you don't have one (https://www.ibm.com/cloud/storage)
- Create credentials for either reading and writing or just reading
	- From the bluemix console page (https://console.bluemix.net/dashboard/apps/), choose `Cloud Object Storage`
	- On the left side, click the `service credentials`
	- Click on the `new credentials` button to create new credentials
	- In the `Add New Credentials` popup, use this parameter `{"HMAC":true}` in the `Add Inline Configuration...`
	- When you create the credentials, copy the `access_key_id` and `secret_access_key` values.
	- Make a note of the endpoint url
		- On the left side of the window, click on `Endpoint`
		- Copy the relevant public or private endpoint. [I choose the us-geo private endpoint].
- In addition setup your [AWS S3 command line](https://aws.amazon.com/cli/) which can be used to create buckets and/or add files to COS.
   - Export `AWS_ACCESS_KEY_ID` with your COS `access_key_id` and `AWS_SECRET_ACCESS_KEY` with your COS `secret_access_key`

### Setup IBM CLI & ML CLI

- Install [IBM Cloud CLI](https://console.bluemix.net/docs/cli/reference/bluemix_cli/get_started.html#getting-started)
  - Login using `ibmcloud login` or `ibmcloud login --sso` if within IBM
- Install [ML CLI Plugin](https://dataplatform.ibm.com/docs/content/analyze-data/ml_dlaas_environment.html)
  - After install, check if there is any plugins that need update
    - `ibmcloud plugin update`
  - Make sure to setup the various environment variables correctly:
    - `ML_INSTANCE`, `ML_USERNAME`, `ML_PASSWORD`, `ML_ENV`

## Training the model

To obtain a sample dataset, we can use the [Baby Name Dataset](https://www.kaggle.com/kaggle/us-baby-names) from Kaggle. In order to download the dataset a Kaggle account is needed. Once you have downloaded the `NationalNames.csv` file and have it saved under this project's directory we can use a script to set up training.

The `train.sh` utility script will prompt the user to enter the names of the buckets to be created for the training data and result weights and start training the model as a `training-run` on the Watson ML service.

```
$ train.sh
Enter a training bucket name

$ name-gen-training
upload: ./NationalNames.csv to s3://name-gen-training/data/NationalNames.csv

$ Enter a results bucket name
name-gen-results
...
```

After training has started, it should print the training-id that is going to be necessary for steps below

```
Starting to train ...
OK
Model-ID is 'training-GCtN_YRig'
```

### Monitor the  training run

- To list the training runs - `ibmcloud ml list training-runs`
- To monitor a specific training run - `ibmcloud ml show training-runs <training-id>`
- To monitor the output (stdout) from the training run - `ibmcloud ml monitor training-runs <training-id>`
	- This will print the first couple of lines, and may time out.


### Save and deploy the model after completion

Save the model, when the training run has successfully completed and deploy it for scoring.
- `ibmcloud ml store training-runs <training-id>`
	- This should give you back a *model-id*
	- This *model-id* will be needed to run the demo later
- `ibmcloud ml deploy <model-id> 'name-generator'`
	- This should give you a *deployment-id*

## Scoring the model

- Update `modelId` and `deploymentId` on `scoring-payload.json`
- Score the model with `ibmcloud ml score scoring-payload.json`

```
$ ibmcloud ml score scoring-payload.json
Fetching scoring results for the deployment 'fbe54656-c146-4162-b56c-0da821776bf9' ...
{"values": 0.1227683424949646}

OK
Score request successful
```

## Train the model in Fabric for Deep Learning

If you want to train this model using Fabric for Deep Learning ([FFDL](https://github.com/IBM/FfDL)), You can simply clone the FfDL repository and follow the instructions over [here](https://github.com/IBM/FfDL/blob/master/etc/converter/ffdl-wml.md) to convert your `training-runs.yml` into FfDL's specification.


## Testing the Model

The `demo.sh` script will download the results from the bucket and run a python script to test the model.

```
Input a single name to be evaluated or leave input blank to generate a name.
$ mary
Name mary gives us a perplexity of 1.03105580807

Input a single name to be evaluated or leave input blank to generate a name.
$ gazorpazorp
Name gazorpazorp gives us a perplexity of 175.940353394

Input a single name to be evaluated or leave input blank to generate a name.
$
michael
```

In the example above, the model "rates" a given name using perplexity. In this case, perplexity can be thought of as how likely it is that the model would have come up with that name itself. The lower the perplexity, the higher the probability that the model would have generated that name. In the example above "Mary", a common name, gets a low perplexity of 1.03, while an unusual name like "Gazorpazorp" has a perplexity of 175.94.
