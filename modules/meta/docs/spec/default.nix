{config, ...}: let
  c = config.internal.docs.spec.core;
  f = config.internal.docs.spec.functions;
  o = config.internal.docs.spec.options;
  p = config.internal.docs.spec.primitives;
  m = config.internal.docs.spec.meta;
in {
  flake.lib.docsSpec =
    c
    // f
    // o
    // p
    // m
    // {
      core = c;
      functions = f;
      options = o;
      primitives = p;
      meta = m;
    };
}
