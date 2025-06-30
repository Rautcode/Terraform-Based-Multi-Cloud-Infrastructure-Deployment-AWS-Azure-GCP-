# Multi-Cloud Infrastructure Management Tool

A comprehensive PowerShell-based tool for managing infrastructure across AWS, Azure, and Google Cloud Platform using Terraform.

## 🚀 Features

- **Multi-Cloud Support**: Deploy and manage infrastructure across AWS, Azure, and GCP
- **User-Friendly CLI**: Interactive menus with color-coded options
- **Automated Setup**: Automatic installation of Terraform and cloud CLI tools
- **Safe Operations**: Confirmation prompts and validation checks
- **Cross-Platform**: Designed for Windows with PowerShell

## 📋 Prerequisites

### Required Software
- **Windows 10/11** with PowerShell 5.1 or later
- **Internet connection** for downloading tools and authenticating

### Automatically Installed
The tool will automatically install these if not present:
- **Terraform** (latest version)
- **AWS CLI** (v2.x)
- **Azure CLI** (latest)
- **Google Cloud CLI** (latest)

## 🛠️ Quick Setup

### 1. Clone or Download the Project
```powershell
# Navigate to your desired directory
cd "C:\Your\Desired\Path"

# Download or clone the multicloud project
```

### 2. Install Cloud CLI Tools
```powershell
# Run the installation script
.\install-cloud-tools.ps1 -All
```

### 3. Initialize Configuration Files
```powershell
# Run the setup script to create terraform.tfvars files
.\setup.ps1
```

### 4. Configure Cloud Authentication

#### AWS Configuration
```powershell
# Configure AWS credentials
.\configure-cloud-auth.ps1 -AWS

# Or manually:
aws configure
```

**You'll need:**
- Access Key ID
- Secret Access Key  
- Default region (e.g., `us-east-1`)
- Output format (`json`)

**Get credentials from:** AWS Console → IAM → Users → Your User → Security Credentials

#### Azure Configuration
```powershell
# Login to Azure
.\configure-cloud-auth.ps1 -Azure

# Or manually:
az login
```

#### Google Cloud Configuration
```powershell
# Login to GCP
.\configure-cloud-auth.ps1 -GCP

# Or manually:
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 5. Set Up Terraform Variables

For each cloud provider, copy the example variables file and customize:

#### AWS Setup
```powershell
cd aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS settings
```

#### Azure Setup  
```powershell
cd azure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Azure settings
```

#### GCP Setup
```powershell
cd gcp
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your GCP settings
```

## 🎯 Usage

### Run the Multi-Cloud Tool
```powershell
.\multicloud.ps1
```

### Available Options
1. **Create Infrastructure** - Deploy resources to selected cloud
2. **Destroy Infrastructure** - Remove resources from selected cloud  
3. **Exit** - Close the application

### Cloud Provider Selection
- **Option 1**: AWS (Amazon Web Services)
- **Option 2**: Azure (Microsoft Azure)
- **Option 3**: GCP (Google Cloud Platform)

## 📁 Project Structure

```
Multicloud/
├── multicloud.ps1                    # Main application script
├── install-cloud-tools.ps1           # CLI tools installation script
├── configure-cloud-auth.ps1          # Authentication configuration script
├── README.md                         # This file
├── aws/                              # AWS Terraform configurations
│   ├── main.tf                       # AWS resources definition
│   ├── variables.tf                  # AWS input variables
│   ├── outputs.tf                    # AWS output values
│   └── terraform.tfvars.example      # AWS configuration template
├── azure/                            # Azure Terraform configurations
│   ├── main.tf                       # Azure resources definition
│   ├── variables.tf                  # Azure input variables
│   ├── outputs.tf                    # Azure output values
│   └── terraform.tfvars.example      # Azure configuration template
└── gcp/                              # GCP Terraform configurations
    ├── main.tf                       # GCP resources definition
    ├── variables.tf                  # GCP input variables
    ├── outputs.tf                    # GCP output values
    └── terraform.tfvars.example      # GCP configuration template
```

## ⚙️ Infrastructure Details

### AWS
- **EC2 Instance**: Configurable instance type and AMI
- **Security**: Key pair authentication
- **Networking**: Default VPC with public IP

### Azure
- **Virtual Machine**: Linux VM with configurable size
- **Networking**: Virtual Network, Subnet, Public IP, Network Security Group
- **Security**: SSH access (port 22)
- **Authentication**: Username/password

### GCP
- **Compute Instance**: Configurable machine type and image
- **Networking**: Default network with external IP
- **Security**: Default firewall rules
- **Authentication**: Project-based access

## 🔧 Troubleshooting

### Common Issues

**1. PowerShell Execution Policy**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**2. PowerShell Color Errors**
If you see color-related errors, ensure only valid PowerShell console colors are used:
- Valid colors: Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White

**3. Terraform Not Found**
```powershell
# Refresh environment variables
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
```

**4. Authentication Issues**
```powershell
# Check authentication status
.\configure-cloud-auth.ps1 -Status

# Reconfigure specific provider
.\configure-cloud-auth.ps1 -AWS    # or -Azure or -GCP
```

**5. Missing terraform.tfvars**
```powershell
# Copy example file and edit
cp terraform.tfvars.example terraform.tfvars
```

**6. Terraform Version Constraint Errors**
If you see "Invalid version constraint" errors, check for:
- Typos in version syntax (should be `"~> 5.0"` not `"~>\`5.0"`)
- Correct provider sources (use `"hashicorp/aws"` not incorrect variants)
- Proper variable references in resource tags

**7. Script Hanging or Stuck**
If the script stops responding:
- **Missing terraform.tfvars**: Ensure each cloud directory has a `terraform.tfvars` file
- **Authentication not configured**: The script will hang if cloud credentials are missing
- **Interactive prompts**: Terraform may be waiting for variable input
- **Solution**: Press `Ctrl+C` to cancel, configure authentication, and ensure terraform.tfvars files exist

**8. Authentication Required Before Deployment**
The script now checks authentication before attempting deployments:
- **AWS**: Must run `aws configure` or `.\configure-cloud-auth.ps1 -AWS`
- **Azure**: Must run `az login` or `.\configure-cloud-auth.ps1 -Azure`  
- **GCP**: Must run `gcloud auth login` or `.\configure-cloud-auth.ps1 -GCP`

**9. PowerShell Syntax Errors**
If you see "Unexpected token" errors:
- Check for missing line breaks in the script
- Ensure proper spacing between commands
- Run `Get-Content .\multicloud.ps1 | Select-String "if"` to check for formatting issues

### Verification Commands

```powershell
# Check tool installations
terraform --version
aws --version
az --version
gcloud --version

# Check authentication
aws sts get-caller-identity
az account show
gcloud auth list
```

## 🛡️ Security Best Practices

1. **Never commit `terraform.tfvars`** files to version control
2. **Use strong passwords** for VM admin accounts
3. **Regularly rotate** cloud credentials
4. **Follow least privilege** principle for IAM roles
5. **Enable multi-factor authentication** on cloud accounts

## 📝 Example Configuration Files

### AWS terraform.tfvars
```hcl
region = "us-east-1"
selected_ami = "ami-0c02fb55956c7d316"  # Amazon Linux 2
instance_type = "t2.micro"
key_name = "your-key-pair-name"
instance_name = "aws-demo-instance"
```

### Azure terraform.tfvars
```hcl
subscription_id = "your-azure-subscription-id"
location = "East US"
resource_group_name = "multicloud-demo"
vm_name = "azure-vm-demo"
vm_size = "Standard_B1s"
admin_username = "azureuser"
admin_password = "YourSecurePassword123!"
image_publisher = "Canonical"
image_offer = "0001-com-ubuntu-server-focal"
image_sku = "20_04-lts-gen2"
```

### GCP terraform.tfvars
```hcl
project_id = "your-gcp-project-id"
region = "us-central1"
zone = "us-central1-a"
selected_image = "ubuntu-os-cloud/ubuntu-2004-lts"
instance_type = "e2-micro"
instance_name = "gcp-demo-instance"
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify all prerequisites are met
3. Check cloud provider documentation
4. Review Terraform error messages carefully

## 🔄 Updates

To update the tool:
```powershell
# Update Terraform
winget upgrade HashiCorp.Terraform

# Update cloud CLI tools
winget upgrade Amazon.AWSCLI
winget upgrade Microsoft.AzureCLI
winget upgrade Google.CloudSDK
```

---

**Happy Multi-Cloud Deploying! 🚀☁️**
