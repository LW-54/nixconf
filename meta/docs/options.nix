# Schema of the documentation registry: `docs.pages` (pages made of sections),
# `docs.sections.<kind>` (instance page templates), and `docs.project` metadata.
{lib, ...}: let
  inherit (lib) mkOption types;

  # A section is strictly { order, content (or body) }
  section = types.submodule {
    options = {
      order = mkOption {
        type = types.int;
        default = 100;
        description = "Visual sort order within the page.";
      };

      content = mkOption {
        type = types.nullOr (types.either types.str (types.functionTo (types.nullOr types.str)));
        default = null;
        description = "Markdown template string or function (ctx -> str | null).";
      };

      body = mkOption {
        type = types.nullOr (types.either types.str (types.functionTo (types.nullOr types.str)));
        default = null;
        description = "Markdown template string or function (ctx -> str | null). Alias for content.";
      };
    };
  };

  # A page is strictly { path, sections }
  page = types.submodule {
    options = {
      path = mkOption {
        type = types.str;
        description = "Output file path relative to repo root (e.g. 'docs/hosts/x240.md' or 'README.md').";
      };

      sections = mkOption {
        type = types.either (types.attrsOf section) (types.listOf section);
        default = {};
        description = "Sections composing the page body.";
      };
    };
  };
in {
  options.docs = {
    project = {
      name = mkOption {
        type = types.str;
        default = "❄️ nixconf";
        description = "Project name rendered as README title.";
      };
      tagline = mkOption {
        type = types.str;
        default = "Declarative multi-host infrastructure, contracts, and modular NixOS configuration repository powered by pure-Nix evaluation.";
        description = "One-line project summary rendered below the README title.";
      };
      flakeRef = mkOption {
        type = types.str;
        default = "github:LW-54/nixconf";
        description = "Public flake reference of this repository used in copy-paste snippets (e.g. `github:owner/repo`).";
      };
      url = mkOption {
        type = types.str;
        default = "https://github.com/LW-54/nixconf";
        description = "Git clone URL of this repository.";
      };
    };

    pages = mkOption {
      type = types.attrsOf page;
      default = {};
      description = "Registry of generated documentation pages keyed by page id. Any flake-parts module may contribute pages or sections.";
    };

    sections = mkOption {
      type = types.attrsOf (types.attrsOf section);
      default = {};
      description = ''
        Section templates added to every instance page of a primitive, keyed by primitive kind (or target page id).
      '';
    };
  };

  options.internal.docs = mkOption {
    type = types.lazyAttrsOf types.raw;
    default = {};
    description = "Internal documentation toolkit (markdown helpers, context builders, renderers).";
  };
}
