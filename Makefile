AWS_PROFILE = default

CYAN = \033[36m
YELLOW = \033[33m
GREEN = \033[32m
RED = \033[31m
BLUE = \033[34m
MAGENTA = \033[35m
RESET = \033[0m
BOLD = \033[1m

setup-aws:
	@printf "$(CYAN)$(BOLD)🚀 AWS CloudFormation Deployment Tool$(RESET)\n"
	@printf "$(CYAN)=====================================$(RESET)\n"
	@printf "\n"

	@if [ -n "$(AWS_PROFILE)" ]; then \
		printf "$(YELLOW)📋 Using AWS profile: $(BOLD)$(AWS_PROFILE)$(RESET)\n"; \
		AWS_PROFILE=$(AWS_PROFILE); \
	fi

	@if ! command -v aws >/dev/null 2>&1; then \
		printf "$(RED)❌ AWS CLI not found. Please install AWS CLI and configure your profile.$(RESET)\n"; \
		exit 1; \
	fi

	@if ! aws configure get aws_access_key_id --profile $(AWS_PROFILE) >/dev/null 2>&1; then \
		printf "$(RED)❌ AWS CLI profile '$(AWS_PROFILE)' not configured. Please configure your AWS CLI profile$(RESET)\n"; \
		exit 1; \
	fi

	@printf "$(GREEN)✅ AWS CLI configured successfully$(RESET)\n"
	@printf "\n"
	@printf "$(BLUE)$(BOLD)📁 Available CloudFormation Deployment Methods:$(RESET)\n"
	@printf "\n"
	@printf "$(MAGENTA)$(BOLD)  1.$(RESET) $(CYAN)Method 1 - Event Bridge + Security Group$(RESET)\n"  
	@printf "     📄 Templates: event-bridge.yaml, security-group.yaml\n"
	@printf "     🎯 Purpose: Ec2 compute with ALB and automated deployment using EventBridge\n"
	@printf "\n"
	@printf "$(MAGENTA)$(BOLD)  2.$(RESET) $(CYAN)Method 2 - ECS Container Service$(RESET)\n"
	@printf "     📄 Templates: ecs.yaml\n"
	@printf "     🎯 Purpose: AWS Managed containerized application deployment\n"
	@printf "\n"
	@printf "$(YELLOW)$(BOLD)Please select a deployment method (1-2):$(RESET) "
	@read choice; \
	case $$choice in \
		1) \
			printf "\n"; \
			printf "$(GREEN)$(BOLD)🚀 Deploying Method 1 - Event Bridge + Security Group$(RESET)\n"; \
			$(MAKE) deploy-method-1; \
			;; \
		2) \
			printf "\n"; \
			printf "$(GREEN)$(BOLD)🚀 Deploying Method 2 - ECS Container Service$(RESET)\n"; \
			$(MAKE) deploy-method-2; \
			;; \
		*) \
			printf "\n"; \
			printf "$(RED)❌ Invalid selection. Please choose 1 or 2.$(RESET)\n"; \
			exit 1; \
			;; \
	esac

deploy-method-1:
	@printf "$(CYAN)$(BOLD)🔧 Deploying EC2 + Event Bridge + Security Group Stack...$(RESET)\n"
	@printf "$(YELLOW)📁 Templates: aws/method-1/security-group.yaml, aws/method-1/event-bridge.yaml$(RESET)\n"
	@printf "\n"
	@printf "$(BLUE)🔒 Deploying Security Group first...$(RESET)\n"
	@aws cloudformation deploy \
		--template-file aws/method-1/security-group.yaml \
		--stack-name security-group-stack \
		--profile $(AWS_PROFILE) \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset
	@printf "\n"
	@printf "$(BLUE)📡 Deploying Event Bridge...$(RESET)\n"
	@aws cloudformation deploy \
		--template-file aws/method-1/event-bridge.yaml \
		--stack-name event-bridge-stack \
		--profile $(AWS_PROFILE) \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset
	@printf "\n"
	@printf "$(GREEN)✅ Method 1 deployment completed successfully!$(RESET)\n"

deploy-method-2:
	@printf "$(CYAN)$(BOLD)🔧 Deploying ECS Container Service Stack...$(RESET)\n"
	@printf "$(YELLOW)📁 Template: aws/method-2/ecs.yaml$(RESET)\n"
	@printf "\n"
	@aws cloudformation deploy \
		--template-file aws/method-2/ecs.yaml \
		--stack-name ecs-stack \
		--profile $(AWS_PROFILE) \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset
	@printf "\n"
	@printf "$(GREEN)✅ Method 2 deployment completed successfully!$(RESET)\n"

list-stacks:
	@printf "$(CYAN)$(BOLD)📋 Current CloudFormation Stacks:$(RESET)\n"
	@printf "\n"
	@aws cloudformation list-stacks \
		--stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
		--profile $(AWS_PROFILE) \
		--query 'StackSummaries[].{Name:StackName,Status:StackStatus,Created:CreationTime}' \
		--output table


cleanup:
	@printf "$(YELLOW)$(BOLD)⚠️  This will delete ALL CloudFormation stacks created by this tool.$(RESET)\n"
	@printf "$(RED)Are you sure? (y/N):$(RESET) "
	@read confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		printf "$(RED)🗑️  Deleting stacks...$(RESET)\n"; \
		aws cloudformation delete-stack --stack-name event-bridge-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
		aws cloudformation delete-stack --stack-name security-group-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
		aws cloudformation delete-stack --stack-name ecs-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
		printf "$(GREEN)✅ Cleanup initiated. Stacks are being deleted...$(RESET)\n"; \
	else \
		printf "$(BLUE)ℹ️  Cleanup cancelled.$(RESET)\n"; \
	fi

.PHONY: setup-aws deploy-method-1 deploy-method-2 list-stacks cleanup help

help:
	@printf "$(CYAN)$(BOLD)🚀 AWS CloudFormation Deployment Tool$(RESET)\n"
	@printf "$(CYAN)=====================================$(RESET)\n"
	@printf "\n"
	@printf "$(YELLOW)$(BOLD)Available commands:$(RESET)\n"
	@printf "\n"
	@printf "  $(GREEN)make setup-aws$(RESET)      - Interactive template selection and deployment\n"
	@printf "  $(GREEN)make list-stacks$(RESET)    - List all active CloudFormation stacks\n"
	@printf "  $(GREEN)make cleanup$(RESET)        - Delete all stacks created by this tool\n"
	@printf "  $(GREEN)make help$(RESET)           - Show this help message\n"
	@printf "\n"
	@printf "$(BLUE)$(BOLD)Direct deployment options:$(RESET)\n"
	@printf "  $(GREEN)make deploy-method-1$(RESET) - Deploy Event Bridge + Security Group\n"
	@printf "  $(GREEN)make deploy-method-2$(RESET) - Deploy ECS Container Service\n"
	@printf "\n"
	@printf "$(MAGENTA)💡 Tip: Run '$(BOLD)make setup-aws$(RESET)$(MAGENTA)' for interactive deployment$(RESET)\n"
