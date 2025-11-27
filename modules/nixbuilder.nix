{
  pkgs,
  ...
}:
{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "nixbld01.qa.ngdev.eu.ad.cuda-inc.com";
      sshUser = "nixbuilder";
      sshKey = "/etc/nix/nixbuilder";
      system = "x86_64-linux";
      supportedFeatures = [
        "nixos-test"
        "big-parallel"
        "kvm"
        "benchmark"
      ];
      maxJobs = 2;
      speedFactor = 1;
    }
    {
      hostName = "nixbld02.qa.ngdev.eu.ad.cuda-inc.com";
      sshUser = "nixbuilder";
      sshKey = "/etc/nix/nixbuilder";
      system = "x86_64-linux";
      supportedFeatures = [
        "nixos-test"
        "big-parallel"
        "kvm"
        "benchmark"
      ];
      maxJobs = 2;
      speedFactor = 1;
    }
    {
      hostName = "nixbld03.qa.ngdev.eu.ad.cuda-inc.com";
      sshUser = "nixbuilder";
      sshKey = "/etc/nix/nixbuilder";
      system = "x86_64-linux";
      supportedFeatures = [
        "nixos-test"
        "big-parallel"
        "kvm"
        "benchmark"
      ];
      maxJobs = 2;
      speedFactor = 1;
    }
  ];
}
