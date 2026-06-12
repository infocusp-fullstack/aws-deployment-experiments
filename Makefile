AWS_PROFILE = default
AWS_REGION = ap-south-1
AWS_ACCOUNT_ID = $(shell aws sts get-caller-identity --profile $(AWS_PROFILE) --query "Account" --output text 2>/dev/null || echo "266735827942")

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
	@printf "$(MAGENTA)$(BOLD)  3.$(RESET) $(CYAN)Method 3a - EKS Kubernetes Service (EC2)$(RESET)\n"
	@printf "     📄 Templates: eks-ec2.yaml\n"
	@printf "     🎯 Purpose: AWS Managed Kubernetes cluster with EC2 nodes & ALB controller support\n"
	@printf "\n"
	@printf "$(MAGENTA)$(BOLD)  4.$(RESET) $(CYAN)Method 3b - EKS Kubernetes Service (Fargate)$(RESET)\n"
	@printf "     📄 Templates: eks-fargate.yaml\n"
	@printf "     🎯 Purpose: AWS Managed serverless Kubernetes cluster & ALB controller support\n"
	@printf "\n"
	@printf "$(YELLOW)$(BOLD)Please select a deployment method (1-4):$(RESET) "
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
		3) \
			printf "\n"; \
			printf "$(GREEN)$(BOLD)🚀 Deploying Method 3a - EKS Kubernetes Service (EC2)$(RESET)\n"; \
			$(MAKE) deploy-method-3-ec2; \
			;; \
		4) \
			printf "\n"; \
			printf "$(GREEN)$(BOLD)🚀 Deploying Method 3b - EKS Kubernetes Service (Fargate)$(RESET)\n"; \
			$(MAKE) deploy-method-3-fargate; \
			;; \
		*) \
			printf "\n"; \
			printf "$(RED)❌ Invalid selection. Please choose 1, 2, 3, or 4.$(RESET)\n"; \
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

deploy-method-3-ec2:
	@printf "$(CYAN)$(BOLD)🔧 Deploying EKS Kubernetes Service (EC2) Stack...$(RESET)\n"
	@printf "$(YELLOW)📁 Template: aws/method-3/eks-ec2.yaml$(RESET)\n"
	@printf "\n"
	@aws cloudformation deploy \
		--template-file aws/method-3/eks-ec2.yaml \
		--stack-name eks-ec2-stack \
		--profile $(AWS_PROFILE) \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset
	@printf "\n"
	@printf "$(GREEN)✅ Method 3a (EKS EC2) deployment completed successfully!$(RESET)\n"

deploy-method-3-fargate:
	@printf "$(CYAN)$(BOLD)🔧 Deploying EKS Kubernetes Service (Fargate) Stack...$(RESET)\n"
	@printf "$(YELLOW)📁 Template: aws/method-3/eks-fargate.yaml$(RESET)\n"
	@printf "\n"
	@aws cloudformation deploy \
		--template-file aws/method-3/eks-fargate.yaml \
		--stack-name eks-fargate-stack \
		--profile $(AWS_PROFILE) \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset
	@printf "\n"
	@printf "$(GREEN)✅ Method 3b (EKS Fargate) deployment completed successfully!$(RESET)\n"

list-stacks:
	@printf "$(CYAN)$(BOLD)📋 Current CloudFormation Stacks:$(RESET)\n"
	@printf "\n"
	@aws cloudformation list-stacks \
		--stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
		--profile $(AWS_PROFILE) \
		--query 'StackSummaries[].{Name:StackName,Status:StackStatus,Created:CreationTime}' \
		--output table

kubeconfig-ec2:
	@printf "$(CYAN)$(BOLD)🔧 Updating kubeconfig for EKS EC2 Cluster...$(RESET)\n"
	@aws eks update-kubeconfig --region $(AWS_REGION) --name aws-deployments-eks-ec2 --profile $(AWS_PROFILE)
	@printf "$(GREEN)✅ kubeconfig updated successfully!$(RESET)\n"

kubeconfig-fargate:
	@printf "$(CYAN)$(BOLD)🔧 Updating kubeconfig for EKS Fargate Cluster...$(RESET)\n"
	@aws eks update-kubeconfig --region $(AWS_REGION) --name aws-deployments-eks-fargate --profile $(AWS_PROFILE)
	@printf "$(GREEN)✅ kubeconfig updated successfully!$(RESET)\n"



setup-alb-controller-ec2:
	@$(MAKE) setup-alb-controller CLUSTER_NAME=aws-deployments-eks-ec2 STACK_NAME=eks-ec2-stack

setup-alb-controller-fargate:
	@$(MAKE) setup-alb-controller CLUSTER_NAME=aws-deployments-eks-fargate STACK_NAME=eks-fargate-stack

setup-alb-controller:
	@printf "$(CYAN)$(BOLD)🔧 Installing AWS Load Balancer Controller for $(CLUSTER_NAME)...$(RESET)\n"
	@ROLE_ARN=$$(aws cloudformation describe-stacks --stack-name $(STACK_NAME) --profile $(AWS_PROFILE) --query "Stacks[0].Outputs[?OutputKey=='ALBControllerRoleArn'].OutputValue" --output text); \
	printf "$(YELLOW)📋 IAM Role ARN: $$ROLE_ARN$(RESET)\n"; \
	helm repo add eks https://aws.github.io/eks-charts; \
	helm repo update; \
	helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
		-n kube-system \
		--set clusterName=$(CLUSTER_NAME) \
		--set serviceAccount.create=true \
		--set serviceAccount.name=aws-load-balancer-controller \
		--set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$$ROLE_ARN
	@printf "$(GREEN)✅ AWS Load Balancer Controller installed successfully for $(CLUSTER_NAME)!$(RESET)\n"

deploy-k8s:
	@printf "$(CYAN)$(BOLD)🚀 Deploying Applications to Kubernetes...$(RESET)\n"
	@sed -i "s/[0-9]\{12\}\.dkr\.ecr/$(AWS_ACCOUNT_ID).dkr.ecr/g" k8s/backend-deployment.yaml
	@sed -i "s/[0-9]\{12\}\.dkr\.ecr/$(AWS_ACCOUNT_ID).dkr.ecr/g" k8s/frontend-deployment.yaml
	@kubectl apply -f k8s/backend-deployment.yaml
	@kubectl apply -f k8s/frontend-deployment.yaml
	@kubectl apply -f k8s/ingress.yaml
	@printf "$(GREEN)✅ Kubernetes deployments and ingress applied successfully!$(RESET)\n"

cleanup:
	@printf "$(YELLOW)$(BOLD)⚠️  This will delete ALL CloudFormation stacks created by this tool.$(RESET)\n"
	@printf "$(RED)Are you sure? (y/N):$(RESET) "
	@read confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		printf "$(RED)🗑️  Deleting stacks...$(RESET)\n"; \
		aws cloudformation delete-stack --stack-name event-bridge-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
		aws cloudformation delete-stack --stack-name security-group-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
		aws cloudformation delete-stack --stack-name ecs-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
		aws cloudformation delete-stack --stack-name eks-ec2-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
		aws cloudformation delete-stack --stack-name eks-fargate-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
		printf "$(GREEN)✅ Cleanup initiated. Stacks are being deleted...$(RESET)\n"; \
	else \
		printf "$(BLUE)ℹ️  Cleanup cancelled.$(RESET)\n"; \
	fi

.PHONY: setup-aws deploy-method-1 deploy-method-2 deploy-method-3-ec2 deploy-method-3-fargate list-stacks kubeconfig-ec2 kubeconfig-fargate setup-alb-controller-ec2 setup-alb-controller-fargate setup-alb-controller deploy-k8s cleanup help

help:
	@printf "$(CYAN)$(BOLD)🚀 AWS CloudFormation Deployment Tool$(RESET)\n"
	@printf "$(CYAN)=====================================$(RESET)\n"
	@printf "\n"
	@printf "$(YELLOW)$(BOLD)Available commands:$(RESET)\n"
	@printf "\n"
	@printf "  $(GREEN)make setup-aws$(RESET)              - Interactive template selection and deployment\n"
	@printf "  $(GREEN)make list-stacks$(RESET)            - List all active CloudFormation stacks\n"
	@printf "  $(GREEN)make cleanup$(RESET)                - Delete all stacks created by this tool\n"
	@printf "  $(GREEN)make help$(RESET)                   - Show this help message\n"
	@printf "\n"
	@printf "$(BLUE)$(BOLD)Direct deployment options:$(RESET)\n"
	@printf "  $(GREEN)make deploy-method-1$(RESET)        - Deploy Event Bridge + Security Group\n"
	@printf "  $(GREEN)make deploy-method-2$(RESET)        - Deploy ECS Container Service\n"
	@printf "  $(GREEN)make deploy-method-3-ec2$(RESET)    - Deploy EKS Kubernetes Service (EC2)\n"
	@printf "  $(GREEN)make deploy-method-3-fargate$(RESET) - Deploy EKS Kubernetes Service (Fargate)\n"
	@printf "\n"
	@printf "$(BLUE)$(BOLD)Kubeconfig update options:$(RESET)\n"
	@printf "  $(GREEN)make kubeconfig-ec2$(RESET)         - Update kubeconfig for EKS EC2 cluster\n"
	@printf "  $(GREEN)make kubeconfig-fargate$(RESET)     - Update kubeconfig for EKS Fargate cluster\n"
	@printf "\n"
	@printf "$(BLUE)$(BOLD)AWS Load Balancer Controller options:$(RESET)\n"
	@printf "  $(GREEN)make setup-alb-controller-ec2$(RESET) - Install ALB controller on EKS EC2 cluster\n"
	@printf "  $(GREEN)make setup-alb-controller-fargate$(RESET) - Install ALB controller on EKS Fargate cluster\n"
	@printf "\n"
	@printf "$(BLUE)$(BOLD)Kubernetes Application Deployment options:$(RESET)\n"
	@printf "  $(GREEN)make deploy-k8s$(RESET)             - Deploy frontend, backend, and Ingress to current EKS cluster\n"
	@printf "\n"
	@printf "$(MAGENTA)💡 Tip: Run '$(BOLD)make setup-aws$(RESET)$(MAGENTA)' for interactive deployment$(RESET)\n"

