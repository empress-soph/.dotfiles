# This module extends home.file, xdg.configFile and xdg.dataFile with the `mutable` option.
# from https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa
{ config, lib, ... }:
let
  fileOptionAttrPaths =
    [ [ "home" "file" ] [ "xdg" "configFile" ] [ "xdg" "dataFile" ] ];
in {
  options = let

    mergeAttrsList = builtins.foldl' (lib.mergeAttrs) { };

    fileAttrsType = lib.types.attrsOf (lib.types.submodule ({ config, ... }: {
      options.mutable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to copy the file without the read-only attribute instead of
          symlinking. If you set this to `true`, you must also set `force` to
          `true`. Mutable files are not removed when you remove them from your
          configuration.

          This option is useful for programs that don't have a very good
          support for read-only configurations.
        '';
      };
    }));

  in mergeAttrsList (map (attrPath:
    lib.setAttrByPath attrPath (lib.mkOption { type = fileAttrsType; }))
    fileOptionAttrPaths);

  config = let
    allFiles = (builtins.concatLists (map
      (attrPath: builtins.attrValues (lib.getAttrFromPath attrPath config))
      fileOptionAttrPaths));

    filterMutableFiles = builtins.filter (file:
      (file.mutable or false) && lib.assertMsg file.force
      "if you specify `mutable` to `true` on a file, you must also set `force` to `true`");

    mutableFiles = filterMutableFiles allFiles;
  in {
    home.activation.mutableFileGenerationCleanup = let
      toCommand = (file:
        let
          source = lib.escapeShellArg file.source;
          target = lib.escapeShellArg file.target;
        in ''
          $VERBOSE_ECHO "! ${target}"

          if [ -d ${target} ]; then
            rm -rf ${target}
          elif [ -e ${target} ]; then
            rm -rf ${target}
          fi
        '');

      command = ''
        echo "Cleaning up old mutable home files for $HOME"
      '' + lib.concatLines (map toCommand mutableFiles);

    in (lib.hm.dag.entryBefore [ "linkGeneration" ] command);

    home.activation.mutableFileGeneration = let
      toCommand = (file:
        let
          source = lib.escapeShellArg file.source;
          target = lib.escapeShellArg file.target;
        in ''
          $VERBOSE_ECHO "${source} -> ${target}"

          if [ -L ${target} ]; then
            rm ${target}
          fi

          if [ -d ${source} ]; then
            $DRY_RUN_CMD cp -r --remove-destination --no-preserve=mode ${source} ${target}
          else
            $DRY_RUN_CMD cp --remove-destination --no-preserve=mode ${source} ${target}
          fi
        '');

      command = ''
        echo "Copying mutable home files for $HOME"
      '' + lib.concatLines (map toCommand mutableFiles);

    in (lib.hm.dag.entryAfter [ "linkGeneration" ] command);
  };
}
