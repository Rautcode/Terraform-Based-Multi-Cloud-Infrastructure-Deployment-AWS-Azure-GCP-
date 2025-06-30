# 🌐 Terraform-Based Multi-Cloud Infrastructure Deployment

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Terraform](https://img.shields.io/badge/Terraform-1.0%2B-623CE4.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-supported-orange.svg)](https://aws.amazon.com/)
[![Azure](https://img.shields.io/badge/Azure-supported-0078D4.svg)](https://azure.microsoft.com/)
[![GCP](https://img.shields.io/badge/GCP-supported-4285F4.svg)](https://cloud.google.com/)

A comprehensive PowerShell-based automation tool for managing infrastructure across multiple cloud providers (AWS, Azure, GCP) using Terraform. This tool provides an interactive interface for creating, managing, and destroying cloud infrastructure with robust error handling and authentication management.

## 🚀 Features

- **Multi-Cloud Support**: Seamlessly manage infrastructure across AWS, Azure, and Google Cloud Platform
- **Interactive CLI**: User-friendly command-line interface with guided workflows
- **Terraform Integration**: Automated Terraform operations (init, plan, apply, destroy)
- **Authentication Management**: Built-in authentication validation and configuration
- **Error Handling**: Comprehensive error handling with detailed feedback
- **Security First**: Secure credential handling and Git-safe configuration
- **Validation Tools**: Built-in project structure and configuration validation
- **Cross-Platform**: Compatible with Windows PowerShell and PowerShell Core

## 📋 Prerequisites

### Required Software
- **PowerShell 5.1+** or **PowerShell Core 6.0+**
- **Terraform 1.0+** ([Installation Guide](https://developer.hashicorp.com/terraform/downloads))

### Cloud Provider CLIs
- **AWS CLI** ([Installation Guide](https://aws.amazon.com/cli/))
- **Azure CLI** ([Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- **Google Cloud CLI** ([Installation Guide](https://cloud.google.com/sdk/docs/install))

### Cloud Provider Accounts
- Active accounts with appropriate permissions for AWS, Azure, and/or GCP
- Configured authentication credentials for your target cloud providers

## 🛠️ Installation

### 1. Clone the Repository
```powershell
git clone https://github.com/Rautcode/Terraform-Based-Multi-Cloud-Infrastructure-Deployment-AWS-Azure-GCP-.git
cd Terraform-Based-Multi-Cloud-Infrastructure-Deployment-AWS-Azure-GCP-
```

### 2. Validate Project Structure
```powershell
.\tests\validate-simple.ps1
```

### 3. Check Prerequisites
```powershell
.\scripts\setup.ps1 -CheckOnly
```

## ⚙️ Configuration

### 1. Configure Cloud Authentication

#### Option A: Interactive Configuration
```powershell
.\scripts\configure-cloud-auth.ps1
```

#### Option B: Provider-Specific Configuration
```powershell
# Configure AWS
.\scripts\configure-cloud-auth.ps1 -AWS

# Configure Azure
.\scripts\configure-cloud-auth.ps1 -Azure

# Configure GCP
.\scripts\configure-cloud-auth.ps1 -GCP
```

#### Option C: Check Authentication Status
```powershell
.\scripts\configure-cloud-auth.ps1 -Status
```

### 2. Set Up Terraform Variables

For each cloud provider you plan to use, copy and customize the terraform.tfvars file:

```powershell
# AWS Configuration
cp "terraform\environments\aws\terraform.tfvars.example" "terraform\environments\aws\terraform.tfvars"

# Azure Configuration  
cp "terraform\environments\azure\terraform.tfvars.example" "terraform\environments\azure\terraform.tfvars"

# GCP Configuration
cp "terraform\environments\gcp\terraform.tfvars.example" "terraform\environments\gcp\terraform.tfvars"
```

Edit each `terraform.tfvars` file with your specific configuration values.

## 🚀 Usage

### Quick Start
```powershell
# Launch the interactive interface
.\run.ps1
```

### Alternative Launch Methods
```powershell
# Direct setup script
.\scripts\setup.ps1

# Main management interface
.\scripts\multicloud.ps1
```

### Interactive Workflow

1. **Launch the Tool**: Run `.\run.ps1`
2. **Select Action**: Choose to CREATE or DESTROY infrastructure
3. **Choose Provider**: Select AWS, Azure, or GCP
4. **Review Configuration**: Confirm your settings
5. **Execute**: The tool handles Terraform operations automatically

### Example Workflow
```powershell
PS> .\run.ps1

Multi-Cloud Infrastructure Management Tool v2.0
Launching interactive interface...

═══════════════════════════════════════════════════
    Multi-Cloud Infrastructure Management Tool     
═══════════════════════════════════════════════════

What would you like to do?

1. Create Infrastructure
2. Destroy Infrastructure
3. Exit

Enter your choice (1-3): 1

Select Cloud Provider:
1. AWS (Amazon Web Services)
2. Azure (Microsoft Azure)  
3. GCP (Google Cloud Platform)
4. Back to Main Menu

Enter your choice (1-3): 1

[Terraform operations execute automatically...]
```

## 📁 Project Structure

```
Multicloud/
├── run.ps1                          # Main launcher script
├── .gitignore                       # Git ignore rules (protects credentials)
├── README.md                        # This file
├── REFACTORING_PLAN.md             # Development documentation
├── REFACTORING_SUMMARY.md          # Refactoring details
├── PROJECT_COMPLETION_REPORT.md    # Project status report
│
├── scripts/                         # PowerShell automation scripts
│   ├── multicloud.ps1              # Main management interface
│   ├── setup.ps1                   # Interactive setup script
│   ├── configure-cloud-auth.ps1    # Authentication helper
│   └── install-cloud-tools.ps1     # Cloud tools installer
│
├── terraform/                      # Terraform configurations
│   └── environments/               # Environment-specific configs
│       ├── aws/                    # AWS infrastructure
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   ├── terraform.tfvars.example
│       │   └── terraform.tfvars    # Your AWS config (gitignored)
│       ├── azure/                  # Azure infrastructure
│       │   └── [similar structure]
│       └── gcp/                    # GCP infrastructure
│           └── [similar structure]
│
├── docs/                           # Additional documentation
│   └── [documentation files]
│
└── tests/                          # Validation and testing
    ├── validate-simple.ps1         # Basic validation
    └── full-validation.ps1         # Comprehensive testing
```

## 🛡️ Security

### Credential Protection
- All sensitive files are automatically excluded from Git via `.gitignore`
- Terraform state files are protected from accidental commits
- Private keys and certificates are automatically excluded
- Authentication tokens and credentials are never stored in the repository

### Best Practices
- Always use separate authentication for each environment
- Regularly rotate access keys and tokens
- Use least-privilege access principles
- Store sensitive configuration in `terraform.tfvars` files (gitignored)

## 🧪 Testing & Validation

### Basic Validation
```powershell
# Quick project structure check
.\tests\validate-simple.ps1
```

### Comprehensive Testing
```powershell
# Full validation suite
.\tests\full-validation.ps1

# Quick validation without interactive tests
.\tests\full-validation.ps1 -Quick
```

### Authentication Testing
```powershell
# Check all provider authentication status
.\scripts\configure-cloud-auth.ps1 -Status

# Test project setup
.\scripts\setup.ps1 -CheckOnly
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Terraform Not Found
```
Error: Terraform is not installed or not in PATH
```
**Solution**: Install Terraform and ensure it's in your system PATH.

#### 2. Authentication Errors
```
Error: Cloud provider authentication failed
```
**Solution**: Run `.\scripts\configure-cloud-auth.ps1 -Status` and configure the failing provider.

#### 3. Missing Configuration Files
```
Error: terraform.tfvars not found
```
**Solution**: Copy the example file and customize it:
```powershell
cp "terraform\environments\aws\terraform.tfvars.example" "terraform\environments\aws\terraform.tfvars"
```

#### 4. PowerShell Execution Policy
```
Error: Execution of scripts is disabled
```
**Solution**: Update your execution policy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Getting Help
```powershell
# Get help for any script
.\run.ps1 -Help
.\scripts\multicloud.ps1 -Help
.\scripts\setup.ps1 -Help
.\scripts\configure-cloud-auth.ps1 -Help
```

## 📚 Documentation

- **[REFACTORING_PLAN.md](REFACTORING_PLAN.md)**: Original development plan and architecture decisions
- **[REFACTORING_SUMMARY.md](REFACTORING_SUMMARY.md)**: Detailed refactoring process and changes
- **[PROJECT_COMPLETION_REPORT.md](PROJECT_COMPLETION_REPORT.md)**: Final project status and validation results
- **[docs/](docs/)**: Additional documentation and guides

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly using the validation scripts
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines
- Follow PowerShell best practices
- Include comprehensive error handling
- Add validation tests for new features
- Update documentation for any changes
- Ensure security best practices are maintained

## 📝 Changelog

### v2.0.0 - Current Release
- ✅ Complete project refactoring and reorganization
- ✅ Enhanced error handling and user experience
- ✅ Comprehensive validation and testing framework
- ✅ Improved security with robust `.gitignore` rules
- ✅ Multi-provider authentication management
- ✅ Interactive CLI interface with guided workflows
- ✅ Cross-platform PowerShell compatibility

### Previous Versions
- v1.x: Legacy single-file implementation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

If you encounter any issues or have questions:

1. Check the [Troubleshooting](#troubleshooting) section
2. Run the validation scripts to identify issues
3. Review the documentation in the `docs/` folder
4. Open an issue on GitHub with:
   - Your PowerShell version
   - Cloud provider(s) you're using
   - Error messages or unexpected behavior
   - Steps to reproduce the issue

## ⭐ Acknowledgments

- **Terraform**: For providing excellent infrastructure as code capabilities
- **Cloud Providers**: AWS, Microsoft Azure, and Google Cloud Platform
- **PowerShell Community**: For ongoing support and best practices
- **Contributors**: Thanks to all contributors who help improve this project

---

**🚀 Ready to deploy multi-cloud infrastructure with confidence!**

For the latest updates and releases, visit: [GitHub Repository](https://github.com/Rautcode/Terraform-Based-Multi-Cloud-Infrastructure-Deployment-AWS-Azure-GCP-)
