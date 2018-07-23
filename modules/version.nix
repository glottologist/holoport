{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.holoport;
  gitCommitId = lib.substring 0 7 cfg.revision;

  releaseFile = "${pkgs.holoportModules}/.version";
  suffixFile = "${pkgs.holoportModules}/.version-suffix";
  revisionFile = "${pkgs.holoportModules}/.git-revision";
  gitRepo = ../.git;

  gitRevision = if pathIsDirectory gitRepo then commitIdFromGitRepo gitRepo
    else if pathExists revisionFile then fileContents revisionFile
    else "master";

  release = fileContents releaseFile;
  versionSuffix = if pathIsDirectory gitRepo then ".${gitCommitId}"
    else if pathExists suffixFile then fileContents suffixFile
    else "pre-git";
  version = release + versionSuffix;

in

{
  options = {

    holoport.release = mkOption {
      type = types.str;
      default = release;
      readOnly = true;
    };

    holoport.revision = mkOption {
      type = types.str;
      default = gitRevision;
    };

    holoport.versionSuffix = mkOption {
      type = types.str;
      default = versionSuffix;
    };

    holoport.version = mkOption {
      type = types.str;
    };
  };

  config = {
    holoport.version = mkDefault (cfg.release + cfg.versionSuffix);
    system.nixos.label = "${config.system.nixos.version}+holoport-${cfg.version}";
  };
}