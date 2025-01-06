.PHONY: init plan apply destroy fmt validate

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply

destroy:
	terraform destroy

fmt:
	terraform fmt -recursive

validate:
	terraform validate

# Database commands
.PHONY: db-dry-run db-apply

db-dry-run:
	psqldef -U ${TF_VAR_db_user} -W ${TF_VAR_db_password} -h ${DB_HOST} --dry-run ${DB_NAME} < db/schema.sql

db-apply:
	psqldef -U ${TF_VAR_db_user} -W ${TF_VAR_db_password} -h ${DB_HOST} ${DB_NAME} < db/schema.sql

.PHONY: setup
setup: init fmt validate 