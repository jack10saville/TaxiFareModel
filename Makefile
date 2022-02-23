
# - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Cloud Functions
default: pylint

pylint:
	find . -iname "*.py" -not -path "./tests/*" | xargs -n1 -I {}  pylint --output-format=colorized {}; true
# ----------------------------------
#         LOCAL SET UP
# ----------------------------------

run_locally:
	@python -W ignore -m TaxiFareModel.trainer

install_requirements:
	@pip install -r requirements.txt

# ----------------------------------
#    LOCAL INSTALL COMMANDS
# ----------------------------------
install:
	@pip install . -U


clean:
	@rm -fr */__pycache__
	@rm -fr __init__.py
	@rm -fr build
	@rm -fr dist
	@rm -fr TaxiFareModel-*.dist-info
	@rm -fr TaxiFareModel.egg-info
	-@rm model.joblib


FUNCTION_NAME=hacker-scrap
REGION=europe-west1
CODE_SOURCE_PATH=.
CODE_ENTRY_POINT=storage_upload
RUNTIME=python39
TIMEOUT=60s

deploy_function:
	gcloud functions deploy ${FUNCTION_NAME} \
		--region ${REGION} \
		--trigger-http \
		--no-allow-unauthenticated \
		--source ${CODE_SOURCE_PATH} \
		--entry-point ${CODE_ENTRY_POINT} \
		--runtime ${RUNTIME} \
		--timeout ${TIMEOUT}

list_function:
	gcloud functions list

describe_function:
	gcloud functions describe ${FUNCTION_NAME} \
		--region ${REGION} \

# - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Cloud Scheduler

JOB_NAME=job-name
JOB_FREQUENCY="* * * * *"
FUNCTION_URI="https://europe-west1-le-wagon-data.cloudfunctions.net/hacker-scrap"
SERVICE_ACCOUNT_EMAIL=le-wagon-data@le-wagon-data.iam.gserviceaccount.com

deploy_trigger:
	gcloud scheduler jobs create http ${JOB_NAME} \
		--schedule ${JOB_FREQUENCY} \
		--uri ${FUNCTION_URI} \
		--oidc-service-account-email ${SERVICE_ACCOUNT_EMAIL}

pause_trigger:
	gcloud scheduler jobs pause ${JOB_NAME}

resume_trigger:
	gcloud scheduler jobs resume ${JOB_NAME}

delete_trigger:
	gcloud scheduler jobs delete ${JOB_NAME} --quiet

list_trigger:
	gcloud scheduler jobs list

describe_trigger:
	gcloud scheduler jobs describe ${JOB_NAME}
