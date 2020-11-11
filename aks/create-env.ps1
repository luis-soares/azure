# Luis Antonio Soares da Silva (luissoares@outlook.com / lui_eu@msn.com)
# output formats
# https://docs.microsoft.com/en-us/cli/azure/format-output-azure-cli


# RG VARS
$REGION_NAME="eastus2"
$RESOURCE_GROUP="rg_aksluis"
$SUBNET_NAME="aks-subnet"
$VNET_NAME="aks-vnet"

# Set AKS Cluster Data 
$PREFIX_AKS_CLUSTER_NAME="aksclluis" # Name prefix
$AKS_NODE_COUNT="2" # Node count, 2 to use on free tier.

# K8s Namespace (Namespace on K8s is a logical isolation)
$KUBE_NAMESPACE="lurenapp"


############## END OF VARS #############################


# create AZ Resource Group
az group create `
  --name $RESOURCE_GROUP `
  --location $REGION_NAME

# create AZ Network
az network vnet create `
  --resource-group $RESOURCE_GROUP `
  --location $REGION_NAME `
  --name $VNET_NAME `
  --address-prefixes 10.0.0.0/8 `
  --subnet-name $SUBNET_NAME `
  --subnet-prefixes 10.240.0.0/16

# Get network information and put on subnet_id variable.
$SUBNET_ID=$(az network vnet subnet show `
  --resource-group $RESOURCE_GROUP `
  --vnet-name $VNET_NAME `
  --name $SUBNET_NAME `
  --query id -o tsv)


# Create AKS Cluster  

# get latest K8s version, non-preview...
$VERSION=$(az aks get-versions `
  --location $REGION_NAME `
  --query 'orchestrators[?!isPreview] | [-1].orchestratorVersion' `
  --output tsv)

# create cluster AKS Name
$AKS_CLUSTER_NAME="$PREFIX_AKS_CLUSTER_NAME-$(Get-Random)"

# Create cluster 

az aks create `
--resource-group $RESOURCE_GROUP `
--name $AKS_CLUSTER_NAME `
--vm-set-type "VirtualMachineScaleSets" `
--node-count $AKS_NODE_COUNT `
--load-balancer-sku "standard" `
--location $REGION_NAME `
--kubernetes-version $VERSION `
--network-plugin "azure" `
--vnet-subnet-id $SUBNET_ID `
--service-cidr "10.2.0.0/24" `
--dns-service-ip "10.2.0.10" `
--docker-bridge-address "172.17.0.1/16" `
--generate-ssh-keys



# generated credentials
az aks get-credentials `
  --resource-group $RESOURCE_GROUP `
  --name $AKS_CLUSTER_NAME

# check nodes
kubectl get nodes

#create namespace
kubectl create namespace $KUBE_NAMESPACE

#check namespaces
kubectl get namespace