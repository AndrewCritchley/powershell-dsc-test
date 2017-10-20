configuration CreateIisSite
{
    Import-DscResource -Module xWebAdministration, PSDesiredStateConfiguration

    Node "localhost"
    {
        File Dir {
            Type            = 'Directory'
            DestinationPath = 'D:\Websites\DscTest'
            Ensure          = "Present"
        }
             
        File IndexHtml {
            Type            = 'File'
            DestinationPath = 'D:\Websites\DscTest\index.html'
            Contents        = "<h1>Hello DSC World</h1>"
            Ensure          = "Present"
        }

        xWebAppPool SampleAppPool {
            Name                  = 'DscTestAppPool'
            Ensure                = 'Present'
            State                 = 'Started'
            autoStart             = $true
            managedPipelineMode   = 'Integrated'
            managedRuntimeLoader  = 'webengine4.dll'
            managedRuntimeVersion = 'v4.0'
            startMode             = 'OnDemand'
            identityType          = 'ApplicationPoolIdentity'
            idleTimeout           = (New-TimeSpan -Minutes 30).ToString()
            idleTimeoutAction     = 'Terminate'
        }

        xWebsite NewWebsite {
            Ensure          = 'Present'
            Name            = "DscTestSite"
            State           = 'Started'
            ApplicationPool = 'DscTestAppPool'
            PhysicalPath    = "D:\Websites\DscTest"
            BindingInfo     = MSFT_xWebBindingInformation { 
                Protocol = "HTTP" 
                Port     = 8004
            } 
        }
    }
}

# Compile the configuration file to a MOF format
CreateIisSite

# Run the configuration on localhost
Start-DscConfiguration -Path .\CreateIisSite -Wait -Force -Verbose

