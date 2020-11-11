# RG VARS

$REGION_NAME=eastus2
$RESOURCE_GROUP=rg_aksluis
$SUBNET_NAME=aks-subnet
$VNET_NAME=aks-vnet

az group create --name $RESOURCE_GROUP --location $REGION_NAME
