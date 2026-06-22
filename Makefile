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
	@printf "     🎯 Purpose: AWS Managed Kubernetes cluster with EC2 nodes & ALB ingress\n"
	@printf "\n"
	@printf "$(MAGENTA)$(BOLD)  4.$(RESET) $(CYAN)Method 3b - EKS Kubernetes Service (Fargate)$(RESET)\n"
	@printf "     📄 Templates: eks-fargate.yaml\n"
	@printf "     🎯 Purpose: AWS Managed serverless Kubernetes cluster & ALB ingress\n"
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

deploy-vpc:
	@printf "$(CYAN)$(BOLD)🔧 Deploying VPC Stack...$(RESET)\n"
	@printf "$(YELLOW)📁 Template: aws/method-3/vpc.yaml$(RESET)\n"
	@printf "\n"
	@aws cloudformation deploy \
		--template-file aws/method-3/vpc.yaml \
		--stack-name eks-vpc-stack \
		--profile $(AWS_PROFILE) \
		--no-fail-on-empty-changeset
	@printf "\n"
	@printf "$(GREEN)✅ VPC stack deployed successfully!$(RESET)\n"

deploy-method-3-ec2:
	@printf "$(CYAN)$(BOLD)🔧 Deploying EKS Kubernetes Service (EC2) Stack...$(RESET)\n"
	@printf "$(YELLOW)📁 Template: aws/method-3/eks-ec2.yaml$(RESET)\n"
	@printf "\n"
	@$(MAKE) deploy-vpc
	@printf "\n"
	@aws cloudformation deploy \
		--template-file aws/method-3/eks-ec2.yaml \
		--stack-name eks-ec2-stack \
		--profile $(AWS_PROFILE) \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset
	@printf "\n"
	@$(MAKE) kubeconfig-ec2
	@$(MAKE) setup-aws-lbc CLUSTER_NAME=aws-deployments-eks-ec2
	@printf "\n"
	@printf "$(GREEN)✅ Method 3a (EKS EC2) deployment completed successfully!$(RESET)\n"

deploy-method-3-fargate:
	@printf "$(CYAN)$(BOLD)🔧 Deploying EKS Kubernetes Service (Fargate) Stack...$(RESET)\n"
	@printf "$(YELLOW)📁 Template: aws/method-3/eks-fargate.yaml$(RESET)\n"
	@printf "\n"
	@$(MAKE) deploy-vpc
	@printf "\n"
	@aws cloudformation deploy \
		--template-file aws/method-3/eks-fargate.yaml \
		--stack-name eks-fargate-stack \
		--profile $(AWS_PROFILE) \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset
	@printf "\n"
	@$(MAKE) kubeconfig-fargate
	@$(MAKE) setup-aws-lbc CLUSTER_NAME=aws-deployments-eks-fargate
	@printf "$(YELLOW)🔄 Restarting CoreDNS to schedule on Fargate nodes...$(RESET)\n"
	@kubectl rollout restart deployment/coredns -n kube-system
	@kubectl rollout status deployment/coredns -n kube-system --timeout=180s
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

setup-aws-lbc:
	@printf "$(CYAN)$(BOLD)🔧 Setting up AWS Load Balancer Controller for cluster: $(CLUSTER_NAME)...$(RESET)\n"
	@OIDC_ISSUER=$$(aws eks describe-cluster --name "$(CLUSTER_NAME)" \
		--profile $(AWS_PROFILE) --region $(AWS_REGION) \
		--query "cluster.identity.oidc.issuer" --output text); \
	OIDC_HOST=$$(echo "$$OIDC_ISSUER" | sed 's|https://||'); \
	OIDC_ARN="arn:aws:iam::$(AWS_ACCOUNT_ID):oidc-provider/$$OIDC_HOST"; \
	if ! aws iam list-open-id-connect-providers --profile $(AWS_PROFILE) \
		--query "OpenIDConnectProviderList[].Arn" --output text 2>/dev/null | grep -q "$$OIDC_HOST"; then \
		printf "$(YELLOW)  Creating OIDC provider...$(RESET)\n"; \
		aws iam create-open-id-connect-provider \
			--url "$$OIDC_ISSUER" \
			--client-id-list "sts.amazonaws.com" \
			--thumbprint-list "9e99a48a9960b14926bb7f3b02e22da2b0ab7280" \
			--profile $(AWS_PROFILE) 2>/dev/null || true; \
	fi; \
	POLICY_ARN="arn:aws:iam::$(AWS_ACCOUNT_ID):policy/AWSLoadBalancerControllerIAMPolicy"; \
	if ! aws iam get-policy --policy-arn "$$POLICY_ARN" --profile $(AWS_PROFILE) >/dev/null 2>&1; then \
		printf "$(YELLOW)  Creating LBC IAM policy...$(RESET)\n"; \
		curl -fsSLo /tmp/lbc-iam-policy.json \
			https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v3.4.0/docs/install/iam_policy.json; \
		aws iam create-policy --policy-name "AWSLoadBalancerControllerIAMPolicy" \
			--policy-document file:///tmp/lbc-iam-policy.json --profile $(AWS_PROFILE); \
	fi; \
	ROLE_NAME="AWSLoadBalancerControllerRole-$(CLUSTER_NAME)"; \
	if ! aws iam get-role --role-name "$$ROLE_NAME" --profile $(AWS_PROFILE) >/dev/null 2>&1; then \
		printf "$(YELLOW)  Creating IAM role for LBC...$(RESET)\n"; \
		printf '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Federated":"%s"},"Action":"sts:AssumeRoleWithWebIdentity","Condition":{"StringEquals":{"%s:sub":"system:serviceaccount:kube-system:aws-load-balancer-controller","%s:aud":"sts.amazonaws.com"}}}]}' \
			"$$OIDC_ARN" "$$OIDC_HOST" "$$OIDC_HOST" > /tmp/lbc-trust-policy.json; \
		aws iam create-role --role-name "$$ROLE_NAME" \
			--assume-role-policy-document file:///tmp/lbc-trust-policy.json --profile $(AWS_PROFILE); \
		aws iam attach-role-policy --role-name "$$ROLE_NAME" \
			--policy-arn "$$POLICY_ARN" --profile $(AWS_PROFILE); \
	fi; \
	ROLE_ARN=$$(aws iam get-role --role-name "$$ROLE_NAME" --profile $(AWS_PROFILE) \
		--query "Role.Arn" --output text); \
	VPC_ID=$$(aws cloudformation describe-stacks --stack-name eks-vpc-stack \
		--profile $(AWS_PROFILE) \
		--query "Stacks[0].Outputs[?OutputKey=='VPCId'].OutputValue" --output text); \
	helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || true; \
	helm repo update; \
	helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
		-n kube-system \
		--set clusterName="$(CLUSTER_NAME)" \
		--set serviceAccount.create=true \
		--set serviceAccount.name=aws-load-balancer-controller \
		--set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=$$ROLE_ARN" \
		--set region=$(AWS_REGION) \
		--set vpcId="$$VPC_ID"
	@printf "$(GREEN)✅ AWS Load Balancer Controller installed successfully!$(RESET)\n"

deploy-k8s:
	@printf "$(CYAN)$(BOLD)🚀 Deploying Applications to Kubernetes...$(RESET)\n"
	@sed -i "s/[0-9]\{12\}\.dkr\.ecr/$(AWS_ACCOUNT_ID).dkr.ecr/g" k8s/backend-deployment.yaml
	@sed -i "s/[0-9]\{12\}\.dkr\.ecr/$(AWS_ACCOUNT_ID).dkr.ecr/g" k8s/frontend-deployment.yaml
	@kubectl apply -f k8s/backend-deployment.yaml
	@kubectl apply -f k8s/frontend-deployment.yaml
	@kubectl apply -f k8s/ingress.yaml
	@kubectl apply -f k8s/pdb.yaml
	@printf "$(GREEN)✅ Kubernetes deployments and ingress applied successfully!$(RESET)\n"

cleanup-cluster-lb:
	@printf "$(YELLOW)🧹 Cleaning up load balancer resources for cluster: $(CLUSTER_NAME)...$(RESET)\n"
	@LB_ARNS=$$(aws resourcegroupstaggingapi get-resources \
		--tag-filters "Key=kubernetes.io/cluster/$(CLUSTER_NAME),Values=owned" \
		--resource-type-filters "elasticloadbalancing:loadbalancer" \
		--profile $(AWS_PROFILE) \
		--query 'ResourceTagMappingList[].ResourceARN' --output text 2>/dev/null); \
	for ARN in $$LB_ARNS; do \
		printf "$(YELLOW)  Deleting load balancer: $$ARN$(RESET)\n"; \
		aws elbv2 delete-load-balancer --load-balancer-arn "$$ARN" --profile $(AWS_PROFILE) 2>/dev/null || true; \
	done; \
	if [ -n "$$LB_ARNS" ]; then \
		printf "$(YELLOW)⏳ Waiting for load balancers to finish deleting...$(RESET)\n"; \
		sleep 15; \
	fi; \
	TG_ARNS=$$(aws resourcegroupstaggingapi get-resources \
		--tag-filters "Key=kubernetes.io/cluster/$(CLUSTER_NAME),Values=owned" \
		--resource-type-filters "elasticloadbalancing:targetgroup" \
		--profile $(AWS_PROFILE) \
		--query 'ResourceTagMappingList[].ResourceARN' --output text 2>/dev/null); \
	for ARN in $$TG_ARNS; do \
		printf "$(YELLOW)  Deleting target group: $$ARN$(RESET)\n"; \
		aws elbv2 delete-target-group --target-group-arn "$$ARN" --profile $(AWS_PROFILE) 2>/dev/null || true; \
	done; \
	SG_IDS=$$(( \
		aws ec2 describe-security-groups --profile $(AWS_PROFILE) \
			--filters "Name=tag:elbv2.k8s.aws/cluster,Values=$(CLUSTER_NAME)" \
			--query 'SecurityGroups[].GroupId' --output text 2>/dev/null; \
		aws ec2 describe-security-groups --profile $(AWS_PROFILE) \
			--filters "Name=tag-key,Values=kubernetes.io/cluster/$(CLUSTER_NAME)" \
			--query 'SecurityGroups[].GroupId' --output text 2>/dev/null \
	) | tr ' ' '\n' | sort -u | tr '\n' ' '); \
	if [ -n "$$SG_IDS" ]; then \
		printf "$(YELLOW)⏳ Waiting 20s for SGs to be released...$(RESET)\n"; \
		sleep 20; \
	fi; \
	for SG in $$SG_IDS; do \
		printf "$(YELLOW)  Deleting security group: $$SG$(RESET)\n"; \
		aws ec2 delete-security-group --group-id "$$SG" --profile $(AWS_PROFILE) 2>/dev/null || true; \
	done; \
	printf "$(GREEN)✅ Load balancer cleanup complete for $(CLUSTER_NAME).$(RESET)\n"

cleanup-vpc-lb-resources:
	@printf "$(YELLOW)🧹 Cleaning up VPC load balancer resources created outside CloudFormation...$(RESET)\n"
	@VPC_ID=$$(aws cloudformation describe-stacks --stack-name eks-vpc-stack --profile $(AWS_PROFILE) \
		--query "Stacks[0].Outputs[?OutputKey=='VPCId'].OutputValue" --output text 2>/dev/null); \
	if [ -z "$$VPC_ID" ] || [ "$$VPC_ID" = "None" ]; then \
		printf "$(YELLOW)ℹ️  VPC stack not found or already deleted, skipping cleanup.$(RESET)\n"; \
	else \
		printf "$(YELLOW)📋 VPC ID: $$VPC_ID$(RESET)\n"; \
		printf "$(YELLOW)🔍 Deleting load balancers in VPC...$(RESET)\n"; \
		LB_ARNS=$$(aws elbv2 describe-load-balancers --profile $(AWS_PROFILE) \
			--query "LoadBalancers[?VpcId=='$$VPC_ID'].LoadBalancerArn" --output text 2>/dev/null); \
		for ARN in $$LB_ARNS; do \
			printf "$(YELLOW)  Deleting load balancer: $$ARN$(RESET)\n"; \
			aws elbv2 delete-load-balancer --load-balancer-arn "$$ARN" --profile $(AWS_PROFILE) 2>/dev/null || true; \
		done; \
		if [ -n "$$LB_ARNS" ]; then \
			printf "$(YELLOW)⏳ Waiting for load balancers to finish deleting...$(RESET)\n"; \
			sleep 15; \
		fi; \
		printf "$(YELLOW)🔍 Deleting target groups in VPC...$(RESET)\n"; \
		TG_ARNS=$$(aws elbv2 describe-target-groups --profile $(AWS_PROFILE) \
			--query "TargetGroups[?VpcId=='$$VPC_ID'].TargetGroupArn" --output text 2>/dev/null); \
		for ARN in $$TG_ARNS; do \
			printf "$(YELLOW)  Deleting target group: $$ARN$(RESET)\n"; \
			aws elbv2 delete-target-group --target-group-arn "$$ARN" --profile $(AWS_PROFILE) 2>/dev/null || true; \
		done; \
		printf "$(YELLOW)🔍 Deleting available ENIs in VPC...$(RESET)\n"; \
		ENI_IDS=$$(aws ec2 describe-network-interfaces --profile $(AWS_PROFILE) \
			--filters "Name=vpc-id,Values=$$VPC_ID" "Name=status,Values=available" \
			--query 'NetworkInterfaces[].NetworkInterfaceId' --output text 2>/dev/null); \
		for ENI in $$ENI_IDS; do \
			printf "$(YELLOW)  Deleting ENI: $$ENI$(RESET)\n"; \
			aws ec2 delete-network-interface --network-interface-id "$$ENI" --profile $(AWS_PROFILE) 2>/dev/null || true; \
		done; \
		printf "$(YELLOW)🔍 Deleting LBC-managed security groups in VPC...$(RESET)\n"; \
		SG_IDS=$$(aws ec2 describe-security-groups --profile $(AWS_PROFILE) \
			--filters "Name=vpc-id,Values=$$VPC_ID" "Name=tag-key,Values=elbv2.k8s.aws/cluster" \
			--query 'SecurityGroups[].GroupId' --output text 2>/dev/null); \
		for SG in $$SG_IDS; do \
			printf "$(YELLOW)  Deleting security group: $$SG$(RESET)\n"; \
			aws ec2 delete-security-group --group-id "$$SG" --profile $(AWS_PROFILE) 2>/dev/null || true; \
		done; \
		printf "$(GREEN)✅ VPC load balancer cleanup complete.$(RESET)\n"; \
	fi

cleanup:
	@printf "$(CYAN)$(BOLD)🗑️  CloudFormation Stack Cleanup$(RESET)\n"
	@printf "$(CYAN)================================$(RESET)\n"
	@printf "\n"
	@printf "$(YELLOW)$(BOLD)Active stacks:$(RESET)\n"
	@aws cloudformation list-stacks \
		--stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
		--profile $(AWS_PROFILE) \
		--query 'StackSummaries[?contains(`["eks-ec2-stack","eks-fargate-stack","eks-vpc-stack"]`, StackName)].{Name:StackName,Status:StackStatus}' \
		--output table 2>/dev/null || true
	@printf "\n"
	@printf "$(YELLOW)$(BOLD)Select what to delete:$(RESET)\n"
	@printf "  $(MAGENTA)$(BOLD)1.$(RESET) EKS EC2     (eks-ec2-stack)\n"
	@printf "  $(MAGENTA)$(BOLD)2.$(RESET) EKS Fargate (eks-fargate-stack)\n"
	@printf "  $(MAGENTA)$(BOLD)3.$(RESET) VPC         (eks-vpc-stack) — cleans up load balancers first\n"
	@printf "  $(MAGENTA)$(BOLD)4.$(RESET) All         (EKS stacks → LB cleanup → VPC)\n"
	@printf "\n"
	@printf "$(RED)Choice (1-4):$(RESET) "
	@read choice; \
	printf "\n"; \
	printf "$(RED)⚠️  Are you sure? (y/N):$(RESET) "; \
	read confirm; \
	if [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
		printf "$(BLUE)ℹ️  Cleanup cancelled.$(RESET)\n"; \
		exit 0; \
	fi; \
	case $$choice in \
		1) \
			OIDC_HOST=$$(aws eks describe-cluster --name aws-deployments-eks-ec2 \
				--profile $(AWS_PROFILE) --region $(AWS_REGION) \
				--query "cluster.identity.oidc.issuer" --output text 2>/dev/null | sed 's|https://||'); \
			printf "$(RED)🗑️  Deleting EKS EC2 stack...$(RESET)\n"; \
			aws cloudformation delete-stack --stack-name eks-ec2-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
			printf "$(YELLOW)⏳ Waiting for deletion to complete...$(RESET)\n"; \
			aws cloudformation wait stack-delete-complete --stack-name eks-ec2-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
			$(MAKE) cleanup-cluster-lb CLUSTER_NAME=aws-deployments-eks-ec2; \
			printf "$(YELLOW)🧹 Cleaning up LBC IAM resources...$(RESET)\n"; \
			aws iam detach-role-policy \
				--role-name "AWSLoadBalancerControllerRole-aws-deployments-eks-ec2" \
				--policy-arn "arn:aws:iam::$(AWS_ACCOUNT_ID):policy/AWSLoadBalancerControllerIAMPolicy" \
				--profile $(AWS_PROFILE) 2>/dev/null || true; \
			aws iam delete-role --role-name "AWSLoadBalancerControllerRole-aws-deployments-eks-ec2" \
				--profile $(AWS_PROFILE) 2>/dev/null || true; \
			if [ -n "$$OIDC_HOST" ]; then \
				aws iam delete-open-id-connect-provider \
					--open-id-connect-provider-arn "arn:aws:iam::$(AWS_ACCOUNT_ID):oidc-provider/$$OIDC_HOST" \
					--profile $(AWS_PROFILE) 2>/dev/null || true; \
			fi; \
			printf "$(GREEN)✅ EKS EC2 stack deleted.$(RESET)\n"; \
			;; \
		2) \
			OIDC_HOST=$$(aws eks describe-cluster --name aws-deployments-eks-fargate \
				--profile $(AWS_PROFILE) --region $(AWS_REGION) \
				--query "cluster.identity.oidc.issuer" --output text 2>/dev/null | sed 's|https://||'); \
			printf "$(RED)🗑️  Deleting EKS Fargate stack...$(RESET)\n"; \
			aws cloudformation delete-stack --stack-name eks-fargate-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
			printf "$(YELLOW)⏳ Waiting for deletion to complete...$(RESET)\n"; \
			aws cloudformation wait stack-delete-complete --stack-name eks-fargate-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
			$(MAKE) cleanup-cluster-lb CLUSTER_NAME=aws-deployments-eks-fargate; \
			printf "$(YELLOW)🧹 Cleaning up LBC IAM resources...$(RESET)\n"; \
			aws iam detach-role-policy \
				--role-name "AWSLoadBalancerControllerRole-aws-deployments-eks-fargate" \
				--policy-arn "arn:aws:iam::$(AWS_ACCOUNT_ID):policy/AWSLoadBalancerControllerIAMPolicy" \
				--profile $(AWS_PROFILE) 2>/dev/null || true; \
			aws iam delete-role --role-name "AWSLoadBalancerControllerRole-aws-deployments-eks-fargate" \
				--profile $(AWS_PROFILE) 2>/dev/null || true; \
			if [ -n "$$OIDC_HOST" ]; then \
				aws iam delete-open-id-connect-provider \
					--open-id-connect-provider-arn "arn:aws:iam::$(AWS_ACCOUNT_ID):oidc-provider/$$OIDC_HOST" \
					--profile $(AWS_PROFILE) 2>/dev/null || true; \
			fi; \
			printf "$(GREEN)✅ EKS Fargate stack deleted.$(RESET)\n"; \
			;; \
		3) \
			printf "$(YELLOW)🧹 Cleaning up load balancer resources before VPC deletion...$(RESET)\n"; \
			$(MAKE) cleanup-vpc-lb-resources; \
			printf "$(RED)🗑️  Deleting VPC stack...$(RESET)\n"; \
			aws cloudformation delete-stack --stack-name eks-vpc-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
			printf "$(GREEN)✅ VPC stack deletion initiated.$(RESET)\n"; \
			;; \
		4) \
			OIDC_HOST_EC2=$$(aws eks describe-cluster --name aws-deployments-eks-ec2 \
				--profile $(AWS_PROFILE) --region $(AWS_REGION) \
				--query "cluster.identity.oidc.issuer" --output text 2>/dev/null | sed 's|https://||'); \
			OIDC_HOST_FARGATE=$$(aws eks describe-cluster --name aws-deployments-eks-fargate \
				--profile $(AWS_PROFILE) --region $(AWS_REGION) \
				--query "cluster.identity.oidc.issuer" --output text 2>/dev/null | sed 's|https://||'); \
			printf "$(RED)🗑️  Deleting all EKS stacks...$(RESET)\n"; \
			aws cloudformation delete-stack --stack-name eks-ec2-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
			aws cloudformation delete-stack --stack-name eks-fargate-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
			printf "$(YELLOW)⏳ Waiting for EKS stacks to finish before removing VPC...$(RESET)\n"; \
			aws cloudformation wait stack-delete-complete --stack-name eks-ec2-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
			aws cloudformation wait stack-delete-complete --stack-name eks-fargate-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
			$(MAKE) cleanup-vpc-lb-resources; \
			printf "$(YELLOW)🧹 Cleaning up LBC IAM resources...$(RESET)\n"; \
			for CLUSTER in aws-deployments-eks-ec2 aws-deployments-eks-fargate; do \
				aws iam detach-role-policy \
					--role-name "AWSLoadBalancerControllerRole-$$CLUSTER" \
					--policy-arn "arn:aws:iam::$(AWS_ACCOUNT_ID):policy/AWSLoadBalancerControllerIAMPolicy" \
					--profile $(AWS_PROFILE) 2>/dev/null || true; \
				aws iam delete-role --role-name "AWSLoadBalancerControllerRole-$$CLUSTER" \
					--profile $(AWS_PROFILE) 2>/dev/null || true; \
			done; \
			aws iam delete-policy \
				--policy-arn "arn:aws:iam::$(AWS_ACCOUNT_ID):policy/AWSLoadBalancerControllerIAMPolicy" \
				--profile $(AWS_PROFILE) 2>/dev/null || true; \
			if [ -n "$$OIDC_HOST_EC2" ]; then \
				aws iam delete-open-id-connect-provider \
					--open-id-connect-provider-arn "arn:aws:iam::$(AWS_ACCOUNT_ID):oidc-provider/$$OIDC_HOST_EC2" \
					--profile $(AWS_PROFILE) 2>/dev/null || true; \
			fi; \
			if [ -n "$$OIDC_HOST_FARGATE" ]; then \
				aws iam delete-open-id-connect-provider \
					--open-id-connect-provider-arn "arn:aws:iam::$(AWS_ACCOUNT_ID):oidc-provider/$$OIDC_HOST_FARGATE" \
					--profile $(AWS_PROFILE) 2>/dev/null || true; \
			fi; \
			aws cloudformation delete-stack --stack-name eks-vpc-stack --profile $(AWS_PROFILE) 2>/dev/null || true; \
			printf "$(GREEN)✅ All stacks deleted.$(RESET)\n"; \
			;; \
		*) \
			printf "$(RED)❌ Invalid selection.$(RESET)\n"; \
			exit 1; \
			;; \
	esac

.PHONY: setup-aws deploy-method-1 deploy-method-2 deploy-vpc deploy-method-3-ec2 deploy-method-3-fargate list-stacks kubeconfig-ec2 kubeconfig-fargate setup-aws-lbc deploy-k8s cleanup cleanup-vpc-lb-resources cleanup-cluster-lb help

help:
	@printf "$(CYAN)$(BOLD)🚀 AWS CloudFormation Deployment Tool$(RESET)\n"
	@printf "$(CYAN)=====================================$(RESET)\n"
	@printf "\n"
	@printf "$(YELLOW)$(BOLD)Available commands:$(RESET)\n"
	@printf "\n"
	@printf "  $(GREEN)make setup-aws$(RESET)              - Interactive template selection and deployment\n"
	@printf "  $(GREEN)make list-stacks$(RESET)            - List all active CloudFormation stacks\n"
	@printf "  $(GREEN)make cleanup$(RESET)                - Delete stacks created by this tool\n"
	@printf "  $(GREEN)make help$(RESET)                   - Show this help message\n"
	@printf "\n"
	@printf "$(BLUE)$(BOLD)Direct deployment options:$(RESET)\n"
	@printf "  $(GREEN)make deploy-method-1$(RESET)        - Deploy Event Bridge + Security Group\n"
	@printf "  $(GREEN)make deploy-method-2$(RESET)        - Deploy ECS Container Service\n"
	@printf "  $(GREEN)make deploy-vpc$(RESET)             - Deploy shared VPC stack (auto-called by method-3)\n"
	@printf "  $(GREEN)make deploy-method-3-ec2$(RESET)    - Deploy EKS Kubernetes Service (EC2)\n"
	@printf "  $(GREEN)make deploy-method-3-fargate$(RESET) - Deploy EKS Kubernetes Service (Fargate)\n"
	@printf "\n"
	@printf "$(BLUE)$(BOLD)Kubeconfig update options:$(RESET)\n"
	@printf "  $(GREEN)make kubeconfig-ec2$(RESET)         - Update kubeconfig for EKS EC2 cluster\n"
	@printf "  $(GREEN)make kubeconfig-fargate$(RESET)     - Update kubeconfig for EKS Fargate cluster\n"
	@printf "\n"
	@printf "$(BLUE)$(BOLD)AWS Load Balancer Controller:$(RESET)\n"
	@printf "  $(GREEN)make setup-aws-lbc$(RESET) CLUSTER_NAME=<name>  - Install AWS LBC on cluster\n"
	@printf "\n"
	@printf "$(BLUE)$(BOLD)Kubernetes Application Deployment:$(RESET)\n"
	@printf "  $(GREEN)make deploy-k8s$(RESET)             - Deploy frontend, backend, and ingress\n"
	@printf "\n"
	@printf "$(MAGENTA)💡 Tip: Run '$(BOLD)make setup-aws$(RESET)$(MAGENTA)' for interactive deployment$(RESET)\n"
